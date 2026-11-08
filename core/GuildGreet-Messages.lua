--[[--------------------------------------------------------
-- GuildGreet Message System Library
-- Handles greeting messages, message parsing, and communication
------------------------------------------------------------]]

-- Get or create the GuildGreet addon instance
local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet", true) or LibStub("AceAddon-3.0"):NewAddon("GuildGreet", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", true)

local function Ambiguate(name)
	if type(name) ~= "string" then return tostring(name or "") end
	return string.match(name, "^([^%-]+)") or name
end

-- Message System Library Namespace
GLDG.Messages = {}

-- NOTE: AceDB-3.0 Migration - Global variables now accessed through compatibility layer
-- GLDG_Data, GLDG_DataChar, GLDG_DataGreet are accessed via Metatables
-- initialized in GuildGreet.lua InitializeCompatibilityLayer()

-------------------------------
-- Message System Initialization --
-------------------------------

function GLDG.Messages:Initialize()
	-- Initialize message queues (use addon instance for storage)
	if not GLDG.Queue then GLDG.Queue = {} end
	
	-- Register addon message prefix
	if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
		C_ChatInfo.RegisterAddonMessagePrefix("GLDG")
	end

	-- Set up message filters
	self:SetupMessageFilters()
end

function GLDG.Messages:ShowQueue()
	if GLDG and GLDG.ShowQueue then
		GLDG:ShowQueue()
	end
end

-------------------------------
-- Setup Message Filters --
-------------------------------

function GLDG.Messages:SetupMessageFilters()
	if self.filtersRegistered then return end
	self.filtersRegistered = true

	-- Register chat message filters for enhanced chat display
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", GLDG_ChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", GLDG_ChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", GLDG_ChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", GLDG_ChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_ACHIEVEMENT", GLDG_ChatFilter)
end

-------------------------------
-- Chat Filter Function --
-------------------------------

function GLDG.Messages:ChatFilter(chatFrame, event, ...)
	local msg, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13 = ...

	-- Return early if data is not initialized yet (can happen during addon loading)
	if not GLDG_Data or not GLDG_Data.GuildSettings then
		return false, msg, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13
	end

	if not GLDG_Data.GuildSettings.ExtendChat then
		return false, msg, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13
	end

	local main = ""
	local class = ""
	local treated = nil

	if event then
		-- Process guild, officer, channel, and whisper messages
		if ((event == "CHAT_MSG_GUILD" and arg2) or
		    (event == "CHAT_MSG_OFFICER" and arg2) or
		    (event == "CHAT_MSG_CHANNEL" and arg9 and (arg9 == GLDG_ChannelName) and arg2) or
		    (event == "CHAT_MSG_WHISPER" and arg2)) then
			
			treated = true
			if GLDG_DataChar[arg2] and (not GLDG_DataChar[arg2].ignore or GLDG_Data.GuildSettings.ExtendIgnored) then
				if GLDG_DataChar[arg2].alt then
					main = GLDG_DataChar[arg2].alt
					if GLDG_Data.GuildSettings.ExtendAlias and GLDG_DataChar[main] and GLDG_DataChar[main].alias then
						main = GLDG_DataChar[main].alias
					end
				elseif GLDG_Data.GuildSettings.ExtendMain and GLDG_DataChar[arg2].main then
					main = arg2
					if GLDG_Data.GuildSettings.ExtendAlias and GLDG_DataChar[main] and GLDG_DataChar[main].alias then
						main = GLDG_DataChar[main].alias
					end
				end
			end
		end
	end

	if main ~= "" and msg and arg2 and (arg2 ~= GLDG.Player) then
		local colors = GLDG.Colors:GetColors()
		msg = colors.help.."{"..Ambiguate(main, "guild").."}|r "..msg
	end

	return false, msg, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13
end

-------------------------------
-- Custom Message Parsing --
-------------------------------

function GLDG.Messages:ParseCustomMessage(cname, name, msg)
	if not msg then return "" end
	if not cname then cname = "" end
	if not name then name = "" end
	
	local player = GLDG_DataChar[cname]
	if not player then player = {} end

	-- Replace custom placeholders
	local shortCName = Ambiguate(cname, "guild")
	local shortName = Ambiguate(name, "guild")
	local p_c = shortCName  -- %c = character name
	local p_n = shortName   -- %n = display name (alias or character name)
	local p_a = ""          -- %a = alias if available, character name else
	if player.alias then
		p_a = player.alias
	else
		p_a = shortCName
	end
	
	local p_m = ""     -- %m = main name if available, character name else
	local p_A = ""     -- %A = main alias if available, main name else, character name else
	if player.alt and GLDG_DataChar[player.alt] then
		p_m = Ambiguate(player.alt, "guild")
		if GLDG_DataChar[player.alt].alias then
			p_A = GLDG_DataChar[player.alt].alias
		else
			p_A = Ambiguate(player.alt, "guild")
		end
	elseif player.main then
		p_m = shortCName
		p_A = p_a
	else
		p_m = shortCName
		p_A = p_a
	end
	
	local p_l = ""     -- %l = level if available, empty else
	if player.lvl then
		p_l = tostring(player.lvl)
	end
	
	local p_L = ""     -- %L = level if available, empty else
	if player.storedLvl then
		p_L = tostring(player.storedLvl)
	end
	
	local p_C = ""     -- %C = class if available, empty else
	if player.classDisplayName then
		p_C = player.classDisplayName
	elseif player.class then
		p_C = player.class
	end
	
	local p_r = ""     -- %r = rank name if available, rank number else if available, empty else
	if player.rankname then
		p_r = player.rankname
	elseif player.rank then
		p_r = tostring(player.rank)
	end
	
	local p_v = ""     -- %v = achievement if available, empty else
	if player.achievment then
		p_v = player.achievment
	end
	
	local p_g = ""     -- %g = guild alias if available, else guild if available, else empty
	local p_G = ""     -- %G = guild name if available, else empty
	local cleanGuild = (GLDG.GuildName and GLDG.GuildName ~= "" and GLDG.GuildName) or GLDG.unique_GuildName or ""
	cleanGuild = string.gsub(cleanGuild, "^Guild:", "")
	cleanGuild = string.match(cleanGuild, "^([^%-]+)") or cleanGuild
	if cleanGuild ~= "" then
		p_g = cleanGuild
		p_G = cleanGuild
	end
	if GLDG_GuildAlias and GLDG_GuildAlias ~= "" then
		p_g = GLDG_GuildAlias
	end

	-- Replace fields in message
	msg = string.gsub(msg, "%%c", p_c)
	msg = string.gsub(msg, "%%n", p_n)
	msg = string.gsub(msg, "%%a", p_a)
	msg = string.gsub(msg, "%%m", p_m)
	msg = string.gsub(msg, "%%A", p_A)
	msg = string.gsub(msg, "%%l", p_l)
	msg = string.gsub(msg, "%%L", p_L)
	msg = string.gsub(msg, "%%C", p_C)
	msg = string.gsub(msg, "%%r", p_r)
	msg = string.gsub(msg, "%%v", p_v)
	msg = string.gsub(msg, "%%g", p_g)
	msg = string.gsub(msg, "%%G", p_G)

	return msg
end

-------------------------------
-- Filter Messages --
-------------------------------

function GLDG.Messages:FilterMessages(player, messageList)
	if not messageList then return {} end
	
	local filtered = {}
	
	-- Copy all messages (filtering can be implemented based on player data)
	for i, msg in pairs(messageList) do
		filtered[i] = msg
	end
	
	-- Future: Add filtering logic based on player level, rank, etc.
	
	return filtered
end

-------------------------------
-- Send Greeting --
-------------------------------

function GLDG.Messages:SendGreet(name, testing)
	if not name then return end
	
	-- Find player entry
	local player = GLDG_DataChar[name]
	if not player then return end
	
	local cname = name
	local names = {}
	local whisper = GLDG_Data.GuildSettings.Whisper
	table.insert(names, name)

	-- Choose appropriate greeting list
	local list = GLDG_DataGreet.Greet
	local option = ""
	
	if player.new then
		list = GLDG_DataGreet.Welcome
	elseif player.newrank then
		list = GLDG_DataGreet.NewRank
		option = player.rankname or ""
	elseif player.achievment then
		list = GLDG_DataGreet.Achievment
		option = player.achievment or ""
	elseif player.newlvl then
		list = GLDG_DataGreet.NewLevel
		option = tostring(player.lvl or "")
		if GLDG_Data.GuildSettings.WhisperLevelup then
			whisper = true
		end
	elseif GLDG_Offline[name] then
		list = GLDG_DataGreet.GreetBack
	end
	
	list = self:FilterMessages(player, list)

	-- Switch to alias if defined
	local usedAlias = false
	if player.alias then
		name = player.alias
		table.insert(names, name)
		usedAlias = true
	else
		name = Ambiguate(name, "guild")
	end

	-- Use name of main if alt and option is set
	if player.alt then
		local lname = ""
		local lalias = ""
		if GLDG_DataChar[player.alt] and GLDG_DataChar[player.alt].alias then
			lalias = GLDG_DataChar[player.alt].alias
		end
		lname = Ambiguate(player.alt, "guild")
		if lname ~= "" then
			table.insert(names, lname)
		end
		if lalias ~= "" then
			table.insert(names, lalias)
			lname = lalias
		end
		if not usedAlias and GLDG_Data.GuildSettings.GreetAsMain and lname and lname ~= "" then
			name = lname
		end
	end

	-- Select a random greeting
	local greetSize = GLDG.Utils:TableSize(list)
	if greetSize == 0 then return end
	local msg = list[math.random(greetSize)]

	-- Select a random name
	greetSize = GLDG.Utils:TableSize(names)
	if GLDG_Data.GuildSettings.Randomize and greetSize ~= 0 then
		name = names[math.random(greetSize)]
		local uName, uRealm = string.split("-", name)
		if uRealm then
			name = Ambiguate(name, "guild")
		end
	end

	-- Parse for our own %-codes
	local message = self:ParseCustomMessage(cname, name, msg)
	message = string.format(message, name, option)

	-- Send greeting
	if testing then
		GLDG:PrintHelp("["..message.."]")
	else
		self:SendMessage(message, whisper, player, cname)
	end
end

-------------------------------
-- Send Goodbye --
-------------------------------

function GLDG.Messages:SendBye(name, testing)
	if not name then return end

	-- Find player entry
	local player = GLDG_DataChar[name]
	if not player then return end

	local cname = name
	local names = {}
	table.insert(names, name)

	-- Choose appropriate goodbye list
	local option = ""
	local list = GLDG_DataGreet.Bye

	-- Use night messages if time is between 20:00 and 05:00
	local hour, min = GLDG.Utils:GetTime()
	if (hour >= 20) or (hour <= 5) then
		list = GLDG_DataGreet.Night
	end
	list = self:FilterMessages(player, list)

	-- Switch to alias if defined
	local usedAlias = false
	if player.alias then
		name = player.alias
		table.insert(names, name)
		usedAlias = true
	end

	-- Use name of main if alt and option is set
	if player.alt then
		local lname = ""
		local lalias = ""
		if GLDG_DataChar[player.alt] and GLDG_DataChar[player.alt].alias then
			lalias = GLDG_DataChar[player.alt].alias
		end
		lname = player.alt
		if lname ~= "" then
			table.insert(names, lname)
		end
		if lalias ~= "" then
			table.insert(names, lalias)
			lname = lalias
		end
		if not usedAlias and GLDG_Data.GuildSettings.GreetAsMain and lname ~= "" then
			name = lname
		end
	end

	-- Select a random goodbye
	local greetSize = GLDG.Utils:TableSize(list)
	if greetSize == 0 then return end
	local msg = list[math.random(greetSize)]

	-- Select a random name
	greetSize = GLDG.Utils:TableSize(names)
	if GLDG_Data.GuildSettings.Randomize and greetSize ~= 0 then
		name = names[math.random(greetSize)]
	end

	-- Parse for our own %-codes
	local message = self:ParseCustomMessage(cname, name, msg)
	message = string.format(message, name, option)

	-- Send goodbye
	if testing then
		GLDG:PrintHelp("["..message.."]")
	else
		self:SendMessage(message, GLDG_Data.GuildSettings.Whisper, player, cname)
	end
end

-------------------------------
-- Send Message Helper --
-------------------------------

function GLDG.Messages:SendMessage(message, forceWhisper, player, targetName)
	if not message then return end
	
	if forceWhisper then
		-- Manual whisper setting overrides all
		SendChatMessage(message, "WHISPER", nil, targetName)
	elseif player and player.guild and player.guild == GLDG.unique_GuildName then
		-- In same guild as this character
		SendChatMessage(message, "GUILD")
	elseif GLDG_ChannelName and player and player.channels and player.channels[GLDG_ChannelName] then
		-- In same channel as this character
		local channel = GetChannelName(GLDG_ChannelName)
		if channel then
			SendChatMessage(message, "CHANNEL", nil, tostring(channel))
		else
			SendChatMessage(message, "WHISPER", nil, targetName)
		end
	else
		-- Friends or indeterminate
		SendChatMessage(message, "WHISPER", nil, targetName)
	end
end

-------------------------------
-- Guild Greeting Functions --
-------------------------------

function GLDG.Messages:GreetGuild()
	if not GLDG.unique_GuildName or GLDG.unique_GuildName == "" then return end

	local list = GLDG_DataGreet.Guild
	list = self:FilterMessages(nil, list)

	local greetSize = GLDG.Utils:TableSize(list)
	if greetSize == 0 then return end

	local msg = list[math.random(greetSize)]
	msg = self:ParseCustomMessage("", "", msg)

	-- Send greeting (still parse for %s for backwards compatibility)
	SendChatMessage(string.format(msg, GLDG_GuildAlias or GLDG.unique_GuildName), "GUILD")
end

function GLDG.Messages:GreetChannel()
	if not GLDG_ChannelName then return end
	
	local list = GLDG_DataGreet.Channel
	list = self:FilterMessages(nil, list)

	local greetSize = GLDG.Utils:TableSize(list)
	if greetSize == 0 then return end

	local msg = list[math.random(greetSize)]
	msg = self:ParseCustomMessage("", "", msg)

	-- Send greeting
	local channel = GetChannelName(GLDG_ChannelName)
	if channel then
		SendChatMessage(msg, "CHANNEL", nil, tostring(channel))
	end
end

function GLDG.Messages:ByeGuild()
	if not GLDG.unique_GuildName or GLDG.unique_GuildName == "" then return end

	local list = GLDG_DataGreet.ByeGuild
	
	-- Use night messages if time is between 20:00 and 06:00
	local hour, min = GLDG.Utils:GetTime()
	if (hour >= 20) or (hour <= 5) then
		list = GLDG_DataGreet.NightGuild
	end
	list = self:FilterMessages(nil, list)

	local greetSize = GLDG.Utils:TableSize(list)
	if greetSize == 0 then return end

	local msg = list[math.random(greetSize)]
	msg = self:ParseCustomMessage("", "", msg)

	-- Send goodbye
	SendChatMessage(string.format(msg, GLDG_GuildAlias or GLDG.unique_GuildName), "GUILD")
end

function GLDG.Messages:ByeChannel()
	if not GLDG_ChannelName then return end
	
	local list = GLDG_DataGreet.ByeChannel
	
	-- Use night messages if time is between 20:00 and 05:00
	local hour, min = GLDG.Utils:GetTime()
	if (hour >= 20) or (hour <= 5) then
		list = GLDG_DataGreet.NightChannel
	end
	list = self:FilterMessages(nil, list)

	local greetSize = GLDG.Utils:TableSize(list)
	if greetSize == 0 then return end

	local msg = list[math.random(greetSize)]
	msg = self:ParseCustomMessage("", "", msg)

	-- Send goodbye
	local channel = GetChannelName(GLDG_ChannelName)
	if channel then
		SendChatMessage(msg, "CHANNEL", nil, tostring(channel))
	end
end

function GLDG.Messages:LaterGuild()
	if not GLDG.unique_GuildName or GLDG.unique_GuildName == "" then return end

	local list = GLDG_DataGreet.LaterGuild
	list = self:FilterMessages(nil, list)

	local greetSize = GLDG.Utils:TableSize(list)
	if greetSize == 0 then return end

	local msg = list[math.random(greetSize)]
	msg = self:ParseCustomMessage("", "", msg)

	-- Send "see you later" message
	SendChatMessage(string.format(msg, GLDG_GuildAlias or GLDG.unique_GuildName), "GUILD")
end

function GLDG.Messages:LaterChannel()
	if not GLDG_ChannelName then return end
	
	local list = GLDG_DataGreet.LaterChannel
	list = self:FilterMessages(nil, list)

	local greetSize = GLDG.Utils:TableSize(list)
	if greetSize == 0 then return end

	local msg = list[math.random(greetSize)]
	msg = self:ParseCustomMessage("", "", msg)

	-- Send "see you later" message
	local channel = GetChannelName(GLDG_ChannelName)
	if channel then
		SendChatMessage(msg, "CHANNEL", nil, tostring(channel))
	end
end

-------------------------------
-- Key Binding Functions --
-------------------------------

function GLDG.Messages:KeyGreet()
	if GLDG_Data.GreetGuild and GLDG_Data.GreetGuild[GLDG.Realm.." - "..GLDG.Player] then
		self:GreetGuild()
	end
	if GLDG_Data.GreetChannel and GLDG_Data.GreetChannel[GLDG.Realm.." - "..GLDG.Player] then
		self:GreetChannel()
	end
end

function GLDG.Messages:KeyBye()
	if GLDG_Data.GreetGuild and GLDG_Data.GreetGuild[GLDG.Realm.." - "..GLDG.Player] then
		self:ByeGuild()
	end
	if GLDG_Data.GreetChannel and GLDG_Data.GreetChannel[GLDG.Realm.." - "..GLDG.Player] then
		self:ByeChannel()
	end
end

function GLDG.Messages:KeyLater()
	if GLDG_Data.GreetGuild and GLDG_Data.GreetGuild[GLDG.Realm.." - "..GLDG.Player] then
		self:LaterGuild()
	end
	if GLDG_Data.GreetChannel and GLDG_Data.GreetChannel[GLDG.Realm.." - "..GLDG.Player] then
		self:LaterChannel()
	end
end

-------------------------------
-- Achievement Handling --
-------------------------------

function GLDG.Messages:TreatAchievement(message, playerName)
	if not message or not playerName then return end
	local shortName, realm = string.split("-", playerName)
	if not realm and GLDG.Realm then
		playerName = shortName.."-"..string.gsub(GLDG.Realm, " ", "")
	end
	
	-- Parse achievement from system message
	local _, _, _, achievementText = string.find(message, GLDG_ACHIEVE)
	if not achievementText then
		achievementText = message
	end
	
	-- Store achievement for greeting
	if GLDG_DataChar[playerName] and not GLDG_DataChar[playerName].ignore then
		-- Print achievement notification if enabled
		if GLDG_Data.GuildSettings.ListAchievments then
			local colors = GLDG.Colors:GetColors()
			local achievementColor = (colors.guild and colors.guild.achievment) or GLDG_DEFAULT_ACHIEVMENT_COLOUR
			GLDG:PrintHelp(achievementColor..Ambiguate(playerName, "guild").." "..(L["has earned"] or "earned").." "..tostring(achievementText).."|r")
		end

		-- Queue for achievement greeting if enabled
		if not GLDG_Data.GuildSettings.SupressAchievment and GLDG.Utils:TableSize(GLDG_DataGreet.Achievment) > 0 and not GLDG_DataChar[playerName].own then
			GLDG_DataChar[playerName].achievment = achievementText
			GLDG_Queue[playerName] = GLDG_GetLogtime(playerName)
			GLDG_ShowQueue()
		end
	end
end

-------------------------------
-- Message Queue Processing --
-------------------------------

function GLDG.Messages:ProcessQueue()
	GLDG_ShowQueue()
end

-------------------------------
-- System Message Processing --
-------------------------------

function GLDG.Messages:ProcessSystemMessage(msg)
	if not msg then return end
	
	-- Check for player coming online
	local _, _, player = string.find(msg, GLDG_ONLINE)
	if player then
		self:HandlePlayerOnline(player)
		return
	end
	
	-- Check for player going offline
	local _, _, offPlayer = string.find(msg, GLDG_OFFLINE)
	if offPlayer then
		self:HandlePlayerOffline(offPlayer)
		return
	end
	
	-- Check for guild join
	local _, _, joinPlayer = string.find(msg, GLDG_JOINED)
	if joinPlayer then
		self:HandleGuildJoin(joinPlayer)
		return
	end
	
	-- Check for promotion
	local _, _, _, promotePlayer, newRank = string.find(msg, GLDG_PROMO)
	if promotePlayer then
		self:HandlePromotion(promotePlayer, nil, newRank)
		return
	end
	
	-- Check for demotion
	local _, _, demotePlayer, demoteRank = string.find(msg, GLDG_DEMOTE)
	if demotePlayer then
		self:HandleDemotion(demotePlayer, demoteRank)
		return
	end
	
	-- Check for achievement
	local _, _, achievePlayer = string.find(msg, GLDG_ACHIEVE)
	if achievePlayer then
		self:TreatAchievement(msg, achievePlayer)
		return
	end
end

-------------------------------
-- Player Status Handlers --
-------------------------------

function GLDG.Messages:HandlePlayerOnline(playerName)
	if not playerName then return end
	
	-- Normalize player name
	local shortName, realm = string.split("-", playerName)
	if not realm and GLDG.Realm then 
		playerName = shortName.."-"..string.gsub(GLDG.Realm, " ", "") 
	end
	
	-- Store online time
	GLDG_Online[playerName] = GetTime()
	
	-- Check if this is a known player
	local p = GLDG_DataChar[playerName]
	if p and not p.ignore and (not p.own or GLDG_Data.GuildSettings.IncludeOwn) then
		-- Show player list if enabled
		if GLDG_Data.GuildSettings.ListNames then
			GLDG.PlayerManager:ListForPlayer(playerName, false, nil, true)
		end

		if p.alt and GLDG_Offline[p.alt] then
			GLDG_Offline[playerName] = GLDG_Offline[p.alt]
		end
		if GLDG_Offline[playerName] and type(GLDG_Offline[playerName]) == "number" then
			if (GLDG_Online[playerName] - GLDG_Offline[playerName]) < ((GLDG_Data.GuildSettings.RelogTime or 2) * 60) then
				return
			end
		end

		-- Add to greeting queue if not suppressed
		if not GLDG_Data.GuildSettings.SupressGreet then
			if GLDG_Offline[playerName] and GLDG.Utils:TableSize(GLDG_DataGreet.GreetBack) == 0 then
				return
			end
			if not GLDG_Offline[playerName] and GLDG.Utils:TableSize(GLDG_DataGreet.Greet) == 0 then
				return
			end
			GLDG_Queue[playerName] = GLDG_GetLogtime(playerName)
			GLDG_ShowQueue()
		end
	end
end

function GLDG.Messages:HandlePlayerOffline(playerName)
	if not playerName then return end
	
	-- Normalize player name
	local shortName, realm = string.split("-", playerName)
	if not realm and GLDG.Realm then 
		playerName = shortName.."-"..string.gsub(GLDG.Realm, " ", "") 
	end
	
	-- Remove from online list
	GLDG_Online[playerName] = nil
	GLDG_RankUpdate[playerName] = nil

	local p = GLDG_DataChar[playerName]
	if p then
		if p.alt and GLDG_DataChar[p.alt] then
			GLDG_DataChar[p.alt].last = playerName
			GLDG_Offline[p.alt] = GetTime()
		elseif p.main then
			p.last = playerName
			GLDG_Offline[playerName] = GetTime()
		else
			GLDG_Offline[playerName] = GetTime()
		end
	else
		GLDG_Offline[playerName] = GetTime()
	end

	if GLDG_Queue[playerName] then
		GLDG_Queue[playerName] = nil
		GLDG_ShowQueue()
	end
	
	-- Show offline notification if enabled
	if GLDG_Data.GuildSettings.ListNamesOff and p and not p.ignore then
		local colors = GLDG.Colors:GetColors()
		local offlineColor = (colors.guild and colors.guild.goOff) or GLDG_DEFAULT_GOES_OFFLINE_COLOUR
		GLDG:PrintHelp(offlineColor..Ambiguate(playerName, "guild").." "..(L["went offline"] or "went offline").."|r")
	end
end

function GLDG.Messages:HandleGuildJoin(playerName)
	if not playerName then return end
	local shortName, realm = string.split("-", playerName)
	if not realm and GLDG.Realm then 
		playerName = shortName.."-"..string.gsub(GLDG.Realm, " ", "") 
	end
	
	-- Mark as new player
	if not GLDG_DataChar[playerName] then
		GLDG_DataChar[playerName] = {}
	end
	GLDG_DataChar[playerName].new = true
	GLDG_DataChar[playerName].guild = GLDG.unique_GuildName
	
	-- Add to greeting queue if not suppressed
	if not GLDG_Data.GuildSettings.SupressJoin and GLDG.Utils:TableSize(GLDG_DataGreet.Welcome) > 0 then
		GLDG_Queue[playerName] = GLDG_GetLogtime(playerName)
		GLDG_ShowQueue()
	end
end

function GLDG.Messages:HandlePromotion(playerName, oldRank, newRank)
	if not playerName then return end
	local shortName, realm = string.split("-", playerName)
	if not realm and GLDG.Realm then 
		playerName = shortName.."-"..string.gsub(GLDG.Realm, " ", "") 
	end
	
	-- Update player rank information
	if GLDG_DataChar[playerName] then
		GLDG_DataChar[playerName].newrank = true
		GLDG_DataChar[playerName].rankname = newRank
		GLDG_DataChar[playerName].oldrank = oldRank
		GLDG_RankUpdate[playerName] = GetTime()
		
		-- Add to greeting queue if not suppressed
		if not GLDG_Data.GuildSettings.SupressRank and GLDG.Utils:TableSize(GLDG_DataGreet.NewRank) > 0 then
			GLDG_Queue[playerName] = GLDG_GetLogtime(playerName)
			GLDG_ShowQueue()
		end
		
		-- Show promotion notification
		local colors = GLDG.Colors:GetColors()
		local rankColor = (colors.guild and colors.guild.rank) or GLDG_DEFAULT_RANK_COLOUR
		GLDG:PrintHelp(rankColor..Ambiguate(playerName, "guild").." "..(L["was promoted to"] or "promoted to").." "..tostring(newRank).."|r")
	end
end

function GLDG.Messages:HandleDemotion(playerName, newRank)
	if not playerName then return end
	local shortName, realm = string.split("-", playerName)
	if not realm and GLDG.Realm then 
		playerName = shortName.."-"..string.gsub(GLDG.Realm, " ", "") 
	end
	
	-- Update player rank information
	if GLDG_DataChar[playerName] then
		GLDG_DataChar[playerName].rankname = newRank
		
		-- Show demotion notification
		local colors = GLDG.Colors:GetColors()
		local rankColor = (colors.guild and colors.guild.rank) or GLDG_DEFAULT_RANK_COLOUR
		GLDG:PrintHelp(rankColor..Ambiguate(playerName, "guild").." "..(L["was demoted to"] or "demoted to").." "..tostring(newRank).."|r")
	end
end

-- Global functions for backwards compatibility
function GLDG_ParseCustomMessage(cname, name, msg)
	return GLDG.Messages:ParseCustomMessage(cname, name, msg)
end

function GLDG_FilterMessages(player, messageList)
	return GLDG.Messages:FilterMessages(player, messageList)
end

function GLDG_SendGreet(name, testing)
	GLDG.Messages:SendGreet(name, testing)
end

function GLDG_SendBye(name, testing)
	GLDG.Messages:SendBye(name, testing)
end

function GLDG.Messages:OnEvent(mainObj, event, ...)
	local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13 = ...
	-- Distribute events to appropriate functions
	if (event == "ADDON_LOADED") and (arg1 == GLDG_NAME) then
		mainObj:UnregisterEvent("ADDON_LOADED")
		if GLDG_InitComplete==nil then
			GLDG_Init()
		end
	elseif (event == "VARIABLES_LOADED") then
		mainObj:UnregisterEvent("VARIABLES_LOADED")

		if GLDG_InitComplete==nil then
			GLDG_Init()
		end
		GLDG_autoConsistencyCheckReady = true

		-- add menu to player frame and chat menu
		if (mainObj.db.profile.ExtendPlayerMenu==true) then
			GLDG_AddPopUpButtons();
		end

	elseif (event == "PLAYER_ENTERING_WORLD") then
		if GLDG_InitComplete==nil then
			GLDG_Init()
		end
		GLDG_CheckForGuildAlert()
		GLDG_InitRoster()
		mainObj:UnregisterEvent("PLAYER_ENTERING_WORLD")
		mainObj:RegisterEvent("GUILD_ROSTER_UPDATE", "OnEvent")
		mainObj:RegisterEvent("FRIENDLIST_UPDATE", "OnEvent")
		mainObj:RegisterEvent("CHAT_MSG_CHANNEL_JOIN", "OnEvent")
		mainObj:RegisterEvent("CHAT_MSG_CHANNEL_LEAVE", "OnEvent")
		mainObj:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE", "OnEvent")
		mainObj:RegisterEvent("CHAT_MSG_ADDON", "OnEvent")
		mainObj:RegisterEvent("GROUP_ROSTER_UPDATE", "OnEvent")
		mainObj:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT", "OnEvent")
		mainObj:RegisterEvent("WHO_LIST_UPDATE", "OnEvent")

		-- Ensure message filters are registered
		self:SetupMessageFilters()

		-- Battle.net events (testing)
		mainObj:RegisterEvent("BN_CONNECTED", "OnEvent")
		mainObj:RegisterEvent("BN_DISCONNECTED", "OnEvent")
		mainObj:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE", "OnEvent")
		mainObj:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE", "OnEvent")
		mainObj:RegisterEvent("BN_FRIEND_INFO_CHANGED", "OnEvent")

	elseif (event == "PLAYER_GUILD_UPDATE") then
		if GLDG.SyncDatabaseReferences then
			GLDG:SyncDatabaseReferences()
		end
		if IsInGuild() then
			GLDG_InitRoster()
			if GLDG_RosterImportRunning == 0 then
				GLDG_RosterImport()
			end
		else
			GLDG.GuildName = ""
			GLDG.unique_GuildName = ""
			GLDG_unique_GuildName = ""
			if GLDG_Online then
				for k in pairs(GLDG_Online) do GLDG_Online[k] = nil end
			end
		end
		if GLDG.RefreshConfigUI then
			GLDG:RefreshConfigUI()
		end

	elseif (event == "GUILD_ROSTER_UPDATE") then
		if GLDG.SyncDatabaseReferences then
			GLDG:SyncDatabaseReferences()
		end
		if IsInGuild() then
			if (GLDG.unique_GuildName and GLDG.Realm and GLDG.unique_GuildName~="") then
				-- guild name known -> treat guild info safely without calling protected GetGuildInfoText()
				local currentInfoTxt = (GLDG.GetSafeGuildInfoText and GLDG:GetSafeGuildInfoText()) or ""
				if (GLDG_ginfotxt) and (GLDG_ginfotxt ~= currentInfoTxt) then
					GLDG_ginfotxt = currentInfoTxt
					GLDG_config_from_guild = nil
				end
				if GLDG_Data.GuildSettings.UseGuildDefault == true and GLDG_config_from_guild == nil then
					GLDG_ginfotxt = currentInfoTxt
					if type(GLDG_ginfotxt) == "string" and GLDG_ginfotxt >= " " then
						if not GLDG_Data[GLDG.unique_GuildName] then GLDG_Data[GLDG.unique_GuildName] = {} end
						if not GLDG_Data.GuildSettings then GLDG_Data.GuildSettings = {} end
						GLDG_Data.GuildSettings.UseGuildDefault = true
						GLDG_readConfigString()
						GLDG_SetCheckboxes()
					else
						GLDG_config_from_guild = "not found"
					end
				end
				if GLDG_Data.GuildSettings.UseGuildDefault == false and GLDG_config_from_guild == nil then
					GLDG_ginfotxt = currentInfoTxt
					if type(GLDG_ginfotxt) == "string" and GLDG_ginfotxt >= " " then
						GLDG_readConfigString()
					else
						GLDG_config_from_guild = "not found"
					end
				end
				if GLDG_RosterImportRunning==0 then
					GLDG_RosterImport()
				end
			else
				-- guild name not yet known -> try reinitialisation
				GLDG_InitRoster()
			end
		else
			GLDG.GuildName = ""
			GLDG.unique_GuildName = ""
			GLDG_unique_GuildName = ""
			if GLDG.SyncDatabaseReferences then
				GLDG:SyncDatabaseReferences()
			end
		end

	elseif (event == "CHAT_MSG_GUILD_ACHIEVEMENT") then
		GLDG_TreatAchievment(arg1, arg2)

		elseif (event == "CHAT_MSG_ACHIEVEMENT") then
		GLDG_TreatAchievment(arg1, arg2)

	-- who response going to social frame
	elseif (event == "WHO_LIST_UPDATE") then
		GLDG_ParseWho()

	-- who responses going to chat
	elseif ( event == "CHAT_MSG_SYSTEM" ) and (arg1 and strfind(arg1, WHO_NUM_RESULTS) ) then
		GLDG_ParseWho()

	-- guild members and/or friends joining/leaving
	elseif (event == "CHAT_MSG_SYSTEM") then
		self:ProcessSystemMessage(arg1)

	elseif (event == "FRIENDLIST_UPDATE") then
		if (GLDG.Realm and GLDG.Player) then
			GLDG_FriendsUpdate()
		else
			GLDG_InitRoster()
		end

	-- entering special channel
	elseif (event == "CHAT_MSG_CHANNEL_NOTICE") then
		if (arg9 and arg9 ~="" and string.lower(arg9) == GLDG_ChannelName) then
			if (arg1 and arg1 == "YOU_JOINED") then
				GLDG_CheckChannel()
			elseif (arg1 and arg1 == "YOU_LEFT") then
				GLDG_inChannel = false;
			end
		end

	-- parsing update of special channel
	elseif (event == "CHAT_MSG_CHANNEL_LIST") then
		if (arg9 and arg9~="" and string.lower(arg9)==GLDG_ChannelName) then
			GLDG_InitChannel(arg1)
		end

	-- catching people entering and leaving channel
	elseif (event == "CHAT_MSG_CHANNEL_JOIN") then
		if (arg9 and arg9~="" and string.lower(arg9) == GLDG_ChannelName) then
			GLDG_UpdateChannel(true, arg2)
		end
	elseif (event == "CHAT_MSG_CHANNEL_LEAVE") then
		if (arg9 and arg9~="" and string.lower(arg9) == GLDG_ChannelName) then
			GLDG_UpdateChannel(false, arg2)
		end

	elseif (event == "CHAT_MSG_ADDON") then
		-- arg1 = prefix, arg2 = msg, arg3 = channel, arg4 = sender
		if (arg1 == "GLDG") then
			--GLDG_Print("--> "..event..": "..arg1.." ["..arg2.."] - "..arg3..": "..arg4)

			if (string.sub(arg2, 1, 4)=="VER:") then
				if (mainObj.db.profile.ShowNewerVersions==true) then
					local myVersion	= GLDG_GetAddOnMetadata("GuildGreet", "Version")
					local hisVersion = string.sub(arg2, 5)

					if (not GLDG_HighestVersion) then
						GLDG_HighestVersion = myVersion
					end

					if (mainObj.db.profile.BigBrother and (arg4 ~= GLDG.Player)) then
						if (not GLDG_BigBrother) then
							GLDG_BigBrother = {}
						end
						if (not GLDG_BigBrother[arg4]) then
							GLDG_BigBrother[arg4] = hisVersion
							mainObj:PrintHelp(arg4..L[" is using version "]..hisVersion)
						elseif (GLDG_BigBrother[arg4] ~= hisVersion) then
							mainObj:PrintHelp(arg4..L[" has updated from version "]..GLDG_BigBrother[arg4]..L[" to version "]..hisVersion..L[""])
							GLDG_BigBrother[arg4] = hisVersion
						end
					end


					if (hisVersion > myVersion) then
						if (hisVersion > GLDG_HighestVersion) then
							-- to make sure, we only warn once
							GLDG_HighestVersion = hisVersion

							mainObj:PrintHelp(L["A newer Version of the addon is available."])
							mainObj:PrintHelp(L["You have version "]..myVersion..L["."])
							mainObj:PrintHelp(L["Player"]..arg4..L[" has version "]..hisVersion..L["."])
						else

						end
					end
				end
			elseif (string.sub(arg2, 1, 6)=="QUERY:") then
				local ver = GLDG_GetAddOnMetadata("GuildGreet", "Version") or "Unknown"
				C_ChatInfo.SendAddonMessage("GLDG", "VER:"..ver, "GUILD")
				local inInstance, instanceType = IsInInstance()
				if (instanceType ~= "pvp") and (instanceType ~= "arena") and (GetNumSubgroupMembers() > 0) then
					C_ChatInfo.SendAddonMessage("GLDG", "VER:"..ver, "PARTY")
				end
				if (instanceType ~= "pvp") and (instanceType ~= "arena") and (GetNumGroupMembers() > 0) then
					C_ChatInfo.SendAddonMessage("GLDG", "VER:"..ver, "RAID")
				end
				if (instanceType == "pvp") then
					C_ChatInfo.SendAddonMessage("GLDG", "VER:"..ver, "BATTLEGROUND")
				end
			end
		end

	-- catching people leaving or entering party/raid
	-- it seems that GetNumParty/RaidMembers() returns >0 when in BGs but PARTY and RAID are unavailable in these settings
	elseif (event == "GROUP_ROSTER_UPDATE") then
		local ver = GLDG_GetAddOnMetadata("GuildGreet", "Version") or "Unknown"
		local inInstance, instanceType = IsInInstance()
		if (instanceType ~= "pvp") and (instanceType ~= "arena") and (GetNumSubgroupMembers() > 0 ) then
			C_ChatInfo.SendAddonMessage("GLDG", "VER:"..ver, "PARTY")
		end
		if (instanceType ~= "pvp") and (instanceType ~= "arena") and (GetNumGroupMembers() > 0) then
			C_ChatInfo.SendAddonMessage("GLDG", "VER:"..ver, "RAID")
		end
		if (instanceType == "pvp") then
			C_ChatInfo.SendAddonMessage("GLDG", "VER:"..ver, "BATTLEGROUND")
		end

	elseif (event == "BN_CONNECTED") or
		(event == "BN_DISCONNECTED") or
		(event == "BN_FRIEND_ACCOUNT_OFFLINE") or
		(event == "BN_FRIEND_ACCOUNT_ONLINE") or
		(event == "BN_FRIEND_INFO_CHANGED") then
		if (arg1~=nil) or (arg2~=nil) or (arg3~=nil) or (arg4~=nil) or (arg5~=nil) or (arg6~=nil) or (arg7~=nil) or (arg8~=nil) or (arg9~=nil) or (arg10~=nil) or (arg11~=nil) or (arg12~=nil) or (arg13~=nil) then

		end

	end
end

function GLDG_GreetGuild()
	GLDG.Messages:GreetGuild()
end

function GLDG_GreetChannel()
	GLDG.Messages:GreetChannel()
end

function GLDG_ByeGuild()
	GLDG.Messages:ByeGuild()
end

function GLDG_ByeChannel()
	GLDG.Messages:ByeChannel()
end

function GLDG_LaterGuild()
	GLDG.Messages:LaterGuild()
end

function GLDG_LaterChannel()
	GLDG.Messages:LaterChannel()
end

function GLDG_KeyGreet()
	GLDG.Messages:KeyGreet()
end

function GLDG_KeyBye()
	GLDG.Messages:KeyBye()
end

function GLDG_KeyLater()
	GLDG.Messages:KeyLater()
end

function GLDG_TreatAchievment(message, playerName)
	GLDG.Messages:TreatAchievement(message, playerName)
end

function GLDG_SystemMsg(msg)
	GLDG.Messages:ProcessSystemMessage(msg)
end

function GLDG_ChatFilter(...)
	return GLDG.Messages:ChatFilter(...)
end

------------------------------------------------------------
-- Greetings Management Functions
------------------------------------------------------------

function GLDG.Messages:ClickGreetButton(self, id)
	-- Set frame
	local frame = self:GetName()
	-- Change selection if id is given
	if id then
		frame = self:GetParent():GetName()
		GLDG_SelMsgNum = nil
		_G[frame.."Editbox"]:SetText("")
		local map = {}
		map[1] = "Greet"
		map[2] = "GreetBack"
		map[3] = "Welcome"
		map[4] = "NewRank"
		map[5] = "NewLevel"
		map[6] = "Bye"
		map[7] = "Night"
		map[8] = "Guild"
		map[9] = "Channel"
		map[10] = "ByeGuild"
		map[11] = "NightGuild"
		map[12] = "ByeChannel"
		map[13] = "NightChannel"
		map[14] = "LaterGuild"
		map[15] = "LaterChannel"
		map[16] = "Achievment"
		GLDG_Selection = map[id]
	end
	-- Enable all buttons except active
	if (GLDG_Selection == "Greet") then _G[frame.."SelDefault"]:Disable() else _G[frame.."SelDefault"]:Enable() end
	if (GLDG_Selection == "GreetBack") then _G[frame.."SelRelog"]:Disable() else _G[frame.."SelRelog"]:Enable() end
	if (GLDG_Selection == "Welcome") then _G[frame.."SelJoin"]:Disable() else _G[frame.."SelJoin"]:Enable() end
	if (GLDG_Selection == "NewRank") then _G[frame.."SelRank"]:Disable() else _G[frame.."SelRank"]:Enable() end
	if (GLDG_Selection == "NewLevel") then _G[frame.."SelLevel"]:Disable() else _G[frame.."SelLevel"]:Enable() end
	if (GLDG_Selection == "Bye") then _G[frame.."SelBye"]:Disable() else _G[frame.."SelBye"]:Enable() end
	if (GLDG_Selection == "Night") then _G[frame.."SelNight"]:Disable() else _G[frame.."SelNight"]:Enable() end
	if (GLDG_Selection == "Guild") then _G[frame.."SelGuild"]:Disable() else _G[frame.."SelGuild"]:Enable() end
	if (GLDG_Selection == "Channel") then _G[frame.."SelChannel"]:Disable() else _G[frame.."SelChannel"]:Enable() end
	if (GLDG_Selection == "ByeGuild") then _G[frame.."SelByeGuild"]:Disable() else _G[frame.."SelByeGuild"]:Enable() end
	if (GLDG_Selection == "NightGuild") then _G[frame.."SelNightGuild"]:Disable() else _G[frame.."SelNightGuild"]:Enable() end
	if (GLDG_Selection == "ByeChannel") then _G[frame.."SelByeChannel"]:Disable() else _G[frame.."SelByeChannel"]:Enable() end
	if (GLDG_Selection == "NightChannel") then _G[frame.."SelNightChannel"]:Disable() else _G[frame.."SelNightChannel"]:Enable() end
	if (GLDG_Selection == "LaterGuild") then _G[frame.."SelLaterGuild"]:Disable() else _G[frame.."SelLaterGuild"]:Enable() end
	if (GLDG_Selection == "LaterChannel") then _G[frame.."SelLaterChannel"]:Disable() else _G[frame.."SelLaterChannel"]:Enable() end
	if (GLDG_Selection == "Achievment") then _G[frame.."SelAchievment"]:Disable() else _G[frame.."SelAchievment"]:Enable() end
	-- Update editbox header
	_G[frame.."EditboxHeader"]:SetText(L["Editbox/"..GLDG_Selection]) -- generate L["Editbox/Achievment"] - L["Editbox/Bye"] etc.
	-- Refresh scrollbar
	GLDG_ClickGreetScrollBar(self, _G[frame.."Scrollbar"])
end

function GLDG.Messages:ClickGreetScrollBar(self, frame)
	if not frame then
		frame = self
	end
	GLDG_GreetOffset = FauxScrollFrame_GetOffset(frame)
	local list = GLDG_Data[GLDG_Selection]
	if GLDG_SelColName then
		list = GLDG_Data.Collections[GLDG_SelColName][GLDG_Selection]
	end
	FauxScrollFrame_Update(frame, GLDG_TableSize(list), GLDG_NumSelRows, 15)
	GLDG_ShowGreetings(frame:GetParent():GetName())
end

function GLDG.Messages:ClickGreeting(self, id)
	-- Set new selected message
	if GLDG_SelMsgNum and (GLDG_SelMsgNum == GLDG_GreetOffset + id) then GLDG_SelMsgNum = nil
	else GLDG_SelMsgNum = GLDG_GreetOffset + id end
	-- Refresh greetings list
	GLDG_ShowGreetings(self:GetParent():GetName())
end

function GLDG.Messages:ClickGreetAdd(self, frame)
	-- Clear focus
	_G[frame.."Editbox"]:ClearFocus()
	-- Refuse if no input in editbox
	local text = _G[frame.."Editbox"]:GetText()
	if (text == "") then return end
	-- Update message if one is selected
	local list = GLDG_Data[GLDG_Selection]
	if GLDG_SelColName then list = GLDG_Data.Collections[GLDG_SelColName][GLDG_Selection] end
	if GLDG_SelMsgNum then list[GLDG_SelMsgNum] = text
	-- Add message if none is selected
	else 	_G[frame.."Editbox"]:SetText("")
		list[GLDG_TableSize(list) + 1] = text end
	-- Update display
	GLDG_ClickGreetScrollBar(self, _G[frame.."Scrollbar"])
end

function GLDG.Messages:ClickGreetRemove(self, frame)
	-- Clear focus
	_G[frame.."Editbox"]:ClearFocus()
	-- Remove message if one is selected
	local list = GLDG_Data[GLDG_Selection]
	if GLDG_SelColName then list = GLDG_Data.Collections[GLDG_SelColName][GLDG_Selection] end
	if GLDG_SelMsgNum then
		local cnt = GLDG_SelMsgNum
		while list[cnt + 1] do
			list[cnt] = list[cnt + 1]
			cnt = cnt + 1 end
		GLDG_SelMsgNum = nil
		list[cnt] = nil end
	-- Update display
	GLDG_ClickGreetScrollBar(self, _G[frame.."Scrollbar"])
end