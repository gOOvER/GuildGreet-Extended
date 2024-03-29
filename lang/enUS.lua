local L = LibStub("AceLocale-3.0"):NewLocale("GuildGreet", "enUS", true)
if not L then return end

L["GuildGreet"] = true
L["Open config window"] = true
L["Clear greet list"] = true
L["Test trigger"] = true
L["Greet Guild and Channel"] = true
L["Say goodbye to guild and channel"] = true
L["Say see you later to guild and channel"] = true
L["Settings"] = true
L["Greetings"] = true
L["Players"] = true
L["Cleanup"] = true
L["Colour"] = true
L["General"] = true
L["Chat"] = true
L["Greeting"] = true
L["Other"] = true
L["Manage the messages you want to use for greeting"] = true
L["Custom collections"] = true
L["Set realm collection"] = true
L["Set guild collection"] = true
L["Set character collection"] = true
L["Current value"] = true
L["Create new collection"] = true
L["cancel"] = true
L["add"] = true
L["Selected collection"] = true
L["Global defaults"] = true
L["not defined"] = true
L["coming online"] = true
L["relogging"] = true
L["joining guild"] = true
L["leveling"] = true
L["bye char"] = true
L["night char"] = true
L["greet guild"] = true
L["greet channel"] = true
L["bye guild"] = true
L["night guild"] = true
L["bye channel"] = true
L["night channel"] = true
L["later guild"] = true
L["later channel"] = true
L["Configure settings for characters: ignore them, set main/alt and enter alias"] = true
L["Include ignored players in the list"] = true
L["Always show alts"] = true
L["Keep with main"] = true
L["Show only unassigned characters"] = true
L["Online only"] = true
L["My friends only"] = true
L["With friends only"] = true
L["Current channel only"] = true
L["Name"] = true
L["Type"] = true
L["Alias/Main"] = true
L["Guild"] = true
L["Rank"] = true
L["Player Note"] = true
L["{c}"] = true
L["{f}"] = true
L["#"] = true
L["Check consistency"] = true
L["Set alias"] = true
L["Set guild"] = true
L["Who query"] = true
L["Remove char"] = true
L["Set note"] = true
L["Edit public note"] = true
L["Edit officer note"] = true
L["Data cleanup"] = true
L["As you switch between characters in different guilds, as you add and remove characters from your friend lists and as characters join and leave channels, a lot of character information assembles. Some of these characters may no longer be played, they may be deleted, renamed or transferred to the opposite faction or other servers.\r\nThis tab helps you to clean up stale characters."] = true
L["Guild cleanup"] = true
L["This button allows you to choose any guild (except the one you belong to), it will then remove this guild from any character that had it assigned. If it is a guild one of your characters belongs to, this information will automatically be added again for all guild members of that guild."] = true
L["Friends cleanup"] = true
L["This button allows you to choose any of your characters that has managed characters on their friend list and to remove this character from all friend references. If this character still exists, it will again be added automatically to those characters which are on its friend list."] = true
L["Channel cleanup"] = true
L["This button allows you to remove a channel from all characters that belong to it. The next time they revisit the channel, it will again be added to them automatically."] = true
L["Orphan cleanup"] = true
L["This button removes all characters that are not main or alt, have no friends and belong to no channel."] = true
L["Guildless cleanup"] = true
L["This button removes all characters that do NOT belong to a Guild."] = true
L["Guildless display"] = true
L["This button displays all characters that do NOT belong to a Guild and displays final counts for both guildless and with a guild."] = true
L["Choose guild to clean up"] = true
L["Choose friend to clean up"] = true
L["Choose channel to clean up"] = true
L["Cleanup orphans"] = true
L["Cleanup Guildless"] = true
L["Display Guildless"] = true
L["Friends"] = true
L["Channel"] = true
L["Coming online"] = true
L["Going offline"] = true
L["Is offline"] = true
L["Alias"] = true
L["Greet list"] = true
L["Relogging"] = true
L["New member"] = true
L["Level up"] = true
L["Promotion"] = true
L["Achievment"] = true
L["Common"] = true
L["Output"] = true
L["Greet list header"] = true
L["Default colours"] = true
L["Configuration options to determine who, when and how to greet"] = true
L["Read the guildsettings from the guild info |cFFFF0000You must reload your interface after change this manually!"] = true
L["Write the config string"] = true
L["Greet alts with the same name as main by default"] = true
L["Randomly use alias and or main and alt names"] = true
L["Whisper greetings and grats to players"] = true
L["Whisper level up messages"] = true
L["Display your own characters"] = true
L["Automatically assign main/alt based on guild note"] = true
L["(include EGP officer notes)"] = true
L["(Automatically assign Alias)"] = true
L["Manage friend's list"] = true
L["Channel name to monitor"] = true
L["Configuration options for displaying the players waiting for a greeting"] = true
L["List grows upwards instead of downwards"] = true
L["List header is always visible"] = true
L["Printing information to chat"] = true
L["List alt and main names when player logs in"] = true
L["List alt and main names when player logs off"] = true
L["List to chat when a player levels up (online only)"] = true
L["List to chat when a player levels up (offline players, printed when you log in)"] = true
L["List to chat when a player leaves the guild"] = true
L["Add main name to chat when an alt sends a message"] = true
L["Add main name to chat when an alt sends a message, even if alt is ignored"] = true
L["Add main's alias to chat (if it exists and the above option is enabled)"] = true
L["Show source of character info in curly braces when printing names to chat"] = true
L["Show /who request and response text in chat"] = true
L["Show achievments of guild members with main/alt in chat"] = true
L["Greeting the guild and channel (per character setting)"] = true
L["Temporarily suppress greeting players"] = true
L["Greet guild when 'Greet Key' is pressed (also applies to saying bye)"] = true
L["Greet channel when 'Greet Key' is pressed (also applies to saying bye)"] = true
L["Automatically greet guild and/or channel when logging in (depends on settings above). |cFFFF0000Use carefully (see tooltip)."] = true
L["Supress all"] = true
L["Supress none"] = true
L["Don't put players coming online on the greet list"] = true
L["Don't put players joining the guild on the greet list"] = true
L["Don't put players that level up on the greet list"] = true
L["Don't put players that get promoted on the greet list"] = true
L["Don't put players that get achievments on the greet list"] = true
L["Don't congratulate players that just logged in"] = true
L["set"] = true
L["clear"] = true
L["Various settings"] = true
L["Use local time instead of server time"] = true
L["Show if newer versions of addons are available"] = true
L["Automatically start /who request when channel member with lacking info logs on"] = true
L["Show popup box summarising offline changes at login"] = true
L["Enable player context menu (may cause taint issues in raid frame, see tooltip)"] = true
L["Guild alias for:"] = true
L["Can't set guild alias while unguilded"] = true
L["Inconsistencies detected. Please use |cFFFFFF7F/gg check|r to display them or |cFFFFFF7F/gg fix|r to fix them"] = true
L["The player note changed for player"] = true
L["from"] = true
L["to"] = true
L["The new note is"] = true
L["A player note was added for player"] = true
L["The player note was removed for player"] = true
L["The old note was"] = true
L["The officer note changed for player"] = true
L["A officer note was added for player"] = true
L["The officer note was removed for player"] = true
L["to rank"] = true
L["was demoted from rank"] = true
L[""] = true
L["increased level from"] = true
L["has increased his level from %s to %s"] = true
L["The officer note from"] = true
L["too many matches for"] = true
L["not found"] = true
L["left guild"] = true
L["has left the guild"] = true
L[" is using version "] = true
L[" has updated from version "] = true
L[" to version "] = true
L["A newer Version of the addon is available."] = true
L["You have version "] = true
L["."] = true
L[" has version "] = true
L["Red"] = true
L["Green"] = true
L["Blue"] = true
L["Opacity"] = true
L["optionHeader"] = true
L["is not in guild"] = true
L["or a friend"] = true
L["or in channel"] = true
L["Listing all characters (also offline)"] = true
L["Listing online characters only"] = true
L["Main"] = true
L["(new rank)"] = true
L["Player Note"] = true
L["Officer Note"] = true
L["Class"] = true
L["Friends Note"] = true
L["Note"] = true
L["Could not parse command"] = true
L["GUILDGREET DEBUG IS NOW "] = true
L["Pasting to list"] = true
L["update"] = true
L["remove"] = true
L["Set guild collection"] = true
L["Set character collection"] = true
L["Set realm collection"] = true
L["No guild filter"] = true
L["No rank filter"] = true
L["IGNORE"] = true
L["MAIN"] = true
L["ALT"] = true
L["Ignored"] = true
L["Alts"] = true
L["Yes"] = true
L["No"] = true
L["New in guild"] = true
L["Last achievment"] = true
L["Channel(s)"] = true
L["Friends"] = true
L["Last on with"] = true
L["Online"] = true
L["Offline"] = true
L["In queue since"] = true
L["Unignore"] = true
L["Ignore"] = true
L["Set as main"] = true
L["Unset as main"] = true
L["Set as alt"] = true
L["Unset as alt"] = true
L["Set alias for character %s"] = true
L["Set guild for character %s"] = true
L["Set note for character %s"] = true
L["Edit public note for character %s"] = true
L["Edit officer note for character %s"] = true
L["Sending /who request for"] = true
L["Who results for"] = true
L["Character"] = true
L["removed"] = true
L["A tool to manage mains and alts in the guild and greet them"] = true
L["Usage"] = true
L["name"] = true
L["List alts of all members to chat"] = true
L["List alts of members that are online to chat"] = true
L["List alts of all members for copying"] = true
L["List main and alts for <name>"] = true
L["List main and alts for <name> with full class and level info"] = true
L["Print a dump of internal data for character <name> to chat"] = true
L["Clear the greet list without greeting anyone"] = true
L["Check if main-alt assignments are correct"] = true
L["Check if |cFFFFFF7FGuild member notification|r is enabled"] = true
L["without argument, show config frame"] = true
L["Lookup"] = true
L["Good bye"] = true
L[" days"] = true
L[" day"] = true
L[" hours"] = true
L[" hour"] = true
L[" minutes"] = true
L[" minute"] = true
L[" seconds"] = true
L[" second"] = true
L["No data found for character"] = true
L["Cannot set default colours while colour picker is open"] = true
L["You must reload your interface for this change to take effect. Shall this be done now?"] = true
L["Reload now"] = true
L["Reload later"] = true
L["You must manually reload your interface by typing /console reloadui"] = true
L["Listing known GuildGreet users"] = true
L["No other GuildGreet users known"] = true
L["Converting guild"] = true
L["found for realm"] = true
L["Converting channel"] = true
L["Converting friends found for realm"] = true
L["Verifying double main-alt entries"] = true
L["--> conflict:"] = true
L["is both main and alt. It's main"] = true
L["however is also main and alt, its main"] = true
L["has not been checked, but will be seperately."] = true
L["should probably be main."] = true
L["however is not main but an alt, its main"] = true
L["is neither main or alt."] = true
L["alt"] = true
L["has main"] = true
L["is its own main. This reference should be removed."] = true
L["character"] = true
L["Verifying main-alt relations part 2"] = true
L["which does not exist."] = true
L["which is not marked as main."] = true
L["Done. Type |cFFFFFF7F/gg fix|r to automatically fix these issues"] = true
L["Done"] = true
L["Verifying main-alt relations"] = true
L["Automatically fixing inconsistencies"] = true
L["will be the new main."] = true
L["will be the new main, even though it is also main and alt, its main"] = true
L["Moving alt"] = true
L["from main"] = true
L["to main"] = true
L["will become main for"] = true
L["and all its alts"] = true
L["is its own main. This reference has been removed."] = true
L["is neither main or alt but will become alt of"] = true
L["which does not exist. This reference will be removed."] = true
L["which is not marked as main. This will be set."] = true
L["Entries have been fixed. Check manually if all main-alt groups have the correct main. If not, use the '|cFFFFFF7F Promote to main|r' function."] = true
L["There seems to be a circular inconsistency that could not be fixed even after 10 iterations. Giving up. Please report this to gOOvER on the addon's page at www.github.com."] = true
L["Nothing needed to be fixed."] = true
L["Clearing 'new in guild' flag for all characters"] = true
L["Removing the 'new in guild' flag for"] = true
L["Guild member notification is active."] = true
L["|cFFFFFF7FGuild member notification|r is currently turned off (See Interface settings, Game, Social).\r\nThis means that GuildGreet is unable to reliably track when your guild mates come online or go offline.\r\n\r\nThis question will only be asked once. To manually check later on type |cFFFFFF7F/gg alert|r.\r\n\r\nDo you want to activate these notifications? (Recommended)"] = true
L["Activate notification"] = true
L["Leave inactive"] = true
L["Guild member notification has been turned on."] = true
L["Guild member notification has not been turned on. |cFFFF0000GuildGreet will not be able to reliably track your guild members coming online and going offline.|r"] = true
L["from character"] = true
L["Removed guild"] = true
L["Removed friend"] = true
L["Removed channel"] = true
L["Entry"] = true
L["was not found in list of available entries for mode."]= true
L["Orphan cleanup"] = true
L["Removed orphan"] = true
L["Removed guildless"] = true
L["Guildless cleanup"] = true
L["Guildless display"] = true
L["Can remove guildless"] = true
L["Select a guild to remove"] = true
L["Select a friend to remove"] = true
L["Select a channel to remove"] = true
L["No guilds found to remove"] = true
L["No friends found to remove"] = true
L["No channels found to remove"] = true
L["ChatMsg/Config string not found."] = true
L["ChatMsg/GuildGreet using default settings!"] = true
L["ChatMsg/Note to the guild master to create the config string"] = true
L["ChatMsg/To set the config string ..."] = true
L["ChatMsg/Config string not found."] = true
L["ChatMsg/GuildGreet using default settings!"] = true
L["ChatMsg/The config string seems to be corrupted. Please generating a new one."] = true
L["ChatMsg/GuildGreet using default settings!"] = true
L["ChatMsg/GuildGreet using your own settings!"] = true
L["ChatMsg/Note to the guild master to create the config string"] = true
L["ChatMsg/To set the config string ..."] = true
L["ChatMsg/GuildGreet using your own Settings. But the config string seems to be corrupted. Please generating a new one."] = true
L["ChatMsg/GuildGreet using your own Settings. But the config string seems to be corrupted. Please inform %s!"] = true
L["ChatMsg/GuildGreet using your own settings (But a config string is in the guild info available)."] = true
L["ChatMsg/Guild info written successfully!"] = true
L["ChatMsg/The guild info is too long..."] = true
L["Forced chatlist to be displayed in chat"] = true
L["Only show relogs after more then %d min"] = true