--[[
	GuildGreet Players GUI Module
	Handles the Players tab interface
]]--

local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", false)

local PlayersGUI = GLDG:NewModule("PlayersGUI")

-- Current state
PlayersGUI.selectedPlayer = nil
PlayersGUI.playersData = {}
PlayersGUI.sortedPlayers = {}
PlayersGUI.filter = {
	showIgnored = false,
	showAlts = false,
	showUnassigned = false,
	searchText = ""
}

--[[
	Create the Players tab content
]]
function PlayersGUI:CreateTabContent(container)
	-- Main container
	local mainGroup = AceGUI:Create("SimpleGroup")
	mainGroup:SetFullWidth(true)
	mainGroup:SetFullHeight(true)
	mainGroup:SetLayout("Flow")
	
	-- Filter controls
	local filterGroup = AceGUI:Create("InlineGroup")
	filterGroup:SetTitle(L["Filter Options"] or "Filter Options")
	filterGroup:SetFullWidth(true)
	filterGroup:SetHeight(120)
	filterGroup:SetLayout("Flow")
	
	self:CreateFilterControls(filterGroup)
	mainGroup:AddChild(filterGroup)
	
	-- Players list and details
	local contentGroup = AceGUI:Create("SimpleGroup")
	contentGroup:SetFullWidth(true)
	contentGroup:SetRelativeHeight(0.8)
	contentGroup:SetLayout("Flow")
	
	-- Players list (left side)
	local playersListGroup = AceGUI:Create("InlineGroup")
	playersListGroup:SetTitle(L["Guild Members"] or "Guild Members")
	playersListGroup:SetWidth(400)
	playersListGroup:SetFullHeight(true)
	playersListGroup:SetLayout("Fill")
	
	self:CreatePlayersList(playersListGroup)
	contentGroup:AddChild(playersListGroup)
	
	-- Player details (right side)
	local detailsGroup = AceGUI:Create("InlineGroup")
	detailsGroup:SetTitle(L["Player Details"] or "Player Details")
	detailsGroup:SetRelativeWidth(0.6)
	detailsGroup:SetFullHeight(true)
	detailsGroup:SetLayout("Flow")
	
	self:CreatePlayerDetails(detailsGroup)
	contentGroup:AddChild(detailsGroup)
	
	mainGroup:AddChild(contentGroup)
	container:AddChild(mainGroup)
	
	-- Store references
	self.filterGroup = filterGroup
	self.playersListGroup = playersListGroup
	self.detailsGroup = detailsGroup
	
	-- Load data
	self:RefreshPlayersList()
end

--[[
	Create filter controls
]]
function PlayersGUI:CreateFilterControls(container)
	-- Search box
	local searchBox = AceGUI:Create("EditBox")
	searchBox:SetLabel(L["Search"] or "Search")
	searchBox:SetWidth(200)
	searchBox:SetCallback("OnTextChanged", function(widget, event, text)
		self.filter.searchText = text:lower()
		self:RefreshPlayersList()
	end)
	container:AddChild(searchBox)
	
	-- Show ignored checkbox
	local showIgnored = AceGUI:Create("CheckBox")
	showIgnored:SetLabel(L["Include ignored players"] or "Include ignored players")
	showIgnored:SetValue(self.filter.showIgnored)
	showIgnored:SetCallback("OnValueChanged", function(widget, event, value)
		self.filter.showIgnored = value
		self:RefreshPlayersList()
	end)
	container:AddChild(showIgnored)
	
	-- Show alts checkbox
	local showAlts = AceGUI:Create("CheckBox")
	showAlts:SetLabel(L["Always show alts"] or "Always show alts")
	showAlts:SetValue(self.filter.showAlts)
	showAlts:SetCallback("OnValueChanged", function(widget, event, value)
		self.filter.showAlts = value
		self:RefreshPlayersList()
	end)
	container:AddChild(showAlts)
	
	-- Show unassigned checkbox
	local showUnassigned = AceGUI:Create("CheckBox")
	showUnassigned:SetLabel(L["Show only unassigned characters"] or "Show only unassigned characters")
	showUnassigned:SetValue(self.filter.showUnassigned)
	showUnassigned:SetCallback("OnValueChanged", function(widget, event, value)
		self.filter.showUnassigned = value
		self:RefreshPlayersList()
	end)
	container:AddChild(showUnassigned)
	
	-- Refresh button
	local refreshBtn = AceGUI:Create("Button")
	refreshBtn:SetText(L["Refresh"] or "Refresh")
	refreshBtn:SetWidth(100)
	refreshBtn:SetCallback("OnClick", function()
		self:RefreshPlayersList()
	end)
	container:AddChild(refreshBtn)
	
	-- Store references
	self.searchBox = searchBox
	self.showIgnored = showIgnored
	self.showAlts = showAlts
	self.showUnassigned = showUnassigned
end

--[[
	Create players list
]]
function PlayersGUI:CreatePlayersList(container)
	-- Scroll frame for players
	local scrollFrame = AceGUI:Create("ScrollFrame")
	scrollFrame:SetFullWidth(true)
	scrollFrame:SetFullHeight(true)
	scrollFrame:SetLayout("List")
	
	container:AddChild(scrollFrame)
	
	-- Store reference
	self.playersScrollFrame = scrollFrame
end

--[[
	Create player details panel
]]
function PlayersGUI:CreatePlayerDetails(container)
	-- Player info section
	local infoGroup = AceGUI:Create("InlineGroup")
	infoGroup:SetTitle(L["Player Information"] or "Player Information")
	infoGroup:SetFullWidth(true)
	infoGroup:SetHeight(200)
	infoGroup:SetLayout("Flow")
	
	-- Player name
	local nameLabel = AceGUI:Create("Label")
	nameLabel:SetText(L["No player selected"] or "No player selected")
	nameLabel:SetFontObject(GameFontNormalLarge)
	nameLabel:SetFullWidth(true)
	infoGroup:AddChild(nameLabel)
	
	-- Level and class
	local levelLabel = AceGUI:Create("Label")
	levelLabel:SetText("")
	levelLabel:SetFullWidth(true)
	infoGroup:AddChild(levelLabel)
	
	-- Guild rank
	local rankLabel = AceGUI:Create("Label")
	rankLabel:SetText("")
	rankLabel:SetFullWidth(true)
	infoGroup:AddChild(rankLabel)
	
	-- Last seen
	local lastSeenLabel = AceGUI:Create("Label")
	lastSeenLabel:SetText("")
	lastSeenLabel:SetFullWidth(true)
	infoGroup:AddChild(lastSeenLabel)
	
	container:AddChild(infoGroup)
	
	-- Actions section
	local actionsGroup = AceGUI:Create("InlineGroup")
	actionsGroup:SetTitle(L["Actions"] or "Actions")
	actionsGroup:SetFullWidth(true)
	actionsGroup:SetHeight(200)
	actionsGroup:SetLayout("Flow")
	
	-- Ignore checkbox
	local ignoreCheck = AceGUI:Create("CheckBox")
	ignoreCheck:SetLabel(L["Ignore this player"] or "Ignore this player")
	ignoreCheck:SetCallback("OnValueChanged", function(widget, event, value)
		self:SetPlayerIgnored(self.selectedPlayer, value)
	end)
	ignoreCheck:SetFullWidth(true)
	actionsGroup:AddChild(ignoreCheck)
	
	-- Main character dropdown
	local mainDropdown = AceGUI:Create("Dropdown")
	mainDropdown:SetLabel(L["Main Character"] or "Main Character")
	mainDropdown:SetCallback("OnValueChanged", function(widget, event, key, value)
		self:SetPlayerMain(self.selectedPlayer, key)
	end)
	mainDropdown:SetFullWidth(true)
	actionsGroup:AddChild(mainDropdown)
	
	-- Alias edit box
	local aliasEdit = AceGUI:Create("EditBox")
	aliasEdit:SetLabel(L["Alias"] or "Alias")
	aliasEdit:SetCallback("OnEnterPressed", function(widget, event, text)
		self:SetPlayerAlias(self.selectedPlayer, text)
	end)
	aliasEdit:SetFullWidth(true)
	actionsGroup:AddChild(aliasEdit)
	
	-- Notes edit box
	local notesEdit = AceGUI:Create("MultiLineEditBox")
	notesEdit:SetLabel(L["Notes"] or "Notes")
	notesEdit:SetHeight(60)
	notesEdit:SetCallback("OnTextChanged", function(widget, event, text)
		-- Auto-save notes after a delay
		if self.notesTimer then
			self.notesTimer:Cancel()
		end
		self.notesTimer = C_Timer.NewTimer(2, function()
			self:SetPlayerNotes(self.selectedPlayer, text)
		end)
	end)
	notesEdit:SetFullWidth(true)
	actionsGroup:AddChild(notesEdit)
	
	container:AddChild(actionsGroup)
	
	-- Store references
	self.nameLabel = nameLabel
	self.levelLabel = levelLabel
	self.rankLabel = rankLabel
	self.lastSeenLabel = lastSeenLabel
	self.ignoreCheck = ignoreCheck
	self.mainDropdown = mainDropdown
	self.aliasEdit = aliasEdit
	self.notesEdit = notesEdit
end

--[[
	Refresh players list
]]
function PlayersGUI:RefreshPlayersList()
	if not self.playersScrollFrame then return end
	
	-- Clear current list
	self.playersScrollFrame:ReleaseChildren()
	
	-- Get guild members data
	self:LoadPlayersData()
	
	-- Apply filters and sorting
	self.sortedPlayers = self:FilterAndSortPlayers()
	
	-- Create player entries
	for _, playerData in ipairs(self.sortedPlayers) do
		local playerFrame = self:CreatePlayerEntry(playerData)
		self.playersScrollFrame:AddChild(playerFrame)
	end
end

--[[
	Load players data from guild roster
]]
function PlayersGUI:LoadPlayersData()
	self.playersData = {}
	
	if not IsInGuild() then return end
	
	local numMembers = GetNumGuildMembers()
	
	for i = 1, numMembers do
		local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i)
		
		if name and name ~= "" then
			-- Get character data
			local charData = GLDG_DataChar and GLDG_DataChar[name] or {}
			
			local playerData = {
				name = name,
				level = level or 1,
				class = class or "Unknown",
				rank = rank or "",
				rankIndex = rankIndex or 10,
				zone = zone or "",
				note = note or "",
				officernote = officernote or "",
				online = online,
				status = status or 0,
				
				-- GuildGreet specific data
				ignored = charData.ignored or false,
				main = charData.main or nil,
				alias = charData.alias or "",
				notes = charData.note or "",
				lastSeen = charData.lastseen or 0,
				greetCount = charData.greetcount or 0
			}
			
			table.insert(self.playersData, playerData)
		end
	end
end

--[[
	Filter and sort players
]]
function PlayersGUI:FilterAndSortPlayers()
	local filtered = {}
	
	for _, player in ipairs(self.playersData) do
		local include = true
		
		-- Apply filters
		if not self.filter.showIgnored and player.ignored then
			include = false
		end
		
		if self.filter.showUnassigned and player.main then
			include = false
		end
		
		if self.filter.searchText ~= "" then
			local searchLower = self.filter.searchText:lower()
			if not (player.name:lower():find(searchLower) or 
					player.alias:lower():find(searchLower) or
					player.class:lower():find(searchLower)) then
				include = false
			end
		end
		
		if include then
			table.insert(filtered, player)
		end
	end
	
	-- Sort by name
	table.sort(filtered, function(a, b)
		return a.name < b.name
	end)
	
	return filtered
end

--[[
	Create player entry widget
]]
function PlayersGUI:CreatePlayerEntry(playerData)
	local entry = AceGUI:Create("InteractiveLabel")
	
	-- Format player text
	local text = string.format("%s (%d %s)", 
		playerData.name, 
		playerData.level, 
		playerData.class)
	
	if playerData.ignored then
		text = "|cFF808080" .. text .. "|r"
	elseif playerData.main then
		text = "|cFFFFFF00" .. text .. " -> " .. playerData.main .. "|r"
	elseif playerData.online then
		text = "|cFF00FF00" .. text .. "|r"
	end
	
	entry:SetText(text)
	entry:SetFullWidth(true)
	entry:SetCallback("OnClick", function()
		self:SelectPlayer(playerData.name)
	end)
	
	return entry
end

--[[
	Select a player
]]
function PlayersGUI:SelectPlayer(playerName)
	self.selectedPlayer = playerName
	self:UpdatePlayerDetails()
end

--[[
	Update player details panel
]]
function PlayersGUI:UpdatePlayerDetails()
	if not self.selectedPlayer or not self.nameLabel then return end
	
	-- Find player data
	local playerData = nil
	for _, player in ipairs(self.playersData) do
		if player.name == self.selectedPlayer then
			playerData = player
			break
		end
	end
	
	if not playerData then
		self.nameLabel:SetText(L["Player not found"] or "Player not found")
		return
	end
	
	-- Update labels
	self.nameLabel:SetText(playerData.name)
	self.nameLabel:SetColor(RAID_CLASS_COLORS[playerData.class] and RAID_CLASS_COLORS[playerData.class].r or 1,
						   RAID_CLASS_COLORS[playerData.class] and RAID_CLASS_COLORS[playerData.class].g or 1,
						   RAID_CLASS_COLORS[playerData.class] and RAID_CLASS_COLORS[playerData.class].b or 1)
	
	self.levelLabel:SetText(string.format(L["Level %d %s"] or "Level %d %s", playerData.level, playerData.class))
	self.rankLabel:SetText(string.format(L["Guild Rank: %s"] or "Guild Rank: %s", playerData.rank))
	
	if playerData.lastSeen > 0 then
		self.lastSeenLabel:SetText(string.format(L["Last seen: %s"] or "Last seen: %s", date("%c", playerData.lastSeen)))
	else
		self.lastSeenLabel:SetText(L["Last seen: Never"] or "Last seen: Never")
	end
	
	-- Update controls
	self.ignoreCheck:SetValue(playerData.ignored)
	self.aliasEdit:SetText(playerData.alias)
	self.notesEdit:SetText(playerData.notes)
	
	-- Update main character dropdown
	local mainList = {[""] = L["None"] or "None"}
	for _, player in ipairs(self.playersData) do
		if player.name ~= self.selectedPlayer and not player.main then
			mainList[player.name] = player.name
		end
	end
	self.mainDropdown:SetList(mainList)
	self.mainDropdown:SetValue(playerData.main or "")
end

--[[
	Set player ignored status
]]
function PlayersGUI:SetPlayerIgnored(playerName, ignored)
	if not playerName then return end
	
	if not GLDG_DataChar then GLDG_DataChar = {} end
	if not GLDG_DataChar[playerName] then GLDG_DataChar[playerName] = {} end
	
	GLDG_DataChar[playerName].ignored = ignored
	
	-- Refresh display
	self:RefreshPlayersList()
	self:UpdatePlayerDetails()
end

--[[
	Set player main character
]]
function PlayersGUI:SetPlayerMain(playerName, mainName)
	if not playerName then return end
	
	if not GLDG_DataChar then GLDG_DataChar = {} end
	if not GLDG_DataChar[playerName] then GLDG_DataChar[playerName] = {} end
	
	GLDG_DataChar[playerName].main = mainName ~= "" and mainName or nil
	
	-- Refresh display
	self:RefreshPlayersList()
	self:UpdatePlayerDetails()
end

--[[
	Set player alias
]]
function PlayersGUI:SetPlayerAlias(playerName, alias)
	if not playerName then return end
	
	if not GLDG_DataChar then GLDG_DataChar = {} end
	if not GLDG_DataChar[playerName] then GLDG_DataChar[playerName] = {} end
	
	GLDG_DataChar[playerName].alias = alias
	
	-- Update display
	self:UpdatePlayerDetails()
end

--[[
	Set player notes
]]
function PlayersGUI:SetPlayerNotes(playerName, notes)
	if not playerName then return end
	
	if not GLDG_DataChar then GLDG_DataChar = {} end
	if not GLDG_DataChar[playerName] then GLDG_DataChar[playerName] = {} end
	
	GLDG_DataChar[playerName].note = notes
end