--[[--------------------------------------------------------
-- GuildGreet, a World of Warcraft social guild assistant --
------------------------------------------------------------
-- 
-- MODULAR ARCHITECTURE (November 2025):
-- This addon has been completely modularized for better maintainability.
-- 
-- Main File: GuildGreet.lua (2,319 lines, reduced from 7,754 lines = 70.09% reduction)
-- - Core initialization and coordination
-- - Event handling and addon lifecycle
-- - Legacy function wrappers for backwards compatibility
-- 
-- Library Modules (15 specialized modules in /libs/):
-- 1. GuildGreet-Utils.lua        - Core utilities and helper functions
-- 2. GuildGreet-Database.lua     - Data persistence and configuration
-- 3. GuildGreet-Colors.lua       - Color management and theming
-- 4. GuildGreet-PlayerManager.lua - Player data and roster operations
-- 5. GuildGreet-Messages.lua     - Chat message handling and automation
-- 6. GuildGreet-GUI.lua          - User interface and option panels
-- 7. GuildGreet-Migration.lua    - Data migration and compatibility
-- 8. GuildGreet-Settings.lua     - Configuration management
-- 9. GuildGreet-Core.lua         - Core addon logic coordination
-- 10. GuildGreet-ChatSystem.lua  - Chat integration and filtering
-- 11. GuildGreet-PlayerUtils.lua - Player-specific utilities
-- 12. GuildGreet-HelpUtils.lua   - Help system and documentation
-- 13. GuildGreet-UIHelpers.lua   - UI utility functions
-- 14. GuildGreet-CleanupUtils.lua - Database cleanup operations
-- 15. GuildGreet-PlayerTooltip.lua - Enhanced player tooltips
-- 
-- Loading Order: libs.xml -> embeds.xml -> GuildGreet.xml -> GuildGreet.lua
-- Namespace: All modules extend the global GLDG object
-- Dependencies: Ace3 framework for professional addon architecture
-- 
-- For developers: Each module has a specific responsibility and clear
-- interfaces. See MODULARIZATION_REPORT.md for complete documentation.
]]----------------------------------------------------------

-- Global addon object for library access
-- Get existing addon if created by libraries, otherwise create new one
GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet", true) or LibStub("AceAddon-3.0"):NewAddon("GuildGreet", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0", "AceComm-3.0", "AceSerializer-3.0")
GuildGreet = GLDG
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", true)

local function Ambiguate(name)
	if type(name) ~= "string" then return tostring(name or "") end
	return string.match(name, "^([^%-]+)") or name
end

function GLDG:ShortName(name)
	return Ambiguate(name)
end

-- Global helper function for cross-version API compatibility
function GLDG_GetAddOnMetadata(addonName, field)
	-- Use modern C_AddOns API if available (WoW 10.0+), fallback to legacy GetAddOnMetadata
	if C_AddOns and C_AddOns.GetAddOnMetadata then
		return C_AddOns.GetAddOnMetadata(addonName, field)
	elseif GetAddOnMetadata then
		return GetAddOnMetadata(addonName, field)
	else
		return "Unknown"
	end
end

-- Database defaults für AceDB-3.0
local defaults = {
	profile = {
		-- Allgemeine Einstellungen (Account-weit konfigurierbar pro Profil)
		ShowNewerVersions = true,
		BigBrother = false,
		ExtendPlayerMenu = true,
		EnableContextMenu = false,
		UseFriends = false,
		ListUp = false,
		ListVisible = false,
		ListSize = 5,
		QueueShowAlias = true,
		QueueShowTwink = true,
		UpdateTime = 0,
		CheckedGuildAlert = false,
		AutoWho = false,
		
		-- Guild-spezifische Einstellungen
		GuildSettings = {
			UseGuildDefault = false,
			RelogTime = 2,
			MinLevelUp = 0,
			GreetAsMain = false,
			Randomize = false,
			Whisper = false,
			WhisperLevelup = false,
			IncludeOwn = false,
			ListNames = false,
			ListNamesOff = false,
			ListLevelUp = false,
			ListLevelUpOff = false,
			ListQuit = false,
			ExtendChat = false,
			ExtendIgnored = false,
			ExtendAlias = false,
			ExtendMain = false,
			AutoAssign = false,
			AutoAssignEgp = false,
			AutoAssignAlias = false,
			AddPostfix = false,
			ShowWhoSpam = false,
			ListAchievments = false,
			SupressGreet = false,
			SupressLevel = false,
			SupressAchievment = false,
		},
		
		-- Farben
		colours = {
			help = "|cFFFFFF7F",
			header = "|c7FFF0000",
			guild = {
				online = "|cFFA0FFA0",
				isOff = "|cFFFFFFFF",
				goOff = "|cFF7F7F7F",
				alias = "|cFFFFA0A0",
				list = "|cFFFF7F00",
				new = "|cFFFF3F3F",
				lvl = "|cFF7F7F7F",
				rank = "|cFFCC00CC",
				relog = "|cFF3FFF3F",
				achievment = "|cFF001FFF",
			},
			friends = {
				online = "|cFFA0FFA0",
				isOff = "|cFFFFFFFF",
				goOff = "|cFF7F7F7F",
				alias = "|cFFFFA0A0",
				list = "|cFFFF7F00",
				new = "|cFFFF3F3F",
				lvl = "|cFF7F7F7F",
				rank = "|cFFCC00CC",
				relog = "|cFF3FFF3F",
				achievment = "|cFF001FFF",
			},
			channel = {
				online = "|cFFA0FFA0",
				isOff = "|cFFFFFFFF",
				goOff = "|cFF7F7F7F",
				alias = "|cFFFFA0A0",
				list = "|cFFFF7F00",
				new = "|cFFFF3F3F",
				lvl = "|cFF7F7F7F",
				rank = "|cFFCC00CC",
				relog = "|cFF3FFF3F",
				achievment = "|cFF001FFF",
			},
		},
		
		-- Filter-Einstellungen
		ShowIgnore = false,
		ShowAlt = false,
		GroupAlt = false,
		FilterUnassigned = false,
		FilterOnline = false,
		FilterMyFriends = false,
		FilterWithFriends = false,
		FilterCurrentChannel = false,
		FilterWithChannel = false,
		
		-- Frame-Optionen
		Frameopts = {},
	},
	
	char = {
		-- Charakterspezifische Daten (automatisch pro Charakter getrennt)
		main = nil,
		own = false,
	},
	
	global = {
		-- Account-weit über alle Charaktere und Realms
		BigBrother = {},
		GreetCollections = {},
		GuildAlias = {},
	},
	
	realm = {
		-- Realm-spezifisch (alle Charaktere auf diesem Realm)
		-- Spielerdaten pro Gilde gespeichert (guildPlayers[guildName][playerName])
		guildPlayers = {},
		-- Legacy-Spielerdaten (wird automatisch in guildPlayers[guildName] migriert)
		players = {},
		
		-- Begrüßungsnachrichten (ersetzt GLDG_DataGreet)
		greetings = {
			Greet = {},
			GreetBack = {},
			Welcome = {},
			NewRank = {},
			NewLevel = {},
			Bye = {},
			Night = {},
			Guild = {},
			Channel = {},
			ByeGuild = {},
			NightGuild = {},
			ByeChannel = {},
			NightChannel = {},
			LaterGuild = {},
			LaterChannel = {},
			Achievment = {},
		},
		
		-- Realm-spezifische Settings
		PlayerChatFrame = {},
		ChannelNames = {},
		Collections = {},
		Custom = {},
		Ranks = {},
	}
}

-- Binding names
BINDING_HEADER_GUILDGREET = L["GuildGreet"]
BINDING_NAME_GUILDGREETCONFIG = L["Open config window"]
BINDING_NAME_GUILDGREETCLEAR = L["Clear greet list"]
BINDING_NAME_GUILDGREETTEST = L["Test trigger"]
BINDING_NAME_GUILDGREETTESTL = L["Test trigger"]
BINDING_NAME_GUILDGREETGREETGUILD = L["Greet Guild and Channel"]
BINDING_NAME_GUILDGREETBYEGUILD = L["Say goodbye to guild and channel"]
BINDING_NAME_GUILDGREETLATERGUILD = L["Say see you later to guild and channel"]

-- Addon constants (now moved to OnInitialize as GLDG instance properties)
-- GLDG.NAME, GLDG.GUI, GLDG.LIST, GLDG.COLOUR, GLDG.VERSION
-- Legacy references for backwards compatibility:
GLDG_NAME 	= "GuildGreet"
GLDG_GUI	= "GuildGreetFrame"		-- Name of GUI config window
GLDG_LIST	= "GuildGreetList"		-- Name of GUI player list
GLDG_COLOUR	= "GuildGreetColourFrame"	-- Name of colour picker addition
GDLG_VNMBR	= 100000			-- Number code for this version

-- Table linking tabs to frames
GLDG_Tab2Frame = {}
GLDG_Tab2Frame.Tab1 = L["Settings"]
GLDG_Tab2Frame.Tab2 = L["Greetings"]
GLDG_Tab2Frame.Tab3 = L["Players"]
GLDG_Tab2Frame.Tab4 = L["Cleanup"]
GLDG_Tab2Frame.Tab5 = L["Colour"]


GLDG_SubTab2Frame = {}
GLDG_SubTab2Frame.Tab1 = L["General"]
GLDG_SubTab2Frame.Tab2 = L["Chat"]
GLDG_SubTab2Frame.Tab3 = L["Greeting"]
--GLDG_SubTab2Frame.Tab4 = "Debug"
GLDG_SubTab2Frame.Tab4 = L["Other"]


-- Strings we look for
GLDG_ONLINE 		= ".*%[(.+)%]%S*"..string.sub(ERR_FRIEND_ONLINE_SS, 20)
-- Fix for RealUI 8 users - split long line for readability
local online_pattern = string.gsub(ERR_FRIEND_ONLINE_SS, "|cff00ff00online|r", "online")
GLDG_ONLINE 		= ".*%[(.+)%]%S*"..string.sub(online_pattern, 20)
GLDG_OFFLINE		= string.format(ERR_FRIEND_OFFLINE_S, "(.+)")
GLDG_JOINED			= string.format(ERR_GUILD_JOIN_S, "(.+)")
GLDG_PROMO			= string.format(ERR_GUILD_PROMOTE_SSS, "(.+)", "(.+)", "(.+)")
GLDG_DEMOTE			= string.format(ERR_GUILD_DEMOTE_SSS, ".+", "(.+)", "(.+)")
GLDG_ACHIEVE    	= string.format(ACHIEVEMENT_BROADCAST, "(.+)", "(.+)")

GLDG_DEFAULT_ONLINE_COLOUR			= "|cFFA0FFA0"
GLDG_DEFAULT_IS_OFFLINE_COLOUR		= "|cFFFFFFFF"
GLDG_DEFAULT_GOES_OFFLINE_COLOUR	= "|cFF7F7F7F"
GLDG_DEFAULT_HELP_COLOUR			= "|cFFFFFF7F"
GLDG_DEFAULT_ALIAS_COLOUR			= "|cFFFFA0A0"
GLDG_DEFAULT_HEADER_COLOUR			= "|c7FFF0000"

GLDG_DEFAULT_LIST_COLOUR			= "|cFFFF7F00"
GLDG_DEFAULT_NEW_COLOUR				= "|cFFFF3F3F"
GLDG_DEFAULT_LVL_COLOUR				= "|cFF7F7F7F"
GLDG_DEFAULT_RANK_COLOUR			= "|cFFCC00CC"
GLDG_DEFAULT_RELOG_COLOUR			= "|cFF3FFF3F"
GLDG_DEFAULT_ACHIEVMENT_COLOUR		= "|cFF001FFF"

GLDG_ONLINE_COLOUR			= GLDG_DEFAULT_ONLINE_COLOUR
GLDG_IS_OFFLINE_COLOUR		= GLDG_DEFAULT_IS_OFFLINE_COLOUR
GLDG_GOES_OFFLINE_COLOUR	= GLDG_DEFAULT_GOES_OFFLINE_COLOUR
GLDG_ALIAS_COLOUR			= GLDG_DEFAULT_ALIAS_COLOUR

GLDG_LEVEL_CAP = 80

-- Default greeting messages (missing constants)
GLDG_GREET = {"Hello %t!", "Hey %t!", "Hi there %t!"}
GLDG_GREETBACK = {"Hi %s!", "Hello %s!", "Hey %s!"}  
GLDG_WELCOME = {"Welcome %t!", "Welcome to the guild %t!"}
GLDG_RANK = {"Congratulations on your promotion %t!", "Gratz on the new rank %t!"}
GLDG_LEVEL = {"Congratulations on level %l %t!", "Gratz on %l %t!"}
GLDG_BYE = {"Goodbye %t!", "See you later %t!", "Take care %t!"}
GLDG_NIGHT = {"Good night %t!", "Sleep well %t!"}
GLDG_GUILD = {"Hello guild!", "Hi everyone!"}
GLDG_CHANNEL = {"Hello channel!", "Hi all!"}
GLDG_BYE_GUILD = {"Goodbye guild!", "See you later everyone!"}
GLDG_NIGHT_GUILD = {"Good night guild!", "Sleep well everyone!"}
GLDG_BYE_CHANNEL = {"Bye channel!", "See you later!"}
GLDG_NIGHT_CHANNEL = {"Good night channel!", "Sleep well!"}
GLDG_LATER_GUILD = {"See you later guild!", "Until next time!"}
GLDG_LATER_CHANNEL = {"See you later channel!", "Until next time!"}
GLDG_ACHIEVMENT = {"Congratulations on your achievement %t!", "Nice achievement %t!"}

-- Global variables - LEGACY (will be replaced by compatibility layer in OnInitialize)
-- These declarations are kept temporarily, but will be overwritten with metatables
-- that redirect all access to self.db.profile/realm/global/*
GLDG_Online = {}
GLDG_DataChar = {}
GLDG_DataGreet = {}
GLDG_Data = {}
GLDG_Queue = {}
GLDG_RankUpdate = {}
GLDG_BigBrother = {}

-- Initialize core variables for the addon
GLDG.Realm = nil
GLDG.Player = nil
GLDG.GuildName = nil

GLDG_CONFIG_STRING = nil
GLDG_CONFIG_STRING_A = nil
GLDG_CONFIG_STRING_B = nil
GLDG_CONFIG_STRING_C = nil
GLDG_CONFIG_STRING_D = nil

--------------------------
-- _01_ Addon Variables --
--------------------------

-- NOTE: The above legacy GLDG_Data* variables are overwritten in OnInitialize()
-- with metatables that redirect to AceDB structure (self.db.*)

-- Legacy pointers (kept for backwards compatibility during migration)
GLDGL_DataChar = nil		    -- Legacy pointer (will be handled by metatable)

-- Runtime variables (not saved)
GLDG_Offline = {}		-- Time of player going offline
GLDG_RankUpdate = {}	-- Set with time for all players getting promoted during the session
GLDG_Queue = {}			-- List of players waiting to be greeted

-- Configuration: greetings tab
GLDG_SelColName = nil		-- Name of the currently selected collection
GLDG_NumColRows = 5		-- Maximum number of collections that can be displayed
GLDG_ChangeName = nil		-- Name of the setting to be changed
GLDG_Selection = "Greet"	-- Selected greeting category
GLDG_SelMsgNum = nil		-- Number of the currently selected message
GLDG_NumSelRows = 5		-- Maximum number of greetings that can be displayed
GLDG_GreetOffset = 0		-- Offset for displaying greetings

-- Configuration: players tab
GLDG_SelPlrName = nil		-- Name of the currently selected player
GLDG_NumPlrRows = 20		-- Maximum number of players that can be displayed
GLDG_SortedList = {}		-- Sorted list of members of your guild, excluding your own characters
GLDG_PlayerOffset = 0		-- Offset for displaying players
GLDG_NumMain = 0		-- Number of players defined as main
GLDG_NumAlts = 0		-- Number of players that are alts for current selected player
GLDG_NumSubRows = 9		-- Maximum number of mains that can be displayed on subframe

-- update timer
GLDG_UPDATE_TIME = 10		-- Number of seconds to query guild and friends list (default)

-- channel parse counter
GLDG_unregister = 0		-- Number of pending requests

-- auto greet flag
GLDG_autoGreeted = 0		-- To make sure auto greet is only done once per login

-- auto check consistency
GLDG_autoConsistencyCheckReady = nil
GLDG_autoConsistencyChecked = nil

------------------------
-- _02_ Addon Startup --
------------------------

------------------------------------------------------------
function GLDG:OnLoad()
	-- Events monitored by Event Handler
	self:RegisterEvent("ADDON_LOADED", "OnEvent")
	self:RegisterEvent("VARIABLES_LOADED", "OnEvent")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")

	-- Modern AceConsole slash command registration
	self:RegisterChatCommand("gg", "SlashHandler")
	self:RegisterChatCommand("guildgreet", "SlashHandler")
end

------------------------------------------------------------
function GLDG:OnInitialize()
	-- AceDB-3.0 Database Initialisierung
	self.db = LibStub("AceDB-3.0"):New("GuildGreetDB", defaults, true)
	GLDG.db = self.db  -- Make db accessible globally for all modules

	-- Set addon constants as instance properties
	self.NAME = "GuildGreet"
	self.GUI = "GuildGreetFrame"
	self.LIST = "GuildGreetList"
	self.COLOUR = "GuildGreetColourFrame"
	self.VERSION = 100000

	-- Addon-Instanz Variablen & globale Legacy-Laufzeitvariablen
	GLDG.Realm = GetRealmName()
	GLDG.Player = UnitName("player")
	self.shortName = GLDG.Player
	GLDG_shortName = GLDG.Player
	self.GuildName = nil
	self.GuildAlias = nil
	GLDG_GuildAlias = nil
	self.GuildLeader = nil
	GLDG_GuildLeader = nil
	self.unique_GuildName = ""
	GLDG_unique_GuildName = ""
	self.ginfotxt = nil
	GLDG_ginfotxt = nil
	self.config_from_guild = nil
	GLDG_config_from_guild = nil
	self.corrupted_config_from_guild = nil
	GLDG_corrupted_config_from_guild = nil
	self.NewGuild = nil
	GLDG_NewGuild = nil
	self.InitialGuildUpdate = nil
	GLDG_InitialGuildUpdate = nil
	self.InitialFriendsUpdate = nil
	GLDG_InitialFriendsUpdate = nil
	self.UpdateRequest = 0
	GLDG_UpdateRequest = 0
	self.UpdateRequestFriends = 0
	GLDG_UpdateRequestFriends = 0
	self.InitComplete = nil
	GLDG_InitComplete = nil
	self.ReadNotes = 1
	GLDG_ReadNotes = 1
	self.RosterImportRunning = 0
	GLDG_RosterImportRunning = 0
	self.InitCheck = 0
	GLDG_InitCheck = 0
	self.ChangesText = {}
	GLDG_ChangesText = self.ChangesText
	self.Online = {}
	GLDG_Online = self.Online

	-- Synchronize direct table references for Lua 5.1 pairs() compatibility
	self:SyncDatabaseReferences()

	-- Register AceDB profile callbacks
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")

	-- Initialize Libraries (must be done after database initialization)
	if self.Utils then self.Utils:Initialize() end
	if self.Colors then self.Colors:Initialize() end
	if self.Database then self.Database:Initialize() end
	if GLDG.PlayerManager then GLDG.PlayerManager:Initialize() end
	if self.Messages then self.Messages:Initialize() end
	if self.Migration then self.Migration:Initialize() end

	-- Re-sync after library initialization
	self:SyncDatabaseReferences()

	-- Register slash commands early so they are available immediately
	self:RegisterSlashCommands()
end

function GLDG:RegisterSlashCommands()
	self:RegisterChatCommand("gg", "SlashHandler")
	self:RegisterChatCommand("guildgreet", "SlashHandler")
	self:RegisterChatCommand("gldg", "SlashHandler")

	SLASH_GUILDGREET1 = "/gg"
	SLASH_GUILDGREET2 = "/guildgreet"
	SLASH_GUILDGREET3 = "/gldg"
	SlashCmdList["GUILDGREET"] = function(msg)
		GLDG:SlashHandler(msg)
	end
	if hash_SlashCmdList then
		hash_SlashCmdList["/GG"] = nil
		hash_SlashCmdList["/GUILDGREET"] = nil
		hash_SlashCmdList["/GLDG"] = nil
	end
end

function GLDG:OnEnable()
	-- Register slash commands
	self:RegisterSlashCommands()

	-- Register core events via AceEvent-3.0 (handler: OnEvent)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
	self:RegisterEvent("VARIABLES_LOADED", "OnEvent")
	self:RegisterEvent("GUILD_ROSTER_UPDATE", "OnEvent")
	self:RegisterEvent("PLAYER_GUILD_UPDATE", "OnEvent")
	self:RegisterEvent("FRIENDLIST_UPDATE", "OnEvent")
	self:RegisterEvent("CHAT_MSG_SYSTEM", "OnEvent")
	self:RegisterEvent("CHAT_MSG_CHANNEL_JOIN", "OnEvent")
	self:RegisterEvent("CHAT_MSG_CHANNEL_LEAVE", "OnEvent")
	self:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE", "OnEvent")
	self:RegisterEvent("CHAT_MSG_ADDON", "OnEvent")
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "OnEvent")
	self:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT", "OnEvent")
	self:RegisterEvent("CHAT_MSG_ACHIEVEMENT", "OnEvent")
	self:RegisterEvent("WHO_LIST_UPDATE", "OnEvent")

	-- Ensure greeting queue frame exists
	self:CreateQueueFrame()

	-- Run full initialization if not yet done
	if not GLDG_InitComplete then
		GLDG_Init()
	end

	-- Periodic update timer (replaces legacy XML <OnUpdate>)
	if not self.updateTimer then
		self.updateTimer = self:ScheduleRepeatingTimer("OnUpdateTimer", 1.0)
	end
end

function GLDG:OnUpdateTimer()
	if self.Utils and self.Utils.OnUpdate then
		self.Utils:OnUpdate(self, 1.0)
	end
end

function GLDG:OnProfileChanged()
	self:SyncDatabaseReferences()
	if self.Colors and self.Colors.Initialize then
		self.Colors:Initialize()
	end
	self:ShowQueue()
	if self.RefreshConfigUI then
		self:RefreshConfigUI()
	end
end

------------------------------------------------------------
-- AceDB Helper Functions
------------------------------------------------------------

-- Profile data access (user settings)
function GLDG:GetGuildSetting(key)
	return self.db.profile.GuildSettings[key]
end

function GLDG:SetGuildSetting(key, value)
	self.db.profile.GuildSettings[key] = value
end

function GLDG:GetProfileData(key)
	return self.db.profile[key]
end

function GLDG:SetProfileData(key, value)
	self.db.profile[key] = value
end

-- Realm data access (per-guild on current realm)
function GLDG:GetPlayerData(playerName, key)
	local tbl = GLDG_DataChar or self.db.realm.players
	if not tbl[playerName] then
		tbl[playerName] = {}
	end
	if key then
		return tbl[playerName][key]
	else
		return tbl[playerName]
	end
end

function GLDG:SetPlayerData(playerName, key, value)
	local tbl = GLDG_DataChar or self.db.realm.players
	if not tbl[playerName] then
		tbl[playerName] = {}
	end
	tbl[playerName][key] = value
end

function GLDG:GetCurrentGuildName()
	if IsInGuild and not IsInGuild() then
		self.GuildName = ""
		self.unique_GuildName = ""
		GLDG_unique_GuildName = ""
		return ""
	end
	local gName = (GetGuildInfo and GetGuildInfo("player")) or self.GuildName or ""
	if self.FormatGuildDisplay then
		gName = self:FormatGuildDisplay(gName)
	else
		gName = string.gsub(gName, "^Guild:", "")
		gName = string.gsub(gName, "@.*$", "")
	end
	self.GuildName = gName
	if gName == "" then
		self.unique_GuildName = ""
		GLDG_unique_GuildName = ""
	elseif not self.unique_GuildName or self.unique_GuildName == "" then
		self.unique_GuildName = gName
		GLDG_unique_GuildName = gName
	end
	return gName
end

function GLDG:GetGreetings(category)
	return self.db.realm.greetings[category] or {}
end

function GLDG:SetGreetings(category, messages)
	self.db.realm.greetings[category] = messages
end

-- Global data access (account-wide)
function GLDG:GetGlobalData(key)
	return self.db.global[key]
end

function GLDG:SetGlobalData(key, value)
	self.db.global[key] = value
end

-- Character data access (this character only)
function GLDG:GetCharData(key)
	return self.db.char[key]
end

function GLDG:SetCharData(key, value)
	self.db.char[key] = value
end

------------------------------------------------------------
-- Database Reference Synchronization
-- Uses direct AceDB table references so Lua 5.1 pairs() works properly
------------------------------------------------------------
function GLDG:SyncDatabaseReferences()
	if not self.db then return end

	self.db.profile.GuildSettings = self.db.profile.GuildSettings or {}
	self.db.profile.colours = self.db.profile.colours or {}
	self.db.profile.Frameopts = self.db.profile.Frameopts or {}
	self.db.profile.AutoGreet = self.db.profile.AutoGreet or {}
	self.db.profile.GreetGuild = self.db.profile.GreetGuild or {}
	self.db.profile.GreetChannel = self.db.profile.GreetChannel or {}

	self.db.realm.guildPlayers = self.db.realm.guildPlayers or {}
	self.db.realm.players = self.db.realm.players or {}
	self.db.realm.greetings = self.db.realm.greetings or {}
	self.db.realm.PlayerChatFrame = self.db.realm.PlayerChatFrame or {}
	self.db.realm.ChannelNames = self.db.realm.ChannelNames or {}
	self.db.realm.Collections = self.db.realm.Collections or {}
	self.db.realm.Custom = self.db.realm.Custom or {}
	self.db.realm.Ranks = self.db.realm.Ranks or {}

	self.db.global.BigBrother = self.db.global.BigBrother or {}
	self.db.global.GreetCollections = self.db.global.GreetCollections or {}
	self.db.global.GuildAlias = self.db.global.GuildAlias or {}

	-- Link shared realm/global subtables into profile so GLDG_Data.<key> accesses live tables
	self.db.profile.PlayerChatFrame = self.db.realm.PlayerChatFrame
	self.db.profile.ChannelNames = self.db.realm.ChannelNames
	self.db.profile.Collections = self.db.realm.Collections
	self.db.profile.Custom = self.db.realm.Custom
	self.db.profile.Ranks = self.db.realm.Ranks
	self.db.profile.GreetCollections = self.db.global.GreetCollections
	self.db.profile.GuildAlias = self.db.global.GuildAlias

	-- Migrate any flat self.db.realm.players entries into per-guild self.db.realm.guildPlayers[guildName]
	local gp = self.db.realm.guildPlayers
	if type(self.db.realm.players) == "table" then
		local isSubTable = false
		for _, gTbl in pairs(gp) do
			if gTbl == self.db.realm.players then
				isSubTable = true
				break
			end
		end
		if not isSubTable then
			for playerName, pData in pairs(self.db.realm.players) do
				if type(pData) == "table" then
					local pGuild = (type(pData.guild) == "string" and pData.guild ~= "")
						and (self.FormatGuildDisplay and self:FormatGuildDisplay(pData.guild) or pData.guild)
						or nil
					if pGuild and pGuild ~= "" then
						pData.guild = pGuild
						gp[pGuild] = gp[pGuild] or {}
						if not gp[pGuild][playerName] then
							gp[pGuild][playerName] = pData
						end
					end
				end
				self.db.realm.players[playerName] = nil
			end
		end
	end

	-- Normalize any legacy guild keys in self.db.realm.guildPlayers
	if self.FormatGuildDisplay then
		local keysToNormalize = {}
		for gKey in pairs(gp) do
			if type(gKey) == "string" then
				local cleanKey = self:FormatGuildDisplay(gKey)
				if cleanKey ~= "" and cleanKey ~= gKey then
					table.insert(keysToNormalize, { old = gKey, clean = cleanKey })
				end
			end
		end
		for _, item in ipairs(keysToNormalize) do
			gp[item.clean] = gp[item.clean] or {}
			if type(gp[item.old]) == "table" then
				for pName, pData in pairs(gp[item.old]) do
					if type(pData) == "table" then
						pData.guild = item.clean
						gp[item.clean][pName] = gp[item.clean][pName] or pData
					end
				end
			end
			gp[item.old] = nil
		end
	end

	-- Point GLDG_DataChar strictly to the current character's guild table (or an empty table when guildless)
	local curGuild = self:GetCurrentGuildName()
	if curGuild ~= "" then
		gp[curGuild] = gp[curGuild] or {}
		GLDG_DataChar = gp[curGuild]
	else
		self._emptyGuildlessDataChar = self._emptyGuildlessDataChar or {}
		for k in pairs(self._emptyGuildlessDataChar) do
			self._emptyGuildlessDataChar[k] = nil
		end
		GLDG_DataChar = self._emptyGuildlessDataChar
	end

	-- Direct table pointers (Lua 5.1 pairs() compatible!)
	GLDG_Data = self.db.profile
	GLDG_DataGreet = self.db.realm.greetings
	GLDG_BigBrother = self.db.global.BigBrother

	-- Ensure default greetings are populated
	if self.Database and self.Database.InitializeGreetings then
		self.Database:InitializeGreetings()
	end

	-- Mirror greeting arrays on GLDG_Data for legacy GUI/Collection code
	for k, v in pairs(self.db.realm.greetings) do
		self.db.profile[k] = v
	end
end

function GLDG:InitializeCompatibilityLayer()
	self:SyncDatabaseReferences()
end

------------------------------------------------------------
-- Moderne Print-Helper Funktionen
------------------------------------------------------------
function GLDG:PrintInfo(message)
	self:Print(tostring(message or ""))
end

function GLDG:PrintError(message)
	self:Print("|cffff4040" .. tostring(message or "") .. "|r")
end

function GLDG:PrintHelp(message)
	local helpCol = (self.GetColors and self:GetColors() and self:GetColors().help) or "|cFFFFFF7F"
	self:Print(helpCol .. tostring(message or "") .. "|r")
end

-- Legacy Kompatibilität für Farben - wird jetzt von Colors Library verwaltet
function GLDG:GetColors()
	if self.Colors then
		return self.Colors:GetColors()
	else
		-- Fallback während der Migration
		return {
			help = "|cff00ff00",
			guild = {},
			friends = {},
			channel = {},
			header = "|c7FFF0000"
		}
	end
end

------------------------
-- _03_ Event Handler --
------------------------

function GLDG:OnEvent(event, ...)
	GLDG.Messages:OnEvent(self, event, ...)
end


-------------------------------
-- _04_ Addon Initialization --
-------------------------------

function GLDG_Init()
	GLDG_InitFull()
end

function GLDG_InitFull()
	GLDG.Utils:InitFull()
end

------------------------------------------------------------
function GLDG_UpdatePlayerCheckboxes()
	GLDG.Utils:UpdatePlayerCheckboxes()
end


function GLDG_InitRoster()
	GLDG.Utils:InitRoster()
end


function GLDG_OnUpdate(self, elapsed)
	return GLDG.Utils:OnUpdate(self, elapsed)
end


------------------------------
-- _05_ Guild Roster Import --
------------------------------

function GLDG_RosterImport()
	GLDG_RosterImportFull()
end

function GLDG_RosterImportFull()
	GLDG.Database:RosterImportFull()
end

------------------------------------------------------------
function GLDG_findMainname(_main, _pl)
	return GLDG.PlayerManager:FindMainName(_main, _pl)
end
------------------------------------------------------------
function GLDG_RosterPurge()
	return GLDG.PlayerManager:RosterPurge()
end


------------------------------------------
-- assemble list of alts of a main char --
function GLDG_FindAlts(mainName, playerName, colourise)
	return GLDG.PlayerManager:FindAlts(mainName, playerName, colourise)
end


------------------------------------------
-- get a list of players that are on --
------------------------------------------
function GLDG_getOnlineList()
	return GLDG.PlayerManager:GetOnlineList()
end

------------------------------------------
-- find player details for a player --
------------------------------------------
function GLDG_findPlayerDetails(playerName)
	return GLDG.PlayerManager:FindPlayerDetails(playerName)
end

------------------------------------------
-- find alias for current player  --
------------------------------------------
function GLDG_findAlias(playerName, colourise)
	return GLDG.PlayerManager:FindAlias(playerName, colourise)
end

function GLDG_ListForPlayer(playerName, allDetails, onList, print, guildOnly)
	return GLDG.PlayerManager:ListForPlayer(playerName, allDetails, onList, print, guildOnly)
end

function GLDG_ListAllPlayers(offline, print, guildOnly)
	return GLDG.PlayerManager:ListAllPlayers(offline, print, guildOnly)
end

function GLDG_MainOrAltInCurrentGuild(name)
	return GLDG.PlayerManager:MainOrAltInCurrentGuild(name)
end

----------------------------------
-- _06_ Monitor System Messages --
----------------------------------

function GLDG_SystemMsg(msg)
	return GLDG.Messages:SystemMsg(msg)
end




----------------------------
-- _07_ Display Greetlist --
----------------------------

local function SaveQueueFramePosition(f)
	if not f or not GLDG.db or not GLDG.db.profile then return end
	local point, _, relativePoint, xOfs, yOfs = f:GetPoint(1)
	if point then
		GLDG.db.profile.QueueFramePos = {
			point = point,
			relativePoint = relativePoint or point,
			x = math.floor((xOfs or 0) + 0.5),
			y = math.floor((yOfs or 0) + 0.5),
		}
		f._posRestored = true
	end
end

local function RestoreQueueFramePosition(f)
	if not f then return end
	local pos = GLDG.db and GLDG.db.profile and GLDG.db.profile.QueueFramePos
	f:ClearAllPoints()
	if type(pos) == "table" and pos.point then
		f:SetPoint(pos.point, UIParent, pos.relativePoint or pos.point, tonumber(pos.x) or 24, tonumber(pos.y) or 120)
		f._posRestored = true
	else
		f:SetPoint("LEFT", UIParent, "LEFT", 24, 120)
	end
end

function GLDG:CreateQueueFrame()
	if _G[GLDG_LIST] then
		return _G[GLDG_LIST]
	end

	local listFrame = CreateFrame("Frame", GLDG_LIST, UIParent, "BackdropTemplate")
	listFrame:SetSize(230, 22)
	RestoreQueueFramePosition(listFrame)
	listFrame:SetFrameStrata("MEDIUM")
	listFrame:SetToplevel(true)
	listFrame:SetClampedToScreen(true)
	listFrame:EnableMouse(true)
	listFrame:SetMovable(true)
	listFrame:RegisterForDrag("LeftButton")
	listFrame:SetScript("OnDragStart", function(f) f:StartMoving() end)
	listFrame:SetScript("OnDragStop", function(f)
		f:StopMovingOrSizing()
		SaveQueueFramePosition(f)
	end)
	listFrame:Hide()

	-- Title bar (anchored TOPLEFT & TOPRIGHT so it always matches listFrame width)
	local titleFrame = CreateFrame("Frame", GLDG_LIST.."Title", listFrame, "BackdropTemplate")
	titleFrame:SetHeight(22)
	titleFrame:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 0, 0)
	titleFrame:SetPoint("TOPRIGHT", listFrame, "TOPRIGHT", 0, 0)
	titleFrame:EnableMouse(true)
	titleFrame:RegisterForDrag("LeftButton")
	titleFrame:SetScript("OnDragStart", function() listFrame:StartMoving() end)
	titleFrame:SetScript("OnDragStop", function()
		listFrame:StopMovingOrSizing()
		SaveQueueFramePosition(listFrame)
	end)
	titleFrame:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = 1,
	})
	titleFrame:SetBackdropColor(0.09, 0.10, 0.13, 0.96)
	titleFrame:SetBackdropBorderColor(0.85, 0.71, 0.29, 0.65)

	local titleTex = titleFrame:CreateTexture(GLDG_LIST.."TitleTexture", "BACKGROUND")
	titleTex:SetAllPoints(titleFrame)
	titleTex:SetColorTexture(0.09, 0.10, 0.13, 0.96)

	local accentLine = titleFrame:CreateTexture(nil, "OVERLAY")
	accentLine:SetHeight(1)
	accentLine:SetPoint("BOTTOMLEFT", titleFrame, "BOTTOMLEFT", 1, 0)
	accentLine:SetPoint("BOTTOMRIGHT", titleFrame, "BOTTOMRIGHT", -1, 0)
	accentLine:SetColorTexture(0.85, 0.71, 0.29, 0.85)

	local titleText = titleFrame:CreateFontString(GLDG_LIST.."TitleText", "OVERLAY", "GameFontNormalSmall")
	titleText:SetPoint("LEFT", titleFrame, "LEFT", 8, 0)
	titleText:SetText("|cffd9b54aGuildGreet|r")

	-- Close / Clear Queue button
	local closeBtn = CreateFrame("Button", GLDG_LIST.."Close", titleFrame, "BackdropTemplate")
	closeBtn:SetSize(18, 18)
	closeBtn:SetPoint("RIGHT", titleFrame, "RIGHT", -2, 0)
	closeBtn:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = 1,
	})
	closeBtn:SetBackdropColor(0.16, 0.17, 0.22, 0.9)
	closeBtn:SetBackdropBorderColor(0.28, 0.30, 0.38, 1)
	local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	closeTxt:SetPoint("CENTER", 0, 0)
	closeTxt:SetText("x")
	closeBtn:SetScript("OnEnter", function(btn)
		btn:SetBackdropColor(0.65, 0.18, 0.18, 1)
		btn:SetBackdropBorderColor(0.90, 0.30, 0.30, 1)
		GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Clear greet list"] or "Clear greet list", 1, 0.82, 0)
		GameTooltip:Show()
	end)
	closeBtn:SetScript("OnLeave", function(btn)
		btn:SetBackdropColor(0.16, 0.17, 0.22, 0.9)
		btn:SetBackdropBorderColor(0.28, 0.30, 0.38, 1)
		GameTooltip:Hide()
	end)
	closeBtn:SetScript("OnClick", function()
		GLDG_ClearList()
	end)

	local function createQueueLine(name, anchorTo, anchorPoint, relativePoint)
		local btn = CreateFrame("Button", name, listFrame, "BackdropTemplate")
		btn:SetSize(230, 20)
		btn:SetPoint(anchorPoint, anchorTo, relativePoint, 0, 0)
		btn:RegisterForClicks("LeftButtonDown", "RightButtonDown")
		btn:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8x8",
			edgeFile = "Interface\\Buttons\\WHITE8x8",
			edgeSize = 1,
		})
		btn:SetBackdropColor(0.06, 0.07, 0.09, 0.94)
		btn:SetBackdropBorderColor(0.20, 0.22, 0.28, 0.85)

		local accentBar = btn:CreateTexture(nil, "OVERLAY")
		accentBar:SetWidth(3)
		accentBar:SetPoint("TOPLEFT", btn, "TOPLEFT", 1, -1)
		accentBar:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 1, 1)
		accentBar:SetColorTexture(0.30, 0.85, 0.39, 0.95)
		btn.accentBar = accentBar

		local text2 = btn:CreateFontString(name.."Text2", "OVERLAY", "GameFontHighlightSmall")
		text2:SetPoint("RIGHT", btn, "RIGHT", -8, 0)
		text2:SetJustifyH("RIGHT")
		text2:SetWordWrap(false)

		local text1 = btn:CreateFontString(name.."Text", "OVERLAY", "GameFontHighlightSmall")
		text1:SetPoint("LEFT", btn, "LEFT", 9, 0)
		text1:SetJustifyH("LEFT")
		text1:SetWordWrap(false)

		btn:SetScript("OnEnter", function(selfBtn)
			selfBtn:SetBackdropColor(0.16, 0.18, 0.24, 0.98)
			selfBtn:SetBackdropBorderColor(0.85, 0.71, 0.29, 0.9)
			GLDG_ShowToolTip(selfBtn, selfBtn:GetName())
		end)
		btn:SetScript("OnLeave", function(selfBtn)
			selfBtn:SetBackdropColor(0.06, 0.07, 0.09, 0.92)
			selfBtn:SetBackdropBorderColor(0.20, 0.22, 0.28, 0.85)
			GameTooltip:Hide()
		end)
		btn:SetScript("OnClick", function(selfBtn, mouseBtn)
			if selfBtn.queueKey then
				GLDG_ClickName(mouseBtn, selfBtn.queueKey)
				return
			end
			local t = _G[selfBtn:GetName().."Text"]
			if t then
				GLDG_ClickName(mouseBtn, t:GetText())
			end
		end)
		btn:Hide()
		return btn
	end

	-- Create downward lines (Line1..15) and upward lines (ULine1..15)
	for i = 1, 15 do
		local prevDown = (i == 1) and titleFrame or _G[GLDG_LIST.."Line"..(i - 1)]
		createQueueLine(GLDG_LIST.."Line"..i, prevDown, "TOP", "BOTTOM")

		local prevUp = (i == 1) and titleFrame or _G[GLDG_LIST.."ULine"..(i - 1)]
		createQueueLine(GLDG_LIST.."ULine"..i, prevUp, "BOTTOM", "TOP")
	end

	return listFrame
end

function GLDG_ShowToolTip(self, element)
	if not element then return end
	local name = self and self.queueKey
	if not name or name == "" then
		local txtObj = _G[element.."Text"]
		if not txtObj then return end
		local raw = txtObj:GetText()
		if not raw or raw == "" then return end
		name = string.sub(raw, 9)
		local _, uRealm = string.split("-", name)
		if not uRealm then
			local prefix = name.."-"
			local len = string.len(prefix)
			for k in pairs(GLDG_DataChar) do
				if string.sub(k, 1, len) == prefix then
					name = k
					break
				end
			end
		end
	end

	local p = GLDG_DataChar and GLDG_DataChar[name]
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(Ambiguate(name, "guild"), 0.85, 0.71, 0.29)
	if p then
		local aliasVal = (p.manualAlias and p.alias and p.alias ~= "" and p.alias)
			or (p.alt and GLDG_DataChar and GLDG_DataChar[p.alt] and GLDG_DataChar[p.alt].manualAlias and GLDG_DataChar[p.alt].alias and GLDG_DataChar[p.alt].alias ~= "" and GLDG_DataChar[p.alt].alias)
			or nil
		if aliasVal then
			GameTooltip:AddDoubleLine(L["First Name / Alias"] or L["Alias"] or "Vorname / Alias", tostring(aliasVal), 0.7, 0.7, 0.7, 1, 0.82, 0.4)
		end
		local mainName = (p.alt and p.alt ~= "" and Ambiguate(p.alt, "guild")) or p.twinkMainName
		if mainName and mainName ~= "" then
			GameTooltip:AddDoubleLine(L["Alt of"] or "Twink von", tostring(mainName), 0.7, 0.7, 0.7, 0.50, 0.85, 1)
		end
		if p.lvl then
			GameTooltip:AddDoubleLine(L["Level"] or "Stufe", tostring(p.lvl).." "..tostring(p.classDisplayName or p.class or ""), 0.7, 0.7, 0.7, 1, 1, 1)
		end
		if p.rankname then
			GameTooltip:AddDoubleLine(L["Rank"] or "Rang", tostring(p.rankname), 0.7, 0.7, 0.7, 1, 1, 1)
		end
		if p.new then
			GameTooltip:AddDoubleLine(L["Status"] or "Status", L["New in guild"] or "Neu in Gilde", 0.7, 0.7, 0.7, 1, 0.35, 0.35)
		elseif p.achievment then
			GameTooltip:AddDoubleLine(L["Last achievment"] or "Erfolg", tostring(p.achievment), 0.7, 0.7, 0.7, 0.4, 0.7, 1)
		elseif p.newrank then
			GameTooltip:AddDoubleLine(L["Status"] or "Status", (L["promotion"] or "Beförderung") .. (p.rankname and (" (" .. p.rankname .. ")") or ""), 0.7, 0.7, 0.7, 0.85, 0.4, 1)
		elseif p.newlvl then
			GameTooltip:AddDoubleLine(L["Status"] or "Status", string.format("%s %s!", L["Level"] or "Stufe", tostring(p.lvl or "?")), 0.7, 0.7, 0.7, 1, 0.85, 0.3)
		elseif GLDG_Offline and GLDG_Offline[name] then
			GameTooltip:AddDoubleLine(L["Status"] or "Status", L["Relog"] or "Relog", 0.7, 0.7, 0.7, 0.25, 1, 0.72)
		else
			GameTooltip:AddDoubleLine(L["Status"] or "Status", L["Logged in"] or "Eingeloggt", 0.7, 0.7, 0.7, 0.3, 0.85, 0.39)
		end
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("|cff4cd964" .. (L["Left-Click"] or "Linksklick") .. ":|r " .. (L["Greeting"] or "Begrüßen") .. "  |cffe64d4d" .. (L["Right-Click"] or "Rechtsklick") .. ":|r " .. (L["Dismiss"] or "Ausblenden"), 0.8, 0.8, 0.8)
	GameTooltip:Show()
end

function GLDG:ShowQueue()
	local listFrame = self:CreateQueueFrame()
	if not listFrame or not GLDG_Data then return end
	if not listFrame._posRestored and self.db and self.db.profile and self.db.profile.QueueFramePos then
		RestoreQueueFramePosition(listFrame)
	end

	-- Hide all lines first
	for i = 1, 15 do
		local dLine = _G[GLDG_LIST.."Line"..i]
		local uLine = _G[GLDG_LIST.."ULine"..i]
		if dLine then dLine:Hide(); dLine.queueKey = nil end
		if uLine then uLine:Hide(); uLine.queueKey = nil end
	end

	-- Collect and sort queued players
	local sorted = {}
	for name in pairs(GLDG_Queue or {}) do
		table.insert(sorted, name)
	end
	table.sort(sorted)

	local count = #sorted
	if count == 0 and not GLDG_Data.ListVisible then
		listFrame:Hide()
		return
	end

	listFrame:Show()
	local titleFrame = _G[GLDG_LIST.."Title"]
	local titleText = _G[GLDG_LIST.."TitleText"]
	if titleText then
		if self.UIStyle then self.UIStyle:ApplyFont(titleText, 0) end
		if count > 0 then
			titleText:SetText(string.format("|cffd9b54aGuildGreet|r |cff9499a6(%d)|r", count))
		else
			titleText:SetText("|cffd9b54aGuildGreet|r")
		end
	end

	local maxLines = math.min(math.max(tonumber(GLDG_Data.ListSize) or 5, 1), 15)
	local visibleCount = math.min(count, maxLines)
	local prefix = GLDG_Data.ListUp and (GLDG_LIST.."ULine") or (GLDG_LIST.."Line")
	local fontSize = self.UIStyle and self.UIStyle:GetFontSize() or 13
	local lineHeight = math.max(22, fontSize + 8)
	local titleHeight = math.max(22, lineHeight + 2)
	local baseWidth = math.max(250, math.floor(235 * (fontSize / 12)))
	local headerNeeded = titleText and math.ceil((titleText:GetStringWidth() or 100) + 40) or baseWidth
	local maxRowWidth = math.max(baseWidth, headerNeeded)

	-- First pass: populate texts and measure required row widths so text1 and text2 never overlap
	for i = 1, visibleCount do
		local name = sorted[i]
		local lineBtn = _G[prefix..i]
		local text1 = _G[prefix..i.."Text"]
		local text2 = _G[prefix..i.."Text2"]
		if lineBtn and text1 and text2 then
			lineBtn.queueKey = name
			if self.UIStyle then
				self.UIStyle:ApplyFont(text1, -1)
				self.UIStyle:ApplyFont(text2, -1)
			end
			local logTime = strtrim(GLDG_Queue[name] or "[00:00]")
			local shortName = Ambiguate(name, "guild")
			local p = GLDG_DataChar and GLDG_DataChar[name]

			-- Class color for character name
			local nameHex = "|cffffd166"
			if p and p.enClass and RAID_CLASS_COLORS and RAID_CLASS_COLORS[p.enClass] then
				local c = RAID_CLASS_COLORS[p.enClass]
				if c.colorStr then
					nameHex = "|c" .. c.colorStr
				else
					nameHex = string.format("|cff%02x%02x%02x", (c.r or 1) * 255, (c.g or 1) * 255, (c.b or 1) * 255)
				end
			end

			-- Separately configurable First Name / Alias and Twink -> Main tags (never raw guild notes!)
			local extraTag = ""
			if p then
				local aliasDisp = nil
				if p.manualAlias and p.alias and p.alias ~= "" then
					aliasDisp = p.alias
				elseif p.alt and p.alt ~= "" and GLDG_DataChar[p.alt] and GLDG_DataChar[p.alt].manualAlias and GLDG_DataChar[p.alt].alias and GLDG_DataChar[p.alt].alias ~= "" then
					aliasDisp = GLDG_DataChar[p.alt].alias
				end

				local mainDisp = nil
				if p.alt and p.alt ~= "" then
					mainDisp = Ambiguate(p.alt, "guild")
				elseif p.twinkMainName and p.twinkMainName ~= "" then
					mainDisp = p.twinkMainName
				end

				if GLDG_Data.QueueShowAlias ~= false and aliasDisp and aliasDisp ~= "" then
					extraTag = extraTag .. " |cffffd166[" .. aliasDisp .. "]|r"
				end
				if GLDG_Data.QueueShowTwink ~= false and mainDisp and mainDisp ~= "" then
					extraTag = extraTag .. string.format(" |cff80d8ff(%s: %s)|r", L["Alt"] or "Twink", mainDisp)
				end
			end

			text1:ClearAllPoints()
			text1:SetPoint("LEFT", lineBtn, "LEFT", 9, 0)
			text1:SetTextColor(1, 1, 1, 1)
			text1:SetText(string.format("|cff9499a8%s|r %s%s|r%s", logTime, nameHex, shortName, extraTag))

			-- Event Icon + Status Badge on the right
			local rightInfo = ""
			local accentR, accentG, accentB = 0.30, 0.85, 0.39
			if p and p.new then
				accentR, accentG, accentB = 1.00, 0.35, 0.35
				rightInfo = "|TInterface\\FriendsFrame\\UI-Toast-FriendInviteIcon:14:14:0:0|t |cffff6666" .. (L["New in guild"] or "Neu in Gilde") .. "|r"
			elseif p and p.newrank then
				accentR, accentG, accentB = 0.85, 0.40, 1.00
				local rankLabel = (p.rankname and p.rankname ~= "")
					and ((L["Rank"] or "Rang") .. ": " .. p.rankname)
					or (L["promotion"] or "Beförderung")
				rightInfo = "|TInterface\\GroupFrame\\UI-Group-LeaderIcon:14:14:0:0|t |cffd966ff" .. rankLabel .. "|r"
			elseif p and p.newlvl then
				accentR, accentG, accentB = 1.00, 0.85, 0.30
				rightInfo = "|TInterface\\Icons\\Spell_Holy_Crusade:14:14:0:0:64:64:5:59:5:59|t |cffffd94d" .. string.format("%s %s!", L["Level"] or "Stufe", tostring(p.lvl or "?")) .. "|r"
			elseif p and p.achievment then
				accentR, accentG, accentB = 0.40, 0.70, 1.00
				rightInfo = "|TInterface\\Icons\\Achievement_General:14:14:0:0:64:64:5:59:5:59|t |cff66b3ff" .. (L["Achievment"] or "Erfolg") .. "|r"
			elseif GLDG_Offline and GLDG_Offline[name] then
				accentR, accentG, accentB = 0.25, 1.00, 0.72
				rightInfo = "|TInterface\\FriendsFrame\\StatusIcon-Online:14:14:0:0|t |cff3fffb8" .. (L["Relog"] or "Relog") .. "|r"
			else
				accentR, accentG, accentB = 0.30, 0.85, 0.39
				rightInfo = "|TInterface\\FriendsFrame\\StatusIcon-Online:14:14:0:0|t |cff4cd964" .. (L["Logged in"] or "Eingeloggt") .. "|r"
			end

			if lineBtn.accentBar then
				lineBtn.accentBar:SetColorTexture(accentR, accentG, accentB, 0.95)
			end

			text2:ClearAllPoints()
			text2:SetPoint("RIGHT", lineBtn, "RIGHT", -8, 0)
			text2:SetTextColor(1, 1, 1, 1)
			text2:SetText(rightInfo)

			local w1 = text1:GetStringWidth() or 120
			local w2 = (rightInfo ~= "") and ((text2:GetStringWidth() or 40) + 18) or 0
			local needed = math.ceil(w1 + w2 + 24)
			if needed > maxRowWidth then
				maxRowWidth = needed
			end
		end
	end

	local lineWidth = math.min(maxRowWidth, 520)
	listFrame:SetSize(lineWidth, titleHeight)
	if titleFrame then
		titleFrame:SetHeight(titleHeight)
	end

	-- Second pass: apply unified width and non-overlapping anchors to all visible rows
	for i = 1, visibleCount do
		local lineBtn = _G[prefix..i]
		local text1 = _G[prefix..i.."Text"]
		local text2 = _G[prefix..i.."Text2"]
		if lineBtn and text1 and text2 then
			lineBtn:SetSize(lineWidth, lineHeight)
			lineBtn:ClearAllPoints()
			if GLDG_Data.ListUp then
				lineBtn:SetPoint("BOTTOMLEFT", listFrame, "TOPLEFT", 0, (i - 1) * (lineHeight - 1))
			else
				lineBtn:SetPoint("TOPLEFT", listFrame, "BOTTOMLEFT", 0, -(i - 1) * (lineHeight - 1))
			end
			text1:ClearAllPoints()
			text1:SetPoint("LEFT", lineBtn, "LEFT", 9, 0)
			text1:SetPoint("RIGHT", text2, "LEFT", -10, 0)
			lineBtn:Show()
		end
	end
end

function GLDG_ShowQueue()
	return GLDG:ShowQueue()
end


------------------------
-- _09_ Greet Players --
------------------------

function GLDG_ClickName(button, name)
	return GLDG.Core:ClickName(button, name)
end

------------------------------------------------------------
function GLDG_ClearList()
	return GLDG.UIHelpers:ClearList()
end

------------------------------------------------------------
-- Player utility functions delegated to PlayerUtils library
function GLDG_CleanupPlayer(name)
	return GLDG.PlayerUtils:CleanupPlayer(name)
end

------------------------------------------------------------
-- Level-based message filtering (submitted by lebanoncyberspace, modified by Urbin)
function GLDG_FilterLevels(message, level)
	return GLDG.PlayerUtils:FilterLevels(message, level)
end

------------------------------------------------------------
-- Time-based message filtering
function GLDG_FilterTime(message, hour, minute)
	return GLDG.PlayerUtils:FilterTime(message, hour, minute)
end

------------------------------------------------------------
function GLDG_FilterMessages(player, list)
	return GLDG.Messages:FilterMessages(player, list)
end

------------------------------------------------------------
function GLDG_ParseCustomMessage(cname, name, msg)
	return GLDG.Messages:ParseCustomMessage(cname, name, msg)
end

------------------------------------------------------------
function GLDG_SendGreet(name, testing)
	return GLDG.Messages:SendGreet(name, testing)
end

------------------------------------------
-- say goodbye to person, using main name
------------------------------------------
function GLDG_SendBye(name, testing)
	return GLDG.Messages:SendBye(name, testing)
end

------------------------------------------------------------
function GLDG_KeyGreet()
	if (GLDG_Data.GreetGuild[GLDG.Realm.." - "..GLDG.Player]) then
		GLDG_GreetGuild()
	end
	if (GLDG_Data.GreetChannel[GLDG.Realm.." - "..GLDG.Player]) then
		GLDG_GreetChannel()
	end
end



------------------------------------------------------------
function GLDG_KeyBye()
	if (GLDG_Data.GreetGuild[GLDG.Realm.." - "..GLDG.Player]) then
		GLDG_ByeGuild()
	end
	if (GLDG_Data.GreetChannel[GLDG.Realm.." - "..GLDG.Player]) then
		GLDG_ByeChannel()
	end
end

------------------------------------------------------------
function GLDG_ByeGuild()
	if (GLDG_unique_GuildName=="") then return end

	local list = GLDG_DataGreet.ByeGuild
	-- if time is between 20:00 and 06:00 use night mode
	local hour, _ = GLDG_GetTime(); -- min not used
	if ((hour >= 20) or (hour <=5)) then
		list = GLDG_DataGreet.NightGuild;
	end
	list = GLDG_FilterMessages(player, list)

	local greetSize = GLDG_TableSize(list)
	if (greetSize ==0 ) then return end

	local msg = list[math.random(greetSize)]
	msg = GLDG_ParseCustomMessage("", "", msg)

	-- Send greeting (still parse for %s for backwards compatibility)
	SendChatMessage(string.format(msg, GLDG_GuildAlias), "GUILD")
end

------------------------------------------------------------
function GLDG_ByeChannel()
	local list = GLDG_DataGreet.ByeChannel
	-- if time is between 20:00 and 05:00 use night mode
	local hour, _ = GLDG_GetTime(); -- min not used
	if ((hour >= 20) or (hour <=5)) then
		list = GLDG_DataGreet.NightChannel;
	end
	list = GLDG_FilterMessages(player, list)

	local greetSize = GLDG_TableSize(list)
	if (greetSize ==0 ) then return end

	local msg = list[math.random(greetSize)]
	msg = GLDG_ParseCustomMessage("", "", msg)

	-- Send greeting
	local channel = GetChannelName(GLDG_ChannelName)
	if (channel) then
		SendChatMessage(msg, "CHANNEL", nil, tostring(channel))
	end
end

------------------------------------------------------------
function GLDG_KeyLater()
	if (GLDG_Data.GreetGuild[GLDG.Realm.." - "..GLDG.Player]) then
		GLDG_LaterGuild()
	end
	if (GLDG_Data.GreetChannel[GLDG.Realm.." - "..GLDG.Player]) then
		GLDG_LaterChannel()
	end
end

------------------------------------------------------------
function GLDG_LaterGuild()
	if (GLDG_unique_GuildName=="") then return end

	local list = GLDG_DataGreet.LaterGuild
	list = GLDG_FilterMessages(nil, list)

	local greetSize = GLDG_TableSize(list)
	if (greetSize ==0 ) then return end

	local msg = list[math.random(greetSize)]
	msg = GLDG_ParseCustomMessage("", "", msg)

	-- Send greeting (still parse for %s for backwards compatibility)
	SendChatMessage(string.format(msg, GLDG_GuildAlias), "GUILD")
end

------------------------------------------------------------
function GLDG_LaterChannel()
	local list = GLDG_DataGreet.LaterChannel
	list = GLDG_FilterMessages(nil, list)

	local greetSize = GLDG_TableSize(list)
	if (greetSize ==0 ) then return end

	local msg = list[math.random(greetSize)]
	msg = GLDG_ParseCustomMessage("", "", msg)

	-- Send greeting
	local channel = GetChannelName(GLDG_ChannelName)
	if (channel) then
		SendChatMessage(msg, "CHANNEL", nil, tostring(channel))
	end
end

------------------------
-- _10_ Slash Handler --
------------------------
function GLDG:SlashHandler(msg)
	GLDG.Utils:SlashHandler(msg)
end

----------------------
-- _11_ Tab Changer --
----------------------
-- Tab management functions delegated to UIHelpers library
function GLDG_ClickTab(self, tabName)
	return GLDG.UIHelpers:ClickTab(self, tabName)
end

function GLDG_ClickSubTab(self, tabName)
	return GLDG.UIHelpers:ClickSubTab(self, tabName)
end

-----------------------------
-- _12_ General Tab Update --
-----------------------------

------------------------------------------------------------
-- Settings functions delegated to Settings library
function GLDG_UpdateRelog(self)
	return GLDG.Settings:UpdateRelog(self)
end

------------------------------------------------------------
function GLDG_UpdateMinLevelUp(self)
	return GLDG.Settings:UpdateMinLevelUp(self)
end

------------------------------------------------------------
function GLDG_UpdateUpdateTime(self)
	return GLDG.Settings:UpdateUpdateTime(self)
end

------------------------------------------------------------
function GLDG_DropDown_Initialize()
	return GLDG.Settings:DropDown_Initialize()
end

------------------------------------------------------------
function GLDG_DropDown_OnClick(self)
	return GLDG.Settings:DropDown_OnClick(self)
end

------------------------------------------------------------
function GLDG_SupressAll()
	return GLDG.Settings:SupressAll()
end

------------------------------------------------------------
function GLDG_SupressNone()
	return GLDG.Settings:SupressNone()
end

------------------------------------------------------------
function GLDG_UpdateSupressed()
	return GLDG.Settings:UpdateSupressed()
end

-------------------------------
-- _13_ Greetings Tab Update --
-------------------------------

-- Collection Management functions delegated to GUI library
function GLDG_ShowCollections(frame)
	return GLDG.GUI:ShowCollections(frame)
end

function GLDG_ShowGreetings(frame)
	return GLDG.GUI:ShowGreetings(frame)
end

function GLDG_ShowCustom(frame)
	return GLDG.GUI:ShowCustom(frame)
end

function GLDG_ClickCollection(self, col)
	return GLDG.GUI:ClickCollection(self, col)
end

function GLDG_ColButtonPressed(frame)
	return GLDG.GUI:ColButtonPressed(frame)
end

------------------------------------------------------------
function GLDG_ClickNewCol(self, frame)
	-- If collection is selected, remove it
	if GLDG_SelColName then
		GLDG_Data.Collections[GLDG_SelColName] = nil
		GLDG_SelColName = nil
		GLDG_ShowCustom(frame)
		GLDG_ShowCollections(frame)
		return end
	-- Disable this button and show the subframe
	GLDG_ColButtonPressed(frame)
	self:Disable()
	_G[frame.."SubNew"]:Show()
end

------------------------------------------------------------
function GLDG_ClickChangeCustom(self, setting, frame)
	-- Set the value to be updated
	GLDG_ChangeName = GLDG.Realm
	if (setting == "guild") then
		_G[frame.."SubChangeHeader"]:SetText(L["Set guild collection"])
		GLDG_ChangeName = GLDG_unique_GuildName
	elseif (setting == "char") then
		_G[frame.."SubChangeHeader"]:SetText(L["Set character collection"])
		GLDG_ChangeName = GLDG_ChangeName.."-"..UnitName("player")
	else	_G[frame.."SubChangeHeader"]:SetText(L["Set realm collection"]) end
	-- Disable this button and show the subframe
	GLDG_ColButtonPressed(frame)
	self:Disable()
	_G[frame.."SubChange"]:Show()
end

------------------------------------------------------------
function GLDG_ClickNewColAdd(self, frame)
	-- Don't do anything if no name is given or name already exists
	local box = _G[self:GetParent():GetName().."Editbox"]
	local name = box:GetText()
	if (name == "") or GLDG_Data.Collections[name] then return end
	box:SetText("")
	-- Create the new collection
	GLDG_Data.Collections[name] = {}
	local n = GLDG_Data.Collections[name]
	n.Greet = {}
	n.GreetBack = {}
	n.Welcome = {}
	n.NewRank = {}
	n.NewLevel = {}
	n.Bye = {}
	n.Night = {}
	n.Guild = {}
	n.Channel = {}
	n.ByeGuild = {}
	n.NightGuild = {}
	n.ByeChannel = {}
	n.NightChannel = {}
	n.LaterGuild = {}
	n.LaterChannel = {}
	n.Achievment = {}
	-- Refresh list and hide new collection frame
	GLDG_ShowCustom(frame)
	GLDG_ShowCollections(frame)
end

------------------------------------------------------------
function GLDG_ChangeCollect(setting, frame)
	-- Set new setting
	if (setting == "clear") then GLDG_Data.Custom[GLDG_ChangeName] = nil
	elseif (setting == "global") then GLDG_Data.Custom[GLDG_ChangeName] = ""
	elseif (setting == "selection") then GLDG_Data.Custom[GLDG_ChangeName] = GLDG_SelColName end
	-- Hide frame
	GLDG_ShowCustom(frame)
end

------------------------------------------------------------
-- Greetings Message functions delegated to Messages library
function GLDG_ClickGreetButton(self, id)
	return GLDG.Messages:ClickGreetButton(self, id)
end

function GLDG_ClickGreetScrollBar(self, frame)
	return GLDG.Messages:ClickGreetScrollBar(self, frame)
end

function GLDG_ClickGreeting(self, id)
	return GLDG.Messages:ClickGreeting(self, id)
end

function GLDG_ClickGreetAdd(self, frame)
	return GLDG.Messages:ClickGreetAdd(self, frame)
end

function GLDG_ClickGreetRemove(self, frame)
	return GLDG.Messages:ClickGreetRemove(self, frame)
end


-----------------------------
-- _14_ Players Tab Update --
-----------------------------

------------------------------------------------------------
function GLDG_ListPlayers()
	return GLDG.GUI:ListPlayers()
end

------------------------------------------------------------
function GLDG_GuildFilterDropDownTemplate_OnLoad(self)
	UIDropDownMenu_Initialize(self, GLDG_GuildFilterDropDown_Initialize);
	UIDropDownMenu_SetWidth(self, 160);
	UIDropDownMenu_JustifyText(self, "LEFT")
end

------------------------------------------------------------
function GLDG_GuildFilterDropDownTemplate_OnShow(self)
	UIDropDownMenu_Initialize(self, GLDG_GuildFilterDropDown_Initialize);
end

------------------------------------------------------------
function GLDG_GuildFilterDropDown_Initialize(frame, level)
	return GLDG.GUI:GuildFilterDropDown_Initialize(frame, level)
end

------------------------------------------------------------
function GLDG_RankFilterDropDownTemplate_OnLoad(self)
	UIDropDownMenu_Initialize(self, GLDG_RankFilterDropDown_Initialize);
	UIDropDownMenu_SetWidth(self, 160);
	UIDropDownMenu_JustifyText(self, "LEFT")
end

------------------------------------------------------------
function GLDG_RankFilterDropDownTemplate_OnShow(self)
	UIDropDownMenu_Initialize(self, GLDG_RankFilterDropDown_Initialize);
end

------------------------------------------------------------
function GLDG_RankFilterDropDown_Initialize(frame, level)
	return GLDG.GUI:RankFilterDropDown_Initialize(frame, level)
end

------------------------------------------------------------
function GLDG_ShowPlayers()
	return GLDG.GUI:ShowPlayers()
end

------------------------------------------------------------
function GLDG_ShowPlayerToolTip(element)
	return GLDG.GUI:ShowPlayerToolTip(element)
end

------------------------------------------------------------
function GLDG_ShowPlayerButtons()
	return GLDG.GUI:ShowPlayerButtons()
end

------------------------------------------------------------
function GLDG_GuildFilterDropDown_OnClick(self, list)
	return GLDG.PlayerManager:GuildFilterDropDown_OnClick(self, list)
end

------------------------------------------------------------
function GLDG_RankFilterDropDown_OnClick(self, list)
	return GLDG.PlayerManager:RankFilterDropDown_OnClick(self, list)
end

------------------------------------------------------------
function GLDG_OnClick_Header(element)
	return GLDG.PlayerManager:OnClick_Header(element)
end

------------------------------------------------------------
function GLDG_ClickPlayer(playerName)
	return GLDG.PlayerManager:ClickPlayer(playerName)
end

------------------------------------------------------------
function GLDG_ClickPlayerBar(frame)
	return GLDG.PlayerManager:ClickPlayerBar(frame)
end

------------------------------------------------------------
function GLDG_ClickIgnore()
	return GLDG.PlayerManager:ClickIgnore()
end

------------------------------------------------------------
function GLDG_ClickAlias(self)
	return GLDG.PlayerManager:ClickAlias(self)
end

------------------------------------------------------------
function GLDG_ShowPlayerAlias(frame)
	return GLDG.PlayerManager:ShowPlayerAlias(frame)
end

------------------------------------------------------------
function GLDG_ClickAliasSet(alias)
	return GLDG.PlayerManager:ClickAliasSet(alias)
end

------------------------------------------------------------
function GLDG_ClickAliasRemove()
	return GLDG.PlayerManager:ClickAliasRemove()
end

------------------------------------------------------------
function GLDG_ClickMain()
	return GLDG.PlayerManager:ClickMain()
end

------------------------------------------------------------
function GLDG_ClickAlt(self)
	return GLDG.PlayerManager:ClickAlt(self)
end

------------------------------------------------------------
function GLDG_ClickGuild(self)
	return GLDG.PlayerManager:ClickGuild(self)
end

------------------------------------------------------------
function GLDG_ShowPlayerGuild(frame)
	return GLDG.PlayerManager:ShowPlayerGuild(frame)
end

------------------------------------------------------------
function GLDG_ClickGuildSet(guild)
	return GLDG.PlayerManager:ClickGuildSet(guild)
end

------------------------------------------------------------
function GLDG_ClickGuildRemove()
	return GLDG.PlayerManager:ClickGuildRemove()
end

------------------------------------------------------------
function GLDG_ClickNote(self)
	return GLDG.PlayerManager:ClickNote(self)
end

------------------------------------------------------------
function GLDG_ShowPlayerNote(frame)
	return GLDG.PlayerManager:ShowPlayerNote(frame)
end

------------------------------------------------------------
function GLDG_ClickNoteSet(note)
	return GLDG.PlayerManager:ClickNoteSet(note)
end

------------------------------------------------------------
function GLDG_ClickNoteRemove()
	return GLDG.PlayerManager:ClickNoteRemove()
end

----------------------------------------------------------------
function GLDG_ClickPublicNote(self)
	return GLDG.PlayerManager:ClickPublicNote(self)
end


------------------------------------------------------------
function GLDG_ShowPublicPlayerNote(frame)
	-- Set title
	_G[frame.."Header"]:SetText(string.format(L["Edit public note for character %s"], GLDG_SelPlrName))
	-- Set editbox and buttons text
	local publicnote = nil
	for i = 1, GetNumGuildMembers() do
		local pl, _, _, _, _, _, pn = GetGuildRosterInfo(i) -- für ofiziersnotiz on anhängen!
		if pl == GLDG_SelPlrName then publicnote = pn end
	end

	if publicnote then
		_G[frame.."Set"]:SetText(L["update"])
		_G[frame.."Del"]:SetText(L["cancel"])
		_G[frame.."Editbox"]:SetText(publicnote)
	else
		_G[frame.."Set"]:SetText(L["set"])
		_G[frame.."Del"]:SetText(L["cancel"])
		_G[frame.."Editbox"]:SetText("") end
end

------------------------------------------------------------
function GLDG_ClickPublicNoteSet(note)
	for i = 1, GetNumGuildMembers() do
		local pl = GetGuildRosterInfo(i)
		if pl == GLDG_SelPlrName then GuildRosterSetPublicNote(i, note) end
	end
	GLDG_ListPlayers()
end

------------------------------------------------------------
function GLDG_ClickPublicNoteRemove()
	GLDG_ListPlayers()
end


function GLDG_ClickOfficerNote(self)
	-- Activate note subframe
	GLDG_ShowPlayerButtons()
	self:Disable()
	_G[self:GetParent():GetParent():GetParent():GetName().."SubOfficerNote"]:Show()
end


------------------------------------------------------------
function GLDG_ShowOfficerNote(frame)
	-- Set title
	_G[frame.."Header"]:SetText(string.format(L["Edit officer note for character %s"], GLDG_SelPlrName))
	-- Set editbox and buttons text
	local officernote = nil
	for i = 1, GetNumGuildMembers() do
		local pl, _, _, _, _, _, _, on = GetGuildRosterInfo(i) -- für ofiziersnotiz on anhängen!
		if pl == GLDG_SelPlrName then officernote = on end
	end

	if officernote then
		_G[frame.."Set"]:SetText(L["update"])
		_G[frame.."Del"]:SetText(L["cancel"])
		_G[frame.."Editbox"]:SetText(officernote)
	else
		_G[frame.."Set"]:SetText(L["set"])
		_G[frame.."Del"]:SetText(L["cancel"])
		_G[frame.."Editbox"]:SetText("") end
end

------------------------------------------------------------
function GLDG_ClickOfficerNoteSet(note)
	for i = 1, GetNumGuildMembers() do
		local pl = GetGuildRosterInfo(i)
		if pl == GLDG_SelPlrName then GuildRosterSetOfficerNote(i, note) end
	end
	GLDG_ListPlayers()
end

function GLDG_ClickOfficerNoteRemove()
	GLDG_ListPlayers()
end

------------------------------------------------------------
function GLDG_ClickWho()
	if GLDG_SelPlrName then
		C_FriendList.SendWho('n-"'..GLDG_SelPlrName..'"')
	end
end

------------------------------------------------------------
function GLDG_SendWho(name)
	if name then
		if (GLDG_Data.GuildSettings.ShowWhoSpam==true) then
			GLDG:PrintHelp(L["Sending /who request for"].." ["..Ambiguate(name, "guild").."]")
		end
		SendWho('n-"'..Ambiguate(name, "guild")..'"')
	end
end

------------------------------------------------------------
function GLDG_ParseWho()
	local _, totalCount = C_FriendList.GetNumWhoResults()
	local charname, guildname, level, _, class, _, _

	for i=1,totalCount do
		charname, guildname, level, _, class, _, _ = C_FriendList.GetWhoInfo(i)
		if (GLDG_DataChar[charname]) then
			GLDG_TreatWhoInfo(charname, guildname, level, class)
		end
	end
	GLDG_ShowPlayers()
end

------------------------------------------------------------
------------------------------------------------------------
function GLDG_TreatWhoInfo(charname, guildname, level, class)
	return GLDG.HelpUtils:TreatWhoInfo(charname, guildname, level, class)
end

------------------------------------------------------------
function GLDG_ClickRemove()
	if GLDG_SelPlrName then
		-- remove character
		GLDG_DataChar[GLDG_SelPlrName] = nil
		GLDG:PrintHelp(L["Character"].." ["..GLDG_SelPlrName.."] "..L["removed"])

		-- Show updated list
		GLDG_ListPlayers()
		-- Adjust scrollbar if needed
		GLDG_CorrectPlayerOffset(old, GLDG_SelPlrName)
	end
end

------------------------------------------------------------
function GLDG_ShowMainAlt(frame)
	-- Set frame and linename
	local name = frame:GetParent():GetName()
	-- Set title
	_G[name.."Header"]:SetText(string.format(L["Select main for character %s"], GLDG_SelPlrName))
	-- Create a sorted list of all mains
	local mainlist = {}
	local total = 0
	for p in pairs(GLDG_DataChar) do
		if GLDG_DataChar[p].main then
			local loc = 1
			while mainlist[loc] and (mainlist[loc] < p) do loc = loc + 1 end
			for cnt = total, loc, -1 do mainlist[cnt + 1] = mainlist[cnt] end
			total = total + 1
			mainlist[loc] = p end end
	-- Configure scrollbar
	FauxScrollFrame_Update(frame, GLDG_TableSize(mainlist), GLDG_NumSubRows, 15)
	local offset = FauxScrollFrame_GetOffset(frame)
	-- Set all rows
	name = name.."Line"
	for line = 1, GLDG_NumSubRows do
		if mainlist[line + offset] then
			_G[name..line.."Text"]:SetText(mainlist[line + offset])
			_G[name..line]:Enable()
		else	_G[name..line.."Text"]:SetText("")
			_G[name..line]:Disable() end end
end

------------------------------------------------------------
function GLDG_ClickMainAlt(self, player)
	-- Mark position of current selected player
	local old = GLDG_GetPlayerOffset(GLDG_SelPlrName)
	-- Make this the main for the currently selected character
	GLDG_DataChar[GLDG_SelPlrName].alt = player
	GLDG_DataChar[GLDG_SelPlrName].ignore = GLDG_DataChar[player].ignore
	-- Hide the subframe window
	self:GetParent():Hide()
	-- Refresh the playerlist
	GLDG_ListPlayers()
	-- Adjust scrollbar if needed
	GLDG_CorrectPlayerOffset(old, GLDG_SelPlrName)
end

------------------------------------------------------------
function GLDG_GetPlayerOffset(playerName)
	-- Find current position number on list
	local old = nil
	for i = 1, GLDG_TableSize(GLDG_SortedList) do
		if (GLDG_SortedList[i] == playerName) then
			old = i
			break end end
	return old
end

------------------------------------------------------------
function GLDG_CorrectPlayerOffset(old, playerName)
	-- Abort if no value given
	if not old then return end
	local new = nil
	-- Find new position number on list for this selection
	for i = 1, GLDG_TableSize(GLDG_SortedList) do
		if (GLDG_SortedList[i] == playerName) then
			new = i
			break end end
	-- Abort if no longer on list or position didn't change
	if (not new) or (old == new) then return end
	-- Calculate new offset and set it
	GLDG_PlayerOffset = math.max(0, math.min(GLDG_PlayerOffset + new - old, GLDG_TableSize(GLDG_SortedList) - GLDG_NumPlrRows))
	FauxScrollFrame_SetOffset(_G[GLDG_GUI.."PlayersPlayerbar"], GLDG_PlayerOffset)
	GLDG_ListPlayers()
end


-----------------------------------
-- _15_ General Helper Functions --
-----------------------------------
-- UI helper functions delegated to UIHelpers library
function GLDG_SetTextColor(textName, setName, colourName)
	return GLDG.UIHelpers:SetTextColor(textName, setName, colourName)
end

------------------------------------------------------------
function GLDG_Print(msg, forceDefault)
	return GLDG.UIHelpers:Print(msg, forceDefault)
end

------------------------------------------------------------
-- Add modern AceConsole error handling method
function GLDG:HandleError(msg, input)
	local errorMsg = tostring(msg or "")
	if input then
		errorMsg = errorMsg .. " ["..self:GetColors().help..input.."|r]"
	end
	self:PrintError(errorMsg)
	GLDG_Help()
end

------------------------------------------------------------
function GLDG_TableSize(info)
	-- Delegate to Utils Library
	return GLDG.Utils:TableSize(info)
end

------------------------------------------------------------
function GLDG_GetWords(str)
	-- Delegate to Utils Library
	return GLDG.Utils:GetWords(str)
end

------------------------------------------------------------
-- Help and utility functions delegated to HelpUtils library
function GLDG_Help()
	return GLDG.HelpUtils:Help()
end

---------------------
-- _16_ List frame --
---------------------
GLDG_PasteList = {
	nilFrame = {
		GetName = function() return "Global" end
	},
}

------------------------------------------------------------
-- Show function for list frame
------------------------------------------------------------
function GLDG_PasteList.Show()
	GLDG_PasteList.List.lastEntry = "";

	local list = GLDG_list;
	if (list) then
		for i in pairs(list) do
			if (list[i]) then
				if (GLDG_PasteList.List.lastEntry ~= "") then
					GLDG_PasteList.List.lastEntry = GLDG_PasteList.List.lastEntry.."\n";
				end
				GLDG_PasteList.List.lastEntry = GLDG_PasteList.List.lastEntry..list[i];
			end
		end
	end

	GLDG_PasteList.List.Box:SetText(GLDG_PasteList.List.lastEntry)
end

------------------------------------------------------------
-- Close function for list frame
------------------------------------------------------------
function GLDG_PasteList.Done()
	GLDG_PasteList.List:Hide()
end

------------------------------------------------------------
-- Update function for list frame
------------------------------------------------------------
function GLDG_PasteList.Update()
	GLDG_PasteList.List.Box:SetText(GLDG_PasteList.List.lastEntry)
	GLDG_PasteList.List.Scroll:UpdateScrollChildRect()
	GLDG_PasteList.List.Box:ClearFocus()
end

------------------------------------------------------------
-- Create our list frame
------------------------------------------------------------
function GLDG_CreatePasteListFrame()
	return GLDG.GUI:CreatePasteListFrame()
end
------------------------------------------------------------


---------------------
-- _17_ player menu --
---------------------

------------------------------------------------------------
function GLDG_AddPopUpButtons()
	-- Legacy UnitPopup system deprecated - disabled to prevent errors

	-- hooksecurefunc("UnitPopup_OnClick", GLDG_UnitPopupOnClick);
	-- hooksecurefunc("UnitPopup_HideButtons", GLDG_UnitPopupHideButtons);
end

------------------------------------------------------------
-- Hooked function for a unit popup
function GLDG_UnitPopupOnClick(self)
	-- Legacy UnitPopup system deprecated - functionality disabled
	--	ToggleDropDownMenu(1, nil, dropdownFrame, "cursor");
	--end

	return;
end

------------------------------------------------------------
-- Hooked function to hide buttons for non-friendly players
function GLDG_UnitPopupHideButtons()
	-- Legacy UnitPopup system deprecated - functionality disabled
end

---------------------
-- _18_ friends roster update --
---------------------

function GLDG_FriendsUpdate()
	return GLDG.GUI:FriendsUpdate()
end


-----------------------------
-- _19_ Achievments        --
-----------------------------
function GLDG_TreatAchievment(achievmentLink, name)
	if not achievmentLink or not name then return end
		local GLDG_shortName, realm = string.split("-", name)
		if not realm then name = GLDG_shortName.."-"..string.gsub(GLDG.Realm, " ", "") end
	-- Check for achievments
	local _, _, _, achievment = string.find(achievmentLink, GLDG_ACHIEVE) -- playerLink not used
	if (achievment) then
		local main = nil
		if (GLDG_DataChar[name] and not GLDG_DataChar[name].ignore) then
			if GLDG_DataChar[name].alt then
				main = GLDG_DataChar[name].alt;
				if GLDG_Data.GuildSettings.ExtendAlias==true then
					if GLDG_DataChar[main] and GLDG_DataChar[main].alias then
						main = GLDG_DataChar[main].alias
					end
				end
			elseif GLDG_Data.GuildSettings.ExtendMain==true and GLDG_DataChar[name].main then
				main = name
				if GLDG_Data.GuildSettings.ExtendAlias==true then
					if GLDG_DataChar[main] and GLDG_DataChar[main].alias then
						main = GLDG_DataChar[main].alias
					end
				end
			end
		end

		if (main) then
			if (GLDG_Data.GuildSettings.ListAchievments==true) then
				GLDG_Print(name..GLDG:GetColors().help.." {"..Ambiguate(main, "guild").."}|r "..L["has earned"].." "..tostring(achievment))
			end
		end
		if (GLDG_DataChar[name] and (GLDG_Data.GuildSettings.SupressAchievment==false) and (GLDG_TableSize(GLDG_DataGreet.Achievment) > 0)) then
			if (not GLDG_DataChar[name].own) then
				GLDG_DataChar[name].achievment = achievment
				GLDG_Queue[name] = GLDG_GetLogtime(name)
				GLDG_ShowQueue()
			end
		end
	end
end


-----------------------------
-- _20_ Channel handling   --
-----------------------------

------------------------------------------------------------
-- Channel management functions delegated to ChatSystem library  
function GLDG_CheckChannel()
	return GLDG.ChatSystem:CheckChannel()
end

------------------------------------------------------------
function GLDG_InitChannel(data)
	-- now that we got a list of all people in the channel, we do not need to monitor this event
	if (GLDG_unregister > 0) then
		GLDG_unregister = GLDG_unregister - 1
		if (GLDG_unregister == 0) then
			GLDG:UnregisterEvent("CHAT_MSG_CHANNEL_LIST")
			DEFAULT_CHAT_FRAME:RegisterEvent("CHAT_MSG_CHANNEL_LIST")
		end
	end


	if (GLDG_DataChar) then
		GLDG_checkedChannel = true
	end

	if (GLDG_inChannel and GLDG_DataChar) then
		if (data) then
			local names = GLDG_GetWords(data)

			for p in pairs(names) do
				local name = names[p]
				local a, _, _ = strfind(name, ',', 0, true)
				if (a) then
					name = string.sub(name, 1, a-1)
				end
				a, _, _ = strfind(name, '*', 0, true) -- reuse variable instead of redeclaring
				if (a) then
					name = string.sub(name, a+1)
				end

				-- Debug statement removed.."] extracted");
				if (name) then
					if (not GLDG_DataChar[name]) then
						GLDG_DataChar[name] = {}
						GLDG_AddToStartupList(L["Channel"]..": "..L["New member"].." ["..Ambiguate(name, "guild").."]")
					end
					if (not GLDG_DataChar[name].channels) then
						GLDG_DataChar[name].channels = {}
					end
					GLDG_DataChar[name].channels[GLDG_ChannelName] = GLDG_ChannelName

					if (not GLDG_Offline[name]) then
						GLDG_Offline[name] = false
					end
					if (GLDG_Online[name] == nil) then
						GLDG_Online[name] = true
					end
				end
			end

			if bit.band(GLDG_InitCheck, 4)==4 then
				GLDG_InitCheck = bit.band(GLDG_InitCheck, bit.bnot(4))	-- channel no longer pending
				GLDG_InitCheck = bit.bor(GLDG_InitCheck, 32)
				--GLDG_Print("InitCheck is ["..tostring(GLDG_InitCheck).."] - channel done")
				GLDG_StartupCheck()
			end
		end
	end
end

------------------------------------------------------------
function GLDG_UpdateChannel(joined, player)
	if not player then return end

	if (GLDG_inChannel) then
		if not GLDG_DataChar[player] then
			GLDG_DataChar[player] = {}
		end
		if (not GLDG_DataChar[player].channels) then
			GLDG_DataChar[player].channels = {}
		end
		GLDG_DataChar[player].channels[GLDG_ChannelName] = GLDG_ChannelName

		if (joined) then
			-- Debug statement removed.."] joined channel ["..GLDG_ChannelName.."]")

			if (GLDG_DataChar[player] and not GLDG_DataChar[player].ignore) then
				-- Debug statement removed.." is a member of our channel")
				GLDG_Online[player] = GetTime()

				-- if player is in our guild or on our friend's list, we've already
				-- listed him above, otherwise, list him now
				if (not GLDG_DataChar[player].guild or GLDG_DataChar[player].guild ~= GLDG_unique_GuildName) and
				   (not GLDG_DataChar[player].friends or not GLDG_DataChar[player].friends[GLDG.Player]) then
					if GLDG_Data.GuildSettings.ListNames==true then
						if GLDG_DataChar[player].alt then
							--
							-- Alt von Main
							--
							local main = GLDG_DataChar[player].alt;
							local altsList = GLDG_FindAlts(main, player, 1)
							GLDG:PrintHelp(altsList)
						else
							if GLDG_DataChar[player].main then
								--
								-- Main
								--
								local main = player;
								local altsList = GLDG_FindAlts(main, player, 1)
								GLDG:PrintHelp(altsList)
							else
								--
								-- Hat keinen Alt
								--
								local details = GLDG_findPlayerDetails(player);
								local alias = GLDG_findAlias(player, 1);

								if (details ~= "") then
									GLDG:PrintHelp(GLDG_ONLINE_COLOUR..Ambiguate(player, "guild")..": "..details.."|r"..alias.." {c}")
								else
									GLDG:PrintHelp(GLDG_ONLINE_COLOUR..Ambiguate(player, "guild").."|r"..alias.." {c}")
								end
							end
						end
					end

					if GLDG_DataChar[player].alt then GLDG_Offline[player] = GLDG_Offline[GLDG_DataChar[player].alt] end
					if GLDG_Offline[player] and (GLDG_Online[player] - GLDG_Offline[player] < GLDG_Data.GuildSettings.RelogTime * 60) then return end
					-- Debug statement removed.." is not been online in the last "..GLDG_Data.GuildSettings.RelogTime.." minutes.")
					if GLDG_Offline[player] and (GLDG_Data.GuildSettings.SupressGreet==true or (GLDG_TableSize(GLDG_DataGreet.GreetBack) == 0)) then return end
					-- Debug statement removed.." is not been online before")
					if not GLDG_Offline[player] and (GLDG_Data.GuildSettings.SupressGreet==true or (GLDG_TableSize(GLDG_DataGreet.Greet) == 0)) then return end
					-- Debug statement removed.." should be greeted")
					GLDG_Queue[player] = GLDG_GetLogtime(player)
					GLDG_ShowQueue()
				end

				-- if no class info is available, this player has never been /who queried before -> do it now
				-- queue these so they don't get lost if there are too many close together
				if ((not GLDG_DataChar[player].guild) or (GLDG_DataChar[player].guild ~= GLDG_unique_GuildName)) and (not GLDG_DataChar[player].class or not GLDG_DataChar[player].lvl or (GLDG_DataChar[player].lvl < GLDG_LEVEL_CAP)) and GLDG_Data.AutoWho==true then
					GLDG_SendWho(player)
				end
			end

		else
			-- Debug statement removed.."] left channel ["..GLDG_ChannelName.."]")

			if (GLDG_DataChar[player] and not GLDG_DataChar[player].ignore) then
				-- Debug statement removed.." is a member of our channel")
				-- if player is in our guild or on our friend's list, we'll list
				-- him again in a second, otherwise, list him now
				if (not GLDG_DataChar[player].guild or GLDG_DataChar[player].guild ~= GLDG_unique_GuildName) and
				   (not GLDG_DataChar[player].friends or not GLDG_DataChar[player].friends[GLDG.Player]) then
					GLDG_Online[player] = nil
					GLDG_RankUpdate[player] = nil

					if GLDG_DataChar[player].alt then
						local main = GLDG_DataChar[player].alt
						GLDG_DataChar[main].last = player
						GLDG_Offline[main] = GetTime()
					elseif GLDG_DataChar[player].main then
						GLDG_DataChar[player].last = player
						GLDG_Offline[player] = GetTime()
					else GLDG_Offline[player] = GetTime() end
					if GLDG_Queue[player] then
						GLDG_Queue[player] = nil
						GLDG_ShowQueue()
					end

					if GLDG_Data.GuildSettings.ListNamesOff==true then
						if GLDG_DataChar[player].alt then
							--
							-- Alt von Main
							--
							local main = GLDG_DataChar[player].alt;
							local altsList = GLDG_FindAlts(main, player, 0)
							GLDG:PrintHelp(altsList)
						else
							if GLDG_DataChar[player].main then
								--
								-- Main
								--
								local main = player;
								local altsList = GLDG_FindAlts(main, player, 0)
								GLDG:PrintHelp(altsList)
							else
								--
								-- Hat keinen Alt
								--
								local details = GLDG_findPlayerDetails(player);
								local alias = GLDG_findAlias(player, 0);

								if (details ~= "") then
									GLDG:PrintHelp(GLDG_GOES_OFFLINE_COLOUR..Ambiguate(player, "guild")..": "..details.."|r"..alias.." {c}")
								else
									GLDG:PrintHelp(GLDG_GOES_OFFLINE_COLOUR..Ambiguate(player, "guild").."|r"..alias.." {c}")
								end


							end
						end
					end
				end
			end
		end
	end
end

------------------------------------------------------------
function GLDG_ForceChatlist()
	return GLDG.ChatSystem:ForceChatlist()
end


-----------------------------
-- _21_ Testing            --
-----------------------------

-- Testing functions delegated to Utils library
function GLDG_SecToTimeString(secs)
	return GLDG.Utils:SecToTimeString(secs)
end

function GLDG_Test(showAll)
	return GLDG.Utils:Test(showAll)
end

function GLDG_CreateTestChars()
	return GLDG.Utils:CreateTestChars()
end

-----------------------------
-- _22_ Showing stored information
-----------------------------

-- Data display function delegated to Utils library
function GLDG_ShowDetails(name)
	return GLDG.Utils:ShowDetails(name)
end

-----------------------------
-- _23_ Colour picker handling    --
-----------------------------
function GLDG_ColourToRGB(colour)
	return GLDG.Colors:ColourToRGB(colour)
end

------------------------------------------------------------
function GLDG_ColourToRGB_perc(colour)
	return GLDG.Colors:ColourToRGB_perc(colour)
end

------------------------------------------------------------
function GLDG_RGBToColour(a, r, g, b)
	return GLDG.Colors:RGBToColour(a, r, g, b)
end

------------------------------------------------------------
function GLDG_RGBToColour_perc(a, r, g, b)
	return GLDG.Colors:RGBToColour_perc(a, r, g, b)
end

------------------------------------------------------------
function GLDG_ShowColourPicker()
	return GLDG.Colors:ShowColourPicker()
end

------------------------------------------------------------
function GLDG_HideColourPicker()
	return GLDG.Colors:HideColourPicker()
end

------------------------------------------------------------
function GLDG_ColourPicked(flag) -- flag is only passed when called from clicking on a button
	return GLDG.Colors:ColourPicked(flag)
end

------------------------------------------------------------
function GLDG_ColourCancel(prevvals)
	return GLDG.Colors:ColourCancel(prevvals)
end

------------------------------------------------------------
function GLDG_UpdateColoursSwatch()
	return GLDG.Colors:UpdateColoursSwatch()
end

------------------------------------------------------------
function GLDG_UpdateColoursNumbers()
	return GLDG.Colors:UpdateColoursNumbers()
end

------------------------------------------------------------
function GLDG_ColourCancelEdit(self, element)
	return GLDG.Colors:ColourCancelEdit(self, element)
end

------------------------------------------------------------
function GLDG_ColourEnter(self, element, number)
	return GLDG.Colors:ColourEnter(self, element, number)
end

------------------------------------------------------------
function GLDG_ColourTab(self, element)
	return GLDG.Colors:ColourTab(self, element)
end

------------------------------------------------------------
function GLDG_ColourUpdate(element, number)
	return GLDG.Colors:ColourUpdate(element, number)
end


-----------------------------
-- _24_ Colour handling    --
-----------------------------

function GLDG_SetActiveColourSet(set)
	return GLDG.Colors:SetActiveColourSet(set)
end

------------------------------------------------------------
function GLDG_ColoursShow()
	return GLDG.Colors:ColoursShow()
end

------------------------------------------------------------
function GLDG_ColourClick(name)
	return GLDG.Colors:ColourClick(name)
end

------------------------------------------------------------
function GLDG_UpdateCurrentColour()
	return GLDG.Colors:UpdateCurrentColour()
end


------------------------------------------------------------
function GLDG_ColourRestoreDefaults()
	return GLDG.Colors:ColourRestoreDefaults()
end


--------------------------
-- _25_ Display Help Tooltip
--------------------------

function GLDG_ShowHelpToolTip(self, element)
	if not element then return end

	local name = ""

--~~~ MSN1: Display element for debugging purposes, to see what is in tooltip variable table (commented out now)
--	GLDG_Print(element)
--~~~~

	-- cut off leading frame name
	if (string.find(element, GLDG_GUI)) then
		name = string.sub(element, string.len(GLDG_GUI)+1)
	elseif (string.find(element, GLDG_COLOUR)) then
		name = string.sub(element, string.len(GLDG_COLOUR)+1)
	elseif (string.find(element, GLDG_LIST)) then
		name = element
	end

	-- cut off trailing number in case of line and collect
	local s,e = string.find(name, "Line");
	if (s and e) then
		name = string.sub(name, 0, e)
	end
	s,e = string.find(name, "Collect");
	if (s and e) then
		name = string.sub(name, 0, e)
	end

-- Legacy tooltip system removed - now using modern AceGUI tooltips
end

--------------------------
-- _26_ Chat name extension
--------------------------

------------------------------------------------------------
-- extracted from r,g,b = RAID_CLASS_COLORS[enClass] * 255
local classColors = {}
if C_ClassColor and C_ClassColor.GetClassColor then
	classColors["MAGE"] = C_ClassColor.GetClassColor("MAGE");
	classColors["PRIEST"] = C_ClassColor.GetClassColor("PRIEST");
	classColors["WARLOCK"] = C_ClassColor.GetClassColor("WARLOCK");
	classColors["PALADIN"] = C_ClassColor.GetClassColor("PALADIN");
	classColors["DRUID"] = C_ClassColor.GetClassColor("DRUID");
	classColors["SHAMAN"] = C_ClassColor.GetClassColor("SHAMAN");
	classColors["DEMONHUNTER"] = C_ClassColor.GetClassColor("DEMONHUNTER");
	classColors["WARRIOR"] = C_ClassColor.GetClassColor("WARRIOR");
	classColors["ROGUE"] = C_ClassColor.GetClassColor("ROGUE");
	classColors["HUNTER"] = C_ClassColor.GetClassColor("HUNTER");
	classColors["DEATHKNIGHT"] = C_ClassColor.GetClassColor("DEATHKNIGHT");
	classColors["MONK"] = C_ClassColor.GetClassColor("MONK");
	classColors["EVOKER"] = C_ClassColor.GetClassColor("EVOKER");
end

------------------------------------------------------------
function GLDG_ChatFilter(chatFrame, event, ...)
	return GLDG.ChatSystem:ChatFilter(chatFrame, event, ...)
end

--------------------------
-- _27_ Debug dumping
--------------------------
------------------------------------------------------------
--function GLDG_Dump(msg)
--	if not msg then return end
--	if not GLDGD_Dump then return end

--	if GLDGD_InitComplete then
--		if GLDG_Backlog_Index and (GLDG_Backlog_Index > 0) then
--			GLDGD_DumpMsg("--- Starting to log backlog ---")
--				for index in pairs(GLDG_Backlog) do
--					GLDGD_DumpMsg("{"..GLDG_Backlog[index].."}")
--				end
--			GLDGD_DumpMsg("--- Done with logging backlog ---")
--			GLDG_Backlog = nil
--			GLDG_Backlog_Index = nil
--		end
--		GLDGD_DumpMsg(msg)
--	else
--		if not GLDG_Backlog then
--			GLDG_Backlog = {}
--			GLDG_Backlog_Index = 0
--		end
--		GLDG_Backlog_Index = GLDG_Backlog_Index + 1
--		GLDG_Backlog[GLDG_Backlog_Index] = msg
--	end
--end

------------------------------------------------------------
--function GLDG_ShowDump()
--	if GLDGD_InitComplete and GLDGD_Dump then
--		_G[GLDG_GUI.."SettingsDebug".."EnableDumpText"]:SetText(GLDG_TXT.enableDump)
--		_G[GLDG_GUI.."SettingsDebug".."VerboseDumpText"]:SetText(GLDG_TXT.verboseDump)
--		_G[GLDG_GUI.."SettingsDebug".."DumpSetText"]:SetText(string.format(GLDG_TXT.dumpSet, GLDGD_Dump.CurrentDumpSet, option))
--		_G[GLDG_GUI.."SettingsDebug".."CurrentIndexText"]:SetText(string.format(GLDG_TXT.currentIndex, GLDGD_Dump.CurrentSetIndex-1, GLDGD_Dump.CurrentDumpSet, option))
--		_G[GLDG_GUI.."SettingsDebug".."ClearButton"]:SetText(string.format(GLDG_TXT.btnClear, GLDGD_Dump.CurrentDumpSet, option))
--		_G[GLDG_GUI.."SettingsDebug".."ClearAllButton"]:SetText(GLDG_TXT.btnClearAll)
--		_G[GLDG_GUI.."SettingsDebug".."NewButton"]:SetText(GLDG_TXT.btnNew)
--
--		_G[GLDG_GUI.."SettingsDebug".."EnableDumpBox"]:SetChecked(GLDGD_Dump.Enabled)
--		_G[GLDG_GUI.."SettingsDebug".."VerboseDumpBox"]:SetChecked(GLDGD_Dump.Verbose)
--		_G[GLDG_GUI.."SettingsDebug".."EnableDumpBox"]:Enable()
--		_G[GLDG_GUI.."SettingsDebug".."VerboseDumpBox"]:Enable()
--		_G[GLDG_GUI.."SettingsDebug".."ClearButton"]:Enable()
--		_G[GLDG_GUI.."SettingsDebug".."ClearAllButton"]:Enable()
--		_G[GLDG_GUI.."SettingsDebug".."NewButton"]:Enable()
--	else
--		_G[GLDG_GUI.."SettingsDebug".."EnableDumpText"]:SetText(GLDG_TXT.noDumping)
--		_G[GLDG_GUI.."SettingsDebug".."VerboseDumpText"]:SetText(GLDG_TXT.noDumping)
--		_G[GLDG_GUI.."SettingsDebug".."DumpSetText"]:SetText(GLDG_TXT.noDumpingShort)
--		_G[GLDG_GUI.."SettingsDebug".."CurrentIndexText"]:SetText(GLDG_TXT.noDumpingShort)
--		_G[GLDG_GUI.."SettingsDebug".."ClearButton"]:SetText(GLDG_TXT.noDumpingShort)
--		_G[GLDG_GUI.."SettingsDebug".."ClearAllButton"]:SetText(GLDG_TXT.noDumpingShort)
--		_G[GLDG_GUI.."SettingsDebug".."NewButton"]:SetText(GLDG_TXT.noDumpingShort)

--		_G[GLDG_GUI.."SettingsDebug".."EnableDumpBox"]:SetChecked(false)
--		_G[GLDG_GUI.."SettingsDebug".."VerboseDumpBox"]:SetChecked(false)
--		_G[GLDG_GUI.."SettingsDebug".."EnableDumpBox"]:Disable()
--		_G[GLDG_GUI.."SettingsDebug".."VerboseDumpBox"]:Disable()
--		_G[GLDG_GUI.."SettingsDebug".."ClearButton"]:Disable()
--		_G[GLDG_GUI.."SettingsDebug".."ClearAllButton"]:Disable()
--		_G[GLDG_GUI.."SettingsDebug".."NewButton"]:Disable()
--	end
--end

------------------------------------------------------------
--function GLDG_ClickDumpEnable(checked)
--	if GLDGD_InitComplete and GLDGD_Dump then
--		GLDGD_Dump.Enabled = checked

--		if GLDGD_Status() then
--			GLDGD_Status()
--		end
--	end
--end

------------------------------------------------------------
--function GLDG_ClickDumpVerbose(checked)
--	if GLDGD_InitComplete and GLDGD_Dump then
--		GLDGD_Dump.Verbose = checked

--		if GLDGD_Status() then
--			GLDGD_Status()
--		end
--	end
--end

------------------------------------------------------------
--function GLDG_ClickDumpClear()
--	if GLDGD_InitComplete and GLDGD_Clear() then
--		GLDGD_Clear()
--	end
--	GLDG_ShowDump()
--end

------------------------------------------------------------
--function GLDG_ClickDumpClearAll()
--	if GLDGD_InitComplete and GLDGD_ClearAll() then
--		GLDGD_ClearAll()
--	end
--	GLDG_ShowDump()
--end

------------------------------------------------------------
--function GLDG_ClickDumpNew()
--	if GLDGD_InitComplete and GLDGD_New() then
--		GLDGD_New()
--	end
--	GLDG_ShowDump()
--end
--------------------------
-- _28_ Interface reloading (currently unused but left in code for future use)
--------------------------
function GLDG_QueryReloadUI()
	StaticPopup_Show("GLDG_RELOAD");
end

------------------------------------------------------------
function GLDG_PrepareReloadQuestion()
	StaticPopupDialogs["GLDG_RELOAD"] = {
		text = L["You must reload your interface for this change to take effect. Shall this be done now?"],
		button1 = L["Reload now"],
		button2 = L["Reload later"],
		OnAccept = function()
			ReloadUI();
			end,
		OnCancel = function()
			GLDG:PrintError(L["You must manually reload your interface by typing /console reloadui"])
			end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
		sound = "igQuestFailed",
	};
end

--------------------------
-- _30_ big brother
--------------------------
function GLDG_BB(flag)
	GLDG.db.profile.BigBrother = flag
	if (not flag) then
		GLDG.db.global.BigBrother = {}
		GLDG_BigBrother = GLDG.db.global.BigBrother
	end
	GLDG_Print("BigBrother is ["..tostring(GLDG.db.profile.BigBrother).."]")
end

------------------------------------------------------------
function GLDG_ShowBigBrother()
	if (GLDG.db.profile.BigBrother and GLDG_BigBrother) then
		GLDG:PrintHelp(L["Listing known GuildGreet users"])
		for p in pairs(GLDG_BigBrother) do
			GLDG:PrintHelp(Ambiguate(p, "guild")..": "..GLDG_BigBrother[p])
		end
	else
		GLDG:PrintHelp(L["No other GuildGreet users known"])
	end
end

------------------------------------------------------------
function GLDG_PollBigBrother()
	C_ChatInfo.SendAddonMessage("GLDG", "QUERY:"..GLDG_GetAddOnMetadata("GuildGreet", "Version"), "GUILD")
	local _, instanceType = IsInInstance()
	if (instanceType ~= "pvp") and (instanceType ~= "arena") then
		local groupMembers = GetNumGroupMembers()
		if groupMembers > 0 then
			if IsInRaid() then
				C_ChatInfo.SendAddonMessage("GLDG", "QUERY:", "RAID")
			else
				-- Party (non-raid) group
				C_ChatInfo.SendAddonMessage("GLDG", "QUERY:", "PARTY")
			end
		end
	end
end

--------------------------
-- _31_ conversion
--------------------------
function GLDG_Convert()
	-- Delegate to Migration Library
	return GLDG.Migration:Convert()
end

------------------------------------------------------------
function GLDG_Convert_Guild(realm, guild)
	return GLDG.Migration:ConvertGuild(realm, guild)
end

------------------------------------------------------------
function GLDG_Convert_Channel(realm, channel)
	return GLDG.Migration:ConvertChannel(realm, channel)
end

------------------------------------------------------------
function GLDG_Convert_Friends(realm)
	return GLDG.Migration:ConvertFriends(realm)
end

------------------------------------------------------------
function GLDG_Convert_ChannelNames()
	return GLDG.Migration:ConvertChannelNames()
end

------------------------------------------------------------
function GLDG_Convert_Colours()
	return GLDG.Migration:ConvertColours()
end

------------------------------------------------------------
function GLDG_Convert_Plausibility_Check(suppressOutput)
	local p
	local fixNeeded = false

	-- check for entries with both main and alt
	if not suppressOutput then
		GLDG:PrintHelp(L["Verifying double main-alt entries"])
	end
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].alt and GLDG_DataChar[p].main) then
			fixNeeded = true
			local alt = GLDG_DataChar[p].alt
			-- this char seems to be main and alt
			if (GLDG_DataChar[alt].main) then
				-- char is main
				if (GLDG_DataChar[alt].alt) then
					-- the main has the same problem as the current char
					if not suppressOutput then
						GLDG:PrintHelp(L["--> conflict:"].." ["..Ambiguate(p, "guild").."] "..L["is both main and alt. It's main"].." ["..alt.."] "..L["however is also main and alt, its main"].." ["..GLDG_DataChar[alt].alt.."] "..L["has not been checked, but will be seperately."]);
					end
				else
					-- ok, we could just de-main this char and we would be fine
					if not suppressOutput then
						GLDG:PrintHelp(L["--> conflict:"].." ["..Ambiguate(p, "guild").."] "..L["is both main and alt. It's main"].." ["..alt.."] "..L["should probably be main."]);
					end
				end
			else
				-- char is not main - strange
				if (GLDG_DataChar[alt].alt) then
					-- the apparent main is not main, but has a main of its own, we could just bend to that char
					if not suppressOutput then
						GLDG:PrintHelp(L["--> conflict:"].." ["..Ambiguate(p, "guild").."] "..L["is both main and alt. It's main"].." ["..alt.."] "..L["however is not main but an alt, its main"].." ["..GLDG_DataChar[alt].alt.."] "..L["has not been checked, but will be seperately."]);
					end
				else
					-- the apparent main is neither main nor has a main, we should probably just set it as main
					if not suppressOutput then
						GLDG:PrintHelp(L["--> conflict:"].." ["..Ambiguate(p, "guild").."] "..L["is both main and alt. It's main"].." ["..alt.."] "..L["is neither main or alt."]);
					end
				end
			end
		end
	end

	-- check for entries that are their own main
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].alt and GLDG_DataChar[p].alt == p) then
			fixNeeded = true
			GLDG:PrintHelp(L["--> conflict:"]..L["character"].." ["..Ambiguate(p, "guild").."] "..L["is its own main. This reference should be removed."])
		end
	end

	-- check for entries where an alt-link points to a char which doesn't exist
	if not suppressOutput then
		GLDG:PrintHelp(L["Verifying main-alt relations part 2"])
	end
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].alt and not GLDG_DataChar[GLDG_DataChar[p].alt]) then
			fixNeeded = true
			if not suppressOutput then
				GLDG:PrintHelp(L["--> conflict:"]..L["alt"].." ["..Ambiguate(p, "guild").."] "..L["has main"].." ["..GLDG_DataChar[p].alt.."] "..L["which does not exist."])
			end
		end
	end

	-- check for entries where an alt-link points to a main that isn't main
	if not suppressOutput then
		GLDG:PrintHelp(L["Verifying main-alt relations"])
	end
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].alt and GLDG_DataChar[GLDG_DataChar[p].alt] and not GLDG_DataChar[GLDG_DataChar[p].alt].main) then
			fixNeeded = true
			if not suppressOutput then
				GLDG:PrintHelp(L["--> conflict:"]..L["alt"].." ["..Ambiguate(p, "guild").."] "..L["has main"].." ["..GLDG_DataChar[p].alt.."] "..L["which is not marked as main."])
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

------------------------------------------------------------
GLDG_fixCount = 0
function GLDG_Convert_Plausibility_Fix(suppressTitle)
	local p
	local fixNeeded = false

	-- check for entries with both main and alt
	if (not suppressTitle) then
		GLDG:PrintHelp(L["Automatically fixing inconsistencies"])
	end
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].alt and GLDG_DataChar[p].main) then
			fixNeeded = true
			local alt = GLDG_DataChar[p].alt
			-- this char seems to be main and alt
			if (GLDG_DataChar[alt].main) then
				-- char is main
				if (GLDG_DataChar[alt].alt) then
					-- the main has the same problem as the current char, let's de-main this char, and check for the higher conflict later
					GLDG:PrintHelp(L["--> conflict:"].." ["..Ambiguate(p, "guild").."] "..L["is both main and alt. It's main"].." ["..alt.."] "..L["however is also main and alt, its main"].." ["..GLDG_DataChar[alt].alt.."] "..L["will be the new main, even though it is also main and alt, its main"]);
				else
					-- ok, we could just de-main this char and we would be fine
					GLDG:PrintHelp(L["--> conflict:"].." ["..Ambiguate(p, "guild").."] "..L["is both main and alt. It's main"].." ["..alt.."] "..L["will be the new main."]);
				end
				GLDG_DataChar[p].main = nil
				for q in pairs(GLDG_DataChar) do
					if GLDG_DataChar[q].alt and GLDG_DataChar[q].alt==p then
						GLDG_DataChar[q].alt = alt
						GLDG:PrintHelp("   "..L["Moving alt"].." ["..q.."] "..L["from main"].." ["..Ambiguate(p, "guild").."] "..L["to main"].." ["..alt.."]")
					end
				end
			else
				-- char is not main - strange
				if (GLDG_DataChar[alt].alt) then
					-- the apparent main is not main, but has a main of its own, we could just bend to that char
					GLDG:PrintHelp(L["--> conflict:"].." ["..Ambiguate(p, "guild").."] "..L["is both main and alt. It's main"].." ["..alt.."] "..L["however is not main but an alt, its main"].." ["..GLDG_DataChar[alt].alt.."] "..L["will become main for"].." ["..Ambiguate(p, "guild").."] "..L["and all its alts"]);
					GLDG_DataChar[p].main = nil
					GLDG_DataChar[p].alt = GLDG_DataChar[alt].alt
					for q in pairs(GLDG_DataChar) do
						if GLDG_DataChar[q].alt and GLDG_DataChar[q].alt==p then
							GLDG_DataChar[q].alt = GLDG_DataChar[alt].alt
							GLDG:PrintHelp("   "..L["Moving alt"].." ["..q.."] "..L["from main"].." ["..Ambiguate(p, "guild").."] "..L["to main"].." ["..GLDG_DataChar[alt].alt.."]")
						end
					end
				else
					-- the apparent main is neither main nor has a main, we should probably just set the original character as main
					GLDG:PrintHelp(L["--> conflict:"].." ["..Ambiguate(p, "guild").."] "..L["is both main and alt. It's main"].." ["..alt.."] "..L["is neither main or alt but will become alt of"].." ["..Ambiguate(p, "guild").."]");
					GLDG_DataChar[alt].alt = p
					GLDG_DataChar[p].alt = nil
				end
			end
		end
	end

	-- check for entries that are their own main
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].alt and GLDG_DataChar[p].alt == p) then
			fixNeeded = true
			GLDG:PrintHelp(L["--> conflict:"]..L["character"].." ["..Ambiguate(p, "guild").."] "..L["is its own main. This reference has been removed."])
			GLDG_DataChar[p].alt = nil
		end
	end

	-- check for entries where an alt-link points to a char which doesn't exist
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].alt and not GLDG_DataChar[GLDG_DataChar[p].alt]) then
			fixNeeded = true
			GLDG:PrintHelp(L["--> conflict:"]..L["alt"].." ["..Ambiguate(p, "guild").."] "..L["will become main for"].." ["..GLDG_DataChar[p].alt.."] "..L["which does not exist. This reference will be removed."])
			GLDG_DataChar[p].alt = nil
		end
	end

	-- check for entries where an alt-link points to a main that isn't main
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].alt and GLDG_DataChar[GLDG_DataChar[p].alt] and not GLDG_DataChar[GLDG_DataChar[p].alt].main) then
			fixNeeded = true
			GLDG:PrintHelp(L["--> conflict:"]..L["alt"].." ["..Ambiguate(p, "guild").."] "..L["has main"].." ["..GLDG_DataChar[p].alt.."] "..L["which is not marked as main. This will be set."])
			GLDG_DataChar[GLDG_DataChar[p].alt].main = true
		end
	end

	if fixNeeded then
		-- recurse
		if (GLDG_fixCount < 10) then
			GLDG_fixCount = GLDG_fixCount + 1
			fixNeeded = GLDG_Convert_Plausibility_Fix(true)

			if not suppressTitle then
					GLDG:PrintHelp(L["Entries have been fixed. Check manually if all main-alt groups have the correct main. If not, use the '|cFFFFFF7F Promote to main|r' function."])
			end
		else
			GLDG:PrintHelp(L["There seems to be a circular inconsistency that could not be fixed even after 10 iterations. Giving up. Please report this to gOOvER on the addon's page at www.github.com."])
		end
	else
		if not suppressTitle then
				GLDG:PrintHelp(L["Nothing needed to be fixed."])
		end
	end

	return fixNeeded
end

------------------------------------------------------------
function GLDG_Reset_Aliases()
	GLDG:PrintHelp("Remove all saved aliases")
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].alias) then
			GLDG_DataChar[p].alias = nil
			GLDG:PrintHelp("Alias from ["..Ambiguate(p, "guild").."] deleted")
		end
	end
end
------------------------------------------------------------
function GLDG_Convert_Unnew()
	GLDG:PrintHelp(L["Clearing 'new in guild' flag for all characters"])
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].new) then
			GLDG_DataChar[p].new = nil
			GLDG:PrintHelp(L["Removing the 'new in guild' flag for"].." ["..Ambiguate(p, "guild").."]")
		end
	end
end

--------------------------
-- _32_ "guild alert" check
--------------------------
function GLDG_CheckForGuildAlert()
	if GLDG_Data.CheckedGuildAlert==false then
		if (GetCVar("guildMemberNotify") ~= "1") then
			StaticPopup_Show("GLDG_GUILD_ALERT");
		else
			GLDG:PrintHelp(L["Guild member notification is active."])
		end
		GLDG_Data.CheckedGuildAlert = true
	end
end

------------------------------------------------------------
function GLDG_PrepareAlertQuestion()
	StaticPopupDialogs["GLDG_GUILD_ALERT"] = {
		text = L["|cFFFFFF7FGuild member notification|r is currently turned off (See Interface settings, Game, Social).\r\nThis means that GuildGreet is unable to reliably track when your guild mates come online or go offline.\r\n\r\nThis question will only be asked once. To manually check later on type |cFFFFFF7F/gg alert|r.\r\n\r\nDo you want to activate these notifications? (Recommended)"],
		button1 = L["Activate notification"],
		button2 = L["Leave inactive"],
		OnAccept = function()
			SetCVar("guildMemberNotify", 1)
			GLDG:PrintHelp(L["Guild member notification has been turned on."])
			end,
		OnCancel = function()
			GLDG:PrintHelp(L["Guild member notification has not been turned on. |cFFFF0000GuildGreet will not be able to reliably track your guild members coming online and going offline.|r"])
			end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
		sound = "igQuestFailed",
	};
end

--------------------------
-- _33_ cleanup
--------------------------
function GLDG_CleanupShowTab()
	-- Hide the subframe window
	_G[GLDG_GUI.."CleanupSubEntries"]:Hide()

	-- re-enable buttons
	_G[GLDG_GUI.."CleanupGuild"]:Enable()
	_G[GLDG_GUI.."CleanupFriends"]:Enable()
	_G[GLDG_GUI.."CleanupChannel"]:Enable()
end

function GLDG_ClickCleanup(self, mode)
	-- enable other buttons (the one clicked will be disabled below)
	_G[GLDG_GUI.."CleanupGuild"]:Enable()
	_G[GLDG_GUI.."CleanupFriends"]:Enable()
	_G[GLDG_GUI.."CleanupChannel"]:Enable()

	local p,q

	GLDG_CleanupList = {}
	GLDG_CleanupMode = mode
	local total = 0
	for p in pairs(GLDG_DataChar) do
		if (mode == "guild" and GLDG_DataChar[p].guild) then
			total = GLDG_CleanupSortedInsert(GLDG_DataChar[p].guild, total)
		elseif (mode == "friends" and GLDG_DataChar[p].friends) then
			for q in pairs(GLDG_DataChar[p].friends) do
				total = GLDG_CleanupSortedInsert(q, total)
			end
		elseif (mode == "channel" and GLDG_DataChar[p].channels) then
			for q in pairs(GLDG_DataChar[p].channels) do
				total = GLDG_CleanupSortedInsert(q, total)
			end
		end
	end

	--GLDG_Print("Cleanup for ["..mode.."]")
	--for p in pairs(GLDG_CleanupList) do
	--	GLDG_Print("  "..Ambiguate(p, "guild")..": ["..GLDG_CleanupList[p].."]")
	--end
	--GLDG_Print("Done")

	-- display list to choose from
	self:Disable()
	_G[self:GetParent():GetName().."SubEntries"]:Hide()	-- do this to refresh an already displayed list
	_G[self:GetParent():GetName().."SubEntries"]:Show()
end

------------------------------------------------------------
function GLDG_CleanupSortedInsert(entry, total)
	local loc = 1
	while GLDG_CleanupList[loc] and (GLDG_CleanupList[loc] < entry) do
		loc = loc + 1
	end
	if (GLDG_CleanupList[loc] ~= entry) then
		for cnt = total, loc, -1 do
			GLDG_CleanupList[cnt + 1] = GLDG_CleanupList[cnt]
		end
		total = total + 1
		GLDG_CleanupList[loc] = entry
	end

	return total
end

------------------------------------------------------------
function GLDG_CleanupExecute(entry)
	local p
	local found = false
	if entry and GLDG_CleanupMode and GLDG_CleanupList then
		for p in pairs(GLDG_CleanupList) do
			if GLDG_CleanupList[p] == entry then
				found = true
			end
		end
		if found then
			for p in pairs(GLDG_DataChar) do
				if (GLDG_CleanupMode == "guild" and GLDG_DataChar[p].guild and GLDG_DataChar[p].guild == entry) then
					GLDG_DataChar[p].guild = nil
					GLDG_DataChar[p].rank = nil
					GLDG_DataChar[p].rankname = nil
					GLDG_DataChar[p].pNote = nil
					GLDG_DataChar[p].oNote = nil
					GLDG:PrintHelp(L["Removed guild"].." ["..entry.."] "..L["from character"].." ["..Ambiguate(p, "guild").."] "..L[""])
				elseif (GLDG_CleanupMode == "friends" and GLDG_DataChar[p].friends and GLDG_DataChar[p].friends[entry]) then
					GLDG_DataChar[p].friends[entry] = nil
					GLDG:PrintHelp(L["Removed friend"].." ["..entry.."] "..L["from character"].." ["..Ambiguate(p, "guild").."] "..L[""])
				elseif (GLDG_CleanupMode == "channel" and GLDG_DataChar[p].channels and GLDG_DataChar[p].channels[entry]) then
					GLDG_DataChar[p].channels[entry] = nil
					GLDG:PrintHelp(L["Removed channel"].." ["..entry.."] "..L["from character"].." ["..Ambiguate(p, "guild").."] "..L[""])
				end
			end
		else
			GLDG:PrintHelp(L["Entry"].." ["..entry.."] "..L["was not found in list of available entries for mode."].." ["..GLDG_CleanupMode.."]")
		end
	end

	-- retrigger channel and friends update (guild not needed, is done periodically)
	GLDG_CheckChannel()
	C_FriendList.ShowFriends()

	GLDG_CleanupList = nil
	GLDG_CleanupMode = nil
end

------------------------------------------------------------
function GLDG_ClickOrphanCleanup()
	return GLDG.CleanupUtils:OrphanCleanup()
end

------------------------------------------------------------
function GLDG_ClickGuildlessCleanup()
	return GLDG.CleanupUtils:GuildlessCleanup()
end
--~~~~

------------------------------------------------------------
function GLDG_ClickGuildlessDisplay()
	return GLDG.CleanupUtils:GuildlessDisplay()
end
--~~~~

------------------------------------------------------------
function GLDG_ShowCleanupEntries(frame)
	if not GLDG_CleanupList or not GLDG_CleanupMode then return end

	-- Set frame and linename
	local name = frame:GetParent():GetName()
	-- Set title
	if (GLDG_TableSize(GLDG_CleanupList) > 0) then
		if GLDG_CleanupMode == "guild" then
			_G[name.."Header"]:SetText(L["Select a guild to remove"])
		elseif GLDG_CleanupMode == "friends" then
			_G[name.."Header"]:SetText(L["Select a friend to remove"])
		elseif GLDG_CleanupMode == "channel" then
			_G[name.."Header"]:SetText(L["Select a channel to remove"])
		else
			_G[name.."Header"]:SetText("")
		end
	else
		if GLDG_CleanupMode == "guild" then
			_G[name.."Header"]:SetText(L["No guilds found to remove"])
		elseif GLDG_CleanupMode == "friends" then
			_G[name.."Header"]:SetText(L["No friends found to remove"])
		elseif GLDG_CleanupMode == "channel" then
			_G[name.."Header"]:SetText(L["No channels found to remove"])
		else
			_G[name.."Header"]:SetText("")
		end
		_G[GLDG_GUI.."CleanupGuild"]:Enable()
		_G[GLDG_GUI.."CleanupFriends"]:Enable()
		_G[GLDG_GUI.."CleanupChannel"]:Enable()
	end
	-- Configure scrollbar
	FauxScrollFrame_Update(frame, GLDG_TableSize(GLDG_CleanupList), GLDG_NumSubRows, 15)
	local offset = FauxScrollFrame_GetOffset(frame)
	-- Set all rows
	name = name.."Line"
	for line = 1, GLDG_NumSubRows do
		if GLDG_CleanupList[line + offset] then
			_G[name..line.."Text"]:SetText(GLDG_CleanupList[line + offset])
			_G[name..line]:Enable()
		else	_G[name..line.."Text"]:SetText("")
			_G[name..line]:Disable()
		end
	end
end

------------------------------------------------------------
function GLDG_ClickCleanupEntry(self, entry)
	-- confirm dialog

	-- do the cleanup
	GLDG_CleanupExecute(entry)

	-- Hide the subframe window
	self:GetParent():Hide()

	-- re-enable buttons
	_G[GLDG_GUI.."CleanupGuild"]:Enable()
	_G[GLDG_GUI.."CleanupFriends"]:Enable()
	_G[GLDG_GUI.."CleanupChannel"]:Enable()
end

--------------------------
-- _34_ interface options
--------------------------
function GLDG_OnLoadOptions(panel)
        panel.name = GLDG_NAME
        panel.okay = GLDG_OptionsOk
        panel.cancel = GLDG_OptionsCancel
        panel.default = GLDG_OptionsDefault

        -- Use new Settings API if available, fallback to InterfaceOptions for older clients
        if Settings and Settings.RegisterCanvasLayoutCategory then
            local category = Settings.RegisterCanvasLayoutCategory(panel, GLDG_NAME)
            Settings.RegisterAddOnCategory(category)
        elseif InterfaceOptions_AddCategory then
            InterfaceOptions_AddCategory(panel);
        end
end

------------------------------------------------------------
function GLDG_OptionsOk()
end

------------------------------------------------------------
function GLDG_OptionsCancel()
end

------------------------------------------------------------
function GLDG_OptionsDefault()
end

--------------------------
-- _35_ startup popup handling
--------------------------
------------------------------------------------------------
function GLDG_StartupCheck()
	return GLDG.HelpUtils:StartupCheck()
end

------------------------------------------------------------
function GLDG_AddToStartupList(entry)
	return GLDG.HelpUtils:AddToStartupList(entry)
end

-- Core/Database delegations
function GLDG_generateConfigString() return GLDG.Core:generateConfigString() end
function GLDG_InitGreet(section) return GLDG.Core:InitGreet(section) end
function GLDG_ClickGuildAliasSet() return GLDG.Core:ClickGuildAliasSet() end
function GLDG_ClickGuildAliasClear() return GLDG.Core:ClickGuildAliasClear() end

------------------------------------------------------------
function GLDG_GetLogtime(player)
	return GLDG.Core:GetLogtime(player)
end

------------------------------------------------------------
function GLDG_GetTime()
	return GLDG.Core:GetTime()
end

------------------------------------------------------------
function GLDG_KeyGreet()
	return GLDG.Core:KeyGreet()
end

------------------------------------------------------------
function GLDG_GreetGuild()
	return GLDG.Core:GreetGuild()
end

------------------------------------------------------------
function GLDG_GreetChannel()
	return GLDG.Core:GreetChannel()
end

------------------------------------------------------------
function GLDG_ClickName(button, name)
	return GLDG.Core:ClickName(button, name)
end

function GLDG_readConfigString_change(value)
	-- Delegate to Database Library
	return GLDG.Database:ReadConfigString_change(value)
end


function GLDG_readConfigString()
	return GLDG.Database:ReadConfigString()
end

function GLDG_WriteGuildString()
	return GLDG.Database:WriteGuildString()
end


