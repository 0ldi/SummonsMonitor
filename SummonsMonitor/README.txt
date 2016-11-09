Summons Monitor -- by Zayla
---------------------------

This addon makes it easy for one or more Warlocks to summon multiple people.  It provides a window that lists who has asked for a summons and who has already been summoned.  The intent is that this list should work even if no one else in your group has the addon.  The way it works is the addon parses the PARTY and RAID chat channels and looks for places where people have asked for a summon or stated that they are summoning someone.  This information is used to update the list.  The addon is somewhat flexible in understanding what people say.  (See below.)  Selecting someone from the list of people waiting for a summon targets them for you, and there is an nice convenient "Summon Target" in the interface.

The addon also provides a feature that automatically sends out a PARTY/RAID chat message when you summon someone.  This feature can be disabled if you have some other addon or macro that you prefer to use for announcing that you are summoning someone.  You can also change the text of the built in announcement.  By default, this feature is turned on.

A useful feature that is unrelated to summoning is that this addon can also announce when you are casting "Soulstone Resurrection" on someone.  This feature is disabled by default.

Usage:

To open the main window use the command "/smbz show" and to close the window "/smbz hide".  There is also a keybinding for toggling the window open and closed.  

The addon will still keep track of summon requests even if the window is not open.  To avoid possibly interfering while you are in combat, the window does NOT open automatically when someone asks for a summon.

The window will show a list of names of people who have asked for a summon.  If you click their name, it will target them.  There is a button at the top of the window that you can click to cast the spell to summon your current target.  If you, or someone else, are summoning a person the name of the summoner will be listed to the right of the summonee's name.  Names are automatically removed from the list after 10 minutes.  If someone is marked as being summoned, then there is a 20 second cooldown before a summon request by that person will be listened to.  (Some morons like to spam "summon me".)

People who are near you (i.e. people who may not really need a summon) are marked as "Nearby".  In the future, if you are in an instance people who are not in the instance with you.

You can summon the person at the top of the list (aka "queue") by using the "Summon Next" button.  You can also use the command "/smbz next" to summon the next person.  The slash command will work even if the window is not open.  Finally, there is a keybinding for summon next that will also work even if the window is not open.

If you want to clear the list for some reason, use "/smbz clear".


To show your current message used to announce that you are summoning someone, use "/smbz showmsg".  The disable the feature, use "/smbz nomsg".  The change the message, use "/smbz setmsg YOUR MESSAGE HERE".  Obviously, YOU MESSAGE HERE should be replaced with an appropriate message.  You should use %t to indicate the name of your target.  You must use a message that the addon can understand.  (See below.)

To show your current message used to announce that you are Soulstoning someone, use "/smbz showsoul".  The disable the feature, use "/smbz nosoul".  The change the message, use "/smbz setsoul YOUR MESSAGE HERE".  Obviously, YOU MESSAGE HERE should be replaced with an appropriate message.  You should use %t to indicate the name of your target.  The Soulstone message can be whatever you like, and it is disabled by default.


What it understands:

Computers are dumb, they do not understand English.  This addon uses some simple pattern matching to figure out what people are saying.  The patterns ignore capitalization and punctuation.

The following messages are recognized as a request for a summon:

	"summon"
	"summon me"
	"summon please"
        "wtb summon"

The following messages are recognized as a request for summoning someone else: 

	Anything with the word "summon" and the name of someone in your
	group.
	Example "Summon Bob!"
	Example "Could you please summon that guy named bob?"

The following messages are recognized as an announcement that the speaker is summoning someone:

	Anything with the word "summoning" and the name of someone in your
	group.
	Example "Summoning Bob!"
	Example "Bob it is that I am summoning."  (If Yoda were a 'lock)
       
	Anything with the words "summon" and "click" and the name of 
	someone in your group.
	Example "Click to summon Bob"

	Anything with the words "portal" and "click" and the name of 
	someone in your group.
	Example "Click the portal to get Bob over here."
	

Other patterns may be added in the future.


NOTE: Only TELLS, PARTY chat, and RAID chat are parsed.  SAYS, YELLS, and other things are ignored.  Originally, TELLS were ignored because if two Warlocks are summoning a whole raid and people use tells, then one Warlock won't know what the other is doing.  I found that people still insisted on using tells so I turned tell parsing on.


Enjoy. 


The author, Zayla, plays on Dethecus. If you like the mod, feel free to say so. If you have suggestions, feel free to make them. If you think the mod sucks, just unload it and move on.


----------------------------------------------------------------

Changelog

Version 0.3 -
You can clear the list with the command "/smbz clear".
A few more types of summon request are recognized (i.e. "wtb summon")
Tells are now parsed also.  But people who ask for a summon in a tell are at lower priority than people who use raid/party chat.


Version 0.2 - 
Added test to see if someone is nearby. 
Added Summon Next button and keybinding 

Version 0.1 - 
Initial beta version. 


