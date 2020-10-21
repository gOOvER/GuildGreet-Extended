-- English localization file for enUS and enGB.
local debug = false
--[===[@debug@
debug = true
--@end-debug@]===]

local L = LibStub("AceLocale-3.0"):NewLocale("GuildGreet", "enUS", true, debug)


-- Binding names
L["GuildGreet"] = "GuildGreet"
L["Open config window"] = "Open config window"
L["Clear greet list"] = "Clear greet list"
L["Test trigger"] = "Test trigger"
L["Greet Guild and Channel"] = "Greet Guild and Channel"
L["Say goodbye to guild and channel"] = "Say goodbye to guild and channel"
L["Say see you later to guild and channel"] = "Say see you later to guild and channel"

-- Names for the tabs
L["TabSettings"]	= "Settings"
L["TabGreetings"]	= "Greetings"
L["TabPlayers"]	= "Characters"
L["TabCleanup"]	= "Cleanup"
L["TabColour"]	= "Colours"
L["TabTodo"]	= "Information"
L["SubTabGeneral"]	= "General"
L["SubTabChat"]	= "Chat"
L["SubTabGreeting"]	= "Greeting"
L["SubTabDebug"]	= "Debug"
L["SubTabOther"]	= "Other"

-- option frame
L["optionHeader"]	= "GuildGreet does not support the option frame.\r\nType |cFFFFFF7F/gg|r to open its configuration dialog."

-- Queue list
L["NEW"] = "NEW"
L["LEVEL"] = "LEVEL"
L["RANK"] = "RANK"
L["ACHV"] = "ACHV"

-- Queue list tooltips
L["At %s, this character came online for the first time during this session."]	= "At %s, this character came online for the first time during this session."
L["At %s, this character came back online after being offline for %s."]	= "At %s, this character came back online after being offline for %s."
L[" Character used by player previously was %s."]	= " Character used by player previously was %s."
L["At %s, this player joined the guild"]		= "At %s, this player joined the guild"
L["Player joined the guild before you logged on."]	= "Player joined the guild before you logged on."
L["Character reached level %s."]		= "Character reached level %s."
L["%s promoted the player to rank %s earlier."]	= "%s promoted the player to rank %s earlier."
L["At %s, %s promoted this player to rank %s."]	= "At %s, %s promoted this player to rank %s."
L["Player was promoted to rank %s before you logged on."]	= "Player was promoted to rank %s before you logged on."
L["Player has achieved %s."]	= "Player has achieved %s."
L[" Main character for this player is %s."]		= " Main character for this player is %s."
L["%d hour "]		= "%d hour "
L["%d min"]		= "%d min"
L["has increased his level from %s to %s"]	= "has increased his level from %s to %s"
L[" (off)"]	= " (off)"
L["has left the guild"]	= "has left the guild"
L["has earned"]       = "has earned"
L["No characters found"]	= "No characters found"

-- Settings tab: greeting options
L["Always show relogs"]	= "Always show relogs"
L["(Automatically assign Alias)"]	= "(Automatically assign Alias)"
L["Only show relogs after more then %d min"]	= "Only show relogs after more then %d min"
L["Configuration options to determine who, when and how to greet"]	= "Configuration options to determine who, when and how to greet"
L["Read the guildsettings from the guild info |cFFFF0000You must reload your interface after change this manually!"]	= "Read the guildsettings from the guild info |cFFFF0000You must reload your interface after change this manually!" -- Needs review
L["Write the config string"] = "Write the config string" -- Needs review
L["Greet alts with the same name as main by default"]	= "Greet alts with the same name as main by default"
L["Randomly use alias and or main and alt names"]	= "Randomly use alias and or main and alt names"
L["Whisper greetings and grats to players"]	= "Whisper greetings and grats to players"
L["Whisper level up messages"]	= "Whisper level up messages"
L["Manage friend's list"]	= "Manage friend's list"
L["Automatically assign main/alt based on guild note"]	= "Automatically assign main/alt based on guild note"
L["(include EGP officer notes)"]	= "(include EGP officer notes)"
L["Channel name to monitor"]	= "Channel name to monitor"
L["Display your own characters"]	= "Display your own characters"
L["Always show level-up"] = "Always show level-up"
L["Only show level-up for levels above %d"]	= "Only show level-up for levels above %d"
L["Only update guild roster on events"]	= "Only update guild roster on events"
L["Update guild roster every %d seconds"]	= "Update guild roster every %d seconds"
L["<none>"]		= "<none>"

-- Settings tab: chat options
L["Printing information to chat"]	= "Printing information to chat"
L["Using default chat frame"] = "Using default chat frame"
L["Using chat frame %d (%s)"]	= "Using chat frame %d (%s)"
L["List alt and main names when player logs in"]	= "List alt and main names when player logs in"
L["List alt and main names when player logs off"]	= "List alt and main names when player logs off"
L["List to chat when a player levels up (online only)"]	= "List to chat when a player levels up (online only)"
L["List to chat when a player levels up (offline players, printed when you log in)"]	= "List to chat when a player levels up (offline players, printed when you log in)"
L["List to chat when a player leaves the guild"]	= "List to chat when a player leaves the guild"
L["Add main name to chat when an alt sends a message"]	= "Add main name to chat when an alt sends a message"
L["Add main name to chat when an alt sends a message, even if alt is ignored"]	= "Add main name to chat when an alt sends a message, even if alt is ignored"
L["Even re-add main name for main char (if the above option is enabled)"]	= "Even re-add main name for main char (if the above option is enabled)"
L["Add main's alias to chat (if it exists and the above option is enabled)"]	= "Add main's alias to chat (if it exists and the above option is enabled)"
L["Show source of character info in curly braces when printing names to chat"]	= "Show source of character info in curly braces when printing names to chat"
L["Show /who request and response text in chat"]	= "Show /who request and response text in chat"
L["Show achievments of guild members with main/alt in chat"] = "Show achievments of guild members with main/alt in chat"

-- Settings tab: greeting options
L["Greeting the guild and channel (per character setting)"]	= "Greeting the guild and channel (per character setting)"
L["Greet guild when 'Greet Key' is pressed (also applies to saying bye)"]	= "Greet guild when 'Greet Key' is pressed (also applies to saying bye)"
L["Greet channel when 'Greet Key' is pressed (also applies to saying bye)"]	= "Greet channel when 'Greet Key' is pressed (also applies to saying bye)"
L["Automatically greet guild and/or channel when logging in (depends on settings above). |cFFFF0000Use carefully (see tooltip)."]	= "Automatically greet guild and/or channel when logging in (depends on settings above). |cFFFF0000Use carefully (see tooltip)."
L["Temporarily suppress greeting players"] = "Temporarily suppress greeting players"
L["Supress all"]	= "Supress all"
L["Supress none"]	= "Supress none"
L["Don't put players coming online on the greet list"]	= "Don't put players coming online on the greet list"
L["Don't put players joining the guild on the greet list"]	= "Don't put players joining the guild on the greet list"
L["Don't put players that level up on the greet list"]	= "Don't put players that level up on the greet list"
L["Don't put players that get promoted on the greet list"]	= "Don't put players that get promoted on the greet list"
L["Don't put players that get achievments on the greet list"] = "Don't put players that get achievments on the greet list"
L["Don't congratulate players that just logged in"]	= "Don't congratulate players that just logged in"
L["Guild alias for:"]	= "Guild alias for: "
L["Can't set guild alias while unguilded"]	= "Can't set guild alias while unguilded"

-- Settings tab: other options
L["Various settings"]	= "Various settings"
L["Use local time instead of server time"]	= "Use local time instead of server time"
L["Show if newer versions of addons are available"] = "Show if newer versions of addons are available"
L["Automatically start /who request when channel member with lacking info logs on"]	= "Automatically start /who request when channel member with lacking info logs on"
L["Show popup box summarising offline changes at login"]	= "Show popup box summarising offline changes at login"
L["Enable player context menu (may cause taint issues in raid frame, see tooltip)"] = "Enable player context menu (may cause taint issues in raid frame, see tooltip)"

-- Settings tab: player list settings
L["Configuration options for displaying the players waiting for a greeting"]	= "Configuration options for displaying the players waiting for a greeting"
L["List grows upwards instead of downwards"]	= "List grows upwards instead of downwards"
L["List header is always visible"]	= "List header is always visible"
L["Display a maximum of %d queued players"]	= "Display a maximum of %d queued players"

-- Greetings tab
L["Manage the messages you want to use for greeting"]	= "Manage the messages you want to use for greeting"
L["Custom collections"]	= "Custom collections"
L["Create new collection"]		= "Create new collection"
L["Remove selection"]		= "Remove selection"
L["Set realm collection"]	= "Set realm collection"
L["Set guild collection"]	= "Set guild collection"
L["Set character collection"]	= "Set character collection"
L["Current value"]	= "Current value"
L["not defined"]		= "not defined"
L["Selected collection"]	= "Selected collection"

-- Greetins tab: selection header and buttons
L["Global defaults"]	= "Global defaults"
L["Collection %q"]	= "Collection %q"
L["%s : select the greeting category you want to edit"]	= "%s : select the greeting category you want to edit"
L["coming online"]	= "coming online"
L["relogging"]		= "relogging"
L["joining guild"]	= "joining guild"
L["promotion"]	= "promotion"
L["leveling"]	= "leveling"
L["bye char"]		= "bye char"
L["night char"]		= "night char"
L["greet guild"]		= "greet guild"
L["greet channel"]	= "greet channel"
L["bye guild"]	= "bye guild"
L["night guild"]	= "night guild"
L["bye channel"]	= "bye channel"
L["night channel"]	= "night channel"
L["later guildl"]	= "later guild"
L["later channel"]	= "later channel"
L["achievment"]	= "achievment"

-- Greetings tab: greetings editbox
L["Editbox/Achievment"] = "Edit achievment congratulations: first %s is player, second %s is achievment"
L["Editbox/Bye"] = "Edit leaving message (day) for players: first use of %s is replaced by player name"
L["Editbox/ByeChannel"] = "Edit message to say good bye to channel"
L["Editbox/ByeGuild"] = "Edit message to say good bye to guild: first use of %s is guild alias"
L["Editbox/Channel"] = "Edit message to greet channel: first use of %s is guild alias"
L["Editbox/Greet"] = "Edit default greeting message: first use of %s is replaced by player name"
L["Editbox/GreetBack"] = "Edit relog greeting message: first use of %s is replaced by player name"
L["Editbox/Guild"] = "Edit message to great guild: first use of %s is guild alias"
L["Editbox/LaterChannel"] = "Edit message to say see you later to channel"
L["Editbox/LaterGuild"] = "Edit message to say see you later to guild: first use of %s is guild alias"
L["Editbox/NewLevel"] = "Edit new level congratulations: first %s is player, second %s is new level"
L["Editbox/NewRank"] = "Edit promotion congratulations: first %s is player, second %s is new rank"
L["Editbox/Night"] = "Edit leaving message (night) for players: first use of %s is replaced by player name"
L["Editbox/NightChannel"] = "Edit message to say good night to channel"
L["Editbox/NightGuild"] = "Edit message to say good night to guild: first use of %s is guild alias"
L["Editbox/Welcome"] = "Edit welcome greeting message: first use of %s is replaced by player name"


L["ChatMsg/Config string found. GuildGreet using default settings from %s!"] = "Config string found. GuildGreet using default settings from %s!" -- Needs review
L["ChatMsg/Config string not found."] = "Config string not found." -- Needs review
L["ChatMsg/GuildGreet using default settings!"] = "GuildGreet using default settings!" -- Needs review
L["ChatMsg/GuildGreet using your own settings!"] = "GuildGreet using your own settings!" -- Needs review
L["ChatMsg/GuildGreet using your own settings (But a config string is in the guild info available)."] = "GuildGreet using your own settings (But a config string is in the guild info available)." -- Needs review
L["ChatMsg/GuildGreet using your own settings. But the config string seems to be corrupted. Please generating a new one."] = "GuildGreet using your own settings. But the config string seems to be corrupted. Please generating a new one." -- Needs review
L["ChatMsg/GuildGreet using your own settings. But the config string seems to be corrupted. Please inform %s!"] = "GuildGreet using your own settings. But the config string seems to be corrupted. Please inform %s!" -- Needs review
L["ChatMsg/Guild info written successfully!"] = "Guild info written successfully!" -- Needs review
L["ChatMsg/Note to the guild master to create the config string"] = "Do be kind to your fellow guild members and write the config string in the guild info." -- Needs review
L["ChatMsg/The config string seems to be corrupted. Please generating a new one."] = "The config string seems to be corrupted. Please generating a new one." -- Needs review
L["ChatMsg/The config string seems to be corrupted. Please inform %s!"] = "The config string seems to be corrupted. Please inform %s!" -- Needs review
L["ChatMsg/The guild info is too long..."] = "The guild info is too long, delete at least %d characters and try again!" -- Needs review
L["ChatMsg/To set the config string ..."] = "To set the config string use the command /gg, uncheck the <Read the guildsettings from the guildinfo>-checkbox, make a reload, make the settings for your members and press the <Whrite the config string>-button." -- Needs review
