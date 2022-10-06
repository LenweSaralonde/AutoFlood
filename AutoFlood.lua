--[[
	AutoFlood
	Author : LenweSaralonde
]]

-- ===========================================
-- Main code functions
-- ===========================================

local MAX_RATE = 10
local isFloodActive = false

--- Main script initialization
--
function AutoFlood_OnLoad()
	AutoFlood_Frame:RegisterEvent("VARIABLES_LOADED")
	AutoFlood_Frame.timeSinceLastUpdate = 0
	AutoFlood_Frame:SetScript("OnEvent", AutoFlood_OnEvent)
	AutoFlood_Frame:SetScript("OnUpdate", AutoFlood_OnUpdate)
end

--- Clean the old account-wide config table
-- @param characterId (string)
local function cleanOldConfig(characterId)
	if AF_config and AF_config[characterId] then
		AF_config[characterId] = nil
		if next(AF_config) == nil then
			AF_config = nil
		end
	end
end

--- Event handler function
--
function AutoFlood_OnEvent(self, event)
	-- Init saved variables
	if event == "VARIABLES_LOADED" then

		-- Add-on version
		local version = GetAddOnMetadata("AutoFlood", "Version")

		-- Config key used for the old account-wide configuration table
		local characterId = GetRealmName() .. '-' .. UnitName("player")
		local oldConfig = AF_config and AF_config[characterId] or {}

		-- Init configuration
		AF_characterConfig = Mixin({
			message = "AutoFlood " .. version,
			system = "CHANNEL",
			channel = "1",
			rate = 60,
			idChannel = "1",
		}, oldConfig, AF_characterConfig or {})

		-- Erase old configuration
		cleanOldConfig(characterId)

		-- Display welcome message
		local s = string.gsub(AUTOFLOOD_LOAD, "VERSION", version)
		DEFAULT_CHAT_FRAME:AddMessage(s, 1, 1, 1)
	end
end

--- Enable flood!
--
function AutoFlood_On()
	isFloodActive = true
	AutoFlood_Info()
	AutoFlood_Frame.timeSinceLastUpdate = AF_characterConfig.rate
end

--- Stop flood
--
function AutoFlood_Off()
	DEFAULT_CHAT_FRAME:AddMessage(AUTOFLOOD_INACTIVE, 1, 1, 1)
	isFloodActive = false
end

--- Frame update handler
--
function AutoFlood_OnUpdate(self, elapsed)
	if not isFloodActive or MessageQueue.GetNumPendingMessages() > 0 then return end
	AutoFlood_Frame.timeSinceLastUpdate = AutoFlood_Frame.timeSinceLastUpdate + elapsed
	if AutoFlood_Frame.timeSinceLastUpdate > AF_characterConfig.rate then
		MessageQueue.SendChatMessage(
			AF_characterConfig.message,
			AF_characterConfig.system,
			AutoFlood_Frame.language,
			(select(1, GetChannelName(AF_characterConfig.idChannel)))
		)
		AutoFlood_Frame.timeSinceLastUpdate = 0
	end
end

--- Show parameters
--
function AutoFlood_Info()
	if isFloodActive then
		DEFAULT_CHAT_FRAME:AddMessage(AUTOFLOOD_ACTIVE, 1, 1, 1)
	else
		DEFAULT_CHAT_FRAME:AddMessage(AUTOFLOOD_INACTIVE, 1, 1, 1)
	end

	local s = AUTOFLOOD_STATS
	s = string.gsub(s, "MESSAGE", AF_characterConfig.message)
	s = string.gsub(s, "CHANNEL", AF_characterConfig.channel)
	s = string.gsub(s, "RATE", AF_characterConfig.rate)
	DEFAULT_CHAT_FRAME:AddMessage(s, 1, 1, 1)
end

--- Set the message to send.
-- @param msg (string)
function AutoFlood_SetMessage(msg)
	if msg ~= "" then AF_characterConfig.message = msg end

	local s = string.gsub(AUTOFLOOD_MESSAGE, "MESSAGE", AF_characterConfig.message)
	DEFAULT_CHAT_FRAME:AddMessage(s, 1, 1, 1)
end

--- Set the amount of seconds between each message sending.
-- @param rate (number)
function AutoFlood_SetRate(rate)
	local s

	if rate ~= nil and tonumber(rate) > 0 and rate ~= "" then rate = tonumber(rate) end
	if rate >= MAX_RATE then
		AF_characterConfig.rate = rate
		s = string.gsub(AUTOFLOOD_RATE, "RATE", AF_characterConfig.rate)
	else
		s = string.gsub(AUTOFLOOD_ERR_RATE, "RATE", MAX_RATE)
	end
	DEFAULT_CHAT_FRAME:AddMessage(s, 1, 1, 1)
end

--- Set the event / system / channel type according fo the game channel /ch. Allowed values : s, say, guild, raid, party and actually joined channel numbers (0-9)
-- @param ch (string)
function AutoFlood_SetChannel(ch)
	AF_characterConfig.system = ""
	if ch == "say" or ch == "s" then
		AF_characterConfig.system = "SAY"
		AF_characterConfig.channel = ch
	end
	if ch == "guild" or ch == "g" then
		AF_characterConfig.system = "GUILD"
		AF_characterConfig.channel = ch
	end
	if ch == "raid" then
		AF_characterConfig.system = "RAID"
		AF_characterConfig.channel = ch
	end
	if ch == "gr" or ch == "party" then
		AF_characterConfig.system = "PARTY"
		AF_characterConfig.channel = ch
	end
	if ch == "bg" then
		AF_characterConfig.system = "BATTLEGROUND"
		AF_characterConfig.channel = ch
	end
	if AF_characterConfig.system == "" then
		if GetChannelName(ch) ~= 0 then
			AF_characterConfig.idChannel = ch
			AF_characterConfig.system = "CHANNEL"
			AF_characterConfig.channel = ch
		end
	end

	-- Bad channel
	if AF_characterConfig.system == "" then
		AF_characterConfig.system = "SAY"
		AF_characterConfig.channel = "s"
		local s = string.gsub(AUTOFLOOD_ERR_CHAN, "CHANNEL", ch)
		DEFAULT_CHAT_FRAME:AddMessage(s, 1, 1, 1)
		return
	end

	local s = string.gsub(AUTOFLOOD_CHANNEL, "CHANNEL", AF_characterConfig.channel)
	DEFAULT_CHAT_FRAME:AddMessage(s, 1, 1, 1)
end

-- ===========================================
-- Slash command aliases
-- ===========================================

--- /flood [on|off]
-- Start / stop flood
-- @param s (string)
SlashCmdList["AUTOFLOOD"] = function(s)
	if s == "on" then
		AutoFlood_On()
	elseif s == "off" then
		AutoFlood_Off()
	else
		if isFloodActive then
			AutoFlood_Off()
		else
			AutoFlood_On()
		end
	end
end


-- /floodmessage <message>
-- Set the message to send
SlashCmdList["AUTOFLOODSETMESSAGE"] = AutoFlood_SetMessage

-- /floodchan <channel>
-- Set the channel
SlashCmdList["AUTOFLOODSETCHANNEL"] = AutoFlood_SetChannel

-- /floodrate <duration>
-- Set the period (in seconds)
SlashCmdList["AUTOFLOODSETRATE"] = AutoFlood_SetRate

-- /floodinfo
-- Display the parameters in chat window
SlashCmdList["AUTOFLOODINFO"] = AutoFlood_Info

-- /floodhelp
-- Display help in chat window
SlashCmdList["AUTOFLOODHELP"] = function()
	for _, l in pairs(AUTOFLOOD_HELP) do
		DEFAULT_CHAT_FRAME:AddMessage(l, 1, 1, 1)
	end
end


-- Command aliases
SLASH_AUTOFLOOD1 = "/flood"

SLASH_AUTOFLOODSETMESSAGE1 = "/floodmessage"
SLASH_AUTOFLOODSETMESSAGE2 = "/floodmsg"

SLASH_AUTOFLOODSETCHANNEL1 = "/floodchannel"
SLASH_AUTOFLOODSETCHANNEL2 = "/floodchan"

SLASH_AUTOFLOODSETRATE1 = "/floodrate"

SLASH_AUTOFLOODINFO1 = "/floodinfo"
SLASH_AUTOFLOODINFO2 = "/floodconfig"

SLASH_AUTOFLOODHELP1 = "/floodhelp"
SLASH_AUTOFLOODHELP2 = "/floodman"
