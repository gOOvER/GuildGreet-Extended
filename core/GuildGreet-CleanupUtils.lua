--[[
GuildGreet-CleanupUtils.lua
Cleanup utility functions for data management

This library provides functionality for:
- Orphan character cleanup
- Guildless character cleanup  
- Guildless character display
- Data validation and cleanup operations
]]

-- Initialize namespace
local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet", true) or GLDG or {}
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", true)

local function Ambiguate(name)
	if type(name) ~= "string" then return tostring(name or "") end
	return string.match(name, "^([^%-]+)") or name
end

if not GLDG.CleanupUtils then GLDG.CleanupUtils = {} end

local CleanupUtils = GLDG.CleanupUtils

local function ResetLegacyCleanupButtons()
	if not GLDG_GUI then return end
	if _G[GLDG_GUI.."CleanupSubEntries"] then _G[GLDG_GUI.."CleanupSubEntries"]:Hide() end
	if _G[GLDG_GUI.."CleanupGuild"] then _G[GLDG_GUI.."CleanupGuild"]:Enable() end
	if _G[GLDG_GUI.."CleanupFriends"] then _G[GLDG_GUI.."CleanupFriends"]:Enable() end
	if _G[GLDG_GUI.."CleanupChannel"] then _G[GLDG_GUI.."CleanupChannel"]:Enable() end
end

-----------------------
-- Orphan Cleanup   --  
-----------------------

function CleanupUtils:OrphanCleanup()
	GLDG.UIHelpers:Print(L["Orphan cleanup"])
	for p in pairs(GLDG_DataChar) do
		if (not GLDG_DataChar[p].main and
		    not GLDG_DataChar[p].alt and
		    not GLDG_DataChar[p].alias and
		    (not GLDG_DataChar[p].channels or GLDG.Utils:TableSize(GLDG_DataChar[p].channels)==0) and
		    (not GLDG_DataChar[p].friends or GLDG.Utils:TableSize(GLDG_DataChar[p].friends)==0)) then
			GLDG_DataChar[p] = nil
			GLDG.UIHelpers:Print(L["Removed orphan"].." ["..Ambiguate(p, "guild").."] "..(L[""] or ""))
		end
	end

	ResetLegacyCleanupButtons()
end

--------------------------
-- Guildless Cleanup   --
--------------------------

function CleanupUtils:GuildlessCleanup()
	local guildless_count = 0
	GLDG.UIHelpers:Print(L["Guildless cleanup"])
	for p in pairs(GLDG_DataChar) do
		if (not GLDG_DataChar[p].guild) then
			guildless_count = guildless_count + 1
			GLDG.UIHelpers:Print(L["Removed guildless"].." ["..Ambiguate(p, "guild").."] "..(L[""] or ""))
			-- Delete the character
			GLDG_DataChar[p] = nil
		end
	end
	GLDG_Print("Amount of removed guildless players: "..guildless_count)

	-- Check for channels/friends 
	GLDG_CheckChannel()
	C_FriendList.ShowFriends()

	GLDG_CleanupList = nil
	GLDG_CleanupMode = nil
end

--------------------------
-- Guildless Display   --
--------------------------

function CleanupUtils:GuildlessDisplay()
	local guildless_count = 0
	local haveguild_count = 0
	local total_count = 0
	GLDG.UIHelpers:Print(L["Guildless display"])
	for p in pairs(GLDG_DataChar) do
		if (not GLDG_DataChar[p].guild) then
			guildless_count = guildless_count + 1
			GLDG.UIHelpers:Print(L["Can remove guildless"].." ["..Ambiguate(p, "guild").."] "..(L[""] or ""))
		else
			haveguild_count = haveguild_count + 1
		end
		total_count = total_count + 1
	end
	GLDG_Print("Amount of guildless players: "..guildless_count)
	GLDG_Print("Amount of players with guild: "..haveguild_count)
	GLDG_Print("Total amount of players: "..total_count)
	ResetLegacyCleanupButtons()
end