string EXTERNAL_API_KEY = "KINDROID-API-KEY-HERE";
string AI_ID = "KINDROID-AI-ID-HERE";
// Define constants
string API_ENDPOINT = "https://api.kindroid.ai/v1/send-message";
integer PRIVATE_CHANNEL = 0;
// Function to send a message via the API
sendAPIMessage(string message)
{
   // Construct the JSON payload
   string json = "{\"ai_id\": \"" + AI_ID + "\", \"message\": \"" + message + "\"}";
   // Set the HTTP headers
   list headers = [
       HTTP_METHOD, "POST",
      HTTP_MIMETYPE, "application/json",
      HTTP_CUSTOM_HEADER, "Authorization", "Bearer " + EXTERNAL_API_KEY
   ];
   // Make the HTTP POST request
   llHTTPRequest(API_ENDPOINT, headers, json);
}
// Function to process and split message into "/me" actions and regular text
processAndSendChatMessage(string message)
{
   integer start = 0;
   integer end = 0;
   while ((start = llSubStringIndex(message, "*")) != -1)
   {
       // Send any text before the action
       if (start > 0)
       {
           string beforeAction = llGetSubString(message, 0, start - 1);
           if (llStringLength(llStringTrim(beforeAction, STRING_TRIM)) > 0)
               llSay(0, llStringTrim(beforeAction, STRING_TRIM));
       }
       // Find the end of the action (next asterisk)
       end = llSubStringIndex(llGetSubString(message, start + 1, -1), "*") + start + 1;
       if (end > start)
       {
           // Send the "/me" action
           llSay(0, "/me " + llGetSubString(message, start + 1, end - 1));
           // Remove the processed part from the message
           message = llDeleteSubString(message, 0, end + 1);
       }
       else
       {
           // If no closing asterisk is found, return to avoid infinite loop
           return;
       }
   }
   // Send any remaining part of the message after all actions have been processed
   if (llStringLength(llStringTrim(message, STRING_TRIM)) > 0)
       llSay(0, llStringTrim(message, STRING_TRIM));
}


// Listen for chat messages
default {
   state_entry()
  {
       llListen(0, "", llGetOwner(), "");
   }
   listen(integer channel, string name, key id, string message)
  {
       // Check if the message is a chat to the AI from the owner
       if (llSubStringIndex(message, "/kindroid ") == 0)
       {
           // Extract the message after the command
           string apiMessage = llStringTrim(llDeleteSubString(message, 0, 9), STRING_TRIM);
           sendAPIMessage(apiMessage);
       }
   }
   // Handle the response from the API
   http_response(key request_id, integer status, list metadata, string body)
  {
       // If the API request was successful, process the text
       if (status == 200) processAndSendChatMessage(body);
       // Otherwise, notify the owner of the issue.
       else llOwnerSay("Error: Failed to send message to API. Status: " + (string)status);
   }
