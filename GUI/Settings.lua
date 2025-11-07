--[[
	GuildGreet Settings GUI Module
	Handles the Settings tab interface
]]--

local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", false)

local SettingsGUI = GLDG:NewModule("SettingsGUI")

-- Sub-tabs for Settings
SettingsGUI.subTabs = {
	{name = "General", text = L["General"]},
	{name = "Chat", text = L["Chat"]},
	{name = "Greeting", text = L["Greeting"]},
	{name = "Other", text = L["Other"]}
}

--[[
	Create the Settings tab content
]]
function SettingsGUI:CreateTabContent(container)
	-- Create sub-tab group
	local subTabGroup = AceGUI:Create("TabGroup")
	subTabGroup:SetLayout("Flow")
	subTabGroup:SetFullWidth(true)
	subTabGroup:SetFullHeight(true)
	
	-- Setup sub-tabs
	local tabs = {}
	for i, tab in ipairs(self.subTabs) do
		tabs[i] = {text = tab.text, value = tab.name}
	end
	subTabGroup:SetTabs(tabs)
	
	-- Sub-tab selection callback
	subTabGroup:SetCallback("OnGroupSelected", function(widget, event, group)
		self:SelectSubTab(group, widget)
	end)
	
	container:AddChild(subTabGroup)
	
	-- Store reference
	self.subTabGroup = subTabGroup
	
	-- Select initial sub-tab
	subTabGroup:SelectTab("General")
end

--[[
	Handle sub-tab selection
]]
function SettingsGUI:SelectSubTab(subTabName, container)
	-- Clear current content
	container:ReleaseChildren()
	
	-- Create content based on sub-tab
	if subTabName == "General" then
		self:CreateGeneralTab(container)
	elseif subTabName == "Chat" then
		self:CreateChatTab(container)
	elseif subTabName == "Greeting" then
		self:CreateGreetingTab(container)
	elseif subTabName == "Other" then
		self:CreateOtherTab(container)
	end
end

--[[
	Create General Settings tab
]]
function SettingsGUI:CreateGeneralTab(container)
	local scrollFrame = AceGUI:Create("ScrollFrame")
	scrollFrame:SetFullWidth(true)
	scrollFrame:SetFullHeight(true)
	scrollFrame:SetLayout("Flow")
	
	-- Basic Settings Group
	local basicGroup = AceGUI:Create("InlineGroup")
	basicGroup:SetTitle(L["Basic Settings"] or "Basic Settings")
	basicGroup:SetFullWidth(true)
	basicGroup:SetLayout("Flow")
	
	-- Auto greet checkbox
	local autoGreet = AceGUI:Create("CheckBox")
	autoGreet:SetLabel(L["Auto greet guild members"] or "Auto greet guild members")
	autoGreet:SetValue(GLDG_Data.AutoGreet or false)
	autoGreet:SetCallback("OnValueChanged", function(widget, event, value)
		GLDG_Data.AutoGreet = value
	end)
	autoGreet:SetFullWidth(true)
	basicGroup:AddChild(autoGreet)
	
	-- Greet as main checkbox
	local greetAsMain = AceGUI:Create("CheckBox")
	greetAsMain:SetLabel(L["Greet as main character"] or "Greet as main character")
	greetAsMain:SetValue(GLDG_Data.GuildSettings and GLDG_Data.GuildSettings.GreetAsMain or false)
	greetAsMain:SetCallback("OnValueChanged", function(widget, event, value)
		if not GLDG_Data.GuildSettings then GLDG_Data.GuildSettings = {} end
		GLDG_Data.GuildSettings.GreetAsMain = value
	end)
	greetAsMain:SetFullWidth(true)
	basicGroup:AddChild(greetAsMain)
	
	-- Randomize messages checkbox
	local randomize = AceGUI:Create("CheckBox")
	randomize:SetLabel(L["Randomize messages"] or "Randomize messages")
	randomize:SetValue(GLDG_Data.GuildSettings and GLDG_Data.GuildSettings.Randomize or false)
	randomize:SetCallback("OnValueChanged", function(widget, event, value)
		if not GLDG_Data.GuildSettings then GLDG_Data.GuildSettings = {} end
		GLDG_Data.GuildSettings.Randomize = value
	end)
	randomize:SetFullWidth(true)
	basicGroup:AddChild(randomize)
	
	scrollFrame:AddChild(basicGroup)
	
	-- Level Settings Group
	local levelGroup = AceGUI:Create("InlineGroup")
	levelGroup:SetTitle(L["Level Settings"] or "Level Settings")
	levelGroup:SetFullWidth(true)
	levelGroup:SetLayout("Flow")
	
	-- Min level slider
	local minLevel = AceGUI:Create("Slider")
	minLevel:SetLabel(L["Minimum level to greet"] or "Minimum level to greet")
	minLevel:SetSliderValues(1, GLDG_LEVEL_CAP or 80, 1)
	minLevel:SetValue(GLDG_Data.MinLevel or 1)
	minLevel:SetCallback("OnValueChanged", function(widget, event, value)
		GLDG_Data.MinLevel = value
	end)
	minLevel:SetFullWidth(true)
	levelGroup:AddChild(minLevel)
	
	-- Max level slider
	local maxLevel = AceGUI:Create("Slider")
	maxLevel:SetLabel(L["Maximum level to greet"] or "Maximum level to greet")
	maxLevel:SetSliderValues(1, GLDG_LEVEL_CAP or 80, 1)
	maxLevel:SetValue(GLDG_Data.MaxLevel or 80)
	maxLevel:SetCallback("OnValueChanged", function(widget, event, value)
		GLDG_Data.MaxLevel = value
	end)
	maxLevel:SetFullWidth(true)
	levelGroup:AddChild(maxLevel)
	
	scrollFrame:AddChild(levelGroup)
	container:AddChild(scrollFrame)
end

--[[
	Create Chat Settings tab
]]
function SettingsGUI:CreateChatTab(container)
	local scrollFrame = AceGUI:Create("ScrollFrame")
	scrollFrame:SetFullWidth(true)
	scrollFrame:SetFullHeight(true)
	scrollFrame:SetLayout("Flow")
	
	-- Chat Options Group
	local chatGroup = AceGUI:Create("InlineGroup")
	chatGroup:SetTitle(L["Chat Options"] or "Chat Options")
	chatGroup:SetFullWidth(true)
	chatGroup:SetLayout("Flow")
	
	-- Use whisper checkbox
	local whisper = AceGUI:Create("CheckBox")
	whisper:SetLabel(L["Use whisper for greetings"] or "Use whisper for greetings")
	whisper:SetValue(GLDG_Data.GuildSettings and GLDG_Data.GuildSettings.Whisper or false)
	whisper:SetCallback("OnValueChanged", function(widget, event, value)
		if not GLDG_Data.GuildSettings then GLDG_Data.GuildSettings = {} end
		GLDG_Data.GuildSettings.Whisper = value
	end)
	whisper:SetFullWidth(true)
	chatGroup:AddChild(whisper)
	
	-- Show in chat frame dropdown
	local chatFrame = AceGUI:Create("Dropdown")
	chatFrame:SetLabel(L["Show messages in chat frame"] or "Show messages in chat frame")
	chatFrame:SetList({
		[0] = L["Disabled"] or "Disabled",
		[1] = "Chat Frame 1",
		[2] = "Chat Frame 2",
		[3] = "Chat Frame 3",
		[4] = "Chat Frame 4"
	})
	chatFrame:SetValue(GLDG_Data.ChatFrame or 0)
	chatFrame:SetCallback("OnValueChanged", function(widget, event, key, value)
		GLDG_Data.ChatFrame = key
	end)
	chatFrame:SetFullWidth(true)
	chatGroup:AddChild(chatFrame)
	
	scrollFrame:AddChild(chatGroup)
	container:AddChild(scrollFrame)
end

--[[
	Create Greeting Settings tab
]]
function SettingsGUI:CreateGreetingTab(container)
	local scrollFrame = AceGUI:Create("ScrollFrame")
	scrollFrame:SetFullWidth(true)
	scrollFrame:SetFullHeight(true)
	scrollFrame:SetLayout("Flow")
	
	-- Greeting Timing Group
	local timingGroup = AceGUI:Create("InlineGroup")
	timingGroup:SetTitle(L["Greeting Timing"] or "Greeting Timing")
	timingGroup:SetFullWidth(true)
	timingGroup:SetLayout("Flow")
	
	-- Greeting delay slider
	local delay = AceGUI:Create("Slider")
	delay:SetLabel(L["Delay before greeting (seconds)"] or "Delay before greeting (seconds)")
	delay:SetSliderValues(0, 180, 5)
	delay:SetValue(GLDG_Data.GreetingDelay or 10)
	delay:SetCallback("OnValueChanged", function(widget, event, value)
		GLDG_Data.GreetingDelay = value
	end)
	delay:SetFullWidth(true)
	timingGroup:AddChild(delay)
	
	scrollFrame:AddChild(timingGroup)
	
	-- Auto Actions Group
	local actionsGroup = AceGUI:Create("InlineGroup")
	actionsGroup:SetTitle(L["Auto Actions"] or "Auto Actions")
	actionsGroup:SetFullWidth(true)
	actionsGroup:SetLayout("Flow")
	
	-- Auto assign main/alt checkbox
	local autoAssign = AceGUI:Create("CheckBox")
	autoAssign:SetLabel(L["Auto assign main/alt relationships"] or "Auto assign main/alt relationships")
	autoAssign:SetValue(GLDG_Data.GuildSettings and GLDG_Data.GuildSettings.AutoAssign or false)
	autoAssign:SetCallback("OnValueChanged", function(widget, event, value)
		if not GLDG_Data.GuildSettings then GLDG_Data.GuildSettings = {} end
		GLDG_Data.GuildSettings.AutoAssign = value
	end)
	autoAssign:SetFullWidth(true)
	actionsGroup:AddChild(autoAssign)
	
	scrollFrame:AddChild(actionsGroup)
	container:AddChild(scrollFrame)
end

--[[
	Create Other Settings tab
]]
function SettingsGUI:CreateOtherTab(container)
	local scrollFrame = AceGUI:Create("ScrollFrame")
	scrollFrame:SetFullWidth(true)
	scrollFrame:SetFullHeight(true)
	scrollFrame:SetLayout("Flow")
	
	-- Debug Group
	local debugGroup = AceGUI:Create("InlineGroup")
	debugGroup:SetTitle(L["Debug Options"] or "Debug Options")
	debugGroup:SetFullWidth(true)
	debugGroup:SetLayout("Flow")
	
	-- Debug mode checkbox
	local debug = AceGUI:Create("CheckBox")
	debug:SetLabel(L["Enable debug mode"] or "Enable debug mode")
	debug:SetValue(GLDG_Debug or false)
	debug:SetCallback("OnValueChanged", function(widget, event, value)
		GLDG_Debug = value
	end)
	debug:SetFullWidth(true)
	debugGroup:AddChild(debug)
	
	scrollFrame:AddChild(debugGroup)
	
	-- Version Info Group
	local versionGroup = AceGUI:Create("InlineGroup")
	versionGroup:SetTitle(L["Version Information"] or "Version Information")
	versionGroup:SetFullWidth(true)
	versionGroup:SetLayout("Flow")
	
	-- Version label
	local version = AceGUI:Create("Label")
	version:SetText((L["Version"] or "Version") .. ": " .. (GetAddOnMetadata("GuildGreet", "Version") or "Unknown"))
	version:SetFullWidth(true)
	versionGroup:AddChild(version)
	
	-- Author label
	local author = AceGUI:Create("Label")
	author:SetText((L["Author"] or "Author") .. ": " .. (GetAddOnMetadata("GuildGreet", "Author") or "Unknown"))
	author:SetFullWidth(true)
	versionGroup:AddChild(author)
	
	scrollFrame:AddChild(versionGroup)
	container:AddChild(scrollFrame)
end