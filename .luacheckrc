-- Simple Luacheck configuration for WoW Addon
std = "lua51"

-- Don't require unused function parameters (common in WoW addon callbacks)
unused_args = false

-- Global variables that our addon creates
globals = {
    "GLDG",
    "GLDG_Data", "GLDG_DataChar", "GLDG_DataFriends", "GLDG_DataChannel",
    "GLDG_NAME", "GLDG_VERSION", "GLDG_AUTHOR", "GLDG_GUI", "GLDG_LIST", "GLDG_COLOUR",
    "GLDG_config_from_guild", "GLDG_corrupted_config_from_guild",
    "GLDG_CONFIG_STRING", "GLDG_ginfotxt", "GLDG_GuildLeader",
    "GLDG_CleanupList", "GLDG_CleanupMode", "GLDG_NumSubRows",
    "GLDG_autoGreeted", "GLDG_RosterImportRunning",
    
    -- Frame tables and UI globals
    "GLDG_Tab2Frame", "GLDG_SubTab2Frame",
    
    -- Pattern globals for message parsing
    "GLDG_ONLINE", "GLDG_OFFLINE", "GLDG_JOINED", "GLDG_PROMO",
    
    -- Additional globals referenced in code
    "GLDG_GREET", "GLDG_BYE", "GLDG_unique_GuildName", 
    "GLDG_Greet", "GLDG_Bye", "GLDG_autoGreet", "GLDG_autoBye",
    "GLDG_GreetAnnounce", "GLDG_ByeAnnounce",
    
    -- Global functions for backwards compatibility
    "GLDG_Print", "GLDG_WriteGuildString", "GLDG_readConfigString",
    "GLDG_RosterImport", "GLDG_RosterImportFull", "GLDG_TableSize",
    "GLDG_GetWords", "GLDG_Convert", "GLDG_SendGreet", "GLDG_ParseCustomMessage",
    "GLDG_InitColors", "GLDG_GetColorCode", "GLDG_generateConfigString",
    "GLDG_InitGreet", "GLDG_ClickGuildAliasSet", "GLDG_ClickGuildAliasClear",
    "GLDG_OnEvent", "GLDG_OnLoad", "GLDG_PrepareAlertQuestion",
    "GLDG_ShowCleanupEntries", "GLDG_ClickCleanupEntry",
    "GLDG_ClickOrphanCleanup", "GLDG_ClickGuildlessCleanup", 
    "GLDG_ClickGuildlessDisplay", "GLDG_AddToStartupList", "GLDG_OnLoadOptions",
    "L"
}

-- Read-only global functions from WoW API and Ace3
read_globals = {
    -- LibStub and Ace3
    "LibStub",
    
    -- Standard Lua (WoW modifications)
    "string", "table", "math", "pairs", "ipairs", "next", "type", 
    "tonumber", "tostring", "strlen", "strsub", "strfind", "strupper", 
    "strlower", "format", "gsub", "gmatch", "match",
    
    -- WoW Error Message Patterns
    "ERR_FRIEND_ONLINE_SS", "ERR_FRIEND_OFFLINE_S", "ERR_GUILD_JOIN_S", 
    "ERR_GUILD_PROMOTE_SSS",
    
    -- WoW API functions
    "GetGuildInfoText", "SetGuildInfoText", "GetNumGuildMembers", "GetGuildRosterInfo",
    "GetFriendInfo", "GetNumFriends", "ShowFriends", "C_FriendList",
    "UnitName", "UnitClass", "UnitLevel", "UnitGUID", "UnitIsPlayer",
    "GetTime", "time", "date", "GetRealmName", "Ambiguate",
    "PlaySound", "PlaySoundFile", "SendChatMessage", "GetDefaultLanguage",
    "IsInGuild", "GetGuildName", "CanEditGuildInfo", "CanViewGuildInfo",
    "CreateFrame", "UIParent", "GameTooltip", "StaticPopupDialogs",
    "StaticPopup_Show", "StaticPopup_Hide", "FauxScrollFrame_Update",
    "FauxScrollFrame_GetOffset", "ChatFrame_AddMessageEventFilter",
    "ChatFrame_RemoveMessageEventFilter", "InterfaceOptions_AddCategory",
    "Settings", "InterfaceOptionsFrame", "_G",
    
    -- WoW Events and Constants
    "GUILD_ROSTER_UPDATE", "GUILD_MOTD", "CHAT_MSG_GUILD",
    "ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_LOGOUT",
    "FRIENDLIST_UPDATE", "WHO_LIST_UPDATE", "ChatFrame1",
    "DEFAULT_CHAT_FRAME", "GUILD", "RAID", "PARTY", "SAY", "YELL", "WHISPER"
}

-- Ignore some warnings that are common in WoW addons
ignore = {
    "212", -- Unused argument (self is common in methods)
    "213", -- Unused loop variable  
    "512", -- Loop can be executed at most once
    "611", -- Line contains only whitespace
    "612", -- Line contains trailing whitespace
}

-- Set line length limit
max_line_length = 120

-- Specific overrides for different file types
files = {}

-- Locale files can have undefined globals
files["lang/"] = {
    ignore = {"111", "112", "113"}
}

-- Library files should allow GLDG as a global
files["libs/"] = {
    allow_defined_top = true
}