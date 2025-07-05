string EXTERNAL_API_KEY = "KINDROID-API-KEY-HERE";
string AI_ID = "KINDROID-AI-ID-HERE";
// Define constants
string API_ENDPOINT = "https://api.kindroid.ai/v1/send-message";
list ANIMS = ["express_afraid", "dance1", "dance2", "dance3", "express_anger", "backflip", "express_laugh", "blowkiss", "express_bored", "clap", "courtbow", "crouch", "express_cry", "dead", "drink", "falldown", "angry_fingerwag", "fist_pump", "hello", "impatient", "jumpforjoy", "no_head", "no_unhappy", "express_repulsed", "kick_roundhouse_r", "express_sad", "salute", "express_shrug", "stretch", "surf", "express_surprise", "angry_tantrum", "type", "whistle", "wink_hollywood", "express_worry", "yes_head", "yes_happy", "yoga_float"];
string previousAnim;
playAnimation(string anim)
{
   if (previousAnim) llStopObjectAnimation(previousAnim);
   llStartObjectAnimation(anim);
   previousAnim = anim;
}
stopAllAnimations()
{
   list curr_anims = llGetObjectAnimationNames();
   integer length = llGetListLength(curr_anims);
   integer index = 0;
   while (index < length)
   {
       string anim = llList2String(curr_anims, index);
       llStopObjectAnimation(anim);
       ++index;
   }
}
default
{
   http_response(key request_id, integer status, list metadata, string body)
   {
       // Handle the response from the API
       if (status == 200)
       {
           list commands = [];
           integer startIndex = llSubStringIndex(body, "(");
           integer endIndex;
           while (llStringLength(body) > 0)
           {
               startIndex = llSubStringIndex(body, "(");
               if (startIndex == 0)
               {
                   // Found a command at the beginning
                   endIndex = llSubStringIndex(body, ")");
                   if (endIndex != -1)
                   {
                       string command = llGetSubString(body, startIndex + 1, endIndex - 1); // Extract the command
                       commands += command; // Add command to the list
                       body = llDeleteSubString(body, startIndex, endIndex); // Remove the processed command
                   }
                   else body = llDeleteSubString(body, 0, 0); // broken command statement, just drop the 1st '(' and treat it as speech)
               }
               else if (startIndex != -1)
               {
                   // There's some text (speech) before the next command
                   string speech = llGetSubString(body, 0, startIndex - 1);
                   if (llStringTrim(speech, STRING_TRIM) != "") commands += speech; // Add speech to the list as is
                   body = llDeleteSubString(body, 0, startIndex - 1); // Remove the processed speech
               }
               else
               {
                   // No more commands; treat the remaining text as speech
                   if (llStringTrim(body, STRING_TRIM) != "") commands += llStringTrim(body, STRING_TRIM); // Add the final speech segment as is
                   body = ""; // Clear the body
               }
           }
           // Process the list of commands
           integer i;
           for (i = 0; i < llGetListLength(commands); i++)
           {
               string command = llList2String(commands, i);
               if (llSubStringIndex(command, "animate") == 0)
               {
                   string anim = llGetSubString(command, 8, -1);
                   // only play approved animations so we don't throw errors
                   if (llListFindList(ANIMS, [anim]) != -1) playAnimation(anim);
               }
               else if (llSubStringIndex(command, "pause") == 0) llSleep((float)llGetSubString(command, 6, -1));
               else llSay(0, command); // speak
           }
       }
       else llOwnerSay("Error: Failed to send message to API. Status: " + (string)status);
   }
   // Relay the message to the API if the owner speaks to the AI
   listen(integer channel, string name, key id, string message)
   {
       if (llSubStringIndex(message, "/kindroid ") == 0)
       {
           // remove prefix
           message = llGetSubString(message, 10, -1);
           // Construct the JSON payload
           string json = "{\"ai_id\": \"" + AI_ID + "\", \"message\": \"" + message + "\"}";
           // Set the HTTP headers
           list headers = [
               HTTP_METHOD, "POST",
               HTTP_MIMETYPE, "application/json",
               HTTP_CUSTOM_HEADER, "Authorization", "Bearer " + EXTERNAL_API_KEY, // authenticate with the external API
               HTTP_BODY_MAXLENGTH, 16384 // allow for a larger response size
           ];
           // Make the HTTP POST request
           key request_id = llHTTPRequest(API_ENDPOINT, headers, json);
           if (request_id = NULL_KEY) llOwnerSay("Error: HTTP POST request ID is NULL_KEY, indicating a request initiation problem.");
       }
   }
   state_entry()
   {
       stopAllAnimations();
       llListen(0, "", llGetOwner(), "");
       llOwnerSay("AI has arrived.");
   }
}
