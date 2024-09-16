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
---
--- -- Ensure MessageQueue is defined
local MessageQueue = MessageQueue or {
	GetNumPendingMessages = function() return 0 end,
	SendChatMessage = function(message, system, language, channelNumber) end
}

-- Ensure DEFAULT_CHAT_FRAME is defined
local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME or {
	AddMessage = function(self, message, r, g, b) print(message) end
}

-- Ensure GetChannelName is defined
local GetChannelName = GetChannelName or function(channel) return 0 end

-- Ensure localization strings are defined
local AUTOFLOOD_LOAD = AUTOFLOOD_LOAD or "AutoFlood vVERSION loaded."
local AUTOFLOOD_INACTIVE = AUTOFLOOD_INACTIVE or "AutoFlood is now inactive."
local AUTOFLOOD_ACTIVE = AUTOFLOOD_ACTIVE or "AutoFlood is now active."
local AUTOFLOOD_STATS = AUTOFLOOD_STATS or "Message: MESSAGE, Channel: CHANNEL, Rate: RATE seconds."
local AUTOFLOOD_MESSAGE = AUTOFLOOD_MESSAGE or "Flood message set to: MESSAGE"
local AUTOFLOOD_RATE = AUTOFLOOD_RATE or "Flood rate set to: RATE seconds"
local AUTOFLOOD_ERR_RATE = AUTOFLOOD_ERR_RATE or "Rate must be at least RATE seconds."
local AUTOFLOOD_ERR_CHAN = AUTOFLOOD_ERR_CHAN or "Invalid channel: CHANNEL"
local AUTOFLOOD_CHANNEL = AUTOFLOOD_CHANNEL or "Flood channel set to: CHANNEL"
local AUTOFLOOD_HELP = AUTOFLOOD_HELP or {
	"/flood [on|off] - Start/stop flood",
	"/floodmessage <message> - Set the message to send",
	"/floodchan <channel> - Set the channel",
	"/floodrate <duration> - Set the period (in seconds)",
	"/floodinfo - Display the parameters in chat window",
	"/floodhelp - Display help in chat window",
	"/floodui - Open the flood message UI"
}

-- Ensure UIDropDownMenu functions are defined
local UIDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo or function() return {} end
local UIDropDownMenu_AddButton = UIDropDownMenu_AddButton or function(info, level) end
local UIDropDownMenu_SetSelectedID = UIDropDownMenu_SetSelectedID or function(dropdown, id) end
local UIDropDownMenu_GetText = UIDropDownMenu_GetText or function(dropdown) return "say" end
local UIDropDownMenu_Initialize = UIDropDownMenu_Initialize or function(dropdown, initializeFunc) end
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
-- Initialize variables
local version = GetAddOnMetadata("AutoFlood", "Version")
local characterId = GetRealmName() .. '-' .. UnitName("player")
local oldConfig = AF_config and AF_config[characterId] or {}
AF_characterConfig = Mixin({
	message = "AutoFlood " .. version,
	channel = "say",
	rate = 60,
}, oldConfig, AF_characterConfig or {})

function AutoFlood_OnEvent(self, event)
	-- Init saved variables
	if event == "VARIABLES_LOADED" then
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
	elseif ch == "trade" or ch == "t" then
		local channelNumber = GetChannelName("Trade")
		if channelNumber ~= 0 then
			return "CHANNEL", channelNumber, ch
		else
			return nil, nil, nil
		end
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

local function AUTOFLOODGUI()
	local frame = CreateFrame("Frame", "FloodPromptFrame", UIParent, "BackdropTemplate")
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11 }
	})
	frame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)  -- Dark background
	frame:SetBackdropBorderColor(0.2, 0.2, 0.2, 1) -- Subtle border

	frame:SetSize(500, 300)
	frame:SetPoint("CENTER")
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetResizable(true)
	frame:SetResizeBounds(400, 300, 800, 300)
	frame:Hide() -- Hide the frame by default

	local resizeButton = CreateFrame("Button", nil, frame)
	resizeButton:SetSize(16, 16)
	resizeButton:SetPoint("BOTTOMRIGHT", -6, 6)
	resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
	resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

	resizeButton:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			frame:StartSizing("BOTTOMRIGHT")
			self:GetHighlightTexture():Hide() -- hide highlight texture while resizing
		end
	end)

	resizeButton:SetScript("OnMouseUp", function(self, button)
		frame:StopMovingOrSizing()
		self:GetHighlightTexture():Show()
		-- Add code here to update frame contents based on new size if needed
	end)

	local padding = 10

	local channelTitle = frame:CreateFontString(nil, "OVERLAY")
	channelTitle:SetFontObject("GameFontHighlight")
	channelTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 2 * padding, -20)
	channelTitle:SetText("Channel")

	local channelDropdown = CreateFrame("Frame", nil, frame, "UIDropDownMenuTemplate")
	channelDropdown:SetPoint("TOPLEFT", channelTitle, "BOTTOMLEFT", -16, -5)
	channelDropdown:SetWidth(100)

	local rateInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
	rateInput:SetSize(50, 20)
	rateInput:SetPoint("LEFT", channelDropdown, "RIGHT", 100, 0)
	rateInput:SetAutoFocus(false)
	rateInput:SetNumeric(true)
	rateInput:SetMaxLetters(3)
	rateInput:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
	rateInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

	local rateTitle = frame:CreateFontString(nil, "OVERLAY")
	rateTitle:SetFontObject("GameFontHighlight")
	rateTitle:SetPoint("BOTTOMLEFT", rateInput, "TOPLEFT", 0, 5)
	rateTitle:SetText("Repeat every minute")

	local inputTitle = frame:CreateFontString(nil, "OVERLAY")
	inputTitle:SetFontObject("GameFontHighlight")
	inputTitle:SetPoint("TOPLEFT", channelDropdown, "BOTTOMLEFT", 16, -padding)
	inputTitle:SetText("Input")

	-- Create a background for the input box
	local inputBoxBg = frame:CreateTexture(nil, "OVERLAY")
	inputBoxBg:SetHeight(60)
	inputBoxBg:SetPoint("TOPLEFT", inputTitle, "BOTTOMLEFT", -4, -5)
	inputBoxBg:SetPoint("RIGHT", frame, "RIGHT", -2 * padding, 0)
	inputBoxBg:SetColorTexture(0.2, 0.2, 0.2, 0.8) -- Darker background

	local inputScrollFrame = CreateFrame("ScrollFrame", "FloodInputScrollFrame", frame, "UIPanelScrollFrameTemplate")
	inputScrollFrame:SetHeight(52)
	inputScrollFrame:SetPoint("TOPLEFT", inputBoxBg, "TOPLEFT", 4, -4)
	inputScrollFrame:SetPoint("RIGHT", inputBoxBg, "RIGHT", -4, 0)

	local scrollChild = CreateFrame("Frame", nil, inputScrollFrame)
	scrollChild:SetHeight(50)
	scrollChild:SetPoint("TOPLEFT", inputScrollFrame, "TOPLEFT", 0, 0)
	scrollChild:SetPoint("RIGHT", inputScrollFrame, "RIGHT", 0, 0)
	inputScrollFrame:SetScrollChild(scrollChild)

	local scrollBar = inputScrollFrame.ScrollBar
	local thumbTexture = scrollBar:GetThumbTexture()
	thumbTexture:SetTexture(nil)
	local upButton = scrollBar.ScrollUpButton
	upButton:GetNormalTexture():SetTexture(nil)
	upButton:GetPushedTexture():SetTexture(nil)
	upButton:GetDisabledTexture():SetTexture(nil)
	upButton:GetHighlightTexture():SetTexture(nil)
	local downButton = scrollBar.ScrollDownButton
	downButton:GetNormalTexture():SetTexture(nil)
	downButton:GetPushedTexture():SetTexture(nil)
	downButton:GetDisabledTexture():SetTexture(nil)
	downButton:GetHighlightTexture():SetTexture(nil)

	local inputBox = CreateFrame("EditBox", nil, scrollChild)
	inputBox:SetAllPoints(scrollChild)
	inputBox:SetAutoFocus(false)
	inputBox:SetMultiLine(true)
	inputBox:EnableMouse(true)
	inputBox:SetFontObject("GameFontHighlight")
	inputBox:SetMaxLetters(255)
	inputBox:SetScript("OnTextChanged", function()
		scrollChild:SetHeight(inputBox:GetHeight())
		inputScrollFrame:UpdateScrollChildRect()
	end)
	inputBox:SetScript("OnEscapePressed", function(self) frame:Hide() end)
	inputBox:SetScript("OnEnterPressed", function()
		-- Add functionality for when Enter is pressed, if needed
		inputBox:ClearFocus()
	end)



	local counter = frame:CreateFontString(nil, "OVERLAY")
	counter:SetFontObject("GameFontHighlight")
	counter:SetPoint("BOTTOMRIGHT", inputBoxBg, "TOPRIGHT", -4, padding)
	counter:SetText("255")

	local outputTitle = frame:CreateFontString(nil, "OVERLAY")
	outputTitle:SetFontObject("GameFontHighlight")
	outputTitle:SetPoint("TOPLEFT", inputBoxBg, "BOTTOMLEFT", 4, -padding)
	outputTitle:SetText("Output")

	-- Create a background for the output box
	local outputBoxBg = frame:CreateTexture(nil, "OVERLAY")
	outputBoxBg:SetHeight(60)
	outputBoxBg:SetPoint("TOPLEFT", outputTitle, "BOTTOMLEFT", -4, -5)
	outputBoxBg:SetPoint("RIGHT", frame, "RIGHT", -2 * padding, 0)
	outputBoxBg:SetColorTexture(0.2, 0.2, 0.2, 0.8) -- Darker background

	local outputScrollFrame = CreateFrame("ScrollFrame", "FloodOutputScrollFrame", frame, "UIPanelScrollFrameTemplate")
	outputScrollFrame:SetHeight(52)
	outputScrollFrame:SetPoint("TOPLEFT", outputBoxBg, "TOPLEFT", 4, -4)
	outputScrollFrame:SetPoint("RIGHT", outputBoxBg, "RIGHT", -4, 0)

	local outputScrollChild = CreateFrame("Frame", nil, outputScrollFrame)
	outputScrollChild:SetHeight(50)
	outputScrollChild:SetWidth(outputBoxBg:GetWidth() - 8) -- Subtracting 8 to account for the 4px padding on each side
	outputScrollFrame:SetScrollChild(outputScrollChild)

	local outputScrollBar = outputScrollFrame.ScrollBar
	local outputThumbTexture = outputScrollBar:GetThumbTexture()
	outputThumbTexture:SetTexture(nil)
	local outputUpButton = outputScrollBar.ScrollUpButton
	outputUpButton:GetNormalTexture():SetTexture(nil)
	outputUpButton:GetPushedTexture():SetTexture(nil)
	outputUpButton:GetDisabledTexture():SetTexture(nil)
	outputUpButton:GetHighlightTexture():SetTexture(nil)
	local outputDownButton = outputScrollBar.ScrollDownButton
	outputDownButton:GetNormalTexture():SetTexture(nil)
	outputDownButton:GetPushedTexture():SetTexture(nil)
	outputDownButton:GetDisabledTexture():SetTexture(nil)
	outputDownButton:GetHighlightTexture():SetTexture(nil)

	local outputBox = CreateFrame("EditBox", nil, outputScrollChild)
	outputBox:SetAllPoints(outputScrollChild)
	outputBox:SetAutoFocus(false)
	outputBox:SetMultiLine(true)
	outputBox:EnableMouse(true)
	outputBox:SetFontObject("GameFontHighlight")
	outputBox:EnableKeyboard(false)
	outputBox:SetPoint("TOPLEFT", outputScrollChild, "TOPLEFT", 0, 0)
	outputBox:SetPoint("BOTTOMRIGHT", outputScrollChild, "BOTTOMRIGHT", 0, 0)
	outputBox:SetResizable(true)
	outputBox:SetScript("OnTextChanged", function()
		outputScrollChild:SetHeight(outputBox:GetHeight())
		outputScrollFrame:UpdateScrollChildRect()
	end)

	-- Update scrollChild and inputBox width when frame size changes
	frame:SetScript("OnSizeChanged", function(self, width, height)
		local newWidth = width - 2 * padding - 20 -- Subtracting padding and scroll bar width
		scrollChild:SetWidth(newWidth)
		inputBox:SetWidth(newWidth)
		inputScrollFrame:UpdateScrollChildRect()
		outputScrollChild:SetWidth(newWidth)
		outputBox:SetWidth(newWidth)
		outputScrollFrame:UpdateScrollChildRect()
	end)

	local saveButton = CreateFrame("Button", nil, frame) -- Removed "UIPanelButtonTemplate"
	saveButton:SetSize(60, 20)                        -- Adjusted size to match the example
	saveButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 2 * padding, 2 * padding)
	saveButton:SetText("Save")

	-- Set custom font
	local saveButtonText = saveButton:GetFontString()

	saveButton:SetNormalFontObject("GameFontHighlight")
	saveButton:SetHighlightFontObject("GameFontNormal")

	-- Override default textures
	saveButton:SetNormalTexture("")
	saveButton:SetPushedTexture("")
	saveButton:SetHighlightTexture("")
	saveButton:SetDisabledTexture("")

	-- Create custom backdrop
	local saveButtonBg = saveButton:CreateTexture(nil, "BACKGROUND")
	saveButtonBg:SetAllPoints()
	saveButtonBg:SetColorTexture(0.2, 0.6, 0.2, 0.5) -- Green background

	local saveButtonBorder = saveButton:CreateTexture(nil, "BORDER")
	saveButtonBorder:SetPoint("TOPLEFT", -1, 1)
	saveButtonBorder:SetPoint("BOTTOMRIGHT", 1, -1)
	saveButtonBorder:SetColorTexture(0.1, 0.3, 0.1, 0.8) -- Darker green border

	local cancelButton = CreateFrame("Button", nil, frame) -- Removed "UIPanelButtonTemplate"
	cancelButton:SetSize(60, 20)
	cancelButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2 * padding, 2 * padding)
	cancelButton:SetText("Cancel")

	-- Set custom font
	local cancelButtonText = cancelButton:GetFontString()

	cancelButton:SetNormalFontObject("GameFontHighlight")
	cancelButton:SetHighlightFontObject("GameFontNormal")

	-- Override default textures
	cancelButton:SetNormalTexture("")
	cancelButton:SetPushedTexture("")
	cancelButton:SetHighlightTexture("")
	cancelButton:SetDisabledTexture("")

	-- Create custom backdrop
	local cancelButtonBg = cancelButton:CreateTexture(nil, "BACKGROUND")
	cancelButtonBg:SetAllPoints()
	cancelButtonBg:SetColorTexture(0.6, 0.2, 0.2, 0.5) -- Red background with reduced opacity

	local cancelButtonBorder = cancelButton:CreateTexture(nil, "BORDER")
	cancelButtonBorder:SetPoint("TOPLEFT", -1, 1)
	cancelButtonBorder:SetPoint("BOTTOMRIGHT", 1, -1)
	cancelButtonBorder:SetColorTexture(0.3, 0.1, 0.1, 0.8) -- Darker red border with reduced opacity

	cancelButton:SetScript("OnClick", function()
		frame:Hide()
	end)


	local function replaceIconsAndLineBreaks(text)
		local iconReplacements = {
			["{star}"] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:0|t",
			["{circle}"] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:0|t",
			["{diamond}"] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:0|t",
			["{triangle}"] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:0|t",
			["{moon}"] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:0|t",
			["{square}"] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:0|t",
			["{cross}"] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:0|t",
			["{skull}"] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0|t",
		}
		for i = 1, 8 do
			iconReplacements["{rt" .. i .. "}"] = iconReplacements
				["{" .. ({ "star", "circle", "diamond", "triangle", "moon", "square", "cross", "skull" })[i] .. "}"]
		end
		text = text:gsub("\n", " ") -- Replace line breaks with spaces
		return (text:gsub("{[^}]+}", iconReplacements))
	end

	inputBox:SetScript("OnTextChanged", function(self)
		local text = self:GetText()
		local remaining = 255 - #text
		counter:SetText(remaining)
		outputBox:SetText(replaceIconsAndLineBreaks(text))
	end)

	saveButton:SetScript("OnClick", function()
		local text = inputBox:GetText()
		local selectedChannel = UIDropDownMenu_GetText(channelDropdown)
		local rateInMinutes = tonumber(rateInput:GetText()) or (AF_characterConfig.rate / 60)
		local rateInSeconds = rateInMinutes * 60
		AutoFlood_SetMessage(text)
		AutoFlood_SetChannel(selectedChannel)
		AutoFlood_SetRate(rateInSeconds)
		frame:Hide()
	end)

	cancelButton:SetScript("OnClick", function()
		frame:Hide()
	end)

	-- Fix the OnChannelSelect function to properly set the selected channel
	local function OnChannelSelect(self, arg1, arg2, checked)
		UIDropDownMenu_SetSelectedID(channelDropdown, self:GetID())
		UIDropDownMenu_SetText(channelDropdown, self:GetText())
	end

	-- Fix the InitializeChannelDropdown function to properly initialize the dropdown
	local function InitializeChannelDropdown(self, level)
		local info = UIDropDownMenu_CreateInfo()
		local channels = { "say", "yell", "party", "raid", "guild", "trade" }
		for i, channel in ipairs(channels) do
			info.text = channel
			info.func = OnChannelSelect
			info.checked = AF_characterConfig.channel == channel
			UIDropDownMenu_AddButton(info, level)
		end
	end

	channelDropdown:SetScript("OnShow", function()
		UIDropDownMenu_Initialize(channelDropdown, InitializeChannelDropdown)
	end)

	frame:SetScript("OnShow", function()
		local currentMessage = AF_characterConfig.message or ""
		local currentChannel = AF_characterConfig.channel or "say"
		local currentRate = (AF_characterConfig.rate or 60) / 60 -- Convert seconds to minutes
		inputBox:SetText(currentMessage)
		counter:SetText(255 - #currentMessage)
		outputBox:SetText(replaceIconsAndLineBreaks(currentMessage))
		UIDropDownMenu_SetText(channelDropdown, currentChannel)
		rateInput:SetText(tostring(math.floor(currentRate))) -- Display rate in minutes without decimal places
		frame:SetWidth(inputBox:GetWidth() + padding * 2)
	end)

	return frame
end

local floodPromptFrame = AUTOFLOODGUI()

--- Show the flood message UI
function AutoFlood_ShowUI()
	floodPromptFrame:Show()
end

-- /floodui
-- Open the flood message UI
SlashCmdList["AUTOFLOODGUI"] = AutoFlood_ShowUI

-- Command alias
SLASH_AUTOFLOODGUI1 = "/floodui"
