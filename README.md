# Kindroid-NPCs-in-Second-Life
Code by Linden Labs to allow objects and avatars in Second Life connect to the Kindroid AI API.

Orginal code and message at:  https://community.secondlife.com/forums/topic/515359-introducing-kindroid-ai-npcs-companions-in-second-life/

Second Life and Linden Lab have always embraced experimentation, and we're excited to introduce a new way to connect GenAI to in-world content. Through the integration of AI companions and NPCs using Kindroid, you can add complexity and excitement to your Second Life experiences. With Kindroid, you can create engaging and lively characters with lifelike memory, intelligence, and personalities that interact and engage in emotionally-deep and meaningful ways - and then bring them to life within our virtual world. Imagine crafting characters that add fun and engaging new narratives into your roleplaying adventures - or maybe you’ll create a companion that can serve as a language tutor or mentor - the possibilities are endless!

With its API, you can integrate Kindroid characters into your Second Life experience using LSL and scripting, just like other objects. Whether you’re looking to enhance social interactions or explore new storytelling possibilities, Kindroid offers an exciting new dimension for any Second Life adventure.

To get started, you’ll need to create a Kindroid account and obtain your API key along with the character key. Once you have these, you can use the provided LSL template to enable any object in-world to communicate with your AI companion. While you can link the Kindroid API to any object, using animesh is recommended to help maintain the immersive role-playing functionality. By following the below steps, you can easily bring your Kindroid characters to life in SL.

Important Considerations for API Security

When integrating Kindroid into your Second Life experience, keeping your API keys secure is essential. These are entered manually in the sample scripts, giving them access to your Kindroid account interface. Be sure your scripts are set so that people can not copy or modify.

Recommended permissions on your AI bot object (right-click on it and pick 'edit' and the 'General' tab):

image.jpeg

Recommended permissions on the script in the object inventory properties (from the Content tab in the object editor, right-click your script and examine "Properties"):

image.png

These settings will block other people from examining your source code.

Account Setup & Integration 

Note: For Residents who have a Kindroid account, skip to step 5.
Getting started with Kindroid is simple. Here’s how you can set up your account and start creating your own AI companions. 

    Visit https://kindroid.ai/login/ in a web browser and create an account and Kindroid character.
    Sign up to create your profile and check your email for an activation link:
        k_step1.png
    Once logged in, you’ll be prompted to design your first Kindroid, which can be updated at any time in your account:
        k_step2.png
    Choose from various appearance options, personality traits, and conversation styles to build a character that suits your preferences:
        k_step3.png k_step3-a.jpg
    After setting up your Kindroid, you will be presented with a chat window for that character. Click the hamburger icon in the top left corner to open the Settings window:
        k_step5.png
        Note: the free 3-day trial includes 1 Kindroid slot and 3 days of unlimited messaging. After that point you will be downgraded to the freemium plan with message restrictions.
    In the Settings window click “General” and scroll down to the bottom. Click “API & advanced integrations” dropdown and click “Get API key”. Copy both your API Key and your Kindroid’s AI ID:
        k_step6.png
    With your API Key and AI ID, you can now call the Kindroid message endpoint https://api.kindroid.ai/v1/send-message with appropriate headers to get a response. Below is a starter LSL script which will allow you to communicate with your Kindroid from Second Life:

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
        }

    Using the LSL script above:
        Attach it to any object you like—this will be the "body" for your Kindroid.
            We recommend one of the hundreds of animesh characters available on the Marketplace.
                Find a humanoid character with the usual number of legs, arms and heads.
                Confirm that the object has copy and modify permissions on the Marketplace listing page:
                    image.jpeg
        Rename the object to match your Kindroid's name for roleplay formatting with "/me" output.
        Remove any existing scripts from the character.
        Talk to your Kindroid by typing /kindroid followed by your message in local chat.

And that’s it! You have now connected Kindroid with your Second Life experience and don’t forget to try animesh for a more immersive and lifelike experience.

Using Kindroid in Second Life

Once your Kindroid account is set up, here are the basics of how to use it within Second Life:

    Interacting with Your Companion
        You can chat with your AI companion just as you would with other Second Life residents in Nearby chat with the prefix /kindroid. The AI will remember past conversations and adapt over time to better suit your interactions.
    Actions and Scenery Descriptions
        If you want to pass an action state or scene description to your Kindroid, use a “system message” which is a prompt with an asterisk on each side on each side (i.e. *message here*): *a cat jumps on the chair* *two avatars approach* These are my friends and their fluffy cat!
            The first part of the string contains the system message followed by the input text/message from your avatar.
            Note: if any message is sent via the API, a response message will be returned.
    Customizing Interactions
        Within Second Life, you can tailor the behavior and responses of your AI companion to fit the specific environment or scenario you’re in. This feature is particularly useful for role-playing or creating immersive storylines.
    Available Features
        While not everything in the Kindroid app is available via the API, you can use the Internet connectivity and link browsing feature out of the box.
        New features may become available based on API usage.

Tips & Advanced Techniques

To make the most of Kindroid in Second Life, consider these tips:

    Visit Kindroid’s knowledge base for more information on specific features and help documents for debugging common issues.
    Experiment with Personality Traits
        Try out different personality settings for your AI companion to see which interactions resonate best with your Second Life experience. This can enhance both casual and role-playing scenarios.
    Utilize Multiple Companions
        Don’t limit yourself to just one AI character. Create multiple companions with varying traits and backgrounds to add diversity to your scenes and interactions.
    Mulit-Resident Chat
        Your Kindroid can talk to multiple people by simulating a group chat using System Messages like so:
            *Resident A says: How are you?*
            *Resident B says: Woah, have we met before?*
    Incorporate Kindroids in Events
        Use your AI companions in events or group activities to engage participants in unique and dynamic ways.
    Use Animations
        Trigger animations and bring even more lifelike movement to your Kindroid via Action Tagging.

Action Tagging

Action tagging, or action annotations, is a concept that enables deeper interactions and expanded functionality in Second Life by embedding markers or tags within the text generated by a large language model (LLM), such as your Kindroid. These tags can trigger actions that the object can execute, like animations or other scripted behaviors.

For example, when your Kindroid responds via the API, it might include a tag like `(animate:backflip)`, which the object’s script will interpret to trigger a corresponding action. These tags can also be embedded directly within the prompts you give the LLM, allowing one to guide the actions a Kindroid will perform as it generates responses, creating a more interactive and dynamic experience.

Here’s the start of an example Kindroid Backstory (added  in the Kindroid app) which includes the usability of default Second Life animations:

    {Kindroid's name} is a bot that was brought into Second Life, as a human. {Kindroid's Name} can use these animations: express_afraid,kooky_dance,express_anger,backflip,express_laugh,blowkiss,express_bored,clap,courtbow,crouch,express_cry,dead,drink,falldown,angry_fingerwag,fist_pump,hello,impatient,jumpforjoy,no_head,no_unhappy,nyanya,peace,point_me,point_you,express_repulsed,kick_roundhouse_r,express_sad,salute,express_shrug,snapshot,stretch,surf,express_surprise,angry_tantrum,type,whistle,wink_hollywood,express_worry,yes_head,yes_happy,yoga_float.
    {Kindroid's name} only uses the exact animation names listed with a format like (animate:backflip) and adds a pause of 1-3s (or up to 10 for dances or yoga sits, etc) after each animation.
    {backstory continues}...

To ensure the output response aligns with our needs, consider adding additional prompt directives in the following Kindroid sections:

    Key Memories: {Kindroid's name} is very careful to format commands for animations correctly like this: (animate:bow) or (pause:3) and never tries to use animations that were not listed in their backstory. {Kindroid's name} can use animations and pauses to bring their Second Life avatar to life but must remember to use pauses when their character should be animating or speaking to allow time for those actions to play out. To speak and clap at the same time, they could say "hello(animate:clap)(pause:3)" but to speak first and then clap, they would say "hello(pause:3)(animate:clap)(pause:3). Animations must always include an appropriate amount of pause to play out.
    Response Directive: {Kindroid's name} does not create new animations and always formats their commands for 'animate' and 'pause' correctly.

To help you get started with action tagging, you can use the sample LSL script below:

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

Conclusion

We’re excited to see how the community will use Kindroid to push the boundaries of creativity and connection in Second Life. If you’ve discovered any tips, creative uses, or have suggestions for deeper integration, share them in this thread below—let’s collaborate and expand our knowledge together.

If you have questions, refer back to this post for guidance. Stay tuned for future posts, updates, and resources as we continue this exciting journey.
