--[[
	AutoFlood
	Author : LenweSaralonde
	
	Variables available in messages:
	{size} - Current group/raid size (e.g., 20)
	{tanks} - Number of tanks in group (e.g., 2)
	{heals} - Number of healers in group (e.g., 4)
	{dps} - Number of DPS in group (e.g., 14)
	
	Math operations are supported:
	{2-tanks} - Subtract tanks from 2 (e.g., 2-1=1, won't go below 0)
	{4-heals} - Subtract healers from 4 (e.g., 4-3=1, won't go below 0)
	{14-dps} - Subtract DPS from 14 (e.g., 14-10=4, won't go below 0)
	
	Need format:
	{need-2/4/14} - Shows what roles are still needed based on desired counts
	                (e.g., with 2/3/10, shows "Need 1 heal, 4 DPS!")
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
			channel = "say",
			rate = 60,
		}, oldConfig, AF_characterConfig or {})

		-- Erase old configuration
		AF_characterConfig.system = nil
		AF_characterConfig.idChannel = nil
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

--- Get the current group/raid size and role counts
-- @return number Current group/raid size
-- @return number Tank count
-- @return number Healer count
-- @return number DPS count
local function GetCurrentGroupInfo()
	local n = GetNumGroupMembers()
	local tanks, healers, dps = 0, 0, 0
	
	if n == 0 then
		return 1, 0, 0, 0 -- Solo
	else
		local isRaid = IsInRaid()
		local unitPrefix = isRaid and "raid" or "party"
		
		for i = 1, n do
			local unit = unitPrefix .. (isRaid and i or (i == 1 and "" or i))
			local role = UnitGroupRolesAssigned(unit)
			if role == "TANK" then
				tanks = tanks + 1
			elseif role == "HEALER" then
				healers = healers + 1
			elseif role == "DAMAGER" then
				dps = dps + 1
			end
		end
		return n, tanks, healers, dps
	end
end

--- Process message placeholders related to group composition
-- @param message (string) Original message with placeholders
-- @return (string) Message with group-related placeholders substituted
local function ProcessGroupPlaceholders(message)
	-- Get current group information
	local size, tanks, healers, dps = GetCurrentGroupInfo()
	
	-- Helper function for math operations to ensure non-negative results
	local function safeSubtract(desired, current)
		local result = tonumber(desired) - current
		return result > 0 and result or 0
	end
	
	-- Basic replacements
	message = string.gsub(message, "{size}", size)
	message = string.gsub(message, "{tanks}", tanks)
	message = string.gsub(message, "{heals}", healers)
	message = string.gsub(message, "{dps}", dps)
	
	-- Math operations - ensure results don't go below 0
	message = string.gsub(message, "{(%d+)%-tanks}", function(num) return safeSubtract(num, tanks) end)
	message = string.gsub(message, "{(%d+)%-heals}", function(num) return safeSubtract(num, healers) end)
	message = string.gsub(message, "{(%d+)%-dps}", function(num) return safeSubtract(num, dps) end)
	message = string.gsub(message, "{(%d+)%-size}", function(num) return safeSubtract(num, size) end)
	
	-- Need format
	message = string.gsub(message, "{need%-(%d+)/(%d+)/(%d+)}", function(neededTanks, neededHealers, neededDps)
		local parts = {}
		local remainingTanks = safeSubtract(neededTanks, tanks)
		local remainingHealers = safeSubtract(neededHealers, healers)
		local remainingDps = safeSubtract(neededDps, dps)
		
		-- Helper function to add a role to the parts list with proper pluralization
		local function addRole(count, singular, plural)
			if count > 0 then
				table.insert(parts, count .. " " .. (count == 1 and singular or plural))
			end
		end
		
		addRole(remainingTanks, "tank", "tanks")
		addRole(remainingHealers, "heal", "heals")
		addRole(remainingDps, "DPS", "DPS")
		
		if #parts == 0 then
			return ""
		else
			return "Need " .. table.concat(parts, ", ") .. "!"
		end
	end)
	
	return message
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
			-- Process the message to replace all placeholders
			local message = AF_characterConfig.message
			message = ProcessGroupPlaceholders(message)
			
			MessageQueue.SendChatMessage(message, system, nil, channelNumber)
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
	s = string.gsub(s, "MESSAGE", AF_characterConfig.message)
	s = string.gsub(s, "CHANNEL", AF_characterConfig.channel)
	s = string.gsub(s, "RATE", AF_characterConfig.rate)
	DEFAULT_CHAT_FRAME:AddMessage(s, 1, 1, 1)
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
