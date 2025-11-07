--[[
	GuildGreet Colour GUI Module
	Handles the Colour tab interface
]]--

local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", false)

local ColourGUI = GLDG:NewModule("ColourGUI")

-- Current state
ColourGUI.currentColours = {}

--[[
	Create the Colour tab content
]]
function ColourGUI:CreateTabContent(container)
	-- Main scroll frame
	local scrollFrame = AceGUI:Create("ScrollFrame")
	scrollFrame:SetFullWidth(true)
	scrollFrame:SetFullHeight(true)
	scrollFrame:SetLayout("Flow")
	
	-- Information section
	local infoGroup = AceGUI:Create("InlineGroup")
	infoGroup:SetTitle(L["Colour Settings"] or "Colour Settings")
	infoGroup:SetFullWidth(true)
	infoGroup:SetHeight(80)
	infoGroup:SetLayout("Flow")
	
	local infoText = AceGUI:Create("Label")
	infoText:SetText(L["Configure colours for different guild ranks and roles. Click on a colour button to change it."] or "Configure colours for different guild ranks and roles. Click on a colour button to change it.")
	infoText:SetFullWidth(true)
	infoGroup:AddChild(infoText)
	
	scrollFrame:AddChild(infoGroup)
	
	-- Guild Rank Colours
	local rankGroup = AceGUI:Create("InlineGroup")
	rankGroup:SetTitle(L["Guild Rank Colours"] or "Guild Rank Colours")
	rankGroup:SetFullWidth(true)
	rankGroup:SetHeight(300)
	rankGroup:SetLayout("Flow")
	
	-- Get guild ranks if in guild
	local guildRanks = {}
	if IsInGuild() then
		for i = 0, 9 do
			local rankName = GuildControlGetRankName(i)
			if rankName and rankName ~= "" then
				table.insert(guildRanks, {index = i, name = rankName})
			end
		end
	else
		-- Default ranks for demonstration
		for i = 0, 9 do
			table.insert(guildRanks, {index = i, name = "Rank " .. i})
		end
	end
	
	-- Create colour pickers for each rank
	for _, rank in ipairs(guildRanks) do
		local rankLabel = AceGUI:Create("Label")
		rankLabel:SetText(rank.name .. ":")
		rankLabel:SetWidth(150)
		rankGroup:AddChild(rankLabel)
		
		local colourButton = AceGUI:Create("Button")
		colourButton:SetText("■ ■ ■")
		colourButton:SetWidth(100)
		
		-- Get current colour
		local currentColour = self:GetRankColour(rank.index)
		colourButton:SetText(self:ColourText("■ ■ ■", currentColour))
		
		colourButton:SetCallback("OnClick", function()
			self:ShowColourPicker(rank.index, rank.name, currentColour, function(newColour)
				self:SetRankColour(rank.index, newColour)
				colourButton:SetText(self:ColourText("■ ■ ■", newColour))
			end)
		end)
		rankGroup:AddChild(colourButton)
		
		-- Reset button
		local resetBtn = AceGUI:Create("Button")
		resetBtn:SetText(L["Reset"] or "Reset")
		resetBtn:SetWidth(80)
		resetBtn:SetCallback("OnClick", function()
			local defaultColour = self:GetDefaultRankColour(rank.index)
			self:SetRankColour(rank.index, defaultColour)
			colourButton:SetText(self:ColourText("■ ■ ■", defaultColour))
		end)
		rankGroup:AddChild(resetBtn)
	end
	
	scrollFrame:AddChild(rankGroup)
	
	-- Special Role Colours
	local roleGroup = AceGUI:Create("InlineGroup")
	roleGroup:SetTitle(L["Special Role Colours"] or "Special Role Colours")
	roleGroup:SetFullWidth(true)
	roleGroup:SetHeight(200)
	roleGroup:SetLayout("Flow")
	
	-- Special roles
	local specialRoles = {
		{key = "guild_master", name = L["Guild Master"] or "Guild Master"},
		{key = "officer", name = L["Officer"] or "Officer"},
		{key = "veteran", name = L["Veteran"] or "Veteran"},
		{key = "member", name = L["Member"] or "Member"},
		{key = "recruit", name = L["Recruit"] or "Recruit"},
		{key = "alt", name = L["Alt Character"] or "Alt Character"}
	}
	
	for _, role in ipairs(specialRoles) do
		local roleLabel = AceGUI:Create("Label")
		roleLabel:SetText(role.name .. ":")
		roleLabel:SetWidth(150)
		roleGroup:AddChild(roleLabel)
		
		local colourButton = AceGUI:Create("Button")
		colourButton:SetText("■ ■ ■")
		colourButton:SetWidth(100)
		
		-- Get current colour
		local currentColour = self:GetSpecialColour(role.key)
		colourButton:SetText(self:ColourText("■ ■ ■", currentColour))
		
		colourButton:SetCallback("OnClick", function()
			self:ShowColourPicker(role.key, role.name, currentColour, function(newColour)
				self:SetSpecialColour(role.key, newColour)
				colourButton:SetText(self:ColourText("■ ■ ■", newColour))
			end)
		end)
		roleGroup:AddChild(colourButton)
		
		-- Reset button
		local resetBtn = AceGUI:Create("Button")
		resetBtn:SetText(L["Reset"] or "Reset")
		resetBtn:SetWidth(80)
		resetBtn:SetCallback("OnClick", function()
			local defaultColour = self:GetDefaultSpecialColour(role.key)
			self:SetSpecialColour(role.key, defaultColour)
			colourButton:SetText(self:ColourText("■ ■ ■", defaultColour))
		end)
		roleGroup:AddChild(resetBtn)
	end
	
	scrollFrame:AddChild(roleGroup)
	
	-- Chat Message Colours
	local chatGroup = AceGUI:Create("InlineGroup")
	chatGroup:SetTitle(L["Chat Message Colours"] or "Chat Message Colours")
	chatGroup:SetFullWidth(true)
	chatGroup:SetHeight(150)
	chatGroup:SetLayout("Flow")
	
	-- Chat colour types
	local chatTypes = {
		{key = "greeting", name = L["Greeting Messages"] or "Greeting Messages"},
		{key = "whisper", name = L["Whisper Messages"] or "Whisper Messages"},
		{key = "system", name = L["System Messages"] or "System Messages"}
	}
	
	for _, chatType in ipairs(chatTypes) do
		local typeLabel = AceGUI:Create("Label")
		typeLabel:SetText(chatType.name .. ":")
		typeLabel:SetWidth(150)
		chatGroup:AddChild(typeLabel)
		
		local colourButton = AceGUI:Create("Button")
		colourButton:SetText("■ ■ ■")
		colourButton:SetWidth(100)
		
		-- Get current colour
		local currentColour = self:GetChatColour(chatType.key)
		colourButton:SetText(self:ColourText("■ ■ ■", currentColour))
		
		colourButton:SetCallback("OnClick", function()
			self:ShowColourPicker(chatType.key, chatType.name, currentColour, function(newColour)
				self:SetChatColour(chatType.key, newColour)
				colourButton:SetText(self:ColourText("■ ■ ■", newColour))
			end)
		end)
		chatGroup:AddChild(colourButton)
		
		-- Reset button
		local resetBtn = AceGUI:Create("Button")
		resetBtn:SetText(L["Reset"] or "Reset")
		resetBtn:SetWidth(80)
		resetBtn:SetCallback("OnClick", function()
			local defaultColour = self:GetDefaultChatColour(chatType.key)
			self:SetChatColour(chatType.key, defaultColour)
			colourButton:SetText(self:ColourText("■ ■ ■", defaultColour))
		end)
		chatGroup:AddChild(resetBtn)
	end
	
	scrollFrame:AddChild(chatGroup)
	
	-- Control buttons
	local controlGroup = AceGUI:Create("InlineGroup")
	controlGroup:SetTitle(L["Colour Controls"] or "Colour Controls")
	controlGroup:SetFullWidth(true)
	controlGroup:SetHeight(100)
	controlGroup:SetLayout("Flow")
	
	-- Reset all colours
	local resetAllBtn = AceGUI:Create("Button")
	resetAllBtn:SetText(L["Reset All Colours"] or "Reset All Colours")
	resetAllBtn:SetWidth(200)
	resetAllBtn:SetCallback("OnClick", function()
		self:ResetAllColours()
		-- Refresh the interface
		container:ReleaseChildren()
		self:CreateTabContent(container)
	end)
	controlGroup:AddChild(resetAllBtn)
	
	-- Import colour scheme
	local importBtn = AceGUI:Create("Button")
	importBtn:SetText(L["Import Scheme"] or "Import Scheme")
	importBtn:SetWidth(150)
	importBtn:SetCallback("OnClick", function()
		self:ImportColourScheme()
	end)
	controlGroup:AddChild(importBtn)
	
	-- Export colour scheme
	local exportBtn = AceGUI:Create("Button")
	exportBtn:SetText(L["Export Scheme"] or "Export Scheme")
	exportBtn:SetWidth(150)
	exportBtn:SetCallback("OnClick", function()
		self:ExportColourScheme()
	end)
	controlGroup:AddChild(exportBtn)
	
	scrollFrame:AddChild(controlGroup)
	container:AddChild(scrollFrame)
end

--[[
	Show colour picker dialog
]]
function ColourGUI:ShowColourPicker(key, name, currentColour, callback)
	-- Create colour picker dialog using AceGUI
	local dialog = AceGUI:Create("Window")
	dialog:SetTitle(string.format(L["Choose colour for %s"] or "Choose colour for %s", name))
	dialog:SetWidth(400)
	dialog:SetHeight(300)
	dialog:SetLayout("Flow")
	
	-- Current colour preview
	local previewGroup = AceGUI:Create("InlineGroup")
	previewGroup:SetTitle(L["Current Colour"] or "Current Colour")
	previewGroup:SetFullWidth(true)
	previewGroup:SetHeight(80)
	previewGroup:SetLayout("Flow")
	
	local previewLabel = AceGUI:Create("Label")
	previewLabel:SetText(self:ColourText("Sample Text", currentColour))
	previewLabel:SetFullWidth(true)
	previewGroup:AddChild(previewLabel)
	
	dialog:AddChild(previewGroup)
	
	-- RGB sliders
	local rgbGroup = AceGUI:Create("InlineGroup")
	rgbGroup:SetTitle(L["RGB Values"] or "RGB Values")
	rgbGroup:SetFullWidth(true)
	rgbGroup:SetHeight(120)
	rgbGroup:SetLayout("Flow")
	
	local r, g, b = self:HexToRGB(currentColour)
	
	-- Red slider
	local redSlider = AceGUI:Create("Slider")
	redSlider:SetLabel(L["Red"] or "Red")
	redSlider:SetSliderValues(0, 255, 1)
	redSlider:SetValue(r)
	redSlider:SetFullWidth(true)
	redSlider:SetCallback("OnValueChanged", function(widget, event, value)
		local newR, newG, newB = value, g, b
		g = newG or g
		b = newB or b
		local newColour = self:RGBToHex(newR, newG, newB)
		previewLabel:SetText(self:ColourText("Sample Text", newColour))
		currentColour = newColour
	end)
	rgbGroup:AddChild(redSlider)
	
	-- Green slider
	local greenSlider = AceGUI:Create("Slider")
	greenSlider:SetLabel(L["Green"] or "Green")
	greenSlider:SetSliderValues(0, 255, 1)
	greenSlider:SetValue(g)
	greenSlider:SetFullWidth(true)
	greenSlider:SetCallback("OnValueChanged", function(widget, event, value)
		local newR, newG, newB = r, value, b
		r = newR or r
		b = newB or b
		local newColour = self:RGBToHex(newR, newG, newB)
		previewLabel:SetText(self:ColourText("Sample Text", newColour))
		currentColour = newColour
	end)
	rgbGroup:AddChild(greenSlider)
	
	-- Blue slider
	local blueSlider = AceGUI:Create("Slider")
	blueSlider:SetLabel(L["Blue"] or "Blue")
	blueSlider:SetSliderValues(0, 255, 1)
	blueSlider:SetValue(b)
	blueSlider:SetFullWidth(true)
	blueSlider:SetCallback("OnValueChanged", function(widget, event, value)
		local newR, newG, newB = r, g, value
		r = newR or r
		g = newG or g
		local newColour = self:RGBToHex(newR, newG, newB)
		previewLabel:SetText(self:ColourText("Sample Text", newColour))
		currentColour = newColour
	end)
	rgbGroup:AddChild(blueSlider)
	
	dialog:AddChild(rgbGroup)
	
	-- Buttons
	local buttonGroup = AceGUI:Create("SimpleGroup")
	buttonGroup:SetFullWidth(true)
	buttonGroup:SetLayout("Flow")
	
	local okBtn = AceGUI:Create("Button")
	okBtn:SetText(L["OK"] or "OK")
	okBtn:SetWidth(100)
	okBtn:SetCallback("OnClick", function()
		callback(currentColour)
		dialog:Release()
	end)
	buttonGroup:AddChild(okBtn)
	
	local cancelBtn = AceGUI:Create("Button")
	cancelBtn:SetText(L["Cancel"] or "Cancel")
	cancelBtn:SetWidth(100)
	cancelBtn:SetCallback("OnClick", function()
		dialog:Release()
	end)
	buttonGroup:AddChild(cancelBtn)
	
	dialog:AddChild(buttonGroup)
end

--[[
	Get rank colour
]]
function ColourGUI:GetRankColour(rankIndex)
	if GLDG_Data and GLDG_Data.colours and GLDG_Data.colours.ranks then
		return GLDG_Data.colours.ranks[rankIndex] or self:GetDefaultRankColour(rankIndex)
	end
	return self:GetDefaultRankColour(rankIndex)
end

--[[
	Set rank colour
]]
function ColourGUI:SetRankColour(rankIndex, colour)
	if not GLDG_Data then GLDG_Data = {} end
	if not GLDG_Data.colours then GLDG_Data.colours = {} end
	if not GLDG_Data.colours.ranks then GLDG_Data.colours.ranks = {} end
	
	GLDG_Data.colours.ranks[rankIndex] = colour
end

--[[
	Get default rank colour
]]
function ColourGUI:GetDefaultRankColour(rankIndex)
	local defaultColours = {
		[0] = "FFD700", -- Guild Master - Gold
		[1] = "FF6600", -- Officer - Orange  
		[2] = "9966CC", -- Veteran - Purple
		[3] = "66CC66", -- Member - Green
		[4] = "6699FF", -- Recruit - Blue
		[5] = "CCCCCC", -- Rank 5 - Light Gray
		[6] = "999999", -- Rank 6 - Gray
		[7] = "666666", -- Rank 7 - Dark Gray
		[8] = "333333", -- Rank 8 - Very Dark Gray
		[9] = "FFFFFF"  -- Rank 9 - White
	}
	return defaultColours[rankIndex] or "FFFFFF"
end

--[[
	Get special colour
]]
function ColourGUI:GetSpecialColour(key)
	if GLDG_Data and GLDG_Data.colours and GLDG_Data.colours.special then
		return GLDG_Data.colours.special[key] or self:GetDefaultSpecialColour(key)
	end
	return self:GetDefaultSpecialColour(key)
end

--[[
	Set special colour
]]
function ColourGUI:SetSpecialColour(key, colour)
	if not GLDG_Data then GLDG_Data = {} end
	if not GLDG_Data.colours then GLDG_Data.colours = {} end
	if not GLDG_Data.colours.special then GLDG_Data.colours.special = {} end
	
	GLDG_Data.colours.special[key] = colour
end

--[[
	Get default special colour
]]
function ColourGUI:GetDefaultSpecialColour(key)
	local defaultColours = {
		guild_master = "FFD700", -- Gold
		officer = "FF6600",      -- Orange
		veteran = "9966CC",      -- Purple
		member = "66CC66",       -- Green
		recruit = "6699FF",      -- Blue
		alt = "FFCC99"          -- Light Orange
	}
	return defaultColours[key] or "FFFFFF"
end

--[[
	Get chat colour
]]
function ColourGUI:GetChatColour(key)
	if GLDG_Data and GLDG_Data.colours and GLDG_Data.colours.chat then
		return GLDG_Data.colours.chat[key] or self:GetDefaultChatColour(key)
	end
	return self:GetDefaultChatColour(key)
end

--[[
	Set chat colour
]]
function ColourGUI:SetChatColour(key, colour)
	if not GLDG_Data then GLDG_Data = {} end
	if not GLDG_Data.colours then GLDG_Data.colours = {} end
	if not GLDG_Data.colours.chat then GLDG_Data.colours.chat = {} end
	
	GLDG_Data.colours.chat[key] = colour
end

--[[
	Get default chat colour
]]
function ColourGUI:GetDefaultChatColour(key)
	local defaultColours = {
		greeting = "FFFF00", -- Yellow
		whisper = "FF69B4",  -- Hot Pink
		system = "FFFFFF"    -- White
	}
	return defaultColours[key] or "FFFFFF"
end

--[[
	Reset all colours to defaults
]]
function ColourGUI:ResetAllColours()
	if not GLDG_Data then GLDG_Data = {} end
	GLDG_Data.colours = {
		ranks = {},
		special = {},
		chat = {}
	}
	
	GLDG:Print(L["All colours reset to defaults"] or "All colours reset to defaults")
end

--[[
	Import colour scheme
]]
function ColourGUI:ImportColourScheme()
	-- Create import dialog
	local dialog = AceGUI:Create("Window")
	dialog:SetTitle(L["Import Colour Scheme"] or "Import Colour Scheme")
	dialog:SetWidth(500)
	dialog:SetHeight(300)
	dialog:SetLayout("Flow")
	
	local importText = AceGUI:Create("MultiLineEditBox")
	importText:SetLabel(L["Paste colour scheme data here"] or "Paste colour scheme data here")
	importText:SetFullWidth(true)
	importText:SetHeight(200)
	dialog:AddChild(importText)
	
	local importBtn = AceGUI:Create("Button")
	importBtn:SetText(L["Import"] or "Import")
	importBtn:SetCallback("OnClick", function()
		local text = importText:GetText()
		if self:ImportColourData(text) then
			GLDG:Print(L["Colour scheme imported successfully"] or "Colour scheme imported successfully")
			dialog:Release()
		else
			GLDG:Print(L["Failed to import colour scheme"] or "Failed to import colour scheme")
		end
	end)
	dialog:AddChild(importBtn)
	
	local closeBtn = AceGUI:Create("Button")
	closeBtn:SetText(L["Close"] or "Close")
	closeBtn:SetCallback("OnClick", function() dialog:Release() end)
	dialog:AddChild(closeBtn)
end

--[[
	Export colour scheme
]]
function ColourGUI:ExportColourScheme()
	-- Create export dialog
	local dialog = AceGUI:Create("Window")
	dialog:SetTitle(L["Export Colour Scheme"] or "Export Colour Scheme")
	dialog:SetWidth(500)
	dialog:SetHeight(300)
	dialog:SetLayout("Flow")
	
	local exportText = AceGUI:Create("MultiLineEditBox")
	exportText:SetLabel(L["Copy this text to save your colour scheme"] or "Copy this text to save your colour scheme")
	exportText:SetFullWidth(true)
	exportText:SetHeight(200)
	
	local exportData = GLDG_Data.colours or {}
	local serialized = self:SerializeColours(exportData)
	exportText:SetText(serialized)
	
	dialog:AddChild(exportText)
	
	local closeBtn = AceGUI:Create("Button")
	closeBtn:SetText(L["Close"] or "Close")
	closeBtn:SetCallback("OnClick", function() dialog:Release() end)
	dialog:AddChild(closeBtn)
end

--[[
	Colour text with hex colour
]]
function ColourGUI:ColourText(text, hexColour)
	return "|cFF" .. hexColour .. text .. "|r"
end

--[[
	Convert hex to RGB
]]
function ColourGUI:HexToRGB(hex)
	hex = hex:gsub("#", "")
	if #hex == 6 then
		return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
	end
	return 255, 255, 255
end

--[[
	Convert RGB to hex
]]
function ColourGUI:RGBToHex(r, g, b)
	return string.format("%02X%02X%02X", r, g, b)
end

--[[
	Serialize colours to string
]]
function ColourGUI:SerializeColours(colourData)
	-- Simple serialization
	local result = "-- GuildGreet Colour Scheme\n-- " .. date() .. "\n\n"
	result = result .. "local colours = {\n"
	
	if colourData.ranks then
		result = result .. "  ranks = {\n"
		for rank, colour in pairs(colourData.ranks) do
			result = result .. "    [" .. rank .. "] = \"" .. colour .. "\",\n"
		end
		result = result .. "  },\n"
	end
	
	if colourData.special then
		result = result .. "  special = {\n"
		for key, colour in pairs(colourData.special) do
			result = result .. "    [\"" .. key .. "\"] = \"" .. colour .. "\",\n"
		end
		result = result .. "  },\n"
	end
	
	if colourData.chat then
		result = result .. "  chat = {\n"
		for key, colour in pairs(colourData.chat) do
			result = result .. "    [\"" .. key .. "\"] = \"" .. colour .. "\",\n"
		end
		result = result .. "  },\n"
	end
	
	result = result .. "}\n\nreturn colours"
	return result
end

--[[
	Import colour data from string
]]
function ColourGUI:ImportColourData(text)
	local func, err = loadstring(text)
	if not func then
		return false
	end
	
	local success, colourData = pcall(func)
	if not success or type(colourData) ~= "table" then
		return false
	end
	
	-- Apply imported colours
	if not GLDG_Data then GLDG_Data = {} end
	if not GLDG_Data.colours then GLDG_Data.colours = {} end
	
	if colourData.ranks then
		GLDG_Data.colours.ranks = colourData.ranks
	end
	
	if colourData.special then
		GLDG_Data.colours.special = colourData.special
	end
	
	if colourData.chat then
		GLDG_Data.colours.chat = colourData.chat
	end
	
	return true
end