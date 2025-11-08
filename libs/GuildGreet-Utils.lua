--[[--------------------------------------------------------
-- GuildGreet Utility Functions Library
-- Provides common utility functions and helpers
------------------------------------------------------------]]

local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", false)

-- Utility Library Namespace
GLDG.Utils = {}

-------------------------------
-- Table Utility Functions --
-------------------------------

function GLDG.Utils:TableSize(table)
	if not table then return 0 end
	
	local count = 0
	for _ in pairs(table) do
		count = count + 1
	end
	return count
end

function GLDG.Utils:TableCopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[self:TableCopy(orig_key)] = self:TableCopy(orig_value)
		end
		setmetatable(copy, self:TableCopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function GLDG.Utils:TableContains(table, value)
	if not table then return false end
	
	for _, v in pairs(table) do
		if v == value then
			return true
		end
	end
	return false
end

function GLDG.Utils:TableMerge(t1, t2)
	if not t1 then t1 = {} end
	if not t2 then return t1 end
	
	for k, v in pairs(t2) do
		t1[k] = v
	end
	return t1
end

-------------------------------
-- String Processing Functions --
-------------------------------

function GLDG.Utils:GetWords(str)
	if not str then return {} end
	
	local words = {}
	local index = 0
	
	-- Split string into words
	for word in string.gmatch(str, "%S+") do
		words[index] = word
		index = index + 1
	end
	
	return words
end

function GLDG.Utils:TrimString(str)
	if not str then return "" end
	return string.match(str, "^%s*(.-)%s*$") or ""
end

function GLDG.Utils:SplitString(str, delimiter)
	if not str then return {} end
	if not delimiter then delimiter = "%s" end
	
	local result = {}
	local pattern = string.format("([^%s]+)", delimiter)
	
	for match in string.gmatch(str, pattern) do
		table.insert(result, match)
	end
	
	return result
end

function GLDG.Utils:EscapeString(str)
	if not str then return "" end
	
	-- Escape special characters for pattern matching
	local escaped = string.gsub(str, "([^%w])", "%%%1")
	return escaped
end

function GLDG.Utils:CapitalizeString(str)
	if not str then return "" end
	
	return string.upper(string.sub(str, 1, 1)) .. string.lower(string.sub(str, 2))
end

-------------------------------
-- Time and Date Functions --
-------------------------------

function GLDG.Utils:GetTime()
	local currentTime = date("*t")
	return currentTime.hour, currentTime.min
end

function GLDG.Utils:FormatTime(timestamp)
	if not timestamp then return "" end
	
	return date("%H:%M:%S", timestamp)
end

function GLDG.Utils:GetTimeStamp()
	return GetTime()
end

function GLDG.Utils:TimeSince(timestamp)
	if not timestamp then return 0 end
	
	return GetTime() - timestamp
end

function GLDG.Utils:FormatDuration(seconds)
	if not seconds or seconds < 0 then return "0s" end
	
	local days = math.floor(seconds / 86400)
	local hours = math.floor((seconds % 86400) / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = math.floor(seconds % 60)
	
	if days > 0 then
		return string.format("%dd %dh %dm", days, hours, minutes)
	elseif hours > 0 then
		return string.format("%dh %dm %ds", hours, minutes, secs)
	elseif minutes > 0 then
		return string.format("%dm %ds", minutes, secs)
	else
		return string.format("%ds", secs)
	end
end

-------------------------------
-- Print and Messaging Functions --
-------------------------------

function GLDG.Utils:Print(message, color)
	if not message then return end
	
	local colorCode = color or "|cffffffff"
	local resetCode = "|r"
	
	print(colorCode .. tostring(message) .. resetCode)
end

function GLDG.Utils:PrintTable(tbl, indent)
	if not tbl then
		self:Print("nil")
		return
	end
	
	indent = indent or 0
	local spacing = string.rep("  ", indent)
	
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			self:Print(spacing .. tostring(k) .. " = {")
			self:PrintTable(v, indent + 1)
			self:Print(spacing .. "}")
		else
			self:Print(spacing .. tostring(k) .. " = " .. tostring(v))
		end
	end
end

function GLDG.Utils:DebugPrint(message, level)
	-- Only print debug messages if debug mode is enabled
	if GLDG_DEBUG_MODE then
		local prefix = ""
		if level then
			prefix = "[" .. string.upper(tostring(level)) .. "] "
		end
		self:Print("|cff888888" .. prefix .. tostring(message) .. "|r")
	end
end

-------------------------------
-- Color Utility Functions --
-------------------------------

function GLDG.Utils:HexToRGB(hex)
	if not hex then return 1, 1, 1, 1 end
	
	-- Remove the | and color prefix if present
	hex = string.gsub(hex, "|c[fF][fF]", "")
	hex = string.gsub(hex, "|r", "")
	
	if string.len(hex) == 6 then
		local r = tonumber(string.sub(hex, 1, 2), 16) / 255
		local g = tonumber(string.sub(hex, 3, 4), 16) / 255
		local b = tonumber(string.sub(hex, 5, 6), 16) / 255
		return 1, r, g, b
	elseif string.len(hex) == 8 then
		local a = tonumber(string.sub(hex, 1, 2), 16) / 255
		local r = tonumber(string.sub(hex, 3, 4), 16) / 255
		local g = tonumber(string.sub(hex, 5, 6), 16) / 255
		local b = tonumber(string.sub(hex, 7, 8), 16) / 255
		return a, r, g, b
	end
	
	return 1, 1, 1, 1
end

function GLDG.Utils:RGBToHex(r, g, b, a)
	r = math.floor((r or 1) * 255)
	g = math.floor((g or 1) * 255)
	b = math.floor((b or 1) * 255)
	a = math.floor((a or 1) * 255)
	
	return string.format("%02x%02x%02x%02x", a, r, g, b)
end

function GLDG.Utils:ColorText(text, colorCode)
	if not text then return "" end
	if not colorCode then return text end
	
	return colorCode .. text .. "|r"
end

-------------------------------
-- Player and Character Functions --
-------------------------------

function GLDG.Utils:GetPlayerGUID(playerName)
	if not playerName then return nil end
	
	if playerName == UnitName("player") then
		return UnitGUID("player")
	end
	
	-- For other players, we'd need to iterate through group members
	-- or use other methods to get their GUID
	return nil
end

function GLDG.Utils:GetPlayerClass(playerName)
	if not playerName then return nil end
	
	if playerName == UnitName("player") then
		return UnitClass("player")
	end
	
	-- Check if player is in guild
	if IsInGuild() then
		for i = 1, GetNumGuildMembers() do
			local name, _, _, _, _, _, _, _, _, _, class = GetGuildRosterInfo(i)
			if name == playerName then
				return class
			end
		end
	end
	
	return nil
end

function GLDG.Utils:IsPlayerOnline(playerName)
	if not playerName then return false end
	
	if playerName == UnitName("player") then
		return true
	end
	
	-- Check guild roster
	if IsInGuild() then
		for i = 1, GetNumGuildMembers() do
			local name, _, _, _, _, _, _, _, isOnline = GetGuildRosterInfo(i)
			if name == playerName then
				return isOnline
			end
		end
	end
	
	-- Check friends list
	for i = 1, C_FriendList.GetNumFriends() do
		local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
		if friendInfo and friendInfo.name == playerName then
			return friendInfo.connected
		end
	end
	
	return false
end

-------------------------------
-- Validation Functions --
-------------------------------

function GLDG.Utils:IsValidPlayerName(name)
	if not name or name == "" then return false end
	
	-- Check for valid character name pattern
	-- Names should be 2-12 characters, letters only, first letter uppercase
	local pattern = "^[A-Z][a-z][a-z]+$"
	local shortName = string.split("-", name) -- Remove realm
	
	return string.match(shortName, pattern) ~= nil and string.len(shortName) >= 2 and string.len(shortName) <= 12
end

function GLDG.Utils:IsValidGuildName(name)
	if not name or name == "" then return false end
	
	-- Guild names can contain spaces and have different rules
	return string.len(name) >= 2 and string.len(name) <= 24
end

function GLDG.Utils:IsValidColorCode(colorCode)
	if not colorCode then return false end
	
	-- Check for valid WoW color code format
	local pattern = "^|c[fF][fF][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]"
	return string.match(colorCode, pattern) ~= nil
end

-------------------------------
-- Configuration Helpers --
-------------------------------

function GLDG.Utils:GetSetting(settingPath, default)
	if not settingPath then return default end
	
	local keys = self:SplitString(settingPath, ".")
	local value = GLDG_Data
	
	for _, key in ipairs(keys) do
		if value and type(value) == "table" and value[key] ~= nil then
			value = value[key]
		else
			return default
		end
	end
	
	return value
end

function GLDG.Utils:SetSetting(settingPath, value)
	if not settingPath then return false end
	
	local keys = self:SplitString(settingPath, ".")
	local current = GLDG_Data
	
	-- Navigate to the parent table
	for i = 1, #keys - 1 do
		local key = keys[i]
		if not current[key] or type(current[key]) ~= "table" then
			current[key] = {}
		end
		current = current[key]
	end
	
	-- Set the final value
	current[keys[#keys]] = value
	return true
end

-------------------------------
-- Channel and Communication --
-------------------------------

function GLDG.Utils:SendAddonMessage(prefix, message, distribution, target)
	if not prefix or not message then return false end
	
	-- Ensure we're not sending messages too frequently
	local now = GetTime()
	if not self.lastMessageTime then self.lastMessageTime = 0 end
	
	if now - self.lastMessageTime < 0.1 then -- Throttle to 10 messages per second
		return false
	end
	
	self.lastMessageTime = now
	
	distribution = distribution or "GUILD"
	
	C_ChatInfo.SendAddonMessage(prefix, message, distribution, target)
	return true
end

function GLDG.Utils:GetChannelNumber(channelName)
	if not channelName then return nil end
	
	local channelList = { GetChannelList() }
	for i = 1, #channelList, 2 do
		local name = channelList[i + 1]
		if name and string.lower(name) == string.lower(channelName) then
			return channelList[i]
		end
	end
	
	return nil
end

-------------------------------
-- Math and Calculation Functions --
-------------------------------

function GLDG.Utils:Round(number, decimals)
	if not number then return 0 end
	decimals = decimals or 0
	
	local multiplier = 10^decimals
	return math.floor(number * multiplier + 0.5) / multiplier
end

function GLDG.Utils:Clamp(value, min, max)
	if not value then return min end
	if value < min then return min end
	if value > max then return max end
	return value
end

function GLDG.Utils:Lerp(start, finish, percent)
	if not start or not finish or not percent then return start end
	return start + (finish - start) * percent
end

-------------------------------
-- Random Utilities --
-------------------------------

function GLDG.Utils:RandomChoice(options)
	if not options or type(options) ~= "table" or #options == 0 then
		return nil
	end
	
	return options[math.random(#options)]
end

function GLDG.Utils:Shuffle(array)
	if not array or type(array) ~= "table" then return array end
	
	local shuffled = self:TableCopy(array)
	for i = #shuffled, 2, -1 do
		local j = math.random(i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end
	
	return shuffled
end

-------------------------------
-- File and Path Utilities --
-------------------------------

function GLDG.Utils:GetFileExtension(filename)
	if not filename then return "" end
	
	local ext = string.match(filename, "%.([^%.]+)$")
	return ext or ""
end

function GLDG.Utils:StripFileExtension(filename)
	if not filename then return "" end
	
	return string.match(filename, "(.+)%.[^%.]+$") or filename
end

-------------------------------
-- Error Handling --
-------------------------------

function GLDG.Utils:SafeCall(func, ...)
	if not func or type(func) ~= "function" then
		return false, "Invalid function"
	end
	
	local success, result = pcall(func, ...)
	if not success then
		self:DebugPrint("Error in SafeCall: " .. tostring(result), "error")
		return false, result
	end
	
	return true, result
end

function GLDG.Utils:TryCatch(tryFunc, catchFunc)
	local success, result = self:SafeCall(tryFunc)
	if not success and catchFunc then
		return self:SafeCall(catchFunc, result)
	end
	return success, result
end

-- Global functions for backwards compatibility
function GLDG_TableSize(table)
	return GLDG.Utils:TableSize(table)
end

function GLDG_GetWords(str)
	return GLDG.Utils:GetWords(str)
end

function GLDG.Utils:UpdatePlayerCheckboxes()
	local name = GLDG_GUI.."Players"
	_G[name.."IgnoreBox"]:SetChecked(GLDG_Data.ShowIgnore)
	_G[name.."AltBox"]:SetChecked(GLDG_Data.ShowAlt)
	_G[name.."Alt2Box"]:SetChecked(GLDG_Data.GroupAlt)
	_G[name.."UnassignedBox"]:SetChecked(GLDG_Data.FilterUnassigned)
	_G[name.."OnlineBox"]:SetChecked(GLDG_Data.FilterOnline)
	_G[name.."MyFriendsBox"]:SetChecked(GLDG_Data.FilterMyFriends)
	_G[name.."WithFriendsBox"]:SetChecked(GLDG_Data.FilterWithFriends)
	_G[name.."CurrentChannelBox"]:SetChecked(GLDG_Data.FilterCurrentChannel)
	_G[name.."WithChannelBox"]:SetChecked(GLDG_Data.FilterWithChannel)
	_G[name.."WARRIORFilterBox"]:SetChecked(GLDG_Data.WARRIORFilter)
	_G[name.."DEATHKNIGHTFilterBox"]:SetChecked(GLDG_Data.DEATHKNIGHTFilter)
	_G[name.."DRUIDFilterBox"]:SetChecked(GLDG_Data.DRUIDFilter)
	_G[name.."HUNTERFilterBox"]:SetChecked(GLDG_Data.HUNTERFilter)
	_G[name.."MAGEFilterBox"]:SetChecked(GLDG_Data.MAGEFilter)
	_G[name.."PALADINFilterBox"]:SetChecked(GLDG_Data.PALADINFilter)
	_G[name.."PRIESTFilterBox"]:SetChecked(GLDG_Data.PRIESTFilter)
	_G[name.."ROGUEFilterBox"]:SetChecked(GLDG_Data.ROGUEFilter)
	_G[name.."SHAMANFilterBox"]:SetChecked(GLDG_Data.SHAMANFilter)
	_G[name.."DEMONHUNTERFilterBox"]:SetChecked(GLDG_Data.DEMONHUNTERFilter)
	_G[name.."WARLOCKFilterBox"]:SetChecked(GLDG_Data.WARLOCKFilter)
	_G[name.."MONKFilterBox"]:SetChecked(GLDG_Data.MONKFilter)
	_G[name.."EVOKERFilterBox"]:SetChecked(GLDG_Data.EVOKERFilter)

	if (GLDG_Data.FilterOnline==true or GLDG_Data.GuildSort==true) then
		_G[name.."Alt2Box"]:Disable()
	else
		_G[name.."Alt2Box"]:Enable()
	end
end

function GLDG.Utils:InitFull()
	if not GLDG_Data.GuildSettings then GLDG_Data.GuildSettings = {} end

	if GLDG_Data[GLDG_unique_GuildName] then
	-- convert for API 6.0.2 begin
		if GLDG_Data[GLDG_unique_GuildName].GreetAsMain==1 then GLDG_Data[GLDG_unique_GuildName].GreetAsMain=true end
		if GLDG_Data[GLDG_unique_GuildName].Randomize==1 then GLDG_Data[GLDG_unique_GuildName].Randomize=true end
		if GLDG_Data[GLDG_unique_GuildName].Whisper==1 then GLDG_Data[GLDG_unique_GuildName].Whisper=true end
		if GLDG_Data[GLDG_unique_GuildName].WhisperLevelup==1 then GLDG_Data[GLDG_unique_GuildName].WhisperLevelup=true end
		if GLDG_Data[GLDG_unique_GuildName].IncludeOwn==1 then GLDG_Data[GLDG_unique_GuildName].IncludeOwn=true end
		if GLDG_Data[GLDG_unique_GuildName].AutoAssign==1 then GLDG_Data[GLDG_unique_GuildName].AutoAssign=true end
		if GLDG_Data[GLDG_unique_GuildName].AutoAssignEgp==1 then GLDG_Data[GLDG_unique_GuildName].AutoAssignEgp=true end
		if GLDG_Data[GLDG_unique_GuildName].AutoAssignAlias==1 then GLDG_Data[GLDG_unique_GuildName].AutoAssignAlias=true end
		if GLDG_Data[GLDG_unique_GuildName].ListNames==1 then GLDG_Data[GLDG_unique_GuildName].ListNames=true end
		if GLDG_Data[GLDG_unique_GuildName].ListNamesOff==1 then GLDG_Data[GLDG_unique_GuildName].ListNamesOff=true end
		if GLDG_Data[GLDG_unique_GuildName].ListLevelUp==1 then GLDG_Data[GLDG_unique_GuildName].ListLevelUp=true end
		if GLDG_Data[GLDG_unique_GuildName].ListLevelUpOff==1 then GLDG_Data[GLDG_unique_GuildName].ListLevelUpOff=true end
		if GLDG_Data[GLDG_unique_GuildName].ListAchievments==1 then GLDG_Data[GLDG_unique_GuildName].ListAchievments=true end
		if GLDG_Data[GLDG_unique_GuildName].ListQuit==1 then GLDG_Data[GLDG_unique_GuildName].ListQuit=true end
		if GLDG_Data[GLDG_unique_GuildName].ExtendChat==1 then GLDG_Data[GLDG_unique_GuildName].ExtendChat=true end
		if GLDG_Data[GLDG_unique_GuildName].ExtendIgnored==1 then GLDG_Data[GLDG_unique_GuildName].ExtendIgnored=true end
		if GLDG_Data[GLDG_unique_GuildName].ExtendMain==1 then GLDG_Data[GLDG_unique_GuildName].ExtendMain=true end
		if GLDG_Data[GLDG_unique_GuildName].ExtendAlias==1 then GLDG_Data[GLDG_unique_GuildName].ExtendAlias=true end
		if GLDG_Data[GLDG_unique_GuildName].AddPostfix==1 then GLDG_Data[GLDG_unique_GuildName].AddPostfix=true end
		if GLDG_Data[GLDG_unique_GuildName].ShowWhoSpam==1 then GLDG_Data[GLDG_unique_GuildName].ShowWhoSpam=true end
		if GLDG_Data[GLDG_unique_GuildName].SupressGreet==1 then GLDG_Data[GLDG_unique_GuildName].SupressGreet=true end
		if GLDG_Data[GLDG_unique_GuildName].SupressJoin==1 then GLDG_Data[GLDG_unique_GuildName].SupressJoin=true end
		if GLDG_Data[GLDG_unique_GuildName].SupressLevel==1 then GLDG_Data[GLDG_unique_GuildName].SupressLevel=true end
		if GLDG_Data[GLDG_unique_GuildName].SupressRank==1 then GLDG_Data[GLDG_unique_GuildName].SupressRank=true end
		if GLDG_Data[GLDG_unique_GuildName].SupressAchievment==1 then GLDG_Data[GLDG_unique_GuildName].SupressAchievment=true end
		if GLDG_Data[GLDG_unique_GuildName].NoGratsOnLogin==1 then GLDG_Data[GLDG_unique_GuildName].NoGratsOnLogin=true end
		if GLDG_Data[GLDG_unique_GuildName].DeltaPopup==1 then GLDG_Data[GLDG_unique_GuildName].DeltaPopup=true end
		if GLDG_Data[GLDG_unique_GuildName].RelogTime==1 then GLDG_Data[GLDG_unique_GuildName].RelogTime=true end
		if GLDG_Data[GLDG_unique_GuildName].MinLevelUp==1 then GLDG_Data[GLDG_unique_GuildName].MinLevelUp=true end
		if GLDG_Data[GLDG_unique_GuildName].UseGuildDefault==1 then	GLDG_Data[GLDG_unique_GuildName].UseGuildDefault=true end
	-- convert for API 6.0.2 end
		GLDG_Data.GuildSettings.GreetAsMain = GLDG_Data[GLDG_unique_GuildName].GreetAsMain
		GLDG_Data.GuildSettings.Randomize = GLDG_Data[GLDG_unique_GuildName].Randomize
		GLDG_Data.GuildSettings.Whisper = GLDG_Data[GLDG_unique_GuildName].Whisper
		GLDG_Data.GuildSettings.WhisperLevelup = GLDG_Data[GLDG_unique_GuildName].WhisperLevelup
		GLDG_Data.GuildSettings.IncludeOwn = GLDG_Data[GLDG_unique_GuildName].IncludeOwn
		GLDG_Data.GuildSettings.AutoAssign = GLDG_Data[GLDG_unique_GuildName].AutoAssign
		GLDG_Data.GuildSettings.AutoAssignEgp = GLDG_Data[GLDG_unique_GuildName].AutoAssignEgp
		GLDG_Data.GuildSettings.AutoAssignAlias = GLDG_Data[GLDG_unique_GuildName].AutoAssignAlias
		GLDG_Data.GuildSettings.ListNames = GLDG_Data[GLDG_unique_GuildName].ListNames
		GLDG_Data.GuildSettings.ListNamesOff = GLDG_Data[GLDG_unique_GuildName].ListNamesOff
		GLDG_Data.GuildSettings.ListLevelUp = GLDG_Data[GLDG_unique_GuildName].ListLevelUp
		GLDG_Data.GuildSettings.ListLevelUpOff = GLDG_Data[GLDG_unique_GuildName].ListLevelUpOff
		GLDG_Data.GuildSettings.ListAchievments = GLDG_Data[GLDG_unique_GuildName].ListAchievments
		GLDG_Data.GuildSettings.ListQuit = GLDG_Data[GLDG_unique_GuildName].ListQuit
		GLDG_Data.GuildSettings.ExtendChat = GLDG_Data[GLDG_unique_GuildName].ExtendChat
		GLDG_Data.GuildSettings.ExtendIgnored = GLDG_Data[GLDG_unique_GuildName].ExtendIgnored
		GLDG_Data.GuildSettings.ExtendMain = GLDG_Data[GLDG_unique_GuildName].ExtendMain
		GLDG_Data.GuildSettings.ExtendAlias = GLDG_Data[GLDG_unique_GuildName].ExtendAlias
		GLDG_Data.GuildSettings.AddPostfix = GLDG_Data[GLDG_unique_GuildName].AddPostfix
		GLDG_Data.GuildSettings.ShowWhoSpam = GLDG_Data[GLDG_unique_GuildName].ShowWhoSpam
		GLDG_Data.GuildSettings.SupressGreet = GLDG_Data[GLDG_unique_GuildName].SupressGreet
		GLDG_Data.GuildSettings.SupressJoin = GLDG_Data[GLDG_unique_GuildName].SupressJoin
		GLDG_Data.GuildSettings.SupressLevel = GLDG_Data[GLDG_unique_GuildName].SupressLevel
		GLDG_Data.GuildSettings.SupressRank = GLDG_Data[GLDG_unique_GuildName].SupressRank
		GLDG_Data.GuildSettings.SupressAchievment = GLDG_Data[GLDG_unique_GuildName].SupressAchievment
		GLDG_Data.GuildSettings.NoGratsOnLogin = GLDG_Data[GLDG_unique_GuildName].NoGratsOnLogin
		GLDG_Data.GuildSettings.DeltaPopup = GLDG_Data[GLDG_unique_GuildName].DeltaPopup
		GLDG_Data.GuildSettings.RelogTime = GLDG_Data[GLDG_unique_GuildName].RelogTime
		GLDG_Data.GuildSettings.MinLevelUp = GLDG_Data[GLDG_unique_GuildName].MinLevelUp
		GLDG_Data.GuildSettings.UseGuildDefault = GLDG_Data[GLDG_unique_GuildName].UseGuildDefault
	end


	if not GLDG_Data.GuildSettings.RelogTime then GLDG_Data.GuildSettings.RelogTime = 2 end
	if not GLDG_Data.GuildSettings.MinLevelUp then GLDG_Data.GuildSettings.MinLevelUp = 0 end
	GLDG_Data.UpdateTime = 0
	if not GLDG_Data.GuildSettings.UseGuildDefault then GLDG_Data.GuildSettings.UseGuildDefault = false end
	if not GLDG_Data.ListSize then GLDG_Data.ListSize = 5 end
	if not GLDG_Data.PlayerChatFrame then GLDG_Data.PlayerChatFrame = {} end
	if not GLDG_Data.PlayerChatFrame[GLDG.Player.."-"..GLDG.Realm] then GLDG_Data.PlayerChatFrame[GLDG.Player.."-"..GLDG.Realm] = 0 end

	if not GLDG_Data.Greet then GLDG_Data.Greet = GLDG_GREET end
	if not GLDG_Data.GreetBack then GLDG_Data.GreetBack = GLDG_GREETBACK end
	if not GLDG_Data.Welcome then GLDG_Data.Welcome = GLDG_WELCOME end
	if not GLDG_Data.NewRank then GLDG_Data.NewRank = GLDG_RANK end
	if not GLDG_Data.NewLevel then GLDG_Data.NewLevel = GLDG_LEVEL end
	if not GLDG_Data.Bye then GLDG_Data.Bye = GLDG_BYE end
	if not GLDG_Data.Night then GLDG_Data.Night = GLDG_NIGHT end
	if not GLDG_Data.Guild then GLDG_Data.Guild = GLDG_GUILD end
	if not GLDG_Data.Channel then GLDG_Data.Channel = GLDG_CHANNEL end
	if not GLDG_Data.ByeGuild then GLDG_Data.ByeGuild = GLDG_BYE_GUILD end
	if not GLDG_Data.NightGuild then GLDG_Data.NightGuild = GLDG_NIGHT_GUILD end
	if not GLDG_Data.ByeChannel then GLDG_Data.ByeChannel = GLDG_BYE_CHANNEL end
	if not GLDG_Data.NightChannel then GLDG_Data.NightChannel = GLDG_NIGHT_CHANNEL end
	if not GLDG_Data.LaterGuild then GLDG_Data.LaterGuild = GLDG_LATER_GUILD end
	if not GLDG_Data.LaterChannel then GLDG_Data.LaterChannel = GLDG_LATER_CHANNEL end
	if not GLDG_Data.Achievment then GLDG_Data.Achievment = GLDG_ACHIEVMENT end

	if not GLDG_Data.Collections then GLDG_Data.Collections = {} end
	if not GLDG_Data.Custom then GLDG_Data.Custom = {} end
	if not GLDG_Data.Ranks then GLDG_Data.Ranks = {} end

	if not GLDG_Data.ChannelNames then GLDG_Data.ChannelNames = {} end
	if not GLDG_Data.Frameopts then GLDG_Data.Frameopts = {} end
	if not GLDG_Data.GuildAlias then GLDG_Data.GuildAlias = {} end

	if not GLDG_Data.CheckedGuildAlert then GLDG_Data.CheckedGuildAlert = false end

	if not GLDG_Data.GuildSettings.GreetAsMain	then GLDG_Data.GuildSettings.GreetAsMain = false end
	if not GLDG_Data.GuildSettings.Randomize	then GLDG_Data.GuildSettings.Randomize = false end
	if not GLDG_Data.GuildSettings.Whisper    	then GLDG_Data.GuildSettings.Whisper = false end
	if not GLDG_Data.GuildSettings.WhisperLevelup then GLDG_Data.GuildSettings.WhisperLevelup = false end
	if not GLDG_Data.GuildSettings.IncludeOwn 	then GLDG_Data.GuildSettings.IncludeOwn = false end
	if not GLDG_Data.GuildSettings.ListNames  	then GLDG_Data.GuildSettings.ListNames = false end
	if not GLDG_Data.GuildSettings.ListNamesOff	then GLDG_Data.GuildSettings.ListNamesOff = false end
	if not GLDG_Data.GuildSettings.ListLevelUp	then GLDG_Data.GuildSettings.ListLevelUp = false end
	if not GLDG_Data.GuildSettings.ListLevelUpOff	then GLDG_Data.GuildSettings.ListLevelUpOff = false end
	if not GLDG_Data.GuildSettings.ListQuit	then GLDG_Data.GuildSettings.ListQuit = false end
	if not GLDG_Data.GuildSettings.ExtendChat	then GLDG_Data.GuildSettings.ExtendChat = false end
	if not GLDG_Data.GuildSettings.ExtendIgnored	then GLDG_Data.GuildSettings.ExtendIgnored = false end
	if not GLDG_Data.GuildSettings.ExtendAlias	then GLDG_Data.GuildSettings.ExtendAlias = false end
	if not GLDG_Data.GuildSettings.ExtendMain	then GLDG_Data.GuildSettings.ExtendMain = false end
	if not GLDG_Data.GuildSettings.AutoAssign	then GLDG_Data.GuildSettings.AutoAssign = false end
	if not GLDG_Data.GuildSettings.AutoAssignEgp	then GLDG_Data.GuildSettings.AutoAssignEgp = false end
	if not GLDG_Data.GuildSettings.AutoAssignAlias	then GLDG_Data.GuildSettings.AutoAssignAlias = false end
	if not GLDG_Data.UseFriends 	then GLDG_Data.UseFriends = false end
	if not GLDG_Data.ListUp     	then GLDG_Data.ListUp = false end
	if not GLDG_Data.ListVisible	then GLDG_Data.ListVisible = false end
	if not GLDG_Data.GuildSettings.AddPostfix	then GLDG_Data.GuildSettings.AddPostfix = false end
	if not GLDG_Data.GuildSettings.ShowWhoSpam	then GLDG_Data.GuildSettings.ShowWhoSpam = false end
	if not GLDG_Data.GuildSettings.ListAchievments then GLDG_Data.GuildSettings.ListAchievments = false end
	-- convert for API 6.0.2 begin
		if GLDG_Data.GuildSettings.GreetAsMain==1 then GLDG_Data.GuildSettings.GreetAsMain=true end
		if GLDG_Data.GuildSettings.Randomize==1 then GLDG_Data.GuildSettings.Randomize=true end
		if GLDG_Data.GuildSettings.Whisper==1 then GLDG_Data.GuildSettings.Whisper=true end
		if GLDG_Data.GuildSettings.WhisperLevelup==1 then GLDG_Data.GuildSettings.WhisperLevelup=true end
		if GLDG_Data.GuildSettings.IncludeOwn==1 then GLDG_Data.GuildSettings.IncludeOwn=true end
		if GLDG_Data.GuildSettings.AutoAssign==1 then GLDG_Data.GuildSettings.AutoAssign=true end
		if GLDG_Data.GuildSettings.AutoAssignEgp==1 then GLDG_Data.GuildSettings.AutoAssignEgp=true end
		if GLDG_Data.GuildSettings.AutoAssignAlias==1 then GLDG_Data.GuildSettings.AutoAssignAlias=true end
		if GLDG_Data.GuildSettings.ListNames==1 then GLDG_Data.GuildSettings.ListNames=true end
		if GLDG_Data.GuildSettings.ListNamesOff==1 then GLDG_Data.GuildSettings.ListNamesOff=true end
		if GLDG_Data.GuildSettings.ListLevelUp==1 then GLDG_Data.GuildSettings.ListLevelUp=true end
		if GLDG_Data.GuildSettings.ListLevelUpOff==1 then GLDG_Data.GuildSettings.ListLevelUpOff=true end
		if GLDG_Data.GuildSettings.ListAchievments==1 then GLDG_Data.GuildSettings.ListAchievments=true end
		if GLDG_Data.GuildSettings.ListQuit==1 then GLDG_Data.GuildSettings.ListQuit=true end
		if GLDG_Data.GuildSettings.ExtendChat==1 then GLDG_Data.GuildSettings.ExtendChat=true end
		if GLDG_Data.GuildSettings.ExtendIgnored==1 then GLDG_Data.GuildSettings.ExtendIgnored=true end
		if GLDG_Data.GuildSettings.ExtendMain==1 then GLDG_Data.GuildSettings.ExtendMain=true end
		if GLDG_Data.GuildSettings.ExtendAlias==1 then GLDG_Data.GuildSettings.ExtendAlias=true end
		if GLDG_Data.GuildSettings.AddPostfix==1 then GLDG_Data.GuildSettings.AddPostfix=true end
		if GLDG_Data.GuildSettings.ShowWhoSpam==1 then GLDG_Data.GuildSettings.ShowWhoSpam=true end
		if GLDG_Data.GuildSettings.SupressGreet==1 then GLDG_Data.GuildSettings.SupressGreet=true end
		if GLDG_Data.GuildSettings.SupressJoin==1 then GLDG_Data.GuildSettings.SupressJoin=true end
		if GLDG_Data.GuildSettings.SupressLevel==1 then GLDG_Data.GuildSettings.SupressLevel=true end
		if GLDG_Data.GuildSettings.SupressRank==1 then GLDG_Data.GuildSettings.SupressRank=true end
		if GLDG_Data.GuildSettings.SupressAchievment==1 then GLDG_Data.GuildSettings.SupressAchievment=true end
		if GLDG_Data.GuildSettings.NoGratsOnLogin==1 then GLDG_Data.GuildSettings.NoGratsOnLogin=true end
		if GLDG_Data.GuildSettings.DeltaPopup==1 then GLDG_Data.GuildSettings.DeltaPopup=true end
		if GLDG_Data.GuildSettings.RelogTime==1 then GLDG_Data.GuildSettings.RelogTime=true end
		if GLDG_Data.GuildSettings.MinLevelUp==1 then GLDG_Data.GuildSettings.MinLevelUp=true end
		if GLDG_Data.GuildSettings.UseGuildDefault==1 then	GLDG_Data.GuildSettings.UseGuildDefault=true end
	-- convert for API 6.0.2 end

	if not GLDG_Data.GreetGuild	then GLDG_Data.GreetGuild = {} end
	if not GLDG_Data.GreetChannel	then GLDG_Data.GreetChannel = {} end
	if not GLDG_Data.AutoGreet	then GLDG_Data.AutoGreet = {} end

	if not GLDG_Data.GuildSettings.SupressGreet		then GLDG_Data.GuildSettings.SupressGreet = false end
	if not GLDG_Data.GuildSettings.SupressJoin		then GLDG_Data.GuildSettings.SupressJoin = false end
	if not GLDG_Data.GuildSettings.SupressLevel		then GLDG_Data.GuildSettings.SupressLevel = false end
	if not GLDG_Data.GuildSettings.SupressRank		then GLDG_Data.GuildSettings.SupressRank = false end
	if not GLDG_Data.GuildSettings.SupressAchievment	then GLDG_Data.GuildSettings.SupressAchievment = false end
	if not GLDG_Data.GuildSettings.SupressNoGratsOnLogin		then GLDG_Data.GuildSettings.NoGratsOnLogin = false end

	if not GLDG_Data.UseLocalTime		then GLDG_Data.UseLocalTime = false end
	if not GLDG.db.profile.ShowNewerVersions	then GLDG.db.profile.ShowNewerVersions = false end
	if not GLDG_Data.AutoWho		then GLDG_Data.AutoWho = false end
	if not GLDG_Data.GuildSettings.DeltaPopup		then GLDG_Data.GuildSettings.DeltaPopup = false end
	if not GLDG.db.profile.ExtendPlayerMenu then GLDG.db.profile.ExtendPlayerMenu = false end
	-- convert for API 6.0.2 begin
	if GLDG_Data.GuildSettings.SupressGreet==1		then GLDG_Data.GuildSettings.SupressGreet = true end
	if GLDG_Data.GuildSettings.SupressJoin==1		then GLDG_Data.GuildSettings.SupressJoin = true end
	if GLDG_Data.GuildSettings.SupressLevel==1		then GLDG_Data.GuildSettings.SupressLevel = true end
	if GLDG_Data.GuildSettings.SupressRank==1		then GLDG_Data.GuildSettings.SupressRank = true end
	if GLDG_Data.GuildSettings.SupressAchievment==1	then GLDG_Data.GuildSettings.SupressAchievment = true end
	if GLDG_Data.GuildSettings.NoGratsOnLogin==1		then GLDG_Data.GuildSettings.NoGratsOnLogin = true end

	if GLDG_Data.UseLocalTime==1		then GLDG_Data.UseLocalTime = true end
	if GLDG.db.profile.ShowNewerVersions==1	then GLDG.db.profile.ShowNewerVersions = true end
	if GLDG_Data.AutoWho==1		then GLDG_Data.AutoWho = true end
	if GLDG_Data.GuildSettings.DeltaPopup==1		then GLDG_Data.GuildSettings.DeltaPopup = true end
	if GLDG.db.profile.ExtendPlayerMenu==1 then GLDG.db.profile.ExtendPlayerMenu = true end
	-- convert for API 6.0.2 end

	if not GLDG_Data.GuildFilter or GLDG_Data.GuildFilter==nil or GLDG_Data.GuildFilter==1 or GLDG_Data.GuildFilter==true then GLDG_Data.GuildFilter = "" end
	if not GLDG_Data.RankFilter	then GLDG_Data.RankFilter = "" end
	GLDG_Data.FilterGuild = false
	GLDG_Data.GuildSort = false
	if not GLDG_Data.ShowIgnore then GLDG_Data.ShowIgnore = false end
	if not GLDG_Data.ShowAlt then GLDG_Data.ShowAlt = false end
	if not GLDG_Data.GroupAlt then GLDG_Data.GroupAlt = false end
	if not GLDG_Data.FilterUnassigned then GLDG_Data.FilterUnassigned = false end
	if not GLDG_Data.FilterOnline then GLDG_Data.FilterOnline = false end
	if not GLDG_Data.FilterMyFriends then GLDG_Data.FilterMyFriends = false end
	if not GLDG_Data.FilterWithFriends then GLDG_Data.FilterWithFriends = false end
	if not GLDG_Data.FilterCurrentChannel then GLDG_Data.FilterCurrentChannel = false end
	if not GLDG_Data.FilterWithChannel then GLDG_Data.FilterWithChannel = false end
	if GLDG_Data.WARRIORFilter == nil then GLDG_Data.WARRIORFilter = true end
	if GLDG_Data.DEATHKNIGHTFilter == nil then GLDG_Data.DEATHKNIGHTFilter = true end
	if GLDG_Data.DRUIDFilter == nil then GLDG_Data.DRUIDFilter = true end
	if GLDG_Data.HUNTERFilter == nil then GLDG_Data.HUNTERFilter = true end
	if GLDG_Data.MAGEFilter == nil then GLDG_Data.MAGEFilter = true end
	if GLDG_Data.PALADINFilter == nil then GLDG_Data.PALADINFilter = true end
	if GLDG_Data.PRIESTFilter == nil then GLDG_Data.PRIESTFilter = true end
	if GLDG_Data.ROGUEFilter == nil then GLDG_Data.ROGUEFilter = true end
	if GLDG_Data.SHAMANFilter == nil then GLDG_Data.SHAMANFilter = true end
	if GLDG_Data.DEMONHUNTERFilter == nil then GLDG_Data.DEMONHUNTERFilter = true end
	if GLDG_Data.WARLOCKFilter == nil then GLDG_Data.WARLOCKFilter = true end
	if GLDG_Data.MONKFilter == nil then GLDG_Data.MONKFilter = true end
	if GLDG_Data.EVOKERFilter == nil then GLDG_Data.EVOKERFilter = true end

	if GLDG_Data.ShowIgnore == 1 then GLDG_Data.ShowIgnore = true end
	if GLDG_Data.ShowAlt == 1 then GLDG_Data.ShowAlt = true end
	if GLDG_Data.GroupAlt == 1 then GLDG_Data.GroupAlt = true end
	if GLDG_Data.FilterUnassigned == 1 then GLDG_Data.FilterUnassigned = true end
	if GLDG_Data.FilterOnline == 1 then GLDG_Data.FilterOnline = true end
	if GLDG_Data.FilterMyFriends == 1 then GLDG_Data.FilterMyFriends = true end
	if GLDG_Data.FilterWithFriends == 1 then GLDG_Data.FilterWithFriends = true end
	if GLDG_Data.FilterCurrentChannel == 1 then GLDG_Data.FilterCurrentChannel = true end
	if GLDG_Data.FilterWithChannel == 1 then GLDG_Data.FilterWithChannel = true end

	-- Color initialization is now handled by the Colors Library
	-- Legacy color migration will be done automatically


	-- Set initial pointers to avoid errors (hack!)
	GLDG_DataChar = {}
	GLDG_DataGreet = {}

	GLDG_ChannelName = ""

	-- Keep version in configuration file
--	GLDG_Data.Version = GDLG_VNMBR

	-- Prepare popup dialogs
	GLDG_PrepareReloadQuestion()
	GLDG_PrepareAlertQuestion()

	-- Initialize the list GUI (disabled - using new AceGUI system)
	-- _G[GLDG_LIST.."TitleText"]:SetText(GLDG_NAME.." "..version)

	-- Initialize new AceGUI system
	if GuildGreet.gui then
		GuildGreet.gui:InitializeAll()
	end
	--	local frameName = GLDG_Tab2Frame["Tab"..tabNum]
	--	if frameName then
	--		local label = L["Tab"..frameName]
	--		if label then
	--			-- tab has label: initialize frame
	--			tab:SetText(label)
	--			tab:Show()
	--			GLDG_InitFrame(frameName)
	--		end
	--	end
	-- end

	-- Initialize subtabs and set the first one active (disabled - using new AceGUI system)
	-- local frame = _G[GLDG_GUI.."Settings"]
	-- PanelTemplates_SetNumTabs(frame, GLDG_TableSize(GLDG_SubTab2Frame))
	-- PanelTemplates_SetTab(frame, 1)

	-- Set subtab names and initialize tabframes (disabled - using new AceGUI system)

	GLDG_InitComplete = true

	GLDG_InitCheck = 0
end

function GLDG_UpdatePlayerCheckboxes()
	GLDG.Utils:UpdatePlayerCheckboxes()
end

function GLDG_GetTime()
	return GLDG.Utils:GetTime()
end

function GLDG_Print(message, color)
	GLDG.Utils:Print(message, color)
end

-- Command processing and slash commands
function GLDG.Utils:SlashHandler(msg)
	if not msg then
		_G[GLDG_GUI]:Show()
	else
		local msgLower = string.lower(msg)
		local words = GLDG_GetWords(msg)
		local wordsLower = GLDG_GetWords(msgLower)
		local size = GLDG_TableSize(wordsLower)

		if (size>0) then
			if (wordsLower[0]=="force") then
				GLDG_ForceChatlist()
			elseif (wordsLower[0]=="clear") then
				GLDG_ClearList()
			elseif (wordsLower[0]=="char") then
				if (size>1) then
					if (wordsLower[1]=="show") then
						GLDG_ListAllPlayers(false, true)		-- include_offline=false, print=true, guildOnly=false
					elseif (wordsLower[1]=="all") then
						GLDG_ListAllPlayers(true, true)			-- include_offline=true, print=true, guildOnly=false
					elseif (wordsLower[1]=="list") then
						GLDG:PrintHelp(L["Pasting to list"]);
						GLDG_list = GLDG_ListAllPlayers(true, false);	-- include_offline=true, print=false, guildOnly=false
						GLDG_PasteList.List:Show();
					else
						GLDG:HandleError(L["Could not parse command"], msgLower)
					end
				else
					GLDG_ListAllPlayers(false, true)			-- include_offline=false, print=true, guildOnly=false
				end
			elseif (wordsLower[0]=="guild") then
				if (size>1) then
					if (wordsLower[1]=="show") then
						GLDG_ListAllPlayers(false, true, true)			-- include_offline=false, print=true, guildOnly=true
					elseif (wordsLower[1]=="all") then
						GLDG_ListAllPlayers(true, true, true)			-- include_offline=true, print=true, guildOnly=true
					elseif (wordsLower[1]=="list") then
						GLDG:PrintHelp(L["Pasting to list"]);
						GLDG_list = GLDG_ListAllPlayers(true, false, true);	-- include_offline=true, print=true, guildOnly=true
						GLDG_PasteList.List:Show();
					else
						GLDG:PrintHelp(L["Could not parse command"].." ["..(GLDG:GetColors().help or "")..msgLower.."|r]")
						GLDG_Help()
					end
				else
					GLDG_ListAllPlayers(false, true, true)				-- include_offline=false, print=true, guildOnly=true
				end

			elseif (wordsLower[0]=="show") then
				if (size>1) then
					GLDG_ListForPlayer(words[1], false)
				else
					GLDG:PrintHelp(L["Another argument is needed after command"].." ["..(GLDG:GetColors().help or "")..wordsLower[0].."|r]")
					GLDG_Help()
				end
			elseif (wordsLower[0]=="full") then
				if (size>1) then
					GLDG_ListForPlayer(words[1], true)
				else
					GLDG:PrintHelp(L["Another argument is needed after command"].." ["..(GLDG:GetColors().help or "")..wordsLower[0].."|r]")
					GLDG_Help()
				end

			elseif (wordsLower[0]=="detail") then
				if (size>1) then
					GLDG_ShowDetails(words[1])
				else
					GLDG:PrintHelp(L["Another argument is needed after command"].." ["..(GLDG:GetColors().help or "")..wordsLower[0].."|r]")
					GLDG_Help()
				end

			elseif (wordsLower[0]=="greet") then
				if (size>1) then
					if (wordsLower[1]=="guild") then
						GLDG_GreetGuild()
					elseif (wordsLower[1]=="channel") then
						GLDG_GreetChannel()
					elseif (wordsLower[1]=="all") then
						GLDG_GreetGuild()
						GLDG_GreetChannel()
					else
						GLDG_SendGreet(words[1])
						--GLDG_SendGreet(words[1], true) -- true at the end means "testing only"
					end
				else
					GLDG_GreetGuild()
					GLDG_GreetChannel()
				end
			elseif (wordsLower[0]=="bye") then
				if (size>1) then
					if (wordsLower[1]=="guild") then
						GLDG_ByeGuild()
					elseif (wordsLower[1]=="channel") then
						GLDG_ByeChannel()
					elseif (wordsLower[1]=="all") then
						GLDG_ByeGuild()
						GLDG_ByeChannel()
					else
						GLDG_SendBye(words[1])
						--GLDG_SendBye(words[1], true)	-- true at the end means "testing only"
					end
				else
					GLDG_ByeGuild()
					GLDG_ByeChannel()
				end

			elseif (wordsLower[0]=="later") then
				if (size>1) then
					if (wordsLower[1]=="guild") then
						GLDG_LaterGuild()
					elseif (wordsLower[1]=="channel") then
						GLDG_LaterChannel()
					elseif (wordsLower[1]=="all") then
						GLDG_LaterGuild()
						GLDG_LaterChannel()
					else
						GLDG:PrintHelp(L["Could not parse command"].." ["..(GLDG:GetColors().help or "")..msgLower.."|r]")
						GLDG_Help()
					end
				else
					GLDG_LaterGuild()
					GLDG_LaterChannel()
				end

			elseif (wordsLower[0]=="help") then
				GLDG_Help()
			elseif (wordsLower[0]=="about") then
				GLDG_About()
			elseif (wordsLower[0]=="urbin") then
				GLDG_ListUrbinAddonDetails()
			elseif (wordsLower[0]=="check") then
				GLDG_Convert_Plausibility_Check()
			elseif (wordsLower[0]=="fix") then
				GLDG_Convert_Plausibility_Fix()
			elseif (wordsLower[0]=="unnew") then
				GLDG_Convert_Unnew()
			elseif (wordsLower[0]=="aliasreset") then
				GLDG_Reset_Aliases()
			elseif (wordsLower[0]=="alert") then
				GLDG_Data.CheckedGuildAlert = false	-- force check if called from command line
				GLDG_CheckForGuildAlert()
			elseif (wordsLower[0]=="test") then
				GLDG_Test(true)
			elseif (wordsLower[0]=="query") then
				GLDG_PollBigBrother()
			elseif (wordsLower[0]=="bbshow") then
				GLDG_ShowBigBrother()
			elseif (wordsLower[0]=="bb") then
				GLDG_BB(not GLDG.db.profile.BigBrother)
			elseif (wordsLower[0]=="config") then
				_G[GLDG_GUI]:Show()
			else
				GLDG_ListForPlayer(words[0], false)
			end
		else
			_G[GLDG_GUI]:Show()
		end
	end
end

-- Roster initialization and guild setup
function GLDG.Utils:InitRoster()
	-- convert GLDG_Data from old format
	GLDG_Convert()

	-- Retreive realm, player and guild name if needed
	if not GLDG.Realm then GLDG.Realm = GetRealmName() end
	if not GLDG.Player then GLDG.Player = UnitName("player") end
	if not GLDG.GuildName or GLDG.GuildName == "" then GLDG.GuildName = GetGuildInfo("player") end
	if not GLDG.GuildName then GLDG.GuildName = "" end
	if not GLDG_unique_GuildName or GLDG_unique_GuildName == "" then
		local maxMembers = GetNumGuildMembers()
		if maxMembers == nil then maxMembers = nil end
		for i = 1, maxMembers do
			local pl, rn, ri, lv, cl, zn, pn, on, ol, st, enClass, ap, ar, isMobile = GetGuildRosterInfo(i)
			if ri == 0 then GLDG_GuildLeader = pl end
		end
		if GLDG_GuildLeader then
			GLDG_unique_GuildName = (GLDG.GuildName.."@"..GLDG_GuildLeader)
			GLDG_Init()
		end
	end
	if not GLDG_unique_GuildName then
		GLDG_unique_GuildName = ""
	end
	if (GLDG_unique_GuildName == "") then
		GLDG_GuildAlias = ""
	else
		if not GLDG_Data.GuildAlias[GLDG_unique_GuildName] then
			GLDG_Data.GuildAlias[GLDG_unique_GuildName] = GLDG_unique_GuildName
		end
		GLDG_GuildAlias = GLDG_Data.GuildAlias[GLDG_unique_GuildName]
	end

	if not (GLDG.Realm and GLDG.Player) then return end

	if not GLDG_Data["DataChar"] then GLDG_Data["DataChar"] = {} end
	GLDG_DataChar = GLDG_Data["DataChar"]

	if (GLDG.Realm and GLDG.Player) then
		-- create channel name store if needed
		if not GLDG_Data.ChannelNames then
			GLDG_Data.ChannelNames = {}
		end
		if not GLDG_Data.ChannelNames[GLDG.Realm.." - "..GLDG.Player] then
			GLDG_Data.ChannelNames[GLDG.Realm.." - "..GLDG.Player] = ""
		end
		-- set channel name pointer
		GLDG_ChannelName = GLDG_Data.ChannelNames[GLDG.Realm.." - "..GLDG.Player]
		if not GLDG_Data.Frameopts[GLDG.Realm.." - "..GLDG.Player] then
			GLDG_Data.Frameopts[GLDG.Realm.." - "..GLDG.Player] = {}
			GLDG_Data.Frameopts[GLDG.Realm.." - "..GLDG.Player].anchorFrom = "CENTER"
			GLDG_Data.Frameopts[GLDG.Realm.." - "..GLDG.Player].anchorTo = "CENTER"
			GLDG_Data.Frameopts[GLDG.Realm.." - "..GLDG.Player].offsetx = 0
			GLDG_Data.Frameopts[GLDG.Realm.." - "..GLDG.Player].offsety = 0
			GLDG_Data.Frameopts[GLDG.Realm.." - "..GLDG.Player].Width = 500
			GLDG_Data.Frameopts[GLDG.Realm.." - "..GLDG.Player].Height = 560
		end
	else
		GLDG_ChannelName = ""
	end
	
	if (GLDG.Realm and GLDG_unique_GuildName and GLDG_unique_GuildName~="" and GLDG.Player) then
		-- Set greetings section pointer
		if GLDG_InitGreet(GLDG.Realm.."-"..GLDG.Player) and
		   GLDG_InitGreet(GLDG_unique_GuildName) and
		   GLDG_InitGreet(GLDG.Realm) then
			-- No custom collections are used
			GLDG_DataGreet = GLDG_Data
		end

		-- Set initial custom collection settings
		GLDG_ShowCustom(GLDG_GUI.."Greetings")
	else
		GLDG_DataGreet = GLDG_Data
	end

	-- Update config dialog (can't be done in InitFrame())
	local name = GLDG_GUI.."SettingsGreeting"
	if (GLDG_unique_GuildName~="") then

		_G[name.."GuildAliasHeader"]:SetText(L["Guild alias for:"].." |cFFFFFF7F"..GLDG_unique_GuildName.."|r")
		if (GLDG_GuildAlias ~= GLDG_unique_GuildName) then
			_G[name.."GuildAliasEditbox"]:SetText(GLDG_GuildAlias)
		else
			_G[name.."GuildAliasEditbox"]:SetText("")
		end

		_G[name.."GuildAliasEditbox"]:Show()
		_G[name.."GuildAliasWarning"]:Hide()
		_G[name.."GuildAliasSet"]:Enable("")
		_G[name.."GuildAliasClear"]:Enable("")
	else
		_G[name.."GuildAliasHeader"]:SetText(L["Guild alias for:"].." |cFFFFFF7F"..GLDG_unique_GuildName.."|r")
		_G[name.."GuildAliasWarning"]:SetText(L["Can't set guild alias while unguilded"])
		_G[name.."GuildAliasEditbox"]:SetText("")

		_G[name.."GuildAliasEditbox"]:Hide()
		_G[name.."GuildAliasWarning"]:Show()
		_G[name.."GuildAliasSet"]:Disable("")
		_G[name.."GuildAliasClear"]:Disable("")
	end

	-- clear stale achievment information
	for p in pairs(GLDG_DataChar) do
		GLDG_DataChar[p].achievment = nil
	end

	-- Launch request for full guild roster
	if (IsInGuild()) then
		local offline = GetGuildRosterShowOffline()
		SetGuildRosterShowOffline(true)
		-- H.Sch. - ReglohPri - this is deprecated -> GuildRoster() - changed to C_GuildInfo.GuildRoster()
		C_GuildInfo.GuildRoster();  -- ?
		if not offline then SetGuildRosterShowOffline(false) end

		if (GLDG_InitialGuildUpdate == nil) then
			if IsInGuild() and bit.band(GLDG_InitCheck, 1)~=1 then
				GLDG_InitCheck = bit.bor(GLDG_InitCheck, 1)	-- guild started
				--GLDG_Print("InitCheck is ["..tostring(GLDG_InitCheck).."] - guild started")
			end
		end

		-- GLDG_RosterImport will call GLDG_CheckChannel
	else
		-- GLDG_RosterImport won't be called
		GLDG_CheckChannel()
	end

	-- Launch request for friends info
	-- H.Sch. - ReglohPri - ShowFriends() is deprecated changed to C_FriendList.ShowFriends()
	C_FriendList.ShowFriends();
	if not GLDG_InitialFriendsUpdate then
		-- H.Sch. - ReglohPri - GetNumFriends() is deprecated changed to C_FriendList.GetNumFriends()
		if GLDG_Data.UseFriends==true and (C_FriendList.GetNumFriends() > 0) and bit.band(GLDG_InitCheck, 2)~=2 then
			GLDG_InitCheck = bit.bor(GLDG_InitCheck, 2)	-- friends started
			--GLDG_Print("InitCheck is ["..tostring(GLDG_InitCheck).."] - friends started")
		end
	end

	-- check if there are inconsistencies
	if GLDG_autoConsistencyCheckReady then
		if not GLDG_autoConsistencyChecked then
			GLDG_autoConsistencyChecked = true
			if GLDG_Convert_Plausibility_Check(true) then
				GLDG:PrintHelp(L["Inconsistencies detected. Please use |cFFFFFF7F/gg check|r to display them or |cFFFFFF7F/gg fix|r to fix them"])
			end
		end
	end
end

------------------------------------------------------------
-- Testing and Debug Functions
------------------------------------------------------------

function GLDG.Utils:SecToTimeString(secs)
	--local result = tostring(secs).." seconds: "
	local result = ""
	if type(secs) == "number"  then
		secs = time() - secs

		--result = result.."diff "..tostring(secs)..": "

		local day = floor(secs / 86400)
		secs = secs % 86400

		local hours = floor(secs / 3600)
		secs = secs % 3600

		local minutes = floor(secs / 60)
		secs = secs % 60

		if (day > 1) then
			result = result.." "..tostring(day)..L[" days"]
		elseif (day > 0) then
			result = result.." "..tostring(day)..L[" day"]
		end
		if (hours > 1) then
			result = result.." "..tostring(hours)..L[" hours"]
		elseif (hours > 0) then
			result = result.." "..tostring(hours)..L[" hour"]
		end
		if (minutes > 1) then
			result = result.." "..tostring(minutes)..L[" minutes"]
		elseif (minutes > 0) then
			result = result.." "..tostring(minutes)..L[" minute"]
		end
		if (secs > 1) then
			result = result.." "..tostring(secs)..L[" seconds"]
		elseif (secs > 0) then
			result = result.." "..tostring(secs)..L[" second"]
		end

	end

	return result
end

------------------------------------------------------------
function GLDG.Utils:Test(showAll)
	GLDG_Print(GLDG:GetColors().help..GLDG_NAME..":|r Test")

	local num, numon = BNGetNumFriends()
	if (numon > 0) or showAll then
		GLDG_Print("BN friends ["..tostring(num).."] - online ["..tostring(numon).."]")
		local presenceID, givenName, surname, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, broadcastText, noteText, isFriend, broadcastTime
		local numToons
		local hasFocus, toonName, client, realmName, faction, race, class, guild, zoneName, level, gameText
		for i = 1, num do
			presenceID, givenName, surname, isBattleTagPresence, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, broadcastText, noteText, isFriend, broadcastTime = BNGetFriendInfo(i)
			--GLDG_Print("  BN friend "..tostring(i)..": presenceId ["..tostring(presenceId).."] givenName ["..tostring(givenName).."] surname ["..tostring(surname).."] toonName ["..tostring(toonName).."] toonID ["..tostring(toonId).."] client ["..tostring(client).."] isOnline ["..tostring(isOnline).."] lastOnline ["..tostring(GLDG_SecToTimeString(lastOnline)).."] isAFK ["..tostring(isAFK).."] isDND ["..tostring(isDND).."] broadcastText ["..tostring(broadcastText).."] noteText ["..tostring(noteText).."] isFriend ["..tostring(isFriend).."] broadcastTime ["..tostring(GLDG_SecToTimeString(broadCastTime)).."]");
			if (isOnline or showAll) then
				if isOnline then isOnline = "online" else isOnline = "offline" end
				GLDG_Print("  BN friend ["..tostring(givenName).." "..tostring(surname).."] - ["..tostring(toonName).."] - ["..tostring(client).."] is ["..tostring(isOnline).."] since ["..tostring(self:SecToTimeString(lastOnline)).."]");

				numToons = BNGetNumFriendGameAccounts(i);
				if ( numToons > 0 ) then
					GLDG_Print("  Has "..tostring(numToons).." toons")
					for j = 1, numToons do
						hasFocus, toonName, client, realmName, realmID, faction, race, class, guild, zoneName, level, gameText = BNGetFriendGameAccountInfo(i, j)
						--GLDG_Print("     Toon "..tostring(j)..": hasFocus ["..tostring(hasFocus).."] toonName ["..tostring(toonName).."] client ["..tostring(client).."] realmName ["..tostring(realmName).."] faction ["..tostring(faction).."] race ["..tostring(race).."] class ["..tostring(class).."] guild ["..tostring(guild).."] zoneName ["..tostring(zoneName).."] level ["..tostring(level).."] gameText ["..tostring(gameText).."]")
						GLDG_Print("     Toon "..tostring(j)..": ["..tostring(toonName).."] on ["..tostring(realmName).."] ["..tostring(faction).."] is ["..tostring(race).."] ["..tostring(class).."] in guild ["..tostring(guild).."] currently in ["..tostring(zoneName).."] - level ["..tostring(level).."]")
					end
				end
			end
		end
	end
end

------------------------------------------------------------
function GLDG.Utils:CreateTestChars()
	GLDG_Queue["Tester1"] = GLDG_GetLogtime("Tester1")
	GLDG_Queue["Tester2"] = GLDG_GetLogtime("Tester2")
	GLDG_Queue["Tester3"] = GLDG_GetLogtime("Tester3")
	GLDG_Queue["Tester4"] = GLDG_GetLogtime("Tester4")
	GLDG_Queue["Tester5"] = GLDG_GetLogtime("Tester5")

	GLDG_Online["Tester1"] = GLDG_GetLogtime("Tester1")
	GLDG_Online["Tester2"] = GLDG_GetLogtime("Tester2")
	GLDG_Online["Tester3"] = GLDG_GetLogtime("Tester3")
	GLDG_Online["Tester4"] = GLDG_GetLogtime("Tester4")
	GLDG_Online["Tester5"] = GLDG_GetLogtime("Tester5")

	GLDG.Messages:ShowQueue()
end

------------------------------------------------------------
function GLDG.Utils:ShowDetails(name)
	if not name then return end

	if (GLDG_DataChar[name]) then
		GLDG_Print(GLDG:GetColors().help..GLDG_NAME..":|r ["..Ambiguate(name, "guild").."]")
		for p in pairs(GLDG_DataChar[name]) do
			if type(GLDG_DataChar[name][p]) == "table" then
				local l = ""
				for q in pairs(GLDG_DataChar[name][p]) do
					l = l..q.." "
				end
				GLDG_Print("  "..Ambiguate(p, "guild").." = "..l)
			else
				GLDG_Print("  "..Ambiguate(p, "guild").." = "..tostring(GLDG_DataChar[name][p]))
			end
		end
	else
		GLDG:PrintHelp(L["No data found for character"].." ["..Ambiguate(name, "guild").."] "..L[""])
	end
end

-------------------------------
-- Utils Initialization --
-------------------------------

function GLDG.Utils:Initialize()
	-- Utils module doesn't need special initialization
	-- All functions are available immediately
	GLDG:Print(GLDG.Colors:GetColors().help..GLDG_NAME..":|r "..L["Utilities module initialized"])
end