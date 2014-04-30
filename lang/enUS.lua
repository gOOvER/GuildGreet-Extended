-- English localization file for enUS and enGB.
local debug = false
--@debug@
debug = true
--@end-debug@

local L = LibStub("AceLocale-3.0"):NewLocale("GuildGreet", "enUS", true, debug)

--@localization(locale="enUS", format="lua_additive_table")@

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



