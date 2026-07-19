--[[
	AutoFlood
	Author : LenweSaralonde
]]

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata

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
function AutoFlood_OnEvent(self, event, ...)
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
			channel = "say",
			rate = 60,
            toggleOnAFK = false,
		}, oldConfig, AF_characterConfig or {})

		-- Erase old configuration
		AF_characterConfig.system = nil
		AF_characterConfig.idChannel = nil
		cleanOldConfig(characterId)

		-- Display welcome message
		local s = string.gsub(AUTOFLOOD_LOAD, "VERSION", version)
		DEFAULT_CHAT_FRAME:AddMessage(s, 1, 1, 1)
	end

    if event == "PLAYER_FLAGS_CHANGED" then
       local unit = ...
       AutoFloodOnAFK(event, unit)
    end
end

--- Enable flood!
--
function AutoFlood_On()
	isFloodActive = true
	AutoFlood_Info()
	AutoFlood_Frame.timeSinceLastUpdate = AF_characterConfig.rate
    AutoFloodAFKRegisterEvent()
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
		local system, channelNumber = AutoFlood_GetChannel(AF_characterConfig.channel)
		if system == nil then
			local s = string.gsub("[AutoFlood] " .. AUTOFLOOD_ERR_CHAN, "CHANNEL", AF_characterConfig.channel)
			DEFAULT_CHAT_FRAME:AddMessage(s, 1, 0, 0)
		else
			MessageQueue.SendChatMessage(AF_characterConfig.message, system, nil, channelNumber)
		end
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
    local toggleOnAFKState =  string.gsub(tostring(AF_characterConfig.toggleOnAFK), "true", AUTOFLOOD_STATE_ENABLED)
    local toggleOnAFKState =  string.gsub(toggleOnAFKState, "false", AUTOFLOOD_STATE_DISABLED)
	s = string.gsub(s, "MESSAGE", AF_characterConfig.message)
	s = string.gsub(s, "CHANNEL", AF_characterConfig.channel)
	s = string.gsub(s, "RATE", AF_characterConfig.rate)
    a = string.gsub(AUTOFLOOD_TOGGLE_ON_AFK, "STATE", toggleOnAFKState)
	DEFAULT_CHAT_FRAME:AddMessage(s, 1, 1, 1)
    DEFAULT_CHAT_FRAME:AddMessage(a, 1, 1, 1)
end

--- Set the message to send.
-- @param msg (string)
function AutoFlood_SetMessage(msg)
	if msg ~= "" then
		AF_characterConfig.message = msg
	end
	local s = string.gsub(AUTOFLOOD_MESSAGE, "MESSAGE", AF_characterConfig.message)
	DEFAULT_CHAT_FRAME:AddMessage(s, 1, 1, 1)
end

--- Set the amount of seconds between each message sending.
-- @param rate (number)
function AutoFlood_SetRate(rate)
	if rate ~= nil and tonumber(rate) > 0 and rate ~= "" then rate = tonumber(rate) end
	if rate >= MAX_RATE then
		AF_characterConfig.rate = rate
		local s = string.gsub(AUTOFLOOD_RATE, "RATE", AF_characterConfig.rate)
		DEFAULT_CHAT_FRAME:AddMessage(s, 1, 1, 1)
	else
		local s = string.gsub(AUTOFLOOD_ERR_RATE, "RATE", MAX_RATE)
		DEFAULT_CHAT_FRAME:AddMessage(s, 1, 0, 0)
	end
end

--- Return channel system and number
-- @param channel (string) Channel name, as prefixed by the slash.
-- @return system (string|nil)
-- @return channelNumber (int|nil)
-- @return channelName (string|nil)
function AutoFlood_GetChannel(channel)
	local ch = strlower(strtrim(channel))
	if ch == "say" or ch == "s" then
		return "SAY", nil, ch
	elseif ch == "guild" or ch == "g" then
		return "GUILD", nil, ch
	elseif ch == "raid" or ch == "ra" then
		return "RAID", nil, ch
	elseif ch == "party" or ch == "p" or ch == "gr" then
		return "PARTY", nil, ch
	elseif ch == "i" then
		return "INSTANCE_CHAT", nil, ch
	elseif ch == "bg" then
		return "BATTLEGROUND", nil, ch
	elseif GetChannelName(channel) ~= 0 then
		return "CHANNEL", (GetChannelName(channel)), channel
	end
	return nil, nil, nil
end

--- Set the event / system / channel type according fo the game channel /channel.
-- @param channel (string) Channel name, as prefixed by the slash.
function AutoFlood_SetChannel(channel)
	local system, _, channelName = AutoFlood_GetChannel(channel)
	if system == nil then
		-- Bad channel
		local s = string.gsub(AUTOFLOOD_ERR_CHAN, "CHANNEL", channel)
		DEFAULT_CHAT_FRAME:AddMessage(s, 1, 0, 0)
	else
		-- Save channel setting
		AF_characterConfig.channel = channelName
		local s = string.gsub(AUTOFLOOD_CHANNEL, "CHANNEL", channelName)
		DEFAULT_CHAT_FRAME:AddMessage(s, 1, 1, 1)
	end
end

function AutoFloodAFK_Toggle(disableOnAFK)
   if disableOnAFK == "on" or disableOnAFK == "true" == disableOnAFK == "t" then
      AF_characterConfig.toggleOnAFK = true
   else
      if AF_characterConfig.toggleOnAFK == false then
         AF_characterConfig.toggleOnAFK = true
      end
   end
   AutoFloodAFKRegisterEvent()
end

function AutoFloodAFKRegisterEvent()
   if AF_characterConfig.toggleOnAFK then
      AutoFlood_Frame:RegisterEvent("PLAYER_FLAGS_CHANGED")
   else
      AutoFlood_Frame:UnregisterEvent("PLAYER_FLAGS_CHANGED")
   end
end

function AutoFloodOnAFK(event, unit)
	if unit ~= "player" then return end
	if not UnitIsAFK("player") then return end
    AutoFlood_Off()
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

-- /floodafk [on|off]
-- Toggle flood disable on afk
SlashCmdList["AUTOFLOODAFK"] = AutoFloodAFK_Toggle

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
SLASH_AUTOFLOODAFK1 = "/floodafk"
