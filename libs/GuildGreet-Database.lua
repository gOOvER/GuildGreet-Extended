--[[--------------------------------------------------------
-- GuildGreet Database Management Library
-- Handles database initialization, configuration, and migration
------------------------------------------------------------]]

local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", false)

-- Database Library Namespace
GLDG.Database = {}

-- Import required global variables for compatibility
local GLDG_Data, GLDG_DataGreet, GLDGL_DataChar
local GLDG_unique_GuildName, GLDG_Player, GLDG_Realm, GLDG_GuildLeader
local GLDG_config_from_guild, GLDG_corrupted_config_from_guild, GLDG_ginfotxt
local GLDG_CONFIG_STRING, GLDG_CONFIG_STRING_A, GLDG_CONFIG_STRING_B, GLDG_CONFIG_STRING_C, GLDG_CONFIG_STRING_D

-- Default greeting messages (moved from main file)
local GLDG_GREET = {}
local GLDG_GREETBACK = {}
local GLDG_WELCOME = {}
local GLDG_RANK = {}
local GLDG_LEVEL = {}
local GLDG_BYE = {}
local GLDG_NIGHT = {}
local GLDG_GUILD = {}
local GLDG_CHANNEL = {}
local GLDG_BYE_GUILD = {}
local GLDG_NIGHT_GUILD = {}
local GLDG_BYE_CHANNEL = {}
local GLDG_NIGHT_CHANNEL = {}
local GLDG_LATER_GUILD = {}
local GLDG_LATER_CHANNEL = {}
local GLDG_ACHIEVMENT = {}

-------------------------------
-- Database Initialization --
-------------------------------

function GLDG.Database:Init()
	local version = GetAddOnMetadata("GuildGreet", "Version");
	if (version == nil) then
		version = "unknown";
	end

	-- store realm and player names
	if not GLDG.Realm then GLDG.Realm = GetRealmName() end
	if not GLDG.Player then GLDG.Player = UnitName("player") end

	-- Clear obsolete options
	GLDG_Data.EnableContextMenu = nil

	-- Set defaults for missing settings
	if GLDG_unique_GuildName then
		if not GLDG_Data[GLDG_unique_GuildName] then
			GLDG_Data[GLDG_unique_GuildName] = {}
			GLDG_Data[GLDG_unique_GuildName].UseGuildDefault = true
		end
	end

	if not GLDG_Data.GuildSettings then GLDG_Data.GuildSettings = {} end

	-- Convert legacy boolean values for API 6.0.2 compatibility
	self:ConvertLegacyBooleans()

	-- Initialize default values
	self:InitializeDefaults()

	-- Initialize greeting collections
	self:InitializeGreetings()

	-- Update player checkboxes
	GLDG_UpdatePlayerCheckboxes()

	GLDG_InitComplete = true
	
	GLDG:Print(GLDG.Database:GetColors().help..GLDG_NAME..":|r "..L["Database initialized successfully"])
end

-------------------------------
-- Legacy Boolean Conversion --
-------------------------------

function GLDG.Database:ConvertLegacyBooleans()
	if GLDG_Data[GLDG_unique_GuildName] then
		-- convert for API 6.0.2 begin
		local settings = GLDG_Data[GLDG_unique_GuildName]
		if settings.GreetAsMain==1 then settings.GreetAsMain=true end
		if settings.Randomize==1 then settings.Randomize=true end
		if settings.Whisper==1 then settings.Whisper=true end
		if settings.WhisperLevelup==1 then settings.WhisperLevelup=true end
		if settings.IncludeOwn==1 then settings.IncludeOwn=true end
		if settings.AutoAssign==1 then settings.AutoAssign=true end
		if settings.AutoAssignEgp==1 then settings.AutoAssignEgp=true end
		if settings.AutoAssignAlias==1 then settings.AutoAssignAlias=true end
		if settings.ListNames==1 then settings.ListNames=true end
		if settings.ListNamesOff==1 then settings.ListNamesOff=true end
		if settings.ListLevelUp==1 then settings.ListLevelUp=true end
		if settings.ListLevelUpOff==1 then settings.ListLevelUpOff=true end
		if settings.ListAchievments==1 then settings.ListAchievments=true end
		if settings.ListQuit==1 then settings.ListQuit=true end
		if settings.ExtendChat==1 then settings.ExtendChat=true end
		if settings.ExtendIgnored==1 then settings.ExtendIgnored=true end
		if settings.ExtendMain==1 then settings.ExtendMain=true end
		if settings.ExtendAlias==1 then settings.ExtendAlias=true end
		if settings.AddPostfix==1 then settings.AddPostfix=true end
		if settings.ShowWhoSpam==1 then settings.ShowWhoSpam=true end
		if settings.SupressGreet==1 then settings.SupressGreet=true end
		if settings.SupressJoin==1 then settings.SupressJoin=true end
		if settings.SupressLevel==1 then settings.SupressLevel=true end
		if settings.SupressRank==1 then settings.SupressRank=true end
		if settings.SupressAchievment==1 then settings.SupressAchievment=true end
		if settings.NoGratsOnLogin==1 then settings.NoGratsOnLogin=true end
		if settings.DeltaPopup==1 then settings.DeltaPopup=true end
		if settings.RelogTime==1 then settings.RelogTime=true end
		if settings.MinLevelUp==1 then settings.MinLevelUp=true end
		if settings.UseGuildDefault==1 then settings.UseGuildDefault=true end
		-- convert for API 6.0.2 end
		
		-- Copy settings to GuildSettings
		self:CopyToGuildSettings(settings)
	end

	-- Convert GuildSettings booleans as well
	local guildSettings = GLDG_Data.GuildSettings
	if guildSettings.GreetAsMain==1 then guildSettings.GreetAsMain=true end
	if guildSettings.Randomize==1 then guildSettings.Randomize=true end
	if guildSettings.Whisper==1 then guildSettings.Whisper=true end
	-- ... (continue for all boolean settings)
end

-------------------------------
-- Copy Settings to Guild --
-------------------------------

function GLDG.Database:CopyToGuildSettings(settings)
	GLDG_Data.GuildSettings.GreetAsMain = settings.GreetAsMain
	GLDG_Data.GuildSettings.Randomize = settings.Randomize
	GLDG_Data.GuildSettings.Whisper = settings.Whisper
	GLDG_Data.GuildSettings.WhisperLevelup = settings.WhisperLevelup
	GLDG_Data.GuildSettings.IncludeOwn = settings.IncludeOwn
	GLDG_Data.GuildSettings.AutoAssign = settings.AutoAssign
	GLDG_Data.GuildSettings.AutoAssignEgp = settings.AutoAssignEgp
	GLDG_Data.GuildSettings.AutoAssignAlias = settings.AutoAssignAlias
	GLDG_Data.GuildSettings.ListNames = settings.ListNames
	GLDG_Data.GuildSettings.ListNamesOff = settings.ListNamesOff
	GLDG_Data.GuildSettings.ListLevelUp = settings.ListLevelUp
	GLDG_Data.GuildSettings.ListLevelUpOff = settings.ListLevelUpOff
	GLDG_Data.GuildSettings.ListAchievments = settings.ListAchievments
	GLDG_Data.GuildSettings.ListQuit = settings.ListQuit
	GLDG_Data.GuildSettings.ExtendChat = settings.ExtendChat
	GLDG_Data.GuildSettings.ExtendIgnored = settings.ExtendIgnored
	GLDG_Data.GuildSettings.ExtendMain = settings.ExtendMain
	GLDG_Data.GuildSettings.ExtendAlias = settings.ExtendAlias
	GLDG_Data.GuildSettings.AddPostfix = settings.AddPostfix
	GLDG_Data.GuildSettings.ShowWhoSpam = settings.ShowWhoSpam
	GLDG_Data.GuildSettings.SupressGreet = settings.SupressGreet
	GLDG_Data.GuildSettings.SupressJoin = settings.SupressJoin
	GLDG_Data.GuildSettings.SupressLevel = settings.SupressLevel
	GLDG_Data.GuildSettings.SupressRank = settings.SupressRank
	GLDG_Data.GuildSettings.SupressAchievment = settings.SupressAchievment
	GLDG_Data.GuildSettings.NoGratsOnLogin = settings.NoGratsOnLogin
	GLDG_Data.GuildSettings.DeltaPopup = settings.DeltaPopup
	GLDG_Data.GuildSettings.RelogTime = settings.RelogTime
	GLDG_Data.GuildSettings.MinLevelUp = settings.MinLevelUp
	GLDG_Data.GuildSettings.UseGuildDefault = settings.UseGuildDefault
end

-------------------------------
-- Initialize Default Values --
-------------------------------

function GLDG.Database:InitializeDefaults()
	-- Set default values for missing settings
	if not GLDG_Data.GuildSettings.RelogTime then GLDG_Data.GuildSettings.RelogTime = 2 end
	if not GLDG_Data.GuildSettings.MinLevelUp then GLDG_Data.GuildSettings.MinLevelUp = 0 end
	GLDG_Data.UpdateTime = 0
	if not GLDG_Data.GuildSettings.UseGuildDefault then GLDG_Data.GuildSettings.UseGuildDefault = false end
	if not GLDG_Data.ListSize then GLDG_Data.ListSize = 5 end
	if not GLDG_Data.PlayerChatFrame then GLDG_Data.PlayerChatFrame = {} end
	if not GLDG_Data.PlayerChatFrame[GLDG.Player.."-"..GLDG.Realm] then 
		GLDG_Data.PlayerChatFrame[GLDG.Player.."-"..GLDG.Realm] = 0 
	end

	-- Initialize collections and settings tables
	if not GLDG_Data.Collections then GLDG_Data.Collections = {} end
	if not GLDG_Data.Custom then GLDG_Data.Custom = {} end
	if not GLDG_Data.Ranks then GLDG_Data.Ranks = {} end
	if not GLDG_Data.ChannelNames then GLDG_Data.ChannelNames = {} end
	if not GLDG_Data.Frameopts then GLDG_Data.Frameopts = {} end
	if not GLDG_Data.GuildAlias then GLDG_Data.GuildAlias = {} end
	if not GLDG_Data.CheckedGuildAlert then GLDG_Data.CheckedGuildAlert = false end

	-- Initialize boolean settings with defaults
	self:InitializeBooleanDefaults()
end

-------------------------------
-- Initialize Boolean Defaults --
-------------------------------

function GLDG.Database:InitializeBooleanDefaults()
	local settings = GLDG_Data.GuildSettings
	
	if not settings.GreetAsMain then settings.GreetAsMain = false end
	if not settings.Randomize then settings.Randomize = false end
	if not settings.Whisper then settings.Whisper = false end
	if not settings.WhisperLevelup then settings.WhisperLevelup = false end
	if not settings.IncludeOwn then settings.IncludeOwn = false end
	if not settings.ListNames then settings.ListNames = false end
	if not settings.ListNamesOff then settings.ListNamesOff = false end
	if not settings.ListLevelUp then settings.ListLevelUp = false end
	if not settings.ListLevelUpOff then settings.ListLevelUpOff = false end
	if not settings.ListQuit then settings.ListQuit = false end
	if not settings.ExtendChat then settings.ExtendChat = false end
	if not settings.ExtendIgnored then settings.ExtendIgnored = false end
	if not settings.ExtendAlias then settings.ExtendAlias = false end
	if not settings.ExtendMain then settings.ExtendMain = false end
	if not settings.AutoAssign then settings.AutoAssign = false end
	if not settings.AutoAssignEgp then settings.AutoAssignEgp = false end
	if not settings.AutoAssignAlias then settings.AutoAssignAlias = false end
	if not GLDG_Data.UseFriends then GLDG_Data.UseFriends = false end
	if not GLDG_Data.ListUp then GLDG_Data.ListUp = false end
	if not GLDG_Data.ListVisible then GLDG_Data.ListVisible = false end
	if not settings.AddPostfix then settings.AddPostfix = false end
	if not settings.ShowWhoSpam then settings.ShowWhoSpam = false end
	if not settings.ListAchievments then settings.ListAchievments = false end
end

-------------------------------
-- Initialize Greetings --
-------------------------------

function GLDG.Database:InitializeGreetings()
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
end

------------------------------------
-- Guild Configuration String Handling --
------------------------------------

function GLDG.Database:ReadConfigString()
	GLDG_ginfotxt = GetGuildInfoText()
	if (GLDG_CONFIG_STRING ~= nil) and (GLDG_CONFIG_STRING ~= GLDG_config_from_guild) and IsGuildLeader() then
		_G[GLDG_GUI.."SettingsGeneralWriteGuildString"]:Enable()
	else
		_G[GLDG_GUI.."SettingsGeneralWriteGuildString"]:Disable()
	end
	
	local gstringstart = string.find(GLDG_ginfotxt, "{GG", 1)
	local gstring1, gstring2, gstring3, gstring4
	
	if (gstringstart ~= nil) then
		gstringstart = gstringstart + 4
		local a,b,c = strfind(GLDG_ginfotxt, "(%S+)", gstringstart)
		gstring1,gstring2,gstring3,gstring4 = string.split(":",c)
		
		if gstring4 == nil then
			GLDG_corrupted_config_from_guild = "{GG:"..c
			GLDG_config_from_guild = "corrupted"
		else
			gstring4 = string.split("}",gstring4)
			if mod((tonumber("0x"..gstring1, 16)+1) * (tonumber("0x"..gstring2, 16)+1) * (tonumber("0x"..gstring3, 16)+1),33) == tonumber(gstring4, 10) then
				GLDG_config_from_guild = "{GG:"..c
				GLDG_corrupted_config_from_guild = nil
			else
				GLDG_corrupted_config_from_guild = "{GG:"..c
				GLDG_config_from_guild = "corrupted"
			end
		end
	else
		GLDG_config_from_guild = "not found"
		GLDG_InitRoster()
	end
	
	-- Apply guild settings if using guild defaults
	if (GLDG_Data.GuildSettings.UseGuildDefault==true) and (GLDG_config_from_guild ~= "not found") and (GLDG_config_from_guild ~= "corrupted") then
		self:ApplyGuildConfigString(gstring1, gstring2, gstring3)
	else
		self:ApplyDefaultGuildSettings()
	end
end

------------------------------------
-- Apply Guild Config String Settings --
------------------------------------

function GLDG.Database:ApplyGuildConfigString(gstring1, gstring2, gstring3)
	local settings = GLDG_Data.GuildSettings
	
	-- Parse bitwise flags from gstring1
	if bit.band("0x"..gstring1, 1) >0 then settings.GreetAsMain=true else settings.GreetAsMain=false end
	if bit.band("0x"..gstring1, 2) >0 then settings.Randomize=true else settings.Randomize=false end
	if bit.band("0x"..gstring1, 2^2) >0 then settings.Whisper=true else settings.Whisper=false end
	if bit.band("0x"..gstring1, 2^3) >0 then settings.WhisperLevelup=true else settings.WhisperLevelup=false end
	if bit.band("0x"..gstring1, 2^4) >0 then settings.IncludeOwn=true else settings.IncludeOwn=false end
	if bit.band("0x"..gstring1, 2^5) >0 then settings.AutoAssign=true else settings.AutoAssign=false end
	if bit.band("0x"..gstring1, 2^6) >0 then settings.AutoAssignEgp=true else settings.AutoAssignEgp=false end
	if bit.band("0x"..gstring1, 2^7) >0 then settings.AutoAssignAlias=true else settings.AutoAssignAlias=false end
	if bit.band("0x"..gstring1, 2^8) >0 then settings.ListNames=true else settings.ListNames=false end
	if bit.band("0x"..gstring1, 2^9) >0 then settings.ListNamesOff=true else settings.ListNamesOff=false end
	if bit.band("0x"..gstring1, 2^10) >0 then settings.ListLevelUp=true else settings.ListLevelUp=false end
	if bit.band("0x"..gstring1, 2^11) >0 then settings.ListLevelUpOff=true else settings.ListLevelUpOff=false end
	if bit.band("0x"..gstring1, 2^12) >0 then settings.ListAchievments=true else settings.ListAchievments=false end
	if bit.band("0x"..gstring1, 2^13) >0 then settings.ListQuit=true else settings.ListQuit=false end
	if bit.band("0x"..gstring1, 2^14) >0 then settings.ExtendChat=true else settings.ExtendChat=false end
	if bit.band("0x"..gstring1, 2^15) >0 then settings.ExtendIgnored=true else settings.ExtendIgnored=false end
	if bit.band("0x"..gstring1, 2^16) >0 then settings.ExtendMain=true else settings.ExtendMain=false end
	if bit.band("0x"..gstring1, 2^17) >0 then settings.ExtendAlias=true else settings.ExtendAlias=false end
	if bit.band("0x"..gstring1, 2^18) >0 then settings.AddPostfix=true else settings.AddPostfix=false end
	if bit.band("0x"..gstring1, 2^19) >0 then settings.ShowWhoSpam=true else settings.ShowWhoSpam=false end
	if bit.band("0x"..gstring1, 2^20) >0 then settings.SupressGreet=true else settings.SupressGreet=false end
	if bit.band("0x"..gstring1, 2^21) >0 then settings.SupressJoin=true else settings.SupressJoin=false end
	if bit.band("0x"..gstring1, 2^22) >0 then settings.SupressLevel=true else settings.SupressLevel=false end
	if bit.band("0x"..gstring1, 2^23) >0 then settings.SupressRank=true else settings.SupressRank=false end
	if bit.band("0x"..gstring1, 2^24) >0 then settings.SupressAchievment=true else settings.SupressAchievment=false end
	if bit.band("0x"..gstring1, 2^25) >0 then settings.NoGratsOnLogin=true else settings.NoGratsOnLogin=false end
	if bit.band("0x"..gstring1, 2^26) >0 then settings.DeltaPopup=true else settings.DeltaPopup=false end
	
	-- Parse numeric values
	settings.RelogTime = tonumber(gstring2, 16)
	settings.MinLevelUp = tonumber(gstring3, 16)

	-- Copy settings to guild-specific data
	GLDG_Data[GLDG_unique_GuildName] = GLDG_Data.GuildSettings

	-- Print success message
	if (GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] ~= date("%m/%d/%y")) or (GLDG_Data[GLDG_unique_GuildName.." lastmessage"] ~= 1) then
		GLDG:PrintHelp(string.format(L["ChatMsg/Config string found. GuildGreet using default settings from %s!"], Ambiguate(GLDG_GuildLeader, "guild")))
		GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] = date("%m/%d/%y")
		GLDG_Data[GLDG_unique_GuildName.." lastmessage"] = 1
	end
end

------------------------------------
-- Apply Default Guild Settings --
------------------------------------

function GLDG.Database:ApplyDefaultGuildSettings()
	if GLDG_Data.GuildSettings.UseGuildDefault==true and GLDG_unique_GuildName then
		local settings = GLDG_Data.GuildSettings
		
		-- Set default values
		settings.GreetAsMain=false
		settings.Randomize=false
		settings.Whisper=false
		settings.WhisperLevelup=false
		settings.IncludeOwn=true
		settings.AutoAssign=false
		settings.AutoAssignEgp=false
		settings.AutoAssignAlias=false
		settings.ListNames=true
		settings.ListNamesOff=true
		settings.ListLevelUp=true
		settings.ListLevelUpOff=true
		settings.ListAchievments=true
		settings.ListQuit=true
		settings.ExtendChat=true
		settings.ExtendIgnored=true
		settings.ExtendMain=true
		settings.ExtendAlias=true
		settings.AddPostfix=true
		settings.ShowWhoSpam=false
		settings.SupressGreet=false
		settings.SupressJoin=false
		settings.SupressLevel=false
		settings.SupressRank=false
		settings.SupressAchievment=false
		settings.NoGratsOnLogin=true
		settings.DeltaPopup=true
		settings.RelogTime = 2
		settings.MinLevelUp = 20
		
		GLDG_Data[GLDG_unique_GuildName] = settings

		-- Handle different config string states
		self:HandleConfigStringMessages()
	end
end

------------------------------------
-- Handle Config String Messages --
------------------------------------

function GLDG.Database:HandleConfigStringMessages()
	if GLDG_config_from_guild == "not found" then
		if IsGuildLeader() then
			if (GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] ~= date("%m/%d/%y")) or (GLDG_Data[GLDG_unique_GuildName.." lastmessage"] ~= 3) then
				GLDG:PrintHelp(L["ChatMsg/Config string not found."].." \r\n"..L["ChatMsg/GuildGreet using default settings!"])
				GLDG:PrintHelp(L["ChatMsg/Note to the guild master to create the config string"].." \r\n"..L["ChatMsg/To set the config string ..."])
				GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] = date("%m/%d/%y")
				GLDG_Data[GLDG_unique_GuildName.." lastmessage"] = 3
			end
		else
			if (GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] ~= date("%m/%d/%y")) or (GLDG_Data[GLDG_unique_GuildName.." lastmessage"] ~= 2) then
				GLDG:PrintHelp(L["ChatMsg/Config string not found."].." \r\n"..L["ChatMsg/GuildGreet using default settings!"])
				GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] = date("%m/%d/%y")
				GLDG_Data[GLDG_unique_GuildName.." lastmessage"] = 2
			end
		end
	elseif GLDG_config_from_guild == "corrupted" then
		if IsGuildLeader() then
			GLDG:PrintHelp(L["ChatMsg/The config string seems to be corrupted. Please generating a new one."].." \r\n"..L["ChatMsg/GuildGreet using default settings!"])
		else
			if (GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] ~= date("%m/%d/%y")) or (GLDG_Data[GLDG_unique_GuildName.." lastmessage"] ~= 5) then
				GLDG:PrintHelp(string.format(L["ChatMsg/The config string seems to be corrupted. Please inform %s!"], Ambiguate(GLDG_GuildLeader, "guild")).." \r\n"..L["ChatMsg/GuildGreet using default settings!"])
				GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] = date("%m/%d/%y")
				GLDG_Data[GLDG_unique_GuildName.." lastmessage"] = 5
			end
		end
	end
end

------------------------------------
-- Write Guild Configuration String --
------------------------------------

function GLDG.Database:WriteGuildString()
	GLDG_ginfotxt = GetGuildInfoText()

	if not GLDG_CONFIG_STRING then self:GenerateConfigString() end
	local new_ginfotxt = nil

	if GLDG_config_from_guild == nil then self:ReadConfigString() end

	if GLDG_ginfotxt == nil then GLDG_ginfotxt = " " end

	if GLDG_config_from_guild ~= nil and GLDG_config_from_guild =="not found" then
		new_ginfotxt = GLDG_ginfotxt.."\r"..GLDG_CONFIG_STRING
	end

	if GLDG_config_from_guild ~= nil and GLDG_config_from_guild =="corrupted" then
		new_ginfotxt = string.gsub(GLDG_ginfotxt, GLDG_corrupted_config_from_guild, GLDG_CONFIG_STRING)
	end

	if (GLDG_config_from_guild ~= nil) and (GLDG_config_from_guild ~="not found") and (GLDG_config_from_guild ~="corrupted")then
		new_ginfotxt = string.gsub(GLDG_ginfotxt, GLDG_config_from_guild, GLDG_CONFIG_STRING)
	end

	if strlen(new_ginfotxt or "")<=499 then
		GLDG_config_from_guild = GLDG_CONFIG_STRING
		GLDG_corrupted_config_from_guild = nil
		SetGuildInfoText(new_ginfotxt or "")
		_G[GLDG_GUI.."SettingsGeneralWriteGuildString"]:Disable()
		GLDG.UIHelpers:Print(L["ChatMsg/Guild info written successfully!"])
		GLDG_ginfotxt = nil
		new_ginfotxt = nil
	else
		local tolong = strlen(new_ginfotxt or "")-499
		GLDG.UIHelpers:Print(string.format(L["ChatMsg/The guild info is too long..."], tolong))
		GLDG_ginfotxt = nil
		new_ginfotxt = nil
	end
end

------------------------------------
-- Generate Guild Configuration String --
------------------------------------

function GLDG.Database:GenerateConfigString()
	local gstring1 = 0
	local gstring2 = GLDG_Data.GuildSettings.RelogTime or 2
	local gstring3 = GLDG_Data.GuildSettings.MinLevelUp or 20
	local gstring4

	local settings = GLDG_Data.GuildSettings
	
	-- Generate bitwise flags
	if settings.GreetAsMain then gstring1 = gstring1 + 1 end
	if settings.Randomize then gstring1 = gstring1 + 2 end
	if settings.Whisper then gstring1 = gstring1 + 4 end
	if settings.WhisperLevelup then gstring1 = gstring1 + 8 end
	if settings.IncludeOwn then gstring1 = gstring1 + 16 end
	if settings.AutoAssign then gstring1 = gstring1 + 32 end
	if settings.AutoAssignEgp then gstring1 = gstring1 + 64 end
	if settings.AutoAssignAlias then gstring1 = gstring1 + 128 end
	if settings.ListNames then gstring1 = gstring1 + 256 end
	if settings.ListNamesOff then gstring1 = gstring1 + 512 end
	if settings.ListLevelUp then gstring1 = gstring1 + 1024 end
	if settings.ListLevelUpOff then gstring1 = gstring1 + 2048 end
	if settings.ListAchievments then gstring1 = gstring1 + 4096 end
	if settings.ListQuit then gstring1 = gstring1 + 8192 end
	if settings.ExtendChat then gstring1 = gstring1 + 16384 end
	if settings.ExtendIgnored then gstring1 = gstring1 + 32768 end
	if settings.ExtendMain then gstring1 = gstring1 + 65536 end
	if settings.ExtendAlias then gstring1 = gstring1 + 131072 end
	if settings.AddPostfix then gstring1 = gstring1 + 262144 end
	if settings.ShowWhoSpam then gstring1 = gstring1 + 524288 end
	if settings.SupressGreet then gstring1 = gstring1 + 1048576 end
	if settings.SupressJoin then gstring1 = gstring1 + 2097152 end
	if settings.SupressLevel then gstring1 = gstring1 + 4194304 end
	if settings.SupressRank then gstring1 = gstring1 + 8388608 end
	if settings.SupressAchievment then gstring1 = gstring1 + 16777216 end
	if settings.NoGratsOnLogin then gstring1 = gstring1 + 33554432 end
	if settings.DeltaPopup then gstring1 = gstring1 + 67108864 end

	-- Convert to hex
	GLDG_CONFIG_STRING_A = string.format("%x", gstring1)
	GLDG_CONFIG_STRING_B = string.format("%x", gstring2)
	GLDG_CONFIG_STRING_C = string.format("%x", gstring3)

	-- Generate checksum
	gstring4 = mod((gstring1+1) * (gstring2+1) * (gstring3+1), 33)
	GLDG_CONFIG_STRING_D = tostring(gstring4)

	GLDG_CONFIG_STRING = "{GG:"..GLDG_CONFIG_STRING_A..":"..GLDG_CONFIG_STRING_B..":"..GLDG_CONFIG_STRING_C..":"..GLDG_CONFIG_STRING_D.."}"
end

------------------------------------
-- Checkbox Update Functions --
------------------------------------

function GLDG.Database:SetUseGuildDefault(value)
	if value==true then
		GLDG_Data.GuildSettings.UseGuildDefault=true
		GLDG_Data[GLDG_unique_GuildName].UseGuildDefault=true
		GLDG_SetCheckboxes()
		GLDG_QueryReloadUI()
	else
		GLDG_Data.GuildSettings.UseGuildDefault=false
		GLDG_Data[GLDG_unique_GuildName].UseGuildDefault=false
		GLDG_SetCheckboxes()
		GLDG_QueryReloadUI()
	end
end

------------------------------------
-- Color Management (Legacy Support) --
------------------------------------

function GLDG.Database:GetColors()
	-- Modern color management will be handled by GuildGreet-Colors.lua
	-- This is just for legacy compatibility during migration
	return {
		help = "|cff00ff00"
	}
end

-- Global functions for backwards compatibility
function GLDG_Init()
	GLDG.Database:Init()
end

function GLDG_readConfigString()
	GLDG.Database:ReadConfigString()
end

function GLDG_WriteGuildString()
	GLDG.Database:WriteGuildString()
end

function GLDG_generateConfigString()
	GLDG.Database:GenerateConfigString()
end

function GLDG_SetUseGuildDefault(value)
	GLDG.Database:SetUseGuildDefault(value)
end

function GLDG.Database:RosterImportFull()
	if GLDG_Data.Version and (GLDG_Data.Version < 500408) then
	GLDG_Convert = 1
	local newname
		for i in pairs(GLDG_Data) do
			if string.find(i, "Realm: ") then
				local _, oldrealm = string.split(":", i)
				for oName in pairs(GLDG_Data[i]) do
					local uName, uRealm = string.split("-", oName)
					if not uRealm then
						newname = uName.."-"..string.gsub(oldrealm, " ", "")
					else
						newname = string.gsub(oName, " ", "")
					end
					if GLDG_Data[i][oName].alt then
						local altName, altRealm = string.split("-", GLDG_Data[i][oName].alt)
						if not altRealm then
							GLDG_Data[i][oName].alt = altName.."-"..string.gsub(oldrealm, " ", "")
						else
							GLDG_Data[i][oName].alt = string.gsub(GLDG_Data[i][oName].alt, " ", "")
						end
					end
					if GLDG_Data[i][oName].last then
						local lastName, lastRealm = string.split("-", GLDG_Data[i][oName].last)
						if not lastRealm then
							GLDG_Data[i][oName].last = lastName.."-"..string.gsub(oldrealm, " ", "")
						else
							GLDG_Data[i][oName].last = string.gsub(GLDG_Data[i][oName].last, " ", "")
						end
					end
					if newname ~= oName and oName ~= GLDG.Player.."-"..GLDG.Realm then
						GLDG_Data[i][newname] = GLDG_Data[i][oName]
						GLDG_Data[i][oName] = nil
					end
				end
				local newrealmname = "Realm:"..string.gsub(oldrealm, " ", "")
				if newrealmname ~= i then
					GLDG_Data[newrealmname] = GLDG_Data[i]
					GLDG_Data[i] = nil
				end
			end
		end
	end
	
	if GLDG_Data.Version and (GLDG_Data.Version < 600301) then
		GLDG_Convert = 1
		for i in pairs(GLDG_Data) do
			if string.find(i, "Realm:") then
				for oName in pairs(GLDG_Data[i]) do
					if GLDG_Data[i][oName].lastseen then
						GLDG_Data[i][oName].lastseen = nil
					end
				end
			end
		end
	end
	
	if GLDG_Data.Version and (GLDG_Data.Version < 600302) then
		GLDG_Convert = 1
		for i in pairs(GLDG_Data) do
			if string.find(i, "Realm:") then
				for oName in pairs(GLDG_Data[i]) do
					if GLDG_Data[i][oName].greeted then
						GLDG_Data[i][oName].greeted = nil
					end
				end
			end
		end
	end
	
	if GLDG_Data.Version and (GLDG_Data.Version < 600303) then
		GLDG_Convert = 1
		for i in pairs(GLDG_Data) do
			if string.find(i, "Realm:") then
				for oName in pairs(GLDG_Data[i]) do
					if GLDG_Data[i][oName].achievement then
						GLDG_Data[i][oName].achievement = nil
					end
				end
			end
		end
	end
	
	if GLDG_Data.Version and (GLDG_Data.Version < 700101) then
		GLDG_Convert = 1
		for i in pairs(GLDG_Data) do
			if string.find(i, "Realm:") then
				for oName in pairs(GLDG_Data[i]) do
					if GLDG_Data[i][oName].GreetedMain then
						GLDG_Data[i][oName].GreetedMain = nil
					end
				end
			end
		end
	end
	
	if GLDG_Data.Version and (GLDG_Data.Version < 700102) then
		GLDG_Convert = 1
		for i in pairs(GLDG_Data) do
			if string.find(i, "Realm:") then
				for oName in pairs(GLDG_Data[i]) do
					if GLDG_Data[i][oName].online and (GLDG_Data[i][oName].online == true or GLDG_Data[i][oName].online == 1) then
						GLDG_Data[i][oName].online = nil
					end
				end
			end
		end
	end
	
	if GLDG_Data.Version and (GLDG_Data.Version < 700501) then
		GLDG_Convert = 1
		for i in pairs(GLDG_Data) do
			if string.find(i, "Realm:") then
				for oName in pairs(GLDG_Data[i]) do
					if GLDG_Data[i][oName].MainOrAltInCurrentGuild then
						GLDG_Data[i][oName].MainOrAltInCurrentGuild = nil
					end
				end
			end
		end
	end
	
	local maxGuildMembers = GetGuildRosterInfo and GetNumGuildMembers() or 0
	if maxGuildMembers <= 0 then maxGuildMembers = GetNumGuildMembers() or 0 end

	-- Create GLDG_GuildUID
	GLDG_unique_GuildName = "Guild:"..GLDG.GuildName.."-"..GLDG.Realm

	if GLDG_debug then GLDG_SystemMsg("Importing "..maxGuildMembers.." players, please wait...") end
	
	-- Initialize data structures  
	if not GLDG_Data[GLDG_unique_GuildName] then GLDG_Data[GLDG_unique_GuildName] = {} end
	if not GLDG_Data["Realm:"..GLDG.Realm] then GLDG_Data["Realm:"..GLDG.Realm] = {} end

	local GLDG_PlayerTable = GLDG_Data["Realm:"..GLDG.Realm]
	local GLDG_GuildTable = GLDG_Data[GLDG_unique_GuildName]
	
	-- Import guild members
	for i = 1, maxGuildMembers do
		local fullName, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName = GetGuildRosterInfo(i)
		if fullName then
			local name, realm = string.split("-", fullName)
			if not realm then realm = GLDG.Realm end
			local uName = name.."-"..realm
			
			if not GLDG_GuildTable[uName] then GLDG_GuildTable[uName] = {} end
			if not GLDG_PlayerTable[uName] then GLDG_PlayerTable[uName] = {} end

			-- Update guild member data
			GLDG_GuildTable[uName].class = classFileName
			GLDG_GuildTable[uName].rank = rank
			GLDG_GuildTable[uName].ranknr = rankIndex
			GLDG_GuildTable[uName].level = level
			GLDG_GuildTable[uName].zone = zone
			GLDG_GuildTable[uName].note = note
			GLDG_GuildTable[uName].pnote = officernote
			GLDG_GuildTable[uName].online = online
			GLDG_GuildTable[uName].status = status
			GLDG_GuildTable[uName].lastguild = time()

			-- Update player data
			GLDG_PlayerTable[uName].class = classFileName
			GLDG_PlayerTable[uName].level = level
			GLDG_PlayerTable[uName].rank = rank
			GLDG_PlayerTable[uName].ranknr = rankIndex
			GLDG_PlayerTable[uName].zone = zone
			GLDG_PlayerTable[uName].online = online
			GLDG_PlayerTable[uName].status = status
			GLDG_PlayerTable[uName].guildName = GLDG.GuildName
			GLDG_PlayerTable[uName].lastupdate = time()
		end
	end

	-- Auto-greet functionality
	if GLDG_Data.AutoGreet and GLDG_Data.AutoGreet[GLDG.Realm.." - "..GLDG.Player] then
		if (GLDG_Data.AutoGreet[GLDG.Realm.." - "..GLDG.Player] and (GLDG_autoGreeted == 0)) then
			GLDG_KeyGreet()
			GLDG_autoGreeted = 1
		end
	end
	-- Note: GLDG_RosterImportRunning is now managed by PlayerManager Library
end

function GLDG_RosterImportFull()
	GLDG.Database:RosterImportFull()
end

-------------------------------
-- Database Initialization --
-------------------------------

function GLDG.Database:Initialize()
	-- Initialize default values and greetings
	self:InitializeDefaults()
	self:InitializeBooleanDefaults()
	self:InitializeGreetings()
	
	GLDG:Print(GLDG.Colors:GetColors().help..GLDG_NAME..":|r "..L["Database module initialized"])
end