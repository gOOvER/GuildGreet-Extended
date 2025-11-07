-- Luacheck configuration for WoW Addons
-- https://luacheck.readthedocs.io/en/stable/config.html

std = "lua51"

-- Allow unused self parameter
self = false

-- Global WoW API functions and variables
read_globals = {
    -- Standard Lua
    "string", "table", "math", "pairs", "ipairs", "next", "type", "tonumber", "tostring",
    "print", "error", "assert", "pcall", "xpcall", "strlen", "strsub", "strfind",
    "strupper", "strlower", "format", "gsub", "gmatch", "match",
    
    -- WoW Global API
    "GetGuildInfoText", "SetGuildInfoText", "GetNumGuildMembers", "GetGuildRosterInfo",
    "GetFriendInfo", "GetNumFriends", "ShowFriends",
    "UnitName", "UnitClass", "UnitLevel", "UnitGUID", "UnitIsPlayer",
    "GetTime", "time", "date",
    "PlaySound", "PlaySoundFile",
    "SendChatMessage", "GetDefaultLanguage",
    "IsInGuild", "GetGuildName", "CanEditGuildInfo", "CanViewGuildInfo",
    "GetRealmName", "GetNormalizedRealmName", "GetAutoCompleteRealms",
    
    -- WoW Frame/UI API
    "CreateFrame", "UIParent", "GameTooltip", "WorldFrame",
    "InterfaceOptionsFrame_OpenToCategory", "InterfaceOptions_AddCategory",
    "StaticPopupDialogs", "StaticPopup_Show", "StaticPopup_Hide",
    "FauxScrollFrame_Update", "FauxScrollFrame_GetOffset", "HybridScrollFrame_GetOffset",
    "GameFontNormal", "GameFontHighlight", "GameFontDisable",
    
    -- WoW Events
    "GUILD_ROSTER_UPDATE", "GUILD_MOTD", "CHAT_MSG_GUILD",
    "ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_LOGOUT",
    "FRIENDLIST_UPDATE", "WHO_LIST_UPDATE",
    
    -- WoW Chat
    "ChatFrame1", "DEFAULT_CHAT_FRAME", "ChatFrame_AddMessageEventFilter",
    "ChatFrame_RemoveMessageEventFilter",
    
    -- WoW Variables/Constants
    "GUILD", "RAID", "PARTY", "SAY", "YELL", "WHISPER",
    "LE_PARTY_CATEGORY_HOME", "LE_PARTY_CATEGORY_INSTANCE",
    
    -- Ace3 Libraries  
    "LibStub",
    
    -- WoW Specific Functions
    "Ambiguate", "GetPlayerInfoByGUID",
    
    -- Additional WoW APIs for newer versions
    "C_FriendList", "C_GuildInfo", "C_ChatInfo",
    "Settings", "InterfaceOptionsFrame",
    "_G"
}

-- Global variables that are written to (addon namespace)
globals = {
    "GLDG", "GLDG_Data", "GLDG_DataChar", "GLDG_DataFriends", "GLDG_DataChannel",
    "GLDG_NAME", "GLDG_VERSION", "GLDG_AUTHOR",
    "GLDG_GUI", "GLDG_config_from_guild", "GLDG_corrupted_config_from_guild",
    "GLDG_CONFIG_STRING", "GLDG_ginfotxt",
    "GLDG_CleanupList", "GLDG_CleanupMode", "GLDG_NumSubRows",
    "GLDG_autoGreeted", "GLDG_RosterImportRunning", "GLDG_GuildLeader",
    
    -- Global functions (backwards compatibility)
    "GLDG_Print", "GLDG_WriteGuildString", "GLDG_readConfigString",
    "GLDG_RosterImport", "GLDG_RosterImportFull", "GLDG_TableSize",
    "GLDG_GetWords", "GLDG_Convert", "GLDG_SendGreet", "GLDG_ParseCustomMessage",
    "GLDG_InitColors", "GLDG_GetColorCode", "GLDG_generateConfigString",
    "GLDG_InitGreet", "GLDG_ClickGuildAliasSet", "GLDG_ClickGuildAliasClear",
    
    -- Event handlers and GUI functions
    "GLDG_OnEvent", "GLDG_OnLoad", "GLDG_PrepareAlertQuestion",
    "GLDG_ShowCleanupEntries", "GLDG_ClickCleanupEntry",
    "GLDG_ClickOrphanCleanup", "GLDG_ClickGuildlessCleanup", "GLDG_ClickGuildlessDisplay",
    "GLDG_AddToStartupList", "GLDG_OnLoadOptions",
    
    -- Localization
    "L"
}

-- Exclude some checks that are problematic with WoW addons
ignore = {
    "212", -- Unused argument (self parameter is common in WoW)
    "213", -- Unused loop variable
    "512", -- Loop can be executed at most once
    "611", -- Line contains only whitespace
    "612", -- Line contains trailing whitespace  
    "614", -- Trailing whitespace in comment
    "621", -- Inconsistent indentation
    "631", -- Line is too long
}

-- Allow longer lines for some cases
max_line_length = 120

-- Specific file configurations
files["lang/*.lua"] = {
    ignore = {"111", "112", "113", "212", "213"}, -- Allow undefined globals in locale files
    globals = {"L"}
}

files["libs/*.lua"] = {
    ignore = {"212", "213"}, -- Allow unused self in library files
    globals = {"GLDG"}
}