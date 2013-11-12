--[[
	AutoFlood

	Version : @project-version@
	Date    : @project-date-iso@
	Author  : @project-author@
]]

-- ===========================================
-- Main code functions
-- ===========================================

-- Init configuration variables
function AutoFlood_InitVars()
    AF_maxRate 		= 10
    AF_version 		= "1.2"
    AF_myID = GetRealmName()..'-'..UnitName("player")
end


-- Main script initialization
function AutoFlood_OnLoad()
	AutoFlood_Frame:RegisterEvent("VARIABLES_LOADED")
	AutoFlood_Frame.TimeSinceLastUpdate = 0

	AF_active = false

	AutoFlood_InitVars()

	AutoFlood_Frame:SetScript("OnEvent",  AutoFlood_OnEvent)
	AutoFlood_Frame:SetScript("OnUpdate", AutoFlood_OnUpdate)
end


-- Event handler function
function AutoFlood_OnEvent(this, event, ...)
	-- Init saved variables
	if (event == "VARIABLES_LOADED") then

		-- Init configuration
		local configInitialisation =
		{
			['message']   = "AutoFlood "..AF_version,
			['system']    = "CHANNEL",
			['channel']   = "1",
			['rate']      = 60,
			['idChannel'] = "1",
		}

		if AF_config == nil then
			AF_config = {}
		end

		if AF_config[AF_myID] == nil then
			AF_config[AF_myID] = {}
		end

		for k, v in pairs(configInitialisation) do
			if AF_config[AF_myID][k] == nil then
			   AF_config[AF_myID][k] = v
			end
		end


    	s = string.gsub(AUTOFLOOD_LOAD, "VERSION", 	AF_version)
    	DEFAULT_CHAT_FRAME:AddMessage(s,1,1,1)
	    return
	end
end


-- Enable flood!
function AutoFlood_On()
	AF_active = true
	AutoFlood_Info()
	AutoFlood_Frame.TimeSinceLastUpdate = AF_config[AF_myID]['rate']
end


-- Stop flood
function AutoFlood_Off()
	DEFAULT_CHAT_FRAME:AddMessage(AUTOFLOOD_INACTIVE,1,1,1)
	AF_active = false
end


-- Frame update handler
function AutoFlood_OnUpdate(this, arg1)
	if(not AF_active) then return end
	AutoFlood_Frame.TimeSinceLastUpdate = AutoFlood_Frame.TimeSinceLastUpdate + arg1
	if( AutoFlood_Frame.TimeSinceLastUpdate > AF_config[AF_myID]['rate'] ) then
     	SendChatMessage(AF_config[AF_myID]['message'], AF_config[AF_myID]['system'], AutoFlood_Frame.language, GetChannelName(AF_config[AF_myID]['idChannel']))
		AutoFlood_Frame.TimeSinceLastUpdate = 0
	end
end


-- Show parameters
function AutoFlood_Info()
	local s

	if(AF_active) then
		DEFAULT_CHAT_FRAME:AddMessage(AUTOFLOOD_ACTIVE,1,1,1)
	else
		DEFAULT_CHAT_FRAME:AddMessage(AUTOFLOOD_INACTIVE,1,1,1)
	end

	s = AUTOFLOOD_STATS
	s = string.gsub(s, "MESSAGE", 	AF_config[AF_myID]['message'])
	s = string.gsub(s, "CHANNEL", 	AF_config[AF_myID]['channel'])
	s = string.gsub(s, "RATE", 		AF_config[AF_myID]['rate'])
	DEFAULT_CHAT_FRAME:AddMessage(s,1,1,1)
end


-- Set the message to send.
-- @param string msg
function AutoFlood_SetMessage(msg)
	local s

	if(msg ~= "") then AF_config[AF_myID]['message'] = msg end

	s = string.gsub(AUTOFLOOD_MESSAGE, "MESSAGE", 	AF_config[AF_myID]['message'])
    DEFAULT_CHAT_FRAME:AddMessage(s,1,1,1)
end


-- Set the amount of seconds between each message sending.
-- @param integer r
function AutoFlood_SetRate(r)
	local s

	if((r ~= nil) and (tonumber(r) > 0) and (r ~= "")) then r = tonumber(r) end
	if(r >= AF_maxRate) then
		AF_config[AF_myID]['rate'] = r
		s = string.gsub(AUTOFLOOD_RATE, "RATE", 	AF_config[AF_myID]['rate'])
	else
		s = string.gsub(AUTOFLOOD_ERR_RATE, "RATE", 	AF_maxRate)
	end
    DEFAULT_CHAT_FRAME:AddMessage(s,1,1,1)
end


-- Set the event / system / channel type according fo the game channel /ch.
-- Allowed values : s, say, guild, raid, party and actually joined channel numbers (0-9)
-- @param string ch
function AutoFlood_SetChannel(ch)
	AF_config[AF_myID]['system'] = ""
	if ((ch == "say") or (ch == "s")) then
		AF_config[AF_myID]['system']	= "SAY"
		AF_config[AF_myID]['channel'] 	= ch
	end
	if ((ch == "guild") or (ch == "g")) then
		AF_config[AF_myID]['system']  	= "GUILD"
		AF_config[AF_myID]['channel'] 	= ch
	end
	if (ch == "raid") then
		AF_config[AF_myID]['system']  = "RAID"
		AF_config[AF_myID]['channel'] = ch
	end
	if ((ch == "gr") or (ch == "party")) then
		AF_config[AF_myID]['system']  	= "PARTY"
		AF_config[AF_myID]['channel'] 	= ch
	end
	if (ch == "bg") then
		AF_config[AF_myID]['system']  	= "BATTLEGROUND"
		AF_config[AF_myID]['channel'] 	= ch
	end
	if(AF_config[AF_myID]['system'] == "") then
		if (GetChannelName(ch) ~= 0) then
			AF_config[AF_myID]['idChannel'] = ch
			AF_config[AF_myID]['system']    = "CHANNEL"
			AF_config[AF_myID]['channel']   = ch
		end
	end

	-- Bad channel
	if(AF_config[AF_myID]['system'] == "") then
		AF_config[AF_myID]['system']  	= "SAY"
		AF_config[AF_myID]['channel']  = "s"
		s = string.gsub(AUTOFLOOD_ERR_CHAN, "CHANNEL", ch)
    	DEFAULT_CHAT_FRAME:AddMessage(s,1,1,1)
		return false
	end

	s = string.gsub(AUTOFLOOD_CHANNEL, "CHANNEL", AF_config[AF_myID]['channel'])
    DEFAULT_CHAT_FRAME:AddMessage(s,1,1,1)

	return true
end


-- ===========================================
-- Slash command aliases
-- ===========================================

-- /flood [on|off]
-- Start / stop flood
-- @param string s
SlashCmdList["AUTOFLOOD"] = function(s)
	if(s == "on") then
	     AutoFlood_On()
	elseif(s == "off") then
	     AutoFlood_Off()
	else
		if(AF_active) then AutoFlood_Off() else AutoFlood_On() end
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
	local l
	for _, l in pairs(AUTOFLOOD_HELP) do
		DEFAULT_CHAT_FRAME:AddMessage(l,1,1,1)
	end
end


-- Command aliases
SLASH_AUTOFLOOD1           = "/flood"

SLASH_AUTOFLOODSETMESSAGE1 = "/floodmessage"
SLASH_AUTOFLOODSETMESSAGE2 = "/floodmsg"

SLASH_AUTOFLOODSETCHANNEL1 = "/floodchannel"
SLASH_AUTOFLOODSETCHANNEL2 = "/floodchan"

SLASH_AUTOFLOODSETRATE1    = "/floodrate"

SLASH_AUTOFLOODINFO1  	   = "/floodinfo"
SLASH_AUTOFLOODINFO2  	   = "/floodconfig"

SLASH_AUTOFLOODHELP1       = "/floodhelp"
SLASH_AUTOFLOODHELP2       = "/floodman"
