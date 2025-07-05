# Code by Otoa Kiyori

# By the way I am not sure if this helps anyone but... I was little bit annoyed that single reponse becomes (actioin, speech, action, speech...) so I  made modification to combine all speeches and actions so response would only be two lines.

# I replaced * to ( and ) on the Kindroid side

# This is for the added Backstory/Response directive "action should be denoted in ( ) instead of *." like this 

# I replaced * to () so on the Kindroid side, the text to speech will not include the action parts 

// v2
process_and_send_chat_message(string message)
{
    // llOwnerSay("Raw Response:" + message);
    list actions = [];
    list speeches = [];

    list text_parts = llParseString2List(message, ["("], []);
    integer i;
    do
    {
        list text_parts2 = llParseString2List(llList2String(text_parts, i), [")"], []);
        if(llList2String(text_parts2, 0) != "")
            actions += llStringTrim(llList2String(text_parts2, 0), STRING_TRIM);
        if(llGetListLength(text_parts2) >= 2 && llList2String(text_parts2, 1) != "")
            speeches += llStringTrim(llList2String(text_parts2, 1), STRING_TRIM);
    }
    while(++i < llGetListLength(text_parts));

    if(speeches)
        say(llDumpList2String(speeches, " "));

    if(actions)
    {
        string action;
        if(llGetListLength(actions) >= 2)
            action = llDumpList2String(llDeleteSubList(actions, -1, -1), ", ") + " and " + llList2String(actions, -1);
        else
            action = llList2String(actions, 0);
        say( "/me " + action);
    }
}
