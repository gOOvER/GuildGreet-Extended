--[[--------------------------------------------------------
-- GuildGreet Player Management Library
-- Handles player tracking, roster management, and character relationships
------------------------------------------------------------]]

-- Get or create the GuildGreet addon instance
local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet", true) or LibStub("AceAddon-3.0"):NewAddon("GuildGreet", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", false)

-- Player Management Library Namespace
GLDG.PlayerManager = {}

-- Import required global variables for compatibility
local GLDG_Data, GLDG_DataChar, GLDG_DataGreet
local GLDG_unique_GuildName, GLDG_Player, GLDG_Realm, GLDG_GuildName, GLDG_GuildLeader
local GLDG_Online, GLDG_Offline, GLDG_Queue
local GLDG_SortedList, GLDG_NumMain, GLDG_NumAlts
local GLDG_RosterImportRunning, GLDG_ReadNotes

-------------------------------
-- Roster Import Functions --
-------------------------------

function GLDG.PlayerManager:RosterImport()
	if (not IsInGuild()) then
		return
	end

	GLDG_RosterImportRunning = 1

	-- Build new roster
	local newRoster = {}
	local numTotal = GetNumGuildMembers()
	
	for index = 1, numTotal do
		local name, rank, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile = GetGuildRosterInfo(index)
		
		if (name) then
			local shortName, realm = string.split("-", name)
			if not realm then 
				name = shortName.."-"..string.gsub(GLDG.Realm, " ", "") 
			end

			-- Store player information
			newRoster[name] = {
				lvl = level or 1,
				rank = rankIndex or 10,
				rankname = rank or L["Guild Member"],
				zone = zone or L["Unknown"],
				pNote = publicNote or "",
				oNote = officerNote or "",
				class = class or "WARRIOR",
				classDisplayName = classDisplayName or L["Unknown"],
				achievementPoints = achievementPoints or 0,
				guild = GLDG_unique_GuildName,
				online = isOnline or false,
				status = status or 0,
				isMobile = isMobile or false
			}

			-- Mark own character
			if (name == GLDG.Player.."-"..string.gsub(GLDG.Realm, " ", "")) then
				newRoster[name].own = true
			end

			-- Process notes for main/alt relationships
			self:ProcessPlayerNotes(name, newRoster[name])
		end
	end

	-- Update main character data with new roster
	self:UpdateCharacterData(newRoster)
	
	-- Process main/alt relationships
	self:ProcessMainAltRelationships()
	
	-- Update guild information
	self:UpdateGuildInfo()

	GLDG_RosterImportRunning = 0
	
	GLDG:Print(GLDG.Database:GetColors().help..GLDG_NAME..":|r "..L["Roster import completed"])
end

-------------------------------
-- Process Player Notes --
-------------------------------

function GLDG.PlayerManager:ProcessPlayerNotes(playerName, playerData)
	if not playerData then return end
	
	local publicNote = playerData.pNote or ""
	local officerNote = playerData.oNote or ""
	
	-- Check for alias in public note
	if publicNote and publicNote ~= "" then
		-- Simple alias detection - could be enhanced
		if not string.find(publicNote, "alt") and not string.find(publicNote, "main") then
			playerData.alias = publicNote
		end
	end
	
	-- Check for main/alt relationships in officer note
	if officerNote and officerNote ~= "" then
		local mainPattern = "main:%s*([%w%-]+)"
		local altPattern = "alt:%s*([%w%-]+)"
		
		local mainName = string.match(string.lower(officerNote), mainPattern)
		if mainName then
			playerData.alt = mainName -- This player is an alt of mainName
		end
		
		-- Check if this player is marked as main
		if string.find(string.lower(officerNote), "main") and not mainName then
			playerData.main = true
		end
	end
end

-------------------------------
-- Update Character Data --
-------------------------------

function GLDG.PlayerManager:UpdateCharacterData(newRoster)
	-- Initialize character data if not exists
	if not GLDG_DataChar then
		GLDG_DataChar = {}
	end

	-- Update existing characters and add new ones
	for playerName, playerData in pairs(newRoster) do
		if not GLDG_DataChar[playerName] then
			GLDG_DataChar[playerName] = {}
		end
		
		-- Update basic information
		GLDG_DataChar[playerName].lvl = playerData.lvl
		GLDG_DataChar[playerName].rank = playerData.rank
		GLDG_DataChar[playerName].rankname = playerData.rankname
		GLDG_DataChar[playerName].zone = playerData.zone
		GLDG_DataChar[playerName].pNote = playerData.pNote
		GLDG_DataChar[playerName].oNote = playerData.oNote
		GLDG_DataChar[playerName].class = playerData.class
		GLDG_DataChar[playerName].classDisplayName = playerData.classDisplayName
		GLDG_DataChar[playerName].achievementPoints = playerData.achievementPoints
		GLDG_DataChar[playerName].guild = playerData.guild
		GLDG_DataChar[playerName].own = playerData.own
		
		-- Store previous level for level-up detection
		if GLDG_DataChar[playerName].lvl and playerData.lvl > GLDG_DataChar[playerName].lvl then
			GLDG_DataChar[playerName].storedLvl = GLDG_DataChar[playerName].lvl
		end
		GLDG_DataChar[playerName].storedLvl = playerData.lvl
		
		-- Update alias and main/alt relationships from notes
		if playerData.alias then
			GLDG_DataChar[playerName].alias = playerData.alias
		end
		if playerData.main then
			GLDG_DataChar[playerName].main = playerData.main
		end
		if playerData.alt then
			GLDG_DataChar[playerName].alt = playerData.alt
		end
	end
	
	-- Mark characters no longer in guild
	for playerName, playerData in pairs(GLDG_DataChar) do
		if playerData.guild == GLDG_unique_GuildName and not newRoster[playerName] then
			GLDG_DataChar[playerName].guild = nil
			GLDG_DataChar[playerName].rank = nil
			GLDG_DataChar[playerName].rankname = nil
			GLDG_DataChar[playerName].pNote = nil
			GLDG_DataChar[playerName].oNote = nil
		end
	end
end

-------------------------------
-- Process Main/Alt Relationships --
-------------------------------

function GLDG.PlayerManager:ProcessMainAltRelationships()
	-- Auto-assign main/alt relationships based on patterns
	if GLDG_Data.GuildSettings.AutoAssign then
		self:AutoAssignMainAlt()
	end
	
	-- Count mains and alts
	GLDG_NumMain = 0
	GLDG_NumAlts = 0
	
	for playerName, playerData in pairs(GLDG_DataChar) do
		if playerData.guild == GLDG_unique_GuildName then
			if playerData.main then
				GLDG_NumMain = GLDG_NumMain + 1
			elseif playerData.alt then
				GLDG_NumAlts = GLDG_NumAlts + 1
			end
		end
	end
end

-------------------------------
-- Auto Assign Main/Alt --
-------------------------------

function GLDG.PlayerManager:AutoAssignMainAlt()
	-- This function implements automatic main/alt detection based on naming patterns
	-- and other heuristics
	
	for playerName, playerData in pairs(GLDG_DataChar) do
		if playerData.guild == GLDG_unique_GuildName and not playerData.main and not playerData.alt then
			-- Look for naming patterns that suggest main/alt relationships
			local baseName = self:GetBaseName(playerName)
			
			-- Find potential main character
			local potentialMain = self:FindPotentialMain(baseName, playerName)
			if potentialMain then
				GLDG_DataChar[playerName].alt = potentialMain
				
				-- Mark the main character as main if not already set
				if GLDG_DataChar[potentialMain] and not GLDG_DataChar[potentialMain].main then
					GLDG_DataChar[potentialMain].main = true
				end
			end
		end
	end
end

-------------------------------
-- Get Base Name --
-------------------------------

function GLDG.PlayerManager:GetBaseName(playerName)
	-- Extract base name by removing common alt suffixes
	local shortName = string.split("-", playerName)
	local baseName = shortName
	
	-- Remove common alt indicators
	baseName = string.gsub(baseName, "alt$", "")
	baseName = string.gsub(baseName, "%d+$", "")
	baseName = string.gsub(baseName, "bank$", "")
	baseName = string.gsub(baseName, "twink$", "")
	
	return baseName
end

-------------------------------
-- Find Potential Main --
-------------------------------

function GLDG.PlayerManager:FindPotentialMain(baseName, excludeName)
	local bestMatch = nil
	local bestScore = 0
	
	for playerName, playerData in pairs(GLDG_DataChar) do
		if playerName ~= excludeName and playerData.guild == GLDG_unique_GuildName then
			local score = self:CalculateMainScore(baseName, playerName, playerData)
			if score > bestScore then
				bestScore = score
				bestMatch = playerName
			end
		end
	end
	
	-- Only return a match if the score is high enough
	return bestScore > 0.5 and bestMatch or nil
end

-------------------------------
-- Calculate Main Score --
-------------------------------

function GLDG.PlayerManager:CalculateMainScore(baseName, playerName, playerData)
	local score = 0
	local shortName = string.split("-", playerName)
	
	-- Name similarity
	if string.find(string.lower(shortName), string.lower(baseName)) then
		score = score + 0.4
	end
	
	-- Level (higher level characters are more likely to be mains)
	if playerData.lvl and playerData.lvl >= 80 then
		score = score + 0.2
	end
	
	-- Guild rank (lower rank index = higher rank)
	if playerData.rank and playerData.rank <= 5 then
		score = score + 0.2
	end
	
	-- Achievement points (higher = more likely main)
	if playerData.achievementPoints and playerData.achievementPoints > 5000 then
		score = score + 0.2
	end
	
	return score
end

-------------------------------
-- Update Guild Info --
-------------------------------

function GLDG.PlayerManager:UpdateGuildInfo()
	if not IsInGuild() then return end
	
	-- Update guild name and leader
	GLDG_GuildName = GetGuildInfo("player") or ""
	GLDG_unique_GuildName = GLDG_GuildName
	
	-- Get guild leader
	for i = 1, GetNumGuildMembers() do
		local name, rank, rankIndex = GetGuildRosterInfo(i)
		if rankIndex == 0 then -- Guild Master
			GLDG_GuildLeader = name
			break
		end
	end
end

-------------------------------
-- Find Main Name --
-------------------------------

function GLDG.PlayerManager:FindMainName(mainName, playerName)
	local result = ""
	
	if mainName and GLDG_DataChar[mainName] then
		if GLDG_DataChar[mainName].alias then
			result = GLDG_DataChar[mainName].alias
		else
			result = Ambiguate(mainName, "guild")
		end
	elseif playerName and GLDG_DataChar[playerName] then
		if GLDG_DataChar[playerName].alias then
			result = GLDG_DataChar[playerName].alias
		else
			result = Ambiguate(playerName, "guild")
		end
	end
	
	return result
end

-------------------------------
-- Find Alts --
-------------------------------

function GLDG.PlayerManager:FindAlts(mainName, playerName, colourise)
	local result = ""
	local colour = ""
	
	if colourise == 0 then
		colour = GLDG_GOES_OFFLINE_COLOUR
	elseif colourise == 1 then
		colour = GLDG_ONLINE_COLOUR
	end
	
	if not mainName then return result end
	
	local onList = self:GetOnlineList()
	local mainDisplayed = false
	local altsList = {}
	
	-- Find all characters related to this main
	for name, data in pairs(GLDG_DataChar) do
		if data.guild == GLDG_unique_GuildName then
			local isRelated = false
			
			-- Check if this is the main character
			if name == mainName and data.main then
				isRelated = true
			-- Check if this is an alt of the main
			elseif data.alt == mainName then
				isRelated = true
			end
			
			if isRelated then
				local displayName = data.alias or Ambiguate(name, "guild")
				local details = self:FindPlayerDetails(name)
				local status = ""
				
				-- Add online status color
				if onList[name] then
					status = colour
				else
					status = GLDG_IS_OFFLINE_COLOUR
				end
				
				-- Format the entry
				local entry = status..displayName
				if details and details ~= "" then
					entry = entry..": "..details
				end
				entry = entry.."|r"
				
				if name == mainName then
					table.insert(altsList, 1, "["..entry.."]") -- Main character in brackets
				else
					table.insert(altsList, "("..entry..")") -- Alts in parentheses
				end
			end
		end
	end
	
	-- Join the list
	result = table.concat(altsList, " ")
	
	return result
end

-------------------------------
-- Get Online List --
-------------------------------

function GLDG.PlayerManager:GetOnlineList()
	local onlineList = {}
	
	-- Check guild members
	if IsInGuild() then
		for i = 1, GetNumGuildMembers() do
			local name, _, _, _, _, _, _, _, isOnline = GetGuildRosterInfo(i)
			if name and isOnline then
				local shortName, realm = string.split("-", name)
				if not realm then 
					name = shortName.."-"..string.gsub(GLDG.Realm, " ", "") 
				end
				onlineList[name] = true
			end
		end
	end
	
	-- Check friends list
	if GLDG_Data.UseFriends then
		for i = 1, C_FriendList.GetNumFriends() do
			local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
			if friendInfo and friendInfo.connected then
				local name = friendInfo.name
				local shortName, realm = string.split("-", name)
				if not realm then 
					name = shortName.."-"..string.gsub(GLDG.Realm, " ", "") 
				end
				onlineList[name] = true
			end
		end
	end
	
	return onlineList
end

-------------------------------
-- Find Player Details --
-------------------------------

function GLDG.PlayerManager:FindPlayerDetails(playerName)
	if not playerName or not GLDG_DataChar[playerName] then
		return ""
	end
	
	local player = GLDG_DataChar[playerName]
	local result = ""
	
	-- Add level
	if player.lvl then
		result = result..GLDG_DEFAULT_LVL_COLOUR..player.lvl.."|r"
	end
	
	-- Add class
	if player.classDisplayName then
		result = result.." "..player.classDisplayName
	end
	
	-- Add rank
	if player.rankname then
		result = result.." "..GLDG_DEFAULT_RANK_COLOUR..player.rankname.."|r"
	end
	
	-- Add zone
	if player.zone and player.zone ~= "" then
		result = result.." ("..player.zone..")"
	end
	
	return result
end

-------------------------------
-- Find Alias --
-------------------------------

function GLDG.PlayerManager:FindAlias(playerName, colourise)
	local result = ""
	local alias = ""
	local aliasColour = ""

	if (colourise == 0) then
		aliasColour = GLDG_GOES_OFFLINE_COLOUR
	elseif (colourise == 1) then
		aliasColour = GLDG_ALIAS_COLOUR
	end

	if playerName and GLDG_DataChar[playerName] then
		local player = GLDG_DataChar[playerName]
		
		if player.alias then
			alias = player.alias
		else
			alias = playerName
		end
		
		-- Use main's alias if greeting as main is enabled
		if GLDG_Data.GuildSettings.GreetAsMain and player.alt then
			local mainPlayer = GLDG_DataChar[player.alt]
			if mainPlayer and mainPlayer.alias then
				alias = mainPlayer.alias
			else
				alias = player.alt
			end
		end
	end

	if alias ~= "" and alias ~= playerName then
		result = result.." - "..aliasColour..alias.."|r"
	end

	return result
end

-------------------------------
-- List for Player --
-------------------------------

function GLDG.PlayerManager:ListForPlayer(playerName, allDetails, onList, printResult, guildOnly)
	local result = ""

	if printResult == nil then printResult = true end
	if allDetails == nil then allDetails = false end
	if guildOnly == nil then guildOnly = false end
	
	if not playerName or not GLDG_DataChar[playerName] then
		result = playerName.." "..L["is not in guild"]
		if GLDG_Data.UseFriends then
			result = result.." "..L["or a friend"]
		end
		if printResult then
			GLDG:PrintHelp(result)
		end
		return result
	end

	if not onList then
		onList = self:GetOnlineList()
	end

	local mainName
	if GLDG_DataChar[playerName].main then
		mainName = playerName
	elseif GLDG_DataChar[playerName].alt then
		mainName = GLDG_DataChar[playerName].alt
	else
		mainName = "-"
	end

	local details = self:FindPlayerDetails(playerName)
	
	-- Build the result using FindAlts function
	result = self:FindAlts(mainName, playerName, printResult and 1 or 0)
	
	if result == "" then
		result = L["No characters found"]
	end
	
	-- Add alias information
	result = result..self:FindAlias(playerName, printResult and 1 or 2)
	
	if printResult then
		GLDG:PrintHelp(result)
	end

	return result
end

-------------------------------
-- List All Players --
-------------------------------

function GLDG.PlayerManager:ListAllPlayers(includeOffline, printResult, guildOnly)
	local onList = self:GetOnlineList()
	local line = ""
	local result = {}
	local i = 0

	if guildOnly == nil then guildOnly = false end

	if includeOffline then
		if printResult then
			GLDG:PrintHelp(L["Listing all characters (also offline)"])
		end
		for player in pairs(GLDG_DataChar) do
			if self:ShouldIncludePlayer(player, guildOnly) then
				line = self:ListForPlayer(player, false, onList, printResult)
				result[i] = line
				i = i + 1
			end
		end
	else
		if printResult then
			GLDG:PrintHelp(L["Listing online characters only"])
		end
		for player in pairs(onList) do
			if not guildOnly or (GLDG_DataChar[player] and GLDG_DataChar[player].guild == GLDG_unique_GuildName) then
				line = self:ListForPlayer(player, false, onList, printResult)
				result[i] = line
				i = i + 1
			end
		end
	end

	return result
end

-------------------------------
-- Should Include Player --
-------------------------------

function GLDG.PlayerManager:ShouldIncludePlayer(playerName, guildOnly)
	local player = GLDG_DataChar[playerName]
	if not player then return false end
	
	if guildOnly then
		if player.guild ~= GLDG_unique_GuildName then return false end
		return (player.main or (not player.alt))
	else
		return (player.main or (not player.alt))
	end
end

-------------------------------
-- Main or Alt in Current Guild --
-------------------------------

function GLDG.PlayerManager:MainOrAltInCurrentGuild(name)
	if not name then return false end

	for p in pairs(GLDG_DataChar) do
		local player = GLDG_DataChar[p]
		-- Check if this player or their main is in the current guild
		if ((p == name) and (player.guild == GLDG_unique_GuildName)) or
		   ((player.alt == name) and (player.guild == GLDG_unique_GuildName)) then
			return true
		end
	end

	return false
end

-------------------------------
-- Roster Purge --
-------------------------------

function GLDG.PlayerManager:RosterPurge()
	local purged = 0
	
	-- Remove characters that are no longer relevant
	for playerName, playerData in pairs(GLDG_DataChar) do
		local shouldPurge = false
		
		-- Characters not in guild, not friends, not in channels
		if not playerData.guild and not playerData.friends and not playerData.channels then
			shouldPurge = true
		end
		
		-- Characters from other realms without connections
		local _, realm = string.split("-", playerName)
		if realm and realm ~= string.gsub(GLDG.Realm, " ", "") then
			if not playerData.friends and not playerData.channels then
				shouldPurge = true
			end
		end
		
		if shouldPurge then
			GLDG_DataChar[playerName] = nil
			purged = purged + 1
		end
	end
	
	GLDG:Print(GLDG.Database:GetColors().help..GLDG_NAME..":|r "..string.format(L["Purged %d characters"], purged))
	
	return purged
end

-------------------------------
-- Show Details --
-------------------------------

function GLDG.PlayerManager:ShowDetails(playerName)
	if not playerName or not GLDG_DataChar[playerName] then
		GLDG:PrintError(L["Player not found"].." ["..tostring(playerName).."]")
		return
	end
	
	local player = GLDG_DataChar[playerName]
	
	GLDG:PrintHelp(L["Details for"].." ["..Ambiguate(playerName, "guild").."]:")
	
	if player.lvl then
		GLDG:Print("  "..L["Level"]..": "..player.lvl)
	end
	
	if player.class then
		GLDG:Print("  "..L["Class"]..": "..(player.classDisplayName or player.class))
	end
	
	if player.rankname then
		GLDG:Print("  "..L["Rank"]..": "..player.rankname.." ("..tostring(player.rank or "?")..")")
	end
	
	if player.guild then
		GLDG:Print("  "..L["Guild"]..": "..player.guild)
	end
	
	if player.alias then
		GLDG:Print("  "..L["Alias"]..": "..player.alias)
	end
	
	if player.main then
		GLDG:Print("  "..L["Type"]..": "..L["Main Character"])
	elseif player.alt then
		GLDG:Print("  "..L["Type"]..": "..L["Alt of"].." "..player.alt)
	end
	
	if player.zone then
		GLDG:Print("  "..L["Zone"]..": "..player.zone)
	end
	
	if player.achievementPoints then
		GLDG:Print("  "..L["Achievement Points"]..": "..player.achievementPoints)
	end
	
	if player.pNote and player.pNote ~= "" then
		GLDG:Print("  "..L["Public Note"]..": "..player.pNote)
	end
	
	if player.oNote and player.oNote ~= "" then
		GLDG:Print("  "..L["Officer Note"]..": "..player.oNote)
	end
end

-- Global functions for backwards compatibility
function GLDG_RosterImport()
	GLDG.PlayerManager:RosterImport()
end

function GLDG_findMainname(main, player)
	return GLDG.PlayerManager:FindMainName(main, player)
end

function GLDG_FindAlts(mainName, playerName, colourise)
	return GLDG.PlayerManager:FindAlts(mainName, playerName, colourise)
end

function GLDG_getOnlineList()
	return GLDG.PlayerManager:GetOnlineList()
end

function GLDG_findPlayerDetails(playerName)
	return GLDG.PlayerManager:FindPlayerDetails(playerName)
end

function GLDG_findAlias(playerName, colourise)
	return GLDG.PlayerManager:FindAlias(playerName, colourise)
end

function GLDG_ListForPlayer(playerName, allDetails, onList, printResult, guildOnly)
	return GLDG.PlayerManager:ListForPlayer(playerName, allDetails, onList, printResult, guildOnly)
end

function GLDG_ListAllPlayers(includeOffline, printResult, guildOnly)
	return GLDG.PlayerManager:ListAllPlayers(includeOffline, printResult, guildOnly)
end

function GLDG_MainOrAltInCurrentGuild(name)
	return GLDG.PlayerManager:MainOrAltInCurrentGuild(name)
end

function GLDG.PlayerManager:ListForPlayer(playerName, allDetails, onList, print, guildOnly)
	local result = "";

	if (print == nil) then
		print = true;
	end
	if (allDetails == nil) then
		allDetails = false
	end
	if (guildOnly == nil) then
		guildOnly = false
	end
	if (playerName ~= nil) then
		if GLDG_DataChar[playerName] ~= nil then
			GLDG_SetActiveColourSet("guild")

			if ( onList == nil) then
				onList = self:getOnlineList();
			end

			local mainName;
			if ( GLDG_DataChar[playerName].main ) then
				mainName = playerName
			elseif ( GLDG_DataChar[playerName].alt ~= nil ) then
				mainName = GLDG_DataChar[playerName].alt;
			else
				mainName = "-";
			end

			local details = self:findPlayerDetails(playerName);
			local playerDetails = "";

			for player in pairs(GLDG_DataChar) do

				if (not guildOnly or (GLDG_DataChar[player].guild and GLDG_DataChar[player].guild==GLDG_unique_GuildName)) then
					local color = "";
					local endcolor = "";
					if (print) then
						color = GLDG_IS_OFFLINE_COLOUR;
						endcolor = "|r";
					end
					if ( onList[player] and print) then
						color = GLDG_ONLINE_COLOUR;
						endcolor = "|r";
					end

					if (allDetails) then
						playerDetails = self:findPlayerDetails(player)
					end

					local postfix = ""
					if (GLDG_Data.GuildSettings.AddPostfix==true) then
						if (GLDG_DataChar[player].guild and GLDG_DataChar[player].guild==GLDG_unique_GuildName) then
							-- no postfix for guild members
						elseif (GLDG_DataChar[player].channels and GLDG_DataChar[player].channels[GLDG_ChannelName]) then
							postfix = " {c}"
						elseif (GLDG_DataChar[player].friends and GLDG_DataChar[player].friends[GLDG.Player]) then
							postfix = " {f}"
						else
							postfix = " {?}"
						end
					end

					if ( GLDG_DataChar[player].main and (player == mainName) ) then
						if ((player == playerName) and print and details ~= "") then
							result = result..color.."["..Ambiguate(player, "guild")..": "..details..postfix.."]"..endcolor.." ";
						elseif (player == playerName) then
							result = result..color.."["..Ambiguate(player, "guild")..postfix.."]"..endcolor.." ";
						elseif (playerDetails~="" and print) then
							result = result..color.."["..Ambiguate(player, "guild")..": "..playerDetails..postfix.."]"..endcolor.." ";
						else
							result = result..color.."["..Ambiguate(player, "guild")..postfix.."]"..endcolor.." ";
						end
					elseif ( GLDG_DataChar[player].alt == mainName ) then
						if ((player == playerName) and print and details ~= "") then
							result = result..color.."("..Ambiguate(player, "guild")..": "..details..postfix..")"..endcolor.." ";
						elseif (player == playerName) then
							result = result..color..Ambiguate(player, "guild")..endcolor.." ";
						elseif (playerDetails~="" and print) then
							result = result..color.."("..Ambiguate(player, "guild")..": "..playerDetails..postfix..")"..endcolor.." ";
						else
							result = result..color..Ambiguate(player, "guild")..postfix..endcolor.." ";
						end
					elseif ((player == playerName) and print and details ~= "") then
						result = result..color.."("..Ambiguate(player, "guild")..": "..details..postfix..")"..endcolor.." ";
					elseif (player == playerName) then
						result = result..color..Ambiguate(player, "guild")..postfix..endcolor.." ";
					end
				end
			end

			if (result ~= "") then
				if (print) then
					result = result..self:findAlias(playerName, 1);
				else
					result = result..self:findAlias(playerName, 2);
				end
			else
				result = result..L["No characters found"]
			end
		else
			result = playerName.." "..L["is not in guild"];
			if GLDG_Data.UseFriends==true then
				result = result.." "..L["or a friend"];
			end
			if GLDG_inChannel then
				result = result.." "..L["or in channel"];
			end
		end
		if (print) then
			GLDG:PrintHelp(result);
		end
	end

	return result;
end

function GLDG.PlayerManager:ListAllPlayers(offline, print, guildOnly)
	local onList = self:getOnlineList();
	local line = "";
	local result = {};
	local i = 0;

	if (guildOnly == nil) then
		guildOnly = false
	end

	GLDG_SetActiveColourSet("guild")

	if offline then
		if (print) then
			GLDG:PrintHelp(L["Listing all characters (also offline)"])
		end
		for player in pairs(GLDG_DataChar) do
			if (not guildOnly and (GLDG_DataChar[player].main or not GLDG_DataChar[player].alt)) or
			   (guildOnly and ((not GLDG_DataChar[player].main and (not GLDG_DataChar[player].alt) and GLDG_DataChar[player].guild==GLDG_unique_GuildName) or
			                   (GLDG_DataChar[player].main and GLDG_MainOrAltInCurrentGuild(player)))) then
					line = self:ListForPlayer(player, false, onList, print);
					result[i] = line;
					i = i+1;
			end
		end
	else
		if (print) then
			GLDG:PrintHelp(L["Listing online characters only"])
		end
		for player in pairs(onList) do
			if (not guildOnly or (GLDG_DataChar[player].guild and GLDG_DataChar[player].guild==GLDG_unique_GuildName)) then
				line = self:ListForPlayer(player, false, onList, print);
				result[i] = line;
				i = i+1;
			end
		end
	end

	return result;
end

function GLDG.PlayerManager:MainOrAltInCurrentGuild(name)
	local result = false

	if name then
		for p in pairs(GLDG_DataChar) do
			if (p == name) and (GLDG_DataChar[p].guild and GLDG_DataChar[p].guild == GLDG_unique_GuildName) or				-- is this main, and in guild?
			   (GLDG_DataChar[p].alt == name) and (GLDG_DataChar[p].guild and GLDG_DataChar[p].guild == GLDG_unique_GuildName) then	-- is this an alt, and in guild?
			   	result = true
			end
		end
	end

	return result
end

function GLDG.PlayerManager:FindAlts(mainName, playerName, colourise)
	local altList = "";

	local details = self:findPlayerDetails(playerName)

	for player in pairs(GLDG_DataChar) do
		local color = GLDG_IS_OFFLINE_COLOUR;
		local endcolor = "|r";
		if (colourise == 0) then
			color = GLDG_GOES_OFFLINE_COLOUR;
		elseif ( player == playerName) then
			color = GLDG_ONLINE_COLOUR;
			endcolor = "|r";
		end

		local postfix = ""
		if (GLDG_Data.GuildSettings.AddPostfix==true) then
			if (GLDG_DataChar[player].guild and GLDG_DataChar[player].guild==GLDG_unique_GuildName) then
				-- no postfix for guild members
			elseif (GLDG_DataChar[player].channels and GLDG_DataChar[player].channels[GLDG_ChannelName]) then
				postfix = " {c}"
			elseif (GLDG_DataChar[player].friends and GLDG_DataChar[player].friends[GLDG.Player]) then
				postfix = " {f}"
			else
				postfix = " {?}"
			end
		end

		if ( GLDG_DataChar[player].main and (player == mainName) ) then
			if (player == playerName and details~="") then
				altList = altList..color.."["..Ambiguate(player, "guild")..": "..details..postfix.."]"..endcolor.." ";
			else
				altList = altList..color.."["..Ambiguate(player, "guild")..postfix.."]"..endcolor.." ";
			end
		elseif ( GLDG_DataChar[player].alt == mainName ) then
			if (player == playerName and details~="") then
				altList = altList..color.."("..Ambiguate(player, "guild")..": "..details..postfix..")"..endcolor.." ";
			else
				altList = altList..color..Ambiguate(player, "guild")..postfix..endcolor.." ";
			end
		end
	end

	altList = altList..self:findAlias(playerName, colourise);

	return altList
end

function GLDG_FindAlts(mainName, playerName, colourise)
	return GLDG.PlayerManager:FindAlts(mainName, playerName, colourise)
end

function GLDG_MainOrAltInCurrentGuild(name)
	return GLDG.PlayerManager:MainOrAltInCurrentGuild(name)
end

function GLDG_ListForPlayer(playerName, allDetails, onList, print, guildOnly)
	return GLDG.PlayerManager:ListForPlayer(playerName, allDetails, onList, print, guildOnly)
end

function GLDG_ListAllPlayers(offline, print, guildOnly)
	return GLDG.PlayerManager:ListAllPlayers(offline, print, guildOnly)
end

function GLDG_RosterPurge()
	return GLDG.PlayerManager:RosterPurge()
end

function GLDG_ShowDetails(playerName)
	GLDG.PlayerManager:ShowDetails(playerName)
end

------------------------------------------------------------
-- Player Filter Management
------------------------------------------------------------

function GLDG.PlayerManager:GuildFilterDropDown_OnClick(self, list)
	if not GLDG_guildFilterDropDownData then GLDG_guildFilterDropDownData = {} end
	local i = self:GetID();
	local n = self:GetParent():GetID()
	local name = self:GetName()
	GLDG_Data.GuildFilter = GLDG_guildFilterDropDownData[(n-1)*20 + i]
	if not GLDG_Data.GuildFilter then GLDG_Data.GuildFilter = "" end
	if GLDG_Data.GuildFilter == L["No guild filter"] then GLDG_Data.GuildFilter = "" end

	if (GLDG_Data.GuildFilter == "") then
		UIDropDownMenu_SetText(_G[GLDG_GUI.."Players".."RankFilterDropboxButton"], L["No rank filter"])
		GLDG_Data.RankFilter = "";
		UIDropDownMenu_SetSelectedID(_G[GLDG_GUI.."Players".."GuildFilterDropboxButton"], 1);
	else
		UIDropDownMenu_SetSelectedID(_G[GLDG_GUI.."Players".."GuildFilterDropboxButton"], i);
		UIDropDownMenu_SetText(_G[GLDG_GUI.."Players".."RankFilterDropboxButton"], L["No rank filter"])
		GLDG_Data.RankFilter = "";
	end

	-- list players
	GLDG_ListPlayers()
end

function GLDG.PlayerManager:RankFilterDropDown_OnClick(self, list)
	if not GLDG_rankFilterDropDownData then GLDG_rankFilterDropDownData = {} end
	local i = self:GetID();
	local n = self:GetParent():GetID()
	local name = self:GetName()
	GLDG_Data.RankFilter = GLDG_rankFilterDropDownData[(n-1)*20 + i]
	if not GLDG_Data.RankFilter then GLDG_Data.RankFilter = "" end
	if GLDG_Data.RankFilter == L["No rank filter"] then GLDG_Data.RankFilter = "" end

	if (GLDG_Data.RankFilter == "") then
		UIDropDownMenu_SetSelectedID(_G[GLDG_GUI.."Players".."RankFilterDropboxButton"], 1);
	else
		UIDropDownMenu_SetSelectedID(_G[GLDG_GUI.."Players".."RankFilterDropboxButton"], i);
	end

	-- list players
	GLDG_ListPlayers()
end

------------------------------------------------------------
-- Player Action Functions
------------------------------------------------------------

function GLDG.PlayerManager:ClickIgnore()
	-- Toggle ignore state for selected player
	local p = GLDG_DataChar[GLDG_SelPlrName]
	local main = p.alt
	if p.main then main = GLDG_SelPlrName end
	local newval = nil
	if not p.ignore then newval = true end
	-- If main or alt, toggle ignore for all characters of this player
	if main then 
		for q in pairs(GLDG_DataChar) do 
			if (q == main) or (GLDG_DataChar[q].alt == main) then 
				GLDG_DataChar[q].ignore = newval 
			end 
		end
	-- Otherwise, simply toggle ignore for this one character
	else p.ignore = newval end
	-- Show updated list
	GLDG_ListPlayers()
end

function GLDG.PlayerManager:ClickAlias(self)
	-- Activate alias subframe
	GLDG_ShowPlayerButtons()
	self:Disable()
	_G[self:GetParent():GetParent():GetParent():GetName().."SubAlias"]:Show()
end

function GLDG.PlayerManager:ShowPlayerAlias(frame)
	-- Set title
	_G[frame.."Header"]:SetText(string.format(L["Set alias for character %s"], GLDG_SelPlrName))
	-- Set editbox and buttons text
	local p = GLDG_DataChar[GLDG_SelPlrName]
	if p.alias then
		_G[frame.."Set"]:SetText(L["update"])
		_G[frame.."Del"]:SetText(L["delete"])
		_G[frame.."Editbox"]:SetText(p.alias)
	else
		_G[frame.."Set"]:SetText(L["set"])
		_G[frame.."Del"]:SetText(L["cancel"])
		_G[frame.."Editbox"]:SetText("")
	end
end

function GLDG.PlayerManager:ClickAliasSet(alias)
	if (alias == "") then return end
	GLDG_DataChar[GLDG_SelPlrName].alias = alias
	GLDG_ListPlayers()
end

function GLDG.PlayerManager:ClickAliasRemove()
	GLDG_DataChar[GLDG_SelPlrName].alias = nil
	GLDG_ListPlayers()
end

function GLDG.PlayerManager:ClickMain()
	-- Toggle main status for selected character or promote an alt
	local p = GLDG_DataChar[GLDG_SelPlrName]
	if p.main then
		p.main = nil
	elseif p.alt then
		local oldmain = p.alt
		p.alt = nil
		p.main = true
		for q in pairs(GLDG_DataChar) do
			if (q == oldmain) then
				GLDG_DataChar[q].main = nil
				GLDG_DataChar[q].alt = GLDG_SelPlrName
			elseif (GLDG_DataChar[q].alt == oldmain) then
				GLDG_DataChar[q].alt = GLDG_SelPlrName
			end
		end
	else
		p.main = true
	end
	-- Show updated list
	GLDG_ListPlayers()
end

function GLDG.PlayerManager:ClickAlt(self)
	-- Prepare for scrollbar adjustment if needed
	local p = {}
	if GLDG_SelPlrName then p = GLDG_DataChar[GLDG_SelPlrName] end
	local old = nil
	if GLDG_Data.GroupAlt==true then old = GLDG_GetPlayerOffset(GLDG_SelPlrName) end
	-- Toggle alt status for selected character
	local p = GLDG_DataChar[GLDG_SelPlrName]
	if p.alt then 
		p.alt = nil
	elseif (GLDG_NumMain == 1) then
		for q in pairs(GLDG_DataChar) do
			if GLDG_DataChar[q].main then
				p.alt = q
				p.ignore = GLDG_DataChar[q].ignore
				break 
			end 
		end
	else	
		GLDG_ShowPlayerButtons()
		self:Disable()
		_G[self:GetParent():GetParent():GetParent():GetName().."SubMainAlt"]:Show()
		return
	end
	-- Show updated list
	GLDG_ListPlayers()
	-- Adjust scrollbar if needed
	GLDG_CorrectPlayerOffset(old, GLDG_SelPlrName)
end

function GLDG.PlayerManager:ClickGuild(self)
	-- Activate guild subframe
	GLDG_ShowPlayerButtons()
	self:Disable()
	_G[self:GetParent():GetParent():GetParent():GetName().."SubGuild"]:Show()
end

function GLDG.PlayerManager:ShowPlayerGuild(frame)
	-- Set title
	_G[frame.."Header"]:SetText(string.format(L["Set guild for character %s"], GLDG_SelPlrName))
	-- Set editbox and buttons text
	local p = GLDG_DataChar[GLDG_SelPlrName]
	if p.guild then
		_G[frame.."Set"]:SetText(L["update"])
		_G[frame.."Del"]:SetText(L["delete"])
		_G[frame.."Editbox"]:SetText(p.guild)
	else
		_G[frame.."Set"]:SetText(L["set"])
		_G[frame.."Del"]:SetText(L["cancel"])
		_G[frame.."Editbox"]:SetText("")
	end
end

function GLDG.PlayerManager:ClickGuildSet(guild)
	if (guild == "") then return end
	GLDG_DataChar[GLDG_SelPlrName].guild = guild
	GLDG_ListPlayers()
end

function GLDG.PlayerManager:ClickGuildRemove()
	GLDG_DataChar[GLDG_SelPlrName].guild = nil
	GLDG_DataChar[GLDG_SelPlrName].rank = nil
	GLDG_DataChar[GLDG_SelPlrName].rankname = nil
	GLDG_DataChar[GLDG_SelPlrName].pNote = nil
	GLDG_DataChar[GLDG_SelPlrName].oNote = nil
	GLDG_ListPlayers()
end

function GLDG.PlayerManager:ClickNote(self)
	-- Activate note subframe
	GLDG_ShowPlayerButtons()
	self:Disable()
	_G[self:GetParent():GetParent():GetParent():GetName().."SubNote"]:Show()
end

function GLDG.PlayerManager:ShowPlayerNote(frame)
	-- Set title
	_G[frame.."Header"]:SetText(string.format(L["Set note for character %s"], GLDG_SelPlrName))
	-- Set editbox and buttons text
	local p = GLDG_DataChar[GLDG_SelPlrName]
	if p.note then
		_G[frame.."Set"]:SetText(L["update"])
		_G[frame.."Del"]:SetText(L["delete"])
		_G[frame.."Editbox"]:SetText(p.note)
	else
		_G[frame.."Set"]:SetText(L["set"])
		_G[frame.."Del"]:SetText(L["cancel"])
		_G[frame.."Editbox"]:SetText("")
	end
end

function GLDG.PlayerManager:ClickNoteSet(note)
	if (note == "") then return end
	GLDG_DataChar[GLDG_SelPlrName].note = note
	GLDG_ListPlayers()
end

function GLDG.PlayerManager:ClickNoteRemove()
	GLDG_DataChar[GLDG_SelPlrName].note = nil
	GLDG_ListPlayers()
end

function GLDG.PlayerManager:ClickPublicNote(self)
	-- Activate note subframe
	GLDG_ShowPlayerButtons()
	self:Disable()
	_G[self:GetParent():GetParent():GetParent():GetName().."SubPublicNote"]:Show()
end

------------------------------------------------------------
-- Player UI Management
------------------------------------------------------------

function GLDG.PlayerManager:ClickPlayerBar(frame)
	-- Update offset
	if not frame then frame = _G[GLDG_GUI.."PlayersPlayerbar"] end
	FauxScrollFrame_Update(frame, GLDG_TableSize(GLDG_SortedList), GLDG_NumPlrRows, 15)
	GLDG_PlayerOffset = FauxScrollFrame_GetOffset(frame)
	GLDG_ShowPlayers()
end

function GLDG.PlayerManager:OnClick_Header(element)
	--GLDG_Print("Clicked on header ["..tostring(element).."]")
end

function GLDG.PlayerManager:ClickPlayer(playerName)
	-- Prepare for scrollbar adjustment if needed
	local p = {}
	if GLDG_SelPlrName then p = GLDG_DataChar[GLDG_SelPlrName] end
	local old = nil
	if (GLDG_Data.ShowAlt==false) and (p.main or p.alt) then old = GLDG_GetPlayerOffset(playerName) end
	-- Set new selected player
	if (playerName == GLDG_SelPlrName) then GLDG_SelPlrName = nil
	else GLDG_SelPlrName = playerName end
	-- Refresh list
	GLDG_ListPlayers()
	-- Adjust scrollbar if needed
	GLDG_CorrectPlayerOffset(old, playerName)
end

function GLDG.PlayerManager:SortString(player)
	-- Helper function: returns string that should be used for sorting
	local result = player
	GLDG_Data.GuildSort=false --vorläufig abgeschaltet weil jetzt gefiltert wird
	if GLDG_Data.GuildSort==true then
		if GLDG_DataChar[player].guild then
			result = GLDG_DataChar[player].guild..player
		else
			result = "@"..player
		end
	elseif (GLDG_DataChar[player].alt and GLDG_Data.GroupAlt==true and GLDG_Data.FilterOnline==false) then
		result = GLDG_DataChar[player].alt..player
	end
	return string.lower(result)
end

-------------------------------
-- Player Manager Initialization --
-------------------------------

function GLDG.PlayerManager:Initialize()
	-- Initialize player tracking variables
	GLDG_RosterImportRunning = false
	GLDG_ReadNotes = false
	
	-- Initialize player lists
	if not GLDG_Online then GLDG_Online = {} end
	if not GLDG_Offline then GLDG_Offline = {} end
	if not GLDG_SortedList then GLDG_SortedList = {} end
	
	GLDG:Print(GLDG.Colors:GetColors().help..GLDG_NAME..":|r "..L["Player Manager module initialized"])
end