# Changelog

All notable changes to **GuildGreet Extended** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
