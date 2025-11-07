--[[--------------------------------------------------------
-- GuildGreet Migration Library
-- Handles data conversion, migration, and consistency checks
------------------------------------------------------------]]

local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", false)

-- Migration Library Namespace
GLDG.Migration = {}

-- Migration counters
local GLDG_fixCount = 0

-------------------------------
-- Migration System Initialization --
-------------------------------

function GLDG.Migration:Initialize()
	-- Check if migration is needed
	self:CheckMigrationNeeded()
	
	GLDG:Print(GLDG.Colors:GetColors().help..GLDG_NAME..":|r "..L["Migration system initialized"])
end

-------------------------------
-- Main Conversion Function --
-------------------------------

function GLDG.Migration:Convert()
	local toConvert = {}
	local i = 0

	GLDG:PrintHelp(L["Starting data conversion..."])

	-- Find channels, guilds and friends for all realms
	for p in pairs(GLDG_Data) do
		i = i + 1

		-- Parse channel entries
		local _, _, realm, channel = string.find(tostring(p), "(.*)%s%-%schannel%s%-%s(.*)")
		if realm ~= nil then
			if not toConvert[realm] then
				toConvert[realm] = {}
			end
			if not toConvert[realm].channels then
				toConvert[realm].channels = {}
			end
			toConvert[realm].channels[channel] = channel
		else
			-- Parse friends entries
			local _, _, realm2 = string.find(tostring(p), "(.*)%s%-%-%sfriends")
			if realm2 ~= nil then
				if not toConvert[realm2] then
					toConvert[realm2] = {}
				end
				if not toConvert[realm2].friends then
					toConvert[realm2].friends = true
				end
			else
				-- Parse guild entries
				local _, _, realm3, guild = string.find(tostring(p), "(.*)%s%-%s(.*)")
				if realm3 ~= nil then
					if not toConvert[realm3] then
						toConvert[realm3] = {}
					end
					if not toConvert[realm3].guilds then
						toConvert[realm3].guilds = {}
					end
					toConvert[realm3].guilds[guild] = guild
				end
			end
		end
	end

	-- Process marked entries
	for r in pairs(toConvert) do
		if toConvert[r].guilds then
			for g in pairs(toConvert[r].guilds) do
				self:ConvertGuild(r, g)
			end
		end

		if toConvert[r].channels then
			for c in pairs(toConvert[r].channels) do
				self:ConvertChannel(r, c)
			end
		end

		if toConvert[r].friends then
			self:ConvertFriends(r)
		end
	end

	-- Cleanup and finalize
	self:CleanupGuildInformation()
	self:ConvertChannelNames()
	self:ConvertColours()

	GLDG:PrintHelp(L["Data conversion completed"])
end

-------------------------------
-- Convert Guild Data --
-------------------------------

function GLDG.Migration:ConvertGuild(realm, guild)
	GLDG:PrintHelp(L["Converting guild"].."["..tostring(guild).."]"..L["found for realm"].."["..tostring(realm).."]")

	local key = realm.." - "..guild
	local newKey = "Realm: "..realm

	if not GLDG_Data[newKey] then
		GLDG_Data[newKey] = {}
	end

	if GLDG_Data[key] then
		for name in pairs(GLDG_Data[key]) do
			if name ~= nil then
				if not GLDG_Data[newKey][name] then
					GLDG_Data[newKey][name] = {}
				end

				-- Copy character data
				for entry in pairs(GLDG_Data[key][name]) do
					if entry and GLDG_Data[key][name][entry] then
						if GLDG_Data[newKey][name][entry] then
							if GLDG_Data[newKey][name][entry] ~= GLDG_Data[key][name][entry] then
								-- Handle conflicts by keeping the newer entry
								GLDG:PrintHelp(L["Conflict resolved for"].." ["..name.."]["..entry.."]")
							end
						else
							GLDG_Data[newKey][name][entry] = GLDG_Data[key][name][entry]
						end
					end
				end
				GLDG_Data[newKey][name].guild = guild
			end
		end

		-- Remove old entry
		GLDG_Data[key] = nil
	end
end

-------------------------------
-- Convert Channel Data --
-------------------------------

function GLDG.Migration:ConvertChannel(realm, channel)
	GLDG:PrintHelp(L["Converting channel"].."["..tostring(channel).."]"..L["found for realm"].."["..tostring(realm).."]")

	local key = realm.." - channel - "..channel
	local newKey = "Realm: "..realm

	if not GLDG_Data[newKey] then
		GLDG_Data[newKey] = {}
	end

	local newChannel = string.lower(channel)

	if GLDG_Data[key] then
		for name in pairs(GLDG_Data[key]) do
			if name ~= nil then
				if not GLDG_Data[newKey][name] then
					GLDG_Data[newKey][name] = {}
				end

				-- Copy character data
				for entry in pairs(GLDG_Data[key][name]) do
					if entry and GLDG_Data[key][name][entry] then
						if not GLDG_Data[newKey][name][entry] then
							GLDG_Data[newKey][name][entry] = GLDG_Data[key][name][entry]
						end
					end
				end
				
				if not GLDG_Data[newKey][name].channels then
					GLDG_Data[newKey][name].channels = {}
				end
				GLDG_Data[newKey][name].channels[newChannel] = newChannel
			end
		end

		-- Remove old entry
		GLDG_Data[key] = nil
	end
end

-------------------------------
-- Convert Friends Data --
-------------------------------

function GLDG.Migration:ConvertFriends(realm)
	GLDG:PrintHelp(L["Converting friends found for realm"].."["..tostring(realm).."]")

	local key = realm.." -- friends"
	local newKey = "Realm: "..realm

	if not GLDG_Data[newKey] then
		GLDG_Data[newKey] = {}
	end

	-- Copy data of friends
	if GLDG_Data[key] and GLDG_Data[key].friends then
		for name in pairs(GLDG_Data[key].friends) do
			if name ~= nil then
				if not GLDG_Data[newKey][name] then
					GLDG_Data[newKey][name] = {}
				end

				-- Copy friend data
				for entry in pairs(GLDG_Data[key].friends[name]) do
					if entry and GLDG_Data[key].friends[name][entry] then
						if not GLDG_Data[newKey][name][entry] then
							GLDG_Data[newKey][name][entry] = GLDG_Data[key].friends[name][entry]
						end
					end
				end
			end
		end
	end

	-- Set who has them on the friend's list
	if GLDG_Data[key] and GLDG_Data[key].chars then
		for name in pairs(GLDG_Data[key].chars) do
			for char in pairs(GLDG_Data[key].chars[name]) do
				if not GLDG_Data[newKey][char] then
					GLDG_Data[newKey][char] = {}
				end
				if not GLDG_Data[newKey][char].friends then
					GLDG_Data[newKey][char].friends = {}
				end
				GLDG_Data[newKey][char].friends[name] = name
			end
		end
	end

	-- Remove old entry
	GLDG_Data[key] = nil
end

-------------------------------
-- Cleanup Functions --
-------------------------------

function GLDG.Migration:CleanupGuildInformation()
	-- Cleanup guild information for non-guild members
	for p in pairs(GLDG_DataChar) do
		local player = GLDG_DataChar[p]
		if not player.guild then
			player.rank = nil
			player.rankname = nil
			player.pNote = nil
			player.oNote = nil
		end
	end
end

function GLDG.Migration:ConvertChannelNames()
	-- Force channel names to lower case
	if GLDG_Data.ChannelNames then
		for p in pairs(GLDG_Data.ChannelNames) do
			local channelName = string.lower(GLDG_Data.ChannelNames[p])
			GLDG_Data.ChannelNames[p] = channelName
		end
	end
end

function GLDG.Migration:ConvertColours()
	-- Remove obsolete channel and friend specific colours
	-- This is handled by the new color system in GuildGreet-Colors.lua
	-- Legacy color entries are automatically migrated to the new structure
end

-------------------------------
-- Plausibility Check System --
-------------------------------

function GLDG.Migration:PlausibilityCheck(suppressOutput)
	local fixNeeded = false

	if not suppressOutput then
		GLDG:PrintHelp(L["Verifying data consistency..."])
	end

	-- Check for entries with both main and alt
	if not suppressOutput then
		GLDG:PrintHelp(L["Verifying double main-alt entries"])
	end
	
	for p in pairs(GLDG_DataChar) do
		local player = GLDG_DataChar[p]
		if player.alt and player.main then
			fixNeeded = true
			local alt = player.alt
			
			if GLDG_DataChar[alt] then
				local altPlayer = GLDG_DataChar[alt]
				if altPlayer.main then
					if altPlayer.alt then
						if not suppressOutput then
							GLDG:PrintHelp(L["--> conflict:"].." ["..Ambiguate(p, "guild").."] "..L["is both main and alt. It's main"].." ["..alt.."] "..L["however is also main and alt, its main"].." ["..altPlayer.alt.."] "..L["has not been checked, but will be seperately."])
						end
					else
						if not suppressOutput then
							GLDG:PrintHelp(L["--> conflict:"].." ["..Ambiguate(p, "guild").."] "..L["is both main and alt. It's main"].." ["..alt.."] "..L["should probably be main."])
						end
					end
				else
					if altPlayer.alt then
						if not suppressOutput then
							GLDG:PrintHelp(L["--> conflict:"].." ["..Ambiguate(p, "guild").."] "..L["is both main and alt. It's main"].." ["..alt.."] "..L["however is not main but an alt, its main"].." ["..altPlayer.alt.."] "..L["has not been checked, but will be seperately."])
						end
					else
						if not suppressOutput then
							GLDG:PrintHelp(L["--> conflict:"].." ["..Ambiguate(p, "guild").."] "..L["is both main and alt. It's main"].." ["..alt.."] "..L["is neither main or alt."])
						end
					end
				end
			end
		end
	end

	-- Check for entries that are their own main
	for p in pairs(GLDG_DataChar) do
		local player = GLDG_DataChar[p]
		if player.alt and player.alt == p then
			fixNeeded = true
			if not suppressOutput then
				GLDG:PrintHelp(L["--> conflict:"]..L["character"].." ["..Ambiguate(p, "guild").."] "..L["is its own main. This reference should be removed."])
			end
		end
	end

	-- Check for entries where an alt-link points to a char which doesn't exist
	if not suppressOutput then
		GLDG:PrintHelp(L["Verifying main-alt relations part 2"])
	end
	
	for p in pairs(GLDG_DataChar) do
		local player = GLDG_DataChar[p]
		if player.alt and not GLDG_DataChar[player.alt] then
			fixNeeded = true
			if not suppressOutput then
				GLDG:PrintHelp(L["--> conflict:"]..L["alt"].." ["..Ambiguate(p, "guild").."] "..L["has main"].." ["..player.alt.."] "..L["which does not exist."])
			end
		end
	end

	-- Check for entries where an alt-link points to a main that isn't main
	if not suppressOutput then
		GLDG:PrintHelp(L["Verifying main-alt relations"])
	end
	
	for p in pairs(GLDG_DataChar) do
		local player = GLDG_DataChar[p]
		if player.alt and GLDG_DataChar[player.alt] and not GLDG_DataChar[player.alt].main then
			fixNeeded = true
			if not suppressOutput then
				GLDG:PrintHelp(L["--> conflict:"]..L["alt"].." ["..Ambiguate(p, "guild").."] "..L["has main"].." ["..player.alt.."] "..L["which is not marked as main."])
			end
		end
	end

	if not suppressOutput then
		if fixNeeded then
			GLDG:PrintHelp(L["Done. Type |cFFFFFF7F/gg fix|r to automatically fix these issues"])
		else
			GLDG:PrintHelp(L["Done"])
		end
	end

	return fixNeeded
end

-------------------------------
-- Automatic Fix System --
-------------------------------

function GLDG.Migration:PlausibilityFix(suppressTitle)
	GLDG_fixCount = 0

	if not suppressTitle then
		GLDG:PrintHelp(L["Automatically fixing inconsistencies"])
	end

	-- Fix entries with both main and alt
	for p in pairs(GLDG_DataChar) do
		local player = GLDG_DataChar[p]
		if player.alt and player.main then
			local alt = player.alt
			
			if GLDG_DataChar[alt] then
				local altPlayer = GLDG_DataChar[alt]
				if altPlayer.main then
					-- The supposed main is actually a main, so remove main flag from this character
					player.main = nil
					GLDG_fixCount = GLDG_fixCount + 1
					GLDG:PrintHelp(L["Fixed: Removed main flag from"].." ["..Ambiguate(p, "guild").."]")
				else
					-- The supposed main is not a main, set it as main
					altPlayer.main = true
					GLDG_fixCount = GLDG_fixCount + 1
					GLDG:PrintHelp(L["Fixed: Set main flag for"].." ["..Ambiguate(alt, "guild").."]")
				end
			else
				-- The supposed main doesn't exist, remove the alt reference
				player.alt = nil
				GLDG_fixCount = GLDG_fixCount + 1
				GLDG:PrintHelp(L["Fixed: Removed invalid alt reference from"].." ["..Ambiguate(p, "guild").."]")
			end
		end
	end

	-- Fix entries that are their own main
	for p in pairs(GLDG_DataChar) do
		local player = GLDG_DataChar[p]
		if player.alt and player.alt == p then
			player.alt = nil
			GLDG_fixCount = GLDG_fixCount + 1
			GLDG:PrintHelp(L["Fixed: Removed self-reference from"].." ["..Ambiguate(p, "guild").."]")
		end
	end

	-- Fix entries where an alt-link points to a char which doesn't exist
	for p in pairs(GLDG_DataChar) do
		local player = GLDG_DataChar[p]
		if player.alt and not GLDG_DataChar[player.alt] then
			player.alt = nil
			GLDG_fixCount = GLDG_fixCount + 1
			GLDG:PrintHelp(L["Fixed: Removed invalid alt reference from"].." ["..Ambiguate(p, "guild").."]")
		end
	end

	-- Fix entries where an alt-link points to a main that isn't main
	for p in pairs(GLDG_DataChar) do
		local player = GLDG_DataChar[p]
		if player.alt and GLDG_DataChar[player.alt] and not GLDG_DataChar[player.alt].main then
			GLDG_DataChar[player.alt].main = true
			GLDG_fixCount = GLDG_fixCount + 1
			GLDG:PrintHelp(L["Fixed: Set main flag for"].." ["..Ambiguate(player.alt, "guild").."]")
		end
	end

	if GLDG_fixCount > 0 then
		GLDG:PrintHelp(string.format(L["Fixed %d issues"], GLDG_fixCount))
	else
		GLDG:PrintHelp(L["No issues found to fix"])
	end

	return GLDG_fixCount
end

-------------------------------
-- Data Validation --
-------------------------------

function GLDG.Migration:ValidateData()
	local issues = {}

	-- Check for orphaned alts
	for p in pairs(GLDG_DataChar) do
		local player = GLDG_DataChar[p]
		if player.alt and not GLDG_DataChar[player.alt] then
			table.insert(issues, {
				type = "orphaned_alt",
				player = p,
				main = player.alt,
				message = L["Player has invalid main reference"]
			})
		end
	end

	-- Check for circular references
	for p in pairs(GLDG_DataChar) do
		local player = GLDG_DataChar[p]
		if player.alt then
			local visited = {}
			local current = p
			
			while current and not visited[current] do
				visited[current] = true
				local currentPlayer = GLDG_DataChar[current]
				if currentPlayer and currentPlayer.alt then
					current = currentPlayer.alt
				else
					break
				end
				
				if current == p then
					table.insert(issues, {
						type = "circular_reference",
						player = p,
						message = L["Circular main-alt reference detected"]
					})
					break
				end
			end
		end
	end

	-- Check for inconsistent guild data
	for p in pairs(GLDG_DataChar) do
		local player = GLDG_DataChar[p]
		if player.guild and player.rank and not player.rankname then
			table.insert(issues, {
				type = "missing_rank_name",
				player = p,
				message = L["Player has rank number but no rank name"]
			})
		end
	end

	return issues
end

-------------------------------
-- Migration Status Check --
-------------------------------

function GLDG.Migration:CheckMigrationNeeded()
	local migrationNeeded = false
	local migrationTasks = {}

	-- Check for old data format entries
	for key in pairs(GLDG_Data) do
		if type(key) == "string" then
			-- Check for old guild format
			if string.find(key, " - ") and not string.find(key, "Realm: ") then
				migrationNeeded = true
				table.insert(migrationTasks, "convert_guild_format")
				break
			end
			
			-- Check for old channel format
			if string.find(key, " - channel - ") then
				migrationNeeded = true
				table.insert(migrationTasks, "convert_channel_format")
				break
			end
			
			-- Check for old friends format
			if string.find(key, " -- friends") then
				migrationNeeded = true
				table.insert(migrationTasks, "convert_friends_format")
				break
			end
		end
	end

	-- Check for data consistency issues
	local hasConsistencyIssues = self:PlausibilityCheck(true)
	if hasConsistencyIssues then
		migrationNeeded = true
		table.insert(migrationTasks, "fix_consistency")
	end

	if migrationNeeded then
		GLDG:PrintHelp(L["Migration tasks needed: "] .. table.concat(migrationTasks, ", "))
		GLDG:PrintHelp(L["Type |cFFFFFF7F/gg convert|r to start migration"])
	end

	return migrationNeeded, migrationTasks
end

-------------------------------
-- Migration Report --
-------------------------------

function GLDG.Migration:GenerateMigrationReport()
	local report = {}
	
	-- Count data entries
	local guildCount = 0
	local channelCount = 0
	local friendCount = 0
	local playerCount = 0
	
	for p in pairs(GLDG_DataChar) do
		playerCount = playerCount + 1
		local player = GLDG_DataChar[p]
		if player.guild then guildCount = guildCount + 1 end
		if player.friends then friendCount = friendCount + 1 end
		if player.channels then channelCount = channelCount + 1 end
	end
	
	table.insert(report, L["Migration Report:"])
	table.insert(report, string.format(L["Total players: %d"], playerCount))
	table.insert(report, string.format(L["Guild members: %d"], guildCount))
	table.insert(report, string.format(L["Friends: %d"], friendCount))
	table.insert(report, string.format(L["Channel members: %d"], channelCount))
	
	-- Check for issues
	local issues = self:ValidateData()
	if #issues > 0 then
		table.insert(report, string.format(L["Data issues found: %d"], #issues))
	else
		table.insert(report, L["No data issues found"])
	end
	
	return report
end

-------------------------------
-- Backup and Restore --
-------------------------------

function GLDG.Migration:CreateBackup()
	-- Create a backup of current data before migration
	if not GLDG_Data.Backups then
		GLDG_Data.Backups = {}
	end
	
	local timestamp = date("%Y%m%d_%H%M%S")
	local backupKey = "backup_" .. timestamp
	
	-- Create deep copy of character data
	GLDG_Data.Backups[backupKey] = {}
	for p in pairs(GLDG_DataChar) do
		GLDG_Data.Backups[backupKey][p] = GLDG.Utils:TableCopy(GLDG_DataChar[p])
	end
	
	GLDG:PrintHelp(string.format(L["Backup created: %s"], backupKey))
	return backupKey
end

function GLDG.Migration:RestoreBackup(backupKey)
	if not GLDG_Data.Backups or not GLDG_Data.Backups[backupKey] then
		GLDG:PrintError(L["Backup not found: "] .. tostring(backupKey))
		return false
	end
	
	-- Restore character data from backup
	GLDG_DataChar = GLDG.Utils:TableCopy(GLDG_Data.Backups[backupKey])
	
	GLDG:PrintHelp(string.format(L["Data restored from backup: %s"], backupKey))
	return true
end

function GLDG.Migration:ListBackups()
	if not GLDG_Data.Backups then
		GLDG:PrintHelp(L["No backups found"])
		return {}
	end
	
	local backups = {}
	for key in pairs(GLDG_Data.Backups) do
		table.insert(backups, key)
	end
	
	table.sort(backups)
	
	GLDG:PrintHelp(L["Available backups:"])
	for _, backup in ipairs(backups) do
		GLDG:Print("  " .. backup)
	end
	
	return backups
end

-- Global functions for backwards compatibility
function GLDG_Convert()
	GLDG.Migration:Convert()
end

function GLDG_Convert_Guild(realm, guild)
	GLDG.Migration:ConvertGuild(realm, guild)
end

function GLDG_Convert_Channel(realm, channel)
	GLDG.Migration:ConvertChannel(realm, channel)
end

function GLDG_Convert_Friends(realm)
	GLDG.Migration:ConvertFriends(realm)
end

function GLDG_Convert_ChannelNames()
	GLDG.Migration:ConvertChannelNames()
end

function GLDG_Convert_Colours()
	GLDG.Migration:ConvertColours()
end

function GLDG_Convert_Plausibility_Check(suppressOutput)
	return GLDG.Migration:PlausibilityCheck(suppressOutput)
end

function GLDG_Convert_Plausibility_Fix(suppressTitle)
	return GLDG.Migration:PlausibilityFix(suppressTitle)
end