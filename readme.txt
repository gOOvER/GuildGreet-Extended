GuildGreet Extended - A World of Warcraft guild and greeting tool
-----------------------------------------------------------------

History
-------
This Addon was originally written by Greya, his last release was 0.52.
I had contributed to the German localisation of that version. Greya has
not updated this addon for WoW 2.0.1 (TBC)

Mordikaiin and Rozak took over the addon and modified the interface for 11000,
his first version was 0.52b and he consequently released v2.2 which was adapted
to the LUA changes Blizzard implemented with patch 2.0.1.

I had already extended the original GuildGreet but never submitted those to
Greya. I copied them over to the new v2.2 and added some features. I sent
my extensions to v2.2 to Mordikaiin but didn't get a reply for quite some
time. I therefore decided to upload my extension to curse independently.
I got a reply from Mordikaiin and he is happy for me to take over the addon
as he is short on time anyway.

Urbin, Dun-Morogh (EU)


Extended features
-----------------
This extension includes all features of the base version (v2.2).

In addition, it includes an option (which can be enabled/disabled in the
configuration frame) to print all alt chars and the main char of the person
that logged in to the chat frame. I added this feature because while GuildGreet
helped me to properly greet people, I found it very hard to keep track of who
was who later during playing and seeing people in guild chat, not being certain
who they were. By printing this line, I regularly see which characters belong
to the same player (whenever they log in) and could therefore learn to know
who is who better.

As we wanted to keep a list of the main chars and all their alts on our
guild web page as well, I added the options to list them not only at the
time of logging in but also from a slash command. The following commands
are supported:

/gg guild [show]	This lists the main and alt chars of all people in the
			guild who are currently logged in
/gg guild all		This lists the main and alt chars of the whole guild,
			no matter whether they are currently online or offline
/gg guild list		This opens a list frame into which the output of
			/gg guild all is listed.
			From here you can select the text and copy it to some
			other place using Ctrl-C.
/gg [show] <charname>	This prints the main and alt chars for the given
			character name.
/gg full <charname>	This prints the main and alt chars for the given
			character name including all level and class infos.

The following is a sample output line:
	/gg Urbin
	GuildGreet: Sunh [Urbin: Hunter, 70] Juran Mymule

	/gg Sunh
	GuildGreet: (Sunh: Priest, 65) [Urbin] Juran Mymule

The character name in square brackets is the main char, the others are alt
chars. The name in round braces is the name passed as argument if it's not the
main name. If one of the chars is currently online, its name will be printed in
a different colour.

For normal features, please refer to the Readme block below (for Greya's 0.52
version)


Friends support
---------------
I have added tentative friend support (very untested). There is a new tab in
the configuration dialog to assign main and alt chars just like for guild
members.
The following commands work similar as the guild variants:
/gg friends [show]	Lists main and alts of friends that are online
/gg friends all		Lists main and alts of all friends
/gg friends list	Show copy-pastable list of all friends


User channel support
--------------------
Many guilds that have co-operations with other guilds have a common
user channel. I added support for such a channel to 20100.4, you can
enable this in the "General" tab and define the channel name to use.
You must join the channel before you can enter it in the configuration.
The channel members (except for guild members) will be managed in a
separate list and their own tab.

/gg channel [show]	Lists main and alts of channel members that are online
/gg channel all		Lists main and alts of all channel members
/gg channel list	Show copy-pastable list of all channel members


Auto assigning of main/alt from guild notes
-------------------------------------------
This is a feature requested by Dhugal

> Scan the guild roster player notes for a standard alt notation in order to
> Auto-config Guild Greet and, optionally, maintain the alt/main associations.
>
> For example, I have my main Jimbob and alts Joebob and Bobbob:
>
> My roster note for my main, Jimbob, says "Main". My roster note for Joebob
> and Bobbob says "alt-Jimbob"
>
> The above was a feature of an addon called AltMinder that I've been trying
> to maintain for my guild, but I am not a LUA coder. I used to use Guild
> Greet's main/alt mapping until I had to reset my addons one day, then
> realized I'd have to do it for our 400+ guild members again. So now I just
> use it for the login and leveling notifications.
>
> Another case for doing this is that WoWroster can scan those roster notes as
> well to make the same determination of alt/main associations. If a consistent
> format is followed, it would work for those using WoWroster as well.

If this feature is enabled (checkbox on general tab) *AND* no manual main/alt
information has yet been added, then the guild note and officer note will be
parsed.

The following keywords will be understood:

  "Main[ <any other text>]"
    It is important to note that if <any other text> follows, there must be a
    space after the "Main" keyword. Any other text will be discarded.
    --> this marks the character with this guild note as a "main" char

  "alt-<main name>[ <any other text>]"
    It is important to note that if <any other text> follows, there must be a
    space after the <main name>. Any other text will be discarded.
    --> this marks the character with this guild note as an "alt" char to the
        indicated "main" char


Flexible message definitions
----------------------------
In your greet/congratulation messages you can use flexible codes
  %c = char name
  %n = name as used today (depending on settings) = %s in old format
  %a = alias
  %m = main if available, %c else
  %A = main alias if available, %m else if available, %c else
  %l = level if available, empty else
  %C = class if available, empty else
  %r = rankname if available, rank number else if available, empty else
  %v = achievment if available, empty else
  %g = guild alias if available, else guild if available, else empty
  %G = guild name if available, else empty
  (suggested by Sentinelum, Keith, AcmeHeroesInc and lebanoncyberspace)
  The old %s entries still work (i.e. the extension is backwards compatible
  to the old greetings you probably have stored)

Also use <levels:##:##> or <time:##.##:##.##> to limit a greeting to a certain
level range or time frame. Combinations of <levles> and <time> are allowed.


Greeting guild and channel members
----------------------------------
This feature was requested by Yongpeng

There are two key bindings that can be used to send a greeting to your guild
chat and your selected channel and to say goodbye to the two channels. You can
also greet selectively using slash commands. You can configure a guild name
alias which can be used in the guild greetings instead of the full guild name.

/gg greet guild		Sends a greeting to the guild chat
/gg greet channel	Sends a greeting to the channel
/gg greet all		Sends a greeting to both the guild chat and the channel

/gg bye guild		Says goodbye to the guild chat
/gg bye channel		Says goodbye to the channel
/gg bye all		Says goodbye to both the build chat and the channel

/gg later guild		Says goodbye to the guild chat (intending to come back)
/gg later channel	Says goodbye to the channel (intending to come back)
/gg later all		Says goodbye to both the build chat and the channel
			(intending to come back)


Temporarily supressing certain greetings
----------------------------------------
This feature was requested by Oakayam

If a category (log-in, relog, joining of guild, level up, guild rank promotion)
has no greetings defined, a character will not be placed in the greet list upon
a corresponding event.
However, you might want to supress a certain category without deleting all its
greetings. This is now possible in the Settings->Greeting dialog, where you
can supress the corresponding events for each category (meaning a player who
levels up will not be placed in the greet list if the level-up category is
being suppressed)


Troubleshooting
---------------
If your guild mates coming online and going offline are not detected, check
the advanced interface options and make sure the "Guild member alert" setting
in the chat section is enabled.


Credits
-------
This addon was started based on an idea from Skint on Bloodhoof (EU) by Greya
(greya@synema.be) and then taken over by Mordikaiin and Rozak of Dragonblight
(US) (Michaelquickel@comcast.net).
Since then taken over and extended by Urbin on Dun Morogh (EU)
Code for level dependent message filtering was submitted by lebanoncyberspace


Todo and request list
---------------------
See todo.lua for a fairly readble version, or check the Information tab in game.


From Curse
----------
- option to suppress original login/logoff messages (requested by AZMAK)

-- detect if officer note contains "<main name>'s alt[ <discardable text]"
	elseif (string.find(on, "'s alt")~=nil) then
	local altstart, altend = string.find(on, "'s alt")
	local main = string.sub(on, 1, altstart-1)
	alts[pl] = main
	-- detect if officer note contains "<main name>' alt[ <discardable text]"
	-- For names like "Darias" which might be "Darias' alt"
	elseif (string.find(on, "' alt")~=nil) then
	local altstart, altend = string.find(on, "' alt")
	local main = string.sub(on, 1, altstart-1)
	alts[pl] = main

	Mind you, I have a bit of work to do on my own because I got a bunch of officers
	who use "Alt" vs "alt" a lot, and the code is case sensitive. If there's a away
	that strfind and sub can be made to be case irrelevant, then it'd make life easier.
	(code supplied by Darias)

- I just noticed that the key-bindings for "later guild and "goodnight guild" in
  the keybindings area isn't working for me. When I use the keybindings, nothing
  happens and I do have messages created for those. (reported by AZMAK)

- (kusinagii) Anyway my question is this:
	I use the GG's notes to keep track of join dates, promotions and whose (using
	their main) invited them. But after I promoted them I go through and parse the
	notes of the Promotion dates and add a letter (x) that lets me know when i scan
	over that they've been promoted and are now on a different type of promotion
	status.
	a guild note would look like this: P01B23feb (recruiter)
	then change to this after the first rolled around: x23feb (recruiter)

	Basically what I want to know is, is there a way to change your gg notes through
	some /gg setnote <name> note or some variation, I've tried a few but am not sure
	what it might be if it exists, I'm not LUA savi so I'm not sure what to search
	for. or... would it be feasible for me to update gg notes in the GuildGreet.lua
	file? But I would be perfectly content with a /gg setnote thing so i could
	update via macro.

- Collections are (partially) broken - reported by several people


VERSION HISTORY
---------------
40200.2
- re-added option to enable/disable player context menu. The menu will be disabled
  by default, as it seems to cause taint issues. Go to the 'other' tab in the config
  window to enable/disable it (needs reload of UI)

NOTE: As I am leaving WoW, this will be the final version of GuildGreet that is released

40200.1
- adjusted toc for patch 4.2.0

40100.1
- adjusted toc for patch 4.1.0

40000.8
- made GuildGreet config frame dragable (requested by evlyxx)

40000.7
- changed priority of greetings: achievments are now higher than levelup, so
  you'll congratulate a player in guild chat for the [Level 10] achievment
  instead of whispering him

40000.6
- fixed level cap for %L congratulations (reported by Deltethnia)

40000.5
- fixed placement of EGP option on config frame

40000.4
- fixed some errors with Collections (reported by Dusarra)
- option to show main name in chat even for alts that are ignored (requested by Elsu)
- added option to support EGP style officer notes for auto-assignment (requested by Dearthmaul)
- added support for 'alt - <name>' for auto-assignment (suggested by mdsandler)

40000.3
- no longer congratulating own achievments
- now showing main name/alias in greet list tooltip (reported by various people)

40000.2
- fixed clicking on event list to send greetings again

40000.1
- adjusted toc for patch 4.0.1
- fixed code so it works with 4.0.1 again
- fixed wrong level being used in grats message

30300.10
- added option to whisper level up grats (part of a suggestion by nighttar)

30300.9
- fixed bug with startup delta dialog when stored data did not contain rankname
  (reported by cycronexium)
- adjusted colours for alt-chars in character list (requested by Elsu)

30300.8
- check to catch error in GLDG_ShowGreetings (reported by Baraknor)
- consistency check now checks for main-links to inexisting characters
  (reported by Elsu)

30300.7
- correct level reported in delta popup for guild members levelling up
- removed 'global GLDG_UpdateTabs (nil value)' bug (reported by cycronexium)
- fixed 'player is nil' bug in SendBye (reported by disoph)
- now applying level and time filter mechanism to all greetings and goodbyes
  (greeting guild & channel; later guild & channel)
- fixed bug in filtering greet messages (might help with missing join and level
  up messages, though I'm not sure)
- 'Don't congratulate players that just logged in' no longer self-enables every
  time a character logs in (reported by Gorgonis)
- added message to delta-popup for rank changes
- fixed using no or wrong colours for friends in greet list
- fixed 'nil passed to gsub' error when calling GLDG_SendBye (reported by
  KingsTears)

30300.6
- showing which players are online in character list using a leading *
- showing main or main's alias in alias column for character list if
  alt has no alias on its own
- fixed %A not using the alias if the character is the main char
  (reported by cycronexium)
- fixed bug with new guild members not being greeted (reported by redblade1530
  and Dellilah)
- will now not offer promotion congrats for own characters
- channel members that are also guild members or friends will not be placed
  on greet list twice
- now also printing class and level for joined/left chat messages for channel
  members that are neither main/alt
- only evaluates officer notes for startup delta dialog if the current player
  is allowed to read the officer notes

30300.5
- added new message code %L for number of levels till max level (inspired by
  code submitted by lebanoncyberspace)
- added level based message filtering (using code submitted by lebanoncyberspace)
- modified message filtering supplied by lebanoncyberspace to also support time
  filtering
- added level based message filtering (using code submitted by lebanoncyberspace)
  use '<levels:##:##>message' where ## are the lower and upper level limit
  (inclusive for which this greeting is used
- added time dependent message filtering (based on code submitted by lebanoncyberspace)
  use '<time:##.##:##.##>message' where ##.## are the 24hour based lower and
  upper time limits (suggested by Balsta and Sentinelum)
- delta-popup now also shows changes in player/officer notes

30300.4
- allow sorting by guild in char list
- verified deDE localisation
- double logout message for channel/guild members fixed
- query to check for new version of addon added
- help tooltip texts completed
- added /gg fix command to automatically correct inconsistencies detected by /gg check
- display a warning if inconsistencies are detected at login
- added /gg unnew command to clear invalid 'new' flag that marks a character as
  'new in guild'
- added new message code %C for the class of the player
- added information tab

30300.3 (in progress)
- suppress achievment option added
- automatic /who requests introduced in 30300.2 have been disabled by default,
  go to Settings->Other to re-enable them
- /who spam to chat has been disabled by default, go to Settings->Chat to
  re-enable them (reported by Tebasile)
- order of achievment grats and relog messages fixed in SendGreet (reported
  by KingsTears and Enigma_TL, fix suggested by lebanoncyberspace)
- added option (Settings->Other) to show a summary box showing offline changes
  when you log in (requested by lebanoncyberspace)
- list friend's notes in tooltip (requested by Sentinelum)
- new greet message variables:
  %c = char
  %n = name as used today (depending on settings)
  %a = alias
  %m = main if available, %c else
  %A = main alias if available, %m else if available, %c else
  %l = level if available, empty else
  %r = rankname if available, rank number else if available, empty else
  %v = achievment if available, empty else
  %g = guild alias if available, else guild if available, else empty
  %G = guild name if available, else empty
  (suggested by Sentinelum, Keith, AcmeHeroesInc and lebanoncyberspace)
  The old %s entries still work (i.e. the extension is backwards compatible
  to the old greetings you probably have stored)
- a free note can be added to each character, it will be displayed in the
  tooltip

30300.2
- greet list now properly shows achievment entries
- automatically sending a /who query for players entering a channel for which
  information is missing
- fixed bug with listing offline/all players in guild
- fixed bug listing guild members that were in channel twice
- updated screenshots on curse.com

30300.1
- huge reorganisation: guild, friends and channel are no longer managed
  seperately but in one list. Your existing data will automatically be
  converted.
  NOTE: if you had some characters stored in guilds for one char and
  as friends or in channels for other chars, this may mean that you need
  to manually verify combined entries and make minor adjustments
- removed friends and channel tabs
- add tooltip to char list with info about character
- reorganise char list
  add new fields: Alias, Guild, Channel, Friend, #friends
- new filter options added to char list: guild only, my friends only,
  with friends only, my channel only, with channel only, online only
- added "remove" button to char list
- added "set guild" button to char list
- added "check" button to char list
- added "who query" button to char list, this will start a /who query for
  the current character, results will be parsed and stored
- show player and officer note in player tooltip (not quite full guild roster
  support but it's a start; full support suggested by Kobihunt)
- extended queue tooltip with some more player info
- added cleanup tab to remove stale data and stale characters
  all "orphans" (unassigned, no channel, no friends)
  remove a specific friend (will be re-added)
  remove a specific channel (will be re-added)
  remove a specific guild (will be re-added)
- achievments can now be congratulated for (requested by Jesterbob and many
  others)
- check for guild alert setting and pop up a box once if it is disabled
- now properly handles channel names in upper, lower and mixed case (reported
  by tochstn: Thorsten Duykers)
- printing main name if an alt leaves the guild
- printing alias and/or main for levelling up
- added config setting to select whether to print achievment to chat
- added config setting to select whether {} postfix is added to chat
- added a page to the Interface->Addons configuration interface stating
  that /gg opens the config dialog


30200.5
- moved the whole chat frame on event hook to the new chat filter system
  in the hope that this will solve the various issues with the chat hook
  (contributions by Wilgorix and Tandanu)

30200.4
- refixed the arg12 fix so that main names are again added to chat output
  (reported by wagg)

30200.3
- truly fixed arg12 being passed to chat handler now (reported by funkydude)

30200.2
- fixed bug when clicking on a name in the greet box (reported by many people)

30200.1
- added check to not call random with an empty greetings list (reported by
  100368)
- added arg12 to obsolete chat handler due to added coloured names in chat
- adjusted toc for patch 3.2

30100.1
- adjusted toc for patch 3.1

30008.1
- adjusted toc for patch 3.0.8
- fixed problem with right click menu (thanks to Mycroftxxx for the hint on
  how to fix it, that saved me a lot of time)
- added code to detect guild member's achievments but not yet doing anything
  with it

30002.1
- adjusted toc for patch 3.0.2
- added self/argN to many API functions (not sure if I got them all)
- fixed a nil error in cases where the main left the guild but its alts
  were still in it (fix proposed by Michael Jenkins)
- only adding chars to "channel list" that join the monitored channel instead
  of all customer channels

20400.4
- finally fixed the "no grats on login" function (reported by Twidget_2743,
  suggestion on how to fix by Martin)

20400.3
- fixed a typo in a function name which caused an error in hooksecurefunc
  (reported by Zidomo and justcallmefred)

20400.2
- changed context menu to use hooksecurefunc() to solve the taint issues
  and always allow support for the menus (removed config option to disable
  menu again) (reported by Zidomo)

20400.1
- updated toc for patch 2.4.0
- broadcasting version to let others know if there is a newer version
- making player context menu configurable in order to work around
  taint issues reported by Zidomo
  NOTE: you will need to enable context menus if you want to keep using
        them, they will be disabled by default
- added possibility to list all addons by Urbin

20300.2
- fixed problem with not showing alts for people in channel

20300.1
- updated toc for patch 2.3.0

20200.2
- key binding to show config window can now also be used to hide window again

20200.1
- updated toc for patch 2.2.0
- added filter to only list unassigned chars (suggested by Kobihunt)
- fixed error in colour editing boxes where green and blue values were mixed up

20103.12
- fixed typo (playere instead of player, reported by Tack)
- added hint about enabling Advanced Interface Options->Chat->Guild Member Alert

20103.11
- allow creation of greet list containing test people
- added "close" button to greet list to allow clearing of list using the mouse
  (indirectly suggested by ImmortalDragon2 who wanted some way of clearing it)
- added an option to choose between server or local time (suggested by
  ImmortalDragon2)

20103.10
- added option to not congratulate players just loggin in (suggested by
  ImmortalDragon2 and Oakayam (though he wanted variable priorities)
- added GuildGreetDump as seperate addon to dump debugging information
  into a file

20103.9
- no longer causing an error when trying to use new greetings (bye guild,
  bye channel etc...) with a collection (reported by Oakayam)
  --> you need to delete and re-create existing collections for this fix
      to work (or delete your saved variables - if you know what you're doing)
- fixed really stupid bug that made greeting people impossible (reported by
  neverawth and tack)
- friends update is now also timer driven, if guild update is timer driven

20103.8
- finally fixed guild roster change update issues (hint provided by neverawth)
- guild event driven or interval polled roster scan now supported
- added /gg clear to clear greet list

20103.7
- fixed typo in default greetings (reported by ImmortalDragon2)
- fixed an issue where "list names to chat when logging on" and
  "list names to chat when logging off" didn't work correctly when one was
  enabled and the other was disabled (reported by ImmortalDragon2)
- now prepending main names to officer chat as well (suggested by ImmortalDragon2)

20103.6
- level of own characters is only shown if "IncludeOwn" setting is enabled
  (reported by Kismi)
- added two buttons to supress all/none of the greet list categories. This can
  be useful to disable the greet list during instance runs, so you won't be
  distracted. Output to the chat is not impacted. (suggested by ImmortalDragon2)
- added a minimum level under which level-up's will be ignored (suggested by
  ImmortalDragon2)
- added ability to select to which chat window the GuildGreet text is printed.
  /gg help and /gg about will always be printed to the default chat frame,
  all other text goes to the selected chat frame (suggested by Kortanis)

20103.5
- added possibility to have name or alias of main prepended to chat messages
  of alts
- fixed a bug which caused the Goodbye and Seeyoulater key bindings not to work

20103.4
- fixed an error in the channel drop down list handling introduced in 20103.1

20103.3
- split "General" Tab into sub-tabs to allow for more configuration options
- printing levelup to chat
- printing people leaving the guild to chat
- added option to turn on/off certain greetings without deleting the greeting
  phrases (suggested by Oakayam)
- added see you/goodbye hotkey
- made behaviour of greet/see you/bye hotkey configurable
- add auto greeting (please use carefully in order not to spam guild chat!)
- can define guild alias to be used in guild greetings

20103.2
- added greeting hotkey and functions (suggested by Yongpeng)
- set default relog timer to 0 as it caused so much confusion

20103.1
- fixed TOC for 2.1.3
- now uses correct colour when people on friends list or channel log in for the
  first time (showing "new" colour instead of "relog" colour)

20102.1
- fixed TOC for 2.1.2
- fixed nil error in GLDG_GetTableSize() (reported by Tack)

20101.6
- translated tooltips to german
- not showing unused colours in the colour config tab

20101.5
- only show mains to choose for friends that are on current characters friends
  list
- help tooltips completed in english
- enable/disable friends -> disable friends tab
- enable/disable channel -> disable channel tab

20101.4
- Only show guild and channel members that are not part of current characters
  guild
- Added support for help tooltips for configuration elements (not many texts
  entered, though)
- allow random greetings using main, alt, alias names (suggested by Balsta)

20101.3
- Replaced funny *, **, ***, #, ##, ###, ?, ??, ??? commands with useful names
  /gg help to display the new commands

20101.2
- created my own ColorPickerFrame that contains the editboxes, so they can't be
  hidden anymore
- ColorPickerFrame can now be moved

20101.1
- fixed colour configuration (now works for friends and channel colours)
  (reported by Balsta)
- removed checkbox for channels (drop down list is enough) (reported by
  Paulie_Gil)
- greet list title background can now be chosen (suggested by Oakayam)
- also parsing officer channel for auto-assignment (suggested by Epophis)

20100.4
- added colour picker (and extending it)
- added colour customisation tab (suggeste by Balsta)
- different colours for guild/friend/channel (suggested by Balsta)

20100.4_beta2
- fixed sending greetings to user-channel
- clearing main of alts when main leaves guild
- guild members in channel list (from other chars) will not be shown
- Offer drop down list for possible channel names
- fixing bug where guild was not detected on first login

20100.4_beta1
- added support for parsing of a user-channel (as used by guild-cooperations)

20100.3
- minor corrections

20100.3_beta2
- separate checkbox to enable/disable listing of main/alts when logging off
  (suggested by Tebasile)
- auto assigning of main/alts based on guild note added (suggested by Dhugal)

20100.3_beta1
- tentative friend support
- /gg full <name> support added

20100.2
- really fixed the log in details for players without main and alts

20100.1
- updated toc for patch 2.1.0
- also printing alias and char details when players without alt log in
- copy-paste list is now uncoloured
- first version by Urbin

v3.02
- changed displaying of class
- last version by Mordikaiin/Rozak, refer to Readme block below

v3.01
- added support to say goodbye to a player (using player menu)
- added displaying of class

v3.0
- added menu entries to look up player

v2.4
- added listing of main and alt chars
- added key binding for configuration interface
- added dumping to list field for copy-pasting

v2.3
- added chat message on loggin, extension by Urbin

v2.2
- base for my branch, release by Mordikaiin/Rozak, refer to Readme block below

v0.52b
- first version by Mordikaiin/Rozak, refer to Readme block below

v0.52
- last version by Greya, refer to Readme block below



-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
  README by Rozak & Mordikaiin
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

I've updated this as I cant se any updates from the original mod author. Seems
to work for me under v2 WOW - any suggestions suggest post to the usual place
on Curse as I've no intention of updating this mod on a perm basis!

v2.1 Changes
1) By request added an option to switch between Guild and Whisper greetings

v2.0 Changes

1) Updated to work with WOW v2
2) Updated to whisper players instead of sending to the public channels

Rozak
Stormrage-EU



-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
  README by Greya
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

GuildGreet - A World of Warcraft guild tool
Readme file for v0.52
----------------------------------------------------------------


INSTALLATION
------------
Extract the folder in GuildGreet.zip to the directory
..\World of Warcraft\Interface\AddOns


DESCRIPTION
-----------
This is a guild tool: it's useless if you are not in a guild

As soon as you go online, the addon loads the list of players in your guild and starts to
monitor all changes. As soon as a player comes online or joins the guild, the name is
added to a small list onscreen. If you leftclick on the name, one of the possible greetings
(at random) is written in the guild channel and the name is removed from the list. if you
rightclick on the name, it's removed from the list without sending a greeting.
These color codes are used for the list:
- red: players joining the guild both during your session and earlier. These players will also
       be indicated by the word NEW at the end of the line.
- orange: players logging in for the first time during your current session
- green: players relogging. They logged on before during your current session
- blue: players gaining a higher level both during your session and then earlier. These players
        will also be indicated by the word LEVEL at the end of the line.
- purple: players getting a higher guildrank then previous session and earlier. These players
          will also be indicated by the word RANK at the end of the line.

Notes:
- the list shown on the screen can be dragged anywhere you want by using the red titlebar to drag.
- the onscreen list shows a maximum of 5 players by default, but GuildGreet will store the names of any
  further players needing a greeting.
- mousing over the names in the list will display a tooltip with usefull information regarding the player

For detailed information on changing the configuration (like greeting texts), see the file manual.txt


DEBUGGING
---------
CLI commands: /gg debug [ on | off | toggle ]
If you encounter problems with GuildGreet, you might want to turn on debugging to see what's going wrong.
When debugging is enabled, two effects will happen:
1) the list of players to be greeted is forced visible, even when no players are on the list
2) incoming system messages are followed: debug messages are written to DEFAULT_CHAT_FRAME
If you find some problem, please report the issue to me, the author, and provide these details:
- version of GuildGreet you are using
- language of your WoW client
- debug messages displayed (if any)
- your description of the problem


SUPPORTED
---------
- WoW clients for all languages (GUI is currently available in English and German)
- myAddOns 2.0

KNOWN BUGS
----------
- playerlist manipulations near end of list can result in temporary hiding the last
  entries of the list from the GUI


TODO LIST
---------
- Implement MiniMap Icon
- Implement Optional [GuildGreet] After name in Chat when sending messages
- Implement Optional Auto Send Greet
- Implement Friends Support (implemented by Urbin)
- Implement Optional Whisper FUnction (implemented by Rozak/Mordikaiin)


VERSION HISTORY
---------------
v0.52c
- Update to Interface: 11100

v0.52b
- Update to Interface: 11000
- Taken over by Mordikaiin

v0.52
- Current I Face Version

v0.51
- initial guild information retrieval is now more reliable

v0.50
- new separate tabs for managing messages and players
- more control over displaying queued greetings list
- more configurable playerlist for configuration
- reworked entire rank detection part as the old one didn't work correctly
- added option to greet alts with the same name as their main
- implemented collections to support using multiple greetings lists: see manual.txt for details
- default relog timeout is now set to 15 min
- faster initial playerlist loading
- fixed minor bug in displaying relogs
- fixed minor bug in displaying playerlist
- updated configuration documentation and moved to manual.txt
- translation for German GUI completed thanks to Urbin
- for NEW installations, the initial greetings will be in German if you have a German WoW client

v0.43
- yet another bug (detecting players going offline)

v0.42
- fixed another stupid bug (typo)

v0.41
- fixed bug with tooltip for main/alt characters when they log on for the first time.

v0.40
- small changes in existing tooltip texts and some additions too
- fixed scrollbar issues introducted by patch 1.9
- fixed another bug in offline counter system
- support for ignore, alias and main/alt

v0.31
- fixed bug in offline counter system
- fixed bug in joining members part
- now compatible with all languages thanks to a brilliant idea of Lunox
- updated for WoW patch 1.9

v0.30
- added support for detecting players joining the guild while you are offline
- added support for player leveling
- added support for player guildrank promotions
- fixed bug with removing messages
- corrected German localisation (thanks to sdw and Lunox)
- corrected French localisation (thanks to Feu)
- made sure offline members are also included in guild info retrieval
- added debug support

v0.21
- corrected French localisation (thanks to mymycracra)

v0.20
- now separate greetings for reloggers and joining players
- configuration GUI: open with /gg or /guildgreet
- fixed bug with tooltip for new players

v0.11beta
- a right click on the name now removes it from the list without sending a greeting
- removed some forgotten debug messages
- importing guild members should be more reliable now
- readme.txt added

v0.10beta
- initial release
