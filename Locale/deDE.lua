-- Deutsch (German)
-------------------
-- Ae		ae ä
-- Oe		oe ö
-- Ue		ue ü

if (GetLocale() == "deDE") then

if (not GLDG_TXT) then
	GLDG_TXT = {}
end


-- Players tab
GLDG_TXT.playersheader	= "Spezielle Einstellungen für Gildenmitglieder verwalten"
GLDG_TXT.markIGN	= "IGNORIEREN"
GLDG_TXT.markMAIN	= "MAIN"
GLDG_TXT.markALT	= "ALT"
GLDG_TXT.ignores	= "Ignorierte Spieler in der Liste mit einschlie\195\159en"
GLDG_TXT.showalt	= "Zeigen Sie immer Alts"
GLDG_TXT.groupalt	= "Unterhalb vom Main"
GLDG_TXT.filterUnassigned = "Zeige nur nicht zugewiesene Spieler"
GLDG_TXT.filterGuild		= "Nur Gildenmitglieder"
GLDG_TXT.filterOnline		= "Nur Online"
GLDG_TXT.filterMyFriends	= "Nur meine Freunde"
GLDG_TXT.filterWithFriends	= "Nur mit Freunden"
GLDG_TXT.filterCurrentChannel	= "Nur aktueller Channel"
GLDG_TXT.filterWithChannel	= "Nur mit Channel"
GLDG_TXT.noGuildFilter		= "Kein Gildenfilter"
GLDG_TXT.noRankFilter		= "Kein Rangfilter"
GLDG_TXT.noClassFilter		= "Kein Klassenfilter"
GLDG_TXT.guildSort		= "Nach Gilde sortieren"
GLDG_TXT.pbsign		= "Ignorieren"
GLDG_TXT.pbrign		= "Grü\195\159en"
GLDG_TXT.pbalias	= "Alias setzen"
GLDG_TXT.pbsmain	= "Als Main setzen"
GLDG_TXT.pbrmain	= "Kein Main"
GLDG_TXT.pbpmain	= "Zum Main"
GLDG_TXT.pbsalt		= "Als Alt setzen"
GLDG_TXT.pbralt		= "Kein Alt"
GLDG_TXT.pbdelete	= "Löschen"
GLDG_TXT.pbcheck	= "Konsistenz prüfen"
GLDG_TXT.pbguild	= "Gilde setzen"
GLDG_TXT.pbwho		= "Who Abfrage"
GLDG_TXT.pbremove	= "Char löschen"
GLDG_TXT.pbnote		= "Notiz setzen"
GLDG_TXT.pbpublicnote	= "Öffentliche Notiz bearbeiten"
GLDG_TXT.pbofficernote	= "Offiziersotiz bearbeiten"
GLDG_TXT.mainhead	= "Main für %s wählen"
GLDG_TXT.aliashead	= "Alias für %s setzen"
GLDG_TXT.guildhead	= "Gilde für %s setzen"
GLDG_TXT.notehead	= "Notiz für %s setzen"
GLDG_TXT.PublicNotehead = "öffentliche Notiz für %s bearbeiten"
GLDG_TXT.OfficerNotehead = "Offiziersnotiz für %s bearbeiten"

GLDG_TXT.headerName	= "Name"
GLDG_TXT.headerType	= "Typ"
GLDG_TXT.headerAlias	= "Alias/Main"
GLDG_TXT.headerGuild	= "Gilde"
GLDG_TXT.headerRankname	= "Rang"
GLDG_TXT.headerPnote	= "Spielernotiz"
GLDG_TXT.headerOnote	= "Offiziersnotiz"
GLDG_TXT.headerChannel	= "{c}"
GLDG_TXT.headerFriend	= "{f}"
GLDG_TXT.headerNumFriends = "#"
GLDG_TXT.charRemoved1	= "Charakter"
GLDG_TXT.charRemoved2	= "gelöscht"

GLDG_TXT.tipIgnore	= "Ignoriert"
GLDG_TXT.tipAlias	= "Alias"
GLDG_TXT.tipMain	= "Main"
GLDG_TXT.tipMainYes	= "Yes"
GLDG_TXT.tipAlts	= "Twinks"
GLDG_TXT.tipGuild	= "Gilde"
GLDG_TXT.tipNew		= "Neu in Gilde"
GLDG_TXT.tipRank	= "Rang"
GLDG_TXT.tipNewRank	= "(neuer Rang)"
GLDG_TXT.tipPlayerNote	= "Spielernotiz"
GLDG_TXT.tipOfficerNote = "Offiziersnotiz"
GLDG_TXT.tipNote	= "Notiz"
GLDG_TXT.tipClass	= "Klasse"
GLDG_TXT.tipLevel	= "Level"
GLDG_TXT.tipLast	= "Zuletzt on mit"
GLDG_TXT.tipOnline	= "Online"
GLDG_TXT.tipOnlineYes	= "Online"
GLDG_TXT.tipOffline	= "Ging off um"
GLDG_TXT.tipQueue	= "In Liste seit"
GLDG_TXT.tipFriends	= "Freunde"
GLDG_TXT.tipFriendNote	= "Freunde-Notiz"
GLDG_TXT.tipChannels	= "Channel"
GLDG_TXT.tipAchievment  = "Letzter Erfolg"

-- Cleanup tab
GLDG_TXT.cleanupHeader	= "Datenbereinigung"
GLDG_TXT.cleanupInfo		= "Beim eim Wechsel zwischen Charakteren verschiedener Gilden, beim Hinzufügen und Entfernen von Charakteren zur Freundesliste, beim Beitreten und Verlassen von Channels wird viele Information zu anderen Charakteren gesammelt. Einige dieser Charakter werden vielleicht nicht mehr gespielt, wurden gelöscht, zur anderen Fraktion oder auf einen anderen Server transferiert.\r\nDiese Seite hilft Dir dabei, Altlasten zu bereinigen."
GLDG_TXT.cleanupGuildHeader	= "Bereinigung von Gilden"
GLDG_TXT.cleanupGuildInfo	= "Dieser Knopf erlaubt Dir eine Gilde auszuwählen, danach wird diese Gilde von allen Charakteren, denen sie zugeordnet ist entfernt. Falls es sich um eine Gilde handelt, in der Du einen Charakter hast, wird diese Information automatisch wieder zugefügt, wenn Du das nächste mal mit diesem einloggst."
GLDG_TXT.cleanupFriendsHeader	= "Bereinigung von Freunden"
GLDG_TXT.cleanupFriendsInfo	= "Dieser Knopf erlaubt Dir einen Deiner Charakter auszuwählen, danach wird bei allen Charakteren dieser als Freunde-Referenz entfernt. Falls der Charakter noch existiert, wird er wieder automatisch als Referenz all seiner Freunde hinzugefügt, wenn damit das nächste mal eingelogt wird."
GLDG_TXT.cleanupChannelHeader	= "Bereinigung von Channeln"
GLDG_TXT.cleanupChannelInfo	= "Dieser Knopf erlaubt Dir, einen Kanal zu wählen, der aus der Referenz aller Charaktere entfernt wird. Das nächste mal, wo sie diesem Kanal beitreten werden dieser automatisch wieder referenziert."
GLDG_TXT.cleanupOrphanHeader	= "Bereinigung von 'Waisen'"
GLDG_TXT.cleanupOrphanInfo	= "Dieser Knopf entfernt alle Charaktere, die weder Main noch Twink sind und keine Freunde oder Channels referenziert haben."
--~~~ MSN1: Added initialization of static variables for 2 new buttons' text (for deleting and displaying guildless characters)
GLDG_TXT.cleanupGuildlessHeader	= "Gildenlose aufräumen"
GLDG_TXT.cleanupGuildlessInfo	= "Dieser Button entfernt alle, welche nicht in einer Gilde (Gildenlos) sind"
GLDG_TXT.displayGuildlessHeader	= "Gildenlos Anzeige"
GLDG_TXT.displayGuildlessInfo	= "This button displays all characters that do NOT belong to a Guild and displays final counts for both guildless and with a guild."
--~~~~

GLDG_TXT.cleanupGuild		= "Wähle zu entfernende Gilde"
GLDG_TXT.cleanupFriends		= "Wähle zu entfernenden Freund"
GLDG_TXT.cleanupChannel		= "Wähle zu entfernenden Channel"
GLDG_TXT.cleanupOrphan		= "Bereinige 'Waisen'"
--~~~ MSN1: Added initialization of static variables for 2 new buttons' mouseover popup window info (for deleting and displaying guildless characters)
GLDG_TXT.cleanupGuildless	= "Cleanup Gildenlose"
GLDG_TXT.displayGuildless	= "Zeige Gildenlose"
--~~~~

GLDG_TXT.cleanupHeaderEntryGuild	= "Wähle eine zu entfernende Gilde"
GLDG_TXT.cleanupHeaderEntryFriends	= "Wähle einen zu entfernenden Freund"
GLDG_TXT.cleanupHeaderEntryChannel	= "Wähle einen zu entfernenden Channel"
GLDG_TXT.cleanupHeaderNoEntryGuild	= "Keine Gilden gefunden, die entfernt werden können"
GLDG_TXT.cleanupHeaderNoEntryFriends	= "Keine Freunde gefunden, die entfernt werden können"
GLDG_TXT.cleanupHeaderNoEntryChannel	= "Keine Channels gefunden, die entfernt werden können"
GLDG_TXT.cleanupRemoveGuild1		= "Gilde"
GLDG_TXT.cleanupRemoveGuild2		= "wurde für Charakter"
GLDG_TXT.cleanupRemoveGuild3		= "entfernt"
GLDG_TXT.cleanupRemoveFriend1		= "Freund"
GLDG_TXT.cleanupRemoveFriend2		= GLDG_TXT.cleanupRemoveGuild2
GLDG_TXT.cleanupRemoveFriend3		= GLDG_TXT.cleanupRemoveGuild3
GLDG_TXT.cleanupRemoveChannel1		= "Channel"
GLDG_TXT.cleanupRemoveChannel2		= GLDG_TXT.cleanupRemoveGuild2
GLDG_TXT.cleanupRemoveChannel3		= GLDG_TXT.cleanupRemoveGuild3
GLDG_TXT.cleanupNotfound1		= "Eintrag"
GLDG_TXT.cleanupNotfound2		= "wurde nicht in der Liste der verfügbaren Einträge gefunden."
GLDG_TXT.cleanupOrphan			= "Bereinigung von 'Waisen'"
GLDG_TXT.cleanupRemovedOrphan1		= "'Waise'"
GLDG_TXT.cleanupRemovedOrphan2		= "wurde entfernt"
--~~~ MSN1: Added initialization of static variables for 2 new buttons' displaying of list/count, for deleting and displaying guildless characters
GLDG_TXT.cleanupGuildless		= "Guildless cleanup"
GLDG_TXT.cleanupRemovedGuildless1	= "Removed guildless"
GLDG_TXT.cleanupRemovedGuildless2	= ""
GLDG_TXT.displayGuildless		= "Guildless display"
GLDG_TXT.displayRemovedGuildless1	= "Can remove guildless"
GLDG_TXT.displayRemovedGuildless2	= ""
--~~~~

-- Colour tab
GLDG_TXT.colGuild	= "Gilde"
GLDG_TXT.colFriends	= "Freunde"
GLDG_TXT.colChannel	= "Channel"
GLDG_TXT.colChatHeader	= "Chat"
GLDG_TXT.colOn		= "Einloggen"
GLDG_TXT.colGoOff	= "Ausloggen"
GLDG_TXT.colIsOff	= "Ist offline"
GLDG_TXT.colAlias	= "Alias"
GLDG_TXT.colListHeader	= "Grussliste"
GLDG_TXT.colList	= "Einloggen"
GLDG_TXT.colRelog	= "Wieder-einloggen"
GLDG_TXT.colNew		= "Neues Mitglied"
GLDG_TXT.colLevel	= "Level erhöht"
GLDG_TXT.colRank	= "Beförderung"
GLDG_TXT.colAchievment	= "Erfolg"
GLDG_TXT.colCommonHeader = "Allgemein"
GLDG_TXT.colHelp	= "Chat"
GLDG_TXT.colHeader	= "Listentitel"
GLDG_TXT.colDefault	= "Standardfarben"

-- Colour picker extension
GLDG_TXT.red		= "Rot"
GLDG_TXT.green		= "Grün"
GLDG_TXT.blue		= "Blau"
GLDG_TXT.opactiy	= "Transparenz"
GLDG_TXT.colourConfig	= "Kann nicht zwei Farben gleichzeitg ändern"
GLDG_TXT.colourDefault	= "Kann Farben nicht zurücksetzen, solange Farbwahl offen ist"

-- Todo tab
GLDG_TXT.infoTodo	= "Todo und Wunschliste"
GLDG_TXT.infoHistory	= "Versions-Historie"
GLDG_TXT.infoHelp	= "Bedienungsanleitung"

-- Common use
GLDG_TXT.set		= "Setzen"
GLDG_TXT.cancel		= "Abbrechen"
GLDG_TXT.update		= "Update"
GLDG_TXT.delete		= "Entfernen"
GLDG_TXT.add		= "Hinzufügen"
GLDG_TXT.clear		= "Löschen"

-- Help, About and Listing
GLDG_TXT.help			= "Verwaltet Mains und Twinks der Gilde und grüsst sie"
GLDG_TXT.usage			= "Benutzung"
GLDG_TXT.name			= "name"
GLDG_TXT.help_all		= "Listet Twinks aller Mitglieder im Chat"
GLDG_TXT.help_online		= "Listet Twinks aller Mitglieder, die online sind im Chat"
GLDG_TXT.help_list		= "Listet Twinks aller Mitglieder zum Kopieren"
GLDG_TXT.help_name		= "Listet Main und Twinks für <name>"
GLDG_TXT.help_name_full		= "Listet Main und Twinks für <name> mit voller Klassen- und Level-Info"
GLDG_TXT.help_name_detail       = "Zeige interne Daten für Charakter <name> im Chat an"
GLDG_TXT.help_clear		= "Grussliste leeren, ohne jemanden zu grüssen"
GLDG_TXT.help_check		= "Prüfen, ob Main-Twink Zuweisungen korrekt sind"
GLDG_TXT.help_alert		= "Prüfen, ob |cFFFFFF7FGuild member notification|r aktiv ist"
GLDG_TXT.help_urbin		= "Listet Details aller Addons von Urbin"
GLDG_TXT.noargs			= "ohne Argumente wird der Konfigurationsdialog gezeigt"
GLDG_TXT.listall		= "Listet alle Gildenmitglieder (auch offline)"
GLDG_TXT.listonline		= "Listet nur Gildenmitglieder, die online sind"
GLDG_TXT.notinguild		= "ist nicht in der Gilde"
GLDG_TXT.notfriend		= "oder auf der Freundesliste"
GLDG_TXT.notchannel		= "oder im Channel"
GLDG_TXT.pasting		= "Füge in Listenfenster"
GLDG_TXT.disabled		= "Unterstützung der Freundesliste ist deaktiviert"
GLDG_TXT.disabled_c		= "Unterstützung der Channelmitglider ist deaktiviert"
GLDG_TXT.command		= "Unbekannter Befehl"
GLDG_TXT.argmissing		= "Ein weiterer Parameter wird benötigt nach Befehl"
GLDG_TXT.by			= "von"
GLDG_TXT.version		= "Version"
GLDG_TXT.date			= "Datum"
GLDG_TXT.web			= "Webseite"
GLDG_TXT.slash			= "Slash Kommando"
GLDG_TXT.urbin			= "Andere addons von Urbin"

-- Force Chatlist
GLDG_TXT.forceChatList	= "Chatlist wird nun wieder im Chat angezeigt"

-- queries
GLDG_TXT.request	= "Sende /who Anfrage für"
GLDG_TXT.whoResult1	= "Who Resultat für"
GLDG_TXT.whoResult2	= "Level"

-- delta popup
GLDG_TXT.deltaGuild	= "Gilde"
GLDG_TXT.deltaFriends	= "Freunde"
GLDG_TXT.deltaChannel	= "Channel"
GLDG_TXT.deltaNewMember	= "Neues Mitglied"
GLDG_TXT.deltaNewFriend	= "Neuer Freund"
GLDG_TXT.deltaLeftGuild	= "hat die Gilde verlassen"
GLDG_TXT.deltaIncrease1	= "hat seinen Level von"
GLDG_TXT.deltaIncrease2	= "auf"
GLDG_TXT.deltaIncrease3	= "erhöht"
GLDG_TXT.deltaPnoteChanged	= "Die Spielernotiz wurde verändert für Charakter"
GLDG_TXT.deltaPnoteAdded	= "Eine Spielernotiz wurde erfasst für Charakter"
GLDG_TXT.deltaPnoteRemoved	= "Die Spielernotiz wurde entfernt für Charakter"
GLDG_TXT.deltaOnoteChanged	= "Die Offiziersnotiz wurde verändert für Charakter"
GLDG_TXT.deltaOnoteAdded	= "Eine Offiziersnotiz wurde erfasst für Charakter"
GLDG_TXT.deltaOnoteRemoved	= "Die Offiziersnotiz wurde entfernt für Charakter"
GLDG_TXT.deltaFrom		= "von"
GLDG_TXT.deltaTo		= "nach"
GLDG_TXT.deltaIs		= "Die neue Notiz ist"
GLDG_TXT.deltaWas		= "Die alte Notiz war"
GLDG_TXT.deltaRank		= "Charakter"
GLDG_TXT.deltaDemoted1		= "wurde von Rang"
GLDG_TXT.deltaRankTo		= "zu Rang"
GLDG_TXT.deltaDemoted2		= "degradiert"
GLDG_TXT.deltaPromoted1		= GLDG_TXT.deltaDemoted1
GLDG_TXT.deltaPromoted2		= "befördert"
GLDG_TXT.deltaOnoteFrom	= "Die Offiziersnotiz von"
GLDG_TXT.deltaOnoteInvalid	= "ist ungültig =>"
GLDG_TXT.deltaOnoteToManyMatches	= "zu viele Treffer für"
GLDG_TXT.deltaOnoteNotFound	= "nicht gefunden"

-- Player menus
GLDG_TXT.menu		= "GuildGreet"
GLDG_TXT.lookup		= "Nachschlagen"
GLDG_TXT.goodbye	= "Abschied"

-- Version check
GLDG_TXT.newer		= "Eine neuere Version des Addons ist verfügbar."
GLDG_TXT.newer1		= "Du hast Version "
GLDG_TXT.newer2		= "Spieler "
GLDG_TXT.newer3		= " hat Version "
GLDG_TXT.newer4		= "."
GLDG_TXT.bigBrother	= " verwendet Version "
GLDG_TXT.bigBrother2	= " hat von Version "
GLDG_TXT.bigBrother3	= " auf Version "
GLDG_TXT.bigBrother4	= " upgedated"
GLDG_TXT.bigBrother5	= "Liste bekannte GuildGreet Benutzer auf"
GLDG_TXT.bigBrother6	= "Keine anderen GuildGreet Benutzer bekannt"

-- Reloading of UI
GLDG_TXT.reloadQuestion	= "Du musst Dein Interface neu laden, damit diese Änderung aktiv wird. Soll dies jetzt gemacht werden?"
GLDG_TXT.reloadNow	= "Jetzt neu laden"
GLDG_TXT.later	= "Später neu laden"
GLDG_TXT.reload		= "Du musst Dein Interface neu laden durch tippen von /console reloadui"

-- Guild Member Alert
GLDG_TXT.alertQuestion	= "|cFFFFFF7FGuildenmitglieder Benachrichtigung|r ist zur Zeit inaktiv (Siehe Interface settings, Game, Social).\r\nDas bedeutet, dass GuildGreet nicht in der Lage ist, zuverlässig zu erkennen, wann Gildenmitglieder ein- oder ausloggen.\r\n\r\nDiese Frage wird nur einmal gestellt. Um diese Prüfung später manuell durchzuführen, tippe |cFFFFFF7F/gg alert|r.\r\n\r\nWillst Du die Benachrichtigung aktivieren? (Empfohlen)"
GLDG_TXT.alertOn	= "Aktiviere Benachrichtigung"
GLDG_TXT.alertLeave	= "Inaktiv lassen"
GLDG_TXT.alertIsOn	= "Gildenmitglieder-Benachrichtigung ist aktiv."
GLDG_TXT.alertTurnedOn	= "Gildenmitglieder-Benachrichtigung wurde aktiviert."
GLDG_TXT.alertUnchanged	= "Gildenmitglieder-Benachrichtigung wurde nicht aktiviert. |cFFFF0000GuildGreet wird das Ein- und Ausloggen von Gildenmitgliedern nicht zuverlässig überwachen können.|r"

-- conversion
GLDG_TXT.nodata1	= "Keine Daten für Charakter"
GLDG_TXT.nodata2	= "gefunden"
GLDG_TXT.convertGuild1	= "Konvertiere Gilde"
GLDG_TXT.convertGuild2	= ",welcher auf Realm"
GLDG_TXT.convertGuild3	= "gefunden wurde"
GLDG_TXT.convertChannel1 = "Konvertiere channel"
GLDG_TXT.convertChannel2 = GLDG_TXT.convertGuild2
GLDG_TXT.convertChannel3 = GLDG_TXT.convertGuild3
GLDG_TXT.convertFriends1 = "Konvertiere Freunde, welche für Realm"
GLDG_TXT.convertFriends2 = GLDG_TXT.convertGuild3
GLDG_TXT.convertVerify1	= "Prüfe doppelte Main-Twink Einträge"
GLDG_TXT.convertVerify2	= "Prüfe Main-Twink Beziehungen"
GLDG_TXT.convertVerify3	= "Abgeschlossen"
GLDG_TXT.convertVerify4	=	"Abgeschlossen. Tippe |cFFFFFF7F/gg fix|r um diese Konflikte automatisch zu beheben."
GLDG_TXT.convertConflict1  = "--> Konflikt:"
GLDG_TXT.convertConflict2  = "ist sowohl Main als auch Twink. Sein Main"
GLDG_TXT.convertConflict3  = "ist jedoch ebenfalls Main und Twink, dessen Main"
GLDG_TXT.convertConflict4  = "wurde nicht geprüft, diese Erfolgt für den Charakter separat."
GLDG_TXT.convertConflict5  = "sollte vermutlich Main sein."
GLDG_TXT.convertConflict6  = "ist jedoch nicht Main, sondern nur Twink, dessen Main"
GLDG_TXT.convertConflict7  = "ist weder Main noch Twink"
GLDG_TXT.convertConflict8  = "Twink"
GLDG_TXT.convertConflict9  = "hat Main"
GLDG_TXT.convertConflict10 = "welcher jedoch nicht als Main markiert ist."
GLDG_TXT.convertConflict11 = "Charakter"
GLDG_TXT.convertConflict12 = "ist sein eigener Main. Diese Referenz sollte vermutlich entfernt werden."
GLDG_TXT.convertConflict13 = "welcher jedoch nicht existiert."
GLDG_TXT.convertFix		= "Repariere Inkonsistenzen"
GLDG_TXT.convertFix1  = "wird der neue Main."
GLDG_TXT.convertFix2	= "Verschiebe Twink"
GLDG_TXT.convertFix3	= "von Main"
GLDG_TXT.convertFix4	= "zu Main"
GLDG_TXT.convertFix5	= "wird der neue Main, obwohl dieser auch Main unt Twink ist, dessen Main"
GLDG_TXT.convertFix6	= "ist weder Main noch Twink, wird aber Twink von"
GLDG_TXT.convertFix7  = "wird Main für"
GLDG_TXT.convertFix8  = "und alle seine Twinks"
GLDG_TXT.convertFix9	= "welcher jedoch nicht als Main markiert ist. Dies wird korrigiert."
GLDG_TXT.convertFix10	= "Korrekturen durchgeführt. Prüfe manuell, ob alle Main-Twink Gruppen den korrekten Main haben. Falls nicht, verwende die '|cFFFFFF7F"..GLDG_TXT.pbpmain.."|r' Funktion."
GLDG_TXT.convertFix11	= "Keine Korrekturen notwendig."
GLDG_TXT.convertFix12	= "ist sein eigener Main. Diese Referenz wurde entfernt."
GLDG_TXT.convertFix13	= "Es scheint eine zirkuläre Inkonsistenz zu geben, die auch nach 10 Iterationen nicht behoben werden konnte. Breche ab. Bitte meldet dies Urbin auf der Seite des Addons auf www.curse.com."
GLDG_TXT.convertFix14	= "welcher nicht existiert. Der Verweis wird entfernt."
GLDG_TXT.shouldFix		= "Inkonsistenzen entdeckt. Verwende |cFFFFFF7F/gg check|r um diese anzuzeigen oder |cFFFFFF7F/gg fix|r um sie zu beheben."

GLDG_TXT.unnew1		= "Setze das 'neu in Gilde' Flag für alle Charaktere zurück"
GLDG_TXT.unnew2		= "Entferne das 'neu in Gilde' Flag für"

-- Help Tooltips
GLDG_TXT.elements.name.GuildGreetListTitle	= "Grussliste"
GLDG_TXT.elements.tip.GuildGreetListTitle	= "Diese Liste zeigt alle Charaktere an, die gegrüsst werden sollten oder eine Gratulation zu gut haben.\r\nEin Linksklick auf einen Eintrag gratuliert bzw. grüsst den Charakter.\r\nEin Rechtsklick auf einen Eintrag entfernt den Charakter ohne Gruss.\r\nEin Rechtsklick auf den Titel entfernt alle Einträge ohne Gruss."
GLDG_TXT.elements.name.GuildGreetListClose	= "Grussliste leeren"
GLDG_TXT.elements.tip.GuildGreetListClose	= "Klicke auf diesen Knopf, um die Grussliste zu leeren, ohne die Spieler auf der Liste zu grüssen oder ihnen zu gratulieren."

GLDG_TXT.elements.name.Tab1	= GLDG_TXT.TabSettings
GLDG_TXT.elements.tip.Tab1	= "Konfiguriert die verschiedenen Features des Addons"
GLDG_TXT.elements.name.Tab2	= GLDG_TXT.TabGreetings
GLDG_TXT.elements.tip.Tab2	= "Definiert Grusstexte und Grusstext-Sets"
GLDG_TXT.elements.name.Tab3	= GLDG_TXT.TabPlayers
GLDG_TXT.elements.tip.Tab3	= "Verwaltet Main und Twink Charaktere Deiner Gilde"
GLDG_TXT.elements.name.Tab4	= GLDG_TXT.TabCleanup
GLDG_TXT.elements.tip.Tab4	= "Bereinigt Charakter-Altlasten in der Datenbank"
GLDG_TXT.elements.name.Tab5	= GLDG_TXT.TabColour
GLDG_TXT.elements.tip.Tab5	= "Farbkonfiguration"

GLDG_TXT.elements.name.SettingsTab1	= GLDG_TXT.SubTabGeneral
GLDG_TXT.elements.tip.SettingsTab1	= "Allgemeine Konfiguration: Wen, wann, wie grüssen"
GLDG_TXT.elements.name.SettingsTab2	= GLDG_TXT.SubTabChat
GLDG_TXT.elements.tip.SettingsTab2	= "Konfiguration der Meldungen, die im Chat angezeigt werden"
GLDG_TXT.elements.name.SettingsTab3	= GLDG_TXT.SubTabGreeting
GLDG_TXT.elements.tip.SettingsTab3	= "Detaillierte Gruss-Einstellungen"
GLDG_TXT.elements.name.SettingsTab4	= GLDG_TXT.SubTabDebug
GLDG_TXT.elements.tip.SettingsTab4	= "Konfiguriert das GuildGreetDump Addon, um zu definieren, wie Debug Information gespeichert werden soll."
GLDG_TXT.elements.name.SettingsTab5	= GLDG_TXT.SubTabOther
GLDG_TXT.elements.tip.SettingsTab5	= "Reserviert für zukünftige Erweiterungen"

GLDG_TXT.elements.name.SettingsGeneralRelogSlider	= "Reloge Zeit"
GLDG_TXT.elements.tip.SettingsGeneralRelogSlider	= "Definiert, ob Charaktere, die sich wieder einloggen, immer in der Grussliste angezeigt werden oder nur wenn sie mindestens für die eingestellte Zeit offline waren"
GLDG_TXT.elements.name.SettingsGeneralMinLevelUpSlider	= "Level-up Limite"
GLDG_TXT.elements.tip.SettingsGeneralMinLevelUpSlider	= "Definiert, welchen Level ein Charakter mindestens erreicht haben muss, damit ihm gratuliert wird, wenn er einen neuen Level erreicht. Wird diese Einstellung auf 0 gesetzt, so wird für jeden neuen Level gratuliert."
GLDG_TXT.elements.name.SettingsGeneralUpdateTimeSlider	= "Gildenliste prüfen"
GLDG_TXT.elements.tip.SettingsGeneralUpdateTimeSlider	= "Definiert, ob die Gildenliste nur bei Ereignissen geprüft wird, oder in einem fixen Interval.\r\nIm Interval zu prüfen kann zu einer höheren Kommunikationslast führen."
GLDG_TXT.elements.name.SettingsGeneralAutoAssignBox	= "Automatische Zuweisung"
GLDG_TXT.elements.tip.SettingsGeneralAutoAssignBox	= "Falls diese Box aktiviert ist, werden die Gilden- und Offiziersnotizen ausgewertet. Enthalten diese die Schlüsselwörter 'Main' oder 'alt-<main name>' so wird der entsprechende Charakter als Main oder Twink des Mains eingeteilt"
GLDG_TXT.elements.name.SettingsGeneralAutoAssignEgpBox	= "Automatische Zuweisung (EGP)"
GLDG_TXT.elements.tip.SettingsGeneralAutoAssignEgpBox	= "Falls diese Box aktiviert ist, wird die Offiziersnotizen ausgewertet. Enthält diese Informationen, welche durch das EGP Addon eingetragen wurden (Zahl für Mains, Name des Twinks), so wird der entsprechende Charakter als Main oder Twink des Mains eingeteilt"
GLDG_TXT.elements.name.SettingsGeneralAutoAssignAliasBox	= "Automatische Zuweisung Alias"
GLDG_TXT.elements.tip.SettingsGeneralAutoAssignAliasBox	= "Falls diese Box aktiviert ist, werden die Gilden- und Offiziersnotizen ausgewertet. Wird ein Eintrag der Form '@Aliasname ' gefunden, wird dem entsprechenden Charakter der Aliasname zugeordnet.\r\nBeispiel:\r\n<Main @Uwe> => Alias = Uwe\r\n<Main @Uwe anderer Text> => Alias = Uwe"
GLDG_TXT.elements.name.SettingsGeneralUseGuildDefaultBox	= "Lese die Gildeneinstellungen"
GLDG_TXT.elements.tip.SettingsGeneralUseGuildDefaultBox	= "Liest die Gildeneinstellungen aus der Gildeninfo"
GLDG_TXT.elements.name.SettingsGeneralGreetAsMainBox	= "Als Main grüssen *"
GLDG_TXT.elements.tip.SettingsGeneralGreetAsMainBox	= "Falls diese Box aktiviert ist, werden Twinks mit dem Namen des Mains gegrüsst"
GLDG_TXT.elements.name.SettingsGeneralIncludeOwnBox	= "Eigene anzeigen"
GLDG_TXT.elements.tip.SettingsGeneralIncludeOwnBox	= "Falls diese Box aktiviert ist, werden eigene Charaktere auch in der Konfigurationsliste angezeigt"
GLDG_TXT.elements.name.SettingsGeneralRandomizeBox	= "Zufälllig grüssen"
GLDG_TXT.elements.tip.SettingsGeneralRandomizeBox	= "Falls diese Box aktiviert ist, werden Mains zufällig mit ihrem Namen oder Alias und Twinks zufällig mit dem Namen oder Alias das Mains oder Alts gegrüsst"
GLDG_TXT.elements.name.SettingsGeneralUseFriendsBox	= "Freunde verwalten"
GLDG_TXT.elements.tip.SettingsGeneralUseFriendsBox	= "Falls diese Box aktiviert ist, überwacht GuildGreet Freunde, die sich ein- und ausloggen."
GLDG_TXT.elements.name.SettingsGeneralWhisperBox	= "Grüsse flüstern"
GLDG_TXT.elements.tip.SettingsGeneralWhisperBox		= "Falls diese Box aktiviert ist, werden Grüsse geflüstert, statt in den Gildenchat oder dan ausgewählen Channel geschrieben zu werden.\r\n\r\nDies schliesst Levelup Meldungen ein."
GLDG_TXT.elements.name.SettingsGeneralWhisperLevelupBox	= "Levelup flüstern"
GLDG_TXT.elements.tip.SettingsGeneralWhisperLevelupBox	= "Falls diese Box aktiviert ist, werden Levelup Nachrichten geflüstert, statt in den Gildenchat oder dan ausgewählen Channel geschrieben zu werden.\r\n\r\nFalls die Einstellung alle Nachrichten zu flüstern aktiviert ist, hat diese Einstellung keinen Effekt."
GLDG_TXT.elements.name.SettingsGeneralChannelNameDropboxButton	= "Channel verwalten"
GLDG_TXT.elements.tip.SettingsGeneralChannelNameDropboxButton	= "Falls Du einen anderne Channel als <kein Channel> auswählst, so überwacht GuildGreet Charaktere, die dem Channel beitreten und ihn verlassen."

GLDG_TXT.elements.name.SettingsGeneralListdirectBox	= "Listenrichtung"
GLDG_TXT.elements.tip.SettingsGeneralListdirectBox	= "Falls diese Box aktiviert ist, wächst die Grussliste nach oben statt unten"
GLDG_TXT.elements.name.SettingsGeneralListheaderBox	= "Titel immer zeigen"
GLDG_TXT.elements.tip.SettingsGeneralListheaderBox	= "Falls diese Box aktiviert ist, wird die Titelzeile der Grussliste immer angezeigt, auch wenn keine Charaktere zu grüssen sind."
GLDG_TXT.elements.name.SettingsGeneralListsizeSlider	= "Grösse der Grusslisten"
GLDG_TXT.elements.tip.SettingsGeneralListsizeSlider	= "Hier wird eingestellt, wie viele Einträge die Grussliste anzeigt. Falls mehr Charaktere zu grüssen sind, als die Liste Platz bietet, werden die ältesten Einträge angezeigt."

GLDG_TXT.elements.name.SettingsChatChatFrameSlider	= "Chat Frame"
GLDG_TXT.elements.tip.SettingsChatChatFrameSlider	= "Definiert, welches Chat Frame verwendet wird, um die Chat-Nachrichten von GuildGreet anzuzeigen. \r\n\r\n|cFFFF0000Sollten nicht alle auswählbar sein, benutze den Befehl \r\n|r/reload|cFFFF0000.|r"
GLDG_TXT.elements.name.SettingsChatListNamesBox		= "Liste beim Einloggen"
GLDG_TXT.elements.tip.SettingsChatListNamesBox		= "Falls diese Box aktiviert ist, wird eine Liste des Mains und aller Twinks des einloggenden Charakters in den Chat geschrieben"
GLDG_TXT.elements.name.SettingsChatListNamesOffBox	= "Liste beim Ausloggen"
GLDG_TXT.elements.tip.SettingsChatListNamesOffBox	= "Falls diese Box aktiviert ist, wird eine Liste des Mains und aller Twinks des ausloggenden Charakters in den Chat geschrieben"
GLDG_TXT.elements.name.SettingsChatListLevelUpBox	= "Liste beim Level-up (online)"
GLDG_TXT.elements.tip.SettingsChatListLevelUpBox	= "Falls diese Box aktiviert ist, wird eine Nachricht in den Chat geschrieben, wenn ein Charakter einen neuen Level erreicht"
GLDG_TXT.elements.name.SettingsChatListLevelUpOffBox	= "Liste beim Level-up (offline)"
GLDG_TXT.elements.tip.SettingsChatListLevelUpOffBox	= "Falls diese Box aktiviert ist, wird für jeden Spieler, der offline ist und seinen Level erhöht hat, während dem Du offline warst, eine Nachricht in den Chat geschrieben"
GLDG_TXT.elements.name.SettingsChatListQuitBox		= "Liste beim Verlassen der Gilde"
GLDG_TXT.elements.tip.SettingsChatListQuitBox		= "Falls diese Box aktiviert ist, wird eine Nachricht in den Chat geschrieben, wenn ein Charakter die Gilde verlässt"
GLDG_TXT.elements.name.SettingsChatExtendChatBox	= "Main-Namen im Chat"
GLDG_TXT.elements.tip.SettingsChatExtendChatBox		= "Falls diese Box aktiviert ist, wird der Name des Mains vor die Nachricht jedes Twinks gestellt."
GLDG_TXT.elements.name.SettingsChatExtendIgnoredBox	= "Main-Namen im Chat für ignorierte Charakter"
GLDG_TXT.elements.tip.SettingsChatExtendIgnoredBox		= "Falls diese Box aktiviert ist, wird der Name des Mains vor die Nachricht jedes Twinks gestellt, selbst wenn dieser Twink ignoriert wird."
GLDG_TXT.elements.name.SettingsChatExtendMainBox	= "Main-Namen für Main wiederholen"
GLDG_TXT.elements.tip.SettingsChatExtendMainBox		= "Falls diese Box aktiviert ist, wird der Name des Mains auch vor die Nachrichte des Mains, nicht nur der Twinks gestellt."
GLDG_TXT.elements.name.SettingsChatExtendAliasBox	= "Main-Alias im Chat"
GLDG_TXT.elements.tip.SettingsChatExtendAliasBox	= "Falls diese Box aktiviert ist, wird das Alias des Mains anstelle des Names vor die Nachricht jedes Twinks gestellt."

GLDG_TXT.elements.name.SettingsChatListAchievmentsBox	= "Erfolge auflisten"
GLDG_TXT.elements.tip.SettingsChatListAchievmentsBox	= "Falls diese Box aktiviert ist, wird eine Nachricht im Chat angezeigt, wenn ein Gildenmitglied einen Erfolg erreicht und für dieses Mitglied ein Main oder Alias definiert ist."
GLDG_TXT.elements.name.SettingsChatAddPostfixBox	= "Quellenzusatz angeben"
GLDG_TXT.elements.tip.SettingsChatAddPostfixBox		= "Falls diese Box aktiviert ist, wird allen Charakternamen, die im Chat angezeigt werden die Quelle, aus der Du sie kennst in geschweiften Klammern angefügt.\r\nGilde: kein Zusatz\r\nChannel: {c}\r\nFreundesliste: {f}\r\n:Keines der obigen: {?}"
GLDG_TXT.elements.name.SettingsChatShowWhoSpamBox	= "Zeige /who Anfragen und Antworten"
GLDG_TXT.elements.tip.SettingsChatShowWhoSpamBox	= "Falls diese Box aktiviert ist, wird eine Meldung im Chat angezeigt, wenn eine /who Anfrage entweder manuell mit dem Knopf im Charakter Tab oder automatisch (falls die Option aktiviert ist) gesendet wird und jedesmal wenn eine /who Antwort empfangen wird (entweder durch GuildGreet oder irgend eine Methode ausgelöst)."

GLDG_TXT.elements.name.SettingsGreetingGreetGuildBox	= "Guild grüssen"
GLDG_TXT.elements.tip.SettingsGreetingGreetGuildBox	= "Falls diese Box aktiviert ist, wird beim Drücken der (zuweisbaren) 'Gruss', 'Abschied' und 'Bis später' Tasten eine entsprechende Nachricht an die Gilde geschickt. Die Tasten können in der spielweiten Tastenzuweisung konfiguriert werden."
GLDG_TXT.elements.name.SettingsGreetingGreetChannelBox	= "Channel grüssen"
GLDG_TXT.elements.tip.SettingsGreetingGreetChannelBox	= "Falls diese Box aktiviert ist, wird beim Drücken der (zuweisbaren) 'Gruss', 'Abschied' und 'Bis später' Tasten eine entsprechende Nachricht an den Channel geschickt. Die Tasten können in der spielweiten Tastenzuweisung konfiguriert werden."
GLDG_TXT.elements.name.SettingsGreetingAutoGreetBox	= "Automatisch grüssem"
GLDG_TXT.elements.tip.SettingsGreetingAutoGreetBox	= "Falls diese Box aktiviert ist, wird ein Gruss an die Gilde und/oder den Channel gesendet (je nach obiger Konfiguration), wenn Du einlogst.\r\n|cFFFF0000Vorsichtig benutzen:\r\nDieses Feature grüsst jedesmal, wenn ihr Euch mit einem Charakter einloggt oder das Interface mit |r/reload|cFFFF0000 neu lädt, ihr könnt damit also leicht Eure Freunde nerven."

GLDG_TXT.elements.name.SettingsGreetingSupressAll	= "Alle Grüsse unterdrücken"
GLDG_TXT.elements.tip.SettingsGreetingSupressAll	= "Drücke diesen Knopf um alle vier untenstehenden Checkboxen zu aktivieren. Dies unterdrückt sämtliche Einträge in die Grussliste, die Ausgabe in den Chat wird davon nicht beeinflusst.\r\nDieser Knopf ist praktisch, wenn Du in Instanzen nicht abgelenkt werden willst."
GLDG_TXT.elements.name.SettingsGreetingSupressNone	= "Alle Grüsse zulassen"
GLDG_TXT.elements.tip.SettingsGreetingSupressNone	= "Drücke diesen Knopf um alle vier untenstehenden Checkboxen zu deaktivieren. Damit werden sämtliche Anlässe, welche zu einem Eintrag in der Grussliste führen, wieder freigeschaltet."
GLDG_TXT.elements.name.SettingsGreetingSupressGreetBox	= "Grüsse unterdrücken"
GLDG_TXT.elements.tip.SettingsGreetingSupressGreetBox	= "Falls diese Box aktiviert ist, werden Charaktere, die sich einloggen nicht in die Grussliste aufgenommen. Damit kann man vorübergehend das Grüssen unterdrücken, ohne alle Gruss-Phrasen löschen zu müsen. Falls keine Gruss-Phrasen definiert sind, werden Charaktere auch nicht in die Grussliste aufgenommen, falls diese Box inaktiv ist."
GLDG_TXT.elements.name.SettingsGreetingSupressJoinBox	= "Willkommen unterdrücken"
GLDG_TXT.elements.tip.SettingsGreetingSupressJoinBox	= "Falls diese Box aktiviert ist, werden Charaktere, die der Gilde beitreten nicht in die Grussliste aufgenommen. Damit kann man vorübergehend das Grüssen unterdrücken, ohne alle Gruss-Phrasen löschen zu müsen. Falls keine Gruss-Phrasen definiert sind, werden Charaktere auch nicht in die Grussliste aufgenommen, falls diese Box inaktiv ist."
GLDG_TXT.elements.name.SettingsGreetingSupressLevelBox	= "Level-up unterdrücken"
GLDG_TXT.elements.tip.SettingsGreetingSupressLevelBox	= "Falls diese Box aktiviert ist, werden Charaktere, einen neuen Level erreichen nicht in die Grussliste aufgenommen. Damit kann man vorübergehend Gratulationen unterdrücken, ohne alle Gratulations-Phrasen löschen zu müsen. Falls keine Gratulations-Phrasen definiert sind, werden Charaktere auch nicht in die Grussliste aufgenommen, falls diese Box inaktiv ist."
GLDG_TXT.elements.name.SettingsGreetingSupressRankBox	= "Beförderungen unterdrücken"
GLDG_TXT.elements.tip.SettingsGreetingSupressRankBox	= "Falls diese Box aktiviert ist, werden Charaktere, die befördert werden nicht in die Grussliste aufgenommen. Damit kann man vorübergehend Gratulationen unterdrücken, ohne alle Gratulations-Phrasen löschen zu müsen. Falls keine Gratulations-Phrasen definiert sind, werden Charaktere auch nicht in die Grussliste aufgenommen, falls diese Box inaktiv ist."
GLDG_TXT.elements.name.SettingsGreetingSupressAchievmentBox	= "Erfolge unterdrücken"
GLDG_TXT.elements.tip.SettingsGreetingSupressAchievmentBox	=" Falls diese Box aktiviert ist, werden Charaktere, die einen Erfolg erreicht haben nicht in die Grussliste aufgenommen. Damit kann man vorübergehend Gratulationen unterdrücken, ohne alle Gratulations-Phrasen löschen zu müsen. Falls keine Gratulations-Phrasen definiert sind, werden Charaktere auch nicht in die Grussliste aufgenommen, falls diese Box inaktiv ist."
GLDG_TXT.elements.name.SettingsGreetingNoGratsOnLoginBox	= "Keine Gratulation beim Login"
GLDG_TXT.elements.tip.SettingsGreetingNoGratsOnLoginBox		= "Falls diese Box aktiviert ist, wird Charakteren, die befördert wurden oder einen neuen Level erreicht haben nicht gratuliert, wenn sie einloggen. Ist diese Option aktiviert, werden Gratulationen nur Spielern ausgesprochen, die bereits online sind."

GLDG_TXT.elements.name.SettingsGreetingGuildAliasEditbox	= "Gilden-Alias"
GLDG_TXT.elements.tip.SettingsGreetingGuildAliasEditbox		= "Gib in dieser Box ein Gilden-Alias ein, welches in Gilden-Grüssen verwendet wird."
GLDG_TXT.elements.name.SettingsGreetingGuildAliasSet		= "Gilden-Alias setzen"
GLDG_TXT.elements.tip.SettingsGreetingGuildAliasSet		= "Klicke auf diesen Button, um das Gilden-Alias, welches editiert wird zu setzen. Dieses wird in Gilden-Grüssen verwendet werden."
GLDG_TXT.elements.name.SettingsGreetingGuildAliasClear		= "Gilden-Alias löschen"
GLDG_TXT.elements.tip.SettingsGreetingGuildAliasClear		= "Drücke diesen Button, um das Gilden-Alias zu löschen. Der volle Gildenname wird in Gilden-Grüssen verwendet werden."

GLDG_TXT.elements.name.SettingsDebugEnableDumpBox	= "Dumping aktivieren"
GLDG_TXT.elements.tip.SettingsDebugEnableDumpBox	= "Falls diese Box aktiviert is, werden Debug Informationen in die SavedVariable Datei des GuildGreetDump Addons geschrieben. Diese Information kann auf Curse Gaming geladen werden, um die Fehlersuche zu unterstützen.\r\n|cFFFF0000Achtung: Dies erzeugt viele Daten, deshalb mit Vorsicht zu verwenden.\r\n\r\nAktiviert diese Einstellung nur, wenn Euch Urbin auf Curse Gaming gesagt hat, ihr sollt es tun!"
GLDG_TXT.elements.name.SettingsDebugVerboseDumpBox	= "'Gesprächiges' Dumping"
GLDG_TXT.elements.tip.SettingsDebugVerboseDumpBox	= "Falls diese Box aktiviert ist, wird jede Nachricht, die in ein Dump Set geschrieben wird, auch im Chat angezeigt."
GLDG_TXT.elements.name.SettingsDebugClearButton		= "Aktuelles Set löschen"
GLDG_TXT.elements.tip.SettingsDebugClearButton		= "Auf diesen Button klicken, um alle Einträge des aktuellen Sets zu löschen"
GLDG_TXT.elements.name.SettingsDebugClearAllButton	= "Alle Sets löschen"
GLDG_TXT.elements.tip.SettingsDebugClearAllButton	= "Auf diesen Button klicken, um alle Sets zu löschen"
GLDG_TXT.elements.name.SettingsDebugNewButton		= "Neues Set verwenden"
GLDG_TXT.elements.tip.SettingsDebugNewButton		= "Auf diesen Button klicken, ein neues Set anzulegen, in das Debug Information geschrieben werden"

GLDG_TXT.elements.name.SettingsOtherUseLocalTimeBox	= "Lokalzeit verwenden"
GLDG_TXT.elements.tip.SettingsOtherUseLocalTimeBox	= "Falls diese Box aktiviert is, wird die Lokalzeit statt die Serverzeit verwendet. Das heisst, dass sowohl die Zeitangaben in der Grussliste Lokalzeit verwenden, als auch der Entscheid ob 'Auf Wiedersehen' oder 'Gute Nacht' gesagt wird auf Lokalzeit basiert."
GLDG_TXT.elements.name.SettingsOtherShowNewerVersionsBox	= "Anzeigen, wenn neuere Version verfügbar ist"
GLDG_TXT.elements.tip.SettingsOtherShowNewerVersionsBox	= "GuildGreet sendet seine Version in den Gilden, Gruppen und Raid chat. Falls diese Box aktiviert ist und ein anderer Spieler eine neuere Version hat, wird dies im Chat angezeigt."
GLDG_TXT.elements.name.SettingsOtherEnableContextMenuBox	= "Kontextmenu für Spieler aktivieren"
GLDG_TXT.elements.tip.SettingsOtherEnableContextMenuBox	= "Auf diesen Button klicken, um das Kontextmenu um zwei Einträge zu erweitern, welches erscheint wenn auf ein Spielrportrait oder einen Spielernamen im Chat rechtsgeklickt wird. Die Einträge erlauben, Informationen, welche GuildGreet über den Spieler hat anzuzeigen oder den Spieler zu verabschieden.\r\n|cFFFF0000Achtung: Offenbar kann dies zu Taint Problemen mit dem Raid Interface führen. Falls Dir das passiert, solltest Du diese Einstellung deaktivieren.|r\r\n\r\nIch werde versuchen, dieses Feature mit sicheren Methoden zu lösen, sobald ich dazu Zeit finde.\r\n\r\n|cFFFF0000ACHTUNG: Damit die Änderung dieser Einstellung in Kraft tritt, musst Du Dein Interface neu laden. Du wirst gefragt, ob dies automatisch gemacht werden soll.|r"
GLDG_TXT.elements.name.SettingsOtherAutoWhoBox		= "Automatische /who Anfragen"
GLDG_TXT.elements.tip.SettingsOtherAutoWhoBox		= "Falls diese Box aktiviert ist, wird automatisch eine /who Anfrage ausgelöst, wenn ein Channel-Mitglied sich einloggt, dessen Gildenname, Klasse oder Level unbekannt ist."
GLDG_TXT.elements.name.SettingsOtherDeltaPopupBox	= "Zeige Pop-up mit Änderungsmeldungen"
GLDG_TXT.elements.tip.SettingsOtherDeltaPopupBox	= "Falls diese Box aktiviert ist, wird beim einloggen ein Pop-up Fenster angezeigt, dass alle Änderungen im Status von Gildenmitgliedern, Freunden und Channel-Mitgliedern zusammenfasst, die passiert sind, während dem Du offline warst."
GLDG_TXT.elements.name.SettingsOtherExtendPlayerMenuBox	= "Kontextmenu für Spieler aktivieren"
GLDG_TXT.elements.tip.SettingsOtherExtendPlayerMenuBox	= "Auf diesen Button klicken, um das Kontextmenu um zwei Einträge zu erweitern, welches erscheint wenn auf ein Spielrportrait oder einen Spielernamen im Chat rechtsgeklickt wird. Die Einträge erlauben, Informationen, welche GuildGreet über den Spieler hat anzuzeigen oder den Spieler zu verabschieden.\r\n|cFFFF0000Achtung: Offenbar kann dies zu Taint Problemen mit dem Raid Interface führen. Falls Dir das passiert, solltest Du diese Einstellung deaktivieren.|r\r\n\r\nIch werde versuchen, dieses Feature mit sicheren Methoden zu lösen, sobald ich dazu Zeit finde.\r\n\r\n|cFFFF0000ACHTUNG: Damit die Änderung dieser Einstellung in Kraft tritt, musst Du Dein Interface neu laden. Du wirst gefragt, ob dies automatisch gemacht werden soll.|r"

GLDG_TXT.elements.name.ColourDefault		= "Standardfarben"
GLDG_TXT.elements.name.ColourHeader		= "Farbe und Transparenz ändern"
GLDG_TXT.elements.name.ColourHelp		= "Farbe ändern"
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

GLDG_TXT.elements.tip.ColourDefault		= "Setzt alle Farbwerte auf ihre Standardwerte zurück."
GLDG_TXT.elements.tip.ColourHeader		= "Definiert die Hintergrundfarbe der Titelzeile der Grussliste"
GLDG_TXT.elements.tip.ColourHelp		= "Definiert die Farbe, mit welcher Nachrichten in den Chat geschrieben werden"

GLDG_TXT.elements.tip.ColourGuildAlias		= "Definiert in welcher Farbe Alias-Namen in den Chat geschrieben werden"
GLDG_TXT.elements.tip.ColourGuildGoOffline	= "Definiert in welcher Farbe Charaktere, die ausloggen, in den Chat geschrieben werden"
GLDG_TXT.elements.tip.ColourGuildIsOffline	= "Definiert in welcher Farbe Charaktere, welche offline sind, in den Chat geschrieben werden"
GLDG_TXT.elements.tip.ColourGuildOnline		= "Definiert in welcher Farbe Charaktere, die einloggen, in den Chat geschrieben werden"

GLDG_TXT.elements.tip.ColourGuildNew		= "Definiert die Farbe der Grusslisteneinträge für Charaktere, die neu der Gilde beigetreten sind"
GLDG_TXT.elements.tip.ColourGuildList		= "Definiert die Farbe der Grusslisteneinträge für Charaktere, die sich zum ersten mal einloggen"
GLDG_TXT.elements.tip.ColourGuildRelog		= "Definiert die Farbe der Grusslisteneinträge für Charaktere, die sich erneut einloggen"
GLDG_TXT.elements.tip.ColourGuildLevel		= "Definiert die Farbe der Grusslisteneinträge für Charaktere, die einen neuen Level erreicht haben"
GLDG_TXT.elements.tip.ColourGuildRank		= "Definiert die Farbe der Grusslisteneinträge für Charaktere, die befördert wurden"
GLDG_TXT.elements.tip.ColourGuildAchievment	= "Definiert die Farbe der Grusslisteneinträge für Charaktere, die einen Erfolg geschafft haben"

GLDG_TXT.elements.tip.ColourChannelAlias	= GLDG_TXT.elements.tip.ColourGuildAlias
GLDG_TXT.elements.tip.ColourChannelGoOffline	= GLDG_TXT.elements.tip.ColourGuildGoOffline
GLDG_TXT.elements.tip.ColourChannelIsOffline	= GLDG_TXT.elements.tip.ColourGuildIsOffline
GLDG_TXT.elements.tip.ColourChannelOnline	= GLDG_TXT.elements.tip.ColourGuildLevel
GLDG_TXT.elements.tip.ColourChannelNew		= "Definiert die Farbe der Grusslisteneinträge für Charaktere, die zum ersten mal den Channel betreten haben"
GLDG_TXT.elements.tip.ColourChannelList		= GLDG_TXT.elements.tip.ColourGuildList
GLDG_TXT.elements.tip.ColourChannelRelog	= GLDG_TXT.elements.tip.ColourGuildRelog
GLDG_TXT.elements.tip.ColourChannelLevel	= GLDG_TXT.elements.tip.ColourGuildNew
GLDG_TXT.elements.tip.ColourChannelRank		= GLDG_TXT.elements.tip.ColourGuildRank
GLDG_TXT.elements.tip.ColourChannelAchievment	= GLDG_TXT.elements.tip.ColourGuildAchievment

GLDG_TXT.elements.tip.ColourFriendsAlias	= GLDG_TXT.elements.tip.ColourGuildAlias
GLDG_TXT.elements.tip.ColourFriendsGoOffline	= GLDG_TXT.elements.tip.ColourGuildGoOffline
GLDG_TXT.elements.tip.ColourFriendsIsOffline	= GLDG_TXT.elements.tip.ColourGuildIsOffline
GLDG_TXT.elements.tip.ColourFriendsOnline	= GLDG_TXT.elements.tip.ColourGuildOnline
GLDG_TXT.elements.tip.ColourFriendsNew		= "Definiert die Farbe der Grusslisteneinträge für Charaktere, die neu der Freundesliste zugefügt wurden"
GLDG_TXT.elements.tip.ColourFriendsList		= GLDG_TXT.elements.tip.ColourGuildList
GLDG_TXT.elements.tip.ColourFriendsRelog	= GLDG_TXT.elements.tip.ColourGuildRelog
GLDG_TXT.elements.tip.ColourFriendsLevel	= GLDG_TXT.elements.tip.ColourGuildLevel
GLDG_TXT.elements.tip.ColourFriendsRank		= GLDG_TXT.elements.tip.ColourGuildRank
GLDG_TXT.elements.tip.ColourFriendsAchievment	= GLDG_TXT.elements.tip.ColourGuildAchievment

GLDG_TXT.elements.name.Red			= GLDG_TXT.red
GLDG_TXT.elements.tip.Red			= "Der Rot-Wert der RGB Farbdefinition.\r\nBereich: 0..255"
GLDG_TXT.elements.name.Green			= GLDG_TXT.green
GLDG_TXT.elements.tip.Green			= "Der Grün-Wert der RGB Farbdefinition.\r\nBereich: 0..255"
GLDG_TXT.elements.name.Blue			= GLDG_TXT.blue
GLDG_TXT.elements.tip.Blue			= "Der Blau-Wert der RGB Farbdefinition.\r\nBereich: 0..255"
GLDG_TXT.elements.name.Opacity			= "Opacity"
GLDG_TXT.elements.tip.Opacity			= "The opacity value from transparent (100%=0) to opaque (0%=255).\r\nRange: 0..100"

GLDG_TXT.elements.name.PlayersAlt2Box	= "Nach Main gruppieren"
GLDG_TXT.elements.tip.PlayersAlt2Box	= "Falls diese Box aktiv ist, werden die Twinks direkt nach ihrem Main gruppiert."
GLDG_TXT.elements.name.PlayersAltBox	= "Twinks immer zeigen"
GLDG_TXT.elements.tip.PlayersAltBox	= "Falls diese Box aktiv ist, werden Twinks in der Liste immer angzeigt.\r\n\r\nFalls die Box inaktiv ist, werden Twinks nur für den ausgewählten Main angezeigt."
GLDG_TXT.elements.name.PlayersIgnoreBox	= "Ignorierte anzeigen"
GLDG_TXT.elements.tip.PlayersIgnoreBox	= "Falls diese Box aktiv ist, werden ignorierte Charaktere in der Liste auch angezeigt. Achtung, dies hat nichts mit der /ignore Liste zu tun, es geht lediglich um Charaktere welche Du mit der Taste 'Ignorieren' von GuildGreet nicht verwalten lässt."
GLDG_TXT.elements.name.PlayersUnassignedBox	= "Nicht zugewiesene Charaktere"
GLDG_TXT.elements.tip.PlayersUnassignedBox	= "Falls diese Box aktiv ist, werden nur Charaktere angezeigt, die weder Main noch Twink sind"
GLDG_TXT.elements.name.PlayersGuildBox		= "Nur Gilde"
GLDG_TXT.elements.tip.PlayersGuildBox		= "Zeige in der Liste nur Charaktere an, die zu der Gilde des momentan eingeloggten Charakters gehören."
GLDG_TXT.elements.name.PlayersOnlineBox		= "Nur Online"
GLDG_TXT.elements.tip.PlayersOnlineBox		= "Zeige in der Liste nur Charaktere an, die zur Zeit online sind.\r\nFalls diese Einstellung aktiv ist, wird die 'Twink mit Main auflisten' Funktion nicht berücksichtigt."
GLDG_TXT.elements.name.PlayersMyFriendsBox	= "Nur meine Freunde"
GLDG_TXT.elements.tip.PlayersMyFriendsBox	= "Zeige in der Liste nur Charaktere an, die auf der Freundesliste des aktuell eingeloggten Charakters sind."
GLDG_TXT.elements.name.PlayersWithFriendsBox	= "Nur mit Freunden"
GLDG_TXT.elements.tip.PlayersWithFriendsBox	= "Zeige in der Liste nur Charaktere an, die auf der Freundesliste eines Deiner Charaktere sind."
GLDG_TXT.elements.name.PlayersCurrentChannelBox	= "Nur aktueller Channel"
GLDG_TXT.elements.tip.PlayersCurrentChannelBox	= "Zeige in der Liste nur Charaktere an, die dem Channel angehören, den Du aktuell verfolgst."
GLDG_TXT.elements.name.PlayersWithChannelBox	= "Nur mit Channel"
GLDG_TXT.elements.tip.PlayersWithChannelBox	= "Zeige in der Liste nur Charaktere an, die einem Channel angehören, nicht zwingend jenem, den Du aktuell verfolgst."
GLDG_TXT.elements.name.PlayersGuildSortBox	= "Nach Gilde sortieren"
GLDG_TXT.elements.tip.PlayersGuildSortBox	= "Falls diese Box aktiv ist, werden Charaktere zuerst nach dem Gildennamen und erst danach nach Charakternamen sortiert.\r\nFalls diese Einstellung aktiv ist, wird die 'Twink mit Main auflisten' Funktion nicht berücksichtigt."
GLDG_TXT.elements.name.PlayersGuildFilterDropboxButton	= "Gilden-Filter"
GLDG_TXT.elements.tip.PlayersGuildFilterDropboxButton	= "Wähle aus der Liste eine Gilde, um nur Charaktere, die Mitglieder der gewählten Gilde sind, anzuzeigen."


GLDG_TXT.elements.name.PlayersActionButtonsAlias		= "Alias"
GLDG_TXT.elements.tip.PlayersActionButtonsAlias		= "Mit diesem Knopf kann ein Alias-Namen für den ausgewählten Charakter definiert, angepasst oder gelöscht werden"
GLDG_TXT.elements.name.PlayersActionButtonsAlt		= "Twink/Alt"
GLDG_TXT.elements.tip.PlayersActionButtonsAlt		= "Mit diesem Knopf kann der ausgewählt Charakter als Alt/Twink einem Main Charakter zugeordnet werden bzw. die Zuordnung wieder aufgehoben werden"
GLDG_TXT.elements.name.PlayersActionButtonsIgnore		= "Ignorieren"
GLDG_TXT.elements.tip.PlayersActionButtonsIgnore		= "Mit diesem Knopf kann ein Charakter ignoriert werden. GuildGreet wird für diesen Charakter dann nicht mehr überwachen, wann er ein- und ausloggt."
GLDG_TXT.elements.name.PlayersActionButtonsMain		= "Main"
GLDG_TXT.elements.tip.PlayersActionButtonsMain		= "Mit diesem Knopf kann der ausgewählt Charakter als Main definiert werden, bzw. diese Definition wieder aufgehoben werden"
GLDG_TXT.elements.name.PlayersActionButtonsWho		= "Who Abfrage"
GLDG_TXT.elements.tip.PlayersActionButtonsWho		= "Startet eine /who Abfrage für den aktuell ausgewählten Charakter.\r\n\r\nJe nachdem, in welcher Form die Antwort angezeigt wird, werden die relevanten Daten automatisch in die Datenbank eingetragen."	-- todo: adjust when this works properly
GLDG_TXT.elements.name.PlayersActionButtonsRemove	= "Charakter entfernen"
GLDG_TXT.elements.tip.PlayersActionButtonsRemove	= "Entfernt diesen Charakter aus der Datenbank. Kann nur für Charaktere gewählt werden, die weder Main noch Twink sind."
GLDG_TXT.elements.name.PlayersActionButtonsGuild	= "Gilde manuell setzen"
GLDG_TXT.elements.tip.PlayersActionButtonsGuild		= "Verwendet diesen Knopf, um den Gildennamen das Charakters manuell zu setzuen/editieren/löschen.\r\nDer Knopf kann nicht für Charaktere verwendet werden, die der Gilde des aktuell eingeloggten Charakters angehören. Sollte später der Gildenname das Charakters automatisch erkannt werden, wird der manuelle Wert ersetzt."
GLDG_TXT.elements.name.PlayersActionButtonsCheck	= "Konsistenzprüfung"
GLDG_TXT.elements.tip.PlayersActionButtonsCheck		= "Verwende diesen Knopf um eine Konsistenzprüfung auszuführen. Inkonsistenzen werden in den Chat geschrieben, diese müssen manuell behoben werden."
GLDG_TXT.elements.name.PlayersActionButtonsNote		= "Notiz"
GLDG_TXT.elements.tip.PlayersActionButtonsNote		= "Verwende diesen Knopf, um dem aktuell ausgewählten Charakter eine eigene Notiz hinzuzufügen/zu editieren/zu löschen. Diese Notiz wird im Tooltip des Charakters angezeigt.\r\nDiese Notiz ist unabhängig von der Gildennotiz, der Offiziersnotiz und der Freunde-Notiz, welche separat im Tooltip angezeigt werden."
GLDG_TXT.elements.name.PlayersActionButtonsPublicNote	= "Öffentliche Notiz"
GLDG_TXT.elements.tip.PlayersActionButtonsPublicNote	= "Verwende diesen Knopf, um die öffentliche Notiz des aktuell ausgewählten Charakters zu bearbeiten."
GLDG_TXT.elements.name.PlayersActionButtonsOfficerNote	= "Offiziersnotiz"
GLDG_TXT.elements.tip.PlayersActionButtonsOfficerNote	= "Verwende diesen Knopf, um die Offiziersnotiz des aktuell ausgewählten Charakters zu bearbeiten."

GLDG_TXT.elements.name.PlayersSubAliasDel	= "Alias löschen"
GLDG_TXT.elements.tip.PlayersSubAliasDel	= "Mit diesem Knopf kann der Alias-Name für den ausgewählten Charakter gelöscht werden"
GLDG_TXT.elements.name.PlayersSubAliasSet	= "Alias-Namen setzen"
GLDG_TXT.elements.tip.PlayersSubAliasSet	= "Mit diesem Knopf kann der Alias-Name für den ausgewählten Charakter gesetzt oder aktualisiert werden."
GLDG_TXT.elements.name.PlayersSubAliasEditbox	= "Alias"
GLDG_TXT.elements.tip.PlayersSubAliasEditbox	= "Gib in diesem Feld den Alias-Namen für den ausgewählten Charakter ein"
--GLDG_TXT.elements.name.PlayersLine		= "Character wählen"
--GLDG_TXT.elements.tip.PlayersLine		= "Klicke auf einen Namen in der Liste, um den Charakter zu verwalten"
GLDG_TXT.elements.name.PlayersSubMainAltLine	= "Main wählen"
GLDG_TXT.elements.tip.PlayersSubMainAltLine	= "Klicke auf einen Namen in der Liste, um diesen Charakter dem ausgewählten Alt als Main zuzuordnen"
GLDG_TXT.elements.name.PlayersHeaderLine	= "Character selection"
GLDG_TXT.elements.tip.PlayersHeaderLine		= "Click on a character name to manage that character. Hovering over the entry in the character list will show a tooltip with relevant information"
GLDG_TXT.elements.name.PlayersSubGuildEditbox	= "Gildenname"
GLDG_TXT.elements.tip.PlayersSubGuildEditbox	= "Gib in diesem Feld manuell einen Gildennamen für den ausgewählten Charakter ein. Dieser Eintrag wird überschrieben, falls der Gildenname später automatisch ermittelt werden kann."
GLDG_TXT.elements.name.PlayersSubGuildSet	= "Gildenname setzen/ändern"
GLDG_TXT.elements.tip.PlayersSubGuildSet	= "Mit diesem Knopf kann der Gildenname für den ausgewählten Charakter gesetzt oder aktualisiert werden."
GLDG_TXT.elements.name.PlayersSubGuildDel	= "Gildennamen löschen"
GLDG_TXT.elements.tip.PlayersSubGuildDel	= "Mit diesem Knopf kann der Gildenname für den ausgewählten Charakter gelöscht werden."
GLDG_TXT.elements.name.PlayersSubNoteEditbox	= "Notiz"
GLDG_TXT.elements.tip.PlayersSubNoteEditbox	= "Gib in diesem Feld eine eigene Notiz für den ausgewählten Charakter ein.\r\nDiese Notiz ist unabhängig von der Gildennotiz, der Offiziersnotiz und der Freunde-Notiz, welche separat im Tooltip angezeigt werden."
GLDG_TXT.elements.name.PlayersSubNoteSet	= "Notiz setzen/ändern"
GLDG_TXT.elements.tip.PlayersSubNoteSet		= "Mit diesem Knopf kann die Notiz für den ausgewählten Charakter gesetzt oder aktualisiert werden."
GLDG_TXT.elements.name.PlayersSubNoteDel	= "Notiz löschen"
GLDG_TXT.elements.tip.PlayersSubNoteDel		= "Mit diesem Knopf kann die Notiz für den ausgewählten Charakter gelöscht werden."

GLDG_TXT.elements.name.CleanupGuild		= "Gilde bereinigen"
GLDG_TXT.elements.tip.CleanupGuild		= "Verwende diesen Knopf, um eine Liste aller in der Datenbank referenzierten Gilden anzuzeigen.\r\nDer Gildenname, den Du dann auswählst, wird von allen Charakteren, die dieser Gilde zugewiesen sind entfernt.\r\nFalls die Charaktere zu einer Gilde gehören, der einer Deiner Charaktere angehört, wird Ihnen der Gildenname automatisch wieder zugewiesen, wenn Du Dich das nächste mal mit diesem Charakter einloggst."
GLDG_TXT.elements.name.CleanupFriends		= "Freunde bereinigen"
GLDG_TXT.elements.tip.CleanupFriends		= "Verwende diesen Knopf, um eine Liste aller Deiner Charaktere anzuzeigen, die verwaltete Charaktere auf der Freundesliste haben.\r\nDen Charakter, den Du auswählst wird bei sämtlichen Charakteren, die diesen referenzieren gelöscht.\r\nDas nächste mal, wo Du Dich mit diesem Charakter einloggst, werden alle Freunde ihn erneut referenzieren."
GLDG_TXT.elements.name.CleanupChannel		= "Channel bereinigen"
GLDG_TXT.elements.tip.CleanupChannel		= "Verwende diesen Knopf, um eine Liste aller Channels anzuzeigen, die verwaltete Charaktere referenzieren.\r\nDen Channel, den Du auswählst, wird bei sämtlichen Charakteren, die ihn referenzieren entfernt.\r\nDas nächste mal, wenn einer dieser Charaktere einem verfolgten Channel beitreten, werden Sie diesen automatisch wieder referenzieren."
GLDG_TXT.elements.name.CleanupOrphan		= "'Waisen' bereinigen"
GLDG_TXT.elements.tip.CleanupOrphan		= "Verwende diesen Knopf, um alle Charaktere zu löschen, die weder Main noch Twink sind, kein Alias haben und weder einen Freund noch einen Channel referenzieren.\r\nGildenzugehörigkeit schützt nicht vor Löschung. Gildenmitglieder, Freunde und Channel-Mitglieder werden wieder in die Datenbank aufgenommen, wenn Sie das nächste mal erkannt werden."
GLDG_TXT.elements.name.CleanupSubEntriesLine	= "Wähle einen zu bereinigenden Eintrag"
GLDG_TXT.elements.tip.CleanupSubEntriesLine	= "Wähle einen Eintrag (Gildenname, Freund, Channel) aus der Liste, um alle Referenzen von Charakteren darauf zu löschen."


GLDG_TXT.elements.name.GreetingsSelLevel	= "Level up Grüsse"
GLDG_TXT.elements.tip.GreetingsSelLevel		= "Mit diesem Knopf können die Gruss-Phrasen definiert werden, die verwendet werden, wenn ein Charakter einen neuen Level erreicht"
GLDG_TXT.elements.name.GreetingsSelBye		= "Abschiedsgrüsse"
GLDG_TXT.elements.tip.GreetingsSelBye		= "Mit diesem Knopf können die Gruss-Phrasen definiert werden, die verwendet werden, wenn ein Charakter verabschiedet werden soll"
GLDG_TXT.elements.name.GreetingsSelNight	= "Gutenachtgrüsse"
GLDG_TXT.elements.tip.GreetingsSelNight		= "Mit diesem Knopf können die Gruss-Phrasen definiert werden, die verwendet werden, wenn einem Charakter gute Nacht gewünscht werden soll"
GLDG_TXT.elements.name.GreetingsSelRank		= "Beförderungsgrüsse"
GLDG_TXT.elements.tip.GreetingsSelRank		= "Mit diesem Knopf können die Gruss-Phrasen definiert werden, die verwendet werden, wenn ein Charakter befördert wurde"
GLDG_TXT.elements.name.GreetingsSelJoin		= "Willkommensgrüsse"
GLDG_TXT.elements.tip.GreetingsSelJoin		= "Mit diesem Knopf können die Gruss-Phrasen definiert werden, die verwendet werden, wenn ein Charakter der Gilde beigetreten ist"
GLDG_TXT.elements.name.GreetingsSelDefault	= "Login Grüsse"
GLDG_TXT.elements.tip.GreetingsSelDefault	= "Mit diesem Knopf können die Gruss-Phrasen definiert werden, die verwendet werden, wenn sich ein Charakter zum ersten mal eingeloggt hat"
GLDG_TXT.elements.name.GreetingsSelRelog	= "Relog Grüsse"
GLDG_TXT.elements.tip.GreetingsSelRelog		= "Mit diesem Knopf können die Gruss-Phrasen definiert werden, die verwendet werden, wenn sich ein Charakter erneut eingeloggt hat"
GLDG_TXT.elements.name.GreetingsSelGuild	= "Guilde grüssen"
GLDG_TXT.elements.tip.GreetingsSelGuild		= "Mit diesem Knopf können die Gruss-Phrasen definiert werden, die verwendet werden, wenn Du Deine Gilde grüsst"
GLDG_TXT.elements.name.GreetingsSelChannel	= "Channel grüssen"
GLDG_TXT.elements.tip.GreetingsSelChannel	= "Mit diesem Knopf können die Gruss-Phrasen definiert werden, die verwendet werden, wenn Du Deinen Channel grüsst"
GLDG_TXT.elements.name.GreetingsSelByeGuild	= "Tschüss Gilde"
GLDG_TXT.elements.tip.GreetingsSelByeGuild	= "Mit diesem Knopf können die Phrasen definiert werden, die verwendet werden, wenn Du Deiner Gilde tschüss sagen willst."
GLDG_TXT.elements.name.GreetingsSelNightGuild	= "Gute Nacht Gilde"
GLDG_TXT.elements.tip.GreetingsSelNightGuild	= "Mit diesem Knopf können die Phrasen definiert werden, die verwendet werden, wenn Du Deiner Gilde gute Nacht sagen willst."
GLDG_TXT.elements.name.GreetingsSelByeChannel	= "Tschüss Channel"
GLDG_TXT.elements.tip.GreetingsSelByeChannel	= "Mit diesem Knopf können die Phrasen definiert werden, die verwendet werden, wenn Du Deinem Channel tschüss sagen willst."
GLDG_TXT.elements.name.GreetingsSelNightChannel	= "Gute Nacht Gilde"
GLDG_TXT.elements.tip.GreetingsSelNightChannel	= "Mit diesem Knopf können die Phrasen definiert werden, die verwendet werden, wenn Du Deinem Channel gute Nacht sagen willst."
GLDG_TXT.elements.name.GreetingsSelLaterGuild	= "Bis später Gilde"
GLDG_TXT.elements.tip.GreetingsSelLaterGuild	= "Mit diesem Knopf können die Phrasen definiert werden, die verwendet werden, wenn Du Deiner Gilde 'bis später' sagen willst."
GLDG_TXT.elements.name.GreetingsSelLaterChannel	= "Bis später Channel"
GLDG_TXT.elements.tip.GreetingsSelLaterChannel	= "Mit diesem Knopf können die Phrasen definiert werden, die verwendet werden, wenn Du Deinem Channel 'bis später' sagen willst."
GLDG_TXT.elements.name.GreetingsSelAchievment	= "Erfolg"
GLDG_TXT.elements.tip.GreetingsSelAchievment	=" Mit diesem Knopf können die Phrasen definiert werden, die verwendet werden, wenn Du einem Gildenmitglied zu einem Erfolg gratulierst."

GLDG_TXT.customerCodes	= "Folgende %-Codes können verwendet werden.\r\n"..
"%s = einmal oder zweilam, gemäss Beschreibung über der Edit-Box\r\n"..
"%c = Charaktername\r\n"..
"%n = Name, wie er für %s verwendet wird (Konfigurationsabhängig: Name, Main, Alias oder zufällig)\r\n"..
"%a = Alias des Charakters\r\n"..
"%m = Main Name, falls vorhanden, sonst %c\r\n"..
"%A = Main Alias, falls vorhanden, sonst %a falls vorhanden, sonst %m\r\n"..
"%l = Level, falls vorhanden, sonst leer\r\n"..
"%L = Level bis zum Maximumlevel, falls vorhanden, sonst leer\r\n"..
"%C = Klasse, falls vorhanden, sonst leer\r\n"..
"%r = Rangname, falls vorhanden, sonst Rang Nummer, falls vorhanden, sonst leer\r\n"..
"%v = Erfolg, falls vorhanden, sonst leer\r\n"..
"%g = Gildenalias, falls vorhanden, sonst Gildenname, falls vorhanden, sonst leer\r\n"..
"%G = Gildenname, falls vorhanden, sonst leer\r\n"..
"\r\n"..
"Du kannst Deine Nachrichten Levelabhängig machen, indem Du folgendes voranstellst:\r\n"..
"<levels:##:##> wobei die #-Zeichen von-Level und bis-Level (inklusive) bedeuten\r\n"..
"\r\n"..
"Du kannst Deine Nachrichten Zeitabhängig machen, indem Du folgendes voranstellst:\r\n"..
"<time:##.##:##.##> wobei ##.## die von-Zeit und bis-Zeit bedeutet\r\n"..
"\r\n"..
"Kombinationen der Form <levels:##:##><time:##.##:##.##>\r\n"..
"und <time:##.##:##.##><levels:##.##> sind auch erlaubt."

GLDG_TXT.elements.name.GreetingsMsgAdd		= "Gruss hinzufügen"
GLDG_TXT.elements.tip.GreetingsMsgAdd		= "Mit diesem Knopf wird der momentan bearbeitet Gruss hinzugefügt oder aktualisiert"
GLDG_TXT.elements.name.GreetingsMsgDel		= "Gruss löschen"
GLDG_TXT.elements.tip.GreetingsMsgDel		= "Mit diesem Knopf wird der momentan bearbeitete Gruss aus der Liste gelöscht"
GLDG_TXT.elements.name.GreetingsEditbox		= "Gruss eingeben"
GLDG_TXT.elements.tip.GreetingsEditbox		= "In diesem Feld werden Grüsse eingegeben oder editiert.\r\n\r\n"..GLDG_TXT.customerCodes
GLDG_TXT.elements.name.GreetingsLine		= "Gruss-Liste"
GLDG_TXT.elements.tip.GreetingsLine		= "Diese Liste enthält die Grüsse für den momentan ausgewählten Gruss-Typ. Klicke auf einen Gruss um ihn zu bearbeiten oder zu löschen.\r\n\r\n"..GLDG_TXT.customerCodes

GLDG_TXT.elements.name.GreetingsColNewDel	= "Sammlung erzeugen/löschen"
GLDG_TXT.elements.tip.GreetingsColNewDel	= "Mit diesem Knopf kann eine neue Sammlung angelegt oder eine ausgewählte Sammlung gelöscht werden"
GLDG_TXT.elements.name.GreetingsColPlayer	= "Charakter-basierte Sammlung"
GLDG_TXT.elements.tip.GreetingsColPlayer	= "Mit diesem Knopf wird definiert, welche Grüsse mit dem aktuellen Charakter verwendet werden. Dies kann praktisch sein, für Charaktere, die einen speziellen Sprachstil pflegen."
GLDG_TXT.elements.name.GreetingsColGuild	= "Gilden-basierte Sammlung"
GLDG_TXT.elements.tip.GreetingsColGuild		= "Mit diesem Knopf wird definiert, welche Grüsse mit den Charakteren der aktuellen Gilde verwendet werden. Dies kann auf einem mehrsprachigen Server praktisch sein, wenn ein Spieler in verschiedensprachigen Gilden ist oder wenn ein Spieler Charakteren in Rollenspiel-Gilden und gewöhnlichen Gilden hat."
GLDG_TXT.elements.name.GreetingsColRealm	= "Server-basierte Sammlung"
GLDG_TXT.elements.tip.GreetingsColRealm		= "Mit diesem Knopf wird definiert, welche Grüsse mit den Charakteren des aktuellen Servers verwendet werden. Dies kann praktisch sein, um verschiedene Grüsse auf Rollenspiel- und gewöhnlichen Servern oder Servern mit verschiedenen Sprachen zu verwenden."
GLDG_TXT.elements.name.GreetingsCollect		= "Sammlungsliste"
GLDG_TXT.elements.tip.GreetingsCollect		= "Diese Liste enthält alle definierten Sammlungen. Klicke auf eine Sammlung um diese zuzuweisen oder deren Grüsse zu bearbeiten"

GLDG_TXT.elements.name.GreetingsSubNewEditbox	= "Sammlungsname eingeben"
GLDG_TXT.elements.tip.GreetingsSubNewEditbox	= "In diesem Feld wird der Name der neu anzulegenden Sammlung eingegeben."

GLDG_TXT.elements.name.GreetingsSubNewAdd	= "Sammlung hinzufügen"
GLDG_TXT.elements.tip.GreetingsSubNewAdd	= "Mit diesem Knopf wird eine neue Sammlung mit dem eingegebenen Namen angelegt."
GLDG_TXT.elements.name.GreetingsSubNewCancel	= "Abbrechen"
GLDG_TXT.elements.tip.GreetingsSubNewCancel	= "Mit diesem Knopf wird die Erstellung einer neuen Sammlung abgebrochen."

GLDG_TXT.elements.name.GreetingsSubChangeGlobal		= "Globale Standards verwenden"
GLDG_TXT.elements.tip.GreetingsSubChangeGlobal		= "Mit diesem Knopf werden für die ausgewählte Gruppe die globalen Grüsse verwendet."
GLDG_TXT.elements.name.GreetingsSubChangeSelection	= "Ausgewählte Sammlung verwenden"
GLDG_TXT.elements.tip.GreetingsSubChangeSelection	= "Mit diesem Knopf werden die Grüsse der ausgewählten Sammlung für die ausgewählte Gruppe verwendet."
GLDG_TXT.elements.name.GreetingsSubChangeClear		= "Keine Sammlung verwenden"
GLDG_TXT.elements.tip.GreetingsSubChangeClear		= "Mit diesem Knopf wird für die ausgewählte Gruppe keine Sammlung verwendet."
GLDG_TXT.elements.name.GreetingsSubChangeCancel		= "Keine änderung"
GLDG_TXT.elements.tip.GreetingsSubChangeCancel		= "Mit diesem Knopf wird die Zuweisung von Grüssen für die ausgewählte Gruppe nicht verändert."


GLDG_TXT.elements.name.TodoTodoBox	= GLDG_TXT.infoTodo
GLDG_TXT.elements.tip.TodoTodoBox	= "Klicke diese Box an, um eine Liste mit gewünschten und geplanten Funktionen zu sehen."
GLDG_TXT.elements.name.TodoHistoryBox	= GLDG_TXT.infoHistory
GLDG_TXT.elements.tip.TodoHistoryBox	= "Klicke diese Box an, um einen Überblick der Änderungen der letzten Versionen zu sehen. Eine vollständige Liste aller Versionen ist in der readme.txt Datei enthalten."
GLDG_TXT.elements.name.TodoHelpBox	= GLDG_TXT.infoHelp
GLDG_TXT.elements.tip.TodoHelpBox	= "Klicke diese Box an, um Informationen über die Verwendung des Addons zu erhalten."


-- Some greetings to get started: those can be changed in the configuration GUI
-- Important note: this list will only be used when no configuration is found!
-------------------------------------------------------------------------------

-- Default
GLDG_GREET[2] = "Hallo %s"
GLDG_GREET[3] = "Willkommen %s"
-- Relogs
GLDG_GREETBACK[1] = "Willkommen zurück %s"
GLDG_GREETBACK[2] = "Hi %s, willkommen zurück"
GLDG_GREETBACK[3] = nil
-- Welcome to guild
GLDG_WELCOME[1] = "Wilkommen in der Gilde, %s"
GLDG_WELCOME[2] = "Hallo %s, toll Dich in der Gilde zu haben"
GLDG_WELCOME[3] = "Willkommen %s, schön, dass Du uns beitrittst"
-- Promotion
GLDG_RANK[1] = "%s, gratuliere zur Beförderung zu %s"
GLDG_RANK[2] = "Gratuliere %s zu %s"
-- New level
GLDG_LEVEL[1] = "%s, gratulire Level %s erreicht zu haben"
GLDG_LEVEL[2] = "%s, grats zu Level %s"
-- Leaving (day)
GLDG_BYE[1] = "Baba %s"
GLDG_BYE[2] = "Tschüss %s"
-- Leaving (night)
GLDG_NIGHT[1] = "Baba %s"
GLDG_NIGHT[2] = "Tschüss %s"
GLDG_NIGHT[3] = "Gute Nacht %s"
GLDG_NIGHT[4] = "Nacht %s"
-- Greeting guild
GLDG_GUILD[1] = "Hallo Gilde"
-- Greeting channel
GLDG_CHANNEL[1] = "Hallo Freunde"
-- Good bye guild
GLDG_BYE_GUILD[1] = "Tschüss Gilde"
-- Good night guild
GLDG_NIGHT_GUILD[1] = "Gute Nacht Gilde"
-- Good bye channel
GLDG_BYE_CHANNEL[1] = "Tschüss Freunde"
-- Good night channel
GLDG_NIGHT_CHANNEL[1] = "Gute Nacht Freunde"
-- See you later guild
GLDG_LATER_GUILD[1] = "Bis später Gilde"
-- See you later channel
GLDG_LATER_CHANNEL[1] = "Bis später Freunde"
-- Achievment
GLDG_ACHIEVMENT = {}
GLDG_ACHIEVMENT[1] = "Gratuliere dir %s zu %s"
GLDG_ACHIEVMENT[2] = "Gratuliere, %s"
GLDG_ACHIEVMENT[3] = "Grats %s"

end
