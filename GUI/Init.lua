--[[
	GuildGreet GUI Initialization
	Initializes the new AceGUI-based interface system
]]--

local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", false)

-- Initialize GUI system after addon is fully loaded
function GLDG:InitializeGUI()
	-- Ensure all GUI modules are loaded
	if not self:GetModule("CoreGUI", true) then
		self:Print("Error: CoreGUI module not loaded!")
		return
	end
	
	-- Initialize the core GUI module
	local coreGUI = self:GetModule("CoreGUI")
	if coreGUI.Initialize then
		coreGUI:Initialize()
	end
	
	-- Register slash commands for the new GUI
	SLASH_GUILDGREET1 = "/gg"
	SLASH_GUILDGREET2 = "/guildgreet"
	SLASH_GUILDGREET3 = "/ggreet"
	
	SlashCmdList["GUILDGREET"] = function(msg)
		msg = msg:lower():trim()
		
		if msg == "show" or msg == "" then
			coreGUI:ShowMainWindow()
		elseif msg == "hide" then
			coreGUI:HideMainWindow()
		elseif msg == "toggle" then
			coreGUI:ToggleMainWindow()
		elseif msg == "config" or msg == "settings" then
			coreGUI:ShowMainWindow("Settings")
		elseif msg == "players" then
			coreGUI:ShowMainWindow("Players")
		elseif msg == "greetings" then
			coreGUI:ShowMainWindow("Greetings")
		elseif msg == "cleanup" then
			coreGUI:ShowMainWindow("Cleanup")
		elseif msg == "colours" or msg == "colors" then
			coreGUI:ShowMainWindow("Colour")
		elseif msg == "help" then
			self:ShowSlashHelp()
		else
			self:ShowSlashHelp()
		end
	end
	
	-- Add minimap button handler
	if self.minimapButton then
		self.minimapButton.OnClick = function(self, button)
			if button == "LeftButton" then
				coreGUI:ToggleMainWindow()
			elseif button == "RightButton" then
				coreGUI:ShowMainWindow("Settings")
			end
		end
	end
	
	-- Add to addon compartment if available (Dragonflight+)
	if AddonCompartmentFrame then
		AddonCompartmentFrame:RegisterAddon({
			text = "GuildGreet",
			icon = "Interface\\Icons\\Spell_Misc_FortuneTelling",
			notCheckable = true,
			func = function()
				coreGUI:ToggleMainWindow()
			end
		})
	end
	
	self:Print(L["GUI system initialized. Type /gg to open the interface."] or "GUI system initialized. Type /gg to open the interface.")
end

--[[
	Show slash command help
]]
function GLDG:ShowSlashHelp()
	self:Print(L["GuildGreet Commands:"] or "GuildGreet Commands:")
	self:Print("/gg show - " .. (L["Show main window"] or "Show main window"))
	self:Print("/gg hide - " .. (L["Hide main window"] or "Hide main window"))
	self:Print("/gg toggle - " .. (L["Toggle main window"] or "Toggle main window"))
	self:Print("/gg config - " .. (L["Open settings"] or "Open settings"))
	self:Print("/gg players - " .. (L["Open players tab"] or "Open players tab"))
	self:Print("/gg greetings - " .. (L["Open greetings tab"] or "Open greetings tab"))
	self:Print("/gg cleanup - " .. (L["Open cleanup tab"] or "Open cleanup tab"))
	self:Print("/gg colours - " .. (L["Open colours tab"] or "Open colours tab"))
	self:Print("/gg help - " .. (L["Show this help"] or "Show this help"))
end

--[[
	Legacy XML GUI compatibility functions
	These maintain compatibility for any code that still references the old XML frames
]]

-- Show main frame (legacy compatibility)
function GLDG_MainFrame_Show()
	if GLDG and GLDG:GetModule("CoreGUI", true) then
		GLDG:GetModule("CoreGUI"):ShowMainWindow()
	end
end

-- Hide main frame (legacy compatibility)  
function GLDG_MainFrame_Hide()
	if GLDG and GLDG:GetModule("CoreGUI", true) then
		GLDG:GetModule("CoreGUI"):HideMainWindow()
	end
end

-- Toggle main frame (legacy compatibility)
function GLDG_MainFrame_Toggle()
	if GLDG and GLDG:GetModule("CoreGUI", true) then
		GLDG:GetModule("CoreGUI"):ToggleMainWindow()
	end
end

-- Update player list (legacy compatibility)
function GLDG_UpdatePlayerList()
	if GLDG and GLDG:GetModule("PlayersGUI", true) then
		GLDG:GetModule("PlayersGUI"):RefreshPlayerList()
	end
end

-- Update greeting list (legacy compatibility)
function GLDG_UpdateGreetingList()
	if GLDG and GLDG:GetModule("GreetingsGUI", true) then
		GLDG:GetModule("GreetingsGUI"):RefreshGreetingList()
	end
end

-- Open settings (legacy compatibility)
function GLDG_OpenSettings()
	if GLDG and GLDG:GetModule("CoreGUI", true) then
		GLDG:GetModule("CoreGUI"):ShowMainWindow("Settings")
	end
end

-- Initialize GUI when addon is ready
GLDG:RegisterEvent("ADDON_LOADED")
GLDG:SetCallback("OnModuleCreated", function(addon, module)
	-- When all modules are loaded, initialize GUI
	if module.GetName and module:GetName() == "ColourGUI" then
		-- This is the last GUI module to load, so initialize now
		C_Timer.After(0.1, function()
			GLDG:InitializeGUI()
		end)
	end
end)