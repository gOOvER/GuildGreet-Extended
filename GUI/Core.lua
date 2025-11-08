--[[
	GuildGreet GUI Manager
	Handles the main AceGUI interface and coordinates between different GUI modules
]]--

local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
local AceGUI = LibStub("AceGUI-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", false)

local GUI = GLDG:NewModule("GUI")

-- GUI State
GUI.mainFrame = nil
GUI.isOpen = false
GUI.currentTab = "Settings"

-- Tab definitions
GUI.tabs = {
	{name = "Settings", text = L["Settings"], module = "SettingsGUI"},
	{name = "Greetings", text = L["Greetings"], module = "GreetingsGUI"},
	{name = "Players", text = L["Players"], module = "PlayersGUI"},
	{name = "Cleanup", text = L["Cleanup"], module = "CleanupGUI"},
	{name = "Colour", text = L["Colour"], module = "ColourGUI"}
}

--[[
	Initialize GUI
]]
function GUI:OnInitialize()
	-- Register slash commands
	GLDG:RegisterChatCommand("guildgreet", "OpenGUI")
	GLDG:RegisterChatCommand("gg", "OpenGUI")
end

--[[
	Open the main GUI window
]]
function GUI:OpenGUI(input)
	if not input or input:trim() == "" then
		self:ShowMainWindow()
	else
		-- Handle slash command arguments
		local args = {strsplit(" ", input:lower())}
		if args[1] == "config" or args[1] == "options" then
			self:ShowMainWindow()
		elseif args[1] == "close" then
			self:CloseMainWindow()
		else
			-- Handle other commands in main addon
			GLDG:HandleSlashCommand(input)
		end
	end
end

--[[
	Create and show the main window
]]
function GUI:ShowMainWindow()
	if self.mainFrame then
		self.mainFrame:Show()
		self.isOpen = true
		return
	end

	-- Create main frame with version-safe metadata access
	local frame = AceGUI:Create("Frame")
	local version = GLDG_GetAddOnMetadata("GuildGreet", "Version") or "Unknown"
	frame:SetTitle("GuildGreet " .. version)
	frame:SetWidth(800)
	frame:SetHeight(600)
	frame:SetLayout("Fill")
	
	-- Set callbacks
	frame:SetCallback("OnClose", function(widget)
		self.isOpen = false
	end)
	
	-- Create tab group
	local tabGroup = AceGUI:Create("TabGroup")
	tabGroup:SetLayout("Fill")
	tabGroup:SetFullWidth(true)
	tabGroup:SetFullHeight(true)
	
	-- Setup tabs
	local tabs = {}
	for i, tab in ipairs(self.tabs) do
		tabs[i] = {text = tab.text, value = tab.name}
	end
	tabGroup:SetTabs(tabs)
	
	-- Tab selection callback
	tabGroup:SetCallback("OnGroupSelected", function(widget, event, group)
		self:SelectTab(group)
	end)
	
	frame:AddChild(tabGroup)
	
	-- Store references
	self.mainFrame = frame
	self.tabGroup = tabGroup
	self.isOpen = true
	
	-- Select initial tab
	tabGroup:SelectTab(self.currentTab)
end

--[[
	Close the main window
]]
function GUI:CloseMainWindow()
	if self.mainFrame then
		self.mainFrame:Hide()
		self.isOpen = false
	end
end

--[[
	Handle tab selection
]]
function GUI:SelectTab(tabName)
	self.currentTab = tabName
	
	-- Clear current content
	self.tabGroup:ReleaseChildren()
	
	-- Find tab definition
	local tabDef = nil
	for _, tab in ipairs(self.tabs) do
		if tab.name == tabName then
			tabDef = tab
			break
		end
	end
	
	if not tabDef then
		self:ShowErrorTab("Unknown tab: " .. tostring(tabName))
		return
	end
	
	-- Load tab module
	local module = GLDG:GetModule(tabDef.module, true)
	if not module then
		self:ShowErrorTab("Module not found: " .. tabDef.module)
		return
	end
	
	-- Create tab content
	if module.CreateTabContent then
		module:CreateTabContent(self.tabGroup)
	else
		self:ShowErrorTab("Module has no CreateTabContent method: " .. tabDef.module)
	end
end

--[[
	Show error message in tab
]]
function GUI:ShowErrorTab(message)
	local label = AceGUI:Create("Label")
	label:SetText("Error: " .. message)
	label:SetColor(1, 0, 0) -- Red
	label:SetFullWidth(true)
	self.tabGroup:AddChild(label)
end

--[[
	Toggle main window visibility
]]
function GUI:ToggleMainWindow()
	if self.isOpen then
		self:CloseMainWindow()
	else
		self:ShowMainWindow()
	end
end

--[[
	Check if main window is open
]]
function GUI:IsOpen()
	return self.isOpen
end

-- Make GUI functions available to main addon
GLDG.OpenGUI = function(self, input) GUI:OpenGUI(input) end
GLDG.ToggleGUI = function(self) GUI:ToggleMainWindow() end
GLDG.CloseGUI = function(self) GUI:CloseMainWindow() end