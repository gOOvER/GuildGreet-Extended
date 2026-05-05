------------------------------------------------------------
-- GuildGreet UI Helpers Library
-- Handles UI text coloring, printing, tab management and general UI utilities  
------------------------------------------------------------

GLDG.UIHelpers = {}

------------------------------------------------------------
-- Set text color for UI elements using color configuration
function GLDG.UIHelpers:SetTextColor(textName, setName, colourName)
	if not (textName and setName and colourName) then return end
	if not GLDG:GetColors()[setName] then return end
	if not GLDG:GetColors()[setName][colourName] then return end

	local colour = GLDG:GetColors()[setName][colourName]
	local a,r,g,b = GLDG_ColourToRGB_perc(colour)

	local text = _G[textName]
	if text then text:SetTextColor(r, g, b) end
end

------------------------------------------------------------
-- Enhanced print function with chat frame support
function GLDG.UIHelpers:Print(msg, forceDefault)
	if not (msg) then return end
	
	-- Use AceConsole for default output or when no specific chat frame is configured
	if ((GLDG_Data==nil) or (GLDG_Data.PlayerChatFrame[GLDG.Player.."-"..GLDG.Realm] == nil) or (GLDG_Data.PlayerChatFrame[GLDG.Player.."-"..GLDG.Realm]==0) or forceDefault) then
		GLDG:Print(msg)
	else
		-- Keep existing chat frame functionality for user-configured frames
		_G["ChatFrame"..GLDG_Data.PlayerChatFrame[GLDG.Player.."-"..GLDG.Realm]]:AddMessage(msg)
	end
end

------------------------------------------------------------
-- Tab management for main interface
function GLDG.UIHelpers:ClickTab(self, tabName)
	-- Actions to perform when a tab is clicked
	PanelTemplates_Tab_OnClick(self, _G[GLDG_GUI])
	-- Show frame linked to tab, hide all others
	local tabNum = 1
	while _G[GLDG_GUI.."Tab"..tabNum] do
		local frame = nil
		if GLDG_Tab2Frame["Tab"..tabNum] then
			frame = _G[GLDG_GUI..GLDG_Tab2Frame["Tab"..tabNum]]
		end
		if frame then
			if (tabName == GLDG_GUI.."Tab"..tabNum) then
				frame:Show()
			else
				frame:Hide()
			end
		end
		tabNum = tabNum + 1
	end
end

------------------------------------------------------------
-- Tab management for settings sub-interface
function GLDG.UIHelpers:ClickSubTab(self, tabName)
	-- Actions to perform when a tab is clicked
	PanelTemplates_Tab_OnClick(self, _G[GLDG_GUI.."Settings"])
	-- Show frame linked to tab, hide all others
	local tabNum = 1
	while _G[GLDG_GUI.."SettingsTab"..tabNum] do
		local frame = nil
		if GLDG_SubTab2Frame["Tab"..tabNum] then 
			frame = _G[GLDG_GUI.."Settings"..GLDG_SubTab2Frame["Tab"..tabNum]] 
		end
		if frame then 
			if (tabName == GLDG_GUI.."SettingsTab"..tabNum) then 
				frame:Show() 
			else 
				frame:Hide() 
			end 
		end
		tabNum = tabNum + 1
	end
end

------------------------------------------------------------
-- Clear greetings queue
function GLDG.UIHelpers:ClearList()
	for name in pairs(GLDG_Queue) do
		GLDG_CleanupPlayer(name)
	end
	GLDG_Queue = {}
	GLDG_ShowQueue()
end