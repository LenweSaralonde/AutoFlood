-- Version : English (default) ( by @project-author@ )
-- Last Update : 22/05/2006


AUTOFLOOD_LOAD = "AutoFlood VERSION loaded. Type /floodhelp for help."

AUTOFLOOD_STATS = "\"MESSAGE\" is sent every RATE seconds in channel /CHANNEL."

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
	"/floodmsg <message> : Sets the message. Use {size} for group size, {tanks} for tank count (e.g., 2), {heals} for healer count (e.g., 4), and {dps} for DPS count (e.g., 14). Math operations like {5-heals} (shows 1) are also supported and will never show negative numbers. Special format {need-2/4/14} shows what roles you still need based on desired counts.",
	"/floodchan <channel> : Sets the channel.",
	"/floodrate <duration> : Sets the period (in seconds).",
	"/floodinfo : Displays parameters.",
	"/floodhelp : Displays this help message.",
}
