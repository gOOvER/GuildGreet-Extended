GLDG_History = "This list shows the changes in the last few versions (a complete history is available in the readme.txt file included with the addon.\r\n\r\n"..
"|cFFFFFF7F40200.2|r\r\n"..
"- re-added option to enable/disable player context menu. The menu will be disabled\r\n"..
"  by default, as it seems to cause taint issues. Go to the 'other' tab in the config\r\n"..
"  window to enable/disable it (needs reload of UI)\r\n"..
"NOTE: As I am leaving WoW, this will be the final version of GuildGreet that is released\r\n"..
"|cFFFFFF7F40200.1|r\r\n"..
"- adjusted toc for patch 4.2.0\r\n"..
"|cFFFFFF7F40100.1|r\r\n"..
"- adjusted toc for patch 4.1.0\r\n"..
"|cFFFFFF7F40000.8|r\r\n"..
"- made GuildGreet config frame dragable (requested by evlyxx)\r\n"..
"|cFFFFFF7F40000.7|r\r\n"..
"- changed priority of greetings: achievments are now higher than levelup, so\r\n"..
"  you'll congratulate a player in guild chat for the [Level 10] achievment instead\r\n"..
"  of whispering him\r\n"..
"|cFFFFFF7F40000.6|r\r\n"..
"- fixed level cap for %L congratulations (reported by Deltethnia)\r\n"..
"\r\n"..
"|cFFFFFF7F40000.5|r\r\n"..
"- fixed placement of EGP option on config frame\r\n"..
"\r\n"..
"|cFFFFFF7F40000.4|r\r\n"..
"- fixed some errors with Collections (reported by Dusarra)\r\n"..
"- option to show main name in chat even for alts that are ignored (requested by Elsu)\r\n"..
"- added option to support EGP style officer notes for auto-assignment (requested by Dearthmaul)\r\n"..
"- added support for 'alt - <name>' for auto-assignment (suggested by mdsandler)\r\n"..
"\r\n"..
"|cFFFFFF7F40000.3|r\r\n"..
"- no longer congratulating own achievments\r\n"..
"- now showing main name/alias in greet list tooltip\r\n"..
"\r\n"..
"|cFFFFFF7F40000.2|r\r\n"..
"- fixed clicking on event list to send greetings again\r\n"..
"\r\n"..
"|cFFFFFF7F40000.1|r\r\n"..
"- adjusted toc for patch 4.0.1\r\n"..
"- fixed code so it works with 4.0.1 again\r\n"..
"- fixed wrong level being used in grats message\r\n"..
"\r\n"..
"|cFFFFFF7F30300.10|r\r\n"..
"- added option to whisper level up grats (part of a suggestion by nighttar)\r\n"..
"\r\n"..
"|cFFFFFF7F30300.9|r\r\n"..
"- fixed bug with startup delta dialog when stored data did not contain rankname\r\n"..
"  (reported by cycronexium)\r\n"..
"- adjusted colours for alt-chars in character list (requested by Elsu)\r\n"..
"\r\n"..
"|cFFFFFF7F30300.8|r\r\n"..
"- check to catch error in GLDG_ShowGreetings (reported by Baraknor)\r\n"..
"- consistency check now checks for main-links to inexisting characters\r\n"..
"  (reported by Elsu)\r\n"..
"\r\n"..
"|cFFFFFF7F30300.7|r\r\n"..
"- correct level reported in delta popup for guild members levelling up\r\n"..
"- removed 'global GLDG_UpdateTabs (nil value)' bug (reported by cycronexium)\r\n"..
"- fixed 'player is nil' bug in SendBye (reported by disoph)\r\n"..
"- now applying level and time filter mechanism to all greetings and goodbyes\r\n"..
"  (greeting guild & channel; later guild & channel)\r\n"..
"- fixed bug in filtering greet messages (might help with missing join and level\r\n"..
"  up messages, though I'm not sure\r\n"..
"- 'Don't congratulate players that just logged in' no longer self-enables every\r\n"..
"  time a character logs in (reported by Gorgonis)\r\n"..
"- added message to delta-popup for rank changes\r\n"..
"- fixed using no or wrong colours for friends in greet list\r\n"..
"- fixed 'nil passed to gsub' error when calling GLDG_SendBye (reported by\r\n"..
"  KingsTears)\r\n"..
"\r\n"..
"|cFFFFFF7F30300.6|r\r\n"..
"- showing which players are online in character list using a leading *\r\n"..
"- showing main or main's alias in alias column for character list if\r\n"..
"  alt has no alias on its own\r\n"..
"- fixed %A not using the alias if the character is the main char\r\n"..
"  (reported by cycronexium)\r\n"..
"- fixed bug with new guild members not being greeted (reported by redblade1530\r\n"..
"  and Dellilah)\r\n"..
"- will now not offer promotion congrats for own characters\r\n"..
"- channel members that are also guild members or friends will not be placed\r\n"..
"  on greet list twice\r\n"..
"- now also printing class and level for joined/left chat messages for channel\r\n"..
"  members that are neither main/alt\r\n"..
"- only evaluates officer notes for startup delta dialog if the current player\r\n"..
"  is allowed to read the officer notes\r\n"..
"\r\n"..
"|cFFFFFF7F30300.5|r\r\n"..
"- added new message code %L for number of levels till max level (inspired by\r\n"..
"  code submitted by lebanoncyberspace)\r\n"..
"- added level based message filtering (using code submitted by lebanoncyberspace)\r\n"..
"  use '<levels:##:##>message' where ## are the lower and upper level limit\r\n"..
"  (inclusive for which this greeting is used\r\n"..
"- added time dependent message filtering (based on code submitted by\r\n"..
"  lebanoncyberspace)\r\n"..
"  use '<time:##.##:##.##>message' where ##.## are the 24hour based lower and\r\n"..
"  upper time limits (suggested by Balsta and Sentinelum)\r\n"..
"- delta-popup now also shows changes in player/officer notes\r\n"..
"\r\n"..
"|cFFFFFF7F30300.4|r\r\n"..
"- allow sorting by guild in char list\r\n"..
"- verified deDE localisation\r\n"..
"- double logout message for channel/guild members fixed\r\n"..
"- query to check for new version of addon added\r\n"..
"- help tooltip texts completed\r\n"..
"- added /gg fix command to automatically correct inconsistencies detected by\r\n"..
"   /gg check\r\n"..
"- display a warning if inconsistencies are detected at login\r\n"..
"- added /gg unnew command to clear invalid 'new' flag that marks a character as\r\n"..
"  'new in guild'\r\n"..
"- added new message code %C for the class of the player\r\n"..
"- added information tab\r\n"..
"\r\n"..
"|cFFFFFF7F30300.3|r\r\n"..
"- suppress achievment option added\r\n"..
"- automatic /who requests introduced in 30300.2 have been disabled by default,\r\n"..
"  go to Settings->Other to re-enable them\r\n"..
"- /who spam to chat has been disabled by default, go to Settings->Chat to\r\n"..
"  re-enable them (reported by Tebasile)\r\n"..
"- order of achievment grats and relog messages fixed in SendGreet (reported\r\n"..
"  by KingsTears and Enigma_TL, fix suggested by lebanoncyberspace)\r\n"..
"- added option (Settings->Other) to show a summary box showing offline changes\r\n"..
"  when you log in (requested by lebanoncyberspace)\r\n"..
"- list friend's notes in tooltip (requested by Sentinelum)\r\n"..
"- new greet message variables:\r\n"..
"  %c = char\r\n"..
"  %n = name as used today (depending on settings)\r\n"..
"  %a = alias\r\n"..
"  %m = main if available, %c else\r\n"..
"  %A = main alias if available, %m else if available, %c else\r\n"..
"  %l = level if available, empty else\r\n"..
"  %r = rankname if available, rank number else if available, empty else\r\n"..
"  %v = achievment if available, empty else\r\n"..
"  %g = guild alias if available, else guild if available, else empty\r\n"..
"  %G = guild name if available, else empty\r\n"..
"  (suggested by Sentinelum, Keith, AcmeHeroesInc and lebanoncyberspace)\r\n"..
"  The old %s entries still work (i.e. the extension is backwards compatible\r\n"..
"  to the old greetings you probably have stored)\r\n"..
"- a free note can be added to each character, it will be displayed in the\r\n"..
"  tooltip\r\n"..
"\r\n"..
"|cFFFFFF7F30300.2|r\r\n"..
"- greet list now properly shows achievment entries\r\n"..
"- automatically sending a /who query for players entering a channel for which\r\n"..
"  information is missing\r\n"..
"- fixed bug with listing offline/all players in guild\r\n"..
"- fixed bug listing guild members that were in channel twice\r\n"..
"- updated screenshots on curse.com\r\n"..
"\r\n"..
"|cFFFFFF7F30300.1|r\r\n"..
"- huge reorganisation: guild, friends and channel are no longer managed\r\n"..
"  seperately but in one list. Your existing data will automatically be\r\n"..
"  converted.\r\n"..
"  NOTE: if you had some characters stored in guilds for one char and\r\n"..
"  as friends or in channels for other chars, this may mean that you need\r\n"..
"  to manually verify combined entries and make minor adjustments\r\n"..
"- removed friends and channel tabs\r\n"..
"- add tooltip to char list with info about character\r\n"..
"- reorganise char list\r\n"..
"  add new fields: Alias, Guild, Channel, Friend, #friends\r\n"..
"- new filter options added to char list: guild only, my friends only,\r\n"..
"  with friends only, my channel only, with channel only, online only\r\n"..
"- added 'remove' button to char list\r\n"..
"- added 'set guild' button to char list\r\n"..
"- added 'check' button to char list\r\n"..
"- added 'who query' button to char list, this will start a /who query for\r\n"..
"  the current character, results will be parsed and stored\r\n"..
"- show player and officer note in player tooltip (not quite full guild roster\r\n"..
"  support but it's a start; full support suggested by Kobihunt)\r\n"..
"- extended queue tooltip with some more player info\r\n"..
"- added cleanup tab to remove stale data and stale characters\r\n"..
"  all 'orphans' (unassigned, no channel, no friends)\r\n"..
"  remove a specific friend (will be re-added)\r\n"..
"  remove a specific channel (will be re-added)\r\n"..
"  remove a specific guild (will be re-added)\r\n"..
"- achievments can now be congratulated for (requested by Jesterbob and many\r\n"..
"  others)\r\n"..
"- check for guild alert setting and pop up a box once if it is disabled\r\n"..
"- now properly handles channel names in upper, lower and mixed case (reported\r\n"..
"  by tochstn: Thorsten Duykers)\r\n"..
"- printing main name if an alt leaves the guild\r\n"..
"- printing alias and/or main for levelling up\r\n"..
"- added config setting to select whether to print achievment to chat\r\n"..
"- added config setting to select whether {} postfix is added to chat\r\n"..
"- added a page to the Interface->Addons configuration interface stating\r\n"..
"  that /gg opens the config dialog\r\n"..
"\r\n"..
"\r\n"..
"|cFFFFFF7F30200.5|r\r\n"..
"- moved the whole chat frame on event hook to the new chat filter system\r\n"..
"  in the hope that this will solve the various issues with the chat hook\r\n"..
"  (contributions by Wilgorix and Tandanu)\r\n"
