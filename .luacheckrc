max_line_length = false

exclude_files = {
}

ignore = {
	-- Ignore global writes/accesses/mutations on anything prefixed with the add-on name.
	-- This is the standard prefix for all of our global frame names and mixins.
	"11./^AutoFlood",
	"11./^AUTOFLOOD_",
	"11./^AF_",

	-- Ignore unused self. This would popup for Mixins and Objects
	"212/self",
}

globals = {
	"AF_config",

	-- Globals
	"SLASH_AUTOFLOOD1",
	"SLASH_AUTOFLOODSETMESSAGE1",
	"SLASH_AUTOFLOODSETMESSAGE2",
	"SLASH_AUTOFLOODSETCHANNEL1",
	"SLASH_AUTOFLOODSETCHANNEL2",
	"SLASH_AUTOFLOODSETRATE1",
	"SLASH_AUTOFLOODINFO1",
	"SLASH_AUTOFLOODINFO2",
	"SLASH_AUTOFLOODHELP1",
	"SLASH_AUTOFLOODHELP2",


	-- AddOn Overrides
}

read_globals = {
	-- Libraries

	-- 3rd party add-ons
	"MessageQueue"
}

std = "lua51+wow"

stds.wow = {
	-- Globals that we mutate.
	globals = {
		"SlashCmdList"
	},

	-- Globals that we access.
	read_globals = {
		-- Lua function aliases and extensions

		"date",
		"floor",
		"ceil",
		"format",
		"sort",
		"strconcat",
		"strjoin",
		"strlen",
		"strlenutf8",
		"strsplit",
		"strtrim",
		"strupper",
		"strlower",
		"tAppendAll",
		"tContains",
		"tFilter",
		"time",
		"tinsert",
		"tInvert",
		"tremove",
		"wipe",
		"max",
		"min",
		"abs",
		"random",
		"Lerp",
		"sin",
		"cos",

		-- Global Functions
		"GetLocale",
		"GetAddOnMetadata",
		"GetRealmName",
		"UnitName",
		"GetChannelName",

		-- Global Mixins and UI Objects
		"DEFAULT_CHAT_FRAME",

		-- Global Constants
	},
}
