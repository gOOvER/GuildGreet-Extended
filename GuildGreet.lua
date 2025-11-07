--[[--------------------------------------------------------
-- GuildGreet, a World of Warcraft social guild assistant --
------------------------------------------------------------
]]----------------------------------------------------------

-- Global addon object for library access
GLDG = LibStub("AceAddon-3.0"):NewAddon("GuildGreet", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceDB-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", false)

-- Database defaults für AceDB-3.0
local defaults = {
	profile = {
		-- Allgemeine Einstellungen
		ShowNewerVersions = true,
		BigBrother = false,
		ExtendPlayerMenu = true,
		EnableContextMenu = false,
		
		-- Guildspezifische Einstellungen
		GuildSettings = {
			UseGuildDefault = true,
			RelogTime = 5
		},
		
		-- Farben (legacy System wird später migriert)
		colours = {
			help = "|cff00ff00"
		}
	},
	char = {
		-- Charakterspezifische Daten
		main = nil
	},
	global = {
		-- Serverweite Daten
		BigBrother = {}
	}
}

-- Binding names
BINDING_HEADER_GUILDGREET = L["GuildGreet"]
BINDING_NAME_GUILDGREETCONFIG = L["Open config window"]
BINDING_NAME_GUILDGREETCLEAR = L["Clear greet list"]
BINDING_NAME_GUILDGREETTESTL = L["Test trigger"]
BINDING_NAME_GUILDGREETGREETGUILD = L["Greet Guild and Channel"]
BINDING_NAME_GUILDGREETBYEGUILD = L["Say goodbye to guild and channel"]
BINDING_NAME_GUILDGREETLATERGUILD = L["Say see you later to guild and channel"]

-- Addon constants
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
GLDG_ONLINE 		= ".*%[(.+)%]%S*"..string.sub(string.gsub(ERR_FRIEND_ONLINE_SS, "|cff00ff00online|r", "online"), 20) -- fix for RealUI 8 users
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

-- Global variables
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

-- Stored data (Legacy - wird zu AceDB-3.0 migriert)
GLDG_Data = {}			        -- Data saved between sessions
GLDG_DataGreet = nil		    -- Pointer to relevant greeting section in GLDG_Data
GLDGL_DataChar = nil		    -- Pointer to relevant character section in GLDG_Data

-- Legacy globale Variablen (werden schrittweise in Addon-Instanz migriert)
-- Siehe OnInitialize() für die modernen self.* Eigenschaften
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
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("VARIABLES_LOADED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("SAVED_VARIABLES_TOO_LARGE")

	-- Modern AceConsole slash command registration
	self:RegisterChatCommand("gg", "SlashHandler")
	self:RegisterChatCommand("guildgreet", "SlashHandler")
end

------------------------------------------------------------
function GLDG:OnInitialize()
	-- AceDB-3.0 Database Initialisierung
	self.db = LibStub("AceDB-3.0"):New("GuildGreetDB", defaults, true)
	
	-- Initialize Libraries (must be done after database initialization)
	if self.Utils then self.Utils:Initialize() end
	if self.Database then self.Database:Initialize() end
	if self.Colors then self.Colors:Initialize() end
	if GLDG.PlayerManager then GLDG.PlayerManager:Initialize() end
	if self.Messages then self.Messages:Initialize() end
	if self.Migration then self.Migration:Initialize() end
	
	-- Addon-Instanz Variablen (anstatt globaler Variablen)
	GLDG.Realm = nil
	GLDG.Player = nil
	self.shortName = nil
	self.GuildName = nil
	self.GuildAlias = nil
	self.GuildLeader = nil
	self.unique_GuildName = nil
	self.ginfotxt = nil
	self.config_from_guild = nil
	self.corrupted_config_from_guild = nil
	self.NewGuild = nil
	self.InitialGuildUpdate = nil
	self.InitialFriendsUpdate = nil
	self.UpdateRequest = 0
	self.UpdateRequestFriends = 0
	self.InitComplete = nil
	self.ReadNotes = 1
	self.RosterImportRunning = 0
	self.InitCheck = 0
	self.ChangesText = {}
	
	-- Core variablen
	self.Online = {}
end

------------------------------------------------------------
-- Moderne Print-Helper Funktionen
------------------------------------------------------------
function GLDG:PrintInfo(message)
	self:Print("|cff00ff00" .. GLDG_NAME .. ":|r " .. message)
end

function GLDG:PrintError(message)
	self:Print("|cffff0000" .. GLDG_NAME .. " Error:|r " .. message)
end

function GLDG:PrintHelp(message)
	self:Print("|cff00ff00" .. GLDG_NAME .. ":|r " .. message)
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
	return GLDG.PlayerManager:findMainname(_main, _pl)
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
	return GLDG.PlayerManager:getOnlineList()
end

------------------------------------------
-- find player details for a player --
------------------------------------------
function GLDG_findPlayerDetails(playerName)
	return GLDG.PlayerManager:findPlayerDetails(playerName)
end

------------------------------------------
-- find alias for current player  --
------------------------------------------
function GLDG_findAlias(playerName, colourise)
	return GLDG.PlayerManager:findAlias(playerName, colourise)
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

function GLDG_ShowQueue()
	return GLDG.Messages:ShowQueue()
end


------------------------
-- _09_ Greet Players --
------------------------

function GLDG_ClickName(button, name)
	-- Strip timestamp from name
	name = string.sub(name, 9)
	local _, uRealm = string.split("-", name)
	if not uRealm then
		name = name.."-"
		local len = string.len(name)
		for i in pairs(GLDG_DataChar) do
			if  string.sub(i, 1, len)==name and GLDG_DataChar[i].guild == GLDG_unique_GuildName then
				name = i
			end
		end
		if string.len(name) == len then name = name..string.gsub(GLDG.Realm, " ", "") end
	end
	-- Greet the player if left click
	if (button == "LeftButton") then
		GLDG_SendGreet(name)
	end
	-- Cleanup where needed
	GLDG_CleanupPlayer(name)
	-- Remove name from queue and refresh
	GLDG_Queue[name] = nil
	GLDG_ShowQueue()
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
	local hour,min = GLDG_GetTime();
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
	local hour,min = GLDG_GetTime();
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
		-- H.Sch. - ReglohPri - SendWho is deprecated, changed to C_FriendList.SendWho
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
	-- H.Sch. - ReglohPri - GetNumWhoResults() is deprecated, changed to C_FriendList.GetNumWhoResults()
	local numWhos, totalCount = C_FriendList.GetNumWhoResults()
	local charname, guildname, level, race, class, zone, classFileName

	for i=1,totalCount do
		-- H.Sch. - ReglohPri - GetWhoInfo is deprecated, changed to C_FriendList.GetWhoInfo
		charname, guildname, level, race, class, zone, classFileName = C_FriendList.GetWhoInfo(i)
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
	local errorMsg = self:GetColors().help..GLDG_NAME..":|r "..msg
	if input then
		errorMsg = errorMsg .. " ["..self:GetColors().help..input.."|r]"
	end
	self:Print(errorMsg)
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
	-- TODO: Migrate to new Menu API in future update
	-- The old UnitPopupButtons/UnitPopupMenus system has been deprecated
	-- For now, this functionality is disabled to prevent errors
	-- UnitPopupMenus["GLDG"] = {"GLDG_LOOKUP", "GLDG_BYE", "CANCEL"};
	-- UnitPopupButtons["GLDG"] = { text = L["GuildGreet"], dist = 0, nested = 1};
	-- UnitPopupButtons["GLDG_LOOKUP"] = { text = L["Lookup"], dist = 0,};
	-- UnitPopupButtons["GLDG_BYE"] = { text = L["Good bye"], dist = 0 };

	-- table.insert(UnitPopupMenus["PLAYER"], #UnitPopupMenus["PLAYER"]-1, "GLDG");
	-- table.insert(UnitPopupMenus["FRIEND"], #UnitPopupMenus["FRIEND"]-1, "GLDG");
	-- table.insert(UnitPopupMenus["PARTY"], #UnitPopupMenus["PARTY"]-1, "GLDG");

	-- hooksecurefunc("UnitPopup_OnClick", GLDG_UnitPopupOnClick);
	-- hooksecurefunc("UnitPopup_HideButtons", GLDG_UnitPopupHideButtons);
end

------------------------------------------------------------
-- Hooked function for a unit popup
function GLDG_UnitPopupOnClick(self)
	-- This function is disabled due to UnitPopup system deprecation
	-- TODO: Migrate to new Menu API in future update
	--local dropdownFrame = _G[UIDROPDOWNMENU_INIT_MENU];
	--local dropdownFrame = UIDROPDOWNMENU_INIT_MENU
	--local button = self.value;
	--local name = dropdownFrame.name;

	--if button == "GLDG_LOOKUP" then
	--	GLDG_ListForPlayer(name, false);
	--	ToggleDropDownMenu(1, nil, dropdownFrame, "cursor");
	--elseif button == "GLDG_BYE" then
	--	GLDG_SendBye(name);
	--	ToggleDropDownMenu(1, nil, dropdownFrame, "cursor");
	--end

	return;
end

------------------------------------------------------------
-- Hooked function to hide buttons for non-friendly players
function GLDG_UnitPopupHideButtons()
	-- This function is disabled due to UnitPopup system deprecation
	-- TODO: Migrate to new Menu API in future update
	--local dropdownFrame = _G[UIDROPDOWNMENU_INIT_MENU];
	--local dropdownFrame = UIDROPDOWNMENU_INIT_MENU
	--local coop = dropdownFrame.unit and UnitCanCooperate("player", dropdownFrame.unit)
	--for index, value in ipairs(UnitPopupMenus[dropdownFrame.which]) do
	--	if (((value == "GLDG_LOOKUP") or (value == "GLDG_BYE")) and not coop) then
	--		UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
	--		return;
	--	end
	--end
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
	local _, _, playerLink, achievment = string.find(achievmentLink, GLDG_ACHIEVE)
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
				GLDG_Print(name..self:GetColors().help.." {"..Ambiguate(main, "guild").."}|r "..L["has earned"].." "..tostring(achievment))
			end
		end
		if (GLDG_DataChar[name] and (GLDG_Data.GuildSettings.SupressAchievment==false) and (GLDG_TableSize(GLDG_DataGreet.Achievment) > 0)) then
			if (not GLDG_DataChar[name].own) then
				GLDG_DataChar[name].achievment = achievment
				GLDG_Queue[name] = GLDG_GetLogtime(player)
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
			self:UnregisterEvent("CHAT_MSG_CHANNEL_LIST")
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
				local a,b,c = strfind(name, ',', 0, true)
				if (a) then
					name = string.sub(name, 1, a-1)
				end
				local a,b,c = strfind(name, '*', 0, true)
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
classColors["DEADKNIGHT"] = C_ClassColor.GetClassColor("DEADKNIGHT");
classColors["MONK"] = C_ClassColor.GetClassColor("MONK");
classColors["EVOKER"] = C_ClassColor.GetClassColor("EVOKER");

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
			GLDG_Print(self:GetColors().help..GLDG_NAME..":|cFFFF0000 "..L["You must manually reload your interface by typing /console reloadui"])
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
	self.db.profile.BigBrother = flag
	if (not flag) then
		GLDG_BigBrother = nil
	end
	GLDG_Print("BigBrother is ["..tostring(self.db.profile.BigBrother).."]")
end

------------------------------------------------------------
function GLDG_ShowBigBrother()
	if (self.db.profile.BigBrother and GLDG_BigBrother) then
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
	C_ChatInfo.SendAddonMessage("GLDG", "QUERY:"..GetAddOnMetadata("GuildGreet", "Version"), "GUILD")
	local inInstance, instanceType = IsInInstance()
	if (instanceType ~= "pvp") and (instanceType ~= "arena") and (GetNumPartyMembers() > 0) then
		C_ChatInfo.SendAddonMessage("GLDG", "QUERY:", "PARTY")
	end
	local inInstance, instanceType = IsInInstance()
	if (instanceType ~= "pvp") and (instanceType ~= "arena") and (GetNumRaidMembers() > 0) then
		C_ChatInfo.SendAddonMessage("GLDG", "QUERY:", "RAID")
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
						GLDG_Print(self:GetColors().help..GLDG_NAME..":|r    "..L["Moving alt"].." ["..q.."] "..L["from main"].." ["..Ambiguate(p, "guild").."] "..L["to main"].." ["..alt.."]");
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
							GLDG_Print(self:GetColors().help..GLDG_NAME..":|r    "..L["Moving alt"].." ["..q.."] "..L["from main"].." ["..Ambiguate(p, "guild").."] "..L["to main"].." ["..GLDG_DataChar[alt].alt.."]");
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
	GLDG_Print(self:GetColors().help..GLDG_NAME..":|r Remove all saved aliases")
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].alias) then
			GLDG_DataChar[p].alias = nil
			GLDG_Print(self:GetColors().help..GLDG_NAME..":|r Alias from ["..Ambiguate(p, "guild").."] deleted")
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
	-- H.Sch. - ReglohPri - ShowFriends() is deprecated changed to C_FriendList.ShowFriends()
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
				--GLDG_InitRoster()
			end
		end
	else
		GLDG_config_from_guild = "not found"
		GLDG_InitRoster()
	end
	if (GLDG_Data.GuildSettings.UseGuildDefault==true) and (GLDG_config_from_guild ~= "not found") and (GLDG_config_from_guild ~= "corrupted") then
		if bit.band("0x"..gstring1, 1) >0 then GLDG_Data.GuildSettings.GreetAsMain=true else GLDG_Data.GuildSettings.GreetAsMain=false end
		if bit.band("0x"..gstring1, 2) >0 then GLDG_Data.GuildSettings.Randomize=true else GLDG_Data.GuildSettings.Randomize=false end
		if bit.band("0x"..gstring1, 2^2) >0 then GLDG_Data.GuildSettings.Whisper=true else GLDG_Data.GuildSettings.Whisper=false end
		if bit.band("0x"..gstring1, 2^3) >0 then GLDG_Data.GuildSettings.WhisperLevelup=true else GLDG_Data.GuildSettings.WhisperLevelup=false end
		if bit.band("0x"..gstring1, 2^4) >0 then GLDG_Data.GuildSettings.IncludeOwn=true else GLDG_Data.GuildSettings.IncludeOwn=false end
		if bit.band("0x"..gstring1, 2^5) >0 then GLDG_Data.GuildSettings.AutoAssign=true else GLDG_Data.GuildSettings.AutoAssign=false end
		if bit.band("0x"..gstring1, 2^6) >0 then GLDG_Data.GuildSettings.AutoAssignEgp=true else GLDG_Data.GuildSettings.AutoAssignEgp=false end
		if bit.band("0x"..gstring1, 2^7) >0 then GLDG_Data.GuildSettings.AutoAssignAlias=true else GLDG_Data.GuildSettings.AutoAssignAlias=false end
		if bit.band("0x"..gstring1, 2^8) >0 then GLDG_Data.GuildSettings.ListNames=true else GLDG_Data.GuildSettings.ListNames=false end
		if bit.band("0x"..gstring1, 2^9) >0 then GLDG_Data.GuildSettings.ListNamesOff=true else GLDG_Data.GuildSettings.ListNamesOff=false end
		if bit.band("0x"..gstring1, 2^10) >0 then GLDG_Data.GuildSettings.ListLevelUp=true else GLDG_Data.GuildSettings.ListLevelUp=false end
		if bit.band("0x"..gstring1, 2^11) >0 then GLDG_Data.GuildSettings.ListLevelUpOff=true else GLDG_Data.GuildSettings.ListLevelUpOff=false end
		if bit.band("0x"..gstring1, 2^12) >0 then GLDG_Data.GuildSettings.ListAchievments=true else GLDG_Data.GuildSettings.ListAchievments=false end
		if bit.band("0x"..gstring1, 2^13) >0 then GLDG_Data.GuildSettings.ListQuit=true else GLDG_Data.GuildSettings.ListQuit=false end
		if bit.band("0x"..gstring1, 2^14) >0 then GLDG_Data.GuildSettings.ExtendChat=true else GLDG_Data.GuildSettings.ExtendChat=false end
		if bit.band("0x"..gstring1, 2^15) >0 then GLDG_Data.GuildSettings.ExtendIgnored=true else GLDG_Data.GuildSettings.ExtendIgnored=false end
		if bit.band("0x"..gstring1, 2^16) >0 then GLDG_Data.GuildSettings.ExtendMain=true else GLDG_Data.GuildSettings.ExtendMain=false end
		if bit.band("0x"..gstring1, 2^17) >0 then GLDG_Data.GuildSettings.ExtendAlias=true else GLDG_Data.GuildSettings.ExtendAlias=false end
		if bit.band("0x"..gstring1, 2^18) >0 then GLDG_Data.GuildSettings.AddPostfix=true else GLDG_Data.GuildSettings.AddPostfix=false end
		if bit.band("0x"..gstring1, 2^19) >0 then GLDG_Data.GuildSettings.ShowWhoSpam=true else GLDG_Data.GuildSettings.ShowWhoSpam=false end
		if bit.band("0x"..gstring1, 2^20) >0 then GLDG_Data.GuildSettings.SupressGreet=true else GLDG_Data.GuildSettings.SupressGreet=false end
		if bit.band("0x"..gstring1, 2^21) >0 then GLDG_Data.GuildSettings.SupressJoin=true else GLDG_Data.GuildSettings.SupressJoin=false end
		if bit.band("0x"..gstring1, 2^22) >0 then GLDG_Data.GuildSettings.SupressLevel=true else GLDG_Data.GuildSettings.SupressLevel=false end
		if bit.band("0x"..gstring1, 2^23) >0 then GLDG_Data.GuildSettings.SupressRank=true else GLDG_Data.GuildSettings.SupressRank=false end
		if bit.band("0x"..gstring1, 2^24) >0 then GLDG_Data.GuildSettings.SupressAchievment=true else GLDG_Data.GuildSettings.SupressAchievment=false end
		if bit.band("0x"..gstring1, 2^25) >0 then GLDG_Data.GuildSettings.NoGratsOnLogin=true else GLDG_Data.GuildSettings.NoGratsOnLogin=false end
		if bit.band("0x"..gstring1, 2^26) >0 then GLDG_Data.GuildSettings.DeltaPopup=true else GLDG_Data.GuildSettings.DeltaPopup=false end
		GLDG_Data.GuildSettings.RelogTime = tonumber(gstring2, 16)
		GLDG_Data.GuildSettings.MinLevelUp= tonumber(gstring3, 16)

		GLDG_Data[GLDG_unique_GuildName].GreetAsMain = GLDG_Data.GuildSettings.GreetAsMain
		GLDG_Data[GLDG_unique_GuildName].Randomize = GLDG_Data.GuildSettings.Randomize
		GLDG_Data[GLDG_unique_GuildName].Whisper = GLDG_Data.GuildSettings.Whisper
		GLDG_Data[GLDG_unique_GuildName].WhisperLevelup = GLDG_Data.GuildSettings.WhisperLevelup
		GLDG_Data[GLDG_unique_GuildName].IncludeOwn = GLDG_Data.GuildSettings.IncludeOwn
		GLDG_Data[GLDG_unique_GuildName].AutoAssign = GLDG_Data.GuildSettings.AutoAssign
		GLDG_Data[GLDG_unique_GuildName].AutoAssignEgp = GLDG_Data.GuildSettings.AutoAssignEgp
		GLDG_Data[GLDG_unique_GuildName].AutoAssignAlias = GLDG_Data.GuildSettings.AutoAssignAlias
		GLDG_Data[GLDG_unique_GuildName].ListNames = GLDG_Data.GuildSettings.ListNames
		GLDG_Data[GLDG_unique_GuildName].ListNamesOff = GLDG_Data.GuildSettings.ListNamesOff
		GLDG_Data[GLDG_unique_GuildName].ListLevelUp = GLDG_Data.GuildSettings.ListLevelUp
		GLDG_Data[GLDG_unique_GuildName].ListLevelUpOff = GLDG_Data.GuildSettings.ListLevelUpOff
		GLDG_Data[GLDG_unique_GuildName].ListAchievments = GLDG_Data.GuildSettings.ListAchievments
		GLDG_Data[GLDG_unique_GuildName].ListQuit = GLDG_Data.GuildSettings.ListQuit
		GLDG_Data[GLDG_unique_GuildName].ExtendChat = GLDG_Data.GuildSettings.ExtendChat
		GLDG_Data[GLDG_unique_GuildName].ExtendIgnored = GLDG_Data.GuildSettings.ExtendIgnored
		GLDG_Data[GLDG_unique_GuildName].ExtendMain = GLDG_Data.GuildSettings.ExtendMain
		GLDG_Data[GLDG_unique_GuildName].ExtendAlias = GLDG_Data.GuildSettings.ExtendAlias
		GLDG_Data[GLDG_unique_GuildName].AddPostfix = GLDG_Data.GuildSettings.AddPostfix
		GLDG_Data[GLDG_unique_GuildName].ShowWhoSpam = GLDG_Data.GuildSettings.ShowWhoSpam
		GLDG_Data[GLDG_unique_GuildName].SupressGreet = GLDG_Data.GuildSettings.SupressGreet
		GLDG_Data[GLDG_unique_GuildName].SupressJoin = GLDG_Data.GuildSettings.SupressJoin
		GLDG_Data[GLDG_unique_GuildName].SupressLevel = GLDG_Data.GuildSettings.SupressLevel
		GLDG_Data[GLDG_unique_GuildName].SupressRank = GLDG_Data.GuildSettings.SupressRank
		GLDG_Data[GLDG_unique_GuildName].SupressAchievment = GLDG_Data.GuildSettings.SupressAchievment
		GLDG_Data[GLDG_unique_GuildName].NoGratsOnLogin = GLDG_Data.GuildSettings.NoGratsOnLogin
		GLDG_Data[GLDG_unique_GuildName].DeltaPopup = GLDG_Data.GuildSettings.DeltaPopup
		GLDG_Data[GLDG_unique_GuildName].RelogTime = GLDG_Data.GuildSettings.RelogTime
		GLDG_Data[GLDG_unique_GuildName].MinLevelUp = GLDG_Data.GuildSettings.MinLevelUp
		GLDG_Data[GLDG_unique_GuildName].UseGuildDefault = true

		if (GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] ~= date("%m/%d/%y")) or (GLDG_Data[GLDG_unique_GuildName.." lastmessage"] ~= 1) then
			GLDG:PrintHelp(string.format(L["ChatMsg/Config string found. GuildGreet using default settings from %s!"],Ambiguate(GLDG_GuildLeader, "guild")))
			GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] = date("%m/%d/%y")
			GLDG_Data[GLDG_unique_GuildName.." lastmessage"] = 1
		end
		--GLDG_Init()
	else
		if GLDG_Data.GuildSettings.UseGuildDefault==true and GLDG_unique_GuildName then
			GLDG_Data.GuildSettings.GreetAsMain=false
			GLDG_Data.GuildSettings.Randomize=false
			GLDG_Data.GuildSettings.Whisper=false
			GLDG_Data.GuildSettings.WhisperLevelup=false
			GLDG_Data.GuildSettings.IncludeOwn=true
			GLDG_Data.GuildSettings.AutoAssign=false
			GLDG_Data.GuildSettings.AutoAssignEgp=false
			GLDG_Data.GuildSettings.AutoAssignAlias=false
			GLDG_Data.GuildSettings.ListNames=true
			GLDG_Data.GuildSettings.ListNamesOff=true
			GLDG_Data.GuildSettings.ListLevelUp=true
			GLDG_Data.GuildSettings.ListLevelUpOff=true
			GLDG_Data.GuildSettings.ListAchievments=true
			GLDG_Data.GuildSettings.ListQuit=true
			GLDG_Data.GuildSettings.ExtendChat=true
			GLDG_Data.GuildSettings.ExtendIgnored=true
			GLDG_Data.GuildSettings.ExtendMain=true
			GLDG_Data.GuildSettings.ExtendAlias=true
			GLDG_Data.GuildSettings.AddPostfix=true
			GLDG_Data.GuildSettings.ShowWhoSpam=false
			GLDG_Data.GuildSettings.SupressGreet=false
			GLDG_Data.GuildSettings.SupressJoin=false
			GLDG_Data.GuildSettings.SupressLevel=false
			GLDG_Data.GuildSettings.SupressRank=false
			GLDG_Data.GuildSettings.SupressAchievment=false
			GLDG_Data.GuildSettings.NoGratsOnLogin=true
			GLDG_Data.GuildSettings.DeltaPopup=true
			GLDG_Data.GuildSettings.RelogTime = 2
			GLDG_Data.GuildSettings.MinLevelUp= 20
			GLDG_Data[GLDG_unique_GuildName] = GLDG_Data.GuildSettings

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
			end
			if GLDG_config_from_guild == "corrupted" then
				if IsGuildLeader() then
						GLDG:PrintHelp(L["ChatMsg/The config string seems to be corrupted. Please generating a new one."].." \r\n"..L["ChatMsg/GuildGreet using default settings!"])
					else
					if (GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] ~= date("%m/%d/%y")) or (GLDG_Data[GLDG_unique_GuildName.." lastmessage"] ~= 5) then
						GLDG:PrintHelp(string.format(L["ChatMsg/The config string seems to be corrupted. Please inform %s!"],Ambiguate(GLDG_GuildLeader, "guild")).." \r\n"..L["ChatMsg/GuildGreet using default settings!"])
						GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] = date("%m/%d/%y")
						GLDG_Data[GLDG_unique_GuildName.." lastmessage"] = 5
					end
				end
			end
		end
	end
	if (GLDG_Data.GuildSettings.UseGuildDefault==nil) then
		if GLDG_config_from_guild then
			if GLDG_config_from_guild == "not found" then
				if (GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] ~= date("%m/%d/%y")) or (GLDG_Data[GLDG_unique_GuildName.." lastmessage"] ~= 6) then
					GLDG:PrintHelp(L["ChatMsg/GuildGreet using your own settings!"])
					GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] = date("%m/%d/%y")
					GLDG_Data[GLDG_unique_GuildName.." lastmessage"] = 6
				end
				if IsGuildLeader() then
					if (GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] ~= date("%m/%d/%y")) or (GLDG_Data[GLDG_unique_GuildName.." lastmessage"] ~= 7) then
						GLDG:PrintHelp(L["ChatMsg/Note to the guild master to create the config string"].." \r\n"..L["ChatMsg/To set the config string ..."])
						GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] = date("%m/%d/%y")
						GLDG_Data[GLDG_unique_GuildName.." lastmessage"] = 7
					end
				end
			end
			if GLDG_config_from_guild == "corrupted" then
				if IsGuildLeader() then
					--if (GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] ~= date("%m/%d/%y")) or (GLDG_Data[GLDG_unique_GuildName.." lastmessage"] ~= 8) then
						GLDG:PrintHelp(L["ChatMsg/GuildGreet using your own Settings. But the config string seems to be corrupted. Please generating a new one."])
					--	GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] = date("%m/%d/%y")
					--	GLDG_Data[GLDG_unique_GuildName.." lastmessage"] = 8
					--end
				else
					if (GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] ~= date("%m/%d/%y")) or (GLDG_Data[GLDG_unique_GuildName.." lastmessage"] ~= 9) then
						GLDG:PrintHelp(string.format(L["ChatMsg/GuildGreet using your own Settings. But the config string seems to be corrupted. Please inform %s!"],Ambiguate(GLDG_GuildLeader, "guild")))
						GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] = date("%m/%d/%y")
						GLDG_Data[GLDG_unique_GuildName.." lastmessage"] = 9
					end
				end
			end
			if (GLDG_config_from_guild ~= "corrupted") and (GLDG_config_from_guild ~= "not found") then
				if (GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] ~= date("%m/%d/%y")) or (GLDG_Data[GLDG_unique_GuildName.." lastmessage"] ~= 10) then
					GLDG:PrintHelp(L["ChatMsg/GuildGreet using your own settings (But a config string is in the guild info available)."])
					GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] = date("%m/%d/%y")
					GLDG_Data[GLDG_unique_GuildName.." lastmessage"] = 10
				end
			end
		end
	end
end

function GLDG_WriteGuildString()
	return GLDG.Database:WriteGuildString()
end


