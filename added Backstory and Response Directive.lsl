# Code by Otoa Kiyori

# By the way I am not sure if this helps anyone but... I was little bit annoyed that single reponse becomes (actioin, speech, action, speech...) so I  made modification to combine all speeches and actions so response would only be two lines.

# I replaced * to ( and ) on the Kindroid side

# This is for the added Backstory/Response directive "action should be denoted in ( ) instead of *." like this 

# I replaced * to () so on the Kindroid side, the text to speech will not include the action parts 

process_and_send_chat_message(string message)
{
    integer start = 0;
    integer end = 0;
    list actions = [];
    list speeches = [];
    while ((start = llSubStringIndex(message, "(")) != -1)
    {
        // Send any text before the action
        if (start > 0)
        {
            string beforeAction = llGetSubString(message, 0, start - 1);
            if (llStringLength(llStringTrim(beforeAction, STRING_TRIM)) > 0)
                speeches += llStringTrim(beforeAction, STRING_TRIM);
        }
        // Find the end of the action (next asterisk)
        end = llSubStringIndex(llGetSubString(message, start + 1, -1), ")") + start + 1;

        if (end > start)
        {
            // Action
            actions += llGetSubString(message, start + 1, end - 1);
            message = llDeleteSubString(message, 0, end + 1);
        }
        else
            return;
    }
    // Send any remaining part of the message after all actions have been processed
    if (llStringLength(llStringTrim(message, STRING_TRIM)) > 0)
        speeches + llStringTrim(message, STRING_TRIM);

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
