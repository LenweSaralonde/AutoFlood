-- Version : English (default) ( by @project-author@ )
-- Last Update : 22/05/2006


AUTOFLOOD_LOAD = "AutoFlood VERSION loaded. Type /floodhelp for help."

AUTOFLOOD_MESSAGE_INFO = "Message: \"MESSAGE\""
AUTOFLOOD_CHANNELS_HEADER = "Broadcasting to:"
AUTOFLOOD_CHANNEL_RATE = "Channel /CHANNEL: every RATE seconds"

AUTOFLOOD_MESSAGE = "The message is now \"MESSAGE\"."
AUTOFLOOD_RATE = "The message is now sent every RATE seconds."
AUTOFLOOD_CHANNEL = "The message is now sent in channel /CHANNEL."

AUTOFLOOD_ACTIVE = "AutoFlood is enabled."
AUTOFLOOD_INACTIVE = "AutoFlood is disabled."

AUTOFLOOD_ERR_CHAN = "The channel /CHANNEL doesn't exist."
AUTOFLOOD_ERR_RATE = "You can't send messages less than every RATE seconds."

AUTOFLOOD_HELP = {
	"===================== Auto Flood =====================",
	"/flood [on|off] : Start / stops sending the message.",
	"/floodmsg <message> : Sets the message. Use {size} for group size, {tanks} for tank count, {heals} for healer count, and {dps} for DPS count. Math operations like {5-heals} are also supported.",
	"  Special formats:",
	"  - {need-2/4/14} (tanks/heals/dps) Shows what roles you still need based on desired counts.",
	"  - {>10need-2/4/14} Only shows needed roles if group size is greater than the specified threshold (10 in this example).",
	"/floodchan <channels> : Sets the channels (comma-separated). Example: say,yell,guild",
	"/floodrate <rates> : Sets the periods in seconds (comma-separated). Example: 60,120,300",
	"/floodinfo : Displays parameters.",
	"/floodhelp : Displays this help message.",
}
