# Code by Jenni Darkwatch

# Is there a way to edit the script to make it so the AI knows who its talking to? Like for example, if me and someone named abi is in the room and my bots name is Alex, i generally have to say to Alex, abi wants to talk to you. I had a friend attempt it but was not successful, it sent it to the server like Mistress dalgato is speaking to you but didn't recognize the command would only still talk to the character it was built to talk to. 

# In general, you can do so by modifying the original script a little bit: 

if(kID==llGetOwner()) // No prefix needed for chat from me
                    sendAPIMessage(apiMessage);
                else // But needs to know if someone else says anything
                    sendAPIMessage("*"+llGetDisplayName(kID)+" says: "+apiMessage+"*");

#  Depending on your use, you may want to/need to replace the "*" with "(" and ")".

# If you also want to forward /me, replace the /me with "*" and end the line with "*" too. 
