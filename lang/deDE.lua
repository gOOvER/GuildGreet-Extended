local L = LibStub("AceLocale-3.0"):NewLocale("GuildGreet", "deDE")
if not L then return end

L[" (off)"] = " (off)"
L[" Character used by player previously was %s."] = " Charakter des Spielers war vorher %s."
L[" Main character for this player is %s."] = " Main dieses Spielers ist %s."
L["%d hour "] = "%d Stunde "
L["%d min"] = "%d Minute"
L["%s : select the greeting category you want to edit"] = "%s : wähle die Grusskategorie, welche Du bearbeiten willst"
L["%s promoted the player to rank %s earlier."] = "Spieler wurde von %s zum Rang %s befördert."
L["(Automatically assign Alias)"] = "Automatische Alias-Zuordnung"
L["(include EGP officer notes)"] = "(EGP-Offiziersnotiz berücksichtigen)"
L["<none>"] = "<Kein Channel>"
L["achievment"] = "Erfolg"
L["ACHV"] = "ERF"
L["Add main name to chat when an alt sends a message"] = "Im Chat den Namen des Mains vor Nachrichten eines Twinks stellen"
L["Add main name to chat when an alt sends a message, even if alt is ignored"] = "Im Chat den Namen des Mains auch dann vor Nachricht stellen, wenn der Charakter ignoriert wird"
L["Add main's alias to chat (if it exists and the above option is enabled)"] = "Im Chat den Alias, anstelle des Namens des Mains, vor Nachrichten eines Twinks stellen (falls obige Option aktiviert ist)."
L["Always show level-up"] = "Stufenaufstieg immer anzeigen"
L["Always show relogs"] = "Relogs immer zeigen"
L["At %s, %s promoted this player to rank %s."] = "Um %s wurde dieser Spieler von %s zum Rang %s befördert."
L["At %s, this character came back online after being offline for %s."] = "Um %s kam der Charakter wieder online, nachdem er %s offline war."
L["At %s, this character came online for the first time during this session."] = "Um %s kam der Charakter erstmals während dieser Sitzung online."
L["At %s, this player joined the guild"] = "Um %s ist dieser Spieler der Gilde beigetreten."
L["Automatically assign main/alt based on guild note"] = "Alt/Main basierend auf der Gildennotiz zuweisen"
L["Automatically greet guild and/or channel when logging in (depends on settings above). |cFFFF0000Use carefully (see tooltip)."] = "Automatisch beim Einloggen Gilde und Channel begrüssen (je nach Einstellung oben) |cFFFF0000Vorsichtig benutzen (vgl. Tooltip)."
L["Automatically start /who request when channel member with lacking info logs on"] = "Automatisch eine /who-Anfrage starten, wenn ein Channel-Mitglied einloggt, für das Information fehlt"
L["bye channel"] = "Nacht Gilde"
L["bye char"] = "Tschüss Spieler"
L["bye guild"] = "Tschüss Gilde"
L["Can't set guild alias while unguilded"] = "Kann keinen Gilden-Alias setzen, ohne in Gilde zu sein"
L["Channel name to monitor"] = "Zu verfolgender Channel-Name"
L["Character reached level %s."] = "Charakter hat Stufe %s erreicht."
--[[Translation missing --]]
--[[ L["ChatMsg/Config string found. GuildGreet using default settings from %s!"] = ""--]] 
--[[Translation missing --]]
--[[ L["ChatMsg/Config string not found."] = ""--]] 
--[[Translation missing --]]
--[[ L["ChatMsg/Guild info written successfully!"] = ""--]] 
--[[Translation missing --]]
--[[ L["ChatMsg/GuildGreet using default settings!"] = ""--]] 
--[[Translation missing --]]
--[[ L["ChatMsg/GuildGreet using your own settings (But a config string is in the guild info available)."] = ""--]] 
--[[Translation missing --]]
--[[ L["ChatMsg/GuildGreet using your own settings!"] = ""--]] 
--[[Translation missing --]]
--[[ L["ChatMsg/GuildGreet using your own settings. But the config string seems to be corrupted. Please generating a new one."] = ""--]] 
--[[Translation missing --]]
--[[ L["ChatMsg/GuildGreet using your own settings. But the config string seems to be corrupted. Please inform %s!"] = ""--]] 
--[[Translation missing --]]
--[[ L["ChatMsg/Note to the guild master to create the config string"] = ""--]] 
--[[Translation missing --]]
--[[ L["ChatMsg/The config string seems to be corrupted. Please generating a new one."] = ""--]] 
--[[Translation missing --]]
--[[ L["ChatMsg/The config string seems to be corrupted. Please inform %s!"] = ""--]] 
--[[Translation missing --]]
--[[ L["ChatMsg/The guild info is too long..."] = ""--]] 
--[[Translation missing --]]
--[[ L["ChatMsg/To set the config string ..."] = ""--]] 
L["Clear greet list"] = "Grußliste leeren"
L["Collection %q"] = "Sammlung %q"
L["coming online"] = "Einloggen"
L["Configuration options for displaying the players waiting for a greeting"] = "Konfigurationsoptionen für die Anzeige von Spielern, die auf eine Begrüssung warten"
L["Configuration options to determine who, when and how to greet"] = "Konfigurationsoptionen, wen, wann und wie zu grüßen"
L["Create new collection"] = "Neue Sammlung erzeugen"
L["Current value"] = "Gegenwärtiger Wert"
L["Custom collections"] = "Persönliche Sammlung"
L["Display a maximum of %d queued players"] = "Maximal %d Spieler in Schlange anzeigen"
L["Display your own characters"] = "Zeige eigene Charaktere an"
L["Don't congratulate players that just logged in"] = "Spielern die gerade online gekommen sind nicht gratulieren."
L["Don't put players coming online on the greet list"] = "Charaktere, die einloggen nicht in Grussliste setzen"
L["Don't put players joining the guild on the greet list"] = "Charaktere, die der Gilde beitreten, nicht in Grussliste setzen"
L["Don't put players that get achievments on the greet list"] = "Charaktere, die einen Erfolg erreicht haben, nicht in Grussliste setzen"
L["Don't put players that get promoted on the greet list"] = "Charaktere, die befördert wurden, nicht in Grussliste setzen"
L["Don't put players that level up on the greet list"] = "Charaktere, die eine neue Stufe erreicht haben, nicht in Grussliste setzen"
--[[Translation missing --]]
--[[ L["Editbox/Achievment"] = ""--]] 
--[[Translation missing --]]
--[[ L["Editbox/Bye"] = ""--]] 
--[[Translation missing --]]
--[[ L["Editbox/ByeChannel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Editbox/ByeGuild"] = ""--]] 
--[[Translation missing --]]
--[[ L["Editbox/Channel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Editbox/Greet"] = ""--]] 
--[[Translation missing --]]
--[[ L["Editbox/GreetBack"] = ""--]] 
--[[Translation missing --]]
--[[ L["Editbox/Guild"] = ""--]] 
--[[Translation missing --]]
--[[ L["Editbox/LaterChannel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Editbox/LaterGuild"] = ""--]] 
--[[Translation missing --]]
--[[ L["Editbox/NewLevel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Editbox/NewRank"] = ""--]] 
--[[Translation missing --]]
--[[ L["Editbox/Night"] = ""--]] 
--[[Translation missing --]]
--[[ L["Editbox/NightChannel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Editbox/NightGuild"] = ""--]] 
--[[Translation missing --]]
--[[ L["Editbox/Welcome"] = ""--]] 
L["Enable player context menu (may cause taint issues in raid frame, see tooltip)"] = "Kontextmenu für Spieler aktivieren (kann zu Taint-Problemem mit dem Raidframe führen, siehe Tooltip)"
L["Even re-add main name for main char (if the above option is enabled)"] = "Im Chat den Namen des Mains sogar für den Main nochmals anfügen (falls obige Option aktiviert ist)"
L["Global defaults"] = "Standardeinstellungen"
L["Greet alts with the same name as main by default"] = "Standardmässig Alts mit dem Namen des Main grüßen"
L["greet channel"] = "Channel grüssen"
L["Greet channel when 'Greet Key' is pressed (also applies to saying bye)"] = "Channel begrüssen, wenn 'Greet Key' gedrückt wird (gilt auch beim Verabschieden)"
L["greet guild"] = "Guild grüssen"
L["Greet Guild and Channel"] = "Gilde und Channel begrüssen"
L["Greet guild when 'Greet Key' is pressed (also applies to saying bye)"] = "Gilde begrüssen, wenn 'Greet Key' gedrückt wird (gilt auch beim Verabschieden)"
L["Greeting the guild and channel (per character setting)"] = "Gilde und Channel grüssen (Einstellung pro Charakter)"
L["Guild alias for:"] = "Gilden-Alias für: "
L["GuildGreet"] = "GuildGreet"
L["has earned"] = "hat erreicht"
L["has increased his level from %s to %s"] = "hat seine Stufe von %s auf %s erhöht"
L["has left the guild"] = "hat die Gilde verlassen"
L["joining guild"] = "Gildenbeitritt"
L["later channel"] = "Später Channel"
L["later guildl"] = "Später Gilde"
L["LEVEL"] = "LEVEL"
L["leveling"] = "Levelup"
L["List alt and main names when player logs in"] = "Alle Spielernamen beim Einloggen auflisten"
L["List alt and main names when player logs off"] = "Alle Spielernamen beim Ausloggen auflisten"
L["List grows upwards instead of downwards"] = "Liste wächst nach oben statt unten"
L["List header is always visible"] = "Listen überschrift ist immer sichtbar"
L["List to chat when a player leaves the guild"] = "Im Chat anzeigen, wenn ein Spieler die Gilde verlässt"
L["List to chat when a player levels up (offline players, printed when you log in)"] = "Im Chat anzeigen, wenn ein Spieler eine neue Stufe erreicht hat (offline Spieler, wird angezeigt wenn Du einloggst)"
L["List to chat when a player levels up (online only)"] = "Im Chat anzeigen, wenn ein Spieler eine neue Stufe erreicht hat (nur online)"
L["Manage friend's list"] = "Freundesliste verwalten"
L["Manage the messages you want to use for greeting"] = "Verwaltet die Nachrichten, die Du zur Begrüssung verwendst"
L["NEW"] = "NEU"
L["night channel"] = "Nacht Channel"
L["night char"] = "Nacht Spieler"
L["night guild"] = "Tschüss Channel"
L["No characters found"] = "Keine Charaktere gefunden"
L["not defined"] = "nicht definiert"
L["Only show level-up for levels above %d"] = "Zeige Stufenaufstieg nur für Stufen höher als %d"
L["Only show relogs after more then %d min"] = "Zeige Relogs nur nach mehr als %d Minuten"
L["Only update guild roster on events"] = "Gildenliste nur bei Ereignis prüfen"
L["Open config window"] = "Konfigurationsfenster öffnen"
L["optionHeader"] = [=[GuildGreet unterstützt das Options-Fenster nicht.
Tippe |cFFFFFF7F/gg|r, um das Konfigurationsfenster zu öffnen.]=]
L["Player has achieved %s."] = "Spieler hat %s erreicht."
L["Player joined the guild before you logged on."] = "Spieler ist der Gilde beigetreten bevor Du eingeloggt hast."
L["Player was promoted to rank %s before you logged on."] = "Der Spieler wurde zum Rang %s befördert, bevor Du eingeloggt hast."
L["Printing information to chat"] = "Zeige Informationen im Chat an"
L["promotion"] = "Beförderung"
L["Randomly use alias and or main and alt names"] = "Zufällig Namen und Alias von Main und Alt verwenden"
L["RANK"] = "RANG"
L["Read the guildsettings from the guild info |cFFFF0000You must reload your interface after change this manually!"] = "Lese die Gildeneinstellungen aus der Gildeninfo |cFFFF0000Du musst nach dem Ändern das Interface neu laden!"
L["relogging"] = "Reloggen"
L["Remove selection"] = "Markierung entfernen"
L["Say goodbye to guild and channel"] = "Gilde und Channel verabschieden"
L["Say see you later to guild and channel"] = "Gilde und Channel vorübergehend verabschieden"
L["Selected collection"] = "Markierte Sammlung"
L["Set character collection"] = "Charakter-Sammlung setzen"
L["Set guild collection"] = "Gilden-Sammlung setzen"
L["Set realm collection"] = "Server-Sammlung setzen"
L["Show /who request and response text in chat"] = "Zeige /who Anfragen und Antworten im Chat"
L["Show achievments of guild members with main/alt in chat"] = "Im Chat Erfolge von Gildenmitgliedern mit Main/Twink anzeigen"
L["Show if newer versions of addons are available"] = "Anzeigen, wenn neuere Versionen des Addons verfügbar sind"
L["Show popup box summarising offline changes at login"] = "Zeige Popup-Liste aller Offline-Änderung beim Einloggen"
L["Show source of character info in curly braces when printing names to chat"] = "Quelle der Charakterinformationen in geschweiften Klammern im Chat hinter dem Namen anzeigen"
L["SubTabChat"] = "Chat"
L["SubTabDebug"] = "Debug"
L["SubTabGeneral"] = "Allgemein"
L["SubTabGreeting"] = "Grüssen"
L["SubTabOther"] = "Anderes"
L["Supress all"] = "Alle unterdrücken"
L["Supress none"] = "Alle zulassen"
L["TabCleanup"] = "Aufräumen"
L["TabColour"] = "Farben"
L["TabGreetings"] = "Grüsse"
L["TabPlayers"] = "Charaktere"
L["TabSettings"] = "Einstellungen"
L["TabTodo"] = "Information"
L["Temporarily suppress greeting players"] = "Vorübergehend Charaktere nicht grüssen"
L["Test trigger"] = "Test trigger"
L["Update guild roster every %d seconds"] = "Gildenliste alle %d Sekunden prüfen"
L["Use local time instead of server time"] = "Lokalzeit statt Serverzeit verwenden"
L["Using chat frame %d (%s)"] = "Verwende Chatfenster %d (%s)"
L["Using default chat frame"] = "Standard Chatfenster verwenden"
L["Various settings"] = "Verschieden Einstellungen"
L["Whisper greetings and grats to players"] = "Spieler anflüstern"
L["Whisper level up messages"] = "Levelup anflüstern"
L["Write the config string"] = "Schreibe den Config-String"

