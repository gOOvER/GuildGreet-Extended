-- Help Tooltips
GLDG_TXT.elements = {}
GLDG_TXT.elements.name = {}
GLDG_TXT.elements.tip = {}

GLDG_TXT.elements.name.GuildGreetListTitle	= "Greet list"
GLDG_TXT.elements.tip.GuildGreetListTitle	= "This list shows characters that need to be greeted or congratulated.\r\nLeft clicking on an entry will greet or congratulate the player.\r\nRight clicking an entry will remove the character without greeting.\r\nRight clicking the title will clear all characters without greeting."
GLDG_TXT.elements.name.GuildGreetListClose	= "Clear greet list"
GLDG_TXT.elements.tip.GuildGreetListClose	= "Click the close button to clear the greet list without greeting or congratulating people."

GLDG_TXT.elements.name.Tab1	= GLDG_TXT.TabSettings
GLDG_TXT.elements.tip.Tab1	= "Configures the features of the addon"
GLDG_TXT.elements.name.Tab2	= GLDG_TXT.TabGreetings
GLDG_TXT.elements.tip.Tab2	= "Define the phrases to be used to greet people. Define customer phrase sets."
GLDG_TXT.elements.name.Tab3	= GLDG_TXT.TabPlayers
GLDG_TXT.elements.tip.Tab3	= "Manage main and alt characters"
GLDG_TXT.elements.name.Tab4	= GLDG_TXT.TabCleanup
GLDG_TXT.elements.tip.Tab4	= "Cleanup stale characters"
GLDG_TXT.elements.name.Tab5	= GLDG_TXT.TabColour
GLDG_TXT.elements.tip.Tab5	= "Define colours to be used"
GLDG_TXT.elements.name.Tab6	= GLDG_TXT.TabTodo
GLDG_TXT.elements.tip.Tab6	= "Show todo list, version history and instructions on how to use the addon."

GLDG_TXT.elements.name.SettingsTab1	= GLDG_TXT.SubTabGeneral
GLDG_TXT.elements.tip.SettingsTab1	= "Settings of the addon, whom to greet, when to greet, list sizes, etc."
GLDG_TXT.elements.name.SettingsTab2	= GLDG_TXT.SubTabChat
GLDG_TXT.elements.tip.SettingsTab2	= "Configures which messages are printed to the chat"
GLDG_TXT.elements.name.SettingsTab3	= GLDG_TXT.SubTabGreeting
GLDG_TXT.elements.tip.SettingsTab3	= "Defining some detailed greeting parameters"
GLDG_TXT.elements.name.SettingsTab4	= GLDG_TXT.SubTabDebug
GLDG_TXT.elements.tip.SettingsTab4	= "Configure the GuildGreetDump addon in order to define how debug information should be dumped"
GLDG_TXT.elements.name.SettingsTab5	= GLDG_TXT.SubTabOther
GLDG_TXT.elements.tip.SettingsTab5	= "Reserved for future extensions"

GLDG_TXT.elements.name.SettingsGeneralWriteGuildString	= "Write config string"
GLDG_TXT.elements.tip.SettingsGeneralWriteGuildString	= "Press this button to write the config string to the guild info. \r\n(only settings with *)"
GLDG_TXT.elements.name.SettingsGeneralRelogSlider	= "Reloge time"
GLDG_TXT.elements.tip.SettingsGeneralRelogSlider	= "Define whether characters that relog are always shown in the greeting list or only if they have been offline for at least the defined time in minutes"
GLDG_TXT.elements.name.SettingsGeneralMinLevelUpSlider	= "Level-up limit"
GLDG_TXT.elements.tip.SettingsGeneralMinLevelUpSlider	= "Define, which level a character needs to have reached before he is congratulated when reaching a new level. If this setting is zero, each new level will be congratulated for."
GLDG_TXT.elements.name.SettingsGeneralUpdateTimeSlider	= "Guild roster updates"
GLDG_TXT.elements.tip.SettingsGeneralUpdateTimeSlider	= "Define, whether the guild roster is only reparsed on events or at fixed intervals.\r\nPolling at fixed intervals may increase your communication load."
GLDG_TXT.elements.name.SettingsGeneralAutoAssignBox	= "Auto Assign"
GLDG_TXT.elements.tip.SettingsGeneralAutoAssignBox	= "If this setting is enabled, the guild notes and officer notes will be parsed for entries of the form 'Main' and 'alt-<main name>' to automatically manage main and alt names for your guild members."
GLDG_TXT.elements.name.SettingsGeneralAutoAssignEgpBox	= "Auto Assign (EGP)"
GLDG_TXT.elements.tip.SettingsGeneralAutoAssignEgpBox	= "If this setting is enabled, the officer notes will be parsed for entries written by the EGP addon (number for mains, main name for alts) to automatically manage main and alt names for your guild members."
GLDG_TXT.elements.name.SettingsGeneralAutoAssignAliasBox	= "Auto Assign Alias"
GLDG_TXT.elements.tip.SettingsGeneralAutoAssignAliasBox	= "If this setting is enabled, the guild notes and officer notes will be parsed for entries of the form '@Aliasname ' to automatically manage names for your guild members.\r\nExamble:\r\n<Main @Uwe> => alias = Uwe\r\n<Main @Uwe other text> => alias = Uwe"
GLDG_TXT.elements.name.SettingsGeneralUseGuildDefaultBox	= "Use default guildsettings"
GLDG_TXT.elements.tip.SettingsGeneralUseGuildDefaultBox	= "Read the guildsettings from the guild info"
GLDG_TXT.elements.name.SettingsGeneralGreetAsMainBox	= "Greet as Main *"
GLDG_TXT.elements.tip.SettingsGeneralGreetAsMainBox	= "If this setting is enabled, any alt character is greetet with the name or alias of its main character"
GLDG_TXT.elements.name.SettingsGeneralIncludeOwnBox	= "Include own"
GLDG_TXT.elements.tip.SettingsGeneralIncludeOwnBox	= "If this setting is enabled, your own characters will also be shown in the guild list"
GLDG_TXT.elements.name.SettingsGeneralRandomizeBox	= "Random Greetings"
GLDG_TXT.elements.tip.SettingsGeneralRandomizeBox	= "If this setting is enabled, a character will be randomly greeted by either his name or alias (or that of his main, if the setting to greet alts as main is enabled)"
GLDG_TXT.elements.name.SettingsGeneralUseFriendsBox	= "Use Friends"
GLDG_TXT.elements.tip.SettingsGeneralUseFriendsBox	= "If this setting is enabled, GuildGreet will also manage your friends coming online and going offline"
GLDG_TXT.elements.name.SettingsGeneralWhisperBox	= "Whisper Greetings"
GLDG_TXT.elements.tip.SettingsGeneralWhisperBox		= "If this setting is enabled, greetings will be whispered to people instead of using the guild chat or the selected channel.\r\n\r\nThis includes levelup messages."
GLDG_TXT.elements.name.SettingsGeneralWhisperLevelupBox	= "Whisper Levelup"
GLDG_TXT.elements.tip.SettingsGeneralWhisperLevelupBox	= "If this setting is enabled, levelup messages will be whispered to people instead of using the guild chat or the selected channel.\r\n\r\nIf the generic whisper setting is enabled, this setting has no effect."
GLDG_TXT.elements.name.SettingsGeneralChannelNameDropboxButton	= "Use Channel"
GLDG_TXT.elements.tip.SettingsGeneralChannelNameDropboxButton	= "If you choose any channel other than <none>, GuildGreet will monitor that channel for people joing and leaving it"

GLDG_TXT.elements.name.SettingsGeneralListdirectBox	= "Grow direction"
GLDG_TXT.elements.tip.SettingsGeneralListdirectBox	= "If this setting is enabled, the greet list will grow upwards instead of downwards"
GLDG_TXT.elements.name.SettingsGeneralListheaderBox	= "Always show header"
GLDG_TXT.elements.tip.SettingsGeneralListheaderBox	= "If this setting is enabled, the greet list header will always be shown, even if nobody needs to be greeted"
GLDG_TXT.elements.name.SettingsGeneralListsizeSlider	= "Greet list size"
GLDG_TXT.elements.tip.SettingsGeneralListsizeSlider	= "This defines how many people to be greeted will be shown in the greet list. If there are more people to be greeted than configured in this setting, the oldest entries will be shown."

GLDG_TXT.elements.name.SettingsChatChatFrameSlider	= "Chat frame"
GLDG_TXT.elements.tip.SettingsChatChatFrameSlider	= "Defines which chat frame is used to display GuildGreet chat messages.\r\n\r\n|cFFFF0000If not all are selectable, use the command\r\n|r/reload|cFFFF0000.|r"
GLDG_TXT.elements.name.SettingsChatListNamesBox		= "List online"
GLDG_TXT.elements.tip.SettingsChatListNamesBox		= "If this setting is enabled, a line printing all characters of the player that has just come online will be printed to the chat"
GLDG_TXT.elements.name.SettingsChatListNamesOffBox	= "List offline"
GLDG_TXT.elements.tip.SettingsChatListNamesOffBox	= "If this setting is enabled, a line printing all characters of the player that has just gone offline will be printed to the chat"
GLDG_TXT.elements.name.SettingsChatListLevelUpBox	= "List level up (online)"
GLDG_TXT.elements.tip.SettingsChatListLevelUpBox	= "If this setting is enabled, a line will be printed to the chat whenever a character levels up"
GLDG_TXT.elements.name.SettingsChatListLevelUpOffBox	= "List level up (offline)"
GLDG_TXT.elements.tip.SettingsChatListLevelUpOffBox	= "If this setting is enabled, a line will be printed for each character that is offline and leveled up while you were offline"
GLDG_TXT.elements.name.SettingsChatListQuitBox		= "List people quitting guild"
GLDG_TXT.elements.tip.SettingsChatListQuitBox		= "If this setting is enabled, a line will be printed if a character leaves the guild"
GLDG_TXT.elements.name.SettingsChatExtendChatBox	= "Main name in chat"
GLDG_TXT.elements.tip.SettingsChatExtendChatBox		= "If this setting is enabled, the name of the main will be prepended to the message an alt sends."
GLDG_TXT.elements.name.SettingsChatExtendIgnoredBox	= "Main name in chat for ignored characters"
GLDG_TXT.elements.tip.SettingsChatExtendIgnoredBox		= "If this setting is enabled, the name of the main will be prepended to the message an alt sends, even if the alt is ignored."
GLDG_TXT.elements.name.SettingsChatExtendMainBox	= "Main name in chat even for main"
GLDG_TXT.elements.tip.SettingsChatExtendMainBox		= "If this setting is enabled, the name of the main will be prepended even to messages of the main, not just the alt."
GLDG_TXT.elements.name.SettingsChatExtendAliasBox	= "Alias in chat"
GLDG_TXT.elements.tip.SettingsChatExtendAliasBox	= "If this setting is enabled, the alias of the main will be prepended to the message an alt sends instead of using the main name."
GLDG_TXT.elements.name.SettingsChatListAchievmentsBox	= "List Achievments"
GLDG_TXT.elements.tip.SettingsChatListAchievmentsBox	= "If this setting is enabled, a line will be printed to the chat whenever a character receives an achievment, if a main char or alias is defined for this character."
GLDG_TXT.elements.name.SettingsChatAddPostfixBox	= "Add source postfix"
GLDG_TXT.elements.tip.SettingsChatAddPostfixBox		= "If this setting is enabled, all character names printed to chat will be postfixed to mark the source, i.e. where the character is known from.\r\nGuild: no postfix\r\nChannel: {c}\r\nFriend list: {f}\r\n:None of the above: {?}"
GLDG_TXT.elements.name.SettingsChatShowWhoSpamBox	= "Show /who requests and responses"
GLDG_TXT.elements.tip.SettingsChatShowWhoSpamBox	= "If this setting is enabled, a message will be printed to chat anytime a /who request is sent either by manually using the corresponding button in the character tab or automatically (if the options is enabled) and everytime a /who response is received (either from a /who request by GuildGreet or any other method)."


GLDG_TXT.elements.name.SettingsGreetingGreetGuildBox	= "Greet guild"
GLDG_TXT.elements.tip.SettingsGreetingGreetGuildBox	= "If this setting is enabled, pressing the (configurable) 'greet', 'see you later' and 'goodbye' keys will send an appropriate message to the guild chat. The keys can be configured in the key binding menu."
GLDG_TXT.elements.name.SettingsGreetingGreetChannelBox	= "Greet channel"
GLDG_TXT.elements.tip.SettingsGreetingGreetChannelBox	= "If this setting is enabled, pressing the (configurable) 'greet', 'see you later' and 'goodbye' keys will send an appropriate message to the channel. The keys can be configured in the key binding menu."
GLDG_TXT.elements.name.SettingsGreetingAutoGreetBox	= "Auto greet"
GLDG_TXT.elements.tip.SettingsGreetingAutoGreetBox	= "If this setting is enabled, a greeting will be sent to the guild chat and/or channel, as configured in the two settings above.\r\n|cFFFF0000Use carefully:\r\nThis will be executed every time you log in or reload your user interface using |r/console reloadui|cFFFF0000, so it's easy to annoy your friends."

GLDG_TXT.elements.name.SettingsGreetingSupressAll	= "Supress all greetings"
GLDG_TXT.elements.tip.SettingsGreetingSupressAll	= "Press this button to check all four checkboxes below. This will suppress all entries to the greet list, the output to the chat is not impacted.\r\nThis button is useful if you do not want to be distracted during an instance run."
GLDG_TXT.elements.name.SettingsGreetingSupressNone	= "Allow all greetings"
GLDG_TXT.elements.tip.SettingsGreetingSupressNone	= "Press this button to clear all four checkboxes below. This will allow all entries to the greet list."
GLDG_TXT.elements.name.SettingsGreetingSupressGreetBox	= "Supress greetings"
GLDG_TXT.elements.tip.SettingsGreetingSupressGreetBox	= "If this setting is enabled, players that come online will not be put on the greet list. This feature can be used to disable greeting of characters without deleting all the greeting phrases. If no greeting phrases are defined, the character will not be put on the greet list, even if this setting is cleared."
GLDG_TXT.elements.name.SettingsGreetingSupressJoinBox	= "Supress welcome"
GLDG_TXT.elements.tip.SettingsGreetingSupressJoinBox	= "If this setting is enabled, players that join the guild will not be put on the greet list. This feature can be used to disable greeting of characters without deleting all the greeting phrases. If no greeting phrases are defined, the character will not be put on the greet list, even if this setting is cleared."
GLDG_TXT.elements.name.SettingsGreetingSupressLevelBox	= "Supress levelup"
GLDG_TXT.elements.tip.SettingsGreetingSupressLevelBox	= "If this setting is enabled, players that level up will not be put on the greet list. This feature can be used to disable congratulating of characters without deleting all the congratulation phrases. If no congratulation phrases are defined, the character will not be put on the greet list, even if this setting is cleared."
GLDG_TXT.elements.name.SettingsGreetingSupressRankBox	= "Supress promotions"
GLDG_TXT.elements.tip.SettingsGreetingSupressRankBox	= "If this setting is enabled, players that are promoted will not be put on the greet list. This feature can be used to disable congratulating of characters without deleting all the congratulation phrases. If no congratulation phrases are defined, the character will not be put on the greet list, even if this setting is cleared."
GLDG_TXT.elements.name.SettingsGreetingSupressAchievmentBox	= "Suppress achievments"
GLDG_TXT.elements.tip.SettingsGreetingSupressAchievmentBox	=" If this setting is enabled, players that reach an achievment will not be put on the greet list. This feature can be used to disable congratulating of characters without deleting all the congratulation phrases. If no congratulation phrases are defined, the character will not be put on the greet list, even if this setting is cleared."
GLDG_TXT.elements.name.SettingsGreetingNoGratsOnLoginBox	= "No congratulations on login"
GLDG_TXT.elements.tip.SettingsGreetingNoGratsOnLoginBox		= "If this setting is enabled, players that have been promoted or levelled up, will not be congratulated when the login but greeted instead.\r\nIf this setting is enabled, congratulations will only be given to players that are promoted or level up when already logged in."

GLDG_TXT.elements.name.SettingsGreetingGuildAliasEditbox	= "Guild Alias"
GLDG_TXT.elements.tip.SettingsGreetingGuildAliasEditbox		= "Enter a guild alias to be used instead of your guild name in the guild greetings. Press enter to set or escape to clear the alias."
GLDG_TXT.elements.name.SettingsGreetingGuildAliasSet		= "Set guild alias"
GLDG_TXT.elements.tip.SettingsGreetingGuildAliasSet		= "Press this button to set the guild alias currently being edited. This alias will then be used in guild greetings."
GLDG_TXT.elements.name.SettingsGreetingGuildAliasClear		= "Clear guild alias"
GLDG_TXT.elements.tip.SettingsGreetingGuildAliasClear		= "Press this button to clear the current guild alias. The full guild name will be used in guild greetings."

GLDG_TXT.elements.name.SettingsDebugEnableDumpBox	= "Enable Dumping"
GLDG_TXT.elements.tip.SettingsDebugEnableDumpBox	= "If this setting is enabled, debug information will be dumped into the saved variables of the GuildGreetDump addon. This information can then be uploaded on Curse Gaming to facilitate debugging.\r\n|cFFFF0000Note: this will create a lot of data, so use carefully.\r\n\r\nDon't enable this unless you were told to do so by Urbin on Curse Gaming!"
GLDG_TXT.elements.name.SettingsDebugVerboseDumpBox	= "Verbose Dumping"
GLDG_TXT.elements.tip.SettingsDebugVerboseDumpBox	= "If this setting is enabled, each message that is written to the dump set will be written to the chat as well."
GLDG_TXT.elements.name.SettingsDebugClearButton		= "Clear current set"
GLDG_TXT.elements.tip.SettingsDebugClearButton		= "Click this button to delete all entries of dump the current set"
GLDG_TXT.elements.name.SettingsDebugClearAllButton	= "Clear all sets"
GLDG_TXT.elements.tip.SettingsDebugClearAllButton	= "Click this button to delete all dump sets"
GLDG_TXT.elements.name.SettingsDebugNewButton		= "Use new set"
GLDG_TXT.elements.tip.SettingsDebugNewButton		= "Click this button to create a new dump set to which debug output is written"

GLDG_TXT.elements.name.SettingsOtherUseLocalTimeBox	= "Use local time"
GLDG_TXT.elements.tip.SettingsOtherUseLocalTimeBox	= "If this setting is enabled, local time is used instead of server time. This means that the time information in the greet list is based on local time as well as the decision whether to say 'good bye' or 'good night'."
GLDG_TXT.elements.name.SettingsOtherShowNewerVersionsBox	= "Show if newer version is available"
GLDG_TXT.elements.tip.SettingsOtherShowNewerVersionsBox	= "GuildGreet broadcasts its version in guild, party and raid channels. If this setting is enabled, and another player has a newer version than the one you are using, you will be informed about it with a message in the chat frame."
GLDG_TXT.elements.name.SettingsOtherEnableContextMenuBox	= "Enable player context menu"
GLDG_TXT.elements.tip.SettingsOtherEnableContextMenuBox	= "If this setting is enabled, two entries are added to the player context menu which appears if you right click on a player portrait or a player name in chat. The entries will allow to query GuildGreet about information you have on this player and to say good bye to the player.\r\n|cFFFF0000Note: There have been reports that this causes taint issues when using the raid frame. If this happens to you, disable this feature.|r\r\n\r\nI will look into secure methods to extend the context menu when I have a little more time.\r\n\r\n|cFFFF0000NOTE: You will be queried if you want to reload your interface when changing this option, as it only takes effect if you reload the user interface.|r"
GLDG_TXT.elements.name.SettingsOtherAutoWhoBox		= "Automatic /who requests"
GLDG_TXT.elements.tip.SettingsOtherAutoWhoBox		= "If this setting is enabled, an automatic /who query is issued whenever a channel member logs in for whom the guild name, class or level information is not stored."
GLDG_TXT.elements.name.SettingsOtherDeltaPopupBox	= "Show popup with change summary"
GLDG_TXT.elements.tip.SettingsOtherDeltaPopupBox	= "If this setting is enabled, a pop up box will be displayed summarising any changes in status of guild members, friends and channel members have occurred while you were offline."
GLDG_TXT.elements.name.SettingsOtherExtendPlayerMenuBox	= "Enable player context menu"
GLDG_TXT.elements.tip.SettingsOtherExtendPlayerMenuBox	= "If this setting is enabled, two entries are added to the player context menu which appears if you right click on a player portrait or a player name in chat. The entries will allow to query GuildGreet about information you have on this player and to say good bye to the player.\r\n|cFFFF0000Note: There have been reports that this causes taint issues when using the raid frame. If this happens to you, disable this feature.|r\r\n\r\nI will look into secure methods to extend the context menu when I have a little more time.\r\n\r\n|cFFFF0000NOTE: You will be queried if you want to reload your interface when changing this option, as it only takes effect if you reload the user interface.|r"

GLDG_TXT.elements.name.ColourDefault		= "Default colours"
GLDG_TXT.elements.name.ColourHeader		= "Change colour and opacity"
GLDG_TXT.elements.name.ColourHelp		= "Change colour"
GLDG_TXT.elements.name.ColourChannelAlias	= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourChannelGoOffline	= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourChannelIsOffline	= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourChannelLevel	= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourChannelList	= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourChannelNew		= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourChannelOnline	= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourChannelRank	= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourChannelRelog	= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourChannelAchievment	= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourFriendsAlias	= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourFriendsGoOffline	= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourFriendsIsOffline	= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourFriendsLevel	= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourFriendsList	= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourFriendsNew		= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourFriendsOnline	= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourFriendsRank	= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourFriendsRelog	= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourFriendsAchievment	= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourGuildAlias		= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourGuildGoOffline	= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourGuildIsOffline	= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourGuildLevel		= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourGuildList		= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourGuildNew		= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourGuildOnline	= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourGuildRank		= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourGuildRelog		= GLDG_TXT.elements.name.ColourHelp
GLDG_TXT.elements.name.ColourGuildAchievment	= GLDG_TXT.elements.name.ColourHelp


GLDG_TXT.elements.tip.ColourDefault		= "Resets all colour values to their default values."
GLDG_TXT.elements.tip.ColourHeader		= "Define the colour of the Greeting List header line"
GLDG_TXT.elements.tip.ColourHelp		= "Define the colour of messages printed to the chat"

GLDG_TXT.elements.tip.ColourGuildAlias		= "Define the colour of alias names printed to the chat"
GLDG_TXT.elements.tip.ColourGuildGoOffline	= "Define the colour of messages printed to the chat about characters that have gone offline"
GLDG_TXT.elements.tip.ColourGuildIsOffline	= "Define the colour of characters that are offline when a message is printed to the chat about a character that has come online"
GLDG_TXT.elements.tip.ColourGuildOnline		= "Define the colour of the character that has just come online in the message that is printed to the chat"

GLDG_TXT.elements.tip.ColourGuildNew		= "Define the colour of an entry in the greet list for players that have just joined the guild"
GLDG_TXT.elements.tip.ColourGuildList		= "Define the colour of an entry in the greet list for players that have come online for the first time this session"
GLDG_TXT.elements.tip.ColourGuildRelog		= "Define the colour of an entry in the greet list for players that have relogged"
GLDG_TXT.elements.tip.ColourGuildLevel		= "Define the colour of an entry in the greet list for players that have levelled up"
GLDG_TXT.elements.tip.ColourGuildRank		= "Define the colour of an entry in the greet list for players that have been promoted"
GLDG_TXT.elements.tip.ColourGuildAchievment	= "Define the colour of an entry in the greet list for players that have reached an achievment"

GLDG_TXT.elements.tip.ColourChannelAlias	= GLDG_TXT.elements.tip.ColourGuildAlias
GLDG_TXT.elements.tip.ColourChannelGoOffline	= GLDG_TXT.elements.tip.ColourGuildGoOffline
GLDG_TXT.elements.tip.ColourChannelIsOffline	= GLDG_TXT.elements.tip.ColourGuildIsOffline
GLDG_TXT.elements.tip.ColourChannelOnline	= GLDG_TXT.elements.tip.ColourGuildLevel
GLDG_TXT.elements.tip.ColourChannelNew		= "Define the colour of an entry in the greet list for players that have just joined the channel"
GLDG_TXT.elements.tip.ColourChannelList		= GLDG_TXT.elements.tip.ColourGuildList
GLDG_TXT.elements.tip.ColourChannelRelog	= GLDG_TXT.elements.tip.ColourGuildRelog
GLDG_TXT.elements.tip.ColourChannelLevel	= GLDG_TXT.elements.tip.ColourGuildNew
GLDG_TXT.elements.tip.ColourChannelRank		= GLDG_TXT.elements.tip.ColourGuildRank
GLDG_TXT.elements.tip.ColourChannelAchievment	= GLDG_TXT.elements.tip.ColourGuildAchievment

GLDG_TXT.elements.tip.ColourFriendsAlias	= GLDG_TXT.elements.tip.ColourGuildAlias
GLDG_TXT.elements.tip.ColourFriendsGoOffline	= GLDG_TXT.elements.tip.ColourGuildGoOffline
GLDG_TXT.elements.tip.ColourFriendsIsOffline	= GLDG_TXT.elements.tip.ColourGuildIsOffline
GLDG_TXT.elements.tip.ColourFriendsOnline	= GLDG_TXT.elements.tip.ColourGuildOnline
GLDG_TXT.elements.tip.ColourFriendsNew		= "Define the colour of an entry in the greet list for players that have just joined the friends list"
GLDG_TXT.elements.tip.ColourFriendsList		= GLDG_TXT.elements.tip.ColourGuildList
GLDG_TXT.elements.tip.ColourFriendsRelog	= GLDG_TXT.elements.tip.ColourGuildRelog
GLDG_TXT.elements.tip.ColourFriendsLevel	= GLDG_TXT.elements.tip.ColourGuildLevel
GLDG_TXT.elements.tip.ColourFriendsRank		= GLDG_TXT.elements.tip.ColourGuildRank
GLDG_TXT.elements.tip.ColourFriendsAchievment	= GLDG_TXT.elements.tip.ColourGuildAchievment

GLDG_TXT.elements.name.Red			= GLDG_TXT.red
GLDG_TXT.elements.tip.Red			= "The red value of an RGB colour definition.\r\nRange: 0..255"
GLDG_TXT.elements.name.Green			= GLDG_TXT.green
GLDG_TXT.elements.tip.Green			= "The green value of an RGB colour definition.\r\nRange: 0..255"
GLDG_TXT.elements.name.Blue			= GLDG_TXT.blue
GLDG_TXT.elements.tip.Blue			= "The blue value of an RGB colour definition.\r\nRange: 0..255"
GLDG_TXT.elements.name.Opacity			= "Opacity"
GLDG_TXT.elements.tip.Opacity			= "The opacity value from transparent (100%=0) to opaque (0%=255).\r\nRange: 0..255"

GLDG_TXT.elements.name.PlayersAlt2Box	= "Keep with main"
GLDG_TXT.elements.tip.PlayersAlt2Box	= "If this setting is enabled, alt characters will be grouped together with their main char in the character list."
GLDG_TXT.elements.name.PlayersAltBox	= "Always show alts"
GLDG_TXT.elements.tip.PlayersAltBox	= "If this setting is enabled, alt characters will be shown in the character list.\r\n\r\nIf the setting is disabled, alts will only be shown for the selected main."
GLDG_TXT.elements.name.PlayersIgnoreBox	= "Include ignored"
GLDG_TXT.elements.tip.PlayersIgnoreBox	= "If this setting is enabled, characters which have been set to ignore using the ignore button, will still be included in the character list. Note, this is not related to placing somebody on the /ignore list"
GLDG_TXT.elements.name.PlayersUnassignedBox	= "Unassigned characters"
GLDG_TXT.elements.tip.PlayersUnassignedBox	= "If this setting is enabled, only characters who are neither main or alt will be shown"
GLDG_TXT.elements.name.PlayersGuildBox		= "Guild members only"
GLDG_TXT.elements.tip.PlayersGuildBox		= "Only show characters in the list that belong to the guild of your currently logged in character."
GLDG_TXT.elements.name.PlayersOnlineBox		= "Online only"
GLDG_TXT.elements.tip.PlayersOnlineBox		= "Only show characters in the list that are currently online.\r\nIf this setting is active, the 'keep alts with main' feature will be disregarded."
GLDG_TXT.elements.name.PlayersMyFriendsBox	= "My friends only"
GLDG_TXT.elements.tip.PlayersMyFriendsBox	= "Only show characters in the list that are on your current character's friend list"
GLDG_TXT.elements.name.PlayersWithFriendsBox	= "With friends only"
GLDG_TXT.elements.tip.PlayersWithFriendsBox	= "Only show characters in the list that are on the friend's list of any of your characters"
GLDG_TXT.elements.name.PlayersCurrentChannelBox	= "Current channel only"
GLDG_TXT.elements.tip.PlayersCurrentChannelBox	= "Only show characters in the list that belong to the same channel you are currently watching"
GLDG_TXT.elements.name.PlayersWithChannelBox	= "With channel only"
GLDG_TXT.elements.tip.PlayersWithChannelBox	= "Only show characters in the list that belong to a channel, not necessarily the one you are currently watching"
GLDG_TXT.elements.name.PlayersGuildSortBox	= "Sort by guild"
GLDG_TXT.elements.tip.PlayersGuildSortBox	= "If this setting is enabled, characters will be sorted by guild name first and name second.\r\nIf this setting is active, the 'keep alts with main' feature will be disregarded."
GLDG_TXT.elements.name.PlayersGuildFilterDropboxButton	= "Guild filter"
GLDG_TXT.elements.tip.PlayersGuildFilterDropboxButton	= "Choose a guild from the dropdown list to limit the characters to be displayed in the list to only the members of that guild."

GLDG_TXT.elements.name.PlayersActionButtonsAlias = "Alias"
GLDG_TXT.elements.tip.PlayersActionButtonsAlias	= "Use this button to define, update or clear an alias for this character"
GLDG_TXT.elements.name.PlayersActionButtonsAlt	= "Alt"
GLDG_TXT.elements.tip.PlayersActionButtonsAlt	= "Use this button to set or unset this character as an alt character to some other (main) character"
GLDG_TXT.elements.name.PlayersActionButtonsIgnore 	= "Ignore"
GLDG_TXT.elements.tip.PlayersActionButtonsIgnore	= "Use this button to not monitor the coming online and going offline of this character. Not, this is not related to placing somebody on the /ignore list."
GLDG_TXT.elements.name.PlayersActionButtonsMain		= "Main"
GLDG_TXT.elements.tip.PlayersActionButtonsMain		= "Use this button to set or unset this character as a main character"
GLDG_TXT.elements.name.PlayersActionButtonsWho		= "Who Query"
GLDG_TXT.elements.tip.PlayersActionButtonsWho		= "Start a /who query for the currently selected character.\r\n\r\nDepending on how the result of the query is returned, the data may or may not be added to the database"	-- todo: adjust when this works properly
GLDG_TXT.elements.name.PlayersActionButtonsRemove	= "Remove character"
GLDG_TXT.elements.tip.PlayersActionButtonsRemove	= "Removes this character from the database. Only works for characters that are neither Main or Alt"
GLDG_TXT.elements.name.PlayersActionButtonsGuild	= "Manually Set Guild"
GLDG_TXT.elements.tip.PlayersActionButtonsGuild		= "Use this button to manually set/edit/remove the guild name of a character.\r\nThe button cannot be used for characters of your current guild. If at a later time the guild name for the character is retrieved automatically, the manual value will be overwritten"
GLDG_TXT.elements.name.PlayersActionButtonsCheck	= "Chech consistency"
GLDG_TXT.elements.tip.PlayersActionButtonsCheck		= "Use this button to print a list of inconsistencies to chat. They must be fixed manually."
GLDG_TXT.elements.name.PlayersActionButtonsNote		= "Note"
GLDG_TXT.elements.tip.PlayersActionButtonsNote		= "Use this button to set/edit/remove a user note for the character. This note will be displayed in the tooltip for this character.\r\nThis note is *not* related to guild notes, officer notes or friend notes (all of which are shown separately in the tooltip)."
GLDG_TXT.elements.name.PlayersActionButtonsPublicNote	= "Public note"
GLDG_TXT.elements.tip.PlayersActionButtonsPublicNote	= "Use this button to edit the public note for this character."
GLDG_TXT.elements.name.PlayersActionButtonsOfficerNote	= "Officer note"
GLDG_TXT.elements.tip.PlayersActionButtonsOfficerNote	= "Use this button to edit the officer note for this character."

GLDG_TXT.elements.name.PlayersSubAliasDel	= "Delete alias"
GLDG_TXT.elements.tip.PlayersSubAliasDel	= "Click this button to delete the alias for the currently selected character"
GLDG_TXT.elements.name.PlayersSubAliasSet	= "Set/Update alias"
GLDG_TXT.elements.tip.PlayersSubAliasSet	= "Use this button to set or update the alias for the currently selected character"
GLDG_TXT.elements.name.PlayersSubAliasEditbox	= "Alias"
GLDG_TXT.elements.tip.PlayersSubAliasEditbox	= "Enter the alias name you want to use for the currently selected character"
--GLDG_TXT.elements.name.PlayersLine		= "Character selection"
--GLDG_TXT.elements.tip.PlayersLine		= "Click on a name to manage this character"
GLDG_TXT.elements.name.PlayersSubMainAltLine	= "Choose main"
GLDG_TXT.elements.tip.PlayersSubMainAltLine	= "Click on an entry in this list to select the main character for the currently selected (alt) character"
GLDG_TXT.elements.name.PlayersHeaderLine	= "Character selection"
GLDG_TXT.elements.tip.PlayersHeaderLine		= "Click on a character name to manage that character. Hovering over the entry in the character list will show a tooltip with relevant information"
GLDG_TXT.elements.name.PlayersSubGuildEditbox	= "Guild name"
GLDG_TXT.elements.tip.PlayersSubGuildEditbox	= "Manually enter the guild name for the currently selected character. This entry will be overwritten if the guild name can be determined automatically at a later point in time."
GLDG_TXT.elements.name.PlayersSubGuildSet	= "Set/update guild name"
GLDG_TXT.elements.tip.PlayersSubGuildSet	= "Use this button to set or update the guild name for the currently selected character."
GLDG_TXT.elements.name.PlayersSubGuildDel	= "Delete guild name"
GLDG_TXT.elements.tip.PlayersSubGuildDel	= "Use this button to remove the guild name for the currently selected character."
GLDG_TXT.elements.name.PlayersSubNoteEditbox	= "User note"
GLDG_TXT.elements.tip.PlayersSubNoteEditbox	= "Enter a user note for the currently selected character. This note will be displayed in the tooltip for this character.\r\nThis note is *not* related to guild notes, officer notes or friend notes (all of which are shown separately in the tooltip)."
GLDG_TXT.elements.name.PlayersSubNoteSet	= "Set/Update note"
GLDG_TXT.elements.tip.PlayersSubNoteSet		= "Use this button to set or update the user note for the currently selected character."
GLDG_TXT.elements.name.PlayersSubNoteDel	= "Delete note"
GLDG_TXT.elements.tip.PlayersSubNoteDel		= "Use this button to remove the user note for the currently selected character."


GLDG_TXT.elements.name.CleanupGuild		= "Cleanup Guild"
GLDG_TXT.elements.tip.CleanupGuild		= "Use this button to display a list of all guild names currently assigned to characters.\r\nThe guild name you choose will be removed from all characters that are currently assigned to it.\r\nIf they belong to a guild that one of your characters belong to, the guild name will automatically be set again the next time you log in with that character."
GLDG_TXT.elements.name.CleanupFriends		= "Cleanup Friends"
GLDG_TXT.elements.tip.CleanupFriends		= "Use this button to display a list of all your characters that have managed characters on their friends list.\r\nThe friend you choose will be removed from all characters that currenlty reference it.\r\nThe next time you log in with this character all characters on the friends list will automatically reference it again."
GLDG_TXT.elements.name.CleanupChannel		= "Cleanup Channel"
GLDG_TXT.elements.tip.CleanupChannel		= "Use this button to display a list of all channels the managed characters reference.\r\nThe channel you choose will be removed from all these characters.\r\nThe next time a character again joins a watched channel, it will automatically reference it again."
GLDG_TXT.elements.name.CleanupOrphan		= "Cleanup Orphans"
GLDG_TXT.elements.tip.CleanupOrphan		= "Use this button to remove all characters from the database that are neither main or alt, don't have an alias and have neither friend nor channel references.\r\nGuild membership does not protect orphans from being deleted. Guild members, friends and channel members will be readded automatically when they are next detected."
GLDG_TXT.elements.name.CleanupSubEntriesLine	= "Select entry to be cleaned up"
GLDG_TXT.elements.tip.CleanupSubEntriesLine	= "Choose an entry (guild name, friend name or channel name) from the list to delete all references to this entry from all managed characters."
--~~~ MSN1: Added initialization of static variables for 2 new buttons' mouseover popup window info (for deleting and displaying guildless characters)
GLDG_TXT.elements.name.CleanupGuildless		= "Cleanup Guildless"
GLDG_TXT.elements.tip.CleanupGuildless		= "Use this button to remove all characters from the database that don't have a Guild."
GLDG_TXT.elements.name.CleanupDisplayGuildless	= "Display Guildless"
GLDG_TXT.elements.tip.CleanupDisplayGuildless	= "Use this button to display all characters from the database that don't have a Guild and counts for those that both do and don't have guilds."
--~~~~


GLDG_TXT.elements.name.GreetingsSelLevel	= "Level up phrases"
GLDG_TXT.elements.tip.GreetingsSelLevel		= "Press this button to define the phrases to be used when a character levels up."
GLDG_TXT.elements.name.GreetingsSelBye		= "Goodybe phrases"
GLDG_TXT.elements.tip.GreetingsSelBye		= "Press this button to define the phrases to be used when you want to say goodbye to a character"
GLDG_TXT.elements.name.GreetingsSelNight	= "Goodnight phrases"
GLDG_TXT.elements.tip.GreetingsSelNight		= "Press this button to define the phrases to be used when you want to say goodbye to a character during the night"
GLDG_TXT.elements.name.GreetingsSelRank		= "Promotion phrases"
GLDG_TXT.elements.tip.GreetingsSelRank		= "Press this button to define the phrases to be used when a character is promoted"
GLDG_TXT.elements.name.GreetingsSelJoin		= "Joining guild phrases"
GLDG_TXT.elements.tip.GreetingsSelJoin		= "Press this button to define the phrases to be used when a character joins your guild"
GLDG_TXT.elements.name.GreetingsSelDefault	= "Greeting phrases"
GLDG_TXT.elements.tip.GreetingsSelDefault	= "Press this button to define the phrases to be used when a character comes online for the first time during a session"
GLDG_TXT.elements.name.GreetingsSelRelog	= "Relog phrases"
GLDG_TXT.elements.tip.GreetingsSelRelog		= "Press this button to define the phrases to be used when a character comes back online after having been offline for some time"
GLDG_TXT.elements.name.GreetingsSelGuild	= "Greet guild"
GLDG_TXT.elements.tip.GreetingsSelGuild		= "Press this button to define the phrases to be used when you greet your guild"
GLDG_TXT.elements.name.GreetingsSelChannel	= "Greet channel"
GLDG_TXT.elements.tip.GreetingsSelChannel	= "Press this button to define the phrases to be used when you greet your channel"
GLDG_TXT.elements.name.GreetingsSelByeGuild	= "Good bye to guild"
GLDG_TXT.elements.tip.GreetingsSelByeGuild	= "Press this button to define the phrases to be used when you are saying good bye to your guild"
GLDG_TXT.elements.name.GreetingsSelNightGuild	= "Good night to guild"
GLDG_TXT.elements.tip.GreetingsSelNightGuild	= "Press this button to define the phrases to be used when you are saying good night guild"
GLDG_TXT.elements.name.GreetingsSelByeChannel	= "Good bye to channel"
GLDG_TXT.elements.tip.GreetingsSelByeChannel	= "Press this button to define the phrases to be used when you are saying good bye to your channel"
GLDG_TXT.elements.name.GreetingsSelNightChannel	= "Good night to channel"
GLDG_TXT.elements.tip.GreetingsSelNightChannel	= "Press this button to define the phrases to be used when you are saying good night to your channel"
GLDG_TXT.elements.name.GreetingsSelLaterGuild	= "See you later to guild"
GLDG_TXT.elements.tip.GreetingsSelLaterGuild	= "Press this button to define the phrases to be used when you are saying 'see you later' to your guild"
GLDG_TXT.elements.name.GreetingsSelLaterChannel	= "See you later to channel"
GLDG_TXT.elements.tip.GreetingsSelLaterChannel	= "Press this button to define the phrases to be used when you are saying 'see you later' to your channel"
GLDG_TXT.elements.name.GreetingsSelAchievment	= "Achievment"
GLDG_TXT.elements.tip.GreetingsSelAchievment	= "Press this button to define the phrases to be used when you congratulate a guild member to an achievment"


GLDG_TXT.customerCodes	= "The following %-codes can be used.\r\n"..
"%s = once or twice, as described in the message above the edit box\r\n"..
"%c = character name\r\n"..
"%n = name as used in %s (depends on config settings: name, main, alias or random)\r\n"..
"%a = alias of current character\r\n"..
"%m = main name if available, %c else\r\n"..
"%A = main alias if available, %a else if available, %m else\r\n"..
"%l = level if available, empty else\r\n"..
"%L = levels left to level cap if available, empty else\r\n"..
"%C = class if available, empty else\r\n"..
"%r = rankname if available, rank number else if available, empty else\r\n"..
"%v = achievment if available, empty else\r\n"..
"%g = guild alias if available, else guild if available, else empty\r\n"..
"%G = guild name if available, else empty\r\n"..
"\r\n"..
"You can make a message level dependent by prepending:\r\n"..
"<levels:##:##> to it, where the hashes are from-level and to-level (inclusive)\r\n"..
"\r\n"..
"You can make a message time dependent by prepending:\r\n"..
"<time:##.##:##.##> to it, where ##.## are the from-time and to-time in 24 hour format\r\n"..
"\r\n"..
"Combinations of the form <levels:##:##><time:##.##:##.##>\r\n"..
"and <time:##.##:##.##><levels:##.##> are also allowed"

GLDG_TXT.elements.name.GreetingsMsgAdd		= "Add or update phrase"
GLDG_TXT.elements.tip.GreetingsMsgAdd		= "Press this button to add or update the currently edited phrase"
GLDG_TXT.elements.name.GreetingsMsgDel		= "Remove or clear phrase"
GLDG_TXT.elements.tip.GreetingsMsgDel		= "Press this button to clear the phrase edit field or to remove the currently selected phrase from the phrase list"
GLDG_TXT.elements.name.GreetingsEditbox		= "Enter phrase"
GLDG_TXT.elements.tip.GreetingsEditbox		= "Enter the phrase to be added in this edit box.\r\n\r\n"..GLDG_TXT.customerCodes
GLDG_TXT.elements.name.GreetingsLine		= "Defined phrases"
GLDG_TXT.elements.tip.GreetingsLine		= "This list contains the currently defined phrases for the selected greeting type. Click on an existing phrase to edit or remove it.\r\n\r\n"..GLDG_TXT.customerCodes

GLDG_TXT.elements.name.GreetingsColNewDel	= "Create/remove collection"
GLDG_TXT.elements.tip.GreetingsColNewDel	= "Press this button to define a new collection of phrases or to delete an existing collection if one is selected"
GLDG_TXT.elements.name.GreetingsColPlayer	= "Set char collection"
GLDG_TXT.elements.tip.GreetingsColPlayer	= "Press this button to select a collection of phrases to be used with the current character. This can be useful to define greetings for a special character."
GLDG_TXT.elements.name.GreetingsColGuild	= "Set guild collection"
GLDG_TXT.elements.tip.GreetingsColGuild		= "Press this button to select a collection of phrases to be used with all characters in the current guild. This can be useful to define different greetings for different language guilds or a RP and non-RP guild."
GLDG_TXT.elements.name.GreetingsColRealm	= "Set realm collection"
GLDG_TXT.elements.tip.GreetingsColRealm		= "Press this button to select a collection of phrases to be used with all characters on the current realm. This can be useful to define different greetings for a RP and non-RP realm for example."
GLDG_TXT.elements.name.GreetingsCollect		= "Collection list"
GLDG_TXT.elements.tip.GreetingsCollect		= "This list contains the currently defined collections. Click on an existing collection to assign or remove it or to edit the assigned phrases"

GLDG_TXT.elements.name.GreetingsSubNewEditbox	= "Enter collection name"
GLDG_TXT.elements.tip.GreetingsSubNewEditbox	= "Enter the name of the new collection to be created in this edit box"

GLDG_TXT.elements.name.GreetingsSubNewAdd	= "Add collection"
GLDG_TXT.elements.tip.GreetingsSubNewAdd	= "Press this button to create a new collection with the name entered in the collection name edit box"
GLDG_TXT.elements.name.GreetingsSubNewCancel	= "Cancel collection"
GLDG_TXT.elements.tip.GreetingsSubNewCancel	= "Press this button to cancel the creation of a new collection"

GLDG_TXT.elements.name.GreetingsSubChangeGlobal		= "Use global defaults"
GLDG_TXT.elements.tip.GreetingsSubChangeGlobal		= "Use this button to use the standard phrases for the selected group instead of a collection"
GLDG_TXT.elements.name.GreetingsSubChangeSelection	= "Use selected collection"
GLDG_TXT.elements.tip.GreetingsSubChangeSelection	= "Use this button to use the phrases of the currently selected collection for the selected group"
GLDG_TXT.elements.name.GreetingsSubChangeClear		= "Don't use collection"
GLDG_TXT.elements.tip.GreetingsSubChangeClear		= "Use this button to not use a collection but the standard phrases for the selected group."
GLDG_TXT.elements.name.GreetingsSubChangeCancel		= "Leave unchanged"
GLDG_TXT.elements.tip.GreetingsSubChangeCancel		= "Use this button to not change the phrases to be used by the selected group"


GLDG_TXT.elements.name.TodoTodoBox	= GLDG_TXT.infoTodo
GLDG_TXT.elements.tip.TodoTodoBox	= "Click this box to show the list of requests and planned features."
GLDG_TXT.elements.name.TodoHistoryBox	= GLDG_TXT.infoHistory
GLDG_TXT.elements.tip.TodoHistoryBox	= "Click this box to show the version history of the last few versions.\r\nA full version history is contained in the readme.txt file included with the addon."
GLDG_TXT.elements.name.TodoHelpBox	= GLDG_TXT.infoHelp
GLDG_TXT.elements.tip.TodoHelpBox	= "Click this box to get information on how to use this addon."


