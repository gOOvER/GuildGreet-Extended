# Changelog

All notable changes to **GuildGreet Extended** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [13.1.0] - 2026-11-11

### Added
- **Floating Player Edit Popup (`GUI/Players.lua`, `GUI/Core.lua`)**:
  - Added a dedicated, draggable floating **Player Edit Popup (`GuildGreetPlayerEditPopup`)** showing read-only guild status, public note, and officer note alongside editable inputs for **First Name / Alias** (automatically synced across Main & all linked Alts), **Assign as Alt of Main** dropdown, **Custom Note**, quick role actions (`Set/Promote/Unset Main`, `Ignore`, `Greeting`, `Remove`), and an explicit **Save (`Speichern`)** button.
- **Automatic Twink / Main Detection from Guild Notes (`core/GuildGreet-PlayerManager.lua`)**:
  - Added `DetectMainFromNotes()` to automatically scan public and officer guild notes for `twink`, `alt`, and `main` indicators (e.g. `"twink aerandir elfaron  Sascha"`, `"twink von ..."`, `"alt of ..."`) and match single- or multi-word character names against the guild roster, linking `p.alt = mainKey` and marking the main character (`main = true`).
- **Separate Greeting Queue Toggles for First Name & Twink Info (`GUI/Settings.lua`, `GuildGreet.lua`)**:
  - Added two independent toggles in **Settings -> General -> Greeting Queue** (`QueueShowAlias` and `QueueShowTwink`) to separately enable or disable displaying the player's **First Name / Alias** (`[Vorname]`) and/or **Twink Info** (`(Twink: <Main>)`) in the floating greeting queue.

### Changed
- **Complete Dark-Slate & Gold Overhaul for Greetings, Cleanup, Colours & Profiles Tabs (`GUI/Greetings.lua`, `GUI/Cleanup.lua`, `GUI/Colour.lua`, `GUI/Profiles.lua`, `GUI/UIStyle.lua`, `GUI/Core.lua`, `lang/deDE.lua`, `lang/enUS.lua`)**:
  - **Greetings (`Begrüßungen`)**: Replaced the stacked dropdown form with a structured **Master-Detail Split View** featuring a scrollable 16-category sidebar (`Player Events` & `Own Announcements` with icons and live message counters), compact Collection selector bar, clickable **Placeholder Chips** (`%s`, `%c`, `%m`, `%a`, `%l`, `%C`, `%r`, `%v`, `%g`, `<1:20>`, `<06:00:11:59>`) with hover tooltips, inline preview banner, and compact `24x24` Preview/Edit/Delete icon buttons on each template row.
  - **Cleanup (`Bereinigung`)**: Redesigned into a structured maintenance dashboard with **6 visual KPI tiles**, spacious 2×3 maintenance action cards (eliminating button text truncation) with an inline diagnostic status bar, clean Dark-Slate reference-removal dropdowns with empty/disabled states, and an unclipped Backup Export/Import editor with `Select All`.
  - **Colours (`Farben`)**: Replaced dropdown scope selection and unstyled swatches with segmented **`Guild` / `Friends` / `Channel`** scope buttons, structured 2-column swatch cards displaying `#RRGGBB` hex badges (`Chat Notifications`, `Greeting Queue`, `System & Header`), and a fully localized live preview card.
  - **Profiles (`Profile`)**: Added an Active Profile hero card with active badge, explicit **`Create & Activate`** button plus 1-click **Quick Presets** (`Character`, `Guild`, `Class`), and side-by-side **Copy / Delete** cards with smart disabled states when no other profiles exist.
  - **Shared UI Style (`GUI/UIStyle.lua`, `GUI/Settings.lua`)**: Added reusable zero-taint Dark-Slate dropdowns, inputs, icon buttons, cards, and cross-flavor `ColorPickerFrame` wrapper, skinned remaining `AceGUI` `Dropdown` and `EditBox` controls in the `Settings` tab, and enabled full-width multi-line word wrapping with dynamic height adjustment for `CheckBox` and `InlineGroup` labels so long localized texts never truncate (`...`).
- **Multi-Column Players Roster Table & Compact Action Icons (`GUI/Players.lua`, `lang/deDE.lua`, `lang/enUS.lua`)**:
  - Replaced the cluttered inline AceGUI character editor and oversized `Select` (`Auswählen`) buttons in the **Players (`Spieler`)** tab with a structured, responsive **6-column roster table** (`Character` with Online/Offline dot + Class Icon, `First Name`, `Role / Main`, `Level & Rank`, single-line non-wrapping `Public Note`, and compact `Actions`) with smooth scrolling, live search-as-you-type filtering, and full hover tooltips.
  - Replaced wide text row buttons with compact `24x24` **Edit (`Bearbeiten`)** and **Quick-Greet** icon buttons (clicking any row or its Edit icon opens the player editor).
- **Floating Greeting Queue Event Icons & Status Badges (`GuildGreet.lua`)**:
  - Redesigned each queue row with a color-coded left accent bar, class-colored character name, and a dedicated right-aligned **Icon + Event Status Badge** (`Eingeloggt` / `Logged in`, `Relog`, `Stufe X!` / `Level X!`, `Rang: <Rang>` / `Rank: <Rank>`, `Neu in Gilde` / `New in guild`, `Erfolg` / `Achievement`).
- **German (`deDE`) UI Localization (`lang/deDE.lua`, `GUI/Core.lua`, `GUI/Settings.lua`, `GUI/Profiles.lua`, `GuildGreet.lua`)**:
  - Completed German translations for queue/minimap/compartment tooltips, sidebar statistics, settings labels, profile management dialogs, and player editor controls.

### Fixed
- **Slash Commands (`/gg`, `/guildgreet`, `/gldg`, `/gghelp`), Window Toggle & Startup Safety (`GuildGreet.lua`, `GUI/Core.lua`, `GUI/Init.lua`, `core/GuildGreet-Utils.lua`, `core/GuildGreet-HelpUtils.lua`, `core/GuildGreet-CleanupUtils.lua`, `core/GuildGreet-PlayerManager.lua`, `core/GuildGreet-ConfigCmd.lua`)**:
  - Fixed `CreateMainFrame()` in `GUI/Core.lua` starting in a visible state (`IsShown() == true`), which caused the first `/gg` or `ToggleConfigWindow()` call to immediately hide the window instead of opening it.
  - Fixed `RegisterSlashCommands()` wiping imported `/GG`, `/GUILDGREET`, and `/GLDG` entries from `hash_SlashCmdList` on `PLAYER_LOGIN` in modern 12.x / Forever clients; unified single-pass `AceConsole-3.0` registration with pre-defined `SLASH_ACECONSOLE_*` globals and `AceTab-3.0` tab completion.
  - Fixed nil-indexing in `GLDG.Utils:UpdatePlayerCheckboxes()` during `OnInitialize()` when legacy XML frames are absent.
  - Added missing `AceLocale-3.0` (`L`) and `Ambiguate` references in `core/GuildGreet-HelpUtils.lua` and `core/GuildGreet-CleanupUtils.lua` that caused `/gg help` to fail, fixed method casing on `GLDG.PlayerManager`, and added realm-agnostic character name resolution for `/gg show <name>` and `/gg detail <name>`.
- **Removed Raw Guild Notes from Greeting Queue & Alias Fields (`core/GuildGreet-PlayerManager.lua`, `GuildGreet.lua`, `GUI/Players.lua`)**:
  - Stopped `ProcessPlayerNotes()` from copying raw public guild notes into `p.alias` and added automatic cleanup (`CleanPollutedAliasesInTable`) to strip previously note-polluted aliases while preserving manually configured aliases (`p.manualAlias = true`).
- **Guild Member Level-Up & Promotion Detection (`core/GuildGreet-PlayerManager.lua`)**:
  - Fixed `UpdateCharacterData()` so guild member level-ups and rank promotions are compared before overwriting `existing.lvl` / `existing.rank`, properly flagging `newlvl` / `newrank` and adding the player to the greeting queue.
- **Per-Guild Player Storage & Active Guild Isolation (`GuildGreet.lua`, `GUI/Players.lua`, `GUI/Core.lua`, `GUI/Cleanup.lua`, `core/GuildGreet-Messages.lua`, `core/GuildGreet-PlayerManager.lua`)**:
  - Stored player roster data per guild (`self.db.realm.guildPlayers[guildName][playerName]`) with automatic migration from legacy flat `self.db.realm.players` tables.
  - Scoped `GLDG_DataChar`, the `Players` (`Spieler`) tab, and sidebar statistics strictly to the current character's active guild (`GetCurrentGuildName()`), showing `0` players and a localized notice (`"Du bist aktuell in keiner Gilde."` / `"Keine Gilde"`) when logged in on a guildless character.

---

## [13.0.0] - 2026-11-08

### Added
- **Complete Rewrite on the Ace3 Framework**:
  - Rebuilt the entire addon architecture from the ground up using **Ace3** (`AceAddon-3.0`, `AceDB-3.0`, `AceGUI-3.0`, `AceEvent-3.0`, `AceTimer-3.0`, `AceLocale-3.0`, `AceSerializer-3.0`, `AceComm-3.0`) alongside `LibSharedMedia-3.0`, `LibDataBroker-1.1`, and `LibDBIcon-1.0`.
  - Full **AceDB-3.0 Profile System** (`Default`, Character, Realm, Class, or Custom profiles) with profile copying, resetting, and automatic migration of legacy `GLDG_Data` saved variables.
- **Modern Dark-Slate & Gold UI (`AceGUI-3.0`)**:
  - Replaced legacy XML dialog frames with a scalable, two-column **Dark-Slate & Gold** configuration interface (`880x620`) featuring 7 dedicated tabs (`General`, `Greetings`, `Characters`, `Sub-Window`, `Cleanup`, `Backup & Restore`, `Information`).
  - **Custom Typography (`LibSharedMedia-3.0`)**: Added global font selection and live **Font Size Scaling (`10pt – 18pt`)** that dynamically resizes all labels, checkboxes, dropdowns, and list rows to prevent text overlaps.
  - **Floating Greeting Queue (`GuildGreetList`)**: Redesigned the on-screen greeting queue with a Dark-Slate & Gold header bar, live counter badge (`GuildGreet (N)`), configurable growth direction (up/down), row width/height, class icons, and class-colored names.
  - **Persistent Window Positions**: Moving either the floating **Greeting Queue (`GuildGreetList`)** or the **Main Configuration Window (`GuildGreetConfigFrame`)** via Drag & Drop now automatically saves and restores its exact screen position across `/reload` and relogs.
- **Main/Alt Auto-Detection, Alias System & Greeting Collections**:
  - Automatic detection and grouping of guild members' Main and Alt characters via guild notes (`Main`, `Alt`) and officer notes, plus manual Main/Alt pairing and custom player aliases (`Characters` tab).
  - **16 Greeting Categories**: Configurable templates (`%s` = player/alias, `%c` = character, `%m` = main, `%g` = guild, `%l` = level, `%r` = rank, `%a` = achievement) for login, relog, guild join, rank promotion, level-up, achievements, Whisper, Party, and Guild channels, plus Realm/Guild/Character Greeting Collections.
- **Database Maintenance & Safe Backups**:
  - Added one-click tools to clean up orphaned character data, purge inactive alts, reset configurations, and create/restore manual database snapshots (`GLDG_DataBackup`).
- **Minimap Button & Addon Compartment**:
  - Integrated `LibDBIcon-1.0` minimap button and Retail Addon Compartment menu entry with quick actions (`Left-Click`: Config, `Right-Click`: Test Queue, `Shift + Left-Click`: Greet Next Player).
- **Multi-Client Support**:
  - Native compatibility across **Retail (12.0.1 Midnight / 11.2.7 The War Within)**, **Mists of Pandaria Classic (5.5.x)**, **Cataclysm Classic (4.4.2)**, **Wrath of the Lich King Classic (3.4.5)**, **Burning Crusade Classic Anniversary (2.5.5)**, **Classic Era (1.15.8)**, and **Classic Forever (1.60.x)**.

### Changed
- Modernized all `C_GuildInfo`, `C_FriendList`, `C_ChatInfo`, and `BackdropTemplate` API calls for full compatibility across Retail 12.x and Classic clients.
- Replaced text-based close button labels (`X`) with native crisp cross textures (`Interface\Buttons\UI-StopButton`) across the main window and floating greeting queue.

### Fixed
- Fixed invisible `AceGUI-3.0` checkbox tick marks when **ElvUI** or **AddOnSkins** strips default button textures by rendering an explicit gold checkmark texture (`Interface\Buttons\UI-CheckBox-Check`).
- Fixed legacy saved-variables migration order so fresh installs and upgrades from older GuildGreet versions initialize cleanly without `nil` errors.

---

## [11.0.2] - 2024-08-19

### Added
- Support for **The War Within (Patch 11.0.2)**.
- Updated `SendChatMessage` and guild roster API wrappers for Retail 11.x compatibility.
