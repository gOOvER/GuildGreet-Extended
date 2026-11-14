<div align="center">
  <img src=".github/assets/social-banner.png" alt="GuildGreet Extended Banner" width="100%" />

  # GuildGreet Extended

  **The Ultimate Guild, Friends & Channel Greeting Assistant for World of Warcraft — Completely Rebuilt on Ace3 with a Modern Dark-Slate & Gold UI!**

  [![Code Quality](https://github.com/gOOvER/GuildGreet-Extended/actions/workflows/quality.yml/badge.svg)](https://github.com/gOOvER/GuildGreet-Extended/actions/workflows/quality.yml)
  [![Release](https://github.com/gOOvER/GuildGreet-Extended/actions/workflows/release.yml/badge.svg)](https://github.com/gOOvER/GuildGreet-Extended/actions/workflows/release.yml)
  [![GitHub Release](https://img.shields.io/github/v/release/gOOvER/GuildGreet-Extended?include_prereleases&label=Version&color=brightgreen&logo=github)](https://github.com/gOOvER/GuildGreet-Extended/releases/latest)
  [![CurseForge](https://img.shields.io/badge/CurseForge-GuildGreet%20Extended-f16436?logo=curseforge&logoColor=white)](https://www.curseforge.com/wow/addons/guildgreet-extended)
  [![Wago.io](https://img.shields.io/badge/Wago.io-GuildGreet%20Extended-c1272d?logo=wagtail&logoColor=white)](https://addons.wago.io/addons/WL6JA9Nv)
  [![WoWInterface](https://img.shields.io/badge/WoWInterface-21709-0078d7)](https://www.wowinterface.com/downloads/info21709-GuildGreetExtended.html)
  [![WoW Versions](https://img.shields.io/badge/WoW-Retail%20%7C%20MoP%20%7C%20Cata%20%7C%20Wrath%20%7C%20TBC%20%7C%20Classic%20%7C%20Forever-f8b700?logo=battle.net&logoColor=white)](#-supported-wow-versions)
  [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
  [![Support](https://img.shields.io/badge/Support-donate.goover.dev-ff69b4?logo=ko-fi&logoColor=white)](https://donate.goover.dev)
</div>

---

**GuildGreet Extended** is a comprehensive World of Warcraft social guild, friends, and channel greeting assistant with full **Main / Alt (Twink) & Alias management**, customizable greeting collections, an interactive floating greeting queue, and a modern **Dark-Slate & Gold UI** with live font scaling (`10pt – 18pt`) — completely rewritten on the **Ace3 framework**.

---

## 🎮 Supported WoW Versions

Supports **all World of Warcraft flavors** from a single unified codebase:
- **Retail (Midnight `12.x` & The War Within `11.2.x`)**
- **Mists of Pandaria Classic (`5.5.x`)**
- **Cataclysm Classic (`4.4.x`)**
- **Wrath of the Lich King Classic (`3.4.x` / `3.8.x`)**
- **The Burning Crusade Classic Anniversary (`2.5.x`)**
- **Classic Era (`1.15.x`) & Classic Forever (`1.60.x` / `16001`)**

---

## ✨ Key Features

### 🎨 Complete Ace3 Rewrite & Modern Dark-Slate & Gold UI (`v13.1.0`)
- **Built on Ace3**: Powered by `AceAddon-3.0`, `AceDB-3.0`, `AceGUI-3.0`, `AceEvent-3.0`, `AceTimer-3.0`, `AceLocale-3.0`, `AceSerializer-3.0`, `AceComm-3.0`, `LibSharedMedia-3.0`, `LibDataBroker-1.1`, and `LibDBIcon-1.0`.
- **Unified Configuration Window (`/gg` or `/guildgreet`)**: Clean 6-tab navigation (`Settings`, `Greetings`, `Players`, `Cleanup`, `Colours`, `Profiles`) plus full **AceDB-3.0 Profile Management** (`Default`, Character, Guild, Class, or Custom profiles).
- **Live UI Font Scaling (`10pt – 18pt`)**: Instant `A-` / `A+` buttons in the window header and a font selector (`LibSharedMedia-3.0`) dynamically scale all text, labels, buttons, inputs, and the floating in-game greeting queue.
- **Persistent Window & Queue Positions**: Both the main configuration window (`GuildGreetConfigFrame`) and the floating greeting queue (`GuildGreetList`) automatically save and restore their exact screen coordinates when dragged.
- **ElvUI & AddOnSkins Compatible**: Custom backdrop and checkbox/button textures work cleanly alongside ElvUI and AddOnSkins without missing checkmarks, double borders, or clipped text.
- **Minimap Button & Addon Compartment**: Built-in `LibDBIcon-1.0` minimap launcher and Retail Addon Compartment integration.

### 📋 Interactive Floating Greeting Queue (`GuildGreetList`)
- Displays guild members, friends, and channel members who just logged in, relogged, joined the guild, leveled up, earned an achievement, or got promoted.
- **Event Icons & Color-Coded Status Badges**: Each queue entry features a colored left accent bar, class-colored character name, clean `(Twink: <Main>)` or manual alias badge, and a right-aligned icon + status label (`Eingeloggt` / `Logged in`, `Relog`, `Stufe X!` / `Level X!`, `Rang: <Rang>` / `Rank: <Rank>`, `Neu in Gilde` / `New in guild`, `Erfolg` / `Achievement`) without cluttering the queue with raw guild notes.
- **Left-Click** an entry to send a context-aware greeting, welcome, or congratulation message; **Right-Click** to dismiss the entry from the queue.
- **Rich Hover Tooltips**: Shows Main/Alt associations, manual aliases, level, class, guild rank, and localized event status.
- Configurable growth direction (upward or downward), maximum visible entries (`1–15`), custom row dimensions, and persistent drag position.

### 👥 Main / Alt (Twink) & Alias Management
- **Structured Multi-Column Roster Table & Floating Edit Popup**: Browse your guild roster in a clean, non-wrapping multi-column table (`Character`, `First Name`, `Role / Main`, `Level & Rank`, `Public Note`) with compact **Edit** and **Quick-Greet** icon buttons. Clicking a character or its Edit icon opens a dedicated floating **Player Edit Popup** to set a shared **First Name / Alias** (automatically synced across the Main and all linked Alts), assign Alts to Mains, manage custom notes, or toggle Main/Ignore status.
- **Smart Twink / Main Note Detection**: Automatically scans public and officer guild notes for `Twink`, `Alt`, and `Main` references (including multi-word character names such as `"twink aerandir elfaron"`) and links the character to the matching Main in the guild roster without copying raw guild notes into player aliases.
- **Chat Enhancement**: Optionally prepends `{Main}` or `{Alias}` tags to guild, officer, whisper, and channel messages so you always know who you are talking to.
- **Live Roster Search & Role Filters**: Instant search-as-you-type and role filtering by name, first name/alias, main, note, online status, unassigned characters, or ignored players.

### 💬 16 Greeting Categories & Custom Collections
- **Master-Detail Template Studio**: Browse all **16 greeting categories** (`Player Events` & `Own Announcements`) in a dedicated left sidebar with live template counters, insert placeholders with 1-click **Placeholder Chips**, preview rendered messages inline, and edit or remove templates via compact icon buttons.
- **16 Specialized Message Categories**:
  - `Greet` (Login), `GreetBack` (Relog), `Welcome` (Joined Guild), `NewRank` (Promotion), `NewLevel` (Level-Up), `Achievment` (Achievement), `Bye` (Logout Day), `Night` (Logout Night), `Guild` / `Channel` (Self Login), `ByeGuild` / `ByeChannel`, `NightGuild` / `NightChannel`, `LaterGuild` / `LaterChannel`.
- **Custom Collections**: Create reusable message collections and assign them globally or per **Guild**.
- **Dynamic Placeholders & Conditional Filters**: Use `%s`, `%c`, `%m`, `%a`, `%A`, `%l`, `%L`, `%C`, `%r`, `%v`, `%g`, `%G` and restrict messages by level range (`<min:max>`) or time of day (`<HH:MM:HH:MM>`).

### 🧹 Database Maintenance, Colour Studio & Profile Manager
- **Structured Maintenance Dashboard (`Cleanup`)**: Real-time KPI tiles (`Players`, `Mains`, `Alts`, `Ignored`, `Guildless`, `Orphans`), 2-column action cards with inline diagnostic feedback, smart Guild/Channel/Friend reference cleanup, and safe `AceSerializer-3.0` Export/Import backups.
- **Segmented Colour Studio (`Colours`)**: Customize chat and greeting queue colors across `Guild`, `Friends`, and `Channel` scopes with `#RRGGBB` swatch cards and a localized live preview.
- **AceDB-3.0 Profile Manager (`Profiles`)**: Switch, reset, copy, or delete profiles, or create new profiles in one click using **Character**, **Guild**, or **Class** quick presets.

---

## 🔤 Message Placeholders & Filters

| Placeholder | Description |
| :--- | :--- |
| `%s` / `%n` | Selected greeting name (Character, Main, or Alias depending on your settings) |
| `%c` | Character name (without realm suffix) |
| `%m` | Main character name (falls back to `%c` if unassigned) |
| `%a` | Character alias (falls back to `%c` if no alias is set) |
| `%A` | Main's alias (falls back to `%m`, then `%c`) |
| `%l` | Current character level |
| `%L` | Remaining levels to level cap |
| `%C` | Localized character class name |
| `%r` | Guild rank name (or rank number) |
| `%v` | Achievement link (for `Achievment` messages) |
| `%g` | Guild alias if configured, otherwise guild name |
| `%G` | Guild name |

### Conditional Message Prefixes
- **Level Filter (`<min:max>`)**: Prefix a message (e.g. `<1:20>Gratz on level %l, %n!`) to only use it when the player's level is between `min` and `max`.
- **Time-of-Day Filter (`<HH:MM:HH:MM>`)**: Prefix a message (e.g. `<06:00:11:59>Good morning %n!`) to restrict it to a specific time window. Both prefixes can be combined.

---

## ⌨️ Slash Commands & Keybindings

### Slash Commands (`/gg`, `/guildgreet`, or `/gldg`)
| Command | Action |
| :--- | :--- |
| `/gg` or `/guildgreet` or `/gldg` | Toggle the main **GuildGreet Extended** configuration window (supports `Tab` completion for `/gg <subcommand>`) |
| `/gg config` / `/gg settings` | Open the Settings tab directly |
| `/gg players` / `/gg spieler` | Open the Players (Main/Alt & First Name/Alias) tab |
| `/gg greetings` / `/gg cleanup` / `/gg colours` / `/gg profiles` | Open the respective configuration tab directly |
| `/gg help` or `/gghelp` | Show all available slash command options in chat |
| `/gg clear` | Clear all pending players from the greeting queue without sending greetings |
| `/gg test` | Add sample characters to the floating greeting queue to test layout and messages |
| `/gg greet [guild\|channel\|all\|<name>]` | Manually send a greeting to your guild, channel, both, or a specific player |
| `/gg bye [guild\|channel\|all\|<name>]` | Manually send a goodbye (or good-night) message |
| `/gg later [guild\|channel\|all]` | Manually send a "see you later" message |
| `/gg [show] <charname>` | Print the Main and all Alts for `<charname>` to chat |
| `/gg full <charname>` | Print the Main and all Alts for `<charname>` including level and class details |
| `/gg guild [show\|all\|list]` | List Main/Alt groups of online guild members (`show`), all members (`all`), or open a copyable window (`list`) |
| `/gg char [show\|all\|list]` | List Main/Alt groups across all tracked characters |
| `/gg check` / `/gg fix` | Check or automatically repair Main/Alt database inconsistencies |

### Keybindings (`ESC -> Options -> Keybindings -> GuildGreet`)
- **Open Config Window**
- **Clear Greet List**
- **Greet Guild and Channel**
- **Say Goodbye to Guild and Channel**
- **Say See You Later to Guild and Channel**
- **Test Trigger**

---

## 📦 Installation

1. Install via the **CurseForge App**, **Wago App**, **WowUp**, or download the latest release from [GitHub Releases](https://github.com/gOOvER/GuildGreet-Extended/releases).
2. Extract the `GuildGreet` folder into your client's `Interface/AddOns/` directory:
   - Retail: `_retail_/Interface/AddOns/`
   - Mists Classic: `_classic_/` or `_classic_ptr_/Interface/AddOns/`
   - Classic Era: `_classic_era_/Interface/AddOns/`
3. Enable **GuildGreet-Extended** in the character selection AddOns menu.

---

## 📜 Credits & License

- **Original Author**: Greya (up to v0.52)
- **TBC Update**: Mordikaiin & Rozak (v0.52b – v2.2)
- **GuildGreet Extended**: Urbin, Dun-Morogh (EU)
- **Complete Ace3 Rewrite & Modern Dark-Slate UI (v11.x – v13.x)**: **gOOvER** ([goover.dev](https://www.goover.dev))
- **License**: [GNU General Public License v3.0 (GPL-3.0)](LICENSE)
- **Support Development**: [donate.goover.dev](https://donate.goover.dev) • [Ko-fi](https://ko-fi.com/oldnoob) • [Buy Me a Coffee](https://www.buymeacoffee.com/goover)

---

## 🐛 Bug Reports & Feedback

Found a bug or have a feature request? Please report it on the **[GitHub Issue Tracker](https://github.com/gOOvER/GuildGreet-Extended/issues)** (please include your WoW client version, addon version, and any Lua errors if available).
