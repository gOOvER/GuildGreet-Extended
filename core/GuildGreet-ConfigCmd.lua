--[[
GuildGreet-ConfigCmd.lua - AceConfigCmd-3.0 Integration
Provides slash command interface for configuration management
]]--

local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet", true) or LibStub("AceAddon-3.0"):NewAddon("GuildGreet", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", true)

-- Initialize ConfigCmd module
function GLDG:InitializeConfigCmd()
	if self.RegisterSlashCommands then
		self:RegisterSlashCommands()
	end
end

-- Main slash command handler (delegates to unified GLDG:SlashHandler)
function GLDG:HandleSlashCommand(input)
	if self.SlashHandler then
		return self:SlashHandler(input)
	end
end

-- Display help information
function GLDG:ShowHelp()
	self:Print("=== GuildGreet Commands ===")
	self:Print("/gg - Open settings")
	self:Print("/gg config - Open configuration")
	self:Print("/gg import - Import guild roster")
	self:Print("/gg about - Show about information")
	self:Print("/gg status - Show status information")
	self:Print("/gg reset - Reset to defaults")
	self:Print("/gghelp - Show this help")
end

-- Show about information
function GLDG:ShowAbout()
	local version = GLDG_GetAddOnMetadata("GuildGreet", "Version")
	self:Print("=== GuildGreet-Extended ===")
	self:Print("Version: " .. (version or "Unknown"))
	self:Print("Advanced guild greeting system")
	self:Print("Author: gOOvER")
	self:Print("Website: https://www.goover.dev")
end

-- Show status information
function GLDG:ShowStatus()
	if not self.db then
		self:Print("Database not initialized")
		return
	end
	
	self:Print("=== GuildGreet Status ===")
	
	-- Check if enabled
	local enabled = self.db.profile.Enabled or true
	self:Print("Status: " .. (enabled and "✓ Enabled" or "✗ Disabled"))
	
	-- Show guild count
	if self.db.profile.GuildSettings then
		local count = 0
		for _ in pairs(self.db.profile.GuildSettings) do
			count = count + 1
		end
		self:Print("Configured guilds: " .. count)
	end
	
	-- Show player count
	if self.db.char and self.db.char.GuildMembers then
		local count = 0
		for _ in pairs(self.db.char.GuildMembers) do
			count = count + 1
		end
		self:Print("Tracked players: " .. count)
	end
	
	-- Show queue status
	if self.Queue and #self.Queue > 0 then
		self:Print("Messages in queue: " .. #self.Queue)
	else
		self:Print("Message queue: empty")
	end
end

-- Reset configuration to defaults
function GLDG:ResetConfig()
	self:Print("Resetting configuration to defaults...")
	if self.db then
		self.db:ResetProfile()
		self:Print("Configuration reset complete")
	end
end

-- Helper: Get arguments from string
function GLDG:GetArgs(str, numArgs)
	if not str or str == "" then
		return
	end
	
	local args = {}
	for word in str:gmatch("%S+") do
		table.insert(args, word)
		if #args == numArgs then
			break
		end
	end
	
	return unpack(args)
end

-- Create slash command entry point
GLDG_SlashCommandInit = function()
	if GLDG.InitializeConfigCmd then
		GLDG:InitializeConfigCmd()
	end
end
