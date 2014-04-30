local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("GuildGreet", "deDE")
if not L then return end

-- Binding names
L["GuildGreet"] = "GuildGreet"
L["Open config window"] = "Konfigurationsfenster öffnen"
L["Clear greet list"] = "Grußliste leeren"
L["Test trigger"] = "Test trigger"
L["Greet Guild and Channel"] = "Gilde und Channel begrüssen"
L["Say goodbye to guild and channel"] = "Gilde und Channel verabschieden"
L["Say see you later to guild and channel"] = "Gilde und Channel vorübergehend verabschieden"

-- Names for the tabs
L["TabSettings"] = "Einstellungen"
L["TabGreetings"] = "Grüsse"
L["TabPlayers"] = "Charaktere"
L["TabCleanup"] = "Aufräumen"
L["TabColour"] = "Farben"
L["TabTodo"] = "Information"
L["SubTabGeneral"] = "Allgemein"
L["SubTabChat"] = "Chat"
L["SubTabGreeting"] = "Grüssen"
L["SubTabDebug"] = "Debug"
L["SubTabOther"] = "Anderes"

-- option frame
L["optionHeader"]	= "GuildGreet unterstützt den Optionen-Dialog nicht.\r\nTippe |cFFFFFF7F/gg|r um das Konfigurationsfenster zu öffnen."

-- Queue list
L["NEW"] = "NEU"
L["LEVEL"] = "LEVEL"
L["RANK"] = "RANG"
L["ACHV"] = "ERF"

-- Queue list tooltips
L["At %s, this character came online for the first time during this session."]	= "Um %s kam der Charakter erstmals diese Sitzung online."
L["At %s, this character came back online after being offline for %s."]	= "Um %s kam der Charakter wieder online, nachdem es %s offline war."
L[" Character used by player previously was %s."]	= " Charakter des Spielers war vorher %s."
L["At %s, this player joined the guild"]		= "Um %s ist dieser Spieler der Gilde beigetreten."
L["Player joined the guild before you logged on."]	= "Spieler ist der Gilde beigetreten bevor Du eingeloggt hast."
L["Character reached level %s."]		= "Charakter hat Level %s erreicht."
L["%s promoted the player to rank %s earlier."]	= "Spieler wurde von %s zum Rang %s befördert."
L["At %s, %s promoted this player to rank %s."]	= "Um %s wurde Spieler von %s zum Rang %s befördert."
L["Player was promoted to rank %s before you logged on."]	= "Der Spieler wurde zum Rang %s befördert, bevor Du eingeloggt hast."
L["Player has achieved %s."]	= "Der Spieler hat %s erreicht."
L[" Main character for this player is %s."]		= " Main dieses Spielers ist %s."
L["%d hour "]		= "%d Stunde "
L["%d min"]		= "%d Minute"
L["has increased his level from %s to %s"]	= "hat seinen Level von %s nach %s erhöht"
L[" (off)"]	= " (off)"
L["has left the guild"]	= "hat die Gilde verlassen"
L["has earned"]       = "erreicht"
L["No characters found"]	= "Es wurden keine Charaktere gefunden"

-- Settings tab: greeting options
--L["Always show relogs"]	= "Always show relogs"
--L["(Automatically assign Alias)"]	= "(Automatically assign Alias)"
--L["Only show relogs after more then %d min"]	= "Only show relogs after more then %d min"
