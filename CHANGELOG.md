# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [12.0.0] - 2026-01-27
### Added

### Changed
- Raised Retail interface version to 120000 for Patch 12.0.0 compatibility.
- Replaced deprecated `GetNumPartyMembers`/`GetNumRaidMembers` usage with modern group APIs in guild poll messaging.
- Improved database initialization to properly bind saved variables before accessing them.

### Fixed
- Fixed nil value error in Database module by ensuring saved variables are initialized before use.
- Fixed nil value error in `UpdatePlayerCheckboxes()` when GUI elements don't exist yet during initialization.
