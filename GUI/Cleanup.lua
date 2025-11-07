--[[
	GuildGreet Cleanup GUI Module
	Handles the Cleanup tab interface
]]--

local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", false)

local CleanupGUI = GLDG:NewModule("CleanupGUI")

-- Current state
CleanupGUI.cleanupData = {}

--[[
	Create the Cleanup tab content
]]
function CleanupGUI:CreateTabContent(container)
	-- Main scroll frame
	local scrollFrame = AceGUI:Create("ScrollFrame")
	scrollFrame:SetFullWidth(true)
	scrollFrame:SetFullHeight(true)
	scrollFrame:SetLayout("Flow")
	
	-- Information section
	local infoGroup = AceGUI:Create("InlineGroup")
	infoGroup:SetTitle(L["Information"] or "Information")
	infoGroup:SetFullWidth(true)
	infoGroup:SetHeight(100)
	infoGroup:SetLayout("Flow")
	
	local infoText = AceGUI:Create("Label")
	infoText:SetText(L["This section helps you clean up outdated player data and greeting statistics. Use these tools to maintain your GuildGreet database."] or "This section helps you clean up outdated player data and greeting statistics. Use these tools to maintain your GuildGreet database.")
	infoText:SetFullWidth(true)
	infoGroup:AddChild(infoText)
	
	scrollFrame:AddChild(infoGroup)
	
	-- Player Data Cleanup
	local playerGroup = AceGUI:Create("InlineGroup")
	playerGroup:SetTitle(L["Player Data Cleanup"] or "Player Data Cleanup")
	playerGroup:SetFullWidth(true)
	playerGroup:SetHeight(200)
	playerGroup:SetLayout("Flow")
	
	-- Remove offline players
	local removeOfflineBtn = AceGUI:Create("Button")
	removeOfflineBtn:SetText(L["Remove players offline > 30 days"] or "Remove players offline > 30 days")
	removeOfflineBtn:SetWidth(250)
	removeOfflineBtn:SetCallback("OnClick", function()
		self:RemoveOfflinePlayers(30)
	end)
	playerGroup:AddChild(removeOfflineBtn)
	
	-- Remove non-guild members
	local removeNonGuildBtn = AceGUI:Create("Button")
	removeNonGuildBtn:SetText(L["Remove non-guild members"] or "Remove non-guild members")
	removeNonGuildBtn:SetWidth(250)
	removeNonGuildBtn:SetCallback("OnClick", function()
		self:RemoveNonGuildMembers()
	end)
	playerGroup:AddChild(removeNonGuildBtn)
	
	-- Reset greeting stats
	local resetStatsBtn = AceGUI:Create("Button")
	resetStatsBtn:SetText(L["Reset greeting statistics"] or "Reset greeting statistics")
	resetStatsBtn:SetWidth(250)
	resetStatsBtn:SetCallback("OnClick", function()
		self:ResetGreetingStats()
	end)
	playerGroup:AddChild(resetStatsBtn)
	
	-- Show cleanup candidates
	local showCandidatesBtn = AceGUI:Create("Button")
	showCandidatesBtn:SetText(L["Show cleanup candidates"] or "Show cleanup candidates")
	showCandidatesBtn:SetWidth(250)
	showCandidatesBtn:SetCallback("OnClick", function()
		self:ShowCleanupCandidates()
	end)
	playerGroup:AddChild(showCandidatesBtn)
	
	scrollFrame:AddChild(playerGroup)
	
	-- Database Maintenance
	local dbGroup = AceGUI:Create("InlineGroup")
	dbGroup:SetTitle(L["Database Maintenance"] or "Database Maintenance")
	dbGroup:SetFullWidth(true)
	dbGroup:SetHeight(150)
	dbGroup:SetLayout("Flow")
	
	-- Compact database
	local compactBtn = AceGUI:Create("Button")
	compactBtn:SetText(L["Compact database"] or "Compact database")
	compactBtn:SetWidth(200)
	compactBtn:SetCallback("OnClick", function()
		self:CompactDatabase()
	end)
	dbGroup:AddChild(compactBtn)
	
	-- Export settings
	local exportBtn = AceGUI:Create("Button")
	exportBtn:SetText(L["Export settings"] or "Export settings")
	exportBtn:SetWidth(200)
	exportBtn:SetCallback("OnClick", function()
		self:ExportSettings()
	end)
	dbGroup:AddChild(exportBtn)
	
	-- Import settings
	local importBtn = AceGUI:Create("Button")
	importBtn:SetText(L["Import settings"] or "Import settings")
	importBtn:SetWidth(200)
	importBtn:SetCallback("OnClick", function()
		self:ImportSettings()
	end)
	dbGroup:AddChild(importBtn)
	
	scrollFrame:AddChild(dbGroup)
	
	-- Cleanup Results
	local resultsGroup = AceGUI:Create("InlineGroup")
	resultsGroup:SetTitle(L["Cleanup Results"] or "Cleanup Results")
	resultsGroup:SetFullWidth(true)
	resultsGroup:SetRelativeHeight(0.4)
	resultsGroup:SetLayout("Fill")
	
	local resultsFrame = AceGUI:Create("ScrollFrame")
	resultsFrame:SetFullWidth(true)
	resultsFrame:SetFullHeight(true)
	resultsFrame:SetLayout("List")
	resultsGroup:AddChild(resultsFrame)
	
	scrollFrame:AddChild(resultsGroup)
	container:AddChild(scrollFrame)
	
	-- Store references
	self.resultsFrame = resultsFrame
	
	-- Load initial data
	self:UpdateCleanupInfo()
end

--[[
	Remove players offline for more than specified days
]]
function CleanupGUI:RemoveOfflinePlayers(days)
	local cutoffTime = time() - (days * 24 * 60 * 60)
	local removedCount = 0
	local removedPlayers = {}
	
	if GLDG_DataChar then
		for playerName, playerData in pairs(GLDG_DataChar) do
			local lastSeen = playerData.lastseen or 0
			if lastSeen > 0 and lastSeen < cutoffTime then
				-- Check if player is still in guild
				local inGuild = false
				if IsInGuild() then
					local numMembers = GetNumGuildMembers()
					for i = 1, numMembers do
						local name = GetGuildRosterInfo(i)
						if name == playerName then
							inGuild = true
							break
						end
					end
				end
				
				if not inGuild then
					table.insert(removedPlayers, {name = playerName, lastSeen = lastSeen})
					GLDG_DataChar[playerName] = nil
					removedCount = removedCount + 1
				end
			end
		end
	end
	
	-- Show results
	self:ShowCleanupResults(string.format(L["Removed %d players offline > %d days"] or "Removed %d players offline > %d days", removedCount, days), removedPlayers)
	
	GLDG:Print(string.format(L["Cleanup complete: Removed %d players"] or "Cleanup complete: Removed %d players", removedCount))
end

--[[
	Remove players who are no longer guild members
]]
function CleanupGUI:RemoveNonGuildMembers()
	if not IsInGuild() or not GLDG_DataChar then
		GLDG:Print(L["Not in guild or no player data"] or "Not in guild or no player data")
		return
	end
	
	-- Get current guild members
	local guildMembers = {}
	local numMembers = GetNumGuildMembers()
	for i = 1, numMembers do
		local name = GetGuildRosterInfo(i)
		if name then
			guildMembers[name] = true
		end
	end
	
	-- Remove non-guild members
	local removedCount = 0
	local removedPlayers = {}
	
	for playerName, playerData in pairs(GLDG_DataChar) do
		if not guildMembers[playerName] then
			table.insert(removedPlayers, {name = playerName})
			GLDG_DataChar[playerName] = nil
			removedCount = removedCount + 1
		end
	end
	
	-- Show results
	self:ShowCleanupResults(string.format(L["Removed %d non-guild members"] or "Removed %d non-guild members", removedCount), removedPlayers)
	
	GLDG:Print(string.format(L["Cleanup complete: Removed %d non-guild members"] or "Cleanup complete: Removed %d non-guild members", removedCount))
end

--[[
	Reset greeting statistics
]]
function CleanupGUI:ResetGreetingStats()
	local resetCount = 0
	
	if GLDG_DataChar then
		for playerName, playerData in pairs(GLDG_DataChar) do
			if playerData.greetcount or playerData.greettime or playerData.greeted then
				playerData.greetcount = nil
				playerData.greettime = nil
				playerData.greeted = nil
				resetCount = resetCount + 1
			end
		end
	end
	
	-- Clear queue and online tracking
	if GLDG_Queue then
		wipe(GLDG_Queue)
	end
	
	if GLDG_Online then
		wipe(GLDG_Online)
	end
	
	-- Show results
	self:ShowCleanupResults(string.format(L["Reset greeting statistics for %d players"] or "Reset greeting statistics for %d players", resetCount), {})
	
	GLDG:Print(string.format(L["Reset greeting statistics for %d players"] or "Reset greeting statistics for %d players", resetCount))
end

--[[
	Show cleanup candidates
]]
function CleanupGUI:ShowCleanupCandidates()
	local candidates = {}
	local cutoffTime = time() - (30 * 24 * 60 * 60) -- 30 days
	
	if GLDG_DataChar then
		for playerName, playerData in pairs(GLDG_DataChar) do
			local lastSeen = playerData.lastseen or 0
			if lastSeen > 0 and lastSeen < cutoffTime then
				-- Check if player is still in guild
				local inGuild = false
				if IsInGuild() then
					local numMembers = GetNumGuildMembers()
					for i = 1, numMembers do
						local name = GetGuildRosterInfo(i)
						if name == playerName then
							inGuild = true
							break
						end
					end
				end
				
				table.insert(candidates, {
					name = playerName, 
					lastSeen = lastSeen,
					inGuild = inGuild,
					reason = inGuild and "Offline > 30 days" or "Not in guild"
				})
			end
		end
	end
	
	-- Sort by last seen
	table.sort(candidates, function(a, b)
		return a.lastSeen < b.lastSeen
	end)
	
	self:ShowCleanupResults(string.format(L["Found %d cleanup candidates"] or "Found %d cleanup candidates", #candidates), candidates)
end

--[[
	Show cleanup results
]]
function CleanupGUI:ShowCleanupResults(title, data)
	if not self.resultsFrame then return end
	
	-- Clear current results
	self.resultsFrame:ReleaseChildren()
	
	-- Title
	local titleLabel = AceGUI:Create("Heading")
	titleLabel:SetText(title)
	titleLabel:SetFullWidth(true)
	self.resultsFrame:AddChild(titleLabel)
	
	-- Data entries
	for _, entry in ipairs(data) do
		local entryLabel = AceGUI:Create("Label")
		local text = entry.name
		
		if entry.lastSeen then
			text = text .. string.format(" (Last seen: %s)", date("%m/%d/%Y", entry.lastSeen))
		end
		
		if entry.reason then
			text = text .. " - " .. entry.reason
		end
		
		entryLabel:SetText(text)
		entryLabel:SetFullWidth(true)
		self.resultsFrame:AddChild(entryLabel)
	end
	
	if #data == 0 then
		local noDataLabel = AceGUI:Create("Label")
		noDataLabel:SetText(L["No data to display"] or "No data to display")
		noDataLabel:SetFullWidth(true)
		self.resultsFrame:AddChild(noDataLabel)
	end
end

--[[
	Compact database
]]
function CleanupGUI:CompactDatabase()
	local originalSize = 0
	local compactedSize = 0
	
	-- Calculate original size (approximate)
	if GLDG_Data then
		for k, v in pairs(GLDG_Data) do
			originalSize = originalSize + 1
		end
	end
	
	-- Remove empty tables and nil values
	if GLDG_DataChar then
		for playerName, playerData in pairs(GLDG_DataChar) do
			if type(playerData) == "table" then
				for key, value in pairs(playerData) do
					if value == nil or value == "" or (type(value) == "table" and next(value) == nil) then
						playerData[key] = nil
					end
				end
				
				-- Remove empty player entries
				if next(playerData) == nil then
					GLDG_DataChar[playerName] = nil
				else
					compactedSize = compactedSize + 1
				end
			end
		end
	end
	
	-- Force garbage collection
	collectgarbage("collect")
	
	self:ShowCleanupResults(string.format(L["Database compacted: %d -> %d entries"] or "Database compacted: %d -> %d entries", originalSize, compactedSize), {})
	
	GLDG:Print(L["Database compaction complete"] or "Database compaction complete")
end

--[[
	Export settings
]]
function CleanupGUI:ExportSettings()
	-- Create export dialog
	local dialog = AceGUI:Create("Window")
	dialog:SetTitle(L["Export Settings"] or "Export Settings")
	dialog:SetWidth(600)
	dialog:SetHeight(400)
	dialog:SetLayout("Flow")
	
	local exportText = AceGUI:Create("MultiLineEditBox")
	exportText:SetLabel(L["Copy this text to save your settings"] or "Copy this text to save your settings")
	exportText:SetFullWidth(true)
	exportText:SetHeight(300)
	
	-- Serialize settings
	local exportData = {
		GuildSettings = GLDG_Data.GuildSettings,
		GreetCollections = GLDG_Data.GreetCollections,
		colours = GLDG_Data.colours,
		MinLevel = GLDG_Data.MinLevel,
		MaxLevel = GLDG_Data.MaxLevel
	}
	
	local serialized = self:SerializeTable(exportData)
	exportText:SetText(serialized)
	
	dialog:AddChild(exportText)
	
	local closeBtn = AceGUI:Create("Button")
	closeBtn:SetText(L["Close"] or "Close")
	closeBtn:SetCallback("OnClick", function() dialog:Release() end)
	dialog:AddChild(closeBtn)
end

--[[
	Import settings
]]
function CleanupGUI:ImportSettings()
	-- Create import dialog
	local dialog = AceGUI:Create("Window")
	dialog:SetTitle(L["Import Settings"] or "Import Settings")
	dialog:SetWidth(600)
	dialog:SetHeight(400)
	dialog:SetLayout("Flow")
	
	local importText = AceGUI:Create("MultiLineEditBox")
	importText:SetLabel(L["Paste your settings text here"] or "Paste your settings text here")
	importText:SetFullWidth(true)
	importText:SetHeight(300)
	dialog:AddChild(importText)
	
	local importBtn = AceGUI:Create("Button")
	importBtn:SetText(L["Import"] or "Import")
	importBtn:SetCallback("OnClick", function()
		local text = importText:GetText()
		if self:ImportSettingsFromText(text) then
			GLDG:Print(L["Settings imported successfully"] or "Settings imported successfully")
			dialog:Release()
		else
			GLDG:Print(L["Failed to import settings"] or "Failed to import settings")
		end
	end)
	dialog:AddChild(importBtn)
	
	local closeBtn = AceGUI:Create("Button")
	closeBtn:SetText(L["Close"] or "Close")
	closeBtn:SetCallback("OnClick", function() dialog:Release() end)
	dialog:AddChild(closeBtn)
end

--[[
	Update cleanup info
]]
function CleanupGUI:UpdateCleanupInfo()
	-- This could show statistics about the current database
end

--[[
	Serialize table to string (simple implementation)
]]
function CleanupGUI:SerializeTable(tbl)
	-- Simple JSON-like serialization
	-- In a real implementation, you might use AceSerializer
	return "-- GuildGreet Settings Export\n-- " .. date() .. "\n\nlocal settings = " .. self:TableToString(tbl) .. "\n\nreturn settings"
end

--[[
	Convert table to string representation
]]
function CleanupGUI:TableToString(tbl, indent)
	indent = indent or 0
	local spacing = string.rep("  ", indent)
	local result = "{\n"
	
	for key, value in pairs(tbl) do
		result = result .. spacing .. "  "
		
		if type(key) == "string" then
			result = result .. "[\"" .. key .. "\"] = "
		else
			result = result .. "[" .. tostring(key) .. "] = "
		end
		
		if type(value) == "table" then
			result = result .. self:TableToString(value, indent + 1)
		elseif type(value) == "string" then
			result = result .. "\"" .. value .. "\""
		else
			result = result .. tostring(value)
		end
		
		result = result .. ",\n"
	end
	
	result = result .. spacing .. "}"
	return result
end

--[[
	Import settings from text
]]
function CleanupGUI:ImportSettingsFromText(text)
	-- Simple implementation - in reality you'd want better error handling
	local func, err = loadstring(text)
	if not func then
		return false
	end
	
	local success, importData = pcall(func)
	if not success or type(importData) ~= "table" then
		return false
	end
	
	-- Apply imported settings
	if importData.GuildSettings then
		GLDG_Data.GuildSettings = importData.GuildSettings
	end
	
	if importData.GreetCollections then
		GLDG_Data.GreetCollections = importData.GreetCollections
	end
	
	if importData.colours then
		GLDG_Data.colours = importData.colours
	end
	
	if importData.MinLevel then
		GLDG_Data.MinLevel = importData.MinLevel
	end
	
	if importData.MaxLevel then
		GLDG_Data.MaxLevel = importData.MaxLevel
	end
	
	return true
end