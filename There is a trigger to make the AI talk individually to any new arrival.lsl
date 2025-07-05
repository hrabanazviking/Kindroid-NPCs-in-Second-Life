# Code by Mistressdalgato Resident

# I forgot to post the finished script, thank you to all who helped modify it. - Mistressdalgato Resident

 

 

// There is a trigger to make the AI talk individually to any new arrival.
// if you want to remove that, comment out line 102: sendAPIMessage("(A "+sGender+" walked near you.)");

string EXTERNAL_API_KEY = "";
string AI_ID = "";
// Define constants
string API_ENDPOINT = "https://api.kindroid.ai/v1/send-message";
integer PRIVATE_CHANNEL = 111;

float SENSOR_RANGE = 20.0; // How far the AI should be aware of people entering its chat range?
string GREETING="Hello, I'm Alex.  Say \"/Alex ...\" to talk to me!"; // Text to send to people

//--- no need to edit anything below this ---
list glPresent; // To detect who arrived near us

// Function to send a message via the API
sendAPIMessage(string sMessage) {
    // Construct the JSON payload
    string sJSON = "{\"ai_id\": \"" + AI_ID + "\", \"message\": \"" +llReplaceSubString(sMessage, "\"", "'", 0)+"\"}";
    // Set the HTTP headers
    list lHeaders = [
        HTTP_BODY_MAXLENGTH,16384, // This accomodates Kindroids character limit, avoiding a cut-off
        HTTP_METHOD, "POST",
        HTTP_MIMETYPE, "application/json",
        HTTP_CUSTOM_HEADER, "Authorization", "Bearer " + EXTERNAL_API_KEY
    ];
    // Make the HTTP POST request
    llHTTPRequest(API_ENDPOINT, lHeaders, sJSON);
}

// Function to process and split message into "/me" actions and regular text
processAndSendChatMessage(string sMessage) {
    integer iStart = 0;
    integer iEnd = 0;

    sMessage=llReplaceSubString(sMessage,"\n\n"," ",0); // Replace double-spaced lines and just put it all in one line
    sMessage=llStringTrim(sMessage,STRING_TRIM); // Remove extraneous whitespace at beginning and end

    while ((iStart=llSubStringIndex(sMessage, "*")) != -1) {
        // Send any text before the action
        if (iStart>0) {
            string sBeforeAction = llGetSubString(sMessage, 0, iStart-1);
            if (llStringLength(llStringTrim(sBeforeAction, STRING_TRIM))>0)
                llSay(0,llStringTrim(sBeforeAction, STRING_TRIM));
        }
       
        // Find the end of the action (next asterisk)
        iEnd = llSubStringIndex(llGetSubString(sMessage, iStart+1, -1), "*")+iStart+1;
        if (iEnd>iStart) { // Send the "/me" action
            llSay(0,"/me " + llGetSubString(sMessage, iStart+1, iEnd-1));
            // Remove the processed part from the message
            sMessage=llDeleteSubString(sMessage, 0, iEnd+1);
        } else { // If no closing asterisk is found, return to avoid infinite loop
           return;
        }
    }
    // Send any remaining part of the message after all actions have been processed
    if (llStringLength(llStringTrim(sMessage, STRING_TRIM))>0)
        llSay(0,llStringTrim(sMessage, STRING_TRIM));
}

//==================================================================================================
// Listen for chat messages
 default {
    state_entry() {
        llListen(0, "", NULL_KEY, "");
        llSensorRepeat("","",AGENT_BY_LEGACY_NAME,SENSOR_RANGE,PI,10.0); // scan 10m radius for new people and people who left, every 10s
    }
    
    listen(integer iChan, string iName, key kID, string sMessage) {
        // Check if the message is a chat to the AI from the owner
        if (llSubStringIndex(sMessage, "/Alex ") == 0) {
            // Extract the message after the command
            string apiMessage = llStringTrim(llDeleteSubString(sMessage, 0, 5), STRING_TRIM);
            sendAPIMessage("("+llGetDisplayName(kID)+" says: "+apiMessage+")");
         }
    }

   // Handle the response from the API
   http_response(key kID, integer iStatus, list lMetadata, string sBody) {
       // If the API request was successful, process the text
       if (iStatus==200) processAndSendChatMessage(sBody);
       // Otherwise, notify the owner of the issue.
       else llOwnerSay("Error: Failed to send message to API. Status: " + (string)iStatus);
   }
   
   // This is to greet people
    sensor(integer iNum) {
        integer i;
        key kAvi;
        list lScannedFor;
        for(i=0;i<iNum;i++) {
            kAvi=(string)llDetectedKey(i);
            if(llListFindList(glPresent,[kAvi])==-1) { // Not found in previous presence list, new arrival
                string sName=llGetDisplayName(kAvi);
                string sGender="female";
                if(llList2Float(llGetObjectDetails(kAvi,[OBJECT_BODY_SHAPE_TYPE]),0)>0.5) sGender="male";
    
                llRegionSayTo(kAvi,0,GREETING);
                sendAPIMessage("(A "+sGender+" walked near you.)");
            } // End height diff check
            lScannedFor+=[kAvi];
        } // End for
        glPresent=lScannedFor;
    }
    
    no_sensor() {
        glPresent=[];
    }
}
