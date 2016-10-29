--[[--------------------------------------------------------
-- GuildGreet, a World of Warcraft social guild assistant --
------------------------------------------------------------
CODE INDEX (search on index for fast access):
_01_ Addon Variables
_02_ Addon Startup
_03_ Event Handler
_04_ Addon Initialization
_05_ Guild Roster Import
_06_ Monitor System Messages
_07_ Display Greetlist
_08_ Display Greeting Tooltip
_09_ Greet Players
_10_ Slash Handler
_11_ Tab Changer
_12_ Settings Tab Update
_13_ Greetings Tab Update
_14_ Players Tab Update
_15_ General Helper Functions
_16_ List frame
_17_ player menu
_18_ Friends list parsing
_19_ Achievments
_20_ Channel handling
_21_ Testing
_22_ Showing stored information
_23_ Colour picker handling
_24_ Colour handling
_25_ Display Help Tooltip
_26_ Chat name extension
_27_ Debug dumping
_28_ Interface reloading
_29_ urbin addon listing
_30_ big brother
_31_ conversion
_32_ guild alert check
_33_ cleanup
_34_ interface options
_35_ startup popup handling

]]----------------------------------------------------------
--local GLDG = LibStub("AceAddon-3.0"):NewAddon("GuildGreet", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", false)

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
GDLG_VNMBR	= 700000			-- Number code for this version

-- Table linking tabs to frames
GLDG_Tab2Frame = {}
GLDG_Tab2Frame.Tab1 = "Settings"
GLDG_Tab2Frame.Tab2 = "Greetings"
GLDG_Tab2Frame.Tab3 = "Players"
GLDG_Tab2Frame.Tab4 = "Cleanup"
GLDG_Tab2Frame.Tab5 = "Colour"


GLDG_SubTab2Frame = {}
GLDG_SubTab2Frame.Tab1 = "General"
GLDG_SubTab2Frame.Tab2 = "Chat"
GLDG_SubTab2Frame.Tab3 = "Greeting"
--GLDG_SubTab2Frame.Tab4 = "Debug"
GLDG_SubTab2Frame.Tab4 = "Other"


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

GLDG_ONLINE_COLOUR				= GLDG_DEFAULT_ONLINE_COLOUR
GLDG_IS_OFFLINE_COLOUR		= GLDG_DEFAULT_IS_OFFLINE_COLOUR
GLDG_GOES_OFFLINE_COLOUR	= GLDG_DEFAULT_GOES_OFFLINE_COLOUR
GLDG_ALIAS_COLOUR					= GLDG_DEFAULT_ALIAS_COLOUR

GLDG_LEVEL_CAP = 110

GLDG_CONFIG_STRING = nil
GLDG_CONFIG_STRING_A = nil
GLDG_CONFIG_STRING_B = nil
GLDG_CONFIG_STRING_C = nil
GLDG_CONFIG_STRING_D = nil
--------------------------
-- _01_ Addon Variables --
--------------------------

-- Stored data
GLDG_Data = {}			        -- Data saved between sessions
GLDG_DataGreet = nil		    -- Pointer to relevant greeting section in GLDG_Data
GLDGL_DataChar = nil		    -- Pointer to relevant character section in GLDG_Data

-- Initialization
GLDG_Main = nil			        -- Main program window
GLDG_Realm = nil		        -- Name of the current realm
GLDG_Player = nil		        -- Name of the current player
GLDG_shortName = nil            -- Playername without Server
GLDG_GuildName = nil		    -- Name of your guild
GLDG_GuildAlias = nil		    -- Alias of your guild
GLDG_GuildLeader = nil
GLDG_unique_GuildName = nil
GLDG_ginfotxt = nil
GLDG_config_from_guild = nil
GLDG_corrupted_config_from_guild = nil
GLDG_NewGuild = nil		        -- Set if initializing a new guild
GLDG_InitialGuildUpdate = nil	-- To make sure we get at least one update
GLDG_InitialFriendsUpdate = nil	-- To make sure we get at least one update
GLDG_UpdateRequest = 0		    -- If set with time, update will be performed
GLDG_UpdateRequestFriends = 0	-- If set with time, update will be performed
GLDG_InitComplete = nil		    -- Set in initialization is done
GLDG_ReadNotes = 1
GLDG_RosterImportRunning = 0
GLDG_InitCheck = 0		        -- Check for changes and display them; 0 = not started, 1 = pending guild, 2 = pending friends, 4 = pending channel, 8 = done guild, 16 = done friends, 32 = done channel
GLDG_ChangesText = {}		    -- text for popup display

-- Various
GLDG_Debug = false		-- Show debugging

-- Core variables
GLDG_Online = {}		-- Time of player going online
GLDG_Offline = {}		-- Time of player going offline			-- todo: make this persistent?
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
function GLDG_OnLoad(self)
	-- Events monitored by Event Handler
	GLDG_Main = self
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("VARIABLES_LOADED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("SAVED_VARIABLES_TOO_LARGE")

	-- Slash commands for CLI
	SLASH_GLDG1 = "/guildgreet"
	SLASH_GLDG2 = "/gg"
	SLASH_GLDG3 = "/greet"
	SlashCmdList.GLDG = GLDG_SlashHandler
end
------------------------------------------------------------
--function GLDG_myAddons()
--	-- Register addon with myAddons
--	if not (myAddOnsFrame_Register) then return end
--	local version = GetAddOnMetadata("GuildGreet", "Version");
--	local date = GetAddOnMetadata("GuildGreet", "X-Date");
--	local author = GetAddOnMetadata("GuildGreet", "Author");
--	local web = GetAddOnMetadata("GuildGreet", "X-Website");
--	if (version == nil) then
--		version = "unknown";
--	end
--	if (date == nil) then
--		date = "unknown";
--	end
--	if (author == nil) then
--		author = "unknown";
--	end
--	if (web == nil) then
--		web = "unknown";
--	end

--	myAddOnsFrame_Register({
--		name = GLDG_NAME,
--		version = version,
--		releaseDate = date,
--		author = author,
--		email = "none",
--		website = web,
--		category = MYADDONS_CATEGORY_GUILD,
--		optionsframe = GLDG_GUI,
--	})
--end


------------------------
-- _03_ Event Handler --
------------------------

function GLDG_OnEvent(self, event, ...)
	local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13 = ...
	-- Distribute events to appropriate functions
	if (event == "ADDON_LOADED") and (arg1 == GLDG_NAME) then
		GLDG_Main:UnregisterEvent("ADDON_LOADED")
		if GLDG_InitComplete==nil then
--			GLDG_myAddons()
			GLDG_Init()
			--GLDG_RegisterUrbinAddon(GLDG_NAME, GLDG_About)
		end
	elseif (event == "VARIABLES_LOADED") then
		GLDG_Main:UnregisterEvent("VARIABLES_LOADED")

		if GLDG_InitComplete==nil then
--			GLDG_myAddons()
			GLDG_Init()
			--GLDG_RegisterUrbinAddon(GLDG_NAME, GLDG_About)
		end				
		GLDG_autoConsistencyCheckReady = true

		-- add menu to player frame and chat menu
		if (GLDG_Data.ExtendPlayerMenu==true) then
			GLDG_AddPopUpButtons();
		end

	elseif (event == "PLAYER_ENTERING_WORLD") then
		if GLDG_InitComplete==nil then
			GLDG_Init()
		end
		GLDG_CheckForGuildAlert()
		GLDG_InitRoster()
		GLDG_Main:UnregisterEvent("PLAYER_ENTERING_WORLD")
		GLDG_Main:RegisterEvent("GUILD_ROSTER_UPDATE")
		GLDG_Main:RegisterEvent("FRIENDLIST_UPDATE")
		GLDG_Main:RegisterEvent("FRIENDLIST_SHOW")
		GLDG_Main:RegisterEvent("CHAT_MSG_CHANNEL_JOIN")
		GLDG_Main:RegisterEvent("CHAT_MSG_CHANNEL_LEAVE")
		GLDG_Main:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")
		--GLDG_Main:RegisterEvent("CHAT_MSG_CHANNEL_LIST")
		GLDG_Main:RegisterEvent("CHAT_MSG_ADDON")
		GLDG_Main:RegisterEvent("GROUP_ROSTER_UPDATE")
		GLDG_Main:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")
		GLDG_Main:RegisterEvent("WHO_LIST_UPDATE")

		-- hooking msg events (replacing old ChatFrame_OnEvent handling)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", GLDG_ChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", GLDG_ChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", GLDG_ChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", GLDG_ChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_ACHIEVEMENT", GLDG_ChatFilter)

		-- Battle.net events (testing)
		GLDG_Main:RegisterEvent("BN_CONNECTED")
		GLDG_Main:RegisterEvent("BN_DISCONNECTED")
		GLDG_Main:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
		GLDG_Main:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
		GLDG_Main:RegisterEvent("BN_FRIEND_INFO_CHANGED")
		GLDG_Main:RegisterEvent("BN_FRIEND_TOON_OFFLINE")
		GLDG_Main:RegisterEvent("BN_FRIEND_TOON_ONLINE")
		GLDG_Main:RegisterEvent("BN_SELF_OFFLINE")
		GLDG_Main:RegisterEvent("BN_SELF_ONLINE")
		GLDG_Main:RegisterEvent("BN_SYSTEM_MESSAGE")
		GLDG_Main:RegisterEvent("BN_TOON_NAME_UPDATED")

	elseif (event == "GUILD_ROSTER_UPDATE") then
		if IsInGuild() then
			if (GLDG_unique_GuildName and GLDG_Realm and GLDG_unique_GuildName~="") then
				-- guild name known -> treat guild info
				if (GLDG_ginfotxt) and (GLDG_ginfotxt ~= GetGuildInfoText()) then GLDG_ginfotxt = GetGuildInfoText(); GLDG_config_from_guild = nil end
				if GLDG_Data.GuildSettings.UseGuildDefault==true and GLDG_config_from_guild == nil then
					GLDG_ginfotxt = GetGuildInfoText()
					if GLDG_ginfotxt >= " " then
						if not GLDG_Data[GLDG_unique_GuildName] then GLDG_Data[GLDG_unique_GuildName] = {} end
						if not GLDG_Data.GuildSettings then GLDG_Data.GuildSettings = {} end
						GLDG_Data.GuildSettings.UseGuildDefault=true
						GLDG_readConfigString()
						GLDG_SetCheckboxes()
					end
				end
				if GLDG_Data.GuildSettings.UseGuildDefault == false and GLDG_config_from_guild == nil then
					GLDG_ginfotxt = GetGuildInfoText()
					if GLDG_ginfotxt >= " " then
						GLDG_readConfigString()
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
			-- nothing to do if not in guild
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
		GLDG_SystemMsg(arg1)
			
	elseif ((event == "FRIENDLIST_UPDATE") or (event == "FRIENDLIST_SHOW")) then
		if (GLDG_Realm and GLDG_Player) then
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
				if (GLDG_Data.ShowNewerVersions==true) then
					local myVersion	= GetAddOnMetadata("GuildGreet", "Version")
					local hisVersion = string.sub(arg2, 5)

					if (not GLDG_HighestVersion) then
						GLDG_HighestVersion = myVersion
					end

					if (GLDG_Data.BigBrother and (arg4 ~= GLDG_Player)) then
						if (not GLDG_BigBrother) then
							GLDG_BigBrother = {}
						end
						if (not GLDG_BigBrother[arg4]) then
							GLDG_BigBrother[arg4] = hisVersion
							GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..arg4..GLDG_TXT.bigBrother..hisVersion)
						elseif (GLDG_BigBrother[arg4] ~= hisVersion) then
							GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..arg4..GLDG_TXT.bigBrother2..GLDG_BigBrother[arg4]..GLDG_TXT.bigBrother3..hisVersion..GLDG_TXT.bigBrother4)
							GLDG_BigBrother[arg4] = hisVersion
						end
					end

					--GLDG_Print("    My Version ["..myVersion.."] - Other Version ["..hisVersion.."]")
					if (hisVersion > myVersion) then
						if (hisVersion > GLDG_HighestVersion) then
							-- to make sure, we only warn once
							GLDG_HighestVersion = hisVersion

							GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.newer)
							GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.newer1..myVersion..GLDG_TXT.newer4)
							GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.newer2..arg4..GLDG_TXT.newer3..hisVersion..GLDG_TXT.newer4)
						else
							--GLDG_Print("    "..arg4.." has version "..hisVersion.." - you have "..myVersion.." - highest seen "..GLDG_HighestVersion)
						end
					end
				end
			elseif (string.sub(arg2, 1, 6)=="QUERY:") then
				SendAddonMessage("GLDG", "VER:"..GetAddOnMetadata("GuildGreet", "Version"), "GUILD")
				local inInstance, instanceType = IsInInstance()
				if (instanceType ~= "pvp") and (instanceType ~= "arena") and (GetNumSubgroupMembers() > 0) then
					SendAddonMessage("GLDG", "VER:"..GetAddOnMetadata("GuildGreet", "Version"), "PARTY")
				end
				if (instanceType ~= "pvp") and (instanceType ~= "arena") and (GetNumGroupMembers() > 0) then
					SendAddonMessage("GLDG", "VER:"..GetAddOnMetadata("GuildGreet", "Version"), "RAID")
				end
				if (instanceType == "pvp") then
					SendAddonMessage("GLDG", "VER:"..GetAddOnMetadata("GuildGreet", "Version"), "BATTLEGROUND")
				end
			end
		end

	-- catching people leaving or entering party/raid
	-- it seems that GetNumParty/RaidMembers() returns >0 when in BGs but PARTY and RAID are unavailable in these settings
	elseif (event == "GROUP_ROSTER_UPDATE") then
		local inInstance, instanceType = IsInInstance()
		if (instanceType ~= "pvp") and (instanceType ~= "arena") and (GetNumSubgroupMembers() > 0 ) then
			SendAddonMessage("GLDG", "VER:"..GetAddOnMetadata("GuildGreet", "Version"), "PARTY")
		end
		if (instanceType ~= "pvp") and (instanceType ~= "arena") and (GetNumGroupMembers() > 0) then
			SendAddonMessage("GLDG", "VER:"..GetAddOnMetadata("GuildGreet", "Version"), "RAID")
		end
		if (instanceType == "pvp") then
			SendAddonMessage("GLDG", "VER:"..GetAddOnMetadata("GuildGreet", "Version"), "BATTLEGROUND")
		end

	elseif (event == "BN_CONNECTED") or
		(event == "BN_DISCONNECTED") or
		(event == "BN_FRIEND_ACCOUNT_OFFLINE") or
		(event == "BN_FRIEND_ACCOUNT_ONLINE") or
		(event == "BN_FRIEND_INFO_CHANGED") or
		(event == "BN_FRIEND_TOON_OFFLINE") or
		(event == "BN_FRIEND_TOON_ONLINE") or
		(event == "BN_SELF_OFFLINE") or
		(event == "BN_SELF_ONLINE") or
		(event == "BN_SYSTEM_MESSAGE") or
		(event == "BN_TOON_NAME_UPDATED") then
		if (arg1~=nil) or (arg2~=nil) or (arg3~=nil) or (arg4~=nil) or (arg5~=nil) or (arg6~=nil) or (arg7~=nil) or (arg8~=nil) or (arg9~=nil) or (arg10~=nil) or (arg11~=nil) or (arg12~=nil) or (arg13~=nil) then
			--GLDG_Print("[Battle.Net] event ["..tostring(event).."]: arg1: "..tostring(arg1).." - arg2: "..tostring(arg2).." - arg3: "..tostring(arg3).." - arg4: "..tostring(arg4).." - arg5: "..tostring(arg5).." - arg6: "..tostring(arg6).." - arg7: "..tostring(arg7).." - arg8: "..tostring(arg8).." - arg9: "..tostring(arg9).." - arg10: "..tostring(arg10).." - arg11: "..tostring(arg11).." - arg12: "..tostring(arg12).." - arg13: "..tostring(arg13));
		end
		--GLDG_Test()
	end
end


-------------------------------
-- _04_ Addon Initialization --
-------------------------------

function GLDG_Init()
	local version = GetAddOnMetadata("GuildGreet", "Version");
	if (version == nil) then
		version = "unknown";
	end

	-- store realm and player names
	if not GLDG_Realm then GLDG_Realm = GetRealmName() end
	if not GLDG_Player then GLDG_Player = UnitName("player") end

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
	

--	if GLDG_Data.GuildSettings.UseGuildDefault==nil and GLDG_Data[GLDG_unique_GuildName] then
--		GLDG_Data.GuildSettings = GLDG_Data[GLDG_unique_GuildName]
--	end	
	if not GLDG_Data.GuildSettings.RelogTime then GLDG_Data.GuildSettings.RelogTime = 2 end
	if not GLDG_Data.GuildSettings.MinLevelUp then GLDG_Data.GuildSettings.MinLevelUp = 0 end
	GLDG_Data.UpdateTime = 0
	if not GLDG_Data.GuildSettings.UseGuildDefault then GLDG_Data.GuildSettings.UseGuildDefault = false end
	if not GLDG_Data.ListSize then GLDG_Data.ListSize = 5 end
	if not GLDG_Data.PlayerChatFrame then GLDG_Data.PlayerChatFrame = {} end
	if not GLDG_Data.PlayerChatFrame[GLDG_Player.."-"..GLDG_Realm] then GLDG_Data.PlayerChatFrame[GLDG_Player.."-"..GLDG_Realm] = 0 end

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
	if not GLDG_Data.GuildSettings.NoGratsOnLogin		then GLDG_Data.GuildSettings.NoGratsOnLogin = false end

	if not GLDG_Data.UseLocalTime		then GLDG_Data.UseLocalTime = false end
	if not GLDG_Data.ShowNewerVersions	then GLDG_Data.ShowNewerVersions = false end
	if not GLDG_Data.AutoWho		then GLDG_Data.AutoWho = false end
	if not GLDG_Data.GuildSettings.DeltaPopup		then GLDG_Data.GuildSettings.DeltaPopup = false end
	if not GLDG_Data.ExtendPlayerMenu then GLDG_Data.ExtendPlayerMenu = false end
	-- convert for API 6.0.2 begin
	if GLDG_Data.GuildSettings.SupressGreet==1		then GLDG_Data.GuildSettings.SupressGreet = true end
	if GLDG_Data.GuildSettings.SupressJoin==1		then GLDG_Data.GuildSettings.SupressJoin = true end
	if GLDG_Data.GuildSettings.SupressLevel==1		then GLDG_Data.GuildSettings.SupressLevel = true end
	if GLDG_Data.GuildSettings.SupressRank==1		then GLDG_Data.GuildSettings.SupressRank = true end
	if GLDG_Data.GuildSettings.SupressAchievment==1	then GLDG_Data.GuildSettings.SupressAchievment = true end
	if GLDG_Data.GuildSettings.NoGratsOnLogin==1		then GLDG_Data.GuildSettings.NoGratsOnLogin = true end

	if GLDG_Data.UseLocalTime==1		then GLDG_Data.UseLocalTime = true end
	if GLDG_Data.ShowNewerVersions==1	then GLDG_Data.ShowNewerVersions = true end
	if GLDG_Data.AutoWho==1		then GLDG_Data.AutoWho = true end
	if GLDG_Data.GuildSettings.DeltaPopup==1		then GLDG_Data.GuildSettings.DeltaPopup = true end
	if GLDG_Data.ExtendPlayerMenu==1 then GLDG_Data.ExtendPlayerMenu = true end
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

	if GLDG_Data.ShowIgnore == 1 then GLDG_Data.ShowIgnore = true end
	if GLDG_Data.ShowAlt == 1 then GLDG_Data.ShowAlt = true end
	if GLDG_Data.GroupAlt == 1 then GLDG_Data.GroupAlt = true end
	if GLDG_Data.FilterUnassigned == 1 then GLDG_Data.FilterUnassigned = true end
	if GLDG_Data.FilterOnline == 1 then GLDG_Data.FilterOnline = true end
	if GLDG_Data.FilterMyFriends == 1 then GLDG_Data.FilterMyFriends = true end
	if GLDG_Data.FilterWithFriends == 1 then GLDG_Data.FilterWithFriends = true end
	if GLDG_Data.FilterCurrentChannel == 1 then GLDG_Data.FilterCurrentChannel = true end
	if GLDG_Data.FilterWithChannel == 1 then GLDG_Data.FilterWithChannel = true end	
	
	
	if not GLDG_Data.colours		then GLDG_Data.colours = {} end
	if not GLDG_Data.colours.guild		then GLDG_Data.colours.guild = {} end
	if not GLDG_Data.colours.friends	then GLDG_Data.colours.friends = {} end
	if not GLDG_Data.colours.channel	then GLDG_Data.colours.channel = {} end
	if not GLDG_Data.colours.help 		then GLDG_Data.colours.help = GLDG_DEFAULT_HELP_COLOUR end
	if not GLDG_Data.colours.header		then GLDG_Data.colours.header = GLDG_DEFAULT_HEADER_COLOUR end

	if not GLDG_Data.colours.guild.online	then GLDG_Data.colours.guild.online = GLDG_DEFAULT_ONLINE_COLOUR end
	if not GLDG_Data.colours.guild.isOff	then GLDG_Data.colours.guild.isOff = GLDG_DEFAULT_IS_OFFLINE_COLOUR end
	if not GLDG_Data.colours.guild.goOff	then GLDG_Data.colours.guild.goOff = GLDG_DEFAULT_GOES_OFFLINE_COLOUR end
	if not GLDG_Data.colours.guild.alias	then GLDG_Data.colours.guild.alias = GLDG_DEFAULT_ALIAS_COLOUR end
	if not GLDG_Data.colours.guild.list	then GLDG_Data.colours.guild.list = GLDG_DEFAULT_LIST_COLOUR end
	if not GLDG_Data.colours.guild.new	then GLDG_Data.colours.guild.new = GLDG_DEFAULT_NEW_COLOUR end
	if not GLDG_Data.colours.guild.lvl	then GLDG_Data.colours.guild.lvl = GLDG_DEFAULT_LVL_COLOUR end
	if not GLDG_Data.colours.guild.rank	then GLDG_Data.colours.guild.rank = GLDG_DEFAULT_RANK_COLOUR end
	if not GLDG_Data.colours.guild.relog	then GLDG_Data.colours.guild.relog = GLDG_DEFAULT_RELOG_COLOUR end
	if not GLDG_Data.colours.guild.achievment then GLDG_Data.colours.guild.achievment = GLDG_DEFAULT_ACHIEVMENT_COLOUR end

	if not GLDG_Data.colours.friends.online	then GLDG_Data.colours.friends.online = GLDG_DEFAULT_ONLINE_COLOUR end
	if not GLDG_Data.colours.friends.isOff	then GLDG_Data.colours.friends.isOff = GLDG_DEFAULT_IS_OFFLINE_COLOUR end
	if not GLDG_Data.colours.friends.goOff	then GLDG_Data.colours.friends.goOff = GLDG_DEFAULT_GOES_OFFLINE_COLOUR end
	if not GLDG_Data.colours.friends.alias	then GLDG_Data.colours.friends.alias = GLDG_DEFAULT_ALIAS_COLOUR end
	if not GLDG_Data.colours.friends.list	then GLDG_Data.colours.friends.list = GLDG_DEFAULT_LIST_COLOUR end
	if not GLDG_Data.colours.friends.new	then GLDG_Data.colours.friends.new = GLDG_DEFAULT_NEW_COLOUR end
	if not GLDG_Data.colours.friends.lvl	then GLDG_Data.colours.friends.lvl = GLDG_DEFAULT_LVL_COLOUR end
	if not GLDG_Data.colours.friends.rank	then GLDG_Data.colours.friends.rank = GLDG_DEFAULT_RANK_COLOUR end
	if not GLDG_Data.colours.friends.relog	then GLDG_Data.colours.friends.relog = GLDG_DEFAULT_RELOG_COLOUR end
	if not GLDG_Data.colours.friends.achievment then GLDG_Data.colours.friends.achievment = GLDG_DEFAULT_ACHIEVMENT_COLOUR end

	if not GLDG_Data.colours.channel.online	then GLDG_Data.colours.channel.online = GLDG_DEFAULT_ONLINE_COLOUR end
	if not GLDG_Data.colours.channel.isOff	then GLDG_Data.colours.channel.isOff = GLDG_DEFAULT_IS_OFFLINE_COLOUR end
	if not GLDG_Data.colours.channel.goOff	then GLDG_Data.colours.channel.goOff = GLDG_DEFAULT_GOES_OFFLINE_COLOUR end
	if not GLDG_Data.colours.channel.alias	then GLDG_Data.colours.channel.alias = GLDG_DEFAULT_ALIAS_COLOUR end
	if not GLDG_Data.colours.channel.list	then GLDG_Data.colours.channel.list = GLDG_DEFAULT_LIST_COLOUR end
	if not GLDG_Data.colours.channel.new	then GLDG_Data.colours.channel.new = GLDG_DEFAULT_NEW_COLOUR end
	if not GLDG_Data.colours.channel.lvl	then GLDG_Data.colours.channel.lvl = GLDG_DEFAULT_LVL_COLOUR end
	if not GLDG_Data.colours.channel.rank	then GLDG_Data.colours.channel.rank = GLDG_DEFAULT_RANK_COLOUR end
	if not GLDG_Data.colours.channel.relog	then GLDG_Data.colours.channel.relog = GLDG_DEFAULT_RELOG_COLOUR end
	if not GLDG_Data.colours.channel.achievment then GLDG_Data.colours.channel.achievment = GLDG_DEFAULT_ACHIEVMENT_COLOUR end
	
	
	-- Set initial pointers to avoid errors (hack!)
	GLDG_DataChar = {}
	GLDG_DataGreet = {}

	GLDG_ChannelName = ""

	-- Keep version in configuration file
--	GLDG_Data.Version = GDLG_VNMBR

	-- Prepare popup dialogs
	GLDG_PrepareReloadQuestion()
	GLDG_PrepareAlertQuestion()

	-- Initialize the list GUI
	_G[GLDG_LIST.."TitleText"]:SetText(GLDG_NAME.." "..version)

	-- Initialize the config GUI
	_G[GLDG_GUI.."Title"]:SetText(GLDG_NAME.." "..version)

	-- Initialize the colour picker frame
	_G[GLDG_COLOUR.."RedText"]:SetText(GLDG_TXT.red)
	_G[GLDG_COLOUR.."GreenText"]:SetText(GLDG_TXT.green)
	_G[GLDG_COLOUR.."BlueText"]:SetText(GLDG_TXT.blue)
	_G[GLDG_COLOUR.."OpacityText"]:SetText(GLDG_TXT.opactiy)

	-- Make GUI close on escape
	tinsert(UISpecialFrames, GLDG_GUI)

	-- Initialize tabs and set the first one active
	local frame = _G[GLDG_GUI]
	PanelTemplates_SetNumTabs(frame, GLDG_TableSize(GLDG_Tab2Frame))
	PanelTemplates_SetTab(frame, 1)

	-- Set tab names and initialize tabframes
	for tabNum = 1, GLDG_TableSize(GLDG_Tab2Frame) do
		local tab = _G[GLDG_GUI.."Tab"..tabNum]
		local frameName = GLDG_Tab2Frame["Tab"..tabNum]
		if frameName then
			local label = L["Tab"..frameName]
			if label then
				-- tab has label: initialize frame
				tab:SetText(label)
				tab:Show()
				GLDG_InitFrame(frameName)
			end
		end
	end

	-- Initialize subtabs and set the first one active
	local frame = _G[GLDG_GUI.."Settings"]
	PanelTemplates_SetNumTabs(frame, GLDG_TableSize(GLDG_SubTab2Frame))
	PanelTemplates_SetTab(frame, 1)

	-- Set subtab names and initialize tabframes
	for tabNum = 1, GLDG_TableSize(GLDG_SubTab2Frame) do
		local tab = _G[GLDG_GUI.."SettingsTab"..tabNum]
		local subFrame = GLDG_SubTab2Frame["Tab"..tabNum]
		local frameName = "Settings"..subFrame
		if frameName then
			local label = L["SubTab"..subFrame]
			if label then
				-- tab has label: initialize frame
				tab:SetText(label)
				tab:Show()
				GLDG_InitFrame(frameName)
			end
		end
	end

	-- initialize the option frame
	_G["GuildGreetOptionsHeader"]:SetText(L["optionHeader"])

	GLDG_InitComplete = true

	GLDG_InitCheck = 0
	--GLDG_Print("InitCheck is ["..tostring(GLDG_InitCheck).."]")
end

------------------------------------------------------------
function GLDG_InitFrame(frameName)
	-- Set full name for frame
	local name = GLDG_GUI..frameName

	-- Configure the frames
	if (frameName == "Settings") then
		-- nothing to set
	elseif (frameName == "Greetings") then
		_G[name.."Header"]:SetText(L["Manage the messages you want to use for greeting"])
		_G[name.."CollectHeader"]:SetText(L["Custom collections"])
		_G[name.."ColRealm"]:SetText(L["Set realm collection"])
		_G[name.."ColGuild"]:SetText(L["Set guild collection"])
		_G[name.."ColPlayer"]:SetText(L["Set character collection"])
		_G[name.."SubCustomHeader"]:SetText(L["Current value"])
		_G[name.."SubNewHeader"]:SetText(L["Create new collection"])
		_G[name.."SubNewAdd"]:SetText(GLDG_TXT.add)
		_G[name.."SubNewCancel"]:SetText(GLDG_TXT.cancel)
		_G[name.."SubChangeSelection"]:SetText(L["Selected collection"])
		_G[name.."SubChangeGlobal"]:SetText(L["Global defaults"])
		_G[name.."SubChangeClear"]:SetText(L["not defined"])
		_G[name.."SubChangeCancel"]:SetText(GLDG_TXT.cancel)
		_G[name.."SelDefault"]:SetText(L["coming online"])
		_G[name.."SelRelog"]:SetText(L["relogging"])
		_G[name.."SelJoin"]:SetText(L["joining guild"])
		_G[name.."SelRank"]:SetText(L["promotion"])
		_G[name.."SelLevel"]:SetText(L["leveling"])
		_G[name.."SelBye"]:SetText(L["bye char"])
		_G[name.."SelNight"]:SetText(L["night char"])
		_G[name.."SelGuild"]:SetText(L["greet guild"])
		_G[name.."SelChannel"]:SetText(L["greet channel"])
		_G[name.."SelByeGuild"]:SetText(L["bye guild"])
		_G[name.."SelNightGuild"]:SetText(L["night guild"])
		_G[name.."SelByeChannel"]:SetText(L["bye channel"])
		_G[name.."SelNightChannel"]:SetText(L["night channel"])
		_G[name.."SelLaterGuild"]:SetText(L["later guildl"])
		_G[name.."SelLaterChannel"]:SetText(L["later channel"])
		_G[name.."SelAchievment"]:SetText(L["achievment"])
	elseif (frameName == "Players") then
		-- Header and option texts
		_G[name.."Header"]:SetText(GLDG_TXT.playersheader)
		_G[name.."IgnoreText"]:SetText(GLDG_TXT.ignores)
		_G[name.."AltText"]:SetText(GLDG_TXT.showalt)
		_G[name.."Alt2Text"]:SetText(GLDG_TXT.groupalt)
		_G[name.."UnassignedText"]:SetText(GLDG_TXT.filterUnassigned)
		--_G[name.."GuildText"]:SetText(GLDG_TXT.filterGuild)
		_G[name.."OnlineText"]:SetText(GLDG_TXT.filterOnline)
		_G[name.."MyFriendsText"]:SetText(GLDG_TXT.filterMyFriends)
		_G[name.."WithFriendsText"]:SetText(GLDG_TXT.filterWithFriends)
		_G[name.."CurrentChannelText"]:SetText(GLDG_TXT.filterCurrentChannel)
		_G[name.."WithChannelText"]:SetText(GLDG_TXT.filterWithChannel)
		_G[name.."WARRIORFilterText"]:SetText(LOCALIZED_CLASS_NAMES_MALE["WARRIOR"])
		_G[name.."DEATHKNIGHTFilterText"]:SetText(LOCALIZED_CLASS_NAMES_MALE["DEATHKNIGHT"])
		_G[name.."DRUIDFilterText"]:SetText(LOCALIZED_CLASS_NAMES_MALE["DRUID"])
		_G[name.."HUNTERFilterText"]:SetText(LOCALIZED_CLASS_NAMES_MALE["HUNTER"])
		_G[name.."MAGEFilterText"]:SetText(LOCALIZED_CLASS_NAMES_MALE["MAGE"])
		_G[name.."PALADINFilterText"]:SetText(LOCALIZED_CLASS_NAMES_MALE["PALADIN"])
		_G[name.."PRIESTFilterText"]:SetText(LOCALIZED_CLASS_NAMES_MALE["PRIEST"])
		_G[name.."ROGUEFilterText"]:SetText(LOCALIZED_CLASS_NAMES_MALE["ROGUE"])
		_G[name.."SHAMANFilterText"]:SetText(LOCALIZED_CLASS_NAMES_MALE["SHAMAN"])
		_G[name.."DEMONHUNTERFilterText"]:SetText(LOCALIZED_CLASS_NAMES_MALE["DEMONHUNTER"])
		_G[name.."WARLOCKFilterText"]:SetText(LOCALIZED_CLASS_NAMES_MALE["WARLOCK"])
		_G[name.."MONKFilterText"]:SetText(LOCALIZED_CLASS_NAMES_MALE["MONK"])
		--_G[name.."GuildSortText"]:SetText(GLDG_TXT.guildSort)
		-- list header
		_G[name.."HeaderLineName"]:SetText(GLDG_TXT.headerName)
		_G[name.."HeaderLineType"]:SetText(GLDG_TXT.headerType)
		_G[name.."HeaderLineAlias"]:SetText(GLDG_TXT.headerAlias)
		_G[name.."HeaderLineGuild"]:SetText(GLDG_TXT.headerGuild)
		_G[name.."HeaderLineRankname"]:SetText(GLDG_TXT.headerRankname)
		_G[name.."HeaderLinePnote"]:SetText(GLDG_TXT.headerPnote)
		_G[name.."HeaderLineOnote"]:SetText(GLDG_TXT.headerOnote)
		_G[name.."HeaderLineChannel"]:SetText(GLDG_TXT.headerChannel)
		_G[name.."HeaderLineFriend"]:SetText(GLDG_TXT.headerFriend)
		_G[name.."HeaderLineNumFriends"]:SetText(GLDG_TXT.headerNumFriends)
		-- Button text
		_G[name.."ActionButtonsCheck"]:SetText(GLDG_TXT.pbcheck)
		_G[name.."ActionButtonsAlias"]:SetText(GLDG_TXT.pbalias)
		_G[name.."ActionButtonsGuild"]:SetText(GLDG_TXT.pbguild)
		_G[name.."ActionButtonsWho"]:SetText(GLDG_TXT.pbwho)
		_G[name.."ActionButtonsRemove"]:SetText(GLDG_TXT.pbremove)
		_G[name.."ActionButtonsNote"]:SetText(GLDG_TXT.pbnote)
		_G[name.."ActionButtonsPublicNote"]:SetText(GLDG_TXT.pbpublicnote)
		_G[name.."ActionButtonsOfficerNote"]:SetText(GLDG_TXT.pbofficernote)
		
		-- Set value for option checkboxes
		GLDG_UpdatePlayerCheckboxes()
	elseif (frameName == "Cleanup") then
		-- Header and option texts
		_G[name.."Header"]:SetText(GLDG_TXT.cleanupHeader)
		_G[name.."Info"]:SetText(GLDG_TXT.cleanupInfo)
		_G[name.."GuildHeader"]:SetText(GLDG_TXT.cleanupGuildHeader)
		_G[name.."GuildInfo"]:SetText(GLDG_TXT.cleanupGuildInfo)
		_G[name.."FriendsHeader"]:SetText(GLDG_TXT.cleanupFriendsHeader)
		_G[name.."FriendsInfo"]:SetText(GLDG_TXT.cleanupFriendsInfo)
		_G[name.."ChannelHeader"]:SetText(GLDG_TXT.cleanupChannelHeader)
		_G[name.."ChannelInfo"]:SetText(GLDG_TXT.cleanupChannelInfo)
		_G[name.."OrphanHeader"]:SetText(GLDG_TXT.cleanupOrphanHeader)
		_G[name.."OrphanInfo"]:SetText(GLDG_TXT.cleanupOrphanInfo)
--~~~ MSN1: Added assigning of program variables for 2 new buttons' text (for deleting and displaying guildless characters)
		_G[name.."GuildlessHeader"]:SetText(GLDG_TXT.cleanupGuildlessHeader)
		_G[name.."GuildlessInfo"]:SetText(GLDG_TXT.cleanupGuildlessInfo)
		_G[name.."DisplayGuildlessHeader"]:SetText(GLDG_TXT.displayGuildlessHeader)
		_G[name.."DisplayGuildlessInfo"]:SetText(GLDG_TXT.displayGuildlessInfo)		
--~~~~
		
		_G[name.."Guild"]:SetText(GLDG_TXT.cleanupGuild)
		_G[name.."Friends"]:SetText(GLDG_TXT.cleanupFriends)
		_G[name.."Channel"]:SetText(GLDG_TXT.cleanupChannel)
		_G[name.."Orphan"]:SetText(GLDG_TXT.cleanupOrphan)
--~~~ MSN1: Added assigning of program variables for 2 new buttons' mouseover popup window info (for deleting and displaying guildless characters)
		_G[name.."Guildless"]:SetText(GLDG_TXT.cleanupGuildless)
		_G[name.."DisplayGuildless"]:SetText(GLDG_TXT.displayGuildless)
--~~~~

	elseif (frameName == "Colour") then
		-- Column header
		_G[name.."ColHeaderGuild"]:SetText(GLDG_TXT.colGuild)
		_G[name.."ColHeaderFriends"]:SetText(GLDG_TXT.colFriends)
		_G[name.."ColHeaderChannel"]:SetText(GLDG_TXT.colChannel)
		-- Chat header and options
		_G[name.."HeaderChat"]:SetText(GLDG_TXT.colChatHeader)
		_G[name.."ComingOnline"]:SetText(GLDG_TXT.colOn)
		_G[name.."GoingOffline"]:SetText(GLDG_TXT.colGoOff)
		_G[name.."IsOffline"]:SetText(GLDG_TXT.colIsOff)
		_G[name.."Alias"]:SetText(GLDG_TXT.colAlias)
		-- List header and options
		_G[name.."HeaderList"]:SetText(GLDG_TXT.colListHeader)
		_G[name.."List"]:SetText(GLDG_TXT.colList)
		_G[name.."Relog"]:SetText(GLDG_TXT.colRelog)
		_G[name.."New"]:SetText(GLDG_TXT.colNew)
		_G[name.."Level"]:SetText(GLDG_TXT.colLevel)
		_G[name.."Rank"]:SetText(GLDG_TXT.colRank)
		_G[name.."Achievment"]:SetText(GLDG_TXT.colAchievment)
		-- Common header and options
		_G[name.."HeaderCommon"]:SetText(GLDG_TXT.colCommonHeader)
		_G[name.."Help"]:SetText(GLDG_TXT.colHelp)
		_G[name.."Header"]:SetText(GLDG_TXT.colHeader)
		-- Default button
		_G[name.."DefaultButton"]:SetText(GLDG_TXT.colDefault)
		-- Hide unused colours
		_G[name.."FriendsNewButton"]:Hide()
		_G[name.."FriendsNewColour"]:Hide()
		_G[name.."FriendsRankButton"]:Hide()
		_G[name.."FriendsRankColour"]:Hide()
		_G[name.."FriendsLevelButton"]:Hide()
		_G[name.."FriendsLevelColour"]:Hide()
		_G[name.."FriendsAchievmentButton"]:Hide()
		_G[name.."FriendsAchievmentColour"]:Hide()
		_G[name.."ChannelNewButton"]:Hide()
		_G[name.."ChannelNewColour"]:Hide()
		_G[name.."ChannelRankButton"]:Hide()
		_G[name.."ChannelRankColour"]:Hide()
		_G[name.."ChannelLevelButton"]:Hide()
		_G[name.."ChannelLevelColour"]:Hide()
		_G[name.."ChannelAchievmentButton"]:Hide()
		_G[name.."ChannelAchievmentColour"]:Hide()
	elseif (frameName == "SettingsGeneral") then
		-- Greeting options texts
		_G[name.."Header"]:SetText(L["Configuration options to determine who, when and how to greet"])
		_G[name.."UseGuildDefaultText"]:SetText(L["Read the guildsettings from the guild info |cFFFF0000You must reload your interface after change this manually!"])
		_G[name.."WriteGuildStringText"]:SetText(L["Write the config string"])
		_G[name.."WriteGuildString"]:Disable()
		_G[name.."GreetAsMainText"]:SetText(L["Greet alts with the same name as main by default"].."*")
		_G[name.."RandomizeText"]:SetText(L["Randomly use alias and or main and alt names"].."*")
		_G[name.."WhisperText"]:SetText(L["Whisper greetings and grats to players"].."*")
		_G[name.."WhisperLevelupText"]:SetText(L["Whisper level up messages"].."*")
		_G[name.."IncludeOwnText"]:SetText(L["Display your own characters"].."*")
		_G[name.."AutoAssignText"]:SetText(L["Automatically assign main/alt based on guild note"].."*")
		_G[name.."AutoAssignEgpText"]:SetText(L["(include EGP officer notes)"].."*")
		_G[name.."AutoAssignAliasText"]:SetText(L["(Automatically assign Alias)"].."*")
		_G[name.."UseFriendsText"]:SetText(L["Manage friend's list"])
		_G[name.."ChannelNameText"]:SetText(L["Channel name to monitor"])
		-- Queued greetings list texts
		_G[name.."ListHeader"]:SetText(L["Configuration options for displaying the players waiting for a greeting"])
		_G[name.."ListdirectText"]:SetText(L["List grows upwards instead of downwards"])
		_G[name.."ListheaderText"]:SetText(L["List header is always visible"])
		-- Set value for checkboxes
		_G[name.."UseGuildDefaultBox"]:SetChecked(GLDG_Data.GuildSettings.UseGuildDefault)
		_G[name.."GreetAsMainBox"]:SetChecked(GLDG_Data.GuildSettings.GreetAsMain)
		_G[name.."RandomizeBox"]:SetChecked(GLDG_Data.GuildSettings.Randomize)
		_G[name.."WhisperBox"]:SetChecked(GLDG_Data.GuildSettings.Whisper)
		_G[name.."WhisperLevelupBox"]:SetChecked(GLDG_Data.GuildSettings.WhisperLevelup)
		_G[name.."IncludeOwnBox"]:SetChecked(GLDG_Data.GuildSettings.IncludeOwn)
		_G[name.."AutoAssignBox"]:SetChecked(GLDG_Data.GuildSettings.AutoAssign)
		_G[name.."AutoAssignEgpBox"]:SetChecked(GLDG_Data.GuildSettings.AutoAssignEgp)
		_G[name.."AutoAssignAliasBox"]:SetChecked(GLDG_Data.GuildSettings.AutoAssignAlias)
		_G[name.."UseFriendsBox"]:SetChecked(GLDG_Data.UseFriends)
		_G[name.."ListdirectBox"]:SetChecked(GLDG_Data.ListUp)
		_G[name.."ListheaderBox"]:SetChecked(GLDG_Data.ListVisible)
		-- Set values for Relog and Listsize sliders
		_G[name.."RelogSlider"]:SetValue(GLDG_Data.GuildSettings.RelogTime)
		_G[name.."MinLevelUpSlider"]:SetValue(GLDG_Data.GuildSettings.MinLevelUp)
--		_G[name.."UpdateTimeSlider"]:SetValue(GLDG_Data.UpdateTime/10)
		_G[name.."ListsizeSlider"]:SetValue(GLDG_Data.ListSize)
	elseif (frameName == "SettingsChat") then
		-- List settings
		_G[name.."Header"]:SetText(L["Printing information to chat"])
		_G[name.."ChatFrameSlider"]:SetValue(GLDG_Data.PlayerChatFrame[GLDG_Player.."-"..GLDG_Realm])
		_G[name.."ListNamesBox"]:SetChecked(GLDG_Data.GuildSettings.ListNames)
		_G[name.."ListNamesOffBox"]:SetChecked(GLDG_Data.GuildSettings.ListNamesOff)
		_G[name.."ListLevelUpBox"]:SetChecked(GLDG_Data.GuildSettings.ListLevelUp)
		_G[name.."ListLevelUpOffBox"]:SetChecked(GLDG_Data.GuildSettings.ListLevelUpOff)
		_G[name.."ListQuitBox"]:SetChecked(GLDG_Data.GuildSettings.ListQuit)
		_G[name.."ExtendChatBox"]:SetChecked(GLDG_Data.GuildSettings.ExtendChat)
		_G[name.."ExtendIgnoredBox"]:SetChecked(GLDG_Data.GuildSettings.ExtendIgnored)
		_G[name.."ExtendAliasBox"]:SetChecked(GLDG_Data.GuildSettings.ExtendAlias)
		_G[name.."ExtendMainBox"]:SetChecked(GLDG_Data.GuildSettings.ExtendMain)
		_G[name.."ListNamesText"]:SetText(L["List alt and main names when player logs in"].."*")
		_G[name.."ListNamesOffText"]:SetText(L["List alt and main names when player logs off"].."*")
		_G[name.."ListLevelUpText"]:SetText(L["List to chat when a player levels up (online only)"].."*")
		_G[name.."ListLevelUpOffText"]:SetText(L["List to chat when a player levels up (offline players, printed when you log in)"].."*")
		_G[name.."ListQuitText"]:SetText(L["List to chat when a player leaves the guild"].."*")
		_G[name.."ExtendChatText"]:SetText(L["Add main name to chat when an alt sends a message"].."*")
		_G[name.."ExtendIgnoredText"]:SetText(L["Add main name to chat when an alt sends a message, even if alt is ignored"].."*")
		_G[name.."ExtendAliasText"]:SetText(L["Add main's alias to chat (if it exists and the above option is enabled)"].."*")
		_G[name.."ExtendMainText"]:SetText(L["Even re-add main name for main char (if the above option is enabled)"].."*")
		_G[name.."AddPostfixText"]:SetText(L["Show source of character info in curly braces when printing names to chat"].."*")
		_G[name.."AddPostfixBox"]:SetChecked(GLDG_Data.GuildSettings.AddPostfix)
		_G[name.."ShowWhoSpamText"]:SetText(L["Show /who request and response text in chat"].."*")
		_G[name.."ShowWhoSpamBox"]:SetChecked(GLDG_Data.GuildSettings.ShowWhoSpam)
		_G[name.."ListAchievmentsText"]:SetText(L["Show achievments of guild members with main/alt in chat"].."*")
		_G[name.."ListAchievmentsBox"]:SetChecked(GLDG_Data.GuildSettings.ListAchievments)
	elseif (frameName == "SettingsGreeting") then
		-- header
		_G[name.."Header"]:SetText(L["Greeting the guild and channel (per character setting)"])
		_G[name.."SubHeader"]:SetText(L["Temporarily suppress greeting players"])
		-- greet options
		_G[name.."GreetGuildBox"]:SetChecked(GLDG_Data.GreetGuild[GLDG_Realm.." - "..GLDG_Player])
		_G[name.."GreetChannelBox"]:SetChecked(GLDG_Data.GreetChannel[GLDG_Realm.." - "..GLDG_Player])
		_G[name.."AutoGreetBox"]:SetChecked(GLDG_Data.AutoGreet[GLDG_Realm.." - "..GLDG_Player])
		_G[name.."GreetGuildText"]:SetText(L["Greet guild when 'Greet Key' is pressed (also applies to saying bye)"])
		_G[name.."GreetChannelText"]:SetText(L["Greet channel when 'Greet Key' is pressed (also applies to saying bye)"])
		_G[name.."AutoGreetText"]:SetText(L["Automatically greet guild and/or channel when logging in (depends on settings above). |cFFFF0000Use carefully (see tooltip)."])
		-- suppress options
		GLDG_UpdateSupressed()
		_G[name.."SupressAll"]:SetText(L["Supress all"])
		_G[name.."SupressNone"]:SetText(L["Supress none"])

		_G[name.."SupressGreetText"]:SetText(L["Don't put players coming online on the greet list"].."*")
		_G[name.."SupressJoinText"]:SetText(L["Don't put players joining the guild on the greet list"].."*")
		_G[name.."SupressLevelText"]:SetText(L["Don't put players that level up on the greet list"].."*")
		_G[name.."SupressRankText"]:SetText(L["Don't put players that get promoted on the greet list"].."*")
		_G[name.."SupressAchievmentText"]:SetText(L["Don't put players that get achievments on the greet list"].."*")

		_G[name.."NoGratsOnLoginBox"]:SetChecked(GLDG_Data.GuildSettings.NoGratsOnLogin)
		_G[name.."NoGratsOnLoginText"]:SetText(L["Don't congratulate players that just logged in"].."*")
		-- guild alias
		_G[name.."GuildAliasSet"]:SetText(GLDG_TXT.set)
		_G[name.."GuildAliasClear"]:SetText(GLDG_TXT.clear)
	elseif (frameName == "SettingsOther") then
		_G[name.."Header"]:SetText(L["Various settings"])
		_G[name.."UseLocalTimeBox"]:SetChecked(GLDG_Data.UseLocalTime)
		_G[name.."UseLocalTimeText"]:SetText(L["Use local time instead of server time"])
		_G[name.."ShowNewerVersionsBox"]:SetChecked(GLDG_Data.ShowNewerVersions)
		_G[name.."ShowNewerVersionsText"]:SetText(L["Show if newer versions of addons are available"])
		_G[name.."AutoWhoText"]:SetText(L["Automatically start /who request when channel member with lacking info logs on"])
		_G[name.."AutoWhoBox"]:SetChecked(GLDG_Data.AutoWho)
		_G[name.."DeltaPopupText"]:SetText(L["Show popup box summarising offline changes at login"].."*")
		_G[name.."DeltaPopupBox"]:SetChecked(GLDG_Data.GuildSettings.DeltaPopup)
		_G[name.."ExtendPlayerMenuText"]:SetText(L["Enable player context menu (may cause taint issues in raid frame, see tooltip)"])
		_G[name.."ExtendPlayerMenuBox"]:SetChecked(GLDG_Data.ExtendPlayerMenu)
	end
	GLDG_SetCheckboxes()
end

------------------------------------------------------------
function GLDG_UpdatePlayerCheckboxes()
	local name = GLDG_GUI.."Players"
	_G[name.."IgnoreBox"]:SetChecked(GLDG_Data.ShowIgnore)
	_G[name.."AltBox"]:SetChecked(GLDG_Data.ShowAlt)
	_G[name.."Alt2Box"]:SetChecked(GLDG_Data.GroupAlt)
	_G[name.."UnassignedBox"]:SetChecked(GLDG_Data.FilterUnassigned)
--	_G[name.."GuildBox"]:SetChecked(GLDG_Data.FilterGuild)
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
	--_G[name.."GuildSortBox"]:SetChecked(GLDG_Data.GuildSort)
	
	if (GLDG_Data.FilterOnline==true or GLDG_Data.GuildSort==true) then
		_G[name.."Alt2Box"]:Disable()
	else
		_G[name.."Alt2Box"]:Enable()
	end
end

------------------------------------------------------------
function GLDG_InitGreet(section)
	-- Set greetings section pointer if section exists
	local t = GLDG_Data.Custom
	if not t[section] then return true
	elseif (t[section] == "") then GLDG_DataGreet = GLDG_Data
	else	GLDG_SelColName = t[section]
		GLDG_DataGreet = GLDG_Data.Collections[t[section]] end
end

------------------------------------------------------------
function GLDG_InitRoster()
	-- convert GLDG_Data from old format
	GLDG_Convert()

	-- Retreive realm, player and guild name if needed
	if not GLDG_Realm then GLDG_Realm = GetRealmName() end
	if not GLDG_Player then GLDG_Player = UnitName("player") end
	if not GLDG_GuildName or GLDG_GuildName == "" then GLDG_GuildName = GetGuildInfo("player") end
	if not GLDG_GuildName then GLDG_GuildName = "" end
	if not GLDG_unique_GuildName or GLDG_unique_GuildName == "" then
		local maxMembers = GetNumGuildMembers()
		if maxMembers == nil then maxMembers = nil end
		for i = 1, maxMembers do
			local pl, rn, ri, lv, cl, zn, pn, on, ol, st, enClass, ap, ar, isMobile = GetGuildRosterInfo(i)
			if ri == 0 then GLDG_GuildLeader = pl end
		end
		if GLDG_GuildLeader then
			GLDG_unique_GuildName = (GLDG_GuildName.."@"..GLDG_GuildLeader)
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

	if not (GLDG_Realm and GLDG_Player) then return end

	
	-- create character store
--	if (GLDG_Realm) then
--		if (not GLDG_Data["Realm: "..GLDG_Realm]) then
--			GLDG_Data["Realm: "..GLDG_Realm] = {}
--		end
--		-- set character section pointer
--		GLDG_DataChar = GLDG_Data["Realm: "..GLDG_Realm]
--	else
--		GLDG_DataChar = {}
--	end
	if not GLDG_Data["DataChar"] then GLDG_Data["DataChar"] = {} end
	GLDG_DataChar = GLDG_Data["DataChar"]

	if (GLDG_Realm and GLDG_Player) then
		-- create channel name store if needed
		if not GLDG_Data.ChannelNames then
			GLDG_Data.ChannelNames = {}
		end
		if not GLDG_Data.ChannelNames[GLDG_Realm.." - "..GLDG_Player] then
			GLDG_Data.ChannelNames[GLDG_Realm.." - "..GLDG_Player] = ""
		end
		-- set channel name pointer
		GLDG_ChannelName = GLDG_Data.ChannelNames[GLDG_Realm.." - "..GLDG_Player]
		if not GLDG_Data.Frameopts[GLDG_Realm.." - "..GLDG_Player] then
			GLDG_Data.Frameopts[GLDG_Realm.." - "..GLDG_Player] = {}
			GLDG_Data.Frameopts[GLDG_Realm.." - "..GLDG_Player].anchorFrom = "CENTER"
			GLDG_Data.Frameopts[GLDG_Realm.." - "..GLDG_Player].anchorTo = "CENTER"
			GLDG_Data.Frameopts[GLDG_Realm.." - "..GLDG_Player].offsetx = 0
			GLDG_Data.Frameopts[GLDG_Realm.." - "..GLDG_Player].offsety = 0
			GLDG_Data.Frameopts[GLDG_Realm.." - "..GLDG_Player].Width = 500
			GLDG_Data.Frameopts[GLDG_Realm.." - "..GLDG_Player].Height = 560
		end
	else
		GLDG_ChannelName = ""
	end
	--_G[GLDG_GUI.."Settings".."ChannelNameEditbox"]:SetText(GLDG_ChannelName)

	if (GLDG_Realm and GLDG_unique_GuildName and GLDG_unique_GuildName~="" and GLDG_Player) then
		-- Set greetings section pointer
		if GLDG_InitGreet(GLDG_Realm.."-"..GLDG_Player) and
		   GLDG_InitGreet(GLDG_unique_GuildName) and
		   GLDG_InitGreet(GLDG_Realm) then
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
		GuildRoster()  -- ?
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
	ShowFriends()
	if not GLDG_InitialFriendsUpdate then
		if GLDG_Data.UseFriends==true and (GetNumFriends() > 0) and bit.band(GLDG_InitCheck, 2)~=2 then
			GLDG_InitCheck = bit.bor(GLDG_InitCheck, 2)	-- friends started
			--GLDG_Print("InitCheck is ["..tostring(GLDG_InitCheck).."] - friends started")
		end
	end

	-- check if there are inconsistencies
	if GLDG_autoConsistencyCheckReady then
		if not GLDG_autoConsistencyChecked then
			GLDG_autoConsistencyChecked = true
			if GLDG_Convert_Plausibility_Check(true) then
				GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.shouldFix)
			end
		end
	end
end

------------------------------------------------------------
function GLDG_ClickGuildAliasSet()
	local name = GLDG_GUI.."SettingsGreeting"
	GLDG_GuildAlias = _G[name.."GuildAliasEditbox"]:GetText()
	GLDG_Data.GuildAlias[GLDG_unique_GuildName] = GLDG_GuildAlias

	_G[name.."GuildAliasEditbox"]:ClearFocus()
end

------------------------------------------------------------
function GLDG_ClickGuildAliasClear()
	GLDG_GuildAlias = GLDG_unique_GuildName
	GLDG_Data.GuildAlias[GLDG_unique_GuildName] = GLDG_GuildAlias

	local name = GLDG_GUI.."SettingsGreeting"
	_G[name.."GuildAliasEditbox"]:SetText("")
	_G[name.."GuildAliasEditbox"]:ClearFocus()
end

------------------------------------------------------------
function GLDG_OnUpdate(self, elapsed)
	-- if we're not interested in updates, return
	if ((not GLDG_UpdateRequest) and (not GLDG_UpdateRequestFriends)) then return end	
	-- are we interested in guild updates?
	if (GLDG_UpdateRequest) then
		-- is it time, yet?
		if (GetTime() >= GLDG_UpdateRequest) then

			-- yes: treat guild information
			if not (GLDG_Realm and GLDG_unique_GuildName and GLDG_unique_GuildName~="") then
				-- some information is still missing - try to get it
				GLDG_InitRoster()

				-- trigger next update
				if not GLDG_updateCount then GLDG_updateCount = 0 end
				GLDG_updateCount = GLDG_updateCount + 1
				if (GLDG_updateCount < 10) then
					-- first 10 updates in quick succession (no matter if we're in a guild or not)
					GLDG_UpdateRequest = GetTime() + 1
				elseif (IsInGuild()) then
					-- we're in a guild and the information is still missing, keep polling
					GLDG_UpdateRequest = GetTime() + GLDG_UPDATE_TIME
				else
					-- we're not in a guild, stop polling
					GLDG_UpdateRequest = nil
				end
			else
				-- we've got all the base information -> renew full roster
				local setting = GetGuildRosterShowOffline()
				SetGuildRosterShowOffline(true)
				GuildRoster()
				if not setting then SetGuildRosterShowOffline(false) end

				-- trigger next update
				if (GLDG_Data.UpdateTime > 0) then
					GLDG_UpdateRequest = GetTime() + GLDG_Data.UpdateTime
				else
					GLDG_UpdateRequest = nil
				end
			end
		end
	end

	-- are we interested in friend updates (i.e. are we in phase 1)?
	if (GLDG_UpdateRequestFriends) then
		if (GLDG_Data.UseFriends==true) then
			-- is it time, yet?
			if (GetTime() >= GLDG_UpdateRequestFriends) then

				-- yes: treat friend information
				if not GLDG_Realm then
					-- some information is still missing - try to get it
					--GLDG_Print("--- OnUpdate: friends update -> reinit roster ---")
					GLDG_InitRoster()

					-- trigger next update
					GLDG_UpdateRequestFriends = GetTime() + 1
				else
					-- we've got all the base information -> check friends
					ShowFriends()

					-- this will cause GLDG_FriendsUpdate() to be called
					-- which will retrigger the update or not depending on
					-- the configuration, until then, turn it off
					GLDG_UpdateRequestFriends = nil
				end
			end
		else
			GLDG_UpdateRequestFriends = nil
		end
	end	
end


------------------------------
-- _05_ Guild Roster Import --
------------------------------

function GLDG_RosterImport()
	GLDG_RosterImportRunning=1
	if (not GLDG_unique_GuildName or GLDG_unique_GuildName == "") then
		return
	end
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
					if GLDG_Data[i][oName].promoter then
						local promoName, promoRealm = string.split("-", GLDG_Data[i][oName].promoter)
						if not promoRealm then
							GLDG_Data[i][oName].promoter = promoName.."-"..string.gsub(oldrealm, " ", "")							
						else
							GLDG_Data[i][oName].promoter = string.gsub(GLDG_Data[i][oName].promoter, " ", "")						
						end
					end						
					GLDG_DataChar[newname] = GLDG_Data[i][oName]
				end
				GLDG_Data[i] = nil
			end
		end
	end
	GLDG_Data.Version = GDLG_VNMBR
	GLDG_SetActiveColourSet("guild")

	-- Update guildrank names
	GLDG_Data.Ranks[GLDG_unique_GuildName] = {}
	for i = 1, GuildControlGetNumRanks() do GLDG_Data.Ranks[GLDG_unique_GuildName][GuildControlGetRankName(i)] = i end
	
	-- Add info about all players of your guild
	local mains = {}
	local alts = {}
	local cnt = 0
	local update = false
	local complete = false
	local maxMembers = GetNumGuildMembers()
	if maxMembers == nil then maxMembers = nil end
	for i = 1, maxMembers do
		local pl, rn, ri, lv, cl, zn, pn, on, ol, st, enClass = GetGuildRosterInfo(i)
		local GLDG_shortName, realm = string.split("-", pl)
		if not realm then pl = GLDG_shortName.."-"..string.gsub(GLDG_Realm, " ", "") end
		if pl then
			cnt = cnt +1
			if not GLDG_DataChar[pl] then
				-- New player
				GLDG_DataChar[pl] = {}
				if (not GLDG_NewGuild) and (GLDG_Data.GuildSettings.SupressJoin==false) and (GLDG_TableSize(GLDG_DataGreet.Welcome) > 0) then
					GLDG_DataChar[pl].new = true
				end
				GLDG_AddToStartupList(GLDG_TXT.deltaGuild..": "..GLDG_TXT.deltaNewMember.." ["..Ambiguate(pl, "guild").."]")
			end
			if (pl == UnitName("player").."-"..string.gsub(GLDG_Realm, " ", "")) then
				-- This player is our own: ignore completely
				GLDG_DataChar[pl].own = true
				--GLDG_DataChar[pl].ignore = true
			end
			if (GLDG_Data.GuildSettings.AutoAssign==true) and (GLDG_ReadNotes == 1) then
				-- detect if note contains "Main[ <discardable text>]"
				if (pn == "Main" or string.sub(pn, 1, 5)=="Main ") then
					mains[pl] = "true"
				elseif (on and (on == "Main" or string.sub(on, 1, 5)=="Main ")) then
					mains[pl] = "true"
				-- detect if note contains EGP style information
				elseif (GLDG_Data.GuildSettings.AutoAssignEgp==true and (on and tonumber(string.sub(on,1,1)))) then
					mains[pl] = "true"
				end
--				------------- Alias-Zuordnung anfang--------------------------
				if (GLDG_Data.GuildSettings.AutoAssignAlias == true) then
					local aliasmatch = nil
					local aliasmatch = string.find(pn, "@",1)
					if (aliasmatch ~= nil) then
						local a,b,c = strfind(pn, "(%S+)", aliasmatch+1)
						if a then
							GLDG_DataChar[pl].alias = c
						end
					end
				end
				if (GLDG_Data.GuildSettings.AutoAssignAlias == true) then
					local aliasmatch = nil
					local aliasmatch = string.find(on, "@",1)
					if (aliasmatch ~= nil) then
						local a,b,c = strfind(on, "(%S+)", aliasmatch+1)
						if a then
							GLDG_DataChar[pl].alias = c
						end
					end
				end
				------------- Alias-Zuordnung ende--------------------------
				-- detect if note contains "alt-<main name>[ <discardable text]"
				if (string.sub(pn, 1, 4)=="alt-") then
					local main = string.sub(pn, 5)
					local a,b,c=strfind(main, "(%S+)"); --contiguous string of non-space characters
					if a then
						main = GLDG_findMainname(c, pl)
					end
					alts[pl] = main
				elseif (on and string.sub(on, 1, 4)=="alt-") then
					local main = string.sub(on, 5)
					local a,b,c=strfind(main, "(%S+)"); --contiguous string of non-space characters
					if a then
						main = GLDG_findMainname(c, pl)
					end
					alts[pl] = main
				-- detect if note contains "alt - <main name>[ <discardable text]"
				elseif (string.sub(pn, 1, 6)=="alt - ") then
					local main = string.sub(pn, 7)
					local a,b,c=strfind(main, "(%S+)"); --contiguous string of non-space characters
					if a then
						main = GLDG_findMainname(c, pl)
					end
					alts[pl] = main
				elseif (on and string.sub(on, 1, 6)=="alt - ") then
					local main = string.sub(on, 7)
					local a,b,c=strfind(main, "(%S+)"); --contiguous string of non-space characters
					if a then
						main = GLDG_findMainname(c, pl)
					end
					alts[pl] = main
				-- detect if note contains "alt <main name>[ <discardable text]"
				elseif (string.sub(pn, 1, 4)=="alt ") then
					local main = string.sub(pn, 5)
					local a,b,c=strfind(main, "(%S+)"); --contiguous string of non-space characters
					if a then
						main = GLDG_findMainname(c, pl)
					end
					alts[pl] = main
				elseif (on and string.sub(on, 1, 4)=="alt ") then
					local main = string.sub(on, 5)
					local a,b,c=strfind(main, "(%S+)"); --contiguous string of non-space characters
					if a then
						main = GLDG_findMainname(c, pl)
					end
					alts[pl] = main
				-- detect if note contains EGP style information
				elseif (GLDG_Data.GuildSettings.AutoAssignEgp==true and (on and tonumber(string.sub(on, 1, 1))==nil)) then
					local main = on
					local a,b,c=strfind(main, "(%S+)"); --contiguous string of non-space characters
					if a then
						main = GLDG_findMainname(c, pl)
					end
					alts[pl] = main
				end
			end
			if cl then
				GLDG_DataChar[pl].class = cl
			end

			if pn and pn ~= "" then
				if GLDG_DataChar[pl].pNote then
					if pn ~= GLDG_DataChar[pl].pNote then
						GLDG_AddToStartupList(GLDG_TXT.deltaGuild..": "..GLDG_TXT.deltaPnoteChanged.." ["..Ambiguate(pl, "guild").."] "..GLDG_TXT.deltaFrom.." ["..GLDG_DataChar[pl].pNote.."] "..GLDG_TXT.deltaTo.." ["..pn.."]")
					end
				else
					GLDG_AddToStartupList(GLDG_TXT.deltaGuild..": "..GLDG_TXT.deltaPnoteAdded.." ["..Ambiguate(pl, "guild").."]. "..GLDG_TXT.deltaIs.." ["..pn.."]")
				end
				GLDG_DataChar[pl].pNote = pn				
			else
				if GLDG_DataChar[pl].pNote then
					GLDG_AddToStartupList(GLDG_TXT.deltaGuild..": "..GLDG_TXT.deltaPnoteRemoved.." ["..Ambiguate(pl, "guild").."]. ("..GLDG_TXT.deltaWas.." ["..GLDG_DataChar[pl].pNote.."])")
				end
				GLDG_DataChar[pl].pNote = nil
			end

			if CanViewOfficerNote() then
				if on and on ~= "" then
					if GLDG_DataChar[pl].oNote then
						if on ~= GLDG_DataChar[pl].oNote then
							GLDG_AddToStartupList(GLDG_TXT.deltaGuild..": "..GLDG_TXT.deltaOnoteChanged.." ["..Ambiguate(pl, "guild").."] "..GLDG_TXT.deltaFrom.." ["..GLDG_DataChar[pl].oNote.."] "..GLDG_TXT.deltaTo.." ["..on.."]")
						end
					else
						GLDG_AddToStartupList(GLDG_TXT.deltaGuild..": "..GLDG_TXT.deltaOnoteAdded.." ["..Ambiguate(pl, "guild").."]. "..GLDG_TXT.deltaIs.." ["..on.."]")
					end
					GLDG_DataChar[pl].oNote = on				
				else
					if GLDG_DataChar[pl].oNote then
						GLDG_AddToStartupList(GLDG_TXT.deltaGuild..": "..GLDG_TXT.deltaOnoteRemoved.." ["..Ambiguate(pl, "guild").."]. ("..GLDG_TXT.deltaWas.." ["..GLDG_DataChar[pl].oNote.."])")
					end
					GLDG_DataChar[pl].oNote = nil
				end
			end

			if enClass then
				GLDG_DataChar[pl].enClass = enClass
			end

			if not GLDG_DataChar[pl].lvl then
				GLDG_DataChar[pl].lvl = lv
			end

			if (type(GLDG_DataChar[pl].newrank) ~= "number") then
				GLDG_DataChar[pl].newrank = nil
			end
			if not GLDG_RankUpdate[pl] then
				if GLDG_DataChar[pl].newrank and (ri > GLDG_DataChar[pl].newrank) then
					-- Player got demoted again
					if (GLDG_DataChar[pl].rankname) then
						GLDG_AddToStartupList(GLDG_TXT.deltaGuild..": "..GLDG_TXT.deltaRank.." ["..Ambiguate(pl, "guild").."] "..GLDG_TXT.deltaDemoted1.." ["..GLDG_DataChar[pl].rankname.."] "..GLDG_TXT.deltaRankTo.." ["..rn.."] "..GLDG_TXT.deltaDemoted2)
					else
						GLDG_AddToStartupList(GLDG_TXT.deltaGuild..": "..GLDG_TXT.deltaRank.." ["..Ambiguate(pl, "guild").."] "..GLDG_TXT.deltaDemoted1.." ["..GLDG_DataChar[pl].newrank.."] "..GLDG_TXT.deltaRankTo.." ["..rn.."] "..GLDG_TXT.deltaDemoted2)
					end
					GLDG_DataChar[pl].promotor = nil
					GLDG_DataChar[pl].newrank = nil
				elseif GLDG_DataChar[pl].rank and (ri > GLDG_DataChar[pl].rank) then
					-- Player got demoted
					if (GLDG_DataChar[pl].rankname) then
						GLDG_AddToStartupList(GLDG_TXT.deltaGuild..": "..GLDG_TXT.deltaRank.." ["..Ambiguate(pl, "guild").."] "..GLDG_TXT.deltaDemoted1.." ["..GLDG_DataChar[pl].rankname.."] "..GLDG_TXT.deltaRankTo.." ["..rn.."] "..GLDG_TXT.deltaDemoted2)
					else
						GLDG_AddToStartupList(GLDG_TXT.deltaGuild..": "..GLDG_TXT.deltaRank.." ["..Ambiguate(pl, "guild").."] "..GLDG_TXT.deltaDemoted1.." ["..GLDG_DataChar[pl].rank.."] "..GLDG_TXT.deltaRankTo.." ["..rn.."] "..GLDG_TXT.deltaDemoted2)
					end
				elseif GLDG_DataChar[pl].newrank and (ri < GLDG_DataChar[pl].newrank) then
					-- Player got promoted again
					if (GLDG_DataChar[pl].rankname) then
						GLDG_AddToStartupList(GLDG_TXT.deltaGuild..": "..GLDG_TXT.deltaRank.." ["..Ambiguate(pl, "guild").."] "..GLDG_TXT.deltaPromoted1.." ["..GLDG_DataChar[pl].rankname.."] "..GLDG_TXT.deltaRankTo.." ["..rn.."] "..GLDG_TXT.deltaPromoted2)
					else
						GLDG_AddToStartupList(GLDG_TXT.deltaGuild..": "..GLDG_TXT.deltaRank.." ["..Ambiguate(pl, "guild").."] "..GLDG_TXT.deltaPromoted1.." ["..GLDG_DataChar[pl].newrank.."] "..GLDG_TXT.deltaRankTo.." ["..rn.."] "..GLDG_TXT.deltaPromoted2)
					end
					GLDG_DataChar[pl].promotor = nil
					GLDG_DataChar[pl].newrank = ri
				elseif GLDG_DataChar[pl].rank and (ri < GLDG_DataChar[pl].rank) then
					-- Player got promoted
					if (GLDG_DataChar[pl].rankname) then
						GLDG_AddToStartupList(GLDG_TXT.deltaGuild..": "..GLDG_TXT.deltaRank.." ["..Ambiguate(pl, "guild").."] "..GLDG_TXT.deltaPromoted1.." ["..GLDG_DataChar[pl].rankname.."] "..GLDG_TXT.deltaRankTo.." ["..rn.."] "..GLDG_TXT.deltaPromoted2)
					else
						GLDG_AddToStartupList(GLDG_TXT.deltaGuild..": "..GLDG_TXT.deltaRank.." ["..Ambiguate(pl, "guild").."] "..GLDG_TXT.deltaPromoted1.." ["..GLDG_DataChar[pl].rank.."] "..GLDG_TXT.deltaRankTo.." ["..rn.."] "..GLDG_TXT.deltaPromoted2)
					end
					GLDG_DataChar[pl].newrank = ri
				end
				GLDG_DataChar[pl].rank = ri
				GLDG_DataChar[pl].rankname = rn
			end
			-- don't congratulate own chars for new ranks
			if (pl == UnitName("player").."-"..string.gsub(GLDG_Realm, " ", "")) then
				GLDG_DataChar[pl].newrank = nil
			end

			-- if no appropriate messages, don't welcome ;-)
			if (GLDG_DataChar[pl].new and GLDG_TableSize(GLDG_FilterMessages(GLDG_DataChar[pl], GLDG_DataGreet.Welcome)) == 0) then
				GLDG_DataChar[pl].new = nil
			end

			-- find name of main/alias for level up message below
			local mainName = nil
			if (GLDG_DataChar[pl] and not GLDG_DataChar[pl].ignore) then
				if GLDG_DataChar[pl].alt then
					mainName = GLDG_DataChar[pl].alt;
					if GLDG_Data.GuildSettings.ExtendAlias==true then
						if GLDG_DataChar[mainName] and GLDG_DataChar[mainName].alias then
							mainName = GLDG_DataChar[mainName].alias
						end
					end
				elseif GLDG_Data.GuildSettings.ExtendMain==true and GLDG_DataChar[pl].main then
					mainName = name
					if GLDG_Data.GuildSettings.ExtendAlias==true then
						if GLDG_DataChar[mainName] and GLDG_DataChar[mainName].alias then
							mainName = GLDG_DataChar[mainName].alias
						end
					end
				end
			end

			if ol then
				-- Remove rank info if we're not interested in it
				if GLDG_DataChar[pl].newrank and (GLDG_Data.GuildSettings.SupressRank==true or (GLDG_TableSize(GLDG_FilterMessages(GLDG_DataChar[pl], GLDG_DataGreet.NewRank)) == 0) or GLDG_DataChar[pl].ignore) then
					GLDG_DataChar[pl].promotor = nil
					GLDG_DataChar[pl].newrank = nil
				end
				-- Add promoted player to queue if hour is known
				if GLDG_DataChar[pl].newrank and GLDG_RankUpdate[pl] and (not GLDG_Queue[pl]) then
					GLDG_Queue[pl] = GLDG_RankUpdate[Ambiguate(pl, "guild")]
					update = true
				end

				-- Update player level
				GLDG_DataChar[pl].oldlvl = GLDG_DataChar[pl].lvl
				GLDG_DataChar[pl].lvl = lv
				GLDG_DataChar[pl].storedLvl = nil	-- if the char is online, there is no need to store an old level
				if (GLDG_DataChar[pl].lvl > GLDG_DataChar[pl].oldlvl) then
					GLDG_AddToStartupList(GLDG_TXT.deltaGuild..": ["..Ambiguate(pl, "guild").."] "..GLDG_TXT.deltaIncrease1.." "..tostring(GLDG_DataChar[pl].oldlvl).." "..GLDG_TXT.deltaIncrease2.." "..tostring(lv).." "..GLDG_TXT.deltaIncrease3)
					if (not GLDG_DataChar[pl].own) then
						if GLDG_Data.GuildSettings.ListLevelUp==true then
							if (mainName) then
								GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r ["..Ambiguate(pl, "guild")..": "..cl.."] "..GLDG_Data.colours.help.."{"..mainName.."}|r "..string.format(L["has increased his level from %s to %s"],GLDG_DataChar[pl].oldlvl, lv));
							else
								GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r ["..Ambiguate(pl, "guild")..": "..cl.."] "..string.format(L["has increased his level from %s to %s"],GLDG_DataChar[pl].oldlvl, lv));
							end
						end
						if ( (GLDG_TableSize(GLDG_FilterMessages(GLDG_DataChar[pl], GLDG_DataGreet.NewLevel)) > 0) and (GLDG_Data.GuildSettings.SupressLevel==false) and (not GLDG_DataChar[pl].ignore) and (lv > GLDG_Data.GuildSettings.MinLevelUp)) then
							if (GLDG_Online[pl] or GLDG_Data.GuildSettings.NoGratsOnLogin==false) then
								GLDG_DataChar[pl].newlvl = true
							end
						end
					end
				end
				GLDG_DataChar[pl].oldlvl = nil

				-- Update queue with all changes still missing
				if (GLDG_DataChar[pl].new or GLDG_DataChar[pl].newlvl or GLDG_DataChar[pl].newrank) and (not GLDG_Queue[pl]) then
					GLDG_Queue[pl] = "[??:??] "
					update = true;
				end
			else
				-- offline players are only shown if the corresponding option has been set
				-- this is forced for the initial update. if there is a guild roster update
				-- event before this, only the online players may be set
				-- this is the reason for setting complete only if at least one offline player
				-- has been seen
				complete = true
				if (not GLDG_DataChar[pl].own) then
					if (lv > GLDG_DataChar[pl].lvl) then
						if ((GLDG_DataChar[pl].storedLvl == nil) or (lv > GLDG_DataChar[pl].storedLvl)) then
							GLDG_AddToStartupList(GLDG_TXT.deltaGuild..": ["..Ambiguate(pl, "guild").."] "..GLDG_TXT.deltaIncrease1.." "..tostring(GLDG_DataChar[pl].lvl).." "..GLDG_TXT.deltaIncrease2.." "..tostring(lv).." "..GLDG_TXT.deltaIncrease3)
							if GLDG_Data.GuildSettings.ListLevelUpOff==true then
								if (mainName) then
									GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":"..GLDG_GOES_OFFLINE_COLOUR.." ["..Ambiguate(pl, "guild").."] "..GLDG_Data.colours.help.."{"..mainName.."}|r "..string.format(L["has increased his level from %s to %s"],GLDG_DataChar[pl].lvl, lv).." (off)");
								else
									GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":"..GLDG_GOES_OFFLINE_COLOUR.." ["..Ambiguate(pl, "guild").."] "..string.format(L["has increased his level from %s to %s"],GLDG_DataChar[pl].lvl, lv)..L[" (off)"]);
								end
							end

							GLDG_DataChar[pl].storedLvl = lv
						end
					end
				end
			end
			if not GLDG_Offline[pl] then
				GLDG_Offline[pl] = false
			end
			if (GLDG_Online[pl] == nil) then
				GLDG_Online[pl] = ol
			end
			GLDG_DataChar[pl].guild = GLDG_unique_GuildName
		end
	end
	GLDG_ReadNotes = 0
	-- Parse guild notes for auto assignation
	if (GLDG_Data.GuildSettings.AutoAssign==true) then
		for p in pairs(mains) do
			if (GLDG_DataChar[p] and GLDG_DataChar[p].alt==nil and GLDG_DataChar[p].main==nil) then
				GLDG_DataChar[p].main = true
			end
		end
		for p in pairs(alts) do
			if (GLDG_DataChar[p] and GLDG_DataChar[p].alt==nil and GLDG_DataChar[p].main==nil) then
				if (GLDG_DataChar[alts[p]] and GLDG_DataChar[alts[p]].main) then
					GLDG_DataChar[p].alt = alts[p]
					GLDG_DataChar[p].main = nil
				end
			end
		end
		-------------------------------weise Twinks den Alias des Mains zu ---------------------
		for p in pairs(alts) do
			if (GLDG_DataChar[p] and GLDG_DataChar[p].alias==nil) then
				if (GLDG_DataChar[alts[p]] and GLDG_DataChar[alts[p]].main) then
					GLDG_DataChar[p].alias = GLDG_DataChar[alts[p]].alias
					GLDG_DataChar[p].main = nil
				end
			end
		end
		-------------------------------weise Twinks den Alias des Mains zu ende---------------------
	end

	if not GLDG_checkedChannel then
		GLDG_CheckChannel()
	end

	-- If we got our info, switch to the next phase
	if (cnt > 0) then
		if (complete and GLDG_InitialGuildUpdate == nil) then
			GLDG_InitialGuildUpdate = true
			GLDG_NewGuild = false

			if (GLDG_Data.UpdateTime > 0) then
				GLDG_UpdateRequest = GetTime() + GLDG_Data.UpdateTime
			else
				GLDG_UpdateRequest = nil
			end

			GLDG_RosterPurge()

			if bit.band(GLDG_InitCheck, 1)==1 then
				GLDG_InitCheck = bit.band(GLDG_InitCheck, bit.bnot(1))	-- guild no longer pending
				GLDG_InitCheck = bit.bor(GLDG_InitCheck, 8)
				--GLDG_Print("InitCheck is ["..tostring(GLDG_InitCheck).."] - guild done")
				GLDG_StartupCheck()
			end

			GLDG_Main:RegisterEvent("CHAT_MSG_SYSTEM")
		end
		if (update==true) then
			GLDG_ShowQueue()
		end

		if (GLDG_Data.AutoGreet[GLDG_Realm.." - "..GLDG_Player] and (GLDG_autoGreeted == 0)) then
			GLDG_KeyGreet()
			GLDG_autoGreeted = 1
		end
	end
	GLDG_RosterImportRunning=0
end

------------------------------------------------------------
function GLDG_findMainname(_main, _pl)
	if _main ~= "Main" then
		local omain = nil
		local oDBname = nil
		local _, uRealm = string.split("-", _main)
		if not uRealm then
			omain = _main.."-"
		else
			omain = _main
		end
		local cntMains = 0
		local maxMembers = GetNumGuildMembers()
		for i = 1, maxMembers do
			local player = GetGuildRosterInfo(i)
			local len = string.len(omain)
			if  string.sub(player, 1, len)==omain then
				oDBname = player
				cntMains = cntMains+1
				if cntMains >= 2 then
					if CanEditOfficerNote() then
						GLDG_AddToStartupList("|cFF7F7F7F"..GLDG_TXT.deltaGuild..": "..GLDG_TXT.deltaOnoteFrom.." ["..Ambiguate(_pl, "guild").." ] "..GLDG_TXT.deltaOnoteInvalid.." "..GLDG_TXT.deltaOnoteToManyMatches.." [".._main.."]!|r")
					end
					--print("Die Offiziersnotiz von "..pl.." ist ungültig (zu viele Treffer):"..oDBname.."Zähler: "..cnt)
					_main = nil
					return _main
				end
			end
		end
		if cntMains == 0 then
			if CanEditOfficerNote() then
				GLDG_AddToStartupList("|cFF7F7F7F"..GLDG_TXT.deltaGuild..": "..GLDG_TXT.deltaOnoteFrom.." ["..Ambiguate(_pl, "guild").." ] "..GLDG_TXT.deltaOnoteInvalid.." [".._main.."] "..GLDG_TXT.deltaOnoteNotFound.."|r")
			end
			--print("Die Offiziersnotiz von "..pl.." ist ungültig (nicht gefunden) Zähler: "..cntMains)
		elseif cntMains == 1 then
			_main = oDBname
		end
		return _main
	end
end
------------------------------------------------------------
function GLDG_RosterPurge()
	-- Don't purge if list is not complete
--	if not GetGuildRosterShowOffline() then
--		GLDG_Print("  --> returning early")
--		return
--	end
	--GLDG_Print("  --> doing purge")

	-- Set guildlist
	local purge = {}

	-- Purge old members from database
	for p in pairs(GLDG_DataChar) do
		if (GLDG_Offline[p] == nil) then
			purge[p] = true
		end
	end
	for p in pairs(purge) do
		if (GLDG_DataChar[p].guild and GLDG_DataChar[p].guild==GLDG_unique_GuildName) then
			GLDG_AddToStartupList(GLDG_TXT.deltaGuild..": ["..Ambiguate(p, "guild").."] "..GLDG_TXT.deltaLeftGuild)
			if GLDG_Data.GuildSettings.ListQuit==true then
				if (GLDG_DataChar[p] and GLDG_DataChar[p].alt) then
					local main = GLDG_DataChar[p].alt;
					GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r ["..Ambiguate(p, "guild").."] "..L["has left the guild"].." {"..Ambiguate(main, "guild").."}");
				else
					GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r ["..Ambiguate(p, "guild").."] "..L["has left the guild"]);
				end
			end
			-- do not remove char, but remove guild tag
			GLDG_DataChar[p].guild = nil
			GLDG_DataChar[p].rank = nil
			GLDG_DataChar[p].rankname = nil
			GLDG_DataChar[p].pNote = nil
			GLDG_DataChar[p].oNote = nil
		end
	end
end


------------------------------------------
-- assemble list of alts of a main char --
------------------------------------------
function GLDG_FindAlts(mainName, playerName, colourise)
	local altList = "";

	local details = GLDG_findPlayerDetails(playerName)

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
			elseif (GLDG_DataChar[player].friends and GLDG_DataChar[player].friends[GLDG_Player]) then
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

	altList = altList..GLDG_findAlias(playerName, colourise);

	return altList
end


------------------------------------------
-- get a list of players that are on --
------------------------------------------
function GLDG_getOnlineList()
	local onList = {};

	-- get guild members that are online
	GuildRoster();
	local numTotal = GetNumGuildMembers(true);
	local i
	for i = 0, numTotal do
		local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i);
		if ((name ~= nil) and ( online ~= nil)) then
		local GLDG_shortName, realm = string.split("-", name)
		if not realm then name = GLDG_shortName.."-"..string.gsub(GLDG_Realm, " ", "") end
			onList[name] = true;
		end
	end

	-- get friends that are online
	numTotal = GetNumFriends()
	for i = 1, numTotal do
		local name, level, class, loc, connected, status = GetFriendInfo(i);
		if ((name ~= nil) and connected) then
			onList[name] = true;
		end
	end

	-- get rest (i.e. channel members)
	for p in pairs(GLDG_DataChar) do
		if (GLDG_Online[p]) then
			onList[p] = true
		end
	end

	return onList;
end

------------------------------------------
-- find player details for a player --
------------------------------------------
function GLDG_findPlayerDetails(playerName)
	local result = "";

	if (playerName and GLDG_DataChar[playerName]) then
		if GLDG_DataChar[playerName].class and GLDG_DataChar[playerName].lvl then
			result = GLDG_DataChar[playerName].class..", "..GLDG_DataChar[playerName].lvl
		elseif GLDG_DataChar[playerName].class then
			result = GLDG_DataChar[playerName].class
		elseif GLDG_DataChar[playerName].lvl then
			result = GLDG_DataChar[playerName].lvl
		else
			-- do nothing
		end
	end

	return result;
end

------------------------------------------
-- find alias for current player  --
------------------------------------------
function GLDG_findAlias(playerName, colourise)
	local result = "";

	local alias = "";

	local aliasColour = "";

	if (colourise == 0) then
		aliasColour = GLDG_GOES_OFFLINE_COLOUR;
	elseif (colourise == 1) then
		aliasColour = GLDG_ALIAS_COLOUR;
	end

	if (playerName) then
		if (GLDG_DataChar[playerName]) then
			if (GLDG_DataChar[playerName].alias) then
				alias = GLDG_DataChar[playerName].alias;
			else
				alias = playerName;
			end
			if (GLDG_Data[GLDG_unique_GuildName].GreetAsMain == true and GLDG_DataChar[playerName].alt) then
				if (GLDG_DataChar[GLDG_DataChar[playerName].alt].alias) then
					alias = GLDG_DataChar[GLDG_DataChar[playerName].alt].alias;
				else
					alias = GLDG_DataChar[playerName].alt;
				end
			end
		end
	end

	if (alias ~= "") then
		result = result.." - "..aliasColour..alias.."|r";
	end

	return result;
end

------------------------------------------
-- list of alts and main of a char --
------------------------------------------
function GLDG_ListForPlayer(playerName, allDetails, onList, print, guildOnly)
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
			-- todo: do these colour sets still make sense?
			GLDG_SetActiveColourSet("guild")

			if ( onList == nil) then
				onList = GLDG_getOnlineList();
			end

			local mainName;
			if ( GLDG_DataChar[playerName].main ) then
				mainName = playerName
			elseif ( GLDG_DataChar[playerName].alt ~= nil ) then
				mainName = GLDG_DataChar[playerName].alt;
			else
				mainName = "-";
			end

			local details = GLDG_findPlayerDetails(playerName);
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
						playerDetails = GLDG_findPlayerDetails(player)
					end

					local postfix = ""
					if (GLDG_Data.GuildSettings.AddPostfix==true) then
						if (GLDG_DataChar[player].guild and GLDG_DataChar[player].guild==GLDG_unique_GuildName) then
							-- no postfix for guild members
						elseif (GLDG_DataChar[player].channels and GLDG_DataChar[player].channels[GLDG_ChannelName]) then
							postfix = " {c}"
						elseif (GLDG_DataChar[player].friends and GLDG_DataChar[player].friends[GLDG_Player]) then
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
					result = result..GLDG_findAlias(playerName, 1);
				else
					result = result..GLDG_findAlias(playerName, 2);
				end
			else
				result = result..L["No characters found"]
			end
		else
			result = playerName.." "..GLDG_TXT.notinguild;
			if GLDG_Data.UseFriends==true then
				result = result.." "..GLDG_TXT.notfriend;
			end
			if GLDG_inChannel then
				result = result.." "..GLDG_TXT.notchannel;
			end
		end
		if (print) then
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..result);
		end
	end

	return result;
end

------------------------------------------
-- list of alts and main of a char --
------------------------------------------
function GLDG_ListAllPlayers(offline, print, guildOnly)
	local onList = GLDG_getOnlineList();
	local line = "";
	local result = {};
	local i = 0;

	if (guildOnly == nil) then
		guildOnly = false
	end

	GLDG_SetActiveColourSet("guild")

	if offline then
		if (print) then
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.listall)
		end
		for player in pairs(GLDG_DataChar) do
			if (not guildOnly and (GLDG_DataChar[player].main or not GLDG_DataChar[player].alt)) or
			   (guildOnly and ((not GLDG_DataChar[player].main and (not GLDG_DataChar[player].alt) and GLDG_DataChar[player].guild==GLDG_unique_GuildName) or
			                   (GLDG_DataChar[player].main and GLDG_MainOrAltInCurrentGuild(player)))) then
					line = GLDG_ListForPlayer(player, false, onList, print);
					result[i] = line;
					i = i+1;
			end
		end
	else
		if (print) then
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.listonline)
		end
		for player in pairs(onList) do
			if (not guildOnly or (GLDG_DataChar[player].guild and GLDG_DataChar[player].guild==GLDG_unique_GuildName)) then
				line = GLDG_ListForPlayer(player, false, onList, print);
				result[i] = line;
				i = i+1;
			end
		end
	end

	return result;
end

------------------------------------------
function GLDG_MainOrAltInCurrentGuild(name)
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

----------------------------------
-- _06_ Monitor System Messages --
----------------------------------

function GLDG_SystemMsg(msg)
	if msg == nil then return end
	GLDG_ONLINE 		= ".*%[(.+)%]%S*"..string.sub(ERR_FRIEND_ONLINE_SS, 20)
	GLDG_OFFLINE		= string.format(ERR_FRIEND_OFFLINE_S, "(.+)")
	GLDG_JOINED			= string.format(ERR_GUILD_JOIN_S, "(.+)")
	GLDG_PROMO			= string.format(ERR_GUILD_PROMOTE_SSS, "(.+)", "(.+)", "(.+)")
	GLDG_DEMOTE			= string.format(ERR_GUILD_DEMOTE_SSS, ".+", "(.+)", "(.+)")
	GLDG_ACHIEVE    = string.format(ACHIEVEMENT_BROADCAST, "(.+)", "(.+)")
	-- Receiving system message
	GLDG_DebugPrint("incoming system message: "..msg)
	-- Check players coming online
	local _, _, player = string.find(msg, GLDG_ONLINE)
	if player then
		local GLDG_shortName, realm = string.split("-", player)
		if not realm then player = GLDG_shortName.."-"..string.gsub(GLDG_Realm, " ", "") end
		
		if (GLDG_DataChar[player] and not GLDG_DataChar[player].ignore) then

			if (not GLDG_DataChar[player].guild or GLDG_DataChar[player].guild ~= GLDG_unique_GuildName) and GLDG_DataChar[player].friends and GLDG_DataChar[player].friends[GLDG_Player] and GLDG_Data.UseFriends==false then
				--GLDG_Print("Player ["..Ambiguate(player, "guild").."] seems to be a friends but friend support has been disabled")
				-- this is "only" a friend but friend support has been disabled, stop treating player
				return
			end

			-- always send to guild channel if we're in a guild
			if (GLDG_unique_GuildName ~= "") then
				SendAddonMessage("GLDG", "VER:"..GetAddOnMetadata("GuildGreet", "Version"), "GUILD")
			end

			GLDG_DebugPrint("player "..Ambiguate(player, "guild").." is a member of our guild")
			GLDG_Online[player] = GetTime()

			if GLDG_Data.GuildSettings.ListNames==true then
				if GLDG_DataChar[player].alt then
					--
					-- Alt von Main
					--
					local main = GLDG_DataChar[player].alt;
					local altsList = GLDG_FindAlts(main, player, 1)
					GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..altsList)
				else
					if GLDG_DataChar[player].main then
						--
						-- Main
						--
						local main = player;
						local altsList = GLDG_FindAlts(main, player, 1)
						GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..altsList)
					else
						--
						-- Hat keinen Alt
						--
						local details = GLDG_findPlayerDetails(player);
						local alias = GLDG_findAlias(player, 1);

						if (details ~= "") then
							GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_ONLINE_COLOUR..Ambiguate(player, "guild")..": "..details.."|r"..alias)
						else
							GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_ONLINE_COLOUR..Ambiguate(player, "guild").."|r"..alias)
						end
					end
				end
			end

			if ((GLDG_DataChar[player].storedLvl ~= nil) and (GLDG_DataChar[player].storedLvl > GLDG_DataChar[player].lvl)) then
				if (not GLDG_DataChar[player].own) then
					if ( (GLDG_TableSize(GLDG_FilterMessages(GLDG_DataChar[player], GLDG_DataGreet.NewLevel)) > 0) and (GLDG_Data.GuildSettings.SupressLevel==false) and (not GLDG_DataChar[player].ignore) and (GLDG_DataChar[player].storedLvl > GLDG_Data.GuildSettings.MinLevelUp)) then

						if (GLDG_Data.GuildSettings.NoGratsOnLogin==false) then
							GLDG_DataChar[player].newlvl = true
						end
					end
				end
				GLDG_DataChar[player].lvl = GLDG_DataChar[player].storedLvl
				GLDG_DataChar[player].storedLvl = nil
			end

			if GLDG_DataChar[player].alt then
				GLDG_Offline[player] = GLDG_Offline[GLDG_DataChar[player].alt]
			end
			if GLDG_Offline[player] and (GLDG_Online[player] - GLDG_Offline[player] < GLDG_Data.GuildSettings.RelogTime * 60) then
				return
			end
			GLDG_DebugPrint("player "..Ambiguate(player, "guild").." is not been online in the last "..GLDG_Data.GuildSettings.RelogTime.." minutes.")
			if GLDG_Offline[player] and ((GLDG_TableSize(GLDG_DataGreet.GreetBack) == 0) or (GLDG_Data.GuildSettings.SupressGreet==true)) then
				return
			end
			GLDG_DebugPrint("player "..Ambiguate(player, "guild").." is not been online before")
			if not (GLDG_Offline[player] or GLDG_DataChar[player].new or GLDG_DataChar[player].newlvl or GLDG_DataChar[player].newrank) and (GLDG_Data.GuildSettings.SupressGreet==true or (GLDG_TableSize(GLDG_DataGreet.Greet) == 0)) then
				return
			end
			GLDG_DebugPrint("player "..Ambiguate(player, "guild").." should be greeted")
			GLDG_Queue[player] = GLDG_GetLogtime(player)

			GLDG_ShowQueue()
		end

		return
	end

	-- Check players going offline
	local _, _, player = string.find(msg, GLDG_OFFLINE)
	if player then
		local GLDG_shortName, realm = string.split("-", player)
		if not realm then player = GLDG_shortName.."-"..string.gsub(GLDG_Realm, " ", "") end
		GLDG_DebugPrint("detected player going offline: "..player)
		if (GLDG_DataChar[player] and not GLDG_DataChar[player].ignore) then
			GLDG_DebugPrint("player "..Ambiguate(player, "guild").." is a member of our guild")
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
				GLDG_ShowQueue() end

			if GLDG_Data.GuildSettings.ListNamesOff==true then
				if GLDG_DataChar[player].alt then
					--
					-- Alt von Main
					--
					local main = GLDG_DataChar[player].alt;
					local altsList = GLDG_FindAlts(main, player, 0)
					GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..altsList)
				else
					if GLDG_DataChar[player].main then
						--
						-- Main
						--
						local main = player;
						local altsList = GLDG_FindAlts(main, player, 0)
						GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..altsList)
					else
						--
						-- Hat keinen Alt
						--
						local details = GLDG_findPlayerDetails(player);
						local alias = GLDG_findAlias(player, 0);

						if (details ~= "") then
							GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_GOES_OFFLINE_COLOUR..Ambiguate(player, "guild")..": "..details.."|r"..alias)
						else
							GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_GOES_OFFLINE_COLOUR..Ambiguate(player, "guild").."|r"..alias)
						end
					end
				end
			end
		end

		return
	end

	-- Check players joining the guild
	local _, _, player = string.find(msg, GLDG_JOINED)
	if player then
		local GLDG_shortName, realm = string.split("-", player)
		if not realm then player = GLDG_shortName.."-"..string.gsub(GLDG_Realm, " ", "") end
		if (not GLDG_DataChar[player]) then
			GLDG_DataChar[player] = {}
		end
		if (GLDG_unique_GuildName) then
			GLDG_DataChar[player].guild = GLDG_unique_GuildName
		end
		GLDG_DebugPrint("detected player joining guild: "..player)
		GLDG_Online[player] = GetTime()
		GLDG_Offline[player] = false
		GLDG_Queue[player] = GLDG_GetLogtime(player)
		SendAddonMessage("GLDG", "VER:"..GetAddOnMetadata("GuildGreet", "Version"), "GUILD")
		if (GLDG_Data.GuildSettings.SupressJoin==false) and (GLDG_TableSize(GLDG_FilterMessages(GLDG_DataChar[player], GLDG_DataGreet.Welcome)) > 0) then
			GLDG_DataChar[player].new = true
			GLDG_ShowQueue()
		end
		return
	end

	-- Check for promotions
	local _, _, promo, player, rank = string.find(msg, GLDG_PROMO)
	if player then
		local GLDG_shortName, realm = string.split("-", player)
		if not realm then player = GLDG_shortName.."-"..string.gsub(GLDG_Realm, " ", "") end
	end
	if GLDG_DataChar[player] then
		if player and (GLDG_TableSize(GLDG_FilterMessages(GLDG_DataChar[player], GLDG_DataGreet.NewRank)) > 0) and (GLDG_Data.GuildSettings.SupressRank==false) and (not GLDG_DataChar[player].ignore) then
			--print("detected player getting promotion: "..Ambiguate(player, "guild").." -> "..rank)
			GLDG_DataChar[player].promoter = promo
			GLDG_DataChar[player].rankname = rank
			if GLDG_Data.Ranks[GLDG_unique_GuildName] and GLDG_Data.Ranks[GLDG_unique_GuildName][rank] then
				GLDG_DataChar[player].rank = GLDG_Data.Ranks[GLDG_unique_GuildName][rank] - 1 end
			GLDG_RankUpdate[player] = GLDG_GetLogtime(player)
			GLDG_DataChar[player].newrank = GLDG_DataChar[player].rank
			if GLDG_Online[player] then
				GLDG_Queue[player] = GLDG_GetLogtime(player)
				GLDG_ShowQueue() end
			return end
	end

	-- Check for demotions
	local _, _, player, rank = string.find(msg, GLDG_DEMOTE)
	if GLDG_DataChar[player] then
		if player then
		local GLDG_shortName, realm = string.split("-", player)
		if not realm then player = GLDG_shortName.."-"..string.gsub(GLDG_Realm, " ", "") end
			--print("detected player getting demotion: "..Ambiguate(player, "guild").." -> "..rank)
			GLDG_DataChar[player].promoter = nil
			GLDG_DataChar[player].rankname = rank
			if GLDG_Data.Ranks[GLDG_unique_GuildName] and GLDG_Data.Ranks[GLDG_unique_GuildName][rank] then
				GLDG_DataChar[player].rank = GLDG_Data.Ranks[GLDG_unique_GuildName][rank] - 1 end
			GLDG_RankUpdate[player] = GLDG_GetLogtime(player)
			if GLDG_DataChar[player].newrank then
				GLDG_DataChar[player].newrank = nil
				GLDG_Queue[player] = nil
				GLDG_ShowQueue() end
			return end	
	end

end

------------------------------------------------------------
function GLDG_GetLogtime(player)
	-- Helper function: mark playing coming online
	local hour, minute = GLDG_GetTime()
	if (hour < 10) then hour = "[0"..hour else hour = "["..hour end
	if (minute < 10) then minute = ":0"..minute.."] " else minute = ":"..minute.."] " end
	return hour..minute
end

------------------------------------------------------------
function GLDG_GetTime()
	local hour, minute

	if GLDG_Data.UseLocalTime==true then
		local t = date('*t')		-- returns local time
		hour = t.hour
		minute = t.min
	else
		hour, minute = GetGameTime()	-- returns server time
	end

	return hour, minute
end


----------------------------
-- _07_ Display Greetlist --
----------------------------

function GLDG_ShowQueue()
	-- Sort queue according logon time
	local queue = {}
	local total = 0
	for p in pairs(GLDG_Queue) do
		-- Look for the position in the list we need
		local loc = 1
		if type(GLDG_Online[queue[loc]])=="number" and type(GLDG_Online[p])=="number" then
			while queue[loc] and GLDG_Online[queue[loc]] do
				loc = loc + 1
			end
		end
		-- We found the position: move everything beyond it
		for cnt = total, loc, -1 do
			queue[cnt+1] = queue[cnt]
		end
		-- Insert the player
		total = total + 1
		queue[loc] = p
	end
	-- Display the list as needed
	if (total == 0) and not (GLDG_Debug or GLDG_Data.ListVisible==true) then
		-- No lines and not debugging: hide main window
		_G[GLDG_LIST]:Hide()
		return end
	-- Hide the unused direction
	local dir = "ULine"
	if GLDG_Data.ListUp==true then dir = "Line" end
	cnt = 1
	while _G[GLDG_LIST..dir..cnt] do
		_G[GLDG_LIST..dir..cnt]:Hide()
		cnt = cnt + 1 end
	if GLDG_Data.ListUp==true then dir = "ULine" else dir = "Line" end
	-- Show the used direction
	if not GLDG_Data.ListSize then GLDG_Data.ListSize = 5 end
	for cnt = 1, math.min(total, GLDG_Data.ListSize) do
		local line = GLDG_LIST..dir..cnt
		local colorName = "list"
		local setName = "guild"	-- todo: still needed?
		local postfix = "";
		if (GLDG_DataChar[queue[cnt]].guild and GLDG_DataChar[queue[cnt]].guild==GLDG_unique_GuildName) then
			-- no postfix for guild members
		elseif (GLDG_DataChar[queue[cnt]].channels and GLDG_DataChar[queue[cnt]].channels[GLDG_ChannelName]) then
			postfix = " {c}"
			setName = "channel"
		elseif (GLDG_DataChar[queue[cnt]].friends and GLDG_DataChar[queue[cnt]].friends[GLDG_Player]) then
			postfix = " {f}"
			setName = "friends"
		else
			postfix = " {?}"
		end

		_G[line.."Text"]:SetText(GLDG_Queue[queue[cnt]]..Ambiguate(queue[cnt], "guild"))
		_G[line.."Text2"]:SetText(postfix)
		if (GLDG_DataChar[queue[cnt]]) then
			if GLDG_DataChar[queue[cnt]].new then
				colorName = "new"
				_G[line.."Text2"]:SetText(L["NEW"]..postfix)
			elseif GLDG_DataChar[queue[cnt]].achievment then
				colorName = "achievment"
				_G[line.."Text2"]:SetText(L["ACHV"]..postfix)
			elseif GLDG_DataChar[queue[cnt]].newlvl then
				colorName = "lvl"
				_G[line.."Text2"]:SetText(L["LEVEL"]..postfix)
			elseif GLDG_DataChar[queue[cnt]].newrank then
				colorName = "rank"
				_G[line.."Text2"]:SetText(L["RANK"]..postfix)
			elseif GLDG_Offline[queue[cnt]] then
				colorName = "relog"
			end
		-- handle test entries
		elseif (string.sub(queue[cnt], 1, 6)=="Tester") then
			local number = string.sub(queue[cnt], 7)
			setName = "guild"
			if (number == "1") then
				_G[line.."Text2"]:SetText("{t}")
				colorName = "list"
			elseif (number == "2") then
				_G[line.."Text2"]:SetText(L["NEW"].." {t}")
				colorName = "new"
			elseif (number == "3") then
				_G[line.."Text2"]:SetText(L["LEVEL"].." {t}")
				colorName = "lvl"
			elseif (number == "4") then
				_G[line.."Text2"]:SetText(L["RANK"].." {t}")
				colorName = "rank"
			elseif (number == "5") then
				_G[line.."Text2"]:SetText("{t}")
				colorName = "relog"
			end
		end
		GLDG_SetTextColor(line.."Text", setName, colorName)
		GLDG_SetTextColor(line.."Text2", setName, colorName)
		_G[line]:Show() end
	-- Hide lines we don't need
	cnt = total + 1
	while _G[GLDG_LIST..dir..cnt] do
		_G[GLDG_LIST..dir..cnt]:Hide()
		cnt = cnt + 1 end

	-- Set header colour
	local a,r,g,b = GLDG_ColourToRGB_perc(GLDG_Data.colours.header)
	local f = 1-((r+g+b)/3)
	GuildGreetListTitleText:SetTextColor(f,f,f,1)
	GuildGreetListTitleTexture:SetColorTexture(r,g,b,a)

	-- Show main window
	_G[GLDG_LIST]:Show()
end


--------------------------
-- _08_ Display Greeting Tooltip --
--------------------------

function GLDG_ShowToolTip(self, buttonName)
	-- Tooltip title: use player name and color
	local name = string.sub(_G[buttonName.."Text"]:GetText(), 9)
	local oname = name
	local oDBname = nil
	local _, uRealm = string.split("-", oname)
	if not uRealm then
		local ooname = oname.."-"
		for i in pairs(GLDG_DataChar) do
			if string.find(i, ooname) and GLDG_DataChar[i].guild == GLDG_unique_GuildName then
				oDBname = i
			end
		end
		if oDBname == nil then oDBname = ooname..string.gsub(GLDG_Realm, " ", "") end
	else
		oDBname = oname
	end
	local logtime = string.sub(_G[buttonName.."Text"]:GetText(), 2, 6)
	local r, g, b = _G[buttonName.."Text"]:GetTextColor()
	-- Construct tip
	local tip = string.format(L["At %s, this character came online for the first time during this session."], logtime)
	if GLDG_DataChar[oDBname] then
		if GLDG_DataChar[oDBname].new then
			if (logtime == "??:??") then
				tip = L["Player joined the guild before you logged on."]
			else
				tip = string.format(L["At %s, this player joined the guild"], logtime)
			end

		elseif GLDG_DataChar[oDBname].achievment then
			tip = string.format(L["Player has achieved %s."], GLDG_DataChar[oDBname].achievment)

		elseif GLDG_DataChar[oDBname].newlvl then
			tip = string.format(L["Character reached level %s."], GLDG_DataChar[oDBname].lvl)

		elseif GLDG_DataChar[oDBname].newrank then
			if GLDG_DataChar[oDBname].promoter then
				 if (logtime == "??:??") then
				 	tip = string.format(L["%s promoted the player to rank %s earlier."], Ambiguate(GLDG_DataChar[oDBname].promoter, "guild"), GLDG_DataChar[oDBname].rankname)
				 else
				 	tip = string.format(L["At %s, %s promoted this player to rank %s."], logtime, Ambiguate(GLDG_DataChar[oDBname].promoter, "guild"), GLDG_DataChar[oDBname].rankname)
				 end
			else
				tip = string.format(L["Player was promoted to rank %s before you logged on."], GLDG_DataChar[oDBname].rankname)
			end

		elseif GLDG_Offline[name] then
			local minoff = math.ceil((GLDG_Online[name] - GLDG_Offline[name]) / 60)
			local hrsoff = math.floor(minoff / 60)
			minoff = math.fmod(minoff, 60)
			local timestr = ""
			if (hrsoff > 0) then timestr = string.format(L["%d hour "], hrsoff) end
			if (minoff > 0) then timestr = timestr..string.format(L["%d min"], minoff) end
			tip = string.format(L["At %s, this character came back online after being offline for %s."], logtime, timestr) end

		-- If this is a main, add last used character to tip
		if GLDG_DataChar[oDBname].main and GLDG_DataChar[oDBname].last then
			tip = tip..string.format(L[" Character used by player previously was %s."], Ambiguate(GLDG_DataChar[oDBname].last, "guild"))

		-- If this is not the main, add last used character and main information to tip
		elseif GLDG_DataChar[oDBname].alt then
			local main = GLDG_DataChar[oDBname].alt
			if GLDG_DataChar[main] and GLDG_DataChar[main].last then
				tip = tip..string.format(L[" Character used by player previously was %s."], Ambiguate(GLDG_DataChar[main].last, "guild"))
			end
			tip = tip..string.format(L[" Main character for this player is %s."], Ambiguate(GLDG_DataChar[oDBname].alt, "guild"))
		end

		-- If player has alias, add to name
		if GLDG_DataChar[oDBname].alt then
			name = name.." ["..Ambiguate(GLDG_DataChar[oDBname].alt, "guild").."]"
			if (GLDG_DataChar[GLDG_DataChar[oDBname].alt] and GLDG_DataChar[GLDG_DataChar[oDBname].alt].alias) then
				name = name .." ("..GLDG_DataChar[GLDG_DataChar[oDBname].alt].alias..")"
			end
		elseif GLDG_DataChar[oDBname].alias then
			name = name.." ("..GLDG_DataChar[oDBname].alias..")"
		end

		-- handle postfix
		if (GLDG_DataChar[oDBname].guild and GLDG_DataChar[oDBname].guild==GLDG_unique_GuildName) then
			  -- no postfix for guild members
		elseif (GLDG_DataChar[oDBname].channels and GLDG_DataChar[oDBname].channels[GLDG_ChannelName]) then
			name = name.." {c}"
		elseif (GLDG_DataChar[oDBname].friends and GLDG_DataChar[oDBname].friends[GLDG_Player]) then
			name = name.." {f}"
		else
			name = name.." {?}"
		end

	-- handle test entries
	elseif (string.sub(name, 1, 6)=="Tester") then
		local number = string.sub(name, 7)
		if (number == "1") then
			tip = string.format(L["At %s, this character came online for the first time during this session."], logtime)
		elseif (number == "2") then
			tip = string.format(L["At %s, this player joined the guild"], logtime)
		elseif (number == "3") then
			tip = string.format(L["Character reached level %s."], math.random(70))
		elseif (number == "4") then
			tip = string.format(L["At %s, %s promoted this player to rank %s."], logtime, "Supertester", "Gopher-Tester")
		elseif (number == "5") then
			tip = string.format(L["At %s, this character came back online after being offline for %s."], logtime, "some time")
		end
		name = name.." {t}"
	end

	-- Show tooltip
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	GameTooltip:SetText(name, r, g, b, 1.0, 1)
	GameTooltip:AddLine(tip, 1, 1, 1, 1.0, 1)
	if (GLDG_DataChar[oDBname].alt or GLDG_DataChar[oDBname].guild or GLDG_DataChar[oDBname].lvl) then
		GameTooltip:AddLine(" ", 1, 1, 1, 1.0, 1)
		if (GLDG_DataChar[oDBname].alt) then
			if (GLDG_DataChar[GLDG_DataChar[oDBname].alt].alias) then
				GameTooltip:AddDoubleLine(GLDG_TXT.tipMain, GLDG_DataChar[oDBname].alt.." ("..GLDG_DataChar[GLDG_DataChar[oDBname].alt].alias..")", 1, 1, 0, 1, 1, 1)
			else
				GameTooltip:AddDoubleLine(GLDG_TXT.tipMain, Ambiguate(GLDG_DataChar[oDBname].alt, "guild"), 1, 1, 0, 1, 1, 1)
			end
		end
		if (GLDG_DataChar[oDBname].guild) then
			if GLDG_DataChar[oDBname].guild==GLDG_unique_GuildName then 
				GameTooltip:AddDoubleLine(GLDG_TXT.tipGuild, GLDG_GuildName, 1, 1, 0, 1, 1, 1)
			else
				GameTooltip:AddDoubleLine(GLDG_TXT.tipGuild, GLDG_DataChar[oDBname].guild, 1, 1, 0, 1, 1, 1)
			end
		end
		if GLDG_DataChar[oDBname].rank and GLDG_DataChar[oDBname].rankname then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipNewRank, GLDG_DataChar[oDBname].rankname.." ("..tostring(GLDG_DataChar[oDBname].rank)..")", 1, 1, 0, 1, 1, 1)
			added = true
		elseif GLDG_DataChar[oDBname].rank then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipNewRank, tostring(GLDG_DataChar[oDBname].rank), 1, 1, 0, 1, 1, 1)
			added = true
		elseif GLDG_DataChar[oDBname].rankname then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipNewRank, GLDG_DataChar[oDBname].rankname, 1, 1, 0, 1, 1, 1)
			added = true
		end
		if GLDG_DataChar[oDBname].pNote then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipPlayerNote, GLDG_DataChar[oDBname].pNote, 1, 1, 0, 1, 1, 1)
			added = true
		end
		if GLDG_DataChar[oDBname].oNote then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipOfficerNote, GLDG_DataChar[oDBname].oNote, 1, 1, 0, 1, 1, 1)
			added = true
		end

		if GLDG_DataChar[oDBname].class then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipClass, GLDG_DataChar[oDBname].class, 1, 1, 0, 1, 1, 1)
			added = true
		end
		if GLDG_DataChar[oDBname].storedLvl then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipLevel, GLDG_DataChar[oDBname].storedLvl, 1, 1, 0, 1, 1, 1)
		elseif GLDG_DataChar[oDBname].lvl then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipLevel, GLDG_DataChar[oDBname].lvl, 1, 1, 0, 1, 1, 1)
			added = true
		end
		if (GLDG_DataChar[oDBname].friends and GLDG_DataChar[oDBname].friends[GLDG_Player] and GLDG_DataChar[oDBname].friends[GLDG_Player]~="") then
			GameTooltip:AddLine(" ", 1, 1, 1, 1.0, 1)
			GameTooltip:AddDoubleLine(GLDG_TXT.tipFriendNote, GLDG_DataChar[oDBname].friends[GLDG_Player], 1, 1, 0, 1, 1, 1)
		end
		if GLDG_DataChar[oDBname].note then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipNote, GLDG_DataChar[oDBname].note, 1, 1, 0, 1, 1, 1)
			added = true
		end
	end
	GameTooltip:Show()
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
		if string.len(name) == len then name = name..string.gsub(GLDG_Realm, " ", "") end
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
	for name in pairs(GLDG_Queue) do
		GLDG_CleanupPlayer(name)
	end
	GLDG_Queue = {}
	GLDG_ShowQueue()
end

------------------------------------------------------------
function GLDG_CleanupPlayer(name)
	if not name then return end
	if (GLDG_DataChar[name]) then
		local player = GLDG_DataChar[name]
		player.new = nil
		player.newlvl = nil
		player.newrank = nil
		player.promoter = nil
		player.achievment = nil
	else
		-- take care of test chars
		GLDG_Online[name] = nil
		GLDG_Offline[name] = nil
	end
end

------------------------------------------------------------
-- this function was submitted by lebanoncyberspace
-- and modified by Urbin for %-based codes and to handle
-- time limits in addition to level ranges
------------------------------------------------------------
function GLDG_FilterLevels(message, level) -- returns message
	local _,_,min,max,msg = string.find(message, "^<levels:(%d*):(%d*)>%s*(.*)")
	--GLDG_Print("Checking levels ["..tostring(min).."] - ["..tostring(max).."] - level is ["..tostring(level).."] - remaining message is ["..tostring(msg).."] - original message was ["..tostring(message).."]")
	if (min and max) then
		if (not level) or (tonumber(min) > level) or (level > tonumber(max)) then
			--GLDG_Print(" --> level criteria failed, removing message")
			message = nil
		else
			--GLDG_Print(" --> level criteria fulfilled")
			message = msg
		end
	else
		--GLDG_Print(" --> no level found, keeping message ["..tostring(message).."] unchanged")
	end

	return message
end

------------------------------------------------------------
function GLDG_FilterTime(message, hour, minute) -- returns message
	local _,_,fromH,fromM,toH,toM,msg = string.find(message, "^<time:(%d*)%.(%d*):(%d*)%.(%d*)>%s*(.*)")
	--GLDG_Print("Checking time ["..tostring(fromH)..":"..tostring(fromM).."] - ["..tostring(toH)..":"..tostring(toM).."] - time is ["..tostring(hour)..":"..tostring(minute).."] - remaining message is ["..tostring(msg).."] - original message was ["..tostring(message).."]")
	if (fromH and fromM and toH and toM) then
		fromH = tonumber(fromH)
		fromM = tonumber(fromM)
		toH = tonumber(toH)
		toM = tonumber(toM)
		if (hour < fromH) or (hour > toH) or ((hour == fromH) and (minute < fromM)) or ((hour == toH) and (minute > toH)) then
			--GLDG_Print(" --> time criteria failed, removing message")
			message = nil
		else
			--GLDG_Print(" --> time criteria fulfilled")
			message = msg
		end
	else
		--GLDG_Print(" --> no time found, keeping message ["..tostring(message).."] unchanged")
	end

	return message
end

------------------------------------------------------------
function GLDG_FilterMessages(player, list)
	local newlist = {}
	local count = 0

	local hour,minute = GLDG_GetTime();
	hour = tonumber(hour)
	minute = tonumber(minute)

	if player == nil then
		-- dummy player, so the checks for subvars below are safe, even if the fail
		player = {}
	end

	local level = nil
	if player.storedLvl then
		level = player.storedLvl
	elseif player.lvl then
		level = player.lvl
	end

	for p in pairs(list) do
		local message = list[p]

		-- first level check takes care of "<levels:##:##>msg" and "<levels:##:##><time:##.##:##.##>msg"
		message = GLDG_FilterLevels(message, level)
		-- time check takes care of "<time:##.##:##.##>msg", "<time:##.##:##.##><levels:##:##>msg" and second part of "<levels:##:##><time:##.##:##.##>msg"
		if message then
			message = GLDG_FilterTime(message, hour, minute)
		end
		-- second level check takes care of second part of "<time:##.##:##.##><levels:##:##>msg"
		if message then
			message = GLDG_FilterLevels(message, level)
		end

		-- if the message wants information we don't have, filter it out
		if (message and (not player.achievment) and string.find(message, "%%v")) then
			message = nil
		end
		if (message and (not player.class) and string.find(message, "%%C")) then
			message = nil
		end
		if (message and (not level) and string.find(message, "%%l")) then
			message = nil
		end
		if (message and (not level) and string.find(message, "%%L")) then
			message = nil
		end
		if (message and (not player.rankname) and string.find(message, "%%r")) then
			message = nil
		end
		if message then
			count = count + 1
			newlist[count] = message
			--GLDG_Print("      ------> adding message ["..message.."]")
		end
	end

	return newlist
end


------------------------------------------------------------
function GLDG_ParseCustomMessage(cname, name, msg)
	local result = msg

	local player = GLDG_DataChar[cname]
	if not player then
		player = {}
	end

	-- prepare our own %-codes
	local p_c = Ambiguate(cname, "guild")	-- %c = char
	local p_n = nil
	local _, uRealm = string.split("-", name)
	if not uRealm then
		p_n = name	-- %n = name as used today (depending on settings)	
	else
		p_n = Ambiguate(name, "guild")	-- %n = name as used today (depending on settings)
	end
	local p_a = Ambiguate(cname, "guild")	-- %a = alias
	if (player.alias) then
		p_a = player.alias
	end
	local p_m = Ambiguate(cname, "guild")	-- %m = main if available, %c else
	if (player.alt) then
		p_m = Ambiguate(player.alt, "guild")
	end
	local p_A = p_m	-- %A = main alias if available, %a else if available, %m else
	if (player.alt and GLDG_DataChar[player.alt].alias) then
		p_A = GLDG_DataChar[player.alt].alias
	elseif player.alias then
		p_A = player.alias
	end
	local p_l = ""	-- %l = level if available, empty else
	if (player.storedLvl) then
		p_l = tostring(player.storedLvl)
	elseif (player.lvl) then
		p_l = tostring(player.lvl)
	end
	local p_L = ""	-- %L = levels left to level cap (inspired by lebanoncyberspace)
	if (player.storedLvl) then
		p_L = tostring(GLDG_LEVEL_CAP - player.storedLvl)
	elseif (player.lvl) then
		p_L = tostring(GLDG_LEVEL_CAP - player.lvl)
	end
	local p_C = ""	-- %C = class name if available, emtpy else (inspired by lebanoncyberspace)
	if (player.class) then
		p_C = player.class
	end
	local p_r = ""	-- %r = rankname if available, rank number else if available, empty else
	if (player.rankname) then
		p_r = player.rankname
	elseif (player.rank) then
		p_r = tostring(player.rank)
	end
	local p_v = ""	-- %v = achievment if available, empty else
	if (player.achievment) then
		p_v = player.achievment
	end
	local p_g = ""	-- %g = guild alias if available, else guild if available, else empty
	local p_G = ""	-- %G = guild name if available, else empty
	if (GLDG_unique_GuildName ~= "") then
		p_g = GLDG_unique_GuildName
		p_G = GLDG_unique_GuildName
	end
	if (GLDG_GuildAlias ~= "") then
		p_g = GLDG_GuildAlias
	end

	-- replace fields
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

------------------------------------------------------------
function GLDG_SendGreet(name, testing)
	-- find player entry
	local option = ""
	local list = GLDG_DataGreet.Greet
	local player = GLDG_DataChar[name]
	local names = {}
	local whisper = GLDG_Data.GuildSettings.Whisper

	if (not player) then
		return
	end
	local cname = name
	table.insert(names, name)

	-- Choose appropriate greeting list
	if player.new then
		list = GLDG_DataGreet.Welcome
	elseif player.newrank then
		list = GLDG_DataGreet.NewRank
		option = player.rankname
	elseif player.achievment then
		list = GLDG_DataGreet.Achievment
		option = player.achievment
	elseif player.newlvl then
		list = GLDG_DataGreet.NewLevel
		option = player.lvl
		if (GLDG_Data.GuildSettings.WhisperLevelup==true) then
			whisper = true
		end
	elseif GLDG_Offline[name] then
		list = GLDG_DataGreet.GreetBack
	end
	list = GLDG_FilterMessages(player, list)

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
		if GLDG_DataChar[player.alt].alias then
			lalias = GLDG_DataChar[player.alt].alias
		end
		lname = Ambiguate(player.alt, "guild")
		if (lname~="") then
			table.insert(names, lname)
		end
		if (lalias~="") then
			table.insert(names, lalias)
			lname = lalias
		end
		if (usedAlias==false and GLDG_Data[GLDG_unique_GuildName].GreetAsMain == true and lname and lname~="") then
			name = lname;
		end
	end

	-- Select a random greeting
	local greetSize = GLDG_TableSize(list)
	if (greetSize == 0) then return end
	local msg = list[math.random(greetSize)]

	-- Select a random name
	greetSize = GLDG_TableSize(names)
	if GLDG_Data.GuildSettings.Randomize==true and (greetSize ~= 0) then
		name = names[math.random(greetSize)]
		local uName, uRealm = string.split("-", name)
		if uRealm then
		name = Ambiguate(name, "guild")
		end
	end

	-- parse for our own %-codes
	local message = GLDG_ParseCustomMessage(cname, name, msg)
	message = string.format(message, name, option)

	-- Send greeting
	if (testing) then
		GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r ["..message.."]")
	else
		if whisper==true then
			-- manual whisper setting overrides all
			SendChatMessage(message, "WHISPER", nil, cname)

		elseif (player.guild and player.guild == GLDG_unique_GuildName) then
			-- in same guild as this char
			SendChatMessage(message, "GUILD")

		elseif (GLDG_ChannelName and player.channels and player.channels[GLDG_ChannelName]) then
			-- in same channel as this char
			local channel = GetChannelName(GLDG_ChannelName)
			if (channel) then
				SendChatMessage(message, "CHANNEL", nil, channel)
			else
				SendChatMessage(message, "WHISPER", nil, cname)
			end
		else
			-- friends or indeterminate
			SendChatMessage(message, "WHISPER", nil, cname)
		end
	end
end

------------------------------------------
-- say goodbye to person, using main name
------------------------------------------
function GLDG_SendBye(name, testing)
	if (name == nil) then return end

	-- find player entry
	local player = GLDG_DataChar[name]
	local names = {}

	if (not player) then
		return
	end

	local cname = name
	table.insert(names, name)

	-- Choose appropriate greeting list
	local option = ""
	local list = GLDG_DataGreet.Bye

	-- if time is between 20:00 and 06:00 use night mode
	local hour,min = GLDG_GetTime();
	if ((hour >= 20) or (hour <=5)) then
		list = GLDG_DataGreet.Night;
	end
	list = GLDG_FilterMessages(player, list)

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
		if GLDG_DataChar[player.alt].alias then
			lalias = GLDG_DataChar[player.alt].alias
		end
		lname = player.alt
		if (lname~="") then
			table.insert(names, lname)
		end
		if (lalias~="") then
			table.insert(names, lalias)
			lname = lalias
		end
		if (usedAlias==false and GLDG_Data[GLDG_unique_GuildName].GreetAsMain == true and lname~="") then
			name = lname;
		end
	end

	-- Select a random good bye
	local greetSize = GLDG_TableSize(list)
	if (greetSize == 0) then return end
	local msg = list[math.random(greetSize)]

	-- Select a random name
	greetSize = GLDG_TableSize(names)
	if GLDG_Data.GuildSettings.Randomize==true and (greetSize ~= 0) then
		name = names[math.random(greetSize)]
	end

	-- parse for our own %-codes
	local message = GLDG_ParseCustomMessage(cname, name, msg)

	-- still replace first and second %s to support old messages
	--print("Name: "..name.." Message: "..message.." Option: "..option)
	message = string.format(message, name, option)

	-- Send good bye
	if (testing) then
		GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r ["..message.."]")
	else
		if GLDG_Data.GuildSettings.Whisper==true then
			SendChatMessage(message, "WHISPER", nil, cname)

		elseif (player.guild and player.guild == GLDG_unique_GuildName) then
			SendChatMessage(message, "GUILD")

		elseif (GLDG_ChannelName and player.channels and player.channels[GLDG_ChannelName]) then
			local channel = GetChannelName(GLDG_ChannelName)
			if (channel) then
				SendChatMessage(message, "CHANNEL", nil, channel)
			else
				SendChatMessage(message, "WHISPER", nil, cname)
			end
		else
			SendChatMessage(message, "WHISPER", nil, cname)
		end
	end
end

------------------------------------------------------------
function GLDG_KeyGreet()
	if (GLDG_Data.GreetGuild[GLDG_Realm.." - "..GLDG_Player]) then
		GLDG_GreetGuild()
	end
	if (GLDG_Data.GreetChannel[GLDG_Realm.." - "..GLDG_Player]) then
		GLDG_GreetChannel()
	end
end

------------------------------------------------------------
function GLDG_GreetGuild()
	if (GLDG_unique_GuildName=="") then return end

	local list = GLDG_DataGreet.Guild
	list = GLDG_FilterMessages(nil, list)

	local greetSize = GLDG_TableSize(list)
	if (greetSize ==0 ) then return end

	local msg = list[math.random(greetSize)]
	msg = GLDG_ParseCustomMessage("", "", msg)

	-- Send greeting (still parse for %s for backwards compatibility)
	SendChatMessage(string.format(msg, GLDG_GuildAlias), "GUILD")
end

------------------------------------------------------------
function GLDG_GreetChannel()
	local list = GLDG_DataGreet.Channel
	list = GLDG_FilterMessages(nil, list)

	local greetSize = GLDG_TableSize(list)
	if (greetSize ==0 ) then return end

	local msg = list[math.random(greetSize)]
	msg = GLDG_ParseCustomMessage("", "", msg)

	-- Send greeting
	local channel = GetChannelName(GLDG_ChannelName)
	if (channel) then
		SendChatMessage(msg, "CHANNEL", nil, channel)
	end
end

------------------------------------------------------------
function GLDG_KeyBye()
	if (GLDG_Data.GreetGuild[GLDG_Realm.." - "..GLDG_Player]) then
		GLDG_ByeGuild()
	end
	if (GLDG_Data.GreetChannel[GLDG_Realm.." - "..GLDG_Player]) then
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
	-- if time is between 20:00 and 06:00 use night mode
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
		SendChatMessage(msg, "CHANNEL", nil, channel)
	end
end

------------------------------------------------------------
function GLDG_KeyLater()
	if (GLDG_Data.GreetGuild[GLDG_Realm.." - "..GLDG_Player]) then
		GLDG_LaterGuild()
	end
	if (GLDG_Data.GreetChannel[GLDG_Realm.." - "..GLDG_Player]) then
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
		SendChatMessage(msg, "CHANNEL", nil, channel)
	end
end

------------------------
-- _10_ Slash Handler --
------------------------
function GLDG_SlashHandler(msg)
	if not msg then
		_G[GLDG_GUI]:Show()
	else
		local msgLower = string.lower(msg)
		local words = GLDG_GetWords(msg)
		local wordsLower = GLDG_GetWords(msgLower)
		local size = GLDG_TableSize(wordsLower)

		if (size>0) then
			if (wordsLower[0]=="debug") then
				if (size>1) then
					if (wordsLower[1]=="off") then
						GLDG_Debug = false
					elseif (wordsLower[1]=="on") then
						GLDG_Debug = true
					elseif (wordsLower[1]=="toggle") then
						GLDG_Debug = not GLDG_Debug
					else
						GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.command.." ["..GLDG_Data.colours.help..msgLower.."|r]")
						GLDG_Help()
					end
				end
				local state = "OFF"
				if GLDG_Debug then state = "ON" end
				DEFAULT_CHAT_FRAME:AddMessage("GUILDGREET DEBUG IS NOW "..state)

			elseif (wordsLower[0]=="force") then
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
						GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.pasting);
						GLDG_list = GLDG_ListAllPlayers(true, false);	-- include_offline=true, print=false, guildOnly=false
						GLDG_PasteList.List:Show();
					else
						GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.command.." ["..GLDG_Data.colours.help..msgLower.."|r]")
						GLDG_Help()
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
						GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.pasting);
						GLDG_list = GLDG_ListAllPlayers(true, false, true);	-- include_offline=true, print=true, guildOnly=true
						GLDG_PasteList.List:Show();
					else
						GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.command.." ["..GLDG_Data.colours.help..msgLower.."|r]")
						GLDG_Help()
					end
				else
					GLDG_ListAllPlayers(false, true, true)				-- include_offline=false, print=true, guildOnly=true
				end

			elseif (wordsLower[0]=="show") then
				if (size>1) then
					GLDG_ListForPlayer(words[1], false)
				else
					GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.argmissing.." ["..GLDG_Data.colours.help..wordsLower[0].."|r]")
					GLDG_Help()
				end
			elseif (wordsLower[0]=="full") then
				if (size>1) then
					GLDG_ListForPlayer(words[1], true)
				else
					GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.argmissing.." ["..GLDG_Data.colours.help..wordsLower[0].."|r]")
					GLDG_Help()
				end

			elseif (wordsLower[0]=="detail") then
				if (size>1) then
					GLDG_ShowDetails(words[1])
				else
					GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.argmissing.." ["..GLDG_Data.colours.help..wordsLower[0].."|r]")
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
						GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.command.." ["..GLDG_Data.colours.help..msgLower.."|r]")
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
				GLDG_BB(not GLDG_Data.BigBrother)
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

----------------------
-- _11_ Tab Changer --
----------------------

function GLDG_ClickTab(self, tabName)
	-- Actions to perform when a tab is clicked
	PanelTemplates_Tab_OnClick(self, _G[GLDG_GUI])
	-- Show frame linked to tab, hide all others
	local tabNum = 1
	while _G[GLDG_GUI.."Tab"..tabNum] do
		local frame = nil
		if GLDG_Tab2Frame["Tab"..tabNum] then
			frame = _G[GLDG_GUI..GLDG_Tab2Frame["Tab"..tabNum]]
		end
		if frame then
			if (tabName == GLDG_GUI.."Tab"..tabNum) then
				frame:Show()
			else
				frame:Hide()
			end
		end
		tabNum = tabNum + 1
	end
end

function GLDG_ClickSubTab(self, tabName)
	-- Actions to perform when a tab is clicked
	PanelTemplates_Tab_OnClick(self, _G[GLDG_GUI.."Settings"])
	-- Show frame linked to tab, hide all others
	local tabNum = 1
	while _G[GLDG_GUI.."SettingsTab"..tabNum] do
		local frame = nil
		if GLDG_SubTab2Frame["Tab"..tabNum] then frame = _G[GLDG_GUI.."Settings"..GLDG_SubTab2Frame["Tab"..tabNum]] end
		if frame then if (tabName == GLDG_GUI.."SettingsTab"..tabNum) then frame:Show() else frame:Hide() end end
		tabNum = tabNum + 1
	end
end

-----------------------------
-- _12_ General Tab Update --
-----------------------------

------------------------------------------------------------
function GLDG_UpdateRelog(self)
	-- Store the new value
	GLDG_Data.GuildSettings.RelogTime = self:GetValue()
	-- Update display
	local text = _G[self:GetParent():GetName().."RelogText"]
	if (GLDG_Data.GuildSettings.RelogTime == 0) then text:SetText(L["Always show relogs"].."*")
	else text:SetText(string.format(L["Only show relogs after more then %d min"], GLDG_Data.GuildSettings.RelogTime)) end
	if GLDG_unique_GuildName then GLDG_generateConfigString() end
end

------------------------------------------------------------
function GLDG_UpdateMinLevelUp(self)
	-- Store the new value
	GLDG_Data.GuildSettings.MinLevelUp = self:GetValue()
	-- Update display
	local text = _G[self:GetParent():GetName().."MinLevelUpText"]
	if (GLDG_Data.GuildSettings.MinLevelUp == 0) then text:SetText(L["Always show level-up"].."*")
	else text:SetText(string.format(L["Only show level-up for levels above %d"], GLDG_Data.GuildSettings.MinLevelUp).."*") end
	if GLDG_unique_GuildName then GLDG_generateConfigString() end
end

------------------------------------------------------------
function GLDG_UpdateUpdateTime(self)
	-- Store the new value
	GLDG_Data.UpdateTime = self:GetValue() * 10
	-- Update display
	local text = _G[self:GetParent():GetName().."UpdateTimeText"]
	if (GLDG_Data.UpdateTime == 0) then
		text:SetText(L["Only update guild roster on events"])
	else
		text:SetText(string.format(L["Update guild roster every %d seconds"], GLDG_Data.UpdateTime))
	end

	if GLDG_InitialGuildUpdate then
		if (GLDG_Data.UpdateTime >= 0) then
			GLDG_UpdateRequest = GetTime() + GLDG_Data.UpdateTime
		else
			GLDG_UpdateRequest = nil
		end
	end
	if GLDG_InitialFriendsUpdate then
		if (GLDG_Data.UpdateTime >= 0) then
			GLDG_UpdateRequestFriends = GetTime() + GLDG_Data.UpdateTime
		else
			GLDG_UpdateRequestFriends = nil
		end
	end
end

------------------------------------------------------------
function GLDG_SetCheckboxes()
	local name1 = GLDG_GUI.."SettingsGeneral"
	local name2 = GLDG_GUI.."SettingsChat"
	local name3 = GLDG_GUI.."SettingsGreeting"
	local name4 = GLDG_GUI.."SettingsOther"
		if GLDG_Data.GuildSettings.UseGuildDefault==true then
			_G[name1.."GreetAsMainBox"]:Disable()
			_G[name1.."GreetAsMainText"]:SetAlpha(0.5)
			_G[name1.."RandomizeBox"]:Disable()
			_G[name1.."RandomizeText"]:SetAlpha(0.5)
			_G[name1.."WhisperBox"]:Disable()
			_G[name1.."WhisperText"]:SetAlpha(0.5)
			_G[name1.."WhisperLevelupBox"]:Disable()
			_G[name1.."WhisperLevelupText"]:SetAlpha(0.5)
			_G[name1.."IncludeOwnBox"]:Disable()
			_G[name1.."IncludeOwnText"]:SetAlpha(0.5)
			_G[name1.."AutoAssignBox"]:Disable()
			_G[name1.."AutoAssignText"]:SetAlpha(0.5)
			_G[name1.."AutoAssignEgpBox"]:Disable()
			_G[name1.."AutoAssignEgpText"]:SetAlpha(0.5)
			_G[name1.."AutoAssignAliasBox"]:Disable()
			_G[name1.."AutoAssignAliasText"]:SetAlpha(0.5)
			_G[name1.."RelogSlider"]:Disable()
			_G[name1.."RelogText"]:SetAlpha(0.5)
			_G[name1.."MinLevelUpSlider"]:Disable()
			_G[name1.."MinLevelUpText"]:SetAlpha(0.5)			
			_G[name2.."ListNamesBox"]:Disable()
			_G[name2.."ListNamesText"]:SetAlpha(0.5)
			_G[name2.."ListNamesOffBox"]:Disable()
			_G[name2.."ListNamesOffText"]:SetAlpha(0.5)
			_G[name2.."ListLevelUpBox"]:Disable()
			_G[name2.."ListLevelUpText"]:SetAlpha(0.5)
			_G[name2.."ListLevelUpOffBox"]:Disable()
			_G[name2.."ListLevelUpOffText"]:SetAlpha(0.5)
			_G[name2.."ListAchievmentsBox"]:Disable()
			_G[name2.."ListAchievmentsText"]:SetAlpha(0.5)
			_G[name2.."ListQuitBox"]:Disable()
			_G[name2.."ListQuitText"]:SetAlpha(0.5)
			_G[name2.."ExtendChatBox"]:Disable()
			_G[name2.."ExtendChatText"]:SetAlpha(0.5)
			_G[name2.."ExtendIgnoredBox"]:Disable()
			_G[name2.."ExtendIgnoredText"]:SetAlpha(0.5)
			_G[name2.."ExtendMainBox"]:Disable()
			_G[name2.."ExtendMainText"]:SetAlpha(0.5)
			_G[name2.."ExtendAliasBox"]:Disable()
			_G[name2.."ExtendAliasText"]:SetAlpha(0.5)
			_G[name2.."AddPostfixBox"]:Disable()
			_G[name2.."AddPostfixText"]:SetAlpha(0.5)
			_G[name2.."ShowWhoSpamBox"]:Disable()
			_G[name2.."ShowWhoSpamText"]:SetAlpha(0.5)
			_G[name3.."SupressGreetBox"]:Disable()
			_G[name3.."SupressGreetText"]:SetAlpha(0.5)
			_G[name3.."SupressJoinBox"]:Disable()
			_G[name3.."SupressJoinText"]:SetAlpha(0.5)
			_G[name3.."SupressLevelBox"]:Disable()
			_G[name3.."SupressLevelText"]:SetAlpha(0.5)
			_G[name3.."SupressRankBox"]:Disable()
			_G[name3.."SupressRankText"]:SetAlpha(0.5)
			_G[name3.."SupressAchievmentBox"]:Disable()
			_G[name3.."SupressAchievmentText"]:SetAlpha(0.5)
			_G[name3.."NoGratsOnLoginBox"]:Disable()
			_G[name3.."NoGratsOnLoginText"]:SetAlpha(0.5)
			_G[name4.."DeltaPopupBox"]:Disable()
			_G[name4.."DeltaPopupText"]:SetAlpha(0.5)
		else
			_G[name1.."GreetAsMainBox"]:Enable()
			_G[name1.."GreetAsMainText"]:SetAlpha(1.0)
			_G[name1.."RandomizeBox"]:Enable()
			_G[name1.."RandomizeText"]:SetAlpha(1.0)
			_G[name1.."WhisperBox"]:Enable()
			_G[name1.."WhisperText"]:SetAlpha(1.0)
			_G[name1.."WhisperLevelupBox"]:Enable()
			_G[name1.."WhisperLevelupText"]:SetAlpha(1.0)
			_G[name1.."IncludeOwnBox"]:Enable()
			_G[name1.."IncludeOwnText"]:SetAlpha(1.0)
			_G[name1.."AutoAssignBox"]:Enable()
			_G[name1.."AutoAssignText"]:SetAlpha(1.0)
			_G[name1.."AutoAssignEgpBox"]:Enable()
			_G[name1.."AutoAssignEgpText"]:SetAlpha(1.0)
			_G[name1.."AutoAssignAliasBox"]:Enable()
			_G[name1.."AutoAssignAliasText"]:SetAlpha(1.0)
			_G[name1.."RelogSlider"]:Enable()
			_G[name1.."RelogText"]:SetAlpha(1.0)
			_G[name1.."MinLevelUpSlider"]:Enable()
			_G[name1.."MinLevelUpText"]:SetAlpha(1.0)
			_G[name2.."ListNamesBox"]:Enable()
			_G[name2.."ListNamesText"]:SetAlpha(1.0)
			_G[name2.."ListNamesOffBox"]:Enable()
			_G[name2.."ListNamesOffText"]:SetAlpha(1.0)
			_G[name2.."ListLevelUpBox"]:Enable()
			_G[name2.."ListLevelUpText"]:SetAlpha(1.0)
			_G[name2.."ListLevelUpOffBox"]:Enable()
			_G[name2.."ListLevelUpOffText"]:SetAlpha(1.0)
			_G[name2.."ListAchievmentsBox"]:Enable()
			_G[name2.."ListAchievmentsText"]:SetAlpha(1.0)
			_G[name2.."ListQuitBox"]:Enable()
			_G[name2.."ListQuitText"]:SetAlpha(1.0)
			_G[name2.."ExtendChatBox"]:Enable()
			_G[name2.."ExtendChatText"]:SetAlpha(1.0)
			_G[name2.."ExtendIgnoredBox"]:Enable()
			_G[name2.."ExtendIgnoredText"]:SetAlpha(1.0)
			_G[name2.."ExtendMainBox"]:Enable()
			_G[name2.."ExtendMainText"]:SetAlpha(1.0)
			_G[name2.."ExtendAliasBox"]:Enable()
			_G[name2.."ExtendAliasText"]:SetAlpha(1.0)
			_G[name2.."AddPostfixBox"]:Enable()
			_G[name2.."AddPostfixText"]:SetAlpha(1.0)
			_G[name2.."ShowWhoSpamBox"]:Enable()
			_G[name2.."ShowWhoSpamText"]:SetAlpha(1.0)
			_G[name3.."SupressGreetBox"]:Enable()
			_G[name3.."SupressGreetText"]:SetAlpha(1.0)
			_G[name3.."SupressJoinBox"]:Enable()
			_G[name3.."SupressJoinText"]:SetAlpha(1.0)
			_G[name3.."SupressLevelBox"]:Enable()
			_G[name3.."SupressLevelText"]:SetAlpha(1.0)
			_G[name3.."SupressRankBox"]:Enable()
			_G[name3.."SupressRankText"]:SetAlpha(1.0)
			_G[name3.."SupressAchievmentBox"]:Enable()
			_G[name3.."SupressAchievmentText"]:SetAlpha(1.0)
			_G[name3.."NoGratsOnLoginBox"]:Enable()
			_G[name3.."NoGratsOnLoginText"]:SetAlpha(1.0)
			_G[name4.."DeltaPopupBox"]:Enable()
			_G[name4.."DeltaPopupText"]:SetAlpha(1.0)
		end
end

------------------------------------------------------------
function GLDG_UpdateListsize(self)
	-- Store the new value
	GLDG_Data.ListSize = self:GetValue()
	-- Update display
	local text = _G[self:GetParent():GetName().."ListsizeText"]
	text:SetText(string.format(L["Display a maximum of %d queued players"], GLDG_Data.ListSize))
	-- Update queue
	GLDG_ShowQueue()
end

------------------------------------------------------------
function GLDG_UpdateChatFrame(self)
	local text = _G[self:GetParent():GetName().."ChatFrameText"]
	if not GLDG_updatingChatFrame and GLDG_Data.PlayerChatFrame[GLDG_Player.."-"..GLDG_Realm] ~= math.floor(self:GetValue()) then
		GLDG_updatingChatFrame = true

		-- Store the new value
		GLDG_Data.PlayerChatFrame[GLDG_Player.."-"..GLDG_Realm] = math.floor(self:GetValue())

		--if (GLDG_Data.ChatFrame > NUM_CHAT_WINDOWS) then
		--	local oldValue = GLDG_Data.ChatFrame
		--	GLDG_Data.ChatFrame = NUM_CHAT_WINDOWS
		--	GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r Chat frame "..oldValue.." does not exist, using chat frame "..GLDG_Data.ChatFrame.." instead")
		--	self:SetValue(GLDG_Data.ChatFrame)
		--end

		-- Update display
		--local text = _G[self:GetParent():GetName().."ChatFrameText"]
		if (GLDG_Data.PlayerChatFrame[GLDG_Player.."-"..GLDG_Realm] == 0) then
			text:SetText(L["Using default chat frame"])
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r Now using default chat frame")
		else
			local name, fontSize, r, g, b, alpha, shown, locked, docked = GetChatWindowInfo(GLDG_Data.PlayerChatFrame[GLDG_Player.."-"..GLDG_Realm])
			text:SetText(string.format(L["Using chat frame %d (%s)"], GLDG_Data.PlayerChatFrame[GLDG_Player.."-"..GLDG_Realm], name))
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r Now using chat frame "..GLDG_Data.PlayerChatFrame[GLDG_Player.."-"..GLDG_Realm].." ("..Ambiguate(name, "guild")..")")
		end

		GLDG_updatingChatFrame = nil
	else
		if (GLDG_Data.PlayerChatFrame[GLDG_Player.."-"..GLDG_Realm] == 0) then
			text:SetText(L["Using default chat frame"])
		else
			local name, fontSize, r, g, b, alpha, shown, locked, docked = GetChatWindowInfo(GLDG_Data.PlayerChatFrame[GLDG_Player.."-"..GLDG_Realm])
			text:SetText(string.format(L["Using chat frame %d (%s)"], GLDG_Data.PlayerChatFrame[GLDG_Player.."-"..GLDG_Realm], name))
		end
	end
end

------------------------------------------------------------

function GLDG_GetNumActiveChatFrames()
        local count = 0;
        local chatFrame;
        for i=1, NUM_CHAT_WINDOWS do
                local _, _, _, _, _, _, shown, locked, docked = GetChatWindowInfo(i);
                chatFrame = _G["ChatFrame"..i];
                if ( chatFrame ) then
                        if ( shown or chatFrame.isDocked ) then
                                count = count + 1;
                        end
                end
        end
        return count;
end

------------------------------------------------------------

function GLDG_DropDownTemplate_OnLoad(self)
	UIDropDownMenu_Initialize(self, GLDG_DropDown_Initialize);
	UIDropDownMenu_SetWidth(self, 150);
end

------------------------------------------------------------
function GLDG_DropDownTemplate_OnShow(self)
	UIDropDownMenu_Initialize(self, GLDG_DropDown_Initialize);
end

------------------------------------------------------------
function GLDG_DropDown_Initialize()

	GLDG_dropDownData = {}

	local info
	info = UIDropDownMenu_CreateInfo();
	info.func = GLDG_DropDown_OnClick
	local j = 1

	for i = 0, 10 do
		local id, name = GetChannelName(i)
		if (i==0 or id>0 and name) then
			if (i==0) then
				name = L["<none>"]
			end

			info.checked = nil
			info.text = name
			UIDropDownMenu_AddButton(info);
			GLDG_dropDownData[j] = string.lower(name)
			if (string.lower(name) == GLDG_ChannelName) or
			   (name == L["<none>"] and GLDG_ChannelName=="") then
				UIDropDownMenu_SetSelectedID(_G[GLDG_GUI.."SettingsGeneral".."ChannelNameDropboxButton"], j);
			end
			j = j + 1
		end
	end
end

------------------------------------------------------------
function GLDG_DropDown_OnClick(self)

	if not GLDG_dropDownData then GLDG_dropDownData = {} end
	local i = self:GetID();
	local name = GLDG_dropDownData[i]
	if not name then name = "" end
	if name == L["<none>"] then name = "" end
	name = string.lower(name)

	local oldChannelName = GLDG_ChannelName
	GLDG_ChannelName = name;
	if (GLDG_ChannelName == "") then
		GLDG_inChannel = false
	else
		if GLDG_CheckChannel() then
			UIDropDownMenu_SetSelectedID(_G[GLDG_GUI.."SettingsGeneral".."ChannelNameDropboxButton"], i);
		else
			GLDG_ChannelName = oldChannelName
			if GLDG_CheckChannel() then
				GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r Channel ["..GLDG_ChannelName.."] does not exist, setting back to ["..oldChannelName.."]")
			else
				GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r Channel ["..GLDG_ChannelName.."] does not exist, nor does the previous channel ["..oldChannelName.."], clearing channel name")
				UIDropDownMenu_SetSelectedID(_G[GLDG_GUI.."SettingsGeneral".."ChannelNameDropboxButton"], 1);
				GLDG_ChannelName = ""
				GLDG_inChannel = false
			end
		end
	end

	-- store new channel name
	if not GLDG_Data.ChannelNames[GLDG_Realm.." - "..GLDG_Player] then
		GLDG_Data.ChannelNames[GLDG_Realm.." - "..GLDG_Player] = ""
	end
	-- set channel name pointer
	GLDG_Data.ChannelNames[GLDG_Realm.." - "..GLDG_Player] = GLDG_ChannelName
end

------------------------------------------------------------
function GLDG_SupressAll()
	GLDG_Data.GuildSettings.SupressGreet = true
	GLDG_Data.GuildSettings.SupressJoin = true
	GLDG_Data.GuildSettings.SupressLevel = true
	GLDG_Data.GuildSettings.SupressRank = true
	GLDG_Data.GuildSettings.SupressAchievment = true

	GLDG_UpdateSupressed()
end

------------------------------------------------------------
function GLDG_SupressNone()
	GLDG_Data.GuildSettings.SupressGreet = false
	GLDG_Data.GuildSettings.SupressJoin = false
	GLDG_Data.GuildSettings.SupressLevel = false
	GLDG_Data.GuildSettings.SupressRank = false
	GLDG_Data.GuildSettings.SupressAchievment = false

	GLDG_UpdateSupressed()
end

------------------------------------------------------------
function GLDG_UpdateSupressed()
	local name = GLDG_GUI.."SettingsGreeting";
	_G[name.."SupressGreetBox"]:SetChecked(GLDG_Data.GuildSettings.SupressGreet)
	_G[name.."SupressJoinBox"]:SetChecked(GLDG_Data.GuildSettings.SupressJoin)
	_G[name.."SupressLevelBox"]:SetChecked(GLDG_Data.GuildSettings.SupressLevel)
	_G[name.."SupressRankBox"]:SetChecked(GLDG_Data.GuildSettings.SupressRank)
	_G[name.."SupressAchievmentBox"]:SetChecked(GLDG_Data.GuildSettings.SupressAchievment)
end

-------------------------------
-- _13_ Greetings Tab Update --
-------------------------------

function GLDG_ShowCollections(frame)
	if not frame then return end
	-- Update scrollbar
	local bar = _G[frame.."Collectbar"]
	FauxScrollFrame_Update(bar, GLDG_TableSize(GLDG_Data.Collections), GLDG_NumColRows, 15)
	local offset = FauxScrollFrame_GetOffset(bar)
	-- Sort the list of existing custom collections
	local sorted = {}
	local total = 0
	for col in pairs(GLDG_Data.Collections) do
		-- Look for the position in the list we need
		local loc = 1
		while sorted[loc] and (sorted[loc] < col) do loc = loc + 1 end
		-- We found the position: move everything beyond it
		for cnt = total, loc, -1 do sorted[cnt+1] = sorted[cnt] end
		-- Insert the collection
		total = total + 1
		sorted[loc] = col end
	-- Show the collections visible
	for i = 1, GLDG_NumColRows do
		_G[frame.."Collect"..i]:UnlockHighlight()
		if sorted[i + offset] then
			_G[frame.."Collect"..i.."Text"]:SetText(sorted[i + offset])
			_G[frame.."Collect"..i]:Enable()
			if GLDG_SelColName and (GLDG_SelColName == sorted[i + offset]) then _G[frame.."Collect"..i]:LockHighlight() end
		else	_G[frame.."Collect"..i.."Text"]:SetText("")
			_G[frame.."Collect"..i]:Disable() end end
	-- Set buttons and text depending the selected collection
	local colhead = L["Global defaults"]
	if GLDG_SelColName then
		_G[frame.."ColNewDel"]:SetText(L["Remove selection"])
		colhead = string.format(L["Collection %q"], GLDG_SelColName)
	else 	_G[frame.."ColNewDel"]:SetText(L["Create new collection"]) end
	_G[frame.."GreetHeader"]:SetText(string.format(L["%s : select the greeting category you want to edit"], colhead))
end

------------------------------------------------------------
function GLDG_ShowGreetings(frame)
	-- Show messages from selected category
	local list = GLDG_Data[GLDG_Selection]
	if GLDG_SelColName then
		list = GLDG_Data.Collections[GLDG_SelColName][GLDG_Selection]
		-- check to catch error reported by Baraknor
		if (list == nil) then
			GLDG_Data.Collections[GLDG_SelColName][GLDG_Selection] = {}
			list = GLDG_Data.Collections[GLDG_SelColName][GLDG_Selection]
		end
	end
	local cnt = 1
	local line = frame.."Line"
	while list[cnt + GLDG_GreetOffset] and _G[line..cnt] do
		_G[line..cnt.."Text"]:SetText(list[cnt + GLDG_GreetOffset])
		_G[line..cnt]:Enable()
		cnt = cnt + 1 end
	while _G[line..cnt] do
		_G[line..cnt.."Text"]:SetText("")
		_G[line..cnt]:Disable()
		cnt = cnt + 1 end
	-- Set highlight
	for cnt = 1, GLDG_NumSelRows do
		if GLDG_SelMsgNum and (GLDG_SelMsgNum == GLDG_GreetOffset + cnt) then _G[line..cnt]:LockHighlight()
		else _G[line..cnt]:UnlockHighlight() end end
	-- Set editbox
	if GLDG_SelMsgNum and list[GLDG_SelMsgNum] then _G[frame.."Editbox"]:SetText(list[GLDG_SelMsgNum])
	else _G[frame.."Editbox"]:SetText("") end
	-- Set editbox buttons
	if GLDG_SelMsgNum then
		_G[frame.."MsgAdd"]:SetText(GLDG_TXT.update)
		_G[frame.."MsgDel"]:SetText(GLDG_TXT.delete)
	else	_G[frame.."MsgAdd"]:SetText(GLDG_TXT.add)
		_G[frame.."MsgDel"]:SetText(GLDG_TXT.clear) end
end

------------------------------------------------------------
function GLDG_ShowCustom(frame)
	-- Display the current values
	local d = GLDG_Data.Custom[GLDG_Realm]
	if d and (d ~= "") and not GLDG_Data.Collections[d] then
		-- Collection no longer exists
		GLDG_Data.Custom[GLDG_Realm] = nil
		d = nil end
	local f = _G[frame.."SubCustomRealm"]
	if not d then f:SetText(L["not defined"])
	elseif (d == "") then f:SetText(L["Global defaults"])
	else f:SetText(d) end
	d = GLDG_Data.Custom[GLDG_unique_GuildName]
	if d and (d ~= "") and not GLDG_Data.Collections[d] then
		-- Collection no longer exists
		GLDG_Data.Custom[GLDG_unique_GuildName] = nil
		d = nil end
	f = _G[frame.."SubCustomGuild"]
	if not d then f:SetText(L["not defined"])
	elseif (d == "") then f:SetText(L["Global defaults"])
	else f:SetText(d) end
	d = GLDG_Data.Custom[GLDG_Realm.."-"..UnitName("player")]
	if d and (d ~= "") and not GLDG_Data.Collections[d] then
		-- Collection no longer exists
		GLDG_Data.Custom[GLDG_Realm.."-"..UnitName("player")] = nil
		d = nil end
	f = _G[frame.."SubCustomChar"]
	if not d then f:SetText(L["not defined"])
	elseif (d == "") then f:SetText(L["Global defaults"])
	else f:SetText(d) end
	-- Set greetings section pointer at is possibly changed
	if GLDG_InitGreet(GLDG_Realm.."-"..UnitName("player")) and
	   GLDG_InitGreet(GLDG_unique_GuildName) and
	   GLDG_InitGreet(GLDG_Realm) then
		-- No custom collections are used
		GLDG_DataGreet = GLDG_Data end
	-- Show the frame
	GLDG_ColButtonPressed(frame)
	_G[frame.."SubCustom"]:Show()
end

------------------------------------------------------------
function GLDG_ClickCollection(self, col)
	-- Set new selected collection
	if GLDG_SelColName and (GLDG_SelColName == col) then GLDG_SelColName = nil
	else GLDG_SelColName = col end
	-- Update change selection button
	local button = _G[self:GetParent():GetName().."SubChangeSelection"]
	if GLDG_SelColName then button:Enable() else button:Disable() end
	-- Refresh display
	GLDG_ShowCollections()
	GLDG_ShowGreetings(self:GetParent():GetName())
end

------------------------------------------------------------
function GLDG_ColButtonPressed(frame)
	-- Enable all collections buttons
	_G[frame.."ColNewDel"]:Enable()
	_G[frame.."ColRealm"]:Enable()
	_G[frame.."ColGuild"]:Enable()
	_G[frame.."ColPlayer"]:Enable()
	-- Hide all subframes
	_G[frame.."SubCustom"]:Hide()
	_G[frame.."SubNew"]:Hide()
	_G[frame.."SubChange"]:Hide()
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
	GLDG_ChangeName = GLDG_Realm
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
function GLDG_ClickGreetButton(self, id)
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

------------------------------------------------------------
function GLDG_ClickGreetScrollBar(self, frame)
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

------------------------------------------------------------
function GLDG_ClickGreeting(self, id)
	-- Set new selected message
	if GLDG_SelMsgNum and (GLDG_SelMsgNum == GLDG_GreetOffset + id) then GLDG_SelMsgNum = nil
	else GLDG_SelMsgNum = GLDG_GreetOffset + id end
	-- Refresh greetings list
	GLDG_ShowGreetings(self:GetParent():GetName())
end

------------------------------------------------------------
function GLDG_ClickGreetAdd(self, frame)
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

------------------------------------------------------------
function GLDG_ClickGreetRemove(self, frame)
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


-----------------------------
-- _14_ Players Tab Update --
-----------------------------

function GLDG_SortString(player)
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

------------------------------------------------------------
function GLDG_ListPlayers()
	-- Abort if addon is not initialized
	if not GLDG_DataChar then return end
	-- Check if there is a reason to clear the selected player
	if GLDG_SelPlrName then
		if (not GLDG_DataChar[GLDG_SelPlrName]) or
		   (GLDG_DataChar[GLDG_SelPlrName].ignore and GLDG_Data.ShowIgnore==false) then
			GLDG_SelPlrName = nil end end
	-- Prepare for list creation
	GLDG_SortedList = {}
	local total = 0
	GLDG_NumMain = 0
	GLDG_NumAlts = 0
	local s = {}
	if GLDG_SelPlrName then s = GLDG_DataChar[GLDG_SelPlrName] end
	-- Create the list of players to display
	for player in pairs(GLDG_DataChar) do
		local p = GLDG_DataChar[player]
		if ((not p.own) or GLDG_Data.GuildSettings.IncludeOwn==true) then
			-- Update counters for main and alt
			if p.main then GLDG_NumMain = GLDG_NumMain + 1 end
			if p.alt and (p.alt == GLDG_SelPlrName) then GLDG_NumAlts = GLDG_NumAlts + 1 end
			-- See if we are supposed to add this player in our list
			local show = GLDG_Data.ShowIgnore or not p.ignore
			show = show and ((p.alt == GLDG_SelPlrName) or (p.alt == s.alt) or not p.alt or GLDG_Data.ShowAlt)
			show = show and (((not p.alt) and (not p.main)) or not GLDG_Data.FilterUnassigned)
			show = show and ((p.guild and p.guild == GLDG_Data.GuildFilter) or GLDG_Data.GuildFilter=="")
			show = show and ((p.rankname and p.rankname == GLDG_Data.RankFilter) or GLDG_Data.RankFilter=="")
			show = show and (p.enClass and GLDG_Data[p.enClass.."Filter"] == true)
			show = show and (GLDG_Online[player] or not GLDG_Data.FilterOnline)
			show = show and ((p.friends and p.friends[GLDG_Player]) or not GLDG_Data.FilterMyFriends)
			show = show and (p.friends or not GLDG_Data.FilterWithFriends)
			show = show and ((p.channels and p.channels[GLDG_ChannelName]) or not GLDG_Data.FilterCurrentChannel)
			show = show and (p.channels or not GLDG_Data.FilterWithChannel)
			if show then
				-- Look for the position in the list we need
				local loc = 1
				while GLDG_SortedList[loc] and (GLDG_SortString(player) > GLDG_SortString(GLDG_SortedList[loc])) do loc = loc + 1 end
				-- We found our position: move everything beyond it
				for cnt = total, loc, -1 do
					GLDG_SortedList[cnt + 1] = GLDG_SortedList[cnt]
				end
				-- Insert our player
				total = total + 1
				GLDG_SortedList[loc] = player
			end
		end
	end
	-- Update the scrollbar
	GLDG_ClickPlayerBar() -- todo bee
end

-- todo: this does not yet work on multiple levels, need to learn how to do this
--[[
UIDropDownMenu_AddButton(info, level)
...
local listFrame = _G["DropDownList"..level];
local listFrameName = listFrame:GetName();
local index = listFrame.numButtons + 1;
local width;

local menuName = UIDROPDOWNMENU_OPEN_MENU;
if ( not menuName ) then menuName = "<nil>"; end

-- If too many buttons error out
if ( index > UIDROPDOWNMENU_MAXBUTTONS ) then
_ERRORMESSAGE("Too many buttons in UIDropDownMenu: "..menuName);
return;
end

-- If too many levels error out
if ( level > UIDROPDOWNMENU_MAXLEVELS ) then
_ERRORMESSAGE("Too many levels in UIDropDownMenu: "..menuName);
return;
end
]]

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

	GLDG_guildFilterDropDownData = {}

	if (not GLDG_DataChar) then return end

	local count = 1
	GLDG_guildFilterDropDownData[count] = GLDG_TXT.noGuildFilter
	count = count + 1
	GLDG_guildFilterDropDownData[count] = " " -- separator
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].guild and GLDG_DataChar[p].guild ~= "") then
			local loc = 3
			while GLDG_guildFilterDropDownData[loc] and (GLDG_guildFilterDropDownData[loc] < GLDG_DataChar[p].guild) do
				loc = loc + 1
			end
			if (GLDG_guildFilterDropDownData[loc] ~= GLDG_DataChar[p].guild) then
				for cnt = count, loc, -1 do
					GLDG_guildFilterDropDownData[cnt + 1] = GLDG_guildFilterDropDownData[cnt]
				end
				count = count + 1
				GLDG_guildFilterDropDownData[loc] = GLDG_DataChar[p].guild
				--GLDG_Print("Added guild ["..GLDG_DataChar[p].guild.."] at position ["..tostring(loc).."] - count is ["..tostring(count).."]")
			end
		end
	end

	local info

	found = false
	local level = 1
	count = 0
	for q in pairs(GLDG_guildFilterDropDownData) do
		info = UIDropDownMenu_CreateInfo();
		info.func = GLDG_GuildFilterDropDown_OnClick
		info.notCheckable = nil
		info.notClickable = nil
		info.checked = nil
		info.text = GLDG_guildFilterDropDownData[q]
		if (GLDG_Data.GuildFilter and GLDG_guildFilterDropDownData[q] == GLDG_Data.GuildFilter) then
			found = true
			info.checked = true
			--GLDG_Print("Match on entry ["..tostring(q).."] - count "..tostring(count).." - level "..tostring(level))
		end
		if (info.text == " ") then
			info.notCheckable = true
			info.notClickable = true
			--GLDG_Print("Making unclickable")
		end
		UIDropDownMenu_AddButton(info, level)
		if (GLDG_Data.GuildFilter and GLDG_guildFilterDropDownData[q] == GLDG_Data.GuildFilter) then
			UIDropDownMenu_SetSelectedID(_G[GLDG_GUI.."Players".."GuildFilterDropboxButton"], q);
			--GLDG_Print("Selecting entry ["..tostring(q).."] - frame ["..GLDG_GUI.."Players".."GuildFilterDropboxButton]")
		end

		count = count + 1
		if (count == 20) then
			info = UIDropDownMenu_CreateInfo();
			info.func = GLDG_GuildFilterDropDown_OnClick
			info.checked = nil
			info.notCheckable = nil
			info.notClickable = nil
			info.hasArrow = true
			info.text = "More"
			UIDropDownMenu_AddButton(info, level)
			info.hasArrow = false

			count = 0
			level = level + 1
			--GLDG_Print("Increased level to ["..tostring(level).."]")
		end
	end
	if not found then
		UIDropDownMenu_SetSelectedID(_G[GLDG_GUI.."Players".."GuildFilterDropboxButton"], 1);
	end
end

------------------------------------------------------------
function GLDG_GuildFilterDropDown_OnClick(self, list)

	if not GLDG_guildFilterDropDownData then GLDG_guildFilterDropDownData = {} end
	local i = self:GetID();
	local n = self:GetParent():GetID()
	local name = self:GetName()
	GLDG_Data.GuildFilter = GLDG_guildFilterDropDownData[(n-1)*20 + i]
	if not GLDG_Data.GuildFilter then GLDG_Data.GuildFilter = "" end
	if GLDG_Data.GuildFilter == GLDG_TXT.noGuildFilter then GLDG_Data.GuildFilter = "" end

	if (GLDG_Data.GuildFilter == "") then
		UIDropDownMenu_SetText(_G[GLDG_GUI.."Players".."RankFilterDropboxButton"], GLDG_TXT.noRankFilter)
		GLDG_Data.RankFilter = "";
		UIDropDownMenu_SetSelectedID(_G[GLDG_GUI.."Players".."GuildFilterDropboxButton"], 1);
	else
		UIDropDownMenu_SetSelectedID(_G[GLDG_GUI.."Players".."GuildFilterDropboxButton"], i);
		UIDropDownMenu_SetText(_G[GLDG_GUI.."Players".."RankFilterDropboxButton"], GLDG_TXT.noRankFilter)
		GLDG_Data.RankFilter = "";
	end

	--GLDG_Print("Chose ["..tostring(GLDG_Data.GuildFilter).."] from ["..tostring(name).."]["..tostring(n).."]["..tostring(i).."]")

	-- list players
	GLDG_ListPlayers()
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

	GLDG_rankFilterDropDownData = {}

	if (not GLDG_DataChar) then return end

	local count = 1
	GLDG_rankFilterDropDownData[count] = GLDG_TXT.noRankFilter
	count = count + 1
	GLDG_rankFilterDropDownData[count] = " " -- separator
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].rankname and GLDG_DataChar[p].rankname ~= "") and (GLDG_DataChar[p].guild and GLDG_DataChar[p].guild == GLDG_Data.GuildFilter) then
			local loc = 3
			while GLDG_rankFilterDropDownData[loc] and (GLDG_rankFilterDropDownData[loc] < GLDG_DataChar[p].rankname) do
				loc = loc + 1
			end
			if (GLDG_rankFilterDropDownData[loc] ~= GLDG_DataChar[p].rankname) then
				for cnt = count, loc, -1 do
					GLDG_rankFilterDropDownData[cnt + 1] = GLDG_rankFilterDropDownData[cnt]
				end
				count = count + 1
				GLDG_rankFilterDropDownData[loc] = GLDG_DataChar[p].rankname
				--GLDG_Print("Added guild ["..GLDG_DataChar[p].guild.."] at position ["..tostring(loc).."] - count is ["..tostring(count).."]")
			end
		end
	end

	local info

	found = false
	local level = 1
	count = 0
	for q in pairs(GLDG_rankFilterDropDownData) do
		info = UIDropDownMenu_CreateInfo();
		info.func = GLDG_RankFilterDropDown_OnClick
		info.notCheckable = nil
		info.notClickable = nil
		info.checked = nil
		info.text = GLDG_rankFilterDropDownData[q]
		if (GLDG_Data.RankFilter and GLDG_rankFilterDropDownData[q] == GLDG_Data.RankFilter) then
			found = true
			info.checked = true
			--GLDG_Print("Match on entry ["..tostring(q).."] - count "..tostring(count).." - level "..tostring(level))
		end
		if (info.text == " ") then
			info.notCheckable = true
			info.notClickable = true
			--GLDG_Print("Making unclickable")
		end
		UIDropDownMenu_AddButton(info, level)
		if (GLDG_Data.RankFilter and GLDG_rankFilterDropDownData[q] == GLDG_Data.RankFilter) then
			UIDropDownMenu_SetSelectedID(_G[GLDG_GUI.."Players".."RankFilterDropboxButton"], q);
			--GLDG_Print("Selecting entry ["..tostring(q).."] - frame ["..GLDG_GUI.."Players".."GuildFilterDropboxButton]")
		end

		count = count + 1
		if (count == 20) then
			info = UIDropDownMenu_CreateInfo();
			info.func = GLDG_RankFilterDropDown_OnClick
			info.checked = nil
			info.notCheckable = nil
			info.notClickable = nil
			info.hasArrow = true
			info.text = "More"
			UIDropDownMenu_AddButton(info, level)
			info.hasArrow = false

			count = 0
			level = level + 1
			--GLDG_Print("Increased level to ["..tostring(level).."]")
		end
	end
	if not found then
		UIDropDownMenu_SetSelectedID(_G[GLDG_GUI.."Players".."RankFilterDropboxButton"], 1);
	end
end

------------------------------------------------------------
function GLDG_RankFilterDropDown_OnClick(self, list)

	if not GLDG_rankFilterDropDownData then GLDG_rankFilterDropDownData = {} end
	local i = self:GetID();
	local n = self:GetParent():GetID()
	local name = self:GetName()
	GLDG_Data.RankFilter = GLDG_rankFilterDropDownData[(n-1)*20 + i]
	if not GLDG_Data.RankFilter then GLDG_Data.RankFilter = "" end
	if GLDG_Data.RankFilter == GLDG_TXT.noRankFilter then GLDG_Data.RankFilter = "" end

	if (GLDG_Data.RankFilter == "") then
		UIDropDownMenu_SetSelectedID(_G[GLDG_GUI.."Players".."RankFilterDropboxButton"], 1);
	else
		UIDropDownMenu_SetSelectedID(_G[GLDG_GUI.."Players".."RankFilterDropboxButton"], i);
	end

	--GLDG_Print("Chose ["..tostring(GLDG_Data.GuildFilter).."] from ["..tostring(name).."]["..tostring(n).."]["..tostring(i).."]")

	-- list players
	GLDG_ListPlayers()
end


------------------------------------------------------------
function GLDG_ShowPlayers()
	-- Display the players visible in the frame
	local cnt = 1
	local line = GLDG_GUI.."PlayersLine"
	while GLDG_SortedList[cnt + GLDG_PlayerOffset] and _G[line..cnt] do
		local textName = _G[line..cnt.."Name"]
		local textType = _G[line..cnt.."Type"]
		local textAlias = _G[line..cnt.."Alias"]
		local textMain = _G[line..cnt.."Main"]
		local textGuild = _G[line..cnt.."Guild"]
		local textRankname = _G[line..cnt.."Rankname"]
		local textPnote = _G[line..cnt.."Pnote"]
		local textOnote = _G[line..cnt.."Onote"]
		local textChannel = _G[line..cnt.."Channel"]
		local textFriend = _G[line..cnt.."Friend"]
		local textNumFriends = _G[line..cnt.."NumFriends"]
		local p = GLDG_DataChar[GLDG_SortedList[cnt + GLDG_PlayerOffset]]

		if GLDG_Online[GLDG_SortedList[cnt + GLDG_PlayerOffset]] then
			textName:SetText("*"..GLDG_SortedList[cnt + GLDG_PlayerOffset])
		else
			textName:SetText(GLDG_SortedList[cnt + GLDG_PlayerOffset])
		end
		textType:SetText("")
		if p.guild then
			textGuild:SetText(p.guild)
		else
			textGuild:SetText("---")
		end
		if p.ignore then
			textGuild:SetTextColor(1, 0.25, 0.25)
			textType:SetText(GLDG_TXT.markIGN)
		elseif p.main then
			textGuild:SetTextColor(0.25, 1, 0.25)
			textType:SetText(GLDG_TXT.markMAIN)
		elseif p.alt then
			--textName:SetTextColor(0.25, 0.25, 1)
			textGuild:SetTextColor(0.25, 1, 1)
			textType:SetText(GLDG_TXT.markALT)
		elseif p.alias then
			textGuild:SetTextColor(0.68, 0.8, 1)
		else
			textGuild:SetTextColor(1, 1, 1)
		end
		if p.enClass then
			textName:SetTextColor(RAID_CLASS_COLORS[p.enClass].r, RAID_CLASS_COLORS[p.enClass].g, RAID_CLASS_COLORS[p.enClass].b)
		end
		if p.alias then
			textAlias:SetText(p.alias)
			textMain:SetText("")
		elseif (GLDG_Data.GuildSort==true or GLDG_Data.GroupAlt==false or GLDG_Data.FilterOnline==true) and p.alt and GLDG_DataChar[p.alt] and GLDG_DataChar[p.alt].alias then
			textAlias:SetText("")
			textMain:SetText(GLDG_DataChar[p.alt].alias)
		elseif (GLDG_Data.GuildSort==true or GLDG_Data.GroupAlt==false or GLDG_Data.FilterOnline==true) and p.alt then
			textAlias:SetText("")
			textMain:SetText(p.alt)
		else
			textAlias:SetText("---")
			textMain:SetText("")
		end
		if p.rankname then
			textRankname:SetText(p.rankname)
		else
			textRankname:SetText("---")
		end
		if p.pNote then
			textPnote:SetText(p.pNote)
		else
			textPnote:SetText("")
		end
		if p.oNote then
			textOnote:SetText(p.oNote)
		else
			textOnote:SetText("")
		end
		if p.channels and p.channels[GLDG_ChannelName] then
			textChannel:SetText("{c}")
		else
			textChannel:SetText("---")
		end
		if p.friends then
			if p.friends[GLDG_Player] then
				textFriend:SetText("{f}")
			else
				textFriend:SetText("---")
			end
			textNumFriends:SetText(tostring(GLDG_TableSize(p.friends)))
		else
			textNumFriends:SetText("0")
 			textFriend:SetText("---")
		end

		textType:SetTextColor(textGuild:GetTextColor())
		textAlias:SetTextColor(textGuild:GetTextColor())
		textMain:SetTextColor(textGuild:GetTextColor())
		textRankname:SetTextColor(textGuild:GetTextColor())
		textPnote:SetTextColor(textGuild:GetTextColor())
		textOnote:SetTextColor(textGuild:GetTextColor())
		textChannel:SetTextColor(textGuild:GetTextColor())
		textFriend:SetTextColor(textGuild:GetTextColor())
		textNumFriends:SetTextColor(textGuild:GetTextColor())
		_G[line..cnt]:Enable()
		cnt = cnt +1 end
	-- Disable any rows left unused
	for cnt2 = cnt, GLDG_NumPlrRows do
		_G[line..cnt2.."Name"]:SetText("")
		_G[line..cnt2.."Type"]:SetText("")
		_G[line..cnt2.."Alias"]:SetText("")
		_G[line..cnt2.."Main"]:SetText("")
		_G[line..cnt2.."Guild"]:SetText("")
		_G[line..cnt2.."Rankname"]:SetText("")
		_G[line..cnt2.."Pnote"]:SetText("")
		_G[line..cnt2.."Onote"]:SetText("")
		_G[line..cnt2.."Channel"]:SetText("")
		_G[line..cnt2.."Friend"]:SetText("")
		_G[line..cnt2.."NumFriends"]:SetText("")
		_G[line..cnt2]:Disable()
	end
	-- Set/clear highlight
	for cnt = 1, GLDG_NumPlrRows do
		if GLDG_SelPlrName and (GLDG_SortedList[cnt + GLDG_PlayerOffset] == GLDG_SelPlrName) then
			_G[line..cnt]:LockHighlight()
		else
			_G[line..cnt]:UnlockHighlight()
		end
	end
	-- Update buttons
	GLDG_ShowPlayerButtons()
end

------------------------------------------------------------
function GLDG_ShowPlayerToolTip(element)
	if not element then return end

	local name = _G[element.."Name"]:GetText()

	if (string.sub(name, 1, 1)=="*") then
		name = string.sub(name, 2)
	end
	local color_s = ""
	local color_p = ""
	if (name and GLDG_DataChar[name]) then
		color_s = ""
		color_p = ""
		if GLDG_DataChar[name].enClass then
			color_s = "|c"..RAID_CLASS_COLORS[GLDG_DataChar[name].enClass].colorStr
			color_p = "|r"
		end
		local p = GLDG_DataChar[name]
		local head = color_s..name..color_p
		if p.alias then
			head = head..GLDG_ALIAS_COLOUR.." ("..p.alias..")|r"
		end

		GameTooltip:SetOwner(_G[element], "ANCHOR_CURSOR")
		GameTooltip:SetText(head, 1, 1, 0.5, 1.0, 1)

		if p.guild then
			if p.guild==GLDG_unique_GuildName then
				GameTooltip:AddLine("<"..GLDG_GuildName..">", 1, 1, 0.75)
			else
				GameTooltip:AddLine("<"..p.guild..">", 1, 1, 0.75)
			end
		end
		if p.ignore then
			GameTooltip:AddLine(GLDG_TXT.tipIgnore, 1, 0, 0)
		end

		GameTooltip:AddLine(" ", 1, 1, 0.75)

		local added = false

		if p.alias then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipAlias, GLDG_ALIAS_COLOUR..p.alias.."|r", 1, 1, 0, 1, 1, 1)
			added = true
		end

		if p.main then
			local hasAlts = false
			local first = true
			for q in pairs(GLDG_DataChar) do
				if GLDG_DataChar[q].alt and GLDG_DataChar[q].alt == name then
					color_s = ""
					color_p = ""
					if GLDG_DataChar[q].enClass then
						color_s = "|c"..RAID_CLASS_COLORS[GLDG_DataChar[q].enClass].colorStr
						color_p = "|r"
					end
					if first then
						first = false
						GameTooltip:AddDoubleLine(GLDG_TXT.tipAlts, color_s..Ambiguate(q, "guild")..color_p, 1, 1, 0, 1, 1, 1)
					else
						GameTooltip:AddDoubleLine(" ", color_s..Ambiguate(q, "guild")..color_p, 1, 1, 0, 1, 1, 1)
					end
					added = true
					hasAlts = true
				end
			end
			if not hasAlts then
				GameTooltip:AddDoubleLine(GLDG_TXT.tipMain, GLDG_TXT.tipMainYes, 1, 1, 0, 1, 1, 1)
			end
		elseif p.alt then
			color_s = ""
			color_p = ""
			if GLDG_DataChar[p.alt].enClass then
				color_s = "|c"..RAID_CLASS_COLORS[GLDG_DataChar[p.alt].enClass].colorStr
				color_p = "|r"
			end
			if (GLDG_DataChar[p.alt] and GLDG_DataChar[p.alt].alias) then
				GameTooltip:AddDoubleLine(GLDG_TXT.tipMain, color_s..Ambiguate(p.alt, "guild")..color_p.." "..GLDG_ALIAS_COLOUR.."("..GLDG_DataChar[p.alt].alias..")|r", 1, 1, 0, 1, 1, 1)
			else
				GameTooltip:AddDoubleLine(GLDG_TXT.tipMain, color_s..Ambiguate(p.alt, "guild")..color_p, 1, 1, 0, 1, 1, 1)
			end
			local first = true
			for q in pairs(GLDG_DataChar) do
				if GLDG_DataChar[q].alt and GLDG_DataChar[q].alt == p.alt and q ~= name then
					color_s = ""
					color_p = ""
					if GLDG_DataChar[q].enClass then
						color_s = "|c"..RAID_CLASS_COLORS[GLDG_DataChar[q].enClass].colorStr
						color_p = "|r"
					end
					if first then
						first = false
						GameTooltip:AddDoubleLine(GLDG_TXT.tipAlts, color_s..Ambiguate(q, "guild")..color_p, 1, 1, 0, 1, 1, 1)
						added = true
					else
						GameTooltip:AddDoubleLine(" ", color_s..Ambiguate(q, "guild")..color_p, 1, 1, 0, 1, 1, 1)
						added = true
					end
				end
			end
		end

		if added then
			GameTooltip:AddLine(" ", 1, 1, 0.75)
			added = false
		end

		if p.guild then
			if p.guild==GLDG_unique_GuildName then
				GameTooltip:AddDoubleLine(GLDG_TXT.tipGuild, GLDG_GuildName, 1, 1, 0, 1, 1, 1)
			else
				GameTooltip:AddDoubleLine(GLDG_TXT.tipGuild, p.guild, 1, 1, 0, 1, 1, 1)
			end
			added = true
			if p.new then
				GameTooltip:AddDoubleLine(" ", GLDG_TXT.tipNew, 1, 1, 0, 1, 1, 1)
			end
		end
		if p.rank and p.rankname then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipRank, p.rankname.." ("..tostring(p.rank)..")", 1, 1, 0, 1, 1, 1)
			added = true
		elseif p.rank then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipRank, tostring(p.rank), 1, 1, 0, 1, 1, 1)
			added = true
		elseif p.rankname then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipRank, p.rankname, 1, 1, 0, 1, 1, 1)
			added = true
		end
		if (p.rank or p.rankname) and p.newrank then
			GameTooltip:AddDoubleLine(" ", GLDG_TXT.tipNewRank, 1, 1, 0, 1, 1, 1)
			added = true
		end
		if p.pNote then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipPlayerNote, p.pNote, 1, 1, 0, 1, 1, 1)
			added = true
		end
		if p.oNote then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipOfficerNote, p.oNote, 1, 1, 0, 1, 1, 1)
			added = true
		end

		if p.class then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipClass, p.class, 1, 1, 0, 1, 1, 1)
			added = true
		end
		if p.storedLvl then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipLevel, p.storedLvl, 1, 1, 0, 1, 1, 1)
			added = true
		elseif p.lvl then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipLevel, p.lvl, 1, 1, 0, 1, 1, 1)
			added = true
		end
		if p.achievment then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipAchievment, p.achievment, 1, 1, 0, 1, 1, 1)
			added = true
		end

		if added then
			GameTooltip:AddLine(" ", 1, 1, 0.75)
			added = false
		end

		if p.channels then
			local first = true
			for q in pairs(p.channels) do
				if first then
					first = false
					GameTooltip:AddDoubleLine(GLDG_TXT.tipChannels, q, 1, 1, 0, 1, 1, 1)
					added = true
				else
					GameTooltip:AddDoubleLine(" ", q, 1, 1, 0, 1, 1, 1)
					added = true
				end
			end
		end
		if p.friends then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipFriends, GLDG_TableSize(p.friends), 1, 1, 0, 1, 1, 1)
			for q in pairs(p.friends) do
				if p.friends[q] ~= "" then
					GameTooltip:AddDoubleLine(" ", q.." (|cFFFFFFBF"..p.friends[q].."|r)", 1, 1, 0, 1, 1, 1)	-- show friends note
				else
					GameTooltip:AddDoubleLine(" ", q, 1, 1, 0, 1, 1, 1)
				end
				added = true
			end
		end

		if added then
			GameTooltip:AddLine(" ", 1, 1, 0.75)
			added = false
		end

		if p.last then
			color_s = ""
			color_p = ""
			if GLDG_DataChar[p.last].enClass then
				color_s = "|c"..RAID_CLASS_COLORS[GLDG_DataChar[p.last].enClass].colorStr
				color_p = "|r"
			end		
			GameTooltip:AddDoubleLine(GLDG_TXT.tipLast, color_s..Ambiguate(p.last, "guild")..color_p, 1, 1, 0, 1, 1, 1)
			added = true
		elseif p.alt and GLDG_DataChar[p.alt].last then
			color_s = ""
			color_p = ""
			if GLDG_DataChar[p.alt].enClass then
				color_s = "|c"..RAID_CLASS_COLORS[GLDG_DataChar[GLDG_DataChar[p.alt].last].enClass].colorStr
				color_p = "|r"
			end	
			GameTooltip:AddDoubleLine(GLDG_TXT.tipLast, color_s..Ambiguate(GLDG_DataChar[p.alt].last..color_p, "guild"), 1, 1, 0, 1, 1, 1)
			added = true
		end

		if GLDG_Online[name] then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipOnline, GLDG_TXT.tipOnlineYes, 1, 1, 0, 1, 1, 1)
			added = true
		end
		if GLDG_Offline[name] then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipOffline, GLDG_Offline[name], 1, 1, 0, 1, 1, 1)
			added = true
		end
		if GLDG_Queue[name] then
			GameTooltip:AddDoubleLine(GLDG_TXT.tipQueue, GLDG_Queue[name], 1, 1, 0, 1, 1, 1)
			added = true
		end

		if p.note then
			if added then
				GameTooltip:AddLine(" ", 1, 1, 0.75)
				added = false
			end
			GameTooltip:AddDoubleLine(GLDG_TXT.tipNote, p.note, 1, 1, 0, 1, 1, 1)
			added = true
		end


		GameTooltip:Show()
	end
end

------------------------------------------------------------
function GLDG_OnClick_Header(element)
	--GLDG_Print("Clicked on header ["..tostring(element).."]")
end

------------------------------------------------------------
function GLDG_ClickPlayer(playerName)
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

------------------------------------------------------------
function GLDG_ClickPlayerBar(frame)
	-- Update offset
	if not frame then frame = _G[GLDG_GUI.."PlayersPlayerbar"] end
	FauxScrollFrame_Update(frame, GLDG_TableSize(GLDG_SortedList), GLDG_NumPlrRows, 15)
	GLDG_PlayerOffset = FauxScrollFrame_GetOffset(frame)
	GLDG_ShowPlayers()
end

------------------------------------------------------------
function GLDG_ShowPlayerButtons()
	-- Set frame
	local frame = GLDG_GUI.."Players"
	-- Hide subframes
	_G[frame.."SubAlias"]:Hide()
	_G[frame.."SubGuild"]:Hide()
	_G[frame.."SubNote"]:Hide()
	_G[frame.."SubMainAlt"]:Hide()
	_G[frame.."SubPublicNote"]:Hide()
	_G[frame.."SubOfficerNote"]:Hide()
	-- If no player is selected: hide all buttons
	frame = frame.."ActionButtons"
	if not GLDG_SelPlrName then
		_G[frame]:Show()
		_G[frame.."Check"]:Show()
		_G[frame.."Ignore"]:Hide()
		_G[frame.."Alias"]:Hide()
		_G[frame.."Main"]:Hide()
		_G[frame.."Alt"]:Hide()
		_G[frame.."Guild"]:Hide()
		_G[frame.."Who"]:Hide()
		_G[frame.."Remove"]:Hide()
		_G[frame.."Note"]:Hide()
		_G[frame.."PublicNote"]:Hide()
		_G[frame.."OfficerNote"]:Hide()		
		return
	end
	-- show subframe
	_G[frame]:Show()
	-- check button
	_G[frame.."Check"]:Show()
	-- Set selected player
	local p = GLDG_DataChar[GLDG_SelPlrName]
	-- Ignore button
	local button = _G[frame.."Ignore"]
	if p.ignore then
		button:SetText(GLDG_TXT.pbrign)
	else
		button:SetText(GLDG_TXT.pbsign)
	end
	button:Show()
	-- Alias button
	button = _G[frame.."Alias"]
	button:Show()
	button:Enable()
	-- Main button
	button = _G[frame.."Main"]
	button:Show()
	if p.alt then
		button:SetText(GLDG_TXT.pbpmain)
	elseif not p.main then
		button:SetText(GLDG_TXT.pbsmain)
	elseif (GLDG_NumAlts == 0) then
		button:SetText(GLDG_TXT.pbrmain)
	else
		button:Hide()
	end
	-- Alt button
	button = _G[frame.."Alt"]
	button:Show()
	button:Enable()
	if p.alt then
		button:SetText(GLDG_TXT.pbralt)
	elseif p.main then
		button:Hide()
	else
		button:SetText(GLDG_TXT.pbsalt)
	end
	-- Guild button
	button = _G[frame.."Guild"]
	button:Show()
	if (p.guild and p.guild == GLDG_unique_GuildName) then
		button:Disable()
	else
		button:Enable()
	end
	-- public Note button
	button = _G[frame.."PublicNote"]
	button:Show()
	if (p.guild and p.guild == GLDG_unique_GuildName and CanEditPublicNote()) then
		button:Enable()
	else
		button:Disable()
	end	
	-- Officernote button
	button = _G[frame.."OfficerNote"]
	button:Show()
	if (p.guild and p.guild == GLDG_unique_GuildName and CanEditOfficerNote()) then
		button:Enable()
	else
		button:Disable()
	end		
	-- Note button
	button = _G[frame.."Note"]
	button:Show()
	button:Enable()
	-- Who button
	button = _G[frame.."Who"]
	button:Show()
	if (GLDG_Online[GLDG_SelPlrName]) then
		button:Enable()
	else
		button:Disable()
	end
	-- Remove button
	button = _G[frame.."Remove"]
	button:Show()
	--if (not p.friends or GLDG_TableSize(p.friends)==0) and (not p.guild or p.guild ~= GLDG_unique_GuildName) and (not p.alt) and (not p.main) then
	if (not p.alt and not p.main) then
		button:Enable()
	else
		button:Disable()
	end
end

------------------------------------------------------------
function GLDG_ClickIgnore()
	-- Toggle ignore state for selected player
	local p = GLDG_DataChar[GLDG_SelPlrName]
	local main = p.alt
	if p.main then main = GLDG_SelPlrName end
	local newval = nil
	if not p.ignore then newval = true end
	-- If main or alt, toggle ignore for all characters of this player
	if main then for q in pairs(GLDG_DataChar) do if (q == main) or (GLDG_DataChar[q].alt == main) then GLDG_DataChar[q].ignore = newval end end
	-- Otherwise, simply toggle ignore for this one character
	else p.ignore = newval end
	-- Show updated list
	GLDG_ListPlayers()
end

------------------------------------------------------------
function GLDG_ClickAlias(self)
	-- Activate alias subframe
	GLDG_ShowPlayerButtons()
	self:Disable()
	_G[self:GetParent():GetParent():GetParent():GetName().."SubAlias"]:Show()
end

------------------------------------------------------------
function GLDG_ShowPlayerAlias(frame)
	-- Set title
	_G[frame.."Header"]:SetText(string.format(GLDG_TXT.aliashead, GLDG_SelPlrName))
	-- Set editbox and buttons text
	local p = GLDG_DataChar[GLDG_SelPlrName]
	if p.alias then
		_G[frame.."Set"]:SetText(GLDG_TXT.update)
		_G[frame.."Del"]:SetText(GLDG_TXT.delete)
		_G[frame.."Editbox"]:SetText(p.alias)
	else
		_G[frame.."Set"]:SetText(GLDG_TXT.set)
		_G[frame.."Del"]:SetText(GLDG_TXT.cancel)
		_G[frame.."Editbox"]:SetText("") end
end

------------------------------------------------------------
function GLDG_ClickAliasSet(alias)
	if (alias == "") then return end
	GLDG_DataChar[GLDG_SelPlrName].alias = alias
	GLDG_ListPlayers()
end

------------------------------------------------------------
function GLDG_ClickAliasRemove()
	GLDG_DataChar[GLDG_SelPlrName].alias = nil
	GLDG_ListPlayers()
end

------------------------------------------------------------
function GLDG_ClickMain()
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

------------------------------------------------------------
function GLDG_ClickAlt(self)
	-- Prepare for scrollbar adjustment if needed
	local p = {}
	if GLDG_SelPlrName then p = GLDG_DataChar[GLDG_SelPlrName] end
	local old = nil
	if GLDG_Data.GroupAlt==true then old = GLDG_GetPlayerOffset(GLDG_SelPlrName) end
	-- Toggle alt status for selected character
	local p = GLDG_DataChar[GLDG_SelPlrName]
	if p.alt then p.alt = nil
	elseif (GLDG_NumMain == 1) then
		for q in pairs(GLDG_DataChar) do
			if GLDG_DataChar[q].main then
				p.alt = q
				p.ignore = GLDG_DataChar[q].ignore
				break end end
	else	GLDG_ShowPlayerButtons()
		self:Disable()
		_G[self:GetParent():GetParent():GetParent():GetName().."SubMainAlt"]:Show()
		return
	end
	-- Show updated list
	GLDG_ListPlayers()
	-- Adjust scrollbar if needed
	GLDG_CorrectPlayerOffset(old, GLDG_SelPlrName)
end

------------------------------------------------------------
function GLDG_ClickGuild(self)
	-- Activate guild subframe
	GLDG_ShowPlayerButtons()
	self:Disable()
	_G[self:GetParent():GetParent():GetParent():GetName().."SubGuild"]:Show()
end

------------------------------------------------------------
function GLDG_ShowPlayerGuild(frame)
	-- Set title
	_G[frame.."Header"]:SetText(string.format(GLDG_TXT.guildhead, GLDG_SelPlrName))
	-- Set editbox and buttons text
	local p = GLDG_DataChar[GLDG_SelPlrName]
	if p.guild then
		_G[frame.."Set"]:SetText(GLDG_TXT.update)
		_G[frame.."Del"]:SetText(GLDG_TXT.delete)
		_G[frame.."Editbox"]:SetText(p.guild)
	else
		_G[frame.."Set"]:SetText(GLDG_TXT.set)
		_G[frame.."Del"]:SetText(GLDG_TXT.cancel)
		_G[frame.."Editbox"]:SetText("") end
end

------------------------------------------------------------
function GLDG_ClickGuildSet(guild)
	if (guild == "") then return end
	GLDG_DataChar[GLDG_SelPlrName].guild = guild
	GLDG_ListPlayers()
end

------------------------------------------------------------
function GLDG_ClickGuildRemove()
	GLDG_DataChar[GLDG_SelPlrName].guild = nil
	GLDG_DataChar[GLDG_SelPlrName].rank = nil
	GLDG_DataChar[GLDG_SelPlrName].rankname = nil
	GLDG_DataChar[GLDG_SelPlrName].pNote = nil
	GLDG_DataChar[GLDG_SelPlrName].oNote = nil
	GLDG_ListPlayers()
end

------------------------------------------------------------
function GLDG_ClickNote(self)
	-- Activate note subframe
	GLDG_ShowPlayerButtons()
	self:Disable()
	_G[self:GetParent():GetParent():GetParent():GetName().."SubNote"]:Show()
end


------------------------------------------------------------
function GLDG_ShowPlayerNote(frame)
	-- Set title
	_G[frame.."Header"]:SetText(string.format(GLDG_TXT.notehead, GLDG_SelPlrName))
	-- Set editbox and buttons text
	local p = GLDG_DataChar[GLDG_SelPlrName]
	if p.note then
		_G[frame.."Set"]:SetText(GLDG_TXT.update)
		_G[frame.."Del"]:SetText(GLDG_TXT.delete)
		_G[frame.."Editbox"]:SetText(p.note)
	else
		_G[frame.."Set"]:SetText(GLDG_TXT.set)
		_G[frame.."Del"]:SetText(GLDG_TXT.cancel)
		_G[frame.."Editbox"]:SetText("") end
end

------------------------------------------------------------
function GLDG_ClickNoteSet(note)
	if (note == "") then return end
	GLDG_DataChar[GLDG_SelPlrName].note = note
	GLDG_ListPlayers()
end

------------------------------------------------------------
function GLDG_ClickNoteRemove()
	GLDG_DataChar[GLDG_SelPlrName].note = nil
	GLDG_ListPlayers()
end

----------------------------------------------------------------

function GLDG_ClickPublicNote(self)
	-- Activate note subframe
	GLDG_ShowPlayerButtons()
	self:Disable()
	_G[self:GetParent():GetParent():GetParent():GetName().."SubPublicNote"]:Show()
end


------------------------------------------------------------
function GLDG_ShowPublicPlayerNote(frame)
	-- Set title
	_G[frame.."Header"]:SetText(string.format(GLDG_TXT.PublicNotehead, GLDG_SelPlrName))
	-- Set editbox and buttons text
	local publicnote = nil
	for i = 1, GetNumGuildMembers() do
		local pl, _, _, _, _, _, pn = GetGuildRosterInfo(i) -- für ofiziersnotiz on anhängen!
		if pl == GLDG_SelPlrName then publicnote = pn end
	end

	if publicnote then
		_G[frame.."Set"]:SetText(GLDG_TXT.update)
		_G[frame.."Del"]:SetText(GLDG_TXT.cancel)
		_G[frame.."Editbox"]:SetText(publicnote)
	else
		_G[frame.."Set"]:SetText(GLDG_TXT.set)
		_G[frame.."Del"]:SetText(GLDG_TXT.cancel)
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
	_G[frame.."Header"]:SetText(string.format(GLDG_TXT.OfficerNotehead, GLDG_SelPlrName))
	-- Set editbox and buttons text
	local officernote = nil
	for i = 1, GetNumGuildMembers() do
		local pl, _, _, _, _, _, _, on = GetGuildRosterInfo(i) -- für ofiziersnotiz on anhängen!
		if pl == GLDG_SelPlrName then officernote = on end
	end

	if officernote then
		_G[frame.."Set"]:SetText(GLDG_TXT.update)
		_G[frame.."Del"]:SetText(GLDG_TXT.cancel)
		_G[frame.."Editbox"]:SetText(officernote)
	else
		_G[frame.."Set"]:SetText(GLDG_TXT.set)
		_G[frame.."Del"]:SetText(GLDG_TXT.cancel)
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
		SendWho('n-"'..GLDG_SelPlrName..'"')
	end
end

------------------------------------------------------------
function GLDG_SendWho(name)
	if name then
		if (GLDG_Data.GuildSettings.ShowWhoSpam==true) then
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.request.." ["..Ambiguate(name, "guild").."]")
		end
		SendWho('n-"'..Ambiguate(name, "guild")..'"')
	end
end

------------------------------------------------------------
function GLDG_ParseWho()
	local numWhos, totalCount = GetNumWhoResults()
	local charname, guildname, level, race, class, zone, classFileName

	for i=1,totalCount do
		charname, guildname, level, race, class, zone, classFileName = GetWhoInfo(i)
		if (GLDG_DataChar[charname]) then
			GLDG_TreatWhoInfo(charname, guildname, level, class)
		end
	end
	GLDG_ShowPlayers()
end

------------------------------------------------------------
function GLDG_TreatWhoInfo(charname, guildname, level, class)
	if not charname then return end

	if GLDG_DataChar[charname] then
		result = GLDG_TXT.whoResult1.." ["..tostring(charname).."] "
		if guildname and guildname ~= "" then
			GLDG_DataChar[charname].guild = guildname
			result = result.."<"..tostring(guildname)..">"
		end
		if level then
			GLDG_DataChar[charname].lvl = level
			result = result..", "..GLDG_TXT.whoResult2.." "..tostring(level)
			-- todo: handle level up check (does this make sense, it might have been ages ago?)
		end
		if class then
			GLDG_DataChar[charname].class = class
			result = result..", "..tostring(class)
		end
		if (GLDG_Data.GuildSettings.ShowWhoSpam==true) then
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..result)
		end
	end
end

------------------------------------------------------------
function GLDG_ClickRemove()
	if GLDG_SelPlrName then
		-- remove character
		GLDG_DataChar[GLDG_SelPlrName] = nil
		GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.charRemoved1.." ["..GLDG_SelPlrName.."] "..GLDG_TXT.charRemoved2)

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
	_G[name.."Header"]:SetText(string.format(GLDG_TXT.mainhead, GLDG_SelPlrName))
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

function GLDG_SetTextColor(textName, setName, colourName)
	if not (textName and setName and colourName) then return end
	if not GLDG_Data.colours[setName] then return end
	if not GLDG_Data.colours[setName][colourName] then return end

	local colour = GLDG_Data.colours[setName][colourName]

	local a,r,g,b = GLDG_ColourToRGB_perc(colour)

	local text = _G[textName]
	if text then text:SetTextColor(r, g, b) end
end

------------------------------------------------------------
function GLDG_DebugPrint(msg)
	if not (GLDG_Debug and msg) then return end
	DEFAULT_CHAT_FRAME:AddMessage("GUILDGREET DEBUG: "..msg)
end

------------------------------------------------------------
function GLDG_Print(msg, forceDefault)
	if not (msg) then return end
	if ((GLDG_Data==nil) or (GLDG_Data.PlayerChatFrame[GLDG_Player.."-"..GLDG_Realm] == nil) or (GLDG_Data.PlayerChatFrame[GLDG_Player.."-"..GLDG_Realm]==0) or forceDefault) then
		DEFAULT_CHAT_FRAME:AddMessage(msg)
	else
		_G["ChatFrame"..GLDG_Data.PlayerChatFrame[GLDG_Player.."-"..GLDG_Realm]]:AddMessage(msg)
	end
end

------------------------------------------------------------
function GLDG_TableSize(info)
	local result = 0
	if info then
		for item in pairs(info) do result = result + 1 end
	end
	return result
end

------------------------------------------------------------
function GLDG_GetWords(str)
	local ret = {};
	local pos=0;
	local index=0
	while(true) do
		local word;
		_,pos,word=string.find(str, "^ *([^%s]+) *", pos+1);
		if(not word) then
			return ret;
		end
		ret[index]=word
		index = index+1
	end
end

------------------------------------------------------------
function GLDG_Help()
	GLDG_Print(" ", true)
	GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.help, true)
	GLDG_Print(GLDG_Data.colours.help..GLDG_TXT.usage..":|r /gg guild "..GLDG_Data.colours.help.."[|rshow"..GLDG_Data.colours.help.."] | |rguild all "..GLDG_Data.colours.help.."| |rguild list", true)
	GLDG_Print(GLDG_Data.colours.help..GLDG_TXT.usage..":|r /gg char "..GLDG_Data.colours.help.."[|rshow"..GLDG_Data.colours.help.."] | |rchar all "..GLDG_Data.colours.help.."| |rchar list", true)
	GLDG_Print(GLDG_Data.colours.help..GLDG_TXT.usage..":|r /gg "..GLDG_Data.colours.help.."[|rshow"..GLDG_Data.colours.help.."] <|r"..GLDG_TXT.name..GLDG_Data.colours.help.."> | |rfull "..GLDG_Data.colours.help.."<|r"..GLDG_TXT.name..GLDG_Data.colours.help.."> | |rdetail "..GLDG_Data.colours.help.."<|r"..GLDG_TXT.name..GLDG_Data.colours.help..">|r", true)
	GLDG_Print(GLDG_Data.colours.help..GLDG_TXT.usage..":|r /gg help "..GLDG_Data.colours.help.."| |rabout "..GLDG_Data.colours.help.."| |rconfig "..GLDG_Data.colours.help.."| |rtest", true)
--	GLDG_Print(GLDG_Data.colours.help..GLDG_TXT.usage..":|r /gg urbin", true);
	GLDG_Print(GLDG_Data.colours.help..GLDG_TXT.usage..":|r /gg clear", true)
	GLDG_Print(GLDG_Data.colours.help..GLDG_TXT.usage..":|r /gg check", true)
	GLDG_Print(GLDG_Data.colours.help..GLDG_TXT.usage..":|r /gg alert", true)
	GLDG_Print(GLDG_Data.colours.help..GLDG_TXT.usage..":|r /gg aliasreset", true)	
	GLDG_Print(GLDG_Data.colours.help..GLDG_TXT.usage..":|r /gg greet "..GLDG_Data.colours.help.."| |rbye "..GLDG_Data.colours.help.."| |rlater "..GLDG_Data.colours.help.."[|r guild "..GLDG_Data.colours.help.."| |rchannel "..GLDG_Data.colours.help.."| |rall "..GLDG_Data.colours.help.."| <|rname"..GLDG_Data.colours.help.."> ]|r", true)
	GLDG_Print(" - "..GLDG_Data.colours.help.."guild/all [show]:|r "..GLDG_TXT.help_all, true);
	GLDG_Print(" - "..GLDG_Data.colours.help.."guild/all all:|r "..GLDG_TXT.help_online, true);
	GLDG_Print(" - "..GLDG_Data.colours.help.."guild/all list:|r "..GLDG_TXT.help_list, true);
	GLDG_Print(" - "..GLDG_Data.colours.help.."[show] <name>:|r "..GLDG_TXT.help_name, true);
	GLDG_Print(" - "..GLDG_Data.colours.help.."full <name>:|r "..GLDG_TXT.help_name_full, true);
	GLDG_Print(" - "..GLDG_Data.colours.help.."detail <name>:|r "..GLDG_TXT.help_name_detail, true);
	GLDG_Print(" - "..GLDG_Data.colours.help.."clear:|r "..GLDG_TXT.help_clear, true);
	GLDG_Print(" - "..GLDG_Data.colours.help.."check:|r "..GLDG_TXT.help_check, true);
	GLDG_Print(" - "..GLDG_Data.colours.help.."alert:|r "..GLDG_TXT.help_alert, true);
	GLDG_Print(" - "..GLDG_Data.colours.help.."urbin:|r "..GLDG_TXT.help_urbin, true);
	GLDG_Print(" - "..GLDG_TXT.noargs, true);
	GLDG_Print(" ", true)
end

------------------------------------------------------------
--function GLDG_About(urbin)
--	local ver = GetAddOnMetadata("GuildGreet", "Version");
--	local date = GetAddOnMetadata("GuildGreet", "X-Date");
--	local author = GetAddOnMetadata("GuildGreet", "Author");
--	local web = GetAddOnMetadata("GuildGreet", "X-Website");
--
--	if (author ~= nil) then
--		GLDG_Print(GLDG_NAME.." "..GLDG_TXT.by.." "..GLDG_Data.colours.help..author.."|r", true);
--	end
--	if (ver ~= nil) then
--		GLDG_Print("  "..GLDG_TXT.version..": "..GLDG_Data.colours.help..ver.."|r", true);
--	end
--	if (date ~= nil) then
--		GLDG_Print("  "..GLDG_TXT.date..": "..GLDG_Data.colours.help..date.."|r", true);
--	end
--	if (web ~= nil) then
--		GLDG_Print("  "..GLDG_TXT.web..": "..GLDG_Data.colours.help..web.."|r", true);
--	end

--	if (urbin) then
--		GLDG_Print("  "..GLDG_TXT.slash..": "..GLDG_Data.colours.help..SLASH_GLDG2.."|r", true);
--	else
--		GLDG_ListUrbinAddons(GLDG_NAME)
--	end
--end


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
GLDG_PasteList.List = CreateFrame("Frame", nil, UIParent)
GLDG_PasteList.List:SetMovable(true)
GLDG_PasteList.List:SetResizable(true)
GLDG_PasteList.List:EnableMouse(true)
GLDG_PasteList.List:SetMinResize(320,120)
GLDG_PasteList.List:RegisterForDrag("LeftButton","RightButton")
GLDG_PasteList.List:SetScript("OnMouseDown",
	function(self, button)
		if button == "LeftButton" then
			self:StartMoving()
			self.isMoving = true
			self.hasMoved = false
		elseif button == "RightButton" then
			self:StartSizing()
			self.isSizing = true
			self.hasSized = false
		end
	end)

GLDG_PasteList.List:SetScript("OnMouseUp",
	function(self, button)
		if button == "LeftButton" then
			self:StopMovingOrSizing()

			local opts = GLDG_Data.Frameopts[GLDG_Realm.." - "..GLDG_Player]
			local from, _, to, x, y = self:GetPoint()

			opts.anchorFrom = from
			opts.anchorTo = to
			if self.is_expanded then
				if opts.anchorFrom == "TOPLEFT" or opts.anchorFrom == "LEFT" or opts.anchorFrom == "BOTTOMLEFT" then
					opts.offsetx = x
				elseif opts.anchorFrom == "TOP" or opts.anchorFrom == "CENTER" or opts.anchorFrom == "BOTTOM" then
					opts.offsetx = x - 151/2
				elseif opts.anchorFrom == "TOPRIGHT" or opts.anchorFrom == "RIGHT" or opts.anchorFrom == "BOTTOMRIGHT" then
					opts.offsetx = x - 151
				end
			else
				opts.offsetx = x
			end
			opts.offsety = y
		elseif button == "RightButton" then
			self:StopMovingOrSizing()
			GLDG_Data.Frameopts[GLDG_Realm.." - "..GLDG_Player].Width = self:GetWidth()
			GLDG_Data.Frameopts[GLDG_Realm.." - "..GLDG_Player].Height = self:GetHeight()
			GLDG_PasteList.List.Box:SetWidth(GLDG_Data.Frameopts[GLDG_Realm.." - "..GLDG_Player].Width - 40)
		end
	end)
GLDG_PasteList.List:Hide()
GLDG_PasteList.List:SetPoint(GLDG_Data.Frameopts[GLDG_Realm.." - "..GLDG_Player].anchorFrom, UIParent, GLDG_Data.Frameopts[GLDG_Realm.." - "..GLDG_Player].anchorTo, GLDG_Data.Frameopts[GLDG_Realm.." - "..GLDG_Player].offsetx, GLDG_Data.Frameopts[GLDG_Realm.." - "..GLDG_Player].offsety)
GLDG_PasteList.List:SetUserPlaced(true)
GLDG_PasteList.List:SetFrameStrata("DIALOG")
GLDG_PasteList.List:SetHeight(GLDG_Data.Frameopts[GLDG_Realm.." - "..GLDG_Player].Height)
GLDG_PasteList.List:SetWidth(GLDG_Data.Frameopts[GLDG_Realm.." - "..GLDG_Player].Width)
GLDG_PasteList.List:SetBackdrop({
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true, tileSize = 32, edgeSize = 32,
	insets = { left = 9, right = 9, top = 9, bottom = 9 }
})
GLDG_PasteList.List:SetBackdropColor(0,0,0, 0.8)
GLDG_PasteList.List:SetScript("OnShow", GLDG_PasteList.Show)

GLDG_PasteList.List.Done = CreateFrame("Button", "", GLDG_PasteList.List, "OptionsButtonTemplate")
GLDG_PasteList.List.Done:SetText("Close")
GLDG_PasteList.List.Done:SetPoint("BOTTOMRIGHT", GLDG_PasteList.List, "BOTTOMRIGHT", -10, 10)
GLDG_PasteList.List.Done:SetScript("OnClick", GLDG_PasteList.Done)

GLDG_PasteList.List.Scroll = CreateFrame("ScrollFrame", "GLDG_PasteListInputScroll", GLDG_PasteList.List, "UIPanelScrollFrameTemplate")
GLDG_PasteList.List.Scroll:SetPoint("TOPLEFT", GLDG_PasteList.List, "TOPLEFT", 20, -20)
GLDG_PasteList.List.Scroll:SetPoint("RIGHT", GLDG_PasteList.List, "RIGHT", -30, 0)
GLDG_PasteList.List.Scroll:SetPoint("BOTTOM", GLDG_PasteList.List.Done, "TOP", 0, 10)

GLDG_PasteList.List.Box = CreateFrame("EditBox", "GLDG_PasteListEditBox", GLDG_PasteList.List.Scroll)
GLDG_PasteList.List.Box:SetWidth(GLDG_Data.Frameopts[GLDG_Realm.." - "..GLDG_Player].Width - 40)
GLDG_PasteList.List.Box:SetHeight(85)
GLDG_PasteList.List.Box:SetMultiLine(true)
GLDG_PasteList.List.Box:SetAutoFocus(false)
GLDG_PasteList.List.Box:SetFontObject(GameFontHighlight)
GLDG_PasteList.List.Box:SetScript("OnEscapePressed", GLDG_PasteList.Done)
GLDG_PasteList.List.Box:SetScript("OnTextChanged", GLDG_PasteList.Update)

GLDG_PasteList.List.Scroll:SetScrollChild(GLDG_PasteList.List.Box)
end
------------------------------------------------------------


---------------------
-- _17_ player menu --
---------------------

------------------------------------------------------------
function GLDG_AddPopUpButtons()
	UnitPopupMenus["GLDG"] = {"GLDG_LOOKUP", "GLDG_BYE", "CANCEL"};
	UnitPopupButtons["GLDG"] = { text = GLDG_TXT.menu, dist = 0, nested = 1};
	UnitPopupButtons["GLDG_LOOKUP"] = { text = GLDG_TXT.lookup, dist = 0,};
	UnitPopupButtons["GLDG_BYE"] = { text = GLDG_TXT.goodbye, dist = 0 };

	table.insert(UnitPopupMenus["PLAYER"], #UnitPopupMenus["PLAYER"]-1, "GLDG");
	table.insert(UnitPopupMenus["FRIEND"], #UnitPopupMenus["FRIEND"]-1, "GLDG");
	table.insert(UnitPopupMenus["PARTY"], #UnitPopupMenus["PARTY"]-1, "GLDG");

	hooksecurefunc("UnitPopup_OnClick", GLDG_UnitPopupOnClick);
	hooksecurefunc("UnitPopup_HideButtons", GLDG_UnitPopupHideButtons);
end

------------------------------------------------------------
-- Hooked function for a unit popup
function GLDG_UnitPopupOnClick(self)
	--local dropdownFrame = _G[UIDROPDOWNMENU_INIT_MENU];
	local dropdownFrame = UIDROPDOWNMENU_INIT_MENU
	local button = self.value;
	local name = dropdownFrame.name;

	if button == "GLDG_LOOKUP" then
		GLDG_ListForPlayer(name, false);
		ToggleDropDownMenu(1, nil, dropdownFrame, "cursor");
	elseif button == "GLDG_BYE" then
		GLDG_SendBye(name);
		ToggleDropDownMenu(1, nil, dropdownFrame, "cursor");
	end

	return;
end

------------------------------------------------------------
-- Hooked function to hide buttons for non-friendly players
function GLDG_UnitPopupHideButtons()
	--local dropdownFrame = _G[UIDROPDOWNMENU_INIT_MENU];
	local dropdownFrame = UIDROPDOWNMENU_INIT_MENU
	local coop = dropdownFrame.unit and UnitCanCooperate("player", dropdownFrame.unit)
	for index, value in ipairs(UnitPopupMenus[dropdownFrame.which]) do
		if (((value == "GLDG_LOOKUP") or (value == "GLDG_BYE")) and not coop) then
			UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			return;
		end
	end
end

---------------------
-- _18_ friends roster update --
---------------------

function GLDG_FriendsUpdate()
	if (GLDG_Data.UseFriends==false) then
		return
	end

	-- prepare purge marks
	local purge = {}
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].friends and GLDG_DataChar[p].friends[GLDG_Player]) then
			purge[p] = false
		end
	end

	-- parse friends list
	local cnt = 0
	local complete = false
	local numTotal = GetNumFriends()
	for i = 1, numTotal do
		local name, level, class, loc, connected, status, note = GetFriendInfo(i);
		if (name) then
			local _, uRealm = string.split("-", name)
			if not uRealm then
				name = name.."-"..string.gsub(GLDG_Realm, " ", "")
			end			
			
			cnt = cnt + 1
			-- mark this friend as "active" so it won't be purged below
			purge[name] = true

			if not note then
				note = ""
			end

			-- update data for this friend
			if (GLDG_DataChar[name] == nil) then
				GLDG_DataChar[name] = {}
				GLDG_AddToStartupList(GLDG_TXT.deltaFriends..": "..GLDG_TXT.deltaNewFriend.." ["..Ambiguate(name, "guild").."]")
			end
			if (GLDG_DataChar[name].lvl == nil) then
				GLDG_DataChar[name].lvl = level
			end

			if (GLDG_Data.UseFriends==true) then
				if (connected) then
					-- Update player level
					if (level > GLDG_DataChar[name].lvl) then
						GLDG_AddToStartupList(GLDG_TXT.deltaFriends..": ["..Ambiguate(name, "guild").."]"..GLDG_TXT.deltaIncrease1.." "..tostring(GLDG_DataChar[name].lvl).." "..GLDG_TXT.deltaIncrease2.." "..tostring(level).." "..GLDG_TXT.deltaIncrease3)
						if GLDG_Data.GuildSettings.ListLevelUp==true then

							local mainName = nil
							if (GLDG_DataChar[name] and not GLDG_DataChar[name].ignore) then
								if GLDG_DataChar[name].alt then
									mainName = GLDG_DataChar[name].alt;
									if GLDG_Data.GuildSettings.ExtendAlias==true then
										if GLDG_DataChar[mainName] and GLDG_DataChar[mainName].alias then
											mainName = GLDG_DataChar[mainName].alias
										end
									end
								elseif GLDG_Data.GuildSettings.ExtendMain==true and GLDG_DataChar[name].main then
									mainName = name
									if GLDG_Data.GuildSettings.ExtendAlias==true then
										if GLDG_DataChar[mainName] and GLDG_DataChar[mainName].alias then
											mainName = GLDG_DataChar[mainName].alias
										end
									end
								end
							end

							if (mainName) then
								GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r ["..Ambiguate(name, "guild").."] "..GLDG_Data.colours.help.."{"..mainName.."}|r "..string.format(L["has increased his level from %s to %s"],GLDG_DataChar[name].lvl, level));
							else
								GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r ["..Ambiguate(name, "guild").."] "..string.format(L["has increased his level from %s to %s"],GLDG_DataChar[name].lvl, level));
							end
						end
						if (GLDG_TableSize(GLDG_DataGreet.NewLevel) > 0) and (GLDG_Data.GuildSettings.SupressLevel==false) and (not GLDG_DataChar[name].ignore) and (level > GLDG_Data.GuildSettings.MinLevelUp) then
							if (GLDG_Online[pl] or GLDG_Data.GuildSettings.NoGratsOnLogin==false) then
								GLDG_DataChar[name].newlvl = true
							end
						end
					end
					-- Update queue with all changes still missing
					if (GLDG_DataChar[name].new or GLDG_DataChar[name].newlvl or GLDG_DataChar[name].newrank) and (not GLDG_Queue[name]) then
						GLDG_Queue[name] = "[??:??] "
					end

					GLDG_DataChar[name].lvl = level

					if class and class ~= "Unknown" then
						GLDG_DataChar[name].class = class
					end
				end
				if (not GLDG_Offline[name]) then
					GLDG_Offline[name] = false
				end
				if (GLDG_Online[name] == nil) then
					GLDG_Online[name] = connected
				end
			end
			if (not GLDG_DataChar[name].friends) then
				GLDG_DataChar[name].friends = {}
			end
			GLDG_DataChar[name].friends[GLDG_Player] = note
		end
	end

	-- purge "removed friends" for this char
	for p in pairs(purge) do
		if (purge[p] ~= true) then
			if (GLDG_DataChar[p].friends) then
				GLDG_DataChar[p].friends[GLDG_Player] = nil;
			end
		end
	end

	-- If we got our info, switch to the next phase
	if (cnt > 0) then
		if not GLDG_InitialFriendsUpdate then
			GLDG_InitialFriendsUpdate = true
			GLDG_Main:RegisterEvent("CHAT_MSG_SYSTEM")
		end

		if bit.band(GLDG_InitCheck, 2)==2 then
			GLDG_InitCheck = bit.band(GLDG_InitCheck, bit.bnot(2))	-- friends no longer pending
			GLDG_InitCheck = bit.bor(GLDG_InitCheck, 16)	-- friends done
			--GLDG_Print("InitCheck is ["..tostring(GLDG_InitCheck).."] - friends done")
			GLDG_StartupCheck()
		end

		-- retrigger friends update
		if (GLDG_Data.UpdateTime > 0) then
			GLDG_UpdateRequestFriends = GetTime() + GLDG_Data.UpdateTime
		else
			GLDG_UpdateRequestFriends = nil
		end

		GLDG_ShowQueue()
	end
end


-----------------------------
-- _19_ Achievments        --
-----------------------------
function GLDG_TreatAchievment(achievmentLink, name)
	if not achievmentLink or not name then return end
		local GLDG_shortName, realm = string.split("-", name)
		if not realm then name = GLDG_shortName.."-"..string.gsub(GLDG_Realm, " ", "") end
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
				GLDG_Print(name..GLDG_Data.colours.help.." {"..Ambiguate(main, "guild").."}|r "..L["has earned"].." "..tostring(achievment))
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
function GLDG_CheckChannel()
	GLDG_inChannel = false;
	if (GLDG_ChannelName and GLDG_ChannelName ~= "") then

		local id, name = GetChannelName(GLDG_ChannelName)
		local id2, name2 = GetChannelName(id)
		--GLDG_Print("Checking channels: Stored name ["..tostring(GLDG_ChannelName).."] - retrieved name ["..tostring(name2).."] - id ["..tostring(id).."] - id2 ["..tostring(id2).."]")
		if ((id>0) and (id2>0) and (id==id2) and (string.lower(name2)==GLDG_ChannelName)) then
			--GLDG_DebugPrint("Channel ["..GLDG_ChannelName.."] exists and has id ["..id.."]")

			GLDG_inChannel = true;

			-- get members of channel
			GLDG_Main:RegisterEvent("CHAT_MSG_CHANNEL_LIST")
			DEFAULT_CHAT_FRAME:UnregisterEvent("CHAT_MSG_CHANNEL_LIST")
			GLDG_unregister = GLDG_unregister + 1
			ListChannelByName(GLDG_ChannelName)

			if not bit.band(GLDG_InitCheck, 32)==32 then
				GLDG_InitCheck = bit.bor(GLDG_InitCheck, 4) -- start channel update
				--GLDG_Print("InitCheck is ["..tostring(GLDG_InitCheck).."] - channel started")
			end
		end
	end

	return GLDG_inChannel
end

------------------------------------------------------------
function GLDG_InitChannel(data)
	-- now that we got a list of all people in the channel, we do not need to monitor this event
	if (GLDG_unregister > 0) then
		GLDG_unregister = GLDG_unregister - 1
		if (GLDG_unregister == 0) then
			GLDG_Main:UnregisterEvent("CHAT_MSG_CHANNEL_LIST")
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

				GLDG_DebugPrint(p..": Name ["..names[p].."] retrieved -> ["..Ambiguate(name, "guild").."] extracted");
				if (name) then
					if (not GLDG_DataChar[name]) then
						GLDG_DataChar[name] = {}
						GLDG_AddToStartupList(GLDG_TXT.deltaChannel..": "..GLDG_TXT.deltaNewMember.." ["..Ambiguate(name, "guild").."]")
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
			GLDG_DebugPrint("Player ["..Ambiguate(player, "guild").."] joined channel ["..GLDG_ChannelName.."]")

			if (GLDG_DataChar[player] and not GLDG_DataChar[player].ignore) then
				GLDG_DebugPrint("player "..Ambiguate(player, "guild").." is a member of our channel")
				GLDG_Online[player] = GetTime()

				-- if player is in our guild or on our friend's list, we've already
				-- listed him above, otherwise, list him now
				if (not GLDG_DataChar[player].guild or GLDG_DataChar[player].guild ~= GLDG_unique_GuildName) and
				   (not GLDG_DataChar[player].friends or not GLDG_DataChar[player].friends[GLDG_Player]) then
					if GLDG_Data.GuildSettings.ListNames==true then
						if GLDG_DataChar[player].alt then
							--
							-- Alt von Main
							--
							local main = GLDG_DataChar[player].alt;
							local altsList = GLDG_FindAlts(main, player, 1)
							GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..altsList)
						else
							if GLDG_DataChar[player].main then
								--
								-- Main
								--
								local main = player;
								local altsList = GLDG_FindAlts(main, player, 1)
								GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..altsList)
							else
								--
								-- Hat keinen Alt
								--
								local details = GLDG_findPlayerDetails(player);
								local alias = GLDG_findAlias(player, 1);

								if (details ~= "") then
									GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_ONLINE_COLOUR..Ambiguate(player, "guild")..": "..details.."|r"..alias.." {c}")
								else
									GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_ONLINE_COLOUR..Ambiguate(player, "guild").."|r"..alias.." {c}")
								end
							end
						end
					end

					if GLDG_DataChar[player].alt then GLDG_Offline[player] = GLDG_Offline[GLDG_DataChar[player].alt] end
					if GLDG_Offline[player] and (GLDG_Online[player] - GLDG_Offline[player] < GLDG_Data.GuildSettings.RelogTime * 60) then return end
					GLDG_DebugPrint("player "..Ambiguate(player, "guild").." is not been online in the last "..GLDG_Data.GuildSettings.RelogTime.." minutes.")
					if GLDG_Offline[player] and (GLDG_Data.GuildSettings.SupressGreet==true or (GLDG_TableSize(GLDG_DataGreet.GreetBack) == 0)) then return end
					GLDG_DebugPrint("player "..Ambiguate(player, "guild").." is not been online before")
					if not GLDG_Offline[player] and (GLDG_Data.GuildSettings.SupressGreet==true or (GLDG_TableSize(GLDG_DataGreet.Greet) == 0)) then return end
					GLDG_DebugPrint("player "..Ambiguate(player, "guild").." should be greeted")
					GLDG_Queue[player] = GLDG_GetLogtime(player)
					GLDG_ShowQueue()
				end

				-- if no class info is available, this player has never been /who queried before -> do it now
				-- todo: queue these so they don't get lost if there are too many close together
				if ((not GLDG_DataChar[player].guild) or (GLDG_DataChar[player].guild ~= GLDG_unique_GuildName)) and (not GLDG_DataChar[player].class or not GLDG_DataChar[player].lvl or (GLDG_DataChar[player].lvl < GLDG_LEVEL_CAP)) and GLDG_Data.AutoWho==true then
					GLDG_SendWho(player)
				end
			end

		else
			GLDG_DebugPrint("Player ["..Ambiguate(player, "guild").."] left channel ["..GLDG_ChannelName.."]")

			if (GLDG_DataChar[player] and not GLDG_DataChar[player].ignore) then
				GLDG_DebugPrint("player "..Ambiguate(player, "guild").." is a member of our channel")
				-- if player is in our guild or on our friend's list, we'll list
				-- him again in a second, otherwise, list him now
				if (not GLDG_DataChar[player].guild or GLDG_DataChar[player].guild ~= GLDG_unique_GuildName) and
				   (not GLDG_DataChar[player].friends or not GLDG_DataChar[player].friends[GLDG_Player]) then
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
							GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..altsList)
						else
							if GLDG_DataChar[player].main then
								--
								-- Main
								--
								local main = player;
								local altsList = GLDG_FindAlts(main, player, 0)
								GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..altsList)
							else
								--
								-- Hat keinen Alt
								--
								local details = GLDG_findPlayerDetails(player);
								local alias = GLDG_findAlias(player, 0);

								if (details ~= "") then
									GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_GOES_OFFLINE_COLOUR..Ambiguate(player, "guild")..": "..details.."|r"..alias.." {c}")
								else
									GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_GOES_OFFLINE_COLOUR..Ambiguate(player, "guild").."|r"..alias.." {c}")
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
	GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.forceChatList)
	GLDG_unregister = 0
	DEFAULT_CHAT_FRAME:RegisterEvent("CHAT_MSG_CHANNEL_LIST")
end


-----------------------------
-- _21_ Testing            --
-----------------------------


function GLDG_SecToTimeString(secs)
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
			result = result.." "..tostring(day).." days"
		elseif (day > 0) then
			result = result.." "..tostring(day).." day"
		end
		if (hours > 1) then
			result = result.." "..tostring(hours).." hours"
		elseif (hours > 0) then
			result = result.." "..tostring(hours).." hour"
		end
		if (minutes > 1) then
			result = result.." "..tostring(minutes).." minutes"
		elseif (minutes > 0) then
			result = result.." "..tostring(minutes).." minute"
		end
		if (secs > 1) then
			result = result.." "..tostring(secs).." seconds"
		elseif (secs > 0) then
			result = result.." "..tostring(secs).." second"
		end

	end

	return result
end

------------------------------------------------------------
function GLDG_Test(showAll)
	GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r Test")

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
				GLDG_Print("  BN friend ["..tostring(givenName).." "..tostring(surname).."] - ["..tostring(toonName).."] - ["..tostring(client).."] is ["..tostring(isOnline).."] since ["..tostring(GLDG_SecToTimeString(lastOnline)).."]");

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

	--GLDG_Convert_Plausibility_Check()

	--SendAddonMessage("GLDG", "Nur so ein Text", "WHISPER", "Urbin")

	--SendAddonMessage("GLDG", "VER:"..GetAddOnMetadata("GuildGreet", "Version"), "GUILD")
	--SendAddonMessage("GLDG", "VER:"..GetAddOnMetadata("GuildGreet", "Version"), "PARTY")
	--SendAddonMessage("GLDG", "VER:"..GetAddOnMetadata("GuildGreet", "Version"), "RAID")

	--SendAddonMessage("GLDG", "VER:"..GetAddOnMetadata("GuildGreet", "Version").."2", "GUILD")

	--GLDG_CreateTestChars()

	--[[ -- used for screenshot in order not to use real guild names --
	GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r Creating list")
	local list = {}
	list[1] = "[Magam] Lyb Venum - Mag"
	list[2] = "[Kelthuzad] Ganad Tholie - Kel"
	list[3] = "[Ronnie] Radon Rumag Renid - Ron"
	list[4] = "[Tom] Saka Luna - Tom"
	list[5] = "[Gundor] Hilada Vorix - Gundor"
	list[6] = "[Luator] Tibbor Hagadu - Luator"
	list[7] = "[Zapator] Mula Jeno Jilador Koradin Wegamul - Zappie"
	list[8] = "[Hilane] Mulase Mimidor - Hil"
	list[9] = "[Hugena] Fiodan - Huggie"
	list[10] = "[Kyreena] Kalomur - Kyreena"
	list[11] = "[Dinosa] Stib Lokinat - Dino"
	list[12] = "[Xynasa] Wugedan - Xyn"
	list[13] = "[Remolo] Quagal - Remo"
	list[14] = "[Anima] Arista Olibeth - Ani"
	list[15] = "[Pug] Thomas Charles - Pug"
	list[16] = "[Dores] Frazon Wiligom - Dori"
	list[17] = "[Numan] Jomin Yaldor - Numan"
	list[18] = "[Haxxor] - Hax"
	list[19] = "[Pwner] Gank0r - L00s0r"
	list[20] = "[Nadel] Sabtise - Nad"
	list[21] = "[Bunjipp] - Bun"
	list[22] = "[Haruna] Jorador - Haru"
	list[23] = "[Olibado] - Oli"
	list[24] = "[Sumada] - Sum"
	list[25] = "[Irida] - Iri"
	list[26] = "[Manolo] - Mano"
	list[27] = "[Tiara] - Tiara"
	list[28] = "[Tonina] - Toni"
	list[29] = "[Tamara] Solana Illidur - Tami"
	list[30] = "[Ugida] - Ugida"
	list[31] = "[Soleno] Somvitg - Sol"
	list[32] = "[Frog] - Frog"
	list[33] = "[Glazzi] - Glazzi"
	list[34] = "[Weinbär] Brummbär Waschbär- Bär"
	list[35] = "[Xhorosh] - Xor"
	list[36] = "[Grubosh] - Grubosh"
	list[37] = "[Mechtild] - Mechtild"
	list[38] = "[Munher] - Muni"
	list[39] = "[Liv] - Liv"
	list[40] = "[Spifosa] - Spif"
	list[41] = "[Hobbus] Calvadur - Hob"
	list[42] = "[Taran] - Taran"
	GLDG_list = list
	GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r Showing list")
	GLDG_PasteList.List:Show();
	GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r Shown list")
	]]--

end

------------------------------------------------------------
function GLDG_CreateTestChars()
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

	GLDG_ShowQueue()
end

-----------------------------
-- _22_ Showing stored information
-----------------------------
function GLDG_ShowDetails(name)
	if not name then return end

	if (GLDG_DataChar[name]) then
		GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r ["..Ambiguate(name, "guild").."]")
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
		GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.nodata1.." ["..Ambiguate(name, "guild").."] "..GLDG_TXT.nodata2)
	end
end

-----------------------------
-- _23_ Colour picker handling    --
-----------------------------
function GLDG_ColourToRGB(colour)
	local hex = string.sub(colour, 3)
	local alpha, rhex, ghex, bhex = string.sub(hex, 1,2), string.sub(hex, 3, 4), string.sub(hex, 5, 6), string.sub(hex, 7, 8)
	return tonumber(alpha, 16), tonumber(rhex, 16), tonumber(ghex, 16), tonumber(bhex, 16)
end

------------------------------------------------------------
function GLDG_ColourToRGB_perc(colour)
	local hex = string.sub(colour, 3)
	local alpha, rhex, ghex, bhex = string.sub(hex, 1,2), string.sub(hex, 3, 4), string.sub(hex, 5, 6), string.sub(hex, 7, 8)
	local a,r,g,b = tonumber(alpha, 16), tonumber(rhex, 16), tonumber(ghex, 16), tonumber(bhex, 16)
	return a/255, r/255, g/255, b/255
end

------------------------------------------------------------
function GLDG_RGBToColour(a, r, g, b)
	return string.format("|c%02X%02X%02X%02X", a, r, g, b)
end

------------------------------------------------------------
function GLDG_RGBToColour_perc(a, r, g, b)
	return string.format("|c%02X%02X%02X%02X", a*255, r*255, g*255, b*255)
end

------------------------------------------------------------
function GLDG_ShowColourPicker()
	if not GLDG_colour then GLDG_colour = "|cFFFFFFFF" end

	-- store old callbacks
	GLDG_oldColourPicked = GLDG_ColorPickerFrame.func
	GLDG_oldColourCancel = GLDG_ColorPickerFrame.cancelFunc
	GLDG_oldOpacityChanged = GLDG_ColorPickerFrame.opacityFunc

	-- define our own callbacks
	GLDG_ColorPickerFrame.func = GLDG_ColourPicked
	GLDG_ColorPickerFrame.opacityFunc = GLDG_ColourPicked
	GLDG_ColorPickerFrame.cancelFunc = GLDG_ColourCancel

	-- set up window
	local a,r,g,b = GLDG_ColourToRGB_perc(GLDG_colour)
	if (GLDG_colourName=="header") then
		GLDG_ColorPickerFrame.hasOpacity = true;
	else
		GLDG_ColorPickerFrame.hasOpacity = false;
	end
	GLDG_ColorPickerFrame.opacity = a
	GLDG_ColorPickerFrame.previousValues = {r, g, b}
	GLDG_oldOpacity = a

	GLDG_updating = true
	GLDG_UpdateColoursSwatch()
	GLDG_UpdateColoursNumbers()
	GLDG_updating = nil

	-- show window
	--GuildGreetColourFrame:Show()
	GLDG_ColorPickerFrame:Show();
	--GuildGreetColourFrame:Lower()

	GLDG_colorPickerShown = true

end

------------------------------------------------------------
function GLDG_HideColourPicker()
	-- hide window
	GLDG_ColorPickerFrame:Hide();
	--GuildGreetColourFrame:Hide()
	GLDG_colorPickerShown = nil

	-- restore old callbacks
	GLDG_ColorPickerFrame.func = GLDG_oldColourPicked
	GLDG_ColorPickerFrame.cancelFunc = GLDG_oldColourCancel
	GLDG_ColorPickerFrame.opacityFunc = GLDG_oldOpacityChanged
	GLDG_oldColourPicked = nil
	GLDG_oldColourCancel = nil
	GLDG_oldOpacityChanged = nil

	-- clear temp values
	GLDG_current_red = nil
	GLDG_current_green = nil
	GLDG_current_blue = nil
	GLDG_current_opacity = nil
	GLDG_oldOpacity = nil
end

------------------------------------------------------------
function GLDG_ColourPicked(flag) -- flag is only passed when called from clicking on a button
	if GLDG_colorPickerShown and not GLDG_updating then
		-- get values
		local r, g, b = GLDG_ColorPickerFrame:GetColorRGB();

		-- use values
		local a = 1
		if (GLDG_colourName=="header") then
			a = GLDG_OpacitySliderFrame:GetValue()
		end
		GLDG_colour = GLDG_RGBToColour_perc(a, r, g, b)
		GLDG_UpdateCurrentColour()

		if (flag) then
			GLDG_HideColourPicker()
		else
			GLDG_updating = true
			GLDG_UpdateColoursNumbers()
			GLDG_updating = nil
		end
	end
end

------------------------------------------------------------
function GLDG_ColourCancel(prevvals)
	-- restore values
	local r, g, b = unpack(prevvals)
	local a = GLDG_oldOpacity


	GLDG_colour = GLDG_RGBToColour_perc(a, r, g, b)
	--GLDG_Print("Restored colour is "..GLDG_colour..string.sub(GLDG_colour, 3).."|r")
	GLDG_UpdateCurrentColour()

	GLDG_HideColourPicker()
end

------------------------------------------------------------
function GLDG_UpdateColoursSwatch()
	local a,r,g,b = GLDG_ColourToRGB_perc(GLDG_colour)

	GLDG_ColorSwatch:SetColorTexture(r, g, b);
	GLDG_ColorPickerFrame:SetColorRGB(r, g, b);

	GLDG_ColorPickerFrame.opacity = a
	GLDG_OpacitySliderFrame:SetValue(a);
end

------------------------------------------------------------
function GLDG_UpdateColoursNumbers()
	local a,r,g,b = GLDG_ColourToRGB(GLDG_colour)

	GLDG_current_red = r
	GLDG_current_green = g
	GLDG_current_blue = b
	GLDG_current_opacity = a

	GuildGreetColourFrameRed:SetNumber(r)
	GuildGreetColourFrameGreen:SetNumber(g)
	GuildGreetColourFrameBlue:SetNumber(b)
	GuildGreetColourFrameOpacity:SetNumber(a)
end

------------------------------------------------------------
function GLDG_ColourCancelEdit(self, element)
	if not GLDG_updating then
		if self then
			self:HighlightText(self:GetNumLetters())
		end
		GLDG_updating = true
		GLDG_UpdateColoursSwatch()
		GLDG_updating = nil
	end
end

------------------------------------------------------------
function GLDG_ColourEnter(self, element, number)
	if not GLDG_updating then
		if self then
			self:HighlightText(self:GetNumLetters())
		end
		if (number >= 0 and number<=255) then
			local a,r,g,b = GLDG_ColourToRGB(GLDG_colour)

			if (element == "GuildGreetColourFrameRed") then
				GLDG_current_red = number
				GLDG_colour = GLDG_RGBToColour(a, number, g, b)
				GLDG_UpdateCurrentColour()
			elseif (element == "GuildGreetColourFrameGreen") then
				GLDG_current_green = number
				GLDG_colour = GLDG_RGBToColour(a, r, number, b)
				GLDG_UpdateCurrentColour()
			elseif (element == "GuildGreetColourFrameBlue") then
				GLDG_current_blue = number
				GLDG_colour = GLDG_RGBToColour(a, r, g, number)
				GLDG_UpdateCurrentColour()
			elseif (element == "GuildGreetColourFrameOpacity") then
				GLDG_current_opacity = number
				GLDG_colour = GLDG_RGBToColour(number, r, g, b)
				GLDG_UpdateCurrentColour()
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
		GLDG_UpdateColoursSwatch()
		GLDG_updating = nil
	end

end

------------------------------------------------------------
function GLDG_ColourTab(self, element)
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

------------------------------------------------------------
function GLDG_ColourUpdate(element, number)
	--GLDG_Print("Update: element ["..element.."].. - number ["..number.."]")
end


-----------------------------
-- _24_ Colour handling    --
-----------------------------
-- todo: remove sets
function GLDG_SetActiveColourSet(set)
	GLDG_ONLINE_COLOUR		= GLDG_DEFAULT_ONLINE_COLOUR
	GLDG_IS_OFFLINE_COLOUR		= GLDG_DEFAULT_IS_OFFLINE_COLOUR
	GLDG_GOES_OFFLINE_COLOUR	= GLDG_DEFAULT_GOES_OFFLINE_COLOUR
	GLDG_ALIAS_COLOUR		= GLDG_DEFAULT_ALIAS_COLOUR

	if (set and GLDG_Data.colours[set]) then
		GLDG_ONLINE_COLOUR		= GLDG_Data.colours[set].online
		GLDG_IS_OFFLINE_COLOUR		= GLDG_Data.colours[set].isOff
		GLDG_GOES_OFFLINE_COLOUR	= GLDG_Data.colours[set].goOff
		GLDG_ALIAS_COLOUR		= GLDG_Data.colours[set].alias
	end
end

------------------------------------------------------------
function GLDG_ColoursShow()
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
			local colour = GLDG_Data.colours[GLDG_set_list[s]][GLDG_element_list[e]]
			local a,r,g,b = GLDG_ColourToRGB_perc(colour)
			local texture = _G[name..s..e.."ColourTexture"]
			texture:SetColorTexture(r,g,b,a)
			local text = _G[name..s..e.."Button"]
			text:SetText(string.sub(colour, 5))
		end
	end

	local a,r,g,b = GLDG_ColourToRGB_perc(GLDG_Data.colours.help)
	local texture = _G[name.."HelpColourTexture"]
	texture:SetColorTexture(r,g,b,a)
	local text = _G[name.."HelpButton"]
	text:SetText(string.sub(GLDG_Data.colours.help, 5))

	a,r,g,b = GLDG_ColourToRGB_perc(GLDG_Data.colours.header)
	texture = _G[name.."HeaderColourTexture"]
	texture:SetColorTexture(r,g,b,a)
	local text = _G[name.."HeaderButton"]
	text:SetText(string.sub(GLDG_Data.colours.header, 3))
end

------------------------------------------------------------
function GLDG_ColourClick(name)
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
			GLDG_ColourRestoreDefaults()
		else
			if ((GLDG_setName~="" or GLDG_colourName=="help" or GLDG_colourName=="header") and (GLDG_colourName ~="")) then
				-- get current colour
				if (GLDG_colourName=="help") then
					GLDG_colour = GLDG_Data.colours.help
				elseif (GLDG_colourName=="header") then
					GLDG_colour = GLDG_Data.colours.header
				else
					GLDG_colour = GLDG_Data.colours[GLDG_setName][GLDG_colourName]
				end

				-- open color picker
				GLDG_ShowColourPicker()
			else
				GLDG_Print("--- unknown button ["..Ambiguate(name, "guild").."] pressed ---")
			end
		end
	else
		GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.colourConfig)
	end
end

------------------------------------------------------------
function GLDG_UpdateCurrentColour()
	--GLDG_Print("Colour is "..GLDG_colour..string.sub(GLDG_colour, 3).."|r")

	if (not GLDG_setName) or (not GLDG_colourName) then return end

	if ((GLDG_setName~="" or GLDG_colourName=="help" or GLDG_colourName=="header") and (GLDG_colourName ~="")) then
		-- set value
		if (GLDG_colourName=="help") then
			GLDG_Data.colours.help = GLDG_colour
		elseif (GLDG_colourName=="header") then
			GLDG_Data.colours.header = GLDG_colour
		else
			GLDG_Data.colours[GLDG_setName][GLDG_colourName] = GLDG_colour
		end

		-- update colour cache
		GLDG_SetActiveColourSet("guild")
	end

	GLDG_ColoursShow()
end


------------------------------------------------------------
function GLDG_ColourRestoreDefaults()
	if not GLDG_colorPickerShown then
		GLDG_Data.colours.help = GLDG_DEFAULT_HELP_COLOUR
		GLDG_Data.colours.header = GLDG_DEFAULT_HEADER_COLOUR

		GLDG_Data.colours.guild.online = GLDG_DEFAULT_ONLINE_COLOUR
		GLDG_Data.colours.guild.isOff = GLDG_DEFAULT_IS_OFFLINE_COLOUR
		GLDG_Data.colours.guild.goOff = GLDG_DEFAULT_GOES_OFFLINE_COLOUR
		GLDG_Data.colours.guild.alias = GLDG_DEFAULT_ALIAS_COLOUR
		GLDG_Data.colours.guild.list = GLDG_DEFAULT_LIST_COLOUR
		GLDG_Data.colours.guild.new = GLDG_DEFAULT_NEW_COLOUR
		GLDG_Data.colours.guild.lvl = GLDG_DEFAULT_LVL_COLOUR
		GLDG_Data.colours.guild.rank = GLDG_DEFAULT_RANK_COLOUR
		GLDG_Data.colours.guild.relog = GLDG_DEFAULT_RELOG_COLOUR
		GLDG_Data.colours.guild.achievment = GLDG_DEFAULT_ACHIEVMENT_COLOUR

		-- todo: remove
		GLDG_Data.colours.friends.online = GLDG_DEFAULT_ONLINE_COLOUR
		GLDG_Data.colours.friends.isOff = GLDG_DEFAULT_IS_OFFLINE_COLOUR
		GLDG_Data.colours.friends.goOff = GLDG_DEFAULT_GOES_OFFLINE_COLOUR
		GLDG_Data.colours.friends.alias = GLDG_DEFAULT_ALIAS_COLOUR
		GLDG_Data.colours.friends.list = GLDG_DEFAULT_LIST_COLOUR
		GLDG_Data.colours.friends.new = GLDG_DEFAULT_NEW_COLOUR
		GLDG_Data.colours.friends.lvl = GLDG_DEFAULT_LVL_COLOUR
		GLDG_Data.colours.friends.rank = GLDG_DEFAULT_RANK_COLOUR
		GLDG_Data.colours.friends.relog = GLDG_DEFAULT_RELOG_COLOUR
		GLDG_Data.colours.friends.achievment = GLDG_DEFAULT_ACHIEVMENT_COLOUR

		-- todo: remove
		GLDG_Data.colours.channel.online = GLDG_DEFAULT_ONLINE_COLOUR
		GLDG_Data.colours.channel.isOff = GLDG_DEFAULT_IS_OFFLINE_COLOUR
		GLDG_Data.colours.channel.goOff = GLDG_DEFAULT_GOES_OFFLINE_COLOUR
		GLDG_Data.colours.channel.alias = GLDG_DEFAULT_ALIAS_COLOUR
		GLDG_Data.colours.channel.list = GLDG_DEFAULT_LIST_COLOUR
		GLDG_Data.colours.channel.new = GLDG_DEFAULT_NEW_COLOUR
		GLDG_Data.colours.channel.lvl = GLDG_DEFAULT_LVL_COLOUR
		GLDG_Data.colours.channel.rank = GLDG_DEFAULT_RANK_COLOUR
		GLDG_Data.colours.channel.relog = GLDG_DEFAULT_RELOG_COLOUR
		GLDG_Data.colours.channel.achievment = GLDG_DEFAULT_ACHIEVMENT_COLOUR

		-- update colour cache
		GLDG_SetActiveColourSet("guild")

		GLDG_ColoursShow()
	else
		GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.colourDefault)
	end
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

	-- cut off colour button/texture
	if (string.find(name, "Colour") == 1) then
		-- ["ColourGuildNewButton"] = true,
		s,e = string.find(name, "Button");
		if (s and e) then
			name = string.sub(name, 0, s-1)
		end
		-- ["ColourGuildNewColour"] = true,
		s,e = string.find(name, "Colour", 2);	-- start at 2 to skip the initial Colour
		if (s and e) then
			name = string.sub(name, 0, s-1)
		end
	end


	local tip = ""
	local head = ""
	if (GLDG_TXT.elements and
	    GLDG_TXT.elements.name and
	    GLDG_TXT.elements.tip and
	    GLDG_TXT.elements.name[name] and
	    GLDG_TXT.elements.tip[name]) then
		tip = GLDG_TXT.elements.tip[name]
		head = GLDG_TXT.elements.name[name]

		if (GLDG_Data.needsTip and GLDG_Data.needsTip[name]) then
			GLDG_Data.needsTip[name] = nil
		end
	else
		if (not GLDG_Data.needsTip) then
			GLDG_Data.needsTip = {}
		end
		GLDG_Data.needsTip[name] = true
	end

	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	if (head ~= "") then
		GameTooltip:SetText(head, 1, 1, 0.5, 1.0, 1)
--		GameTooltip:AddLine(name, 1, 0, 0, 1.0, 1)
		GameTooltip:AddLine(tip, 1, 1, 1, 1.0, 1)
--	else
--		GameTooltip:SetText(element, 1, 1, 0.5, 1.0, 1)
--		GameTooltip:AddLine(name, 1, 1, 1, 1.0, 1)
	end

	GameTooltip:Show()
end


--------------------------
-- _26_ Chat name extension
--------------------------

------------------------------------------------------------
-- extracted from r,g,b = RAID_CLASS_COLORS[enClass] * 255
local classColors = {}
classColors["MAGE"]			= "|cFF69CCF0";
classColors["PRIEST"]		= "|cFFFFFFFF";
classColors["WARLOCK"]		= "|cFF9682C9";
classColors["PALADIN"]		= "|cFFF58CBA";
classColors["DRUID"]		= "|cFFFF7D0A";
classColors["SHAMAN"]		= "|cFF00DBBA";
classColors["DEMONHUNTER"]  = "|cFFA330C9";
classColors["WARRIOR"]		= "|cFFBE9C6E";
classColors["ROGUE"]		= "|cFFFFF569";
classColors["HUNTER"]		= "|cFFAAD473";
classColors["DEADKNIGHT"]	= "|cFFC41F3B";
classColors["MONK"]      	= "|cFF00FF96";

------------------------------------------------------------
function GLDG_ChatFilter(chatFrame, event, ...) -- chatFrame = self
--[[
	taken from "http://www.wowwiki.com/Events_C_(Cancel,_Character,_Chat,_Cinematic,_Clear,_Close,_Confirm,_Corpse,_Craft,_Current,_Cursor,_CVar)"

	"CHAT_MSG_CHANNEL"
	Called when the client recieves a channel message.
	msg: chat message
	arg2: author
	arg3: language
	arg4: channel name with number
	arg5: unknown (empty string)
	arg6: unknown (empty string)
	arg7: unknown (appears to be channel number)
	arg8: channel number
	arg9: channel name without number
	arg12: colour uid

	"CHAT_MSG_GUILD"
	Fired when a message is sent or received in the Guild channel.
	msg: Message that was sent
	arg2: Author
	arg3: Language that the message was sent in
	arg12: colour uid

	"CHAT_MSG_OFFICER"
	Fired when a message is sent or received in the Guild Officer channel.
	msg: Message that was received
	arg2: Author
	arg3: Language used
	arg12: colour uid

	"CHAT_MSG_WHISPER"
	Fired when a whisper is received from another player.
	The rest of the arguments appear to be nil
	msg: Message received
	arg2: Author
	arg3: Language (or nil if universal, like messages from GM)
	arg6: status (like "DND" or "GM")
	arg12: colour uid
]]--

	local msg, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13 = ...;

	--GLDG_Print("CHAT: event ["..tostring(event).."] - msg ["..tostring(msg).."] - arg2 ["..tostring(arg2).."] - arg3 ["..tostring(arg3).."]");

	if GLDG_Data.GuildSettings.ExtendChat==true then
		local main = ""
		local class = ""
		local treated = nil

		if (event) then
			-- guild members can post to all three (officers even four) channels
			if (((event == "CHAT_MSG_GUILD") and arg2) or
			    ((event == "CHAT_MSG_OFFICER") and arg2) or
			    ((event == "CHAT_MSG_CHANNEL") and arg9 and (arg9 == GLDG_ChannelName) and arg2) or
			    ((event == "CHAT_MSG_WHISPER") and arg2)) then
				--GLDG_Print("Event ["..event.."] from player ["..arg2.."]")
				treated = true
				if (GLDG_DataChar[arg2] and (not GLDG_DataChar[arg2].ignore or GLDG_Data.GuildSettings.ExtendIgnored==true)) then
					if GLDG_DataChar[arg2].alt then
						main = GLDG_DataChar[arg2].alt;
						if GLDG_Data.GuildSettings.ExtendAlias==true then
							if GLDG_DataChar[main] and GLDG_DataChar[main].alias then
								main = GLDG_DataChar[main].alias
							end
						end
					elseif GLDG_Data.GuildSettings.ExtendMain==true and GLDG_DataChar[arg2].main then
						main = arg2
						if GLDG_Data.GuildSettings.ExtendAlias==true then
							if GLDG_DataChar[main] and GLDG_DataChar[main].alias then
								main = GLDG_DataChar[main].alias
							end
						end
					end
				end
			end

			-- use this to discover any other events being sent
			if ((event ~= "CHAT_MSG_GUILD") and
			    (event ~= "CHAT_MSG_OFFICER") and
			    (event ~= "CHAT_MSG_CHANNEL") and
			    (event ~= "CHAT_MSG_WHISPER")) then
				--GLDG_Print("Event ["..event.."] is boring")
			end
		end

		if ((main ~= "") and msg and arg2 and (arg2 ~= GLDG_Player)) then
			msg = GLDG_Data.colours.help.."{"..Ambiguate(main, "guild").."}|r "..msg
		end

		--if (treated) then
			--GLDG_Print("Main of ["..tostring(arg2).."] is ["..tostring(main).."] - passed text is ["..tostring(msg).."]");
		--end
	end

	return false, msg, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13;
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
		text = GLDG_TXT.reloadQuestion,
		button1 = GLDG_TXT.reloadNow,
		button2 = GLDG_TXT.later,
		OnAccept = function()
			ReloadUI();
			end,
		OnCancel = function()
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|cFFFF0000 "..GLDG_TXT.reload)
			end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
		sound = "igQuestFailed",
	};
end

--------------------------
-- _29_ urbin addon listing
--------------------------
--function GLDG_RegisterUrbinAddon(name, about)
--	if (not name) then return end
--	if (not URBIN_AddonList) then
--		URBIN_AddonList = {}
--	end
--	URBIN_AddonList[name] = {}
--	URBIN_AddonList[name].name = name
--	URBIN_AddonList[name].about = about
--end

------------------------------------------------------------
--function GLDG_ListUrbinAddons(name)
--	if (not URBIN_AddonList) then
--		return
--	end
--
--	local addons = ""
--	for p in pairs(URBIN_AddonList) do
--		if (URBIN_AddonList[p].name ~= name) then
--			if (addons ~= "") then
--				addons = addons..", "
--			end
--			addons = addons..URBIN_AddonList[p].name
--		end
--	end
--
--	if (addons ~= "") then
--		GLDG_Print(" ", true);
--		GLDG_Print("  "..GLDG_TXT.urbin..": "..GLDG_Data.colours.help..addons.."|r", true);
--	end
--end

------------------------------------------------------------
function GLDG_ListUrbinAddonDetails()
	if (not URBIN_AddonList) then
		return
	end

	for p in pairs(URBIN_AddonList) do
		if (URBIN_AddonList[p].about) then
			URBIN_AddonList[p].about(true)
		end
	end
end

--------------------------
-- _30_ big brother
--------------------------
function GLDG_BB(flag)
	GLDG_Data.BigBrother = flag
	if (not flag) then
		GLDG_BigBrother = nil
	end
	GLDG_Print("BigBrother is ["..tostring(GLDG_Data.BigBrother).."]")
end

------------------------------------------------------------
function GLDG_ShowBigBrother()
	if (GLDG_Data.BigBrother and GLDG_BigBrother) then
		GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.bigBrother5)
		for p in pairs(GLDG_BigBrother) do
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..Ambiguate(p, "guild")..": "..GLDG_BigBrother[p])
		end
	else
		GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.bigBrother6)
	end
end

------------------------------------------------------------
function GLDG_PollBigBrother()
	SendAddonMessage("GLDG", "QUERY:"..GetAddOnMetadata("GuildGreet", "Version"), "GUILD")
	local inInstance, instanceType = IsInInstance()
	if (instanceType ~= "pvp") and (instanceType ~= "arena") and (GetNumPartyMembers() > 0) then
		SendAddonMessage("GLDG", "QUERY:", "PARTY")
	end
	local inInstance, instanceType = IsInInstance()
	if (instanceType ~= "pvp") and (instanceType ~= "arena") and (GetNumRaidMembers() > 0) then
		SendAddonMessage("GLDG", "QUERY:", "RAID")
	end
end

--------------------------
-- _31_ conversion
--------------------------
function GLDG_Convert()
	local toConvert = {}
	local i = 0

	-- find channels, guilds and friends for all realms
	for p in pairs(GLDG_Data) do
		-- GLDG_Print("Iterator "..tostring(i)..": ["..tostring(p).."] - ["..tostring(GLDG_Data[p]).."]")
		i = i + 1

		local _, _, realm, channel = string.find(tostring(p), "(.*)%s%-%schannel%s%-%s(.*)")
		if (realm ~= nil) then
			if (not toConvert[realm]) then
				toConvert[realm] = {}
			end
			if (not toConvert[realm].channels) then
				toConvert[realm].channels = {}
			end
			toConvert[realm].channels[channel] = channel

			--GLDG_Print("Marking realm ["..tostring(realm).."] channel ["..tostring(channel).."] for conversion")
		else
			local _, _, realm2 = string.find(tostring(p), "(.*)%s%-%-%sfriends")
			if (realm2 ~= nil) then
				if (not toConvert[realm2]) then
					toConvert[realm2] = {}
				end
				if (not toConvert[realm2].friends) then
					toConvert[realm2].friends = true
				end

				--GLDG_Print("Marking realm ["..tostring(realm2).."] friends for conversion")
			else
				local _, _, realm3, guild = string.find(tostring(p), "(.*)%s%-%s(.*)")
				if (realm3 ~= nil) then
					if (not toConvert[realm3]) then
						toConvert[realm3] = {}
					end
					if (not toConvert[realm3].guilds) then
						toConvert[realm3].guilds = {}
					end
					toConvert[realm3].guilds[guild] = guild

					--GLDG_Print("Marking realm ["..tostring(realm3).."] guild ["..tostring(guild).."] for conversion")
				end
			end
		end
	end

	-- treat marked entries
	for r in pairs(toConvert) do
		--GLDG_Print("Converting realm ["..tostring(r).."]")

		if (toConvert[r].guilds) then
			for g in pairs(toConvert[r].guilds) do
				GLDG_Convert_Guild(r, g)
			end
		else
			--GLDG_Print("  No guilds to convert for realm ["..tostring(r).."]")
		end

		if (toConvert[r].channels) then
			for c in pairs(toConvert[r].channels) do
				GLDG_Convert_Channel(r, c)
			end
		else
			--GLDG_Print("  No channels to convert for realm ["..tostring(r).."]")
		end

		if (toConvert[r].friends) then
			GLDG_Convert_Friends(r)
		else
			--GLDG_Print("  No friends to convert for realm ["..tostring(r).."]")
		end
	end

	-- cleanup guild information
	for p in pairs(GLDG_DataChar) do
		if (not GLDG_DataChar[p].guild) then
			if (GLDG_DataChar[p].rank) then
				GLDG_DataChar[p].rank = nil
			end
			if (GLDG_DataChar[p].rankname) then
				GLDG_DataChar[p].rankname = nil
			end
			if (GLDG_DataChar[p].pNote) then
				GLDG_DataChar[p].pNote = nil
			end
			if (GLDG_DataChar[p].oNote) then
				GLDG_DataChar[p].oNote = nil
			end
		end
	end

	-- force channel names to lower case
	GLDG_Convert_ChannelNames()

	-- remove channel and friend specific colours
	GLDG_Convert_Colours()
end

------------------------------------------------------------
function GLDG_Convert_Guild(realm, guild)
	GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertGuild1.."["..tostring(guild).."]"..GLDG_TXT.convertGuild2.."["..tostring(realm).."]"..GLDG_TXT.convertGuild3)

	local key = realm.." - "..guild
	local newKey = "Realm: "..realm

	if (not GLDG_Data[newKey]) then
		GLDG_Data[newKey] = {}
	end

	if (GLDG_Data[key]) then
		for name in pairs(GLDG_Data[key]) do
			if (name ~= nil) then
				--GLDG_Print("     Treating char ["..Ambiguate(name, "guild").."]")
				if (not GLDG_Data[newKey][name]) then
					GLDG_Data[newKey][name] = {}
				end

				for entry in pairs(GLDG_Data[key][name]) do
					if (entry and GLDG_Data[key][name][entry]) then
						if (GLDG_Data[newKey][name][entry]) then
							if (GLDG_Data[newKey][name][entry] == GLDG_Data[key][name][entry]) then
								--GLDG_Print("      Entry ["..entry.."] = ["..tostring(GLDG_Data[key][name][entry]).."] already exists")
							else
								--GLDG_Print("      Conflict between ["..entry.."] = ["..tostring(GLDG_Data[key][name][entry]).."] and ["..entry.."] = ["..GLDG_Data[newKey][name][entry].."]")
								-- what to do?
							end
						else
							--GLDG_Print("      Copying ["..entry.."] = ["..tostring(GLDG_Data[key][name][entry]).."]")
							GLDG_Data[newKey][name][entry] = GLDG_Data[key][name][entry]
						end
					else
						--GLDG_Print("      Nil found in either ["..tostring(entry).."] or ["..tostring(GLDG_Data[key][name][entry]).."]")
					end
				end
				GLDG_Data[newKey][name].guild = guild

			else
				--GLDG_Print("     Nil instead of char")
			end
		end

		-- remove old entry
		GLDG_Data[key] = nil
	else
		--GLDG_Print("     No data found for guild ["..guild.."] on realm ["..realm.."]")
	end
end

------------------------------------------------------------
function GLDG_Convert_Channel(realm, channel)
	GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertChannel1.."["..tostring(channel).."]"..GLDG_TXT.convertChannel2.."["..tostring(realm).."]"..GLDG_TXT.convertChannel3)


	local key = realm.." - channel - "..channel
	local newKey = "Realm: "..realm

	if (not GLDG_Data[newKey]) then
		GLDG_Data[newKey] = {}
	end

	local newChannel = string.lower(channel)

	if (GLDG_Data[key]) then

		for name in pairs(GLDG_Data[key]) do
			if (name ~= nil) then
				--GLDG_Print("     Treating char ["..Ambiguate(name, "guild").."]")
				if (not GLDG_Data[newKey][name]) then
					GLDG_Data[newKey][name] = {}
				end

				for entry in pairs(GLDG_Data[key][name]) do
					if (entry and GLDG_Data[key][name][entry]) then
						if (GLDG_Data[newKey][name][entry]) then
							if (GLDG_Data[newKey][name][entry] == GLDG_Data[key][name][entry]) then
								--GLDG_Print("      Entry ["..entry.."] = ["..tostring(GLDG_Data[key][name][entry]).."] already exists")
							else
								--GLDG_Print("      Conflict between ["..entry.."] = ["..tostring(GLDG_Data[key][name][entry]).."] and ["..entry.."] = ["..GLDG_Data[newKey][name][entry].."]")
								-- what to do?
							end
						else
							--GLDG_Print("      Copying ["..entry.."] = ["..tostring(GLDG_Data[key][name][entry]).."]")
							GLDG_Data[newKey][name][entry] = GLDG_Data[key][name][entry]
						end
					else
						--GLDG_Print("      Nil found in either ["..tostring(entry).."] or ["..tostring(GLDG_Data[key][name][entry]).."]")
					end
				end
				if (not GLDG_Data[newKey][name].channels) then
					GLDG_Data[newKey][name].channels = {}
				end
				GLDG_Data[newKey][name].channels[newChannel] = newChannel
			else
				--GLDG_Print("     Nil instead of char")
			end
		end

		-- remove old entry
		GLDG_Data[key] = nil
	else
		--GLDG_Print("     No data found for channel ["..channel.."] on realm ["..realm.."]")
	end

end

------------------------------------------------------------
function GLDG_Convert_Friends(realm)
	GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertFriends1.."["..tostring(realm).."]"..GLDG_TXT.convertFriends2)

	local key = realm.." -- friends"
	local newKey = "Realm: "..realm

	if (not GLDG_Data[newKey]) then
		GLDG_Data[newKey] = {}
	end

	-- copy data of friends
	if (GLDG_Data[key] and GLDG_Data[key].friends) then

		for name in pairs(GLDG_Data[key].friends) do
			if (name ~= nil) then
				--GLDG_Print("     Treating char ["..Ambiguate(name, "guild").."]")
				if (not GLDG_Data[newKey][name]) then
					GLDG_Data[newKey][name] = {}
				end

				for entry in pairs(GLDG_Data[key].friends[name]) do
					if (entry and GLDG_Data[key].friends[name][entry]) then
						if (GLDG_Data[newKey][name][entry]) then
							if (GLDG_Data[newKey][name][entry] == GLDG_Data[key].friends[name][entry]) then
								--GLDG_Print("      Entry ["..entry.."] = ["..tostring(GLDG_Data[key].friends[name][entry]).."] already exists")
							else
								--GLDG_Print("      Conflict between ["..entry.."] = ["..tostring(GLDG_Data[key].friends[name][entry]).."] and ["..entry.."] = ["..GLDG_Data[newKey][name][entry].."]")
								-- what to do?
							end
						else
							--GLDG_Print("      Copying ["..entry.."] = ["..tostring(GLDG_Data[key].friends[name][entry]).."]")
							GLDG_Data[newKey][name][entry] = GLDG_Data[key].friends[name][entry]
						end
					else
						--GLDG_Print("      Nil found in either ["..tostring(entry).."] or ["..tostring(GLDG_Data[key].friends[name][entry]).."]")
					end
				end
				--if (not GLDG_Data[newKey][name].channels) then
				--	GLDG_Data[newKey][name].channels = {}
				--end
				--GLDG_Data[newKey][name].channels[newChannel] = newChannel
			else
				--GLDG_Print("     Nil instead of char")
			end
		end



	else
		--GLDG_Print("     No data found for friends data on realm ["..realm.."]")
	end

	-- set who has them on the friend's list
	if (GLDG_Data[key] and GLDG_Data[key].chars) then

		for name in pairs(GLDG_Data[key].chars) do
			for char in pairs(GLDG_Data[key].chars[name]) do
				if (not GLDG_Data[newKey][char]) then
					GLDG_Data[newKey][char] = {}
				end
				if (not GLDG_Data[newKey][char].friends) then
					GLDG_Data[newKey][char].friends = {}
				end
				GLDG_Data[newKey][char].friends[name] = name	-- will later be overwritten by friends note
			end
		end
	else
		--GLDG_Print("     No data found for friends mapping on realm ["..realm.."]")
	end

	-- remove old entry
	GLDG_Data[key] = nil
end

------------------------------------------------------------
function GLDG_Convert_ChannelNames()
	if (GLDG_Data.ChannelNames) then
		for p in pairs(GLDG_Data.ChannelNames) do
			local channelName = string.lower(GLDG_Data.ChannelNames[p])
			GLDG_Data.ChannelNames[p] = channelName
		end
	end
end

------------------------------------------------------------
function GLDG_Convert_Colours()
	-- todo: remove channel and friend specific colours once the elements have been removed as well
end

------------------------------------------------------------
function GLDG_Convert_Plausibility_Check(suppressOutput)
	local p
	local fixNeeded = false

	-- check for entries with both main and alt
	if not suppressOutput then
		GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertVerify1)
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
						GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertConflict1.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.convertConflict2.." ["..alt.."] "..GLDG_TXT.convertConflict3.." ["..GLDG_DataChar[alt].alt.."] "..GLDG_TXT.convertConflict4);
					end
				else
					-- ok, we could just de-main this char and we would be fine
					if not suppressOutput then
						GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertConflict1.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.convertConflict2.." ["..alt.."] "..GLDG_TXT.convertConflict5);
					end
				end
			else
				-- char is not main - strange
				if (GLDG_DataChar[alt].alt) then
					-- the apparent main is not main, but has a main of its own, we could just bend to that char
					if not suppressOutput then
						GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertConflict1.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.convertConflict2.." ["..alt.."] "..GLDG_TXT.convertConflict6.." ["..GLDG_DataChar[alt].alt.."] "..GLDG_TXT.convertConflict4);
					end
				else
					-- the apparent main is neither main nor has a main, we should probably just set it as main
					if not suppressOutput then
						GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertConflict1.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.convertConflict2.." ["..alt.."] "..GLDG_TXT.convertConflict7);
					end
				end
			end
		end
	end

	-- check for entries that are their own main
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].alt and GLDG_DataChar[p].alt == p) then
			fixNeeded = true
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertConflict1..GLDG_TXT.convertConflict11.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.convertConflict12)
		end
	end

	-- check for entries where an alt-link points to a char which doesn't exist
	if not suppressOutput then
		GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertVerify5)
	end
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].alt and not GLDG_DataChar[GLDG_DataChar[p].alt]) then
			fixNeeded = true
			if not suppressOutput then
				GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertConflict1..GLDG_TXT.convertConflict8.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.convertConflict9.." ["..GLDG_DataChar[p].alt.."] "..GLDG_TXT.convertConflict13)
			end
		end
	end

	-- check for entries where an alt-link points to a main that isn't main
	if not suppressOutput then
		GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertVerify2)
	end
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].alt and GLDG_DataChar[GLDG_DataChar[p].alt] and not GLDG_DataChar[GLDG_DataChar[p].alt].main) then
			fixNeeded = true
			if not suppressOutput then
				GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertConflict1..GLDG_TXT.convertConflict8.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.convertConflict9.." ["..GLDG_DataChar[p].alt.."] "..GLDG_TXT.convertConflict10)
			end
		end
	end

	if not suppressOutput then
		if fixNeeded then
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertVerify4)
		else
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertVerify3)
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
		GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertFix)
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
					GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertConflict1.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.convertConflict2.." ["..alt.."] "..GLDG_TXT.convertConflict3.." ["..GLDG_DataChar[alt].alt.."] "..GLDG_TXT.convertFix5);
				else
					-- ok, we could just de-main this char and we would be fine
					GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertConflict1.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.convertConflict2.." ["..alt.."] "..GLDG_TXT.convertFix1);
				end
				GLDG_DataChar[p].main = nil
				for q in pairs(GLDG_DataChar) do
					if GLDG_DataChar[q].alt and GLDG_DataChar[q].alt==p then
						GLDG_DataChar[q].alt = alt
						GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r    "..GLDG_TXT.convertFix2.." ["..q.."] "..GLDG_TXT.convertFix3.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.convertFix4.." ["..alt.."]");
					end
				end
			else
				-- char is not main - strange
				if (GLDG_DataChar[alt].alt) then
					-- the apparent main is not main, but has a main of its own, we could just bend to that char
					GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertConflict1.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.convertConflict2.." ["..alt.."] "..GLDG_TXT.convertConflict6.." ["..GLDG_DataChar[alt].alt.."] "..GLDG_TXT.convertFix7.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.convertFix8);
					GLDG_DataChar[p].main = nil
					GLDG_DataChar[p].alt = GLDG_DataChar[alt].alt
					for q in pairs(GLDG_DataChar) do
						if GLDG_DataChar[q].alt and GLDG_DataChar[q].alt==p then
							GLDG_DataChar[q].alt = GLDG_DataChar[alt].alt
							GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r    "..GLDG_TXT.convertFix2.." ["..q.."] "..GLDG_TXT.convertFix3.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.convertFix4.." ["..GLDG_DataChar[alt].alt.."]");
						end
					end
				else
					-- the apparent main is neither main nor has a main, we should probably just set the original character as main
					GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertConflict1.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.convertConflict2.." ["..alt.."] "..GLDG_TXT.convertFix6.." ["..Ambiguate(p, "guild").."]");
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
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertConflict1..GLDG_TXT.convertConflict11.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.convertFix12)
			GLDG_DataChar[p].alt = nil
		end
	end

	-- check for entries where an alt-link points to a char which doesn't exist
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].alt and not GLDG_DataChar[GLDG_DataChar[p].alt]) then
			fixNeeded = true
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertConflict1..GLDG_TXT.convertConflict8.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.convertConflict9.." ["..GLDG_DataChar[p].alt.."] "..GLDG_TXT.convertFix14)
			GLDG_DataChar[p].alt = nil
		end
	end

	-- check for entries where an alt-link points to a main that isn't main
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].alt and GLDG_DataChar[GLDG_DataChar[p].alt] and not GLDG_DataChar[GLDG_DataChar[p].alt].main) then
			fixNeeded = true
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertConflict1..GLDG_TXT.convertConflict8.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.convertConflict9.." ["..GLDG_DataChar[p].alt.."] "..GLDG_TXT.convertFix9)
			GLDG_DataChar[GLDG_DataChar[p].alt].main = true
		end
	end

	if fixNeeded then
		-- recurse
		if (GLDG_fixCount < 10) then
			GLDG_fixCount = GLDG_fixCount + 1
			fixNeeded = GLDG_Convert_Plausibility_Fix(true)

			if not suppressTitle then
					GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertFix10)
			end
		else
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertFix13)
		end
	else
		if not suppressTitle then
				GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.convertFix11)
		end
	end

	return fixNeeded
end

------------------------------------------------------------
function GLDG_Reset_Aliases()
	GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r Remove all saved aliases")
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].alias) then
			GLDG_DataChar[p].alias = nil
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r Alias from ["..Ambiguate(p, "guild").."] deleted")
		end
	end
end
------------------------------------------------------------
function GLDG_Convert_Unnew()
	GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.unnew1)
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].new) then
			GLDG_DataChar[p].new = nil
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.unnew2.." ["..Ambiguate(p, "guild").."]")
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
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.alertIsOn)
		end
		GLDG_Data.CheckedGuildAlert = true
	end
end

------------------------------------------------------------
function GLDG_PrepareAlertQuestion()
	StaticPopupDialogs["GLDG_GUILD_ALERT"] = {
		text = GLDG_TXT.alertQuestion,
		button1 = GLDG_TXT.alertOn,
		button2 = GLDG_TXT.alertLeave,
		OnAccept = function()
			SetCVar("guildMemberNotify", 1)
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.alertTurnedOn)
			end,
		OnCancel = function()
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.alertUnchanged)
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
					GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.cleanupRemoveGuild1.." ["..entry.."] "..GLDG_TXT.cleanupRemoveGuild2.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.cleanupRemoveGuild3)
				elseif (GLDG_CleanupMode == "friends" and GLDG_DataChar[p].friends and GLDG_DataChar[p].friends[entry]) then
					GLDG_DataChar[p].friends[entry] = nil
					GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.cleanupRemoveFriend1.." ["..entry.."] "..GLDG_TXT.cleanupRemoveFriend2.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.cleanupRemoveFriend3)
				elseif (GLDG_CleanupMode == "channel" and GLDG_DataChar[p].channels and GLDG_DataChar[p].channels[entry]) then
					GLDG_DataChar[p].channels[entry] = nil
					GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.cleanupRemoveChannel1.." ["..entry.."] "..GLDG_TXT.cleanupRemoveChannel2.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.cleanupRemoveChannel3)
				end
			end
		else
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.cleanupNotfound1.." ["..entry.."] "..GLDG_TXT.cleanupNotfound2.." ["..GLDG_CleanupMode.."]")
		end
	end

	-- retrigger channel and friends update (guild not needed, is done periodically)
	GLDG_CheckChannel()
	ShowFriends()

	GLDG_CleanupList = nil
	GLDG_CleanupMode = nil
end

------------------------------------------------------------
function GLDG_ClickOrphanCleanup()
	GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.cleanupOrphan)
	for p in pairs(GLDG_DataChar) do
		if (not GLDG_DataChar[p].main and
		    not GLDG_DataChar[p].alt and
		    not GLDG_DataChar[p].alias and
		    (not GLDG_DataChar[p].channels or GLDG_TableSize(GLDG_DataChar[p].channels)==0) and
		    (not GLDG_DataChar[p].friends or GLDG_TableSize(GLDG_DataChar[p].friends)==0)) then
			GLDG_DataChar[p] = nil
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.cleanupRemovedOrphan1.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.cleanupRemovedOrphan2)
		end
	end

	-- Hide the subframe window
	_G[GLDG_GUI.."CleanupSubEntries"]:Hide()

	-- re-enable buttons
	_G[GLDG_GUI.."CleanupGuild"]:Enable()
	_G[GLDG_GUI.."CleanupFriends"]:Enable()
	_G[GLDG_GUI.."CleanupChannel"]:Enable()
end

------------------------------------------------------------
--~~~ MSN1: New function to delete guildless characters, displays list and count after deletion
function GLDG_ClickGuildlessCleanup()
	guildless_count = 0
	GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.cleanupGuildless)
	for p in pairs(GLDG_DataChar) do
		if (not GLDG_DataChar[p].guild) then
			guildless_count = guildless_count + 1
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.cleanupRemovedGuildless1.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.cleanupRemovedGuildless2)			
--Delete the character
			GLDG_DataChar[p] = nil
		end
	end
	GLDG_Print("Amount of guildless players removed: "..guildless_count)
	
	-- Hide the subframe window
	_G[GLDG_GUI.."CleanupSubEntries"]:Hide()

	-- re-enable buttons
	_G[GLDG_GUI.."CleanupGuild"]:Enable()
	_G[GLDG_GUI.."CleanupFriends"]:Enable()
	_G[GLDG_GUI.."CleanupChannel"]:Enable()
end
--~~~~

------------------------------------------------------------
--~~~ MSN1: New function to display guildless characters, displays list of guildless, then count of guildless and with guild after deletion
function GLDG_ClickGuildlessDisplay()
	guildless_count = 0
	haveguild_count = 0
	total_count = 0
	GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.displayGuildless)
	for p in pairs(GLDG_DataChar) do
		if (not GLDG_DataChar[p].guild) then
			guildless_count = guildless_count + 1
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..GLDG_TXT.displayRemovedGuildless1.." ["..Ambiguate(p, "guild").."] "..GLDG_TXT.displayRemovedGuildless2)			
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
--~~~~

------------------------------------------------------------
function GLDG_ShowCleanupEntries(frame)
	if not GLDG_CleanupList or not GLDG_CleanupMode then return end

	-- Set frame and linename
	local name = frame:GetParent():GetName()
	-- Set title
	if (GLDG_TableSize(GLDG_CleanupList) > 0) then
		if GLDG_CleanupMode == "guild" then
			_G[name.."Header"]:SetText(GLDG_TXT.cleanupHeaderEntryGuild)
		elseif GLDG_CleanupMode == "friends" then
			_G[name.."Header"]:SetText(GLDG_TXT.cleanupHeaderEntryFriends)
		elseif GLDG_CleanupMode == "channel" then
			_G[name.."Header"]:SetText(GLDG_TXT.cleanupHeaderEntryChannel)
		else
			_G[name.."Header"]:SetText("")
		end
	else
		if GLDG_CleanupMode == "guild" then
			_G[name.."Header"]:SetText(GLDG_TXT.cleanupHeaderNoEntryGuild)
		elseif GLDG_CleanupMode == "friends" then
			_G[name.."Header"]:SetText(GLDG_TXT.cleanupHeaderNoEntryFriends)
		elseif GLDG_CleanupMode == "channel" then
			_G[name.."Header"]:SetText(GLDG_TXT.cleanupHeaderNoEntryChannel)
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
	-- todo: confirm dialog

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

        InterfaceOptions_AddCategory(panel);
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
function GLDG_StartupCheck()
	-- are we done?
	if bit.band(GLDG_InitCheck, 7) == 0 and bit.band(GLDG_InitCheck, 56) ~= 0 then
		-- nothing pending and at least one complete -> assume we're done
		--GLDG_Print("All done")

		if (GLDG_TableSize(GLDG_ChangesText)>0 and GLDG_Data.GuildSettings.DeltaPopup==true) then
			-- display text
			GLDG_list = GLDG_ChangesText
			GLDG_CreatePasteListFrame()
			GLDG_PasteList.List:Show();
		end
		GLDG_ChangesText = nil
	end
end

------------------------------------------------------------
function GLDG_AddToStartupList(entry)
	if not GLDG_ChangesText then return end
	local index = GLDG_TableSize(GLDG_ChangesText) + 1
	GLDG_ChangesText[index] = entry
end


-------------------------------------------------------------

--------------------------
-- _36_ guildconfig
--------------------------

function GLDG_generateConfigString()
	local a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,az = nil
	if GLDG_Data.GuildSettings.GreetAsMain==true then a = 1 else a=0 end
	if GLDG_Data.GuildSettings.Randomize==true then b = 2 else b=0 end
	if GLDG_Data.GuildSettings.Whisper==true then c = 2^2 else c=0 end
	if GLDG_Data.GuildSettings.WhisperLevelup==true then d = 2^3 else d=0 end
	if GLDG_Data.GuildSettings.IncludeOwn==true then e = 2^4 else e=0 end
	if GLDG_Data.GuildSettings.AutoAssign==true then f = 2^5 else f=0 end
	if GLDG_Data.GuildSettings.AutoAssignEgp==true then g = 2^6 else g=0 end
	if GLDG_Data.GuildSettings.AutoAssignAlias==true then h = 2^7 else h=0 end
	if GLDG_Data.GuildSettings.ListNames==true then i = 2^8 else i=0 end
	if GLDG_Data.GuildSettings.ListNamesOff==true then j = 2^9 else j=0 end
	if GLDG_Data.GuildSettings.ListLevelUp==true then k = 2^10 else k=0 end
	if GLDG_Data.GuildSettings.ListLevelUpOff==true then l = 2^11 else l=0 end
	if GLDG_Data.GuildSettings.ListAchievments==true then m = 2^12 else m=0 end
	if GLDG_Data.GuildSettings.ListQuit==true then n = 2^13 else n=0 end
	if GLDG_Data.GuildSettings.ExtendChat==true then o = 2^14 else o=0 end
	if GLDG_Data.GuildSettings.ExtendIgnored==true then p = 2^15 else p=0 end
	if GLDG_Data.GuildSettings.ExtendMain==true then q = 2^16 else q=0 end
	if GLDG_Data.GuildSettings.ExtendAlias==true then r = 2^17 else r=0 end
	if GLDG_Data.GuildSettings.AddPostfix==true then s = 2^18 else s=0 end
	if GLDG_Data.GuildSettings.ShowWhoSpam==true then t = 2^19 else t=0 end
	if GLDG_Data.GuildSettings.SupressGreet==true then u = 2^20 else u=0 end
	if GLDG_Data.GuildSettings.SupressJoin==true then v = 2^21 else v=0 end
	if GLDG_Data.GuildSettings.SupressLevel==true then w = 2^22 else w=0 end
	if GLDG_Data.GuildSettings.SupressRank==true then x = 2^23 else x=0 end
	if GLDG_Data.GuildSettings.SupressAchievment==true then y = 2^24 else y=0 end
	if GLDG_Data.GuildSettings.NoGratsOnLogin==true then z = 2^25 else z=0 end
	if GLDG_Data.GuildSettings.DeltaPopup == true then az = 2^26 else az=0 end
	if GLDG_Data.GuildSettings.RelogTime then GLDG_CONFIG_STRING_B = string.format("%x",math.floor(GLDG_Data.GuildSettings.RelogTime)) end
	if GLDG_Data.GuildSettings.MinLevelUp then GLDG_CONFIG_STRING_C = string.format("%x",math.floor(GLDG_Data.GuildSettings.MinLevelUp)) end
	GLDG_CONFIG_STRING_A = string.format("%x",a+b+c+d+e+f+g+h+i+j+k+l+m+n+o+p+q+r+s+t+u+v+w+x+y+z+az)
	GLDG_CONFIG_STRING_D = mod((tonumber("0x"..GLDG_CONFIG_STRING_A, 16)+1) * (tonumber("0x"..GLDG_CONFIG_STRING_B, 16)+1) * (tonumber("0x"..GLDG_CONFIG_STRING_C, 16)+1),33)
	GLDG_CONFIG_STRING = "{GG:"..GLDG_CONFIG_STRING_A..":"..GLDG_CONFIG_STRING_B..":"..GLDG_CONFIG_STRING_C..":"..GLDG_CONFIG_STRING_D.."}"
	if GLDG_unique_GuildName then
		GLDG_Data[GLDG_unique_GuildName] = GLDG_Data.GuildSettings
		GLDG_Data[GLDG_unique_GuildName].GLDG_CONFIG_STRING = GLDG_CONFIG_STRING
	end
	if (GLDG_CONFIG_STRING ~= GLDG_config_from_guild) and IsGuildLeader() then
		_G[GLDG_GUI.."SettingsGeneralWriteGuildString"]:Enable()
	else
		_G[GLDG_GUI.."SettingsGeneralWriteGuildString"]:Disable()
	end
end

function GLDG_readConfigString_change(value)
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


function GLDG_readConfigString()
	GLDG_ginfotxt = GetGuildInfoText()
	if (GLDG_CONFIG_STRING ~= nil) and (GLDG_CONFIG_STRING ~= GLDG_config_from_guild) and IsGuildLeader() then
		_G[GLDG_GUI.."SettingsGeneralWriteGuildString"]:Enable()
	else
		_G[GLDG_GUI.."SettingsGeneralWriteGuildString"]:Disable()
	end
	local gstringstart = string.find(GLDG_ginfotxt, "{GG", 1)
	local gstring1,gstring2,gstring3,gstring4 = nil
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
			GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..string.format(L["ChatMsg/Config string found. GuildGreet using default settings from %s!"],Ambiguate(GLDG_GuildLeader, "guild")))
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
						GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..L["ChatMsg/Config string not found."].." \r\n"..L["ChatMsg/GuildGreet using default settings!"])
						GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..L["ChatMsg/Note to the guild master to create the config string"].." \r\n"..L["ChatMsg/To set the config string ..."])
						GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] = date("%m/%d/%y")
						GLDG_Data[GLDG_unique_GuildName.." lastmessage"] = 3
					end
				else
					if (GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] ~= date("%m/%d/%y")) or (GLDG_Data[GLDG_unique_GuildName.." lastmessage"] ~= 2) then
						GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..L["ChatMsg/Config string not found."].." \r\n"..L["ChatMsg/GuildGreet using default settings!"])
						GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] = date("%m/%d/%y")
						GLDG_Data[GLDG_unique_GuildName.." lastmessage"] = 2
					end				
				end
			end
			if GLDG_config_from_guild == "corrupted" then
				if IsGuildLeader() then
					--if (GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] ~= date("%m/%d/%y")) or (GLDG_Data[GLDG_unique_GuildName.." lastmessage"] ~= 4) then
						GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..L["ChatMsg/The config string seems to be corrupted. Please generating a new one."].." \r\n"..L["ChatMsg/GuildGreet using default settings!"])
					--	GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] = date("%m/%d/%y")
					--	GLDG_Data[GLDG_unique_GuildName.." lastmessage"] = 4
					--end
				else
					if (GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] ~= date("%m/%d/%y")) or (GLDG_Data[GLDG_unique_GuildName.." lastmessage"] ~= 5) then
						GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..string.format(L["ChatMsg/The config string seems to be corrupted. Please inform %s!"],Ambiguate(GLDG_GuildLeader, "guild")).." \r\n"..L["ChatMsg/GuildGreet using default settings!"])
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
					GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..L["ChatMsg/GuildGreet using your own settings!"])
					GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] = date("%m/%d/%y")
					GLDG_Data[GLDG_unique_GuildName.." lastmessage"] = 6
				end
				if IsGuildLeader() then
					if (GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] ~= date("%m/%d/%y")) or (GLDG_Data[GLDG_unique_GuildName.." lastmessage"] ~= 7) then
						GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..L["ChatMsg/Note to the guild master to create the config string"].." \r\n"..L["ChatMsg/To set the config string ..."])
						GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] = date("%m/%d/%y")
						GLDG_Data[GLDG_unique_GuildName.." lastmessage"] = 7
					end
				end
			end
			if GLDG_config_from_guild == "corrupted" then
				if IsGuildLeader() then
					--if (GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] ~= date("%m/%d/%y")) or (GLDG_Data[GLDG_unique_GuildName.." lastmessage"] ~= 8) then
						GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..L["ChatMsg/GuildGreet using your own Settings. But the config string seems to be corrupted. Please generating a new one."])
					--	GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] = date("%m/%d/%y")
					--	GLDG_Data[GLDG_unique_GuildName.." lastmessage"] = 8
					--end
				else
					if (GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] ~= date("%m/%d/%y")) or (GLDG_Data[GLDG_unique_GuildName.." lastmessage"] ~= 9) then
						GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..string.format(L["ChatMsg/GuildGreet using your own Settings. But the config string seems to be corrupted. Please inform %s!"],Ambiguate(GLDG_GuildLeader, "guild")))
						GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] = date("%m/%d/%y")
						GLDG_Data[GLDG_unique_GuildName.." lastmessage"] = 9
					end
				end
			end
			if (GLDG_config_from_guild ~= "corrupted") and (GLDG_config_from_guild ~= "not found") then
				if (GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] ~= date("%m/%d/%y")) or (GLDG_Data[GLDG_unique_GuildName.." lastmessage"] ~= 10) then
					GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..L["ChatMsg/GuildGreet using your own settings (But a config string is in the guild info available)."])
					GLDG_Data[GLDG_unique_GuildName.." lastmessagedate"] = date("%m/%d/%y")
					GLDG_Data[GLDG_unique_GuildName.." lastmessage"] = 10
				end
			end
		end	
	end	
end

function GLDG_WriteGuildString()
	GLDG_ginfotxt = GetGuildInfoText()
	
	if not GLDG_CONFIG_STRING then GLDG_generateConfigString() end
	local new_ginfotxt = nil

	if GLDG_config_from_guild == nil then GLDG_readConfigString() end

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
	
	if strlen(new_ginfotxt)<=499 then
		GLDG_config_from_guild = GLDG_CONFIG_STRING
		GLDG_corrupted_config_from_guild = nil
		SetGuildInfoText(new_ginfotxt)
		_G[GLDG_GUI.."SettingsGeneralWriteGuildString"]:Disable()
		GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..L["ChatMsg/Guild info written successfully!"])
		GLDG_ginfotxt = nil
		new_ginfotxt = nil
	else
		local tolong = strlen(new_ginfotxt)-499
		GLDG_Print(GLDG_Data.colours.help..GLDG_NAME..":|r "..string.format(L["ChatMsg/The guild info is too long..."],tolong))
		GLDG_ginfotxt = nil
		new_ginfotxt = nil
	end
end