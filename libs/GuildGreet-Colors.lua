--[[--------------------------------------------------------
-- GuildGreet Color Management Library
-- Handles color schemes, color picker interface, and color utilities
------------------------------------------------------------]]

-- Get or create the GuildGreet addon instance
local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet", true) or LibStub("AceAddon-3.0"):NewAddon("GuildGreet", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", false)

-- Color Management Library Namespace
GLDG.Colors = {}

-- Color Constants
local GLDG_DEFAULT_ONLINE_COLOUR = "|cFFA0FFA0"
local GLDG_DEFAULT_IS_OFFLINE_COLOUR = "|cFFFFFFFF"
local GLDG_DEFAULT_GOES_OFFLINE_COLOUR = "|cFF7F7F7F"
local GLDG_DEFAULT_HELP_COLOUR = "|cFFFFFF7F"
local GLDG_DEFAULT_ALIAS_COLOUR = "|cFFFFA0A0"
local GLDG_DEFAULT_HEADER_COLOUR = "|c7FFF0000"
local GLDG_DEFAULT_LIST_COLOUR = "|cFFFF7F00"
local GLDG_DEFAULT_NEW_COLOUR = "|cFFFF3F3F"
local GLDG_DEFAULT_LVL_COLOUR = "|cFF7F7F7F"
local GLDG_DEFAULT_RANK_COLOUR = "|cFFCC00CC"
local GLDG_DEFAULT_RELOG_COLOUR = "|cFF3FFF3F"
local GLDG_DEFAULT_ACHIEVMENT_COLOUR = "|cFF001FFF"

-- Active Color Variables  
local GLDG_ONLINE_COLOUR = GLDG_DEFAULT_ONLINE_COLOUR
local GLDG_IS_OFFLINE_COLOUR = GLDG_DEFAULT_IS_OFFLINE_COLOUR
local GLDG_GOES_OFFLINE_COLOUR = GLDG_DEFAULT_GOES_OFFLINE_COLOUR
local GLDG_ALIAS_COLOUR = GLDG_DEFAULT_ALIAS_COLOUR

-- Color Picker Variables
local GLDG_colorPickerShown = false
local GLDG_colour = ""
local GLDG_setName = ""
local GLDG_colourName = ""
local GLDG_updating = false
local GLDG_current_red = 255
local GLDG_current_green = 255
local GLDG_current_blue = 255
local GLDG_current_opacity = 255

-- Color Set Lists (built dynamically)
local GLDG_set_list = nil
local GLDG_element_list = nil

-- UI Constants (need to be imported from main addon)
local GLDG_GUI = "GuildGreet"
local GLDG_COLOUR = "GuildGreetColour"

-------------------------------
-- Color System Initialization --
-------------------------------

-- Complex Color UI Functions

function GLDG.Colors:ColourPicked(flag)
	if GLDG_colorPickerShown and not GLDG_updating then
		-- get values
		local r, g, b = GLDG_ColorPickerFrame:GetColorRGB();

		-- use values
		local a = 1
		if (GLDG_colourName=="header") then
			a = GLDG_OpacitySliderFrame:GetValue()
		end
		GLDG_colour = GLDG.Colors:RGBToColour_perc(a, r, g, b)
		GLDG.Colors:UpdateCurrentColour()

		if (flag) then
			GLDG.Colors:HideColourPicker()
		else
			GLDG_updating = true
			GLDG.Colors:UpdateColoursNumbers()
			GLDG_updating = nil
		end
	end
end

function GLDG.Colors:ColourCancelEdit(self, element)
	if not GLDG_updating then
		if self then
			self:HighlightText(self:GetNumLetters())
		end
		GLDG_updating = true
		GLDG.Colors:UpdateColoursSwatch()
		GLDG_updating = nil
	end
end

function GLDG.Colors:ColourEnter(self, element, number)
	if not GLDG_updating then
		if self then
			self:HighlightText(self:GetNumLetters())
		end
		if (number >= 0 and number<=255) then
			local a,r,g,b = GLDG.Colors:ColourToRGB(GLDG_colour)

			if (element == "GuildGreetColourFrameRed") then
				GLDG_current_red = number
				GLDG_colour = GLDG.Colors:RGBToColour(a, number, g, b)
				GLDG.Colors:UpdateCurrentColour()
			elseif (element == "GuildGreetColourFrameGreen") then
				GLDG_current_green = number
				GLDG_colour = GLDG.Colors:RGBToColour(a, r, number, b)
				GLDG.Colors:UpdateCurrentColour()
			elseif (element == "GuildGreetColourFrameBlue") then
				GLDG_current_blue = number
				GLDG_colour = GLDG.Colors:RGBToColour(a, r, g, number)
				GLDG.Colors:UpdateCurrentColour()
			elseif (element == "GuildGreetColourFrameOpacity") then
				GLDG_current_opacity = number
				GLDG_colour = GLDG.Colors:RGBToColour(number, r, g, b)
				GLDG.Colors:UpdateCurrentColour()
			end
		else
			if (element == "GuildGreetColourFrameRed") then
				GuildGreetColourFrameRed:SetNumber(GLDG_current_red)
			elseif (element == "GuildGreetColourFrameGreen") then
				GuildGreetColourFrameGreen:SetNumber(GLDG_current_green)
			elseif (element == "GuildGreetColourFrameBlue") then
				GuildGreetColourFrameBlue:SetNumber(GLDG_current_blue)
			elseif (element == "GuildGreetColourFrameOpacity") then
				GuildGreetColourFrameOpacity:SetNumber(GLDG_current_opacity)
			end
		end

		GLDG_updating = true
		GLDG.Colors:UpdateColoursSwatch()
		GLDG_updating = nil
	end
end

function GLDG.Colors:ColourTab(self, element)
	if self then
		self:HighlightText(self:GetNumLetters())
	end
	if (element == "GuildGreetColourFrameRed") then
		GuildGreetColourFrameGreen:SetFocus()
		GuildGreetColourFrameGreen:HighlightText()
	elseif (element == "GuildGreetColourFrameGreen") then
		GuildGreetColourFrameBlue:SetFocus()
		GuildGreetColourFrameBlue:HighlightText()
	elseif (element == "GuildGreetColourFrameBlue") then
		if (GLDG_ColorPickerFrame.hasOpacity) then
			GuildGreetColourFrameOpacity:SetFocus()
			GuildGreetColourFrameOpacity:HighlightText()
		else
			GuildGreetColourFrameRed:SetFocus()
			GuildGreetColourFrameRed:HighlightText()
		end
	elseif (element == "GuildGreetColourFrameOpacity") then
		GuildGreetColourFrameRed:SetFocus()
		GuildGreetColourFrameRed:HighlightText()
	end
end

function GLDG.Colors:ColourUpdate(element, number)
	--GLDG_Print("Update: element ["..element.."].. - number ["..number.."]")
end

function GLDG.Colors:SetActiveColourSet(set)
	GLDG_ONLINE_COLOUR			= GLDG_DEFAULT_ONLINE_COLOUR
	GLDG_IS_OFFLINE_COLOUR		= GLDG_DEFAULT_IS_OFFLINE_COLOUR
	GLDG_GOES_OFFLINE_COLOUR	= GLDG_DEFAULT_GOES_OFFLINE_COLOUR
	GLDG_ALIAS_COLOUR			= GLDG_DEFAULT_ALIAS_COLOUR

	if (set and GLDG:GetColors()[set]) then
		GLDG_ONLINE_COLOUR			= GLDG:GetColors()[set].online
		GLDG_IS_OFFLINE_COLOUR		= GLDG:GetColors()[set].isOff
		GLDG_GOES_OFFLINE_COLOUR	= GLDG:GetColors()[set].goOff
		GLDG_ALIAS_COLOUR			= GLDG:GetColors()[set].alias
	end
end

function GLDG.Colors:ColoursShow()
	local name = GLDG_GUI.."Colour"

	-- only build these lists the first time they are used to avoid excessive garbage creation
	if not GLDG_set_list then
		GLDG_set_list = {}
		GLDG_set_list["Guild"] = "guild"
		GLDG_set_list["Friends"] = "friends"
		GLDG_set_list["Channel"] = "channel"
	end
	if not GLDG_element_list then
		GLDG_element_list = {}
		GLDG_element_list["Online"] = "online"
		GLDG_element_list["IsOffline"] = "isOff"
		GLDG_element_list["GoOffline"] = "goOff"
		GLDG_element_list["Alias"] = "alias"
		GLDG_element_list["List"] = "list"
		GLDG_element_list["Relog"] = "relog"
		GLDG_element_list["New"] = "new"
		GLDG_element_list["Level"] = "lvl"
		GLDG_element_list["Rank"] = "rank"
		GLDG_element_list["Achievment"] = "achievment"
	end

	for s in pairs(GLDG_set_list) do
		for e in pairs(GLDG_element_list) do
			local colour = GLDG:GetColors()[GLDG_set_list[s]][GLDG_element_list[e]]
			local a,r,g,b = GLDG.Colors:ColourToRGB_perc(colour)
			local texture = _G[name..s..e.."ColourTexture"]
			texture:SetColorTexture(r, g, b, a)
			local text = _G[name..s..e.."Button"]
			text:SetText(string.sub(colour, 5))
		end
	end

	local a,r,g,b = GLDG.Colors:ColourToRGB_perc(GLDG:GetColors().help)
	local texture = _G[name.."HelpColourTexture"]
	texture:SetColorTexture(r, g, b, a)
	local text = _G[name.."HelpButton"]
	text:SetText(string.sub(GLDG:GetColors().help, 5))

	a,r,g,b = GLDG.Colors:ColourToRGB_perc(GLDG:GetColors().header)
	texture = _G[name.."HeaderColourTexture"]
	texture:SetColorTexture(r, g, b, a)
	local text = _G[name.."HeaderButton"]
	text:SetText(string.sub(GLDG:GetColors().header, 3))
end

function GLDG.Colors:ColourClick(name)
	if not GLDG_colorPickerShown then
		-- which element was clicked
		GLDG_setName = ""
		if (string.find(name, GLDG_GUI.."Colour".."Guild")) then
			GLDG_setName = "guild"
		elseif (string.find(name, GLDG_GUI.."Colour".."Friends")) then
			GLDG_setName = "friends"
		elseif (string.find(name, GLDG_GUI.."Colour".."Channel")) then
			GLDG_setName = "channel"
		end

		GLDG_colourName = ""
		if (string.find(name, "Online")) then
			GLDG_colourName = "online"
		elseif (string.find(name, "IsOffline")) then
			GLDG_colourName = "isOff"
		elseif (string.find(name, "GoOffline")) then
			GLDG_colourName = "goOff"
		elseif (string.find(name, "Alias")) then
			GLDG_colourName = "alias"

		elseif (string.find(name, "List")) then
			GLDG_colourName = "list"
		elseif (string.find(name, "New")) then
			GLDG_colourName = "new"
		elseif (string.find(name, "Level")) then
			GLDG_colourName = "lvl"
		elseif (string.find(name, "Rank")) then
			GLDG_colourName = "rank"
		elseif (string.find(name, "Relog")) then
			GLDG_colourName = "relog"
		elseif (string.find(name, "Achievment")) then
			GLDG_colourName = "achievment"

		elseif (string.find(name, "Help")) then
			GLDG_colourName = "help"
		elseif (string.find(name, "Header")) then
			GLDG_colourName = "header"
		end

		if (string.find(name, "Default")) then
			GLDG.Colors:ColourRestoreDefaults()
		else
			if ((GLDG_setName~="" or GLDG_colourName=="help" or GLDG_colourName=="header") and (GLDG_colourName ~="")) then
				-- get current colour
				if (GLDG_colourName=="help") then
					GLDG_colour = GLDG:GetColors().help
				elseif (GLDG_colourName=="header") then
					GLDG_colour = GLDG:GetColors().header
				else
					GLDG_colour = GLDG:GetColors()[GLDG_setName][GLDG_colourName]
				end

				-- open color picker
				GLDG.Colors:ShowColourPicker()
			else
				GLDG:Print("--- unknown button ["..Ambiguate(name, "guild").."] pressed ---")
			end
		end
	else
		GLDG:PrintHelp(L["Cannot set default colours while colour picker is open"])
	end
end

function GLDG.Colors:UpdateCurrentColour()
	--GLDG_Print("Colour is "..GLDG_colour..string.sub(GLDG_colour, 3).."|r")

	if (not GLDG_setName) or (not GLDG_colourName) then return end

	if ((GLDG_setName~="" or GLDG_colourName=="help" or GLDG_colourName=="header") and (GLDG_colourName ~="")) then
		-- set value
		if (GLDG_colourName=="help") then
			GLDG:GetColors().help = GLDG_colour
		elseif (GLDG_colourName=="header") then
			GLDG:GetColors().header = GLDG_colour
		else
			GLDG:GetColors()[GLDG_setName][GLDG_colourName] = GLDG_colour
		end

		-- update colour cache
		GLDG.Colors:SetActiveColourSet("guild")
	end

	GLDG.Colors:ColoursShow()
end

function GLDG.Colors:ColourRestoreDefaults()
	if not GLDG_colorPickerShown then
		GLDG:GetColors().help = GLDG_DEFAULT_HELP_COLOUR
		GLDG:GetColors().header = GLDG_DEFAULT_HEADER_COLOUR

		GLDG:GetColors().guild.online = GLDG_DEFAULT_ONLINE_COLOUR
		GLDG:GetColors().guild.isOff = GLDG_DEFAULT_IS_OFFLINE_COLOUR
		GLDG:GetColors().guild.goOff = GLDG_DEFAULT_GOES_OFFLINE_COLOUR
		GLDG:GetColors().guild.alias = GLDG_DEFAULT_ALIAS_COLOUR
		GLDG:GetColors().guild.list = GLDG_DEFAULT_LIST_COLOUR
		GLDG:GetColors().guild.new = GLDG_DEFAULT_NEW_COLOUR
		GLDG:GetColors().guild.lvl = GLDG_DEFAULT_LVL_COLOUR
		GLDG:GetColors().guild.rank = GLDG_DEFAULT_RANK_COLOUR
		GLDG:GetColors().guild.relog = GLDG_DEFAULT_RELOG_COLOUR
		GLDG:GetColors().guild.achievment = GLDG_DEFAULT_ACHIEVMENT_COLOUR

		GLDG:GetColors().friends.online = GLDG_DEFAULT_ONLINE_COLOUR
		GLDG:GetColors().friends.isOff = GLDG_DEFAULT_IS_OFFLINE_COLOUR
		GLDG:GetColors().friends.goOff = GLDG_DEFAULT_GOES_OFFLINE_COLOUR
		GLDG:GetColors().friends.alias = GLDG_DEFAULT_ALIAS_COLOUR
		GLDG:GetColors().friends.list = GLDG_DEFAULT_LIST_COLOUR
		GLDG:GetColors().friends.new = GLDG_DEFAULT_NEW_COLOUR
		GLDG:GetColors().friends.lvl = GLDG_DEFAULT_LVL_COLOUR
		GLDG:GetColors().friends.rank = GLDG_DEFAULT_RANK_COLOUR
		GLDG:GetColors().friends.relog = GLDG_DEFAULT_RELOG_COLOUR
		GLDG:GetColors().friends.achievment = GLDG_DEFAULT_ACHIEVMENT_COLOUR

		GLDG:GetColors().channel.online = GLDG_DEFAULT_ONLINE_COLOUR
		GLDG:GetColors().channel.isOff = GLDG_DEFAULT_IS_OFFLINE_COLOUR
		GLDG:GetColors().channel.goOff = GLDG_DEFAULT_GOES_OFFLINE_COLOUR
		GLDG:GetColors().channel.alias = GLDG_DEFAULT_ALIAS_COLOUR
		GLDG:GetColors().channel.list = GLDG_DEFAULT_LIST_COLOUR
		GLDG:GetColors().channel.new = GLDG_DEFAULT_NEW_COLOUR
		GLDG:GetColors().channel.lvl = GLDG_DEFAULT_LVL_COLOUR
		GLDG:GetColors().channel.rank = GLDG_DEFAULT_RANK_COLOUR
		GLDG:GetColors().channel.relog = GLDG_DEFAULT_RELOG_COLOUR
		GLDG:GetColors().channel.achievment = GLDG_DEFAULT_ACHIEVMENT_COLOUR

		-- update colour cache
		GLDG.Colors:SetActiveColourSet("guild")

		GLDG.Colors:ColoursShow()
	else
		GLDG:PrintHelp(L["Cannot set default colours while colour picker is open"])
	end
end

function GLDG.Colors:Initialize()
	-- Initialize color data structure if not exists
	if not GLDG_Data.colours then
		GLDG_Data.colours = {}
	end
	
	-- Initialize default color schemes
	self:InitializeColorSchemes()
	
	-- Set active color set to guild by default
	self:SetActiveColourSet("guild")
	
	print("GuildGreet: Color system initialized")
end

-------------------------------
-- Initialize Color Schemes --
-------------------------------

function GLDG.Colors:InitializeColorSchemes()
	-- Ensure GLDG_Data exists before accessing colours
	if not GLDG_Data then
		GLDG:Print("Warning: GLDG_Data not yet initialized, skipping color scheme setup")
		return
	end
	
	local colors = GLDG_Data.colours
	
	-- Initialize help and header colors
	if not colors.help then colors.help = GLDG_DEFAULT_HELP_COLOUR end
	if not colors.header then colors.header = GLDG_DEFAULT_HEADER_COLOUR end
	
	-- Initialize guild color scheme
	if not colors.guild then colors.guild = {} end
	local guild = colors.guild
	if not guild.online then guild.online = GLDG_DEFAULT_ONLINE_COLOUR end
	if not guild.isOff then guild.isOff = GLDG_DEFAULT_IS_OFFLINE_COLOUR end
	if not guild.goOff then guild.goOff = GLDG_DEFAULT_GOES_OFFLINE_COLOUR end
	if not guild.alias then guild.alias = GLDG_DEFAULT_ALIAS_COLOUR end
	if not guild.list then guild.list = GLDG_DEFAULT_LIST_COLOUR end
	if not guild.new then guild.new = GLDG_DEFAULT_NEW_COLOUR end
	if not guild.lvl then guild.lvl = GLDG_DEFAULT_LVL_COLOUR end
	if not guild.rank then guild.rank = GLDG_DEFAULT_RANK_COLOUR end
	if not guild.relog then guild.relog = GLDG_DEFAULT_RELOG_COLOUR end
	if not guild.achievment then guild.achievment = GLDG_DEFAULT_ACHIEVMENT_COLOUR end
	
	-- Initialize friends color scheme
	if not colors.friends then colors.friends = {} end
	local friends = colors.friends
	if not friends.online then friends.online = GLDG_DEFAULT_ONLINE_COLOUR end
	if not friends.isOff then friends.isOff = GLDG_DEFAULT_IS_OFFLINE_COLOUR end
	if not friends.goOff then friends.goOff = GLDG_DEFAULT_GOES_OFFLINE_COLOUR end
	if not friends.alias then friends.alias = GLDG_DEFAULT_ALIAS_COLOUR end
	if not friends.list then friends.list = GLDG_DEFAULT_LIST_COLOUR end
	if not friends.new then friends.new = GLDG_DEFAULT_NEW_COLOUR end
	if not friends.lvl then friends.lvl = GLDG_DEFAULT_LVL_COLOUR end
	if not friends.rank then friends.rank = GLDG_DEFAULT_RANK_COLOUR end
	if not friends.relog then friends.relog = GLDG_DEFAULT_RELOG_COLOUR end
	if not friends.achievment then friends.achievment = GLDG_DEFAULT_ACHIEVMENT_COLOUR end
	
	-- Initialize channel color scheme
	if not colors.channel then colors.channel = {} end
	local channel = colors.channel
	if not channel.online then channel.online = GLDG_DEFAULT_ONLINE_COLOUR end
	if not channel.isOff then channel.isOff = GLDG_DEFAULT_IS_OFFLINE_COLOUR end
	if not channel.goOff then channel.goOff = GLDG_DEFAULT_GOES_OFFLINE_COLOUR end
	if not channel.alias then channel.alias = GLDG_DEFAULT_ALIAS_COLOUR end
	if not channel.list then channel.list = GLDG_DEFAULT_LIST_COLOUR end
	if not channel.new then channel.new = GLDG_DEFAULT_NEW_COLOUR end
	if not channel.lvl then channel.lvl = GLDG_DEFAULT_LVL_COLOUR end
	if not channel.rank then channel.rank = GLDG_DEFAULT_RANK_COLOUR end
	if not channel.relog then channel.relog = GLDG_DEFAULT_RELOG_COLOUR end
	if not channel.achievment then channel.achievment = GLDG_DEFAULT_ACHIEVMENT_COLOUR end
end

-------------------------------
-- Get Colors --
-------------------------------

function GLDG.Colors:GetColors()
	-- Return default colors if GLDG_Data is not ready yet
	if not GLDG_Data then
		return {
		help = GLDG_DEFAULT_HELP_COLOUR or "|cFFFFFFFF",
			header = GLDG_DEFAULT_HEADER_COLOUR or "|cFFFFFFFF"
		}
	end
	
	-- Initialize colour structure if needed
	if not GLDG_Data.colours then
		self:InitializeColorSchemes()
	end
	
	return GLDG_Data.colours
end

-------------------------------
-- Set Active Color Set --
-------------------------------

function GLDG.Colors:SetActiveColourSet(set)
	-- Reset to defaults first
	GLDG_ONLINE_COLOUR = GLDG_DEFAULT_ONLINE_COLOUR
	GLDG_IS_OFFLINE_COLOUR = GLDG_DEFAULT_IS_OFFLINE_COLOUR
	GLDG_GOES_OFFLINE_COLOUR = GLDG_DEFAULT_GOES_OFFLINE_COLOUR
	GLDG_ALIAS_COLOUR = GLDG_DEFAULT_ALIAS_COLOUR

	-- Apply set-specific colors if they exist
	local colors = self:GetColors()
	if set and colors[set] then
		GLDG_ONLINE_COLOUR = colors[set].online or GLDG_DEFAULT_ONLINE_COLOUR
		GLDG_IS_OFFLINE_COLOUR = colors[set].isOff or GLDG_DEFAULT_IS_OFFLINE_COLOUR
		GLDG_GOES_OFFLINE_COLOUR = colors[set].goOff or GLDG_DEFAULT_GOES_OFFLINE_COLOUR
		GLDG_ALIAS_COLOUR = colors[set].alias or GLDG_DEFAULT_ALIAS_COLOUR
	end
end

-------------------------------
-- RGB Conversion Functions --
-------------------------------

function GLDG.Colors:ColourToRGB(colour)
	if not colour then return 255, 255, 255, 255 end
	
	-- Remove |c prefix and |r suffix
	local hex = string.gsub(colour, "|c[fF][fF]", "")
	hex = string.gsub(hex, "|r", "")
	
	if string.len(hex) == 6 then
		local r = tonumber(string.sub(hex, 1, 2), 16) or 255
		local g = tonumber(string.sub(hex, 3, 4), 16) or 255
		local b = tonumber(string.sub(hex, 5, 6), 16) or 255
		return 255, r, g, b
	elseif string.len(hex) == 8 then
		local a = tonumber(string.sub(hex, 1, 2), 16) or 255
		local r = tonumber(string.sub(hex, 3, 4), 16) or 255
		local g = tonumber(string.sub(hex, 5, 6), 16) or 255
		local b = tonumber(string.sub(hex, 7, 8), 16) or 255
		return a, r, g, b
	end
	
	return 255, 255, 255, 255
end

function GLDG.Colors:ColourToRGB_perc(colour)
	local a, r, g, b = self:ColourToRGB(colour)
	return a/255, r/255, g/255, b/255
end

function GLDG.Colors:RGBToColour(a, r, g, b)
	a = math.floor(a or 255)
	r = math.floor(r or 255)
	g = math.floor(g or 255)
	b = math.floor(b or 255)
	
	-- Clamp values
	a = math.max(0, math.min(255, a))
	r = math.max(0, math.min(255, r))
	g = math.max(0, math.min(255, g))
	b = math.max(0, math.min(255, b))
	
	return string.format("|cff%02x%02x%02x", r, g, b)
end

-------------------------------
-- Color Picker Interface --
-------------------------------

function GLDG.Colors:ShowColourPicker()
	GLDG_colorPickerShown = true
	
	-- Set up color picker frame
	local info = {}
	info.r, info.g, info.b = self:ColourToRGB_perc(GLDG_colour)
	info.opacity = 1.0
	info.hasOpacity = false -- Disable opacity for now
	info.opacityFunc = function() self:OpacityChanged() end
	info.swatchFunc = function() self:ColorChanged() end
	info.cancelFunc = function() self:ColorCancelled() end
	
	-- Open the color picker
	OpenColorPicker(info)
	
	-- Update the color numbers display
	self:UpdateColoursNumbers()
end

function GLDG.Colors:ColorChanged()
	if GLDG_updating then return end
	
	local r, g, b = ColorPickerFrame:GetColorRGB()
	local a = ColorPickerFrame.opacity or 1.0
	
	GLDG_colour = self:RGBToColour(a * 255, r * 255, g * 255, b * 255)
	self:UpdateCurrentColour()
end

function GLDG.Colors:OpacityChanged()
	if GLDG_updating then return end
	
	local a = OpacitySliderFrame:GetValue() or 1.0
	ColorPickerFrame.opacity = a
	
	local r, g, b = ColorPickerFrame:GetColorRGB()
	GLDG_colour = self:RGBToColour(a * 255, r * 255, g * 255, b * 255)
	self:UpdateCurrentColour()
end

function GLDG.Colors:ColorCancelled()
	GLDG_colorPickerShown = false
	-- Restore original color here if needed
end

-------------------------------
-- Color Interface Updates --
-------------------------------

function GLDG.Colors:ColoursShow()
	local name = GLDG_GUI.."Colour"

	-- Build lists only the first time they are used
	if not GLDG_set_list then
		GLDG_set_list = {}
		GLDG_set_list["Guild"] = "guild"
		GLDG_set_list["Friends"] = "friends"
		GLDG_set_list["Channel"] = "channel"
	end
	if not GLDG_element_list then
		GLDG_element_list = {}
		GLDG_element_list["Online"] = "online"
		GLDG_element_list["IsOffline"] = "isOff"
		GLDG_element_list["GoOffline"] = "goOff"
		GLDG_element_list["Alias"] = "alias"
		GLDG_element_list["List"] = "list"
		GLDG_element_list["Relog"] = "relog"
		GLDG_element_list["New"] = "new"
		GLDG_element_list["Level"] = "lvl"
		GLDG_element_list["Rank"] = "rank"
		GLDG_element_list["Achievment"] = "achievment"
	end

	local colors = self:GetColors()
	
	-- Update color swatches for each set and element
	for s in pairs(GLDG_set_list) do
		for e in pairs(GLDG_element_list) do
			local colour = colors[GLDG_set_list[s]][GLDG_element_list[e]]
			local a, r, g, b = self:ColourToRGB_perc(colour)
			
			local texture = _G[name..s..e.."ColourTexture"]
			if texture then
				texture:SetColorTexture(r, g, b, a)
			end
			
			local text = _G[name..s..e.."Button"]
			if text then
				text:SetText(string.sub(colour, 5))
			end
		end
	end

	-- Update help and header colors
	local a, r, g, b = self:ColourToRGB_perc(colors.help)
	local texture = _G[name.."HelpColourTexture"]
	if texture then
		texture:SetColorTexture(r, g, b, a)
	end
	local text = _G[name.."HelpButton"]
	if text then
		text:SetText(string.sub(colors.help, 5))
	end

	a, r, g, b = self:ColourToRGB_perc(colors.header)
	texture = _G[name.."HeaderColourTexture"]
	if texture then
		texture:SetColorTexture(r, g, b, a)
	end
	text = _G[name.."HeaderButton"]
	if text then
		text:SetText(string.sub(colors.header, 3))
	end
end

function GLDG.Colors:UpdateColoursNumbers()
	local a, r, g, b = self:ColourToRGB(GLDG_colour)

	GLDG_current_red = r
	GLDG_current_green = g
	GLDG_current_blue = b
	GLDG_current_opacity = a

	local redFrame = _G["GuildGreetColourFrameRed"]
	local greenFrame = _G["GuildGreetColourFrameGreen"]
	local blueFrame = _G["GuildGreetColourFrameBlue"]
	local opacityFrame = _G["GuildGreetColourFrameOpacity"]
	
	if redFrame and redFrame.SetNumber then redFrame:SetNumber(r) end
	if greenFrame and greenFrame.SetNumber then greenFrame:SetNumber(g) end
	if blueFrame and blueFrame.SetNumber then blueFrame:SetNumber(b) end
	if opacityFrame and opacityFrame.SetNumber then opacityFrame:SetNumber(a) end
end

function GLDG.Colors:UpdateColoursSwatch()
	-- Update the color swatch display
	local a, r, g, b = self:ColourToRGB_perc(GLDG_colour)
	
	-- Set ColorPickerFrame color if it's open
	if ColorPickerFrame:IsShown() then
		ColorPickerFrame:SetColorRGB(r, g, b)
		if ColorPickerFrame.opacity then
			ColorPickerFrame.opacity = a
		end
	end
end

-------------------------------
-- Color Click Handlers --
-------------------------------

function GLDG.Colors:ColourClick(name)
	if GLDG_colorPickerShown then
		GLDG:PrintHelp(L["Cannot set default colours while colour picker is open"])
		return
	end

	-- Parse which element was clicked
	GLDG_setName = ""
	if string.find(name, GLDG_GUI.."Colour".."Guild") then
		GLDG_setName = "guild"
	elseif string.find(name, GLDG_GUI.."Colour".."Friends") then
		GLDG_setName = "friends"
	elseif string.find(name, GLDG_GUI.."Colour".."Channel") then
		GLDG_setName = "channel"
	end

	GLDG_colourName = ""
	if string.find(name, "Online") then
		GLDG_colourName = "online"
	elseif string.find(name, "IsOffline") then
		GLDG_colourName = "isOff"
	elseif string.find(name, "GoOffline") then
		GLDG_colourName = "goOff"
	elseif string.find(name, "Alias") then
		GLDG_colourName = "alias"
	elseif string.find(name, "List") then
		GLDG_colourName = "list"
	elseif string.find(name, "New") then
		GLDG_colourName = "new"
	elseif string.find(name, "Level") then
		GLDG_colourName = "lvl"
	elseif string.find(name, "Rank") then
		GLDG_colourName = "rank"
	elseif string.find(name, "Relog") then
		GLDG_colourName = "relog"
	elseif string.find(name, "Achievment") then
		GLDG_colourName = "achievment"
	elseif string.find(name, "Help") then
		GLDG_colourName = "help"
	elseif string.find(name, "Header") then
		GLDG_colourName = "header"
	end

	-- Handle default button
	if string.find(name, "Default") then
		self:ColourRestoreDefaults()
	else
		if (GLDG_setName ~= "" or GLDG_colourName == "help" or GLDG_colourName == "header") and (GLDG_colourName ~= "") then
			-- Get current colour
			local colors = self:GetColors()
			if GLDG_colourName == "help" then
				GLDG_colour = colors.help
			elseif GLDG_colourName == "header" then
				GLDG_colour = colors.header
			else
				GLDG_colour = colors[GLDG_setName][GLDG_colourName]
			end

			-- Open color picker
			self:ShowColourPicker()
		else
			GLDG:Print("--- unknown button ["..Ambiguate(name, "guild").."] pressed ---")
		end
	end
end

function GLDG.Colors:UpdateCurrentColour()
	if not GLDG_setName or not GLDG_colourName then return end

	local colors = self:GetColors()
	
	if (GLDG_setName ~= "" or GLDG_colourName == "help" or GLDG_colourName == "header") and (GLDG_colourName ~= "") then
		-- Set value
		if GLDG_colourName == "help" then
			colors.help = GLDG_colour
		elseif GLDG_colourName == "header" then
			colors.header = GLDG_colour
		else
			colors[GLDG_setName][GLDG_colourName] = GLDG_colour
		end

		-- Update colour cache
		self:SetActiveColourSet("guild")
	end

	self:ColoursShow()
end

-------------------------------
-- Restore Default Colors --
-------------------------------

function GLDG.Colors:ColourRestoreDefaults()
	if GLDG_colorPickerShown then
		GLDG:PrintHelp(L["Cannot set default colours while colour picker is open"])
		return
	end

	local colors = self:GetColors()
	
	-- Restore default colors
	colors.help = GLDG_DEFAULT_HELP_COLOUR
	colors.header = GLDG_DEFAULT_HEADER_COLOUR

	-- Guild colors
	colors.guild.online = GLDG_DEFAULT_ONLINE_COLOUR
	colors.guild.isOff = GLDG_DEFAULT_IS_OFFLINE_COLOUR
	colors.guild.goOff = GLDG_DEFAULT_GOES_OFFLINE_COLOUR
	colors.guild.alias = GLDG_DEFAULT_ALIAS_COLOUR
	colors.guild.list = GLDG_DEFAULT_LIST_COLOUR
	colors.guild.new = GLDG_DEFAULT_NEW_COLOUR
	colors.guild.lvl = GLDG_DEFAULT_LVL_COLOUR
	colors.guild.rank = GLDG_DEFAULT_RANK_COLOUR
	colors.guild.relog = GLDG_DEFAULT_RELOG_COLOUR
	colors.guild.achievment = GLDG_DEFAULT_ACHIEVMENT_COLOUR

	-- Friends colors
	colors.friends.online = GLDG_DEFAULT_ONLINE_COLOUR
	colors.friends.isOff = GLDG_DEFAULT_IS_OFFLINE_COLOUR
	colors.friends.goOff = GLDG_DEFAULT_GOES_OFFLINE_COLOUR
	colors.friends.alias = GLDG_DEFAULT_ALIAS_COLOUR
	colors.friends.list = GLDG_DEFAULT_LIST_COLOUR
	colors.friends.new = GLDG_DEFAULT_NEW_COLOUR
	colors.friends.lvl = GLDG_DEFAULT_LVL_COLOUR
	colors.friends.rank = GLDG_DEFAULT_RANK_COLOUR
	colors.friends.relog = GLDG_DEFAULT_RELOG_COLOUR
	colors.friends.achievment = GLDG_DEFAULT_ACHIEVMENT_COLOUR

	-- Channel colors
	colors.channel.online = GLDG_DEFAULT_ONLINE_COLOUR
	colors.channel.isOff = GLDG_DEFAULT_IS_OFFLINE_COLOUR
	colors.channel.goOff = GLDG_DEFAULT_GOES_OFFLINE_COLOUR
	colors.channel.alias = GLDG_DEFAULT_ALIAS_COLOUR
	colors.channel.list = GLDG_DEFAULT_LIST_COLOUR
	colors.channel.new = GLDG_DEFAULT_NEW_COLOUR
	colors.channel.lvl = GLDG_DEFAULT_LVL_COLOUR
	colors.channel.rank = GLDG_DEFAULT_RANK_COLOUR
	colors.channel.relog = GLDG_DEFAULT_RELOG_COLOUR
	colors.channel.achievment = GLDG_DEFAULT_ACHIEVMENT_COLOUR

	-- Update colour cache
	self:SetActiveColourSet("guild")
	self:ColoursShow()
	
	GLDG:PrintHelp(L["Default colors restored"])
end

-------------------------------
-- Color Input Handlers --
-------------------------------

function GLDG.Colors:ColourCancelEdit(frame, element)
	if GLDG_updating then return end
	
	if frame then
		frame:HighlightText(frame:GetNumLetters())
	end
	GLDG_updating = true
	self:UpdateColoursSwatch()
	GLDG_updating = nil
end

function GLDG.Colors:ColourEnter(frame, element, number)
	if GLDG_updating then return end
	
	if frame then
		frame:HighlightText(frame:GetNumLetters())
	end
	
	if number >= 0 and number <= 255 then
		local a, r, g, b = self:ColourToRGB(GLDG_colour)

		if element == "GuildGreetColourFrameRed" then
			GLDG_current_red = number
			GLDG_colour = self:RGBToColour(a, number, g, b)
			self:UpdateCurrentColour()
		elseif element == "GuildGreetColourFrameGreen" then
			GLDG_current_green = number
			GLDG_colour = self:RGBToColour(a, r, number, b)
			self:UpdateCurrentColour()
		elseif element == "GuildGreetColourFrameBlue" then
			GLDG_current_blue = number
			GLDG_colour = self:RGBToColour(a, r, g, number)
			self:UpdateCurrentColour()
		elseif element == "GuildGreetColourFrameOpacity" then
			GLDG_current_opacity = number
			GLDG_colour = self:RGBToColour(number, r, g, b)
			self:UpdateCurrentColour()
		end
	else
		-- Reset to current value if invalid
		local redFrame = _G["GuildGreetColourFrameRed"]
		local greenFrame = _G["GuildGreetColourFrameGreen"]
		local blueFrame = _G["GuildGreetColourFrameBlue"]
		local opacityFrame = _G["GuildGreetColourFrameOpacity"]
		
		if element == "GuildGreetColourFrameRed" and redFrame and redFrame.SetNumber then
			redFrame:SetNumber(GLDG_current_red)
		elseif element == "GuildGreetColourFrameGreen" and greenFrame and greenFrame.SetNumber then
			greenFrame:SetNumber(GLDG_current_green)
		elseif element == "GuildGreetColourFrameBlue" and blueFrame and blueFrame.SetNumber then
			blueFrame:SetNumber(GLDG_current_blue)
		elseif element == "GuildGreetColourFrameOpacity" and opacityFrame and opacityFrame.SetNumber then
			opacityFrame:SetNumber(GLDG_current_opacity)
		end
	end

	GLDG_updating = true
	self:UpdateColoursSwatch()
	GLDG_updating = nil
end

function GLDG.Colors:ColourTab(frame, element)
	if frame then
		frame:HighlightText(frame:GetNumLetters())
	end
	
	local redFrame = _G["GuildGreetColourFrameRed"]
	local greenFrame = _G["GuildGreetColourFrameGreen"]
	local blueFrame = _G["GuildGreetColourFrameBlue"]
	local opacityFrame = _G["GuildGreetColourFrameOpacity"]
	
	if element == "GuildGreetColourFrameRed" and greenFrame then
		greenFrame:SetFocus()
		greenFrame:HighlightText()
	elseif element == "GuildGreetColourFrameGreen" and blueFrame then
		blueFrame:SetFocus()
		blueFrame:HighlightText()
	elseif element == "GuildGreetColourFrameBlue" then
		if opacityFrame and GLDG_ColorPickerFrame and GLDG_ColorPickerFrame.hasOpacity then
			opacityFrame:SetFocus()
			opacityFrame:HighlightText()
		elseif redFrame then
			redFrame:SetFocus()
			redFrame:HighlightText()
		end
	elseif element == "GuildGreetColourFrameOpacity" and redFrame then
		redFrame:SetFocus()
		redFrame:HighlightText()
	end
end

-- Global functions for backwards compatibility
function GLDG_SetActiveColourSet(set)
	GLDG.Colors:SetActiveColourSet(set)
end

function GLDG_ColoursShow()
	GLDG.Colors:ColoursShow()
end

function GLDG_ColourClick(name)
	GLDG.Colors:ColourClick(name)
end

function GLDG_UpdateCurrentColour()
	GLDG.Colors:UpdateCurrentColour()
end

function GLDG_ColourRestoreDefaults()
	GLDG.Colors:ColourRestoreDefaults()
end

function GLDG_ColourToRGB(colour)
	return GLDG.Colors:ColourToRGB(colour)
end

function GLDG_ColourToRGB_perc(colour)
	return GLDG.Colors:ColourToRGB_perc(colour)
end

function GLDG_RGBToColour(a, r, g, b)
	return GLDG.Colors:RGBToColour(a, r, g, b)
end

function GLDG_UpdateColoursNumbers()
	GLDG.Colors:UpdateColoursNumbers()
end

function GLDG_UpdateColoursSwatch()
	GLDG.Colors:UpdateColoursSwatch()
end

function GLDG_ColourCancelEdit(frame, element)
	GLDG.Colors:ColourCancelEdit(frame, element)
end

function GLDG_ColourEnter(frame, element, number)
	GLDG.Colors:ColourEnter(frame, element, number)
end

function GLDG_ColourTab(frame, element)
	GLDG.Colors:ColourTab(frame, element)
end