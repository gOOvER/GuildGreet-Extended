--[[
GuildGreet-Serializer.lua - AceSerializer-3.0 Integration
Provides data serialization and deserialization for backups and data exchange
]]--

local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet", true) or LibStub("AceAddon-3.0"):NewAddon("GuildGreet", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", false)

-- Initialize Serializer module
function GLDG:InitializeSerializer()
	if not LibStub("AceSerializer-3.0", true) then
		return -- AceSerializer not available
	end
	
	self.Serializer = LibStub("AceSerializer-3.0")
	self.SerializerReady = true
end

-- Export database to serialized string
function GLDG:ExportData(scope)
	if not self.SerializerReady or not self.Serializer then
		return nil, "Serializer not available"
	end
	
	scope = scope or "profile"
	
	local data
	if scope == "profile" then
		data = self.db.profile
	elseif scope == "char" then
		data = self.db.char
	elseif scope == "realm" then
		data = self.db.realm
	elseif scope == "global" then
		data = self.db.global
	elseif scope == "all" then
		data = {
			profile = self.db.profile,
			char = self.db.char,
			realm = self.db.realm,
			global = self.db.global,
			timestamp = time(),
			version = GLDG_GetAddOnMetadata("GuildGreet", "Version")
		}
	else
		return nil, "Invalid scope: " .. tostring(scope)
	end
	
	if not data then
		return nil, "No data to export"
	end
	
	local success, serialized = self.Serializer:Serialize(data)
	if not success then
		return nil, "Serialization failed"
	end
	
	return serialized
end

-- Import serialized data
function GLDG:ImportData(serialized, scope, merge)
	if not self.SerializerReady or not self.Serializer then
		return false, "Serializer not available"
	end
	
	if not serialized or serialized == "" then
		return false, "No data to import"
	end
	
	scope = scope or "profile"
	merge = merge or false
	
	local success, data = self.Serializer:Deserialize(serialized)
	if not success then
		return false, "Deserialization failed"
	end
	
	-- Validate imported data
	if not data or type(data) ~= "table" then
		return false, "Invalid data format"
	end
	
	-- Import to appropriate scope
	if scope == "profile" then
		if merge then
			self:MergeTable(self.db.profile, data)
		else
			self.db.profile = data
		end
	elseif scope == "char" then
		if merge then
			self:MergeTable(self.db.char, data)
		else
			self.db.char = data
		end
	elseif scope == "realm" then
		if merge then
			self:MergeTable(self.db.realm, data)
		else
			self.db.realm = data
		end
	elseif scope == "global" then
		if merge then
			self:MergeTable(self.db.global, data)
		else
			self.db.global = data
		end
	else
		return false, "Invalid scope: " .. tostring(scope)
	end
	
	return true, "Data imported successfully"
end

-- Create backup of all data
function GLDG:CreateBackup()
	if not self.SerializerReady or not self.Serializer then
		return nil, "Serializer not available"
	end
	
	local backup = {
		profile = self.db.profile,
		char = self.db.char,
		realm = self.db.realm,
		global = self.db.global,
		timestamp = time(),
		version = GLDG_GetAddOnMetadata("GuildGreet", "Version"),
		character = GetUnitName("player", false),
		realm = GetRealmName()
	}
	
	local success, serialized = self.Serializer:Serialize(backup)
	if not success then
		return nil, "Backup serialization failed"
	end
	
	return serialized
end

-- Restore from backup
function GLDG:RestoreBackup(backupData)
	if not self.SerializerReady or not self.Serializer then
		return false, "Serializer not available"
	end
	
	if not backupData or backupData == "" then
		return false, "No backup data provided"
	end
	
	local success, backup = self.Serializer:Deserialize(backupData)
	if not success then
		return false, "Backup deserialization failed"
	end
	
	if not backup or type(backup) ~= "table" then
		return false, "Invalid backup format"
	end
	
	-- Restore each scope
	if backup.profile then
		self.db.profile = backup.profile
	end
	if backup.char then
		self.db.char = backup.char
	end
	if backup.realm then
		self.db.realm = backup.realm
	end
	if backup.global then
		self.db.global = backup.global
	end
	
	return true, "Backup restored successfully"
end

-- Merge table helper (for partial imports)
function GLDG:MergeTable(target, source)
	if not source then return end
	
	for key, value in pairs(source) do
		if type(value) == "table" and type(target[key]) == "table" then
			self:MergeTable(target[key], value)
		else
			target[key] = value
		end
	end
end

-- Get statistics about serialized data
function GLDG:GetSerializationStats(serialized)
	if not serialized then
		return nil
	end
	
	return {
		size = string.len(serialized),
		formatted_size = string.format("%.2f KB", string.len(serialized) / 1024)
	}
end
