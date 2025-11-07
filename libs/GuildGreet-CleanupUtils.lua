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
if not GLDG then GLDG = {} end
if not GLDG.CleanupUtils then GLDG.CleanupUtils = {} end

local CleanupUtils = GLDG.CleanupUtils

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
			GLDG.UIHelpers:Print(L["Removed orphan"].." ["..Ambiguate(p, "guild").."] "..L[""])
		end
	end

	-- Hide the subframe window
	_G[GLDG_GUI.."CleanupSubEntries"]:Hide()

	-- re-enable buttons
	_G[GLDG_GUI.."CleanupGuild"]:Enable()
	_G[GLDG_GUI.."CleanupFriends"]:Enable()
	_G[GLDG_GUI.."CleanupChannel"]:Enable()
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
			GLDG.UIHelpers:Print(L["Removed guildless"].." ["..Ambiguate(p, "guild").."] "..L[""])
			-- Delete the character
			GLDG_DataChar[p] = nil
		end
	end
	GLDG_Print("Amount of removed guildless players: "..guildless_count)

	-- Check for channels/friends 
	GLDG_CheckChannel()
	-- H.Sch. - ReglohPri - ShowFriends() is deprecated changed to C_FriendList.ShowFriends()
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
			GLDG.UIHelpers:Print(L["Can remove guildless"].." ["..Ambiguate(p, "guild").."] "..L[""])
		else
			haveguild_count = haveguild_count + 1
		end
		total_count = total_count + 1
	end
	GLDG_Print("Amount of guildless players: "..guildless_count)
	GLDG_Print("Amount of players with guild: "..haveguild_count)
	GLDG_Print("Total amount of players: "..total_count)
	-- Hide the subframe window
	_G[GLDG_GUI.."CleanupSubEntries"]:Hide()

	-- re-enable buttons
	_G[GLDG_GUI.."CleanupGuild"]:Enable()
	_G[GLDG_GUI.."CleanupFriends"]:Enable()
	_G[GLDG_GUI.."CleanupChannel"]:Enable()
end