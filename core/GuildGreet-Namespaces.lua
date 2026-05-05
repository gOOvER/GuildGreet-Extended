--[[
GuildGreet-Namespaces.lua - AceDB Namespace Optimization
Provides better organization of data using AceDB namespaces for different functional areas
]]--

local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet", true) or LibStub("AceAddon-3.0"):NewAddon("GuildGreet", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", false)

-- Initialize namespaces
function GLDG:InitializeNamespaces()
	if not self.db then return end
	
	-- Create separate namespaces for different functional areas
	self.db_settings = self.db:RegisterNamespace("Settings")
	self.db_players = self.db:RegisterNamespace("PlayerManager")
	self.db_greetings = self.db:RegisterNamespace("Greetings")
	self.db_messages = self.db:RegisterNamespace("Messages")
	self.db_cleanup = self.db:RegisterNamespace("Cleanup")
	self.db_ui = self.db:RegisterNamespace("UI")
	self.db_cache = self.db:RegisterNamespace("Cache")
	
	-- Initialize namespace defaults
	self:InitializeNamespaceDefaults()
end

-- Initialize defaults for each namespace
function GLDG:InitializeNamespaceDefaults()
	-- Settings namespace defaults
	self.db_settings:RegisterDefaults({
		profile = {
			ShowNewerVersions = true,
			BigBrother = false,
			ExtendPlayerMenu = true,
			EnableContextMenu = false,
			UseFriends = false,
			AutoWho = false,
			EnableSync = false,
			DebugMode = false
		}
	})
	
	-- PlayerManager namespace defaults
	self.db_players:RegisterDefaults({
		char = {
			GuildMembers = {},
			PlayerRelations = {},
			RecentInteractions = {},
			LastUpdateTime = 0
		}
	})
	
	-- Greetings namespace defaults
	self.db_greetings:RegisterDefaults({
		global = {
			Greetings = {},
			GreetingProfiles = {},
			ActiveGreeting = 1
		}
	})
	
	-- Messages namespace defaults
	self.db_messages:RegisterDefaults({
		realm = {
			MessageQueue = {},
			MessageHistory = {},
			LastMessageTime = {}
		}
	})
	
	-- Cleanup namespace defaults
	self.db_cleanup:RegisterDefaults({
		profile = {
			LastCleanupTime = 0,
			AutoCleanup = false,
			CleanupInterval = 86400,
			InactivePlayerDays = 30
		}
	})
	
	-- UI namespace defaults
	self.db_ui:RegisterDefaults({
		profile = {
			WindowPosition = {},
			ExpandedSections = {},
			SortMethod = "name",
			FilterMethod = "all"
		}
	})
	
	-- Cache namespace defaults (temporary data)
	self.db_cache:RegisterDefaults({
		char = {
			LastRosterData = {},
			DetectedAddons = {},
			SyncedPlayers = {}
		}
	})
end

-- Get settings namespace
function GLDG:GetSettingsNamespace()
	return self.db_settings
end

-- Get player manager namespace
function GLDG:GetPlayerManagerNamespace()
	return self.db_players
end

-- Get greetings namespace
function GLDG:GetGreetingsNamespace()
	return self.db_greetings
end

-- Get messages namespace
function GLDG:GetMessagesNamespace()
	return self.db_messages
end

-- Get cleanup namespace
function GLDG:GetCleanupNamespace()
	return self.db_cleanup
end

-- Get UI namespace
function GLDG:GetUINamespace()
	return self.db_ui
end

-- Get cache namespace
function GLDG:GetCacheNamespace()
	return self.db_cache
end

-- Safe getter for setting values
function GLDG:GetSetting(key, default)
	local ns = self:GetSettingsNamespace()
	if not ns then return default end
	
	local value = ns.profile[key]
	return value ~= nil and value or default
end

-- Safe setter for setting values
function GLDG:SetSetting(key, value)
	local ns = self:GetSettingsNamespace()
	if ns then
		ns.profile[key] = value
	end
end

-- Get player data
function GLDG:GetPlayerData(playerName)
	local ns = self:GetPlayerManagerNamespace()
	if not ns or not ns.char or not ns.char.GuildMembers then
		return nil
	end
	
	return ns.char.GuildMembers[playerName]
end

-- Set player data
function GLDG:SetPlayerData(playerName, data)
	local ns = self:GetPlayerManagerNamespace()
	if not ns or not ns.char then return end
	
	if not ns.char.GuildMembers then
		ns.char.GuildMembers = {}
	end
	
	ns.char.GuildMembers[playerName] = data
end

-- Get all greetings
function GLDG:GetAllGreetings()
	local ns = self:GetGreetingsNamespace()
	if not ns or not ns.global then
		return {}
	end
	
	return ns.global.Greetings or {}
end

-- Get specific greeting
function GLDG:GetGreeting(id)
	local greetings = self:GetAllGreetings()
	return greetings[id]
end

-- Add greeting
function GLDG:AddGreeting(greeting)
	local ns = self:GetGreetingsNamespace()
	if not ns or not ns.global then return false end
	
	if not ns.global.Greetings then
		ns.global.Greetings = {}
	end
	
	table.insert(ns.global.Greetings, greeting)
	return true
end

-- Update greeting
function GLDG:UpdateGreeting(id, greeting)
	local ns = self:GetGreetingsNamespace()
	if not ns or not ns.global or not ns.global.Greetings then
		return false
	end
	
	if ns.global.Greetings[id] then
		ns.global.Greetings[id] = greeting
		return true
	end
	
	return false
end

-- Delete greeting
function GLDG:DeleteGreeting(id)
	local ns = self:GetGreetingsNamespace()
	if not ns or not ns.global or not ns.global.Greetings then
		return false
	end
	
	if ns.global.Greetings[id] then
		table.remove(ns.global.Greetings, id)
		return true
	end
	
	return false
end

-- Add message to queue
function GLDG:QueueMessage(message)
	local ns = self:GetMessagesNamespace()
	if not ns or not ns.realm then return false end
	
	if not ns.realm.MessageQueue then
		ns.realm.MessageQueue = {}
	end
	
	table.insert(ns.realm.MessageQueue, {
		content = message,
		timestamp = time(),
		sent = false
	})
	
	return true
end

-- Get queued messages
function GLDG:GetQueuedMessages()
	local ns = self:GetMessagesNamespace()
	if not ns or not ns.realm or not ns.realm.MessageQueue then
		return {}
	end
	
	return ns.realm.MessageQueue
end

-- Clear message queue
function GLDG:ClearMessageQueue()
	local ns = self:GetMessagesNamespace()
	if ns and ns.realm then
		ns.realm.MessageQueue = {}
	end
end

-- Get cleanup settings
function GLDG:GetCleanupSettings()
	local ns = self:GetCleanupNamespace()
	if not ns or not ns.profile then
		return {}
	end
	
	return ns.profile
end

-- Update cleanup timestamp
function GLDG:UpdateCleanupTime()
	local ns = self:GetCleanupNamespace()
	if ns and ns.profile then
		ns.profile.LastCleanupTime = time()
	end
end

-- Get UI state
function GLDG:GetUIState()
	local ns = self:GetUINamespace()
	if not ns or not ns.profile then
		return {}
	end
	
	return ns.profile
end

-- Save window position
function GLDG:SaveWindowPosition(windowName, position)
	local ns = self:GetUINamespace()
	if ns and ns.profile then
		if not ns.profile.WindowPosition then
			ns.profile.WindowPosition = {}
		end
		ns.profile.WindowPosition[windowName] = position
	end
end

-- Get window position
function GLDG:GetWindowPosition(windowName)
	local ns = self:GetUINamespace()
	if ns and ns.profile and ns.profile.WindowPosition then
		return ns.profile.WindowPosition[windowName]
	end
	return nil
end

-- Get namespace statistics
function GLDG:GetNamespaceStats()
	return {
		settings = {
			size = self:GetTableSize(self.db_settings and self.db_settings.profile or {})
		},
		players = {
			size = self:GetTableSize(self.db_players and self.db_players.char and self.db_players.char.GuildMembers or {}),
			count = self.db_players and self.db_players.char and #self.db_players.char.GuildMembers or 0
		},
		greetings = {
			size = self:GetTableSize(self.db_greetings and self.db_greetings.global and self.db_greetings.global.Greetings or {}),
			count = self.db_greetings and self.db_greetings.global and #self.db_greetings.global.Greetings or 0
		},
		messages = {
			queued = self.db_messages and self.db_messages.realm and #self.db_messages.realm.MessageQueue or 0
		}
	}
end

-- Helper to count table size
function GLDG:GetTableSize(tbl)
	local count = 0
	for _ in pairs(tbl) do count = count + 1 end
	return count
end

-- Reset all namespaces to defaults
function GLDG:ResetAllNamespaces()
	if self.db_settings then self.db_settings:ResetProfile() end
	if self.db_players then self.db_players:ResetProfile() end
	if self.db_greetings then self.db_greetings:ResetProfile() end
	if self.db_messages then self.db_messages:ResetProfile() end
	if self.db_cleanup then self.db_cleanup:ResetProfile() end
	if self.db_ui then self.db_ui:ResetProfile() end
	if self.db_cache then self.db_cache:ResetProfile() end
end
