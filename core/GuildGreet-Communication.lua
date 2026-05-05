--[[
GuildGreet-Communication.lua - AceComm-3.0 Integration
Provides inter-addon communication for guild synchronization and data sharing
]]--

local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet", true) or LibStub("AceAddon-3.0"):NewAddon("GuildGreet", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", false)

-- Initialize Communication module
function GLDG:InitializeCommunication()
	if not LibStub("AceComm-3.0", true) then
		return -- AceComm not available
	end
	
	self.Comm = LibStub("AceComm-3.0")
	self.CommReady = true
	
	-- Register communication handlers
	self:RegisterComm("GG", "OnCommReceived")
	self:RegisterComm("GGDATA", "OnDataCommReceived")
	
	-- Initialize communication queues
	self.CommIncoming = {}
	self.CommOutgoing = {}
	
	-- Broadcast presence on load
	self:ScheduleTimer(function()
		self:BroadcastPresence()
	end, 2)
end

-- Send simple message to guild
function GLDG:SendGuildMessage(message, priority)
	if not self.CommReady or not self.Comm then
		return false
	end
	
	priority = priority or "NORMAL"
	
	local msgData = {
		type = "MESSAGE",
		sender = UnitName("player"),
		realm = GetRealmName(),
		timestamp = time(),
		content = message,
		priority = priority
	}
	
	local success = self.Comm:SendCommMessage("GG", self:SerializeMessage(msgData), "GUILD")
	if success then
		table.insert(self.CommOutgoing, msgData)
		-- Keep only last 100 messages
		if #self.CommOutgoing > 100 then
			table.remove(self.CommOutgoing, 1)
		end
	end
	
	return success
end

-- Send player data to guild members
function GLDG:SyncPlayerData(targetPlayer)
	if not self.CommReady or not self.Comm then
		return false
	end
	
	local playerData = {
		type = "SYNC",
		sender = UnitName("player"),
		realm = GetRealmName(),
		timestamp = time(),
		players = self.db.char.GuildMembers or {},
		settings = {
			GreetingsEnabled = self.db.profile.Enabled,
			WhisperGreet = self.db.profile.Whisper
		}
	}
	
	if targetPlayer then
		-- Send to specific player (requires target to be online)
		return self.Comm:SendCommMessage("GGDATA", self:SerializeMessage(playerData), "WHISPER", targetPlayer)
	else
		-- Broadcast to all guild members
		return self.Comm:SendCommMessage("GGDATA", self:SerializeMessage(playerData), "GUILD")
	end
end

-- Request data from guild members
function GLDG:RequestData(dataType, targetPlayer)
	if not self.CommReady or not self.Comm then
		return false
	end
	
	local request = {
		type = "REQUEST",
		sender = UnitName("player"),
		realm = GetRealmName(),
		timestamp = time(),
		requestType = dataType
	}
	
	if targetPlayer then
		return self.Comm:SendCommMessage("GGDATA", self:SerializeMessage(request), "WHISPER", targetPlayer)
	else
		return self.Comm:SendCommMessage("GGDATA", self:SerializeMessage(request), "GUILD")
	end
end

-- Broadcast presence to detect other GuildGreet users
function GLDG:BroadcastPresence()
	if not self.CommReady or not self.Comm then
		return false
	end
	
	local presence = {
		type = "PRESENCE",
		sender = UnitName("player"),
		realm = GetRealmName(),
		timestamp = time(),
		version = GLDG_GetAddOnMetadata("GuildGreet", "Version"),
		features = {
			ConfigCmd = true,
			Serialization = true,
			Communication = true,
			Hooks = true
		}
	}
	
	return self.Comm:SendCommMessage("GG", self:SerializeMessage(presence), "GUILD")
end

-- Handle incoming communications
function GLDG:OnCommReceived(prefix, message, distribution, sender)
	if prefix ~= "GG" then return end
	
	local success, data = self:DeserializeMessage(message)
	if not success or not data then
		self:DebugPrint("Failed to deserialize message from " .. sender)
		return
	end
	
	-- Ignore own messages
	if data.sender == UnitName("player") and data.realm == GetRealmName() then
		return
	end
	
	-- Store incoming message
	table.insert(self.CommIncoming, data)
	if #self.CommIncoming > 100 then
		table.remove(self.CommIncoming, 1)
	end
	
	-- Handle different message types
	if data.type == "MESSAGE" then
		self:HandleIncomingMessage(data)
	elseif data.type == "PRESENCE" then
		self:HandlePresenceNotification(data)
	end
end

-- Handle incoming data communications
function GLDG:OnDataCommReceived(prefix, message, distribution, sender)
	if prefix ~= "GGDATA" then return end
	
	local success, data = self:DeserializeMessage(message)
	if not success or not data then
		self:DebugPrint("Failed to deserialize data from " .. sender)
		return
	end
	
	-- Ignore own messages
	if data.sender == UnitName("player") and data.realm == GetRealmName() then
		return
	end
	
	-- Handle different data types
	if data.type == "SYNC" then
		self:HandleDataSync(data, sender)
	elseif data.type == "REQUEST" then
		self:HandleDataRequest(data, sender)
	end
end

-- Handle incoming message
function GLDG:HandleIncomingMessage(data)
	if data.priority == "HIGH" then
		self:Print("[GuildGreet] Message from " .. data.sender .. ": " .. data.content)
	end
end

-- Handle presence notification
function GLDG:HandlePresenceNotification(data)
	if not self.db.char.DetectedAddons then
		self.db.char.DetectedAddons = {}
	end
	
	self.db.char.DetectedAddons[data.sender] = {
		timestamp = data.timestamp,
		version = data.version,
		features = data.features
	}
end

-- Handle data synchronization
function GLDG:HandleDataSync(data, sender)
	if not self.db.profile.EnableSync then
		return
	end
	
	-- Merge player data if available
	if data.players then
		if not self.db.char.SyncedPlayers then
			self.db.char.SyncedPlayers = {}
		end
		
		for playerName, playerData in pairs(data.players) do
			self.db.char.SyncedPlayers[playerName] = {
				data = playerData,
				syncedFrom = sender,
				syncTime = data.timestamp
			}
		end
	end
end

-- Handle data request
function GLDG:HandleDataRequest(data, sender)
	if data.requestType == "PLAYERS" then
		self:SyncPlayerData(sender)
	elseif data.requestType == "SETTINGS" then
		self:SendSettingsData(sender)
	end
end

-- Send settings to a player
function GLDG:SendSettingsData(targetPlayer)
	if not self.CommReady or not self.Comm then
		return false
	end
	
	local settingsData = {
		type = "SETTINGS",
		sender = UnitName("player"),
		realm = GetRealmName(),
		timestamp = time(),
		greetings = self.db.global.Greetings or {},
		guildSettings = self.db.profile.GuildSettings or {}
	}
	
	return self.Comm:SendCommMessage("GGDATA", self:SerializeMessage(settingsData), "WHISPER", targetPlayer)
end

-- Serialize message data using AceSerializer
function GLDG:SerializeMessage(data)
	if not data then return "" end
	
	-- Simple JSON-like serialization for AceComm compatibility
	-- This is intentionally simple to avoid size issues
	local serialized = ""
	for key, value in pairs(data) do
		if type(value) == "string" then
			serialized = serialized .. key .. "=" .. string.gsub(value, "\\", "\\\\") .. ";"
		elseif type(value) == "number" or type(value) == "boolean" then
			serialized = serialized .. key .. "=" .. tostring(value) .. ";"
		end
	end
	return serialized
end

-- Deserialize message data
function GLDG:DeserializeMessage(serialized)
	if not serialized or serialized == "" then
		return false
	end
	
	local data = {}
	for pair in string.gmatch(serialized, "[^;]+") do
		local key, value = string.match(pair, "([^=]+)=(.+)")
		if key and value then
			data[key] = value
		end
	end
	
	return true, data
end

-- Get list of detected GuildGreet users
function GLDG:GetDetectedUsers()
	if not self.db.char.DetectedAddons then
		return {}
	end
	
	local users = {}
	for playerName, info in pairs(self.db.char.DetectedAddons) do
		table.insert(users, {
			name = playerName,
			version = info.version,
			features = info.features,
			lastSeen = info.timestamp
		})
	end
	
	return users
end

-- Get communication statistics
function GLDG:GetCommStats()
	return {
		incoming = #self.CommIncoming,
		outgoing = #self.CommOutgoing,
		detectedUsers = self.db.char.DetectedAddons and (function()
			local count = 0
			for _ in pairs(self.db.char.DetectedAddons) do count = count + 1 end
			return count
		end)() or 0
	}
end

-- Debug print helper
function GLDG:DebugPrint(msg)
	if self.db and self.db.profile and self.db.profile.DebugMode then
		self:Print("[DEBUG] " .. msg)
	end
end

-- Cleanup communication on unload
function GLDG:CleanupCommunication()
	if self.CommReady then
		self.CommIncoming = {}
		self.CommOutgoing = {}
		self.CommReady = false
	end
end
