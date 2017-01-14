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


Test

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