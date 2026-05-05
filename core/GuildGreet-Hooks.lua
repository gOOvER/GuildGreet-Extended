--[[
GuildGreet-Hooks.lua - AceHook-3.0 Integration
Provides secure hooks for Blizzard functions and addon interoperability
]]--

local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet", true) or LibStub("AceAddon-3.0"):NewAddon("GuildGreet", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", false)

-- Initialize Hooks module
function GLDG:InitializeHooks()
	if not self:IsHookingEnabled() then return end
	
	-- Hook roster functions
	self:SetupRosterHooks()
	
	-- Hook player interaction functions
	self:SetupPlayerHooks()
	
	-- Hook guild functions
	self:SetupGuildHooks()
	
	-- Hook communication functions
	self:SetupCommunicationHooks()
	
	self.HooksReady = true
end

-- Check if hooking should be enabled
function GLDG:IsHookingEnabled()
	return LibStub("AceHook-3.0", true) ~= nil
end

-- Setup roster-related hooks
function GLDG:SetupRosterHooks()
	-- Hook GuildRoster_Update to track roster changes
	self:SecureHook("GuildRoster_Update", function()
		if GLDG:IsRosterUpdateEnabled() then
			GLDG:OnGuildRosterUpdated()
		end
	end)
	
	-- Hook GuildRoster_SetSelection for player selection
	if GuildRoster_SetSelection then
		self:SecureHook("GuildRoster_SetSelection", function(index)
			if GLDG:IsPlayerSelectionEnabled() then
				GLDG:OnPlayerSelected(index)
			end
		end)
	end
end

-- Setup player interaction hooks
function GLDG:SetupPlayerHooks()
	-- Hook SetItemRef for chat links
	if SetItemRef then
		self:SecureHook("SetItemRef", function(link, text, button)
			if string.find(link, "player:") then
				GLDG:OnPlayerLinkClicked(link, text, button)
			end
		end)
	end
	
	-- Hook ChatFrame_OpenChat to detect player mentions
	if ChatFrame_OpenChat then
		self:SecureHook("ChatFrame_OpenChat", function(text)
			if GLDG:ShouldMonitorChat() then
				GLDG:OnChatInput(text)
			end
		end)
	end
end

-- Setup guild-related hooks
function GLDG:SetupGuildHooks()
	-- Hook GuildMemberStatus_Update for member status changes
	if GuildMemberStatus_Update then
		self:SecureHook("GuildMemberStatus_Update", function()
			if GLDG:IsStatusMonitoringEnabled() then
				GLDG:OnGuildMemberStatusUpdated()
			end
		end)
	end
	
	-- Hook GuildFrame_OnShow to track guild UI visibility
	if GuildFrame_OnShow then
		self:SecureHook("GuildFrame_OnShow", function()
			GLDG:OnGuildFrameOpened()
		end)
	end
	
	-- Hook GuildFrame_OnHide to track guild UI visibility
	if GuildFrame_OnHide then
		self:SecureHook("GuildFrame_OnHide", function()
			GLDG:OnGuildFrameClosed()
		end)
	end
end

-- Setup communication hooks
function GLDG:SetupCommunicationHooks()
	-- Hook SendChatMessage for outgoing messages
	if SendChatMessage then
		self:SecureHook("SendChatMessage", function(text, chatType, language, channel)
			if chatType == "GUILD" and GLDG:ShouldTrackOutgoingMessages() then
				GLDG:OnOutgoingGuildMessage(text)
			end
		end)
	end
end

-- Roster update callback
function GLDG:OnGuildRosterUpdated()
	if not self.db.profile.AutoWho then return end
	
	-- Update player information
	local numGuildMembers = GetNumGuildMembers()
	if numGuildMembers > 0 and self.RosterImportFull then
		-- Async roster import
		self:ScheduleTimer(function()
			if self.RosterImportFull then
				self.RosterImportFull()
			end
		end, 1)
	end
end

-- Player roster selection callback
function GLDG:OnPlayerSelected(index)
	local name, rank, rankIndex, level, class, zone, note, officerNote, isOnline, status, classFileName = GetGuildRosterInfo(index)
	if name then
		-- Store player interaction
		if self.db.profile.TrackInteractions then
			if not self.db.char.RecentInteractions then
				self.db.char.RecentInteractions = {}
			end
			self.db.char.RecentInteractions[name] = time()
		end
	end
end

-- Player link clicked callback
function GLDG:OnPlayerLinkClicked(link, text, button)
	-- Extract player name from link
	local playerName = string.match(link, "player:.-:(.*)")
	if playerName and button == "LeftButton" then
		-- Check if we should greet this player
		if self.db.profile.EnableContextMenu then
			self:TriggerGreeting(playerName)
		end
	end
end

-- Chat input monitoring
function GLDG:OnChatInput(text)
	-- Monitor for player mentions in chat
	if self.db.profile.BigBrother then
		for playerName in text:gmatch("@(%S+)") do
			self:OnPlayerMentioned(playerName)
		end
	end
end

-- Guild member status update callback
function GLDG:OnGuildMemberStatusUpdated()
	-- Handle player login/logout
	if self.db.profile.ListUp or self.db.profile.BigBrother then
		-- Schedule async update
		self:ScheduleTimer(function()
			if self.UpdateMemberList then
				self.UpdateMemberList()
			end
		end, 0.5)
	end
end

-- Guild frame opened callback
function GLDG:OnGuildFrameOpened()
	-- Auto-update roster when guild window opens
	if self.db.profile.AutoWho and self.db.profile.AutoUpdateOnGuildOpen then
		self:ScheduleTimer(function()
			GuildRoster_Update()
		end, 0.1)
	end
end

-- Guild frame closed callback
function GLDG:OnGuildFrameClosed()
	-- Save roster state
	self.db.char.GuildFrameLastClosed = time()
end

-- Outgoing guild message callback
function GLDG:OnOutgoingGuildMessage(text)
	-- Track message send time for rate limiting
	if not self.db.char.LastGuildMessageTime then
		self.db.char.LastGuildMessageTime = {}
	end
	self.db.char.LastGuildMessageTime[GetUnitName("player", false)] = time()
end

-- Player mentioned in chat callback
function GLDG:OnPlayerMentioned(playerName)
	-- Record player mention
	if not self.db.char.PlayerMentions then
		self.db.char.PlayerMentions = {}
	end
	if not self.db.char.PlayerMentions[playerName] then
		self.db.char.PlayerMentions[playerName] = 0
	end
	self.db.char.PlayerMentions[playerName] = self.db.char.PlayerMentions[playerName] + 1
end

-- Trigger greeting for player
function GLDG:TriggerGreeting(playerName)
	if self.GreetGuild then
		self.GreetGuild(playerName)
	end
end

-- Configuration flags
function GLDG:IsRosterUpdateEnabled()
	return self.db and self.db.profile and self.db.profile.AutoWho or false
end

function GLDG:IsPlayerSelectionEnabled()
	return self.db and self.db.profile and self.db.profile.TrackInteractions or false
end

function GLDG:ShouldMonitorChat()
	return self.db and self.db.profile and self.db.profile.BigBrother or false
end

function GLDG:IsStatusMonitoringEnabled()
	return self.db and self.db.profile and (self.db.profile.ListUp or self.db.profile.BigBrother) or false
end

function GLDG:ShouldTrackOutgoingMessages()
	return self.db and self.db.profile and self.db.profile.TrackMessages or false
end

-- Cleanup hooks on unload
function GLDG:CleanupHooks()
	if self.HooksReady then
		self:UnhookAll()
		self.HooksReady = false
	end
end
