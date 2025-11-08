--[[--------------------------------------------------------
-- GuildGreet GUI System Library
-- Handles user interface elements, dropdowns, and GUI interactions
------------------------------------------------------------]]

-- Get or create the GuildGreet addon instance
local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet", true) or LibStub("AceAddon-3.0"):NewAddon("GuildGreet", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", false)

-- GUI System Library Namespace
GLDG.GUI = {}

-- Import required global variables for compatibility
local GLDG_Data, GLDG_DataChar, GLDG_guildFilterDropDownData, GLDG_rankFilterDropDownData
local GLDG_GUI, GLDG_SortedList, GLDG_PlayerOffset, GLDG_NumSelRows

-------------------------------
-- GUI System Initialization --
-------------------------------

function GLDG.GUI:Initialize()
	-- Initialize GUI dropdowns
	self:InitializeDropdowns()
	
	print("GuildGreet: GUI system initialized")
end

-------------------------------
-- Initialize Dropdowns --
-------------------------------

function GLDG.GUI:InitializeDropdowns()
	-- Setup guild and rank filter dropdowns
	GLDG_guildFilterDropDownData = {}
	GLDG_rankFilterDropDownData = {}
end

-------------------------------
-- Guild Filter DropDown Functions --
-------------------------------

function GLDG.GUI:GuildFilterDropDown_Initialize(frame, level)
	GLDG_guildFilterDropDownData = {}

	if (not GLDG_DataChar) then return end

	local count = 1
	GLDG_guildFilterDropDownData[count] = L["No guild filter"]
	count = count + 1
	GLDG_guildFilterDropDownData[count] = " " -- separator
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].guild and GLDG_DataChar[p].guild ~= "") then
			local loc = 3
			while GLDG_guildFilterDropDownData[loc] and (GLDG_guildFilterDropDownData[loc] < GLDG_DataChar[p].guild) do
				loc = loc + 1
			end
			if (GLDG_guildFilterDropDownData[loc] ~= GLDG_DataChar[p].guild) then
				for cnt = count, loc, -1 do
					GLDG_guildFilterDropDownData[cnt + 1] = GLDG_guildFilterDropDownData[cnt]
				end
				count = count + 1
				GLDG_guildFilterDropDownData[loc] = GLDG_DataChar[p].guild
				--GLDG_Print("Added guild ["..GLDG_DataChar[p].guild.."] at position ["..tostring(loc).."] - count is ["..tostring(count).."]")
			end
		end
	end

	local info

	found = false
	local level = 1
	count = 0
	for q in pairs(GLDG_guildFilterDropDownData) do
		info = UIDropDownMenu_CreateInfo();
		info.func = GLDG_GuildFilterDropDown_OnClick
		info.notCheckable = nil
		info.notClickable = nil
		info.checked = nil
		info.text = GLDG_guildFilterDropDownData[q]
		if (GLDG_Data.GuildFilter and GLDG_guildFilterDropDownData[q] == GLDG_Data.GuildFilter) then
			found = true
			info.checked = true
			--GLDG_Print("Match on entry ["..tostring(q).."] - count "..tostring(count).." - level "..tostring(level))
		end
		if (info.text == " ") then
			info.notCheckable = true
			info.notClickable = true
			--GLDG_Print("Making unclickable")
		end
		UIDropDownMenu_AddButton(info, level)
		if (GLDG_Data.GuildFilter and GLDG_guildFilterDropDownData[q] == GLDG_Data.GuildFilter) then
			UIDropDownMenu_SetSelectedID(_G[GLDG_GUI.."Players".."GuildFilterDropboxButton"], q);
			--GLDG_Print("Selecting entry ["..tostring(q).."] - frame ["..GLDG_GUI.."Players".."GuildFilterDropboxButton]")
		end

		count = count + 1
		if (count == 20) then
			info = UIDropDownMenu_CreateInfo();
			info.func = GLDG_GuildFilterDropDown_OnClick
			info.checked = nil
			info.notCheckable = nil
			info.notClickable = nil
			info.hasArrow = true
			info.text = "More"
			UIDropDownMenu_AddButton(info, level)
			info.hasArrow = false

			count = 0
			level = level + 1
			--GLDG_Print("Increased level to ["..tostring(level).."]")
		end
	end
	if not found then
		UIDropDownMenu_SetSelectedID(_G[GLDG_GUI.."Players".."GuildFilterDropboxButton"], 1);
	end
end

function GLDG.GUI:RankFilterDropDown_Initialize(frame, level)
	GLDG_rankFilterDropDownData = {}

	if (not GLDG_DataChar) then return end

	local count = 1
	GLDG_rankFilterDropDownData[count] = L["No rank filter"]
	count = count + 1
	GLDG_rankFilterDropDownData[count] = " " -- separator
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].rankname and GLDG_DataChar[p].rankname ~= "") and (GLDG_DataChar[p].guild and GLDG_DataChar[p].guild == GLDG_Data.GuildFilter) then
			local loc = 3
			while GLDG_rankFilterDropDownData[loc] and (GLDG_rankFilterDropDownData[loc] < GLDG_DataChar[p].rankname) do
				loc = loc + 1
			end
			if (GLDG_rankFilterDropDownData[loc] ~= GLDG_DataChar[p].rankname) then
				for cnt = count, loc, -1 do
					GLDG_rankFilterDropDownData[cnt + 1] = GLDG_rankFilterDropDownData[cnt]
				end
				count = count + 1
				GLDG_rankFilterDropDownData[loc] = GLDG_DataChar[p].rankname
				--GLDG_Print("Added guild ["..GLDG_DataChar[p].guild.."] at position ["..tostring(loc).."] - count is ["..tostring(count).."]")
			end
		end
	end

	local info

	found = false
	local level = 1
	count = 0
	for q in pairs(GLDG_rankFilterDropDownData) do
		info = UIDropDownMenu_CreateInfo();
		info.func = GLDG_RankFilterDropDown_OnClick
		info.notCheckable = nil
		info.notClickable = nil
		info.checked = nil
		info.text = GLDG_rankFilterDropDownData[q]
		if (GLDG_Data.RankFilter and GLDG_rankFilterDropDownData[q] == GLDG_Data.RankFilter) then
			found = true
			info.checked = true
			--GLDG_Print("Match on entry ["..tostring(q).."] - count "..tostring(count).." - level "..tostring(level))
		end
		if (info.text == " ") then
			info.notCheckable = true
			info.notClickable = true
			--GLDG_Print("Making unclickable")
		end
		UIDropDownMenu_AddButton(info, level)
		if (GLDG_Data.RankFilter and GLDG_rankFilterDropDownData[q] == GLDG_Data.RankFilter) then
			UIDropDownMenu_SetSelectedID(_G[GLDG_GUI.."Players".."RankFilterDropboxButton"], q);
			--GLDG_Print("Selecting entry ["..tostring(q).."] - frame ["..GLDG_GUI.."Players".."GuildFilterDropboxButton]")
		end

		count = count + 1
		if (count == 20) then
			info = UIDropDownMenu_CreateInfo();
			info.func = GLDG_RankFilterDropDown_OnClick
			info.checked = nil
			info.notCheckable = nil
			info.notClickable = nil
			info.hasArrow = true
			info.text = "More"
			UIDropDownMenu_AddButton(info, level)
			info.hasArrow = false

			count = 0
			level = level + 1
			--GLDG_Print("Increased level to ["..tostring(level).."]")
		end
	end
	if not found then
		UIDropDownMenu_SetSelectedID(_G[GLDG_GUI.."Players".."RankFilterDropboxButton"], 1);
	end
end

-------------------------------
-- Player Management Functions --
-------------------------------

function GLDG.GUI:ListPlayers()
	-- Abort if addon is not initialized
	if not GLDG_DataChar then return end
	-- Check if there is a reason to clear the selected player
	if GLDG_SelPlrName then
		if (not GLDG_DataChar[GLDG_SelPlrName]) or
		   (GLDG_DataChar[GLDG_SelPlrName].ignore and GLDG_Data.ShowIgnore==false) then
			GLDG_SelPlrName = nil end end
	-- Prepare for list creation
	GLDG_SortedList = {}
	local total = 0
	GLDG_NumMain = 0
	GLDG_NumAlts = 0
	local s = {}
	if GLDG_SelPlrName then s = GLDG_DataChar[GLDG_SelPlrName] end
	-- Create the list of players to display
	for player in pairs(GLDG_DataChar) do
		local p = GLDG_DataChar[player]
		if ((not p.own) or GLDG_Data.GuildSettings.IncludeOwn==true) then
			-- Update counters for main and alt
			if p.main then GLDG_NumMain = GLDG_NumMain + 1 end
			if p.alt and (p.alt == GLDG_SelPlrName) then GLDG_NumAlts = GLDG_NumAlts + 1 end
			-- See if we are supposed to add this player in our list
			local show = GLDG_Data.ShowIgnore or not p.ignore
			show = show and ((p.alt == GLDG_SelPlrName) or (p.alt == s.alt) or not p.alt or GLDG_Data.ShowAlt)
			show = show and (((not p.alt) and (not p.main)) or not GLDG_Data.FilterUnassigned)
			show = show and ((p.guild and p.guild == GLDG_Data.GuildFilter) or GLDG_Data.GuildFilter=="")
			show = show and ((p.rankname and p.rankname == GLDG_Data.RankFilter) or GLDG_Data.RankFilter=="")
			show = show and (p.enClass and GLDG_Data[p.enClass.."Filter"] == true)
			show = show and (GLDG_Online[player] or not GLDG_Data.FilterOnline)
			show = show and ((p.friends and p.friends[GLDG.Player]) or not GLDG_Data.FilterMyFriends)
			show = show and (p.friends or not GLDG_Data.FilterWithFriends)
			show = show and ((p.channels and p.channels[GLDG_ChannelName]) or not GLDG_Data.FilterCurrentChannel)
			show = show and (p.channels or not GLDG_Data.FilterWithChannel)
			if show then
				-- Look for the position in the list we need
				local loc = 1
				while GLDG_SortedList[loc] and (GLDG_SortString(player) > GLDG_SortString(GLDG_SortedList[loc])) do loc = loc + 1 end
				-- We found our position: move everything beyond it
				for cnt = total, loc, -1 do
					GLDG_SortedList[cnt + 1] = GLDG_SortedList[cnt]
				end
				-- Insert our player
				total = total + 1
				GLDG_SortedList[loc] = player
			end
		end
	end
	-- Update the scrollbar
	GLDG_ClickPlayerBar()
end

function GLDG.GUI:ShowPlayers()
	-- Display the players visible in the frame
	local cnt = 1
	local line = GLDG_GUI.."PlayersLine"
	while GLDG_SortedList[cnt + GLDG_PlayerOffset] and _G[line..cnt] do
		local textName = _G[line..cnt.."Name"]
		local textType = _G[line..cnt.."Type"]
		local textAlias = _G[line..cnt.."Alias"]
		local textMain = _G[line..cnt.."Main"]
		local textGuild = _G[line..cnt.."Guild"]
		local textRankname = _G[line..cnt.."Rankname"]
		local textPnote = _G[line..cnt.."Pnote"]
		local textOnote = _G[line..cnt.."Onote"]
		local textChannel = _G[line..cnt.."Channel"]
		local textFriend = _G[line..cnt.."Friend"]
		local textNumFriends = _G[line..cnt.."NumFriends"]
		local p = GLDG_DataChar[GLDG_SortedList[cnt + GLDG_PlayerOffset]]

		if GLDG_Online[GLDG_SortedList[cnt + GLDG_PlayerOffset]] then
			textName:SetText("*"..GLDG_SortedList[cnt + GLDG_PlayerOffset])
		else
			textName:SetText(GLDG_SortedList[cnt + GLDG_PlayerOffset])
		end
		textType:SetText("")
		if p.guild then
			textGuild:SetText(p.guild)
		else
			textGuild:SetText("---")
		end
		if p.ignore then
			textGuild:SetTextColor(1, 0.25, 0.25)
			textType:SetText(L["IGNORE"])
		elseif p.main then
			textGuild:SetTextColor(0.25, 1, 0.25)
			textType:SetText(L["MAIN"])
		elseif p.alt then
			--textName:SetTextColor(0.25, 0.25, 1)
			textGuild:SetTextColor(0.25, 1, 1)
			textType:SetText(L["ALT"])
		elseif p.alias then
			textGuild:SetTextColor(0.68, 0.8, 1)
		else
			textGuild:SetTextColor(1, 1, 1)
		end
		if p.enClass then
			textName:SetTextColor(RAID_CLASS_COLORS[p.enClass].r, RAID_CLASS_COLORS[p.enClass].g, RAID_CLASS_COLORS[p.enClass].b)
		end
		if p.alias then
			textAlias:SetText(p.alias)
			textMain:SetText("")
		elseif (GLDG_Data.GuildSort==true or GLDG_Data.GroupAlt==false or GLDG_Data.FilterOnline==true) and p.alt and GLDG_DataChar[p.alt] and GLDG_DataChar[p.alt].alias then
			textAlias:SetText("")
			textMain:SetText(GLDG_DataChar[p.alt].alias)
		elseif (GLDG_Data.GuildSort==true or GLDG_Data.GroupAlt==false or GLDG_Data.FilterOnline==true) and p.alt then
			textAlias:SetText("")
			textMain:SetText(p.alt)
		else
			textAlias:SetText("---")
			textMain:SetText("")
		end
		if p.rankname then
			textRankname:SetText(p.rankname)
		else
			textRankname:SetText("---")
		end
		if p.pNote then
			textPnote:SetText(p.pNote)
		else
			textPnote:SetText("")
		end
		if p.oNote then
			textOnote:SetText(p.oNote)
		else
			textOnote:SetText("")
		end
		if p.channels and p.channels[GLDG_ChannelName] then
			textChannel:SetText("{c}")
		else
			textChannel:SetText("---")
		end
		if p.friends then
			if p.friends[GLDG.Player] then
				textFriend:SetText("{f}")
			else
				textFriend:SetText("---")
			end
			textNumFriends:SetText(tostring(GLDG_TableSize(p.friends)))
		else
			textNumFriends:SetText("0")
 			textFriend:SetText("---")
		end

		textType:SetTextColor(textGuild:GetTextColor())
		textAlias:SetTextColor(textGuild:GetTextColor())
		textMain:SetTextColor(textGuild:GetTextColor())
		textRankname:SetTextColor(textGuild:GetTextColor())
		textPnote:SetTextColor(textGuild:GetTextColor())
		textOnote:SetTextColor(textGuild:GetTextColor())
		textChannel:SetTextColor(textGuild:GetTextColor())
		textFriend:SetTextColor(textGuild:GetTextColor())
		textNumFriends:SetTextColor(textGuild:GetTextColor())
		_G[line..cnt]:Enable()
		cnt = cnt +1 end
	-- Disable any rows left unused
	for cnt2 = cnt, GLDG_NumPlrRows do
		_G[line..cnt2.."Name"]:SetText("")
		_G[line..cnt2.."Type"]:SetText("")
		_G[line..cnt2.."Alias"]:SetText("")
		_G[line..cnt2.."Main"]:SetText("")
		_G[line..cnt2.."Guild"]:SetText("")
		_G[line..cnt2.."Rankname"]:SetText("")
		_G[line..cnt2.."Pnote"]:SetText("")
		_G[line..cnt2.."Onote"]:SetText("")
		_G[line..cnt2.."Channel"]:SetText("")
		_G[line..cnt2.."Friend"]:SetText("")
		_G[line..cnt2.."NumFriends"]:SetText("")
		_G[line..cnt2]:Disable()
	end
	-- Set/clear highlight
	for cnt = 1, GLDG_NumPlrRows do
		if GLDG_SelPlrName and (GLDG_SortedList[cnt + GLDG_PlayerOffset] == GLDG_SelPlrName) then
			_G[line..cnt]:LockHighlight()
		else
			_G[line..cnt]:UnlockHighlight()
		end
	end
	-- Update buttons
	self:ShowPlayerButtons()
end

function GLDG.GUI:ShowPlayerButtons()
	-- Set frame
	local frame = GLDG_GUI.."Players"
	-- Hide subframes
	_G[frame.."SubAlias"]:Hide()
	_G[frame.."SubGuild"]:Hide()
	_G[frame.."SubNote"]:Hide()
	_G[frame.."SubMainAlt"]:Hide()
	_G[frame.."SubPublicNote"]:Hide()
	_G[frame.."SubOfficerNote"]:Hide()
	-- If no player is selected: hide all buttons
	frame = frame.."ActionButtons"
	if not GLDG_SelPlrName then
		_G[frame]:Show()
		_G[frame.."Check"]:Show()
		_G[frame.."Ignore"]:Hide()
		_G[frame.."Alias"]:Hide()
		_G[frame.."Main"]:Hide()
		_G[frame.."Alt"]:Hide()
		_G[frame.."Guild"]:Hide()
		_G[frame.."Who"]:Hide()
		_G[frame.."Remove"]:Hide()
		_G[frame.."Note"]:Hide()
		_G[frame.."PublicNote"]:Hide()
		_G[frame.."OfficerNote"]:Hide()
		return
	end
	-- show subframe
	_G[frame]:Show()
	-- check button
	_G[frame.."Check"]:Show()
	-- Set selected player
	local p = GLDG_DataChar[GLDG_SelPlrName]
	-- Ignore button
	local button = _G[frame.."Ignore"]
	if p.ignore then
		button:SetText(L["Unignore"])
	else
		button:SetText(L["Ignore"])
	end
	button:Show()
	-- Alias button
	button = _G[frame.."Alias"]
	button:Show()
	button:Enable()
	-- Main button
	button = _G[frame.."Main"]
	button:Show()
	if p.alt then
		button:SetText(L["Promote to main"])
	elseif not p.main then
		button:SetText(L["Set as main"])
	elseif (GLDG_NumAlts == 0) then
		button:SetText(L["Unset as main"])
	else
		button:Hide()
	end
	-- Alt button
	button = _G[frame.."Alt"]
	button:Show()
	button:Enable()
	if p.alt then
		button:SetText(L["Unset as alt"])
	elseif p.main then
		button:Hide()
	else
		button:SetText(L["Set as alt"])
	end
	-- Guild button
	button = _G[frame.."Guild"]
	button:Show()
	if (p.guild and p.guild == GLDG_unique_GuildName) then
		button:Disable()
	else
		button:Enable()
	end
	-- public Note button
	button = _G[frame.."PublicNote"]
	button:Show()
	if (p.guild and p.guild == GLDG_unique_GuildName and CanEditPublicNote()) then
		button:Enable()
	else
		button:Disable()
	end
	-- Officernote button
	button = _G[frame.."OfficerNote"]
	button:Show()
	-- H.Sch. - ReglohPri- CanEditOfficerNote() is deprecated, changed to C_GuildInfo.CanEditOfficerNote()
	if (p.guild and p.guild == GLDG_unique_GuildName and C_GuildInfo.CanEditOfficerNote()) then
		button:Enable()
	else
		button:Disable()
	end
	-- Note button
	button = _G[frame.."Note"]
	button:Show()
	button:Enable()
	-- Who button
	button = _G[frame.."Who"]
	button:Show()
	if (GLDG_Online[GLDG_SelPlrName]) then
		button:Enable()
	else
		button:Disable()
	end
	-- Remove button
	button = _G[frame.."Remove"]
	button:Show()
	--if (not p.friends or GLDG_TableSize(p.friends)==0) and (not p.guild or p.guild ~= GLDG_unique_GuildName) and (not p.alt) and (not p.main) then
	if (not p.alt and not p.main) then
		button:Enable()
	else
		button:Disable()
	end
end

-------------------------------
-- Frame Creation Functions --
-------------------------------

function GLDG.GUI:CreatePasteListFrame()
-- H.Sch. - ReglohPri - changes for Patch 9.0.1 Shadowlands
--GLDG_PasteList.List = CreateFrame("Frame", nil, UIParent)
GLDG_PasteList.List = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
GLDG_PasteList.List:SetMovable(true)
GLDG_PasteList.List:SetResizable(true)
GLDG_PasteList.List:EnableMouse(true)
GLDG_PasteList.List:SetMinResize(320,120)
GLDG_PasteList.List:RegisterForDrag("LeftButton","RightButton")
GLDG_PasteList.List:SetScript("OnMouseDown",
	function(self, button)
		if button == "LeftButton" then
			self:StartMoving()
			self.isMoving = true
			self.hasMoved = false
		elseif button == "RightButton" then
			self:StartSizing()
			self.isSizing = true
			self.hasSized = false
		end
	end)

GLDG_PasteList.List:SetScript("OnMouseUp",
	function(self, button)
		if button == "LeftButton" then
			self:StopMovingOrSizing()

			local opts = GLDG_Data.Frameopts[GLDG.Realm.." - "..GLDG.Player]
			local from, _, to, x, y = self:GetPoint()

			opts.anchorFrom = from
			opts.anchorTo = to
			if self.is_expanded then
				if opts.anchorFrom == "TOPLEFT" or opts.anchorFrom == "LEFT" or opts.anchorFrom == "BOTTOMLEFT" then
					opts.offsetx = x
				elseif opts.anchorFrom == "TOP" or opts.anchorFrom == "CENTER" or opts.anchorFrom == "BOTTOM" then
					opts.offsetx = x - 151/2
				elseif opts.anchorFrom == "TOPRIGHT" or opts.anchorFrom == "RIGHT" or opts.anchorFrom == "BOTTOMRIGHT" then
					opts.offsetx = x - 151
				end
			else
				opts.offsetx = x
			end
			opts.offsety = y
		elseif button == "RightButton" then
			self:StopMovingOrSizing()
			GLDG_Data.Frameopts[GLDG.Realm.." - "..GLDG.Player].Width = self:GetWidth()
			GLDG_Data.Frameopts[GLDG.Realm.." - "..GLDG.Player].Height = self:GetHeight()
			GLDG_PasteList.List.Box:SetWidth(GLDG_Data.Frameopts[GLDG.Realm.." - "..GLDG.Player].Width - 40)
		end
	end)
GLDG_PasteList.List:Hide()
GLDG_PasteList.List:SetPoint(GLDG_Data.Frameopts[GLDG.Realm.." - "..GLDG.Player].anchorFrom, UIParent, GLDG_Data.Frameopts[GLDG.Realm.." - "..GLDG.Player].anchorTo, GLDG_Data.Frameopts[GLDG.Realm.." - "..GLDG.Player].offsetx, GLDG_Data.Frameopts[GLDG.Realm.." - "..GLDG.Player].offsety)
GLDG_PasteList.List:SetUserPlaced(true)
GLDG_PasteList.List:SetFrameStrata("DIALOG")
GLDG_PasteList.List:SetHeight(GLDG_Data.Frameopts[GLDG.Realm.." - "..GLDG.Player].Height)
GLDG_PasteList.List:SetWidth(GLDG_Data.Frameopts[GLDG.Realm.." - "..GLDG.Player].Width)

-- H.Sch. - ReglohPri - changes for Patch 9.0.1 Shadowlands
GLDG_PasteList.List.backdropInfo = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 32, edgeSize = 32,
	insets = { left = 9, right = 9, top = 9, bottom = 9 }
}
GLDG_PasteList.List:ApplyBackdrop()
-- H.Sch. End for Patch 9.0.1

GLDG_PasteList.List:SetBackdropColor(0,0,0, 0.8)
GLDG_PasteList.List:SetScript("OnShow", GLDG_PasteList.Show)

GLDG_PasteList.List.Done = CreateFrame("Button", "", GLDG_PasteList.List, "OptionsButtonTemplate")
GLDG_PasteList.List.Done:SetText("Close")
GLDG_PasteList.List.Done:SetPoint("BOTTOMRIGHT", GLDG_PasteList.List, "BOTTOMRIGHT", -10, 10)
GLDG_PasteList.List.Done:SetScript("OnClick", GLDG_PasteList.Done)

GLDG_PasteList.List.Scroll = CreateFrame("ScrollFrame", "GLDG_PasteListInputScroll", GLDG_PasteList.List, "UIPanelScrollFrameTemplate")
GLDG_PasteList.List.Scroll:SetPoint("TOPLEFT", GLDG_PasteList.List, "TOPLEFT", 20, -20)
GLDG_PasteList.List.Scroll:SetPoint("RIGHT", GLDG_PasteList.List, "RIGHT", -30, 0)
GLDG_PasteList.List.Scroll:SetPoint("BOTTOM", GLDG_PasteList.List.Done, "TOP", 0, 10)

GLDG_PasteList.List.Box = CreateFrame("EditBox", "GLDG_PasteListEditBox", GLDG_PasteList.List.Scroll)
GLDG_PasteList.List.Box:SetWidth(GLDG_Data.Frameopts[GLDG.Realm.." - "..GLDG.Player].Width - 40)
GLDG_PasteList.List.Box:SetHeight(85)
GLDG_PasteList.List.Box:SetMultiLine(true)
GLDG_PasteList.List.Box:SetAutoFocus(false)
GLDG_PasteList.List.Box:SetFontObject(GameFontHighlight)
GLDG_PasteList.List.Box:SetScript("OnEscapePressed", GLDG_PasteList.Done)
GLDG_PasteList.List.Box:SetScript("OnTextChanged", GLDG_PasteList.Update)

GLDG_PasteList.List.Scroll:SetScrollChild(GLDG_PasteList.List.Box)
end

-------------------------------
-- Friends Update System --
-------------------------------

function GLDG.GUI:FriendsUpdate()
	if (GLDG_Data.UseFriends==false) then
		return
	end

	-- prepare purge marks
	local purge = {}
	for p in pairs(GLDG_DataChar) do
		if (GLDG_DataChar[p].friends and GLDG_DataChar[p].friends[GLDG.Player]) then
			purge[p] = false
		end
	end

	-- parse friends list
	local cnt = 0
	local complete = false
	-- H.Sch. - ReglohPri - GetNumFriends() is deprecated changed to C_FriendList.GetNumFriends
	local numTotal = C_FriendList.GetNumFriends()
	local myFriends = nil
	local name, level, class, loc, connected, status, note

	-- H.Sch. - ReglohPri - GetFriendInfo(index) is deprecated changed to C_FriendList.GetFriendInfoByIndex(index)
	for i = 1, numTotal do
		--local name, level, class, loc, connected, status, note = GetFriendInfo(i);
		myFriends = C_FriendList.GetFriendInfoByIndex(i)
		name = myFriends.name
		level = myFriends.level
		class = myFriends.className
		loc = myFriends.area
		connected = myFriends.connected
		status = myFriends.afk
		note = myFriends.notes

		if (name) then
			local _, uRealm = string.split("-", name)
			if not uRealm then
				name = name.."-"..string.gsub(GLDG.Realm, " ", "")
			end

			cnt = cnt + 1
			-- mark this friend as "active" so it won't be purged below
			purge[name] = true

			if not note then
				note = ""
			end

			-- update data for this friend
			if (GLDG_DataChar[name] == nil) then
				GLDG_DataChar[name] = {}
				GLDG_AddToStartupList(L["Friends"]..": "..L["New friend"].." ["..Ambiguate(name, "guild").."]")
			end
			if (GLDG_DataChar[name].lvl == nil) then
				GLDG_DataChar[name].lvl = level
			end

			if (GLDG_Data.UseFriends==true) then
				if (connected) then
					-- Update player level
					if (level > GLDG_DataChar[name].lvl) then
						GLDG_AddToStartupList(L["Friends"]..": ["..Ambiguate(name, "guild").."]"..L["increased level from"].." "..tostring(GLDG_DataChar[name].lvl).." "..L["to"].." "..tostring(level).." "..L[""])
						if GLDG_Data.GuildSettings.ListLevelUp==true then

							local mainName = nil
							if (GLDG_DataChar[name] and not GLDG_DataChar[name].ignore) then
								if GLDG_DataChar[name].alt then
									mainName = GLDG_DataChar[name].alt;
									if GLDG_Data.GuildSettings.ExtendAlias==true then
										if GLDG_DataChar[mainName] and GLDG_DataChar[mainName].alias then
											mainName = GLDG_DataChar[mainName].alias
										end
									end
								elseif GLDG_Data.GuildSettings.ExtendMain==true and GLDG_DataChar[name].main then
									mainName = name
									if GLDG_Data.GuildSettings.ExtendAlias==true then
										if GLDG_DataChar[mainName] and GLDG_DataChar[mainName].alias then
											mainName = GLDG_DataChar[mainName].alias
										end
									end
								end
							end

							if (mainName) then
								GLDG:Print(GLDG.Colors:GetColors().help..GLDG_NAME..":|r ["..Ambiguate(name, "guild").."] "..GLDG.Colors:GetColors().help.."{"..mainName.."}|r "..string.format(L["has increased his level from %s to %s"],GLDG_DataChar[name].lvl, level));
							else
								GLDG:Print(GLDG.Colors:GetColors().help..GLDG_NAME..":|r ["..Ambiguate(name, "guild").."] "..string.format(L["has increased his level from %s to %s"],GLDG_DataChar[name].lvl, level));
							end
						end
						if (GLDG_TableSize(GLDG_DataGreet.NewLevel) > 0) and (GLDG_Data.GuildSettings.SupressLevel==false) and (not GLDG_DataChar[name].ignore) and (level > GLDG_Data.GuildSettings.MinLevelUp) then
							if (GLDG_Online[pl] or GLDG_Data.GuildSettings.NoGratsOnLogin==false) then
								GLDG_DataChar[name].newlvl = true
							end
						end
					end
					-- Update queue with all changes still missing
					if (GLDG_DataChar[name].new or GLDG_DataChar[name].newlvl or GLDG_DataChar[name].newrank) and (not GLDG_Queue[name]) then
						GLDG_Queue[name] = "[??:??] "
					end

					GLDG_DataChar[name].lvl = level

					if class and class ~= "Unknown" then
						GLDG_DataChar[name].class = class
					end
				end
				if (not GLDG_Offline[name]) then
					GLDG_Offline[name] = false
				end
				if (GLDG_Online[name] == nil) then
					GLDG_Online[name] = connected
				end
			end
			if (not GLDG_DataChar[name].friends) then
				GLDG_DataChar[name].friends = {}
			end
			GLDG_DataChar[name].friends[GLDG.Player] = note
		end
	end

	-- purge "removed friends" for this char
	for p in pairs(purge) do
		if (purge[p] ~= true) then
			if (GLDG_DataChar[p].friends) then
				GLDG_DataChar[p].friends[GLDG.Player] = nil;
			end
		end
	end

	-- If we got our info, switch to the next phase
	if (cnt > 0) then
		if not GLDG_InitialFriendsUpdate then
			GLDG_InitialFriendsUpdate = true
			GLDG:RegisterEvent("CHAT_MSG_SYSTEM")
		end

		if bit.band(GLDG_InitCheck, 2)==2 then
			GLDG_InitCheck = bit.band(GLDG_InitCheck, bit.bnot(2))	-- friends no longer pending
			GLDG_InitCheck = bit.bor(GLDG_InitCheck, 16)	-- friends done
			--GLDG_Print("InitCheck is ["..tostring(GLDG_InitCheck).."] - friends done")
			GLDG_StartupCheck()
		end

		-- retrigger friends update
		if (GLDG_Data.UpdateTime > 0) then
			GLDG_UpdateRequestFriends = GetTime() + GLDG_Data.UpdateTime
		else
			GLDG_UpdateRequestFriends = nil
		end

		GLDG.Messages:ShowQueue()
	end
end

------------------------------------------------------------
-- Settings GUI and Checkbox Management
------------------------------------------------------------

function GLDG.GUI:SetCheckboxes()
	local name1 = GLDG_GUI.."SettingsGeneral"
	local name2 = GLDG_GUI.."SettingsChat"
	local name3 = GLDG_GUI.."SettingsGreeting"
	local name4 = GLDG_GUI.."SettingsOther"
	
	if GLDG_Data.GuildSettings.UseGuildDefault==true then
		_G[name1.."GreetAsMainBox"]:Disable()
		_G[name1.."GreetAsMainText"]:SetAlpha(0.5)
		_G[name1.."RandomizeBox"]:Disable()
		_G[name1.."RandomizeText"]:SetAlpha(0.5)
		_G[name1.."WhisperBox"]:Disable()
		_G[name1.."WhisperText"]:SetAlpha(0.5)
		_G[name1.."WhisperLevelupBox"]:Disable()
		_G[name1.."WhisperLevelupText"]:SetAlpha(0.5)
		_G[name1.."IncludeOwnBox"]:Disable()
		_G[name1.."IncludeOwnText"]:SetAlpha(0.5)
		_G[name1.."AutoAssignBox"]:Disable()
		_G[name1.."AutoAssignText"]:SetAlpha(0.5)
		_G[name1.."AutoAssignEgpBox"]:Disable()
		_G[name1.."AutoAssignEgpText"]:SetAlpha(0.5)
		_G[name1.."AutoAssignAliasBox"]:Disable()
		_G[name1.."AutoAssignAliasText"]:SetAlpha(0.5)
		_G[name1.."RelogSlider"]:Disable()
		_G[name1.."RelogText"]:SetAlpha(0.5)
		_G[name1.."MinLevelUpSlider"]:Disable()
		_G[name1.."MinLevelUpText"]:SetAlpha(0.5)
		_G[name2.."ListNamesBox"]:Disable()
		_G[name2.."ListNamesText"]:SetAlpha(0.5)
		_G[name2.."ListNamesOffBox"]:Disable()
		_G[name2.."ListNamesOffText"]:SetAlpha(0.5)
		_G[name2.."ListLevelUpBox"]:Disable()
		_G[name2.."ListLevelUpText"]:SetAlpha(0.5)
		_G[name2.."ListLevelUpOffBox"]:Disable()
		_G[name2.."ListLevelUpOffText"]:SetAlpha(0.5)
		_G[name2.."ListAchievmentsBox"]:Disable()
		_G[name2.."ListAchievmentsText"]:SetAlpha(0.5)
		_G[name2.."ListQuitBox"]:Disable()
		_G[name2.."ListQuitText"]:SetAlpha(0.5)
		_G[name2.."ExtendChatBox"]:Disable()
		_G[name2.."ExtendChatText"]:SetAlpha(0.5)
		_G[name2.."ExtendIgnoredBox"]:Disable()
		_G[name2.."ExtendIgnoredText"]:SetAlpha(0.5)
		_G[name2.."ExtendMainBox"]:Disable()
		_G[name2.."ExtendMainText"]:SetAlpha(0.5)
		_G[name2.."ExtendAliasBox"]:Disable()
		_G[name2.."ExtendAliasText"]:SetAlpha(0.5)
		_G[name2.."AddPostfixBox"]:Disable()
		_G[name2.."AddPostfixText"]:SetAlpha(0.5)
		_G[name2.."ShowWhoSpamBox"]:Disable()
		_G[name2.."ShowWhoSpamText"]:SetAlpha(0.5)
		_G[name3.."SupressGreetBox"]:Disable()
		_G[name3.."SupressGreetText"]:SetAlpha(0.5)
		_G[name3.."SupressJoinBox"]:Disable()
		_G[name3.."SupressJoinText"]:SetAlpha(0.5)
		_G[name3.."SupressLevelBox"]:Disable()
		_G[name3.."SupressLevelText"]:SetAlpha(0.5)
		_G[name3.."SupressRankBox"]:Disable()
		_G[name3.."SupressRankText"]:SetAlpha(0.5)
		_G[name3.."SupressAchievmentBox"]:Disable()
		_G[name3.."SupressAchievmentText"]:SetAlpha(0.5)
		_G[name3.."NoGratsOnLoginBox"]:Disable()
		_G[name3.."NoGratsOnLoginText"]:SetAlpha(0.5)
		_G[name4.."DeltaPopupBox"]:Disable()
		_G[name4.."DeltaPopupText"]:SetAlpha(0.5)
	else
		_G[name1.."GreetAsMainBox"]:Enable()
		_G[name1.."GreetAsMainText"]:SetAlpha(1.0)
		_G[name1.."RandomizeBox"]:Enable()
		_G[name1.."RandomizeText"]:SetAlpha(1.0)
		_G[name1.."WhisperBox"]:Enable()
		_G[name1.."WhisperText"]:SetAlpha(1.0)
		_G[name1.."WhisperLevelupBox"]:Enable()
		_G[name1.."WhisperLevelupText"]:SetAlpha(1.0)
		_G[name1.."IncludeOwnBox"]:Enable()
		_G[name1.."IncludeOwnText"]:SetAlpha(1.0)
		_G[name1.."AutoAssignBox"]:Enable()
		_G[name1.."AutoAssignText"]:SetAlpha(1.0)
		_G[name1.."AutoAssignEgpBox"]:Enable()
		_G[name1.."AutoAssignEgpText"]:SetAlpha(1.0)
		_G[name1.."AutoAssignAliasBox"]:Enable()
		_G[name1.."AutoAssignAliasText"]:SetAlpha(1.0)
		_G[name1.."RelogSlider"]:Enable()
		_G[name1.."RelogText"]:SetAlpha(1.0)
		_G[name1.."MinLevelUpSlider"]:Enable()
		_G[name1.."MinLevelUpText"]:SetAlpha(1.0)
		_G[name2.."ListNamesBox"]:Enable()
		_G[name2.."ListNamesText"]:SetAlpha(1.0)
		_G[name2.."ListNamesOffBox"]:Enable()
		_G[name2.."ListNamesOffText"]:SetAlpha(1.0)
		_G[name2.."ListLevelUpBox"]:Enable()
		_G[name2.."ListLevelUpText"]:SetAlpha(1.0)
		_G[name2.."ListLevelUpOffBox"]:Enable()
		_G[name2.."ListLevelUpOffText"]:SetAlpha(1.0)
		_G[name2.."ListAchievmentsBox"]:Enable()
		_G[name2.."ListAchievmentsText"]:SetAlpha(1.0)
		_G[name2.."ListQuitBox"]:Enable()
		_G[name2.."ListQuitText"]:SetAlpha(1.0)
		_G[name2.."ExtendChatBox"]:Enable()
		_G[name2.."ExtendChatText"]:SetAlpha(1.0)
		_G[name2.."ExtendIgnoredBox"]:Enable()
		_G[name2.."ExtendIgnoredText"]:SetAlpha(1.0)
		_G[name2.."ExtendMainBox"]:Enable()
		_G[name2.."ExtendMainText"]:SetAlpha(1.0)
		_G[name2.."ExtendAliasBox"]:Enable()
		_G[name2.."ExtendAliasText"]:SetAlpha(1.0)
		_G[name2.."AddPostfixBox"]:Enable()
		_G[name2.."AddPostfixText"]:SetAlpha(1.0)
		_G[name2.."ShowWhoSpamBox"]:Enable()
		_G[name2.."ShowWhoSpamText"]:SetAlpha(1.0)
		_G[name3.."SupressGreetBox"]:Enable()
		_G[name3.."SupressGreetText"]:SetAlpha(1.0)
		_G[name3.."SupressJoinBox"]:Enable()
		_G[name3.."SupressJoinText"]:SetAlpha(1.0)
		_G[name3.."SupressLevelBox"]:Enable()
		_G[name3.."SupressLevelText"]:SetAlpha(1.0)
		_G[name3.."SupressRankBox"]:Enable()
		_G[name3.."SupressRankText"]:SetAlpha(1.0)
		_G[name3.."SupressAchievmentBox"]:Enable()
		_G[name3.."SupressAchievmentText"]:SetAlpha(1.0)
		_G[name3.."NoGratsOnLoginBox"]:Enable()
		_G[name3.."NoGratsOnLoginText"]:SetAlpha(1.0)
		_G[name4.."DeltaPopupBox"]:Enable()
		_G[name4.."DeltaPopupText"]:SetAlpha(1.0)
	end
end

------------------------------------------------------------
function GLDG.GUI:UpdateListsize(self)
	-- Store the new value
	GLDG_Data.ListSize = self:GetValue()
	-- Update display
	local text = _G[self:GetParent():GetName().."ListsizeText"]
	text:SetText(string.format(L["Display a maximum of %d queued players"], GLDG_Data.ListSize))
	-- Update queue
	GLDG.Messages:ShowQueue()
end

------------------------------------------------------------
function GLDG.GUI:UpdateChatFrame(self)
	local text = _G[self:GetParent():GetName().."ChatFrameText"]
	if not GLDG_updatingChatFrame and GLDG_Data.PlayerChatFrame[GLDG.Player.."-"..GLDG.Realm] ~= math.floor(self:GetValue()) then
		GLDG_updatingChatFrame = true

		-- Store the new value
		GLDG_Data.PlayerChatFrame[GLDG.Player.."-"..GLDG.Realm] = math.floor(self:GetValue())
		
		if (GLDG_Data.PlayerChatFrame[GLDG.Player.."-"..GLDG.Realm] == 0) then
			text:SetText(L["Using default chat frame"])
			GLDG_Print(GLDG:GetColors().help..GLDG_NAME..":|r Now using default chat frame")
		else
			local name, fontSize, r, g, b, alpha, shown, locked, docked = GetChatWindowInfo(GLDG_Data.PlayerChatFrame[GLDG.Player.."-"..GLDG.Realm])
			text:SetText(string.format(L["Using chat frame %d (%s)"], GLDG_Data.PlayerChatFrame[GLDG.Player.."-"..GLDG.Realm], name))
			GLDG:PrintHelp(string.format(L["Now using chat frame %d (%s)"], GLDG_Data.PlayerChatFrame[GLDG.Player.."-"..GLDG.Realm], Ambiguate(name, "guild")))
		end

		GLDG_updatingChatFrame = nil
	else
		if (GLDG_Data.PlayerChatFrame[GLDG.Player.."-"..GLDG.Realm] == 0) then
			text:SetText(L["Using default chat frame"])
		else
			local name, fontSize, r, g, b, alpha, shown, locked, docked = GetChatWindowInfo(GLDG_Data.PlayerChatFrame[GLDG.Player.."-"..GLDG.Realm])
			text:SetText(string.format(L["Using chat frame %d (%s)"], GLDG_Data.PlayerChatFrame[GLDG.Player.."-"..GLDG.Realm], name))
		end
	end
end

------------------------------------------------------------
function GLDG.GUI:GetNumActiveChatFrames()
	local count = 0;
	local chatFrame;
	for i=1, NUM_CHAT_WINDOWS do
		local _, _, _, _, _, _, shown, locked, docked = GetChatWindowInfo(i);
		chatFrame = _G["ChatFrame"..i];
		if ( chatFrame ) then
			if ( shown or chatFrame.isDocked ) then
				count = count + 1;
			end
		end
	end
	return count;
end

------------------------------------------------------------
function GLDG.GUI:DropDownTemplate_OnLoad(self)
	UIDropDownMenu_Initialize(self, GLDG_DropDown_Initialize);
	UIDropDownMenu_SetWidth(self, 150);
end

------------------------------------------------------------
-- Player Tooltip Management
------------------------------------------------------------

function GLDG.GUI:ShowPlayerToolTip(element)
	if not element then return end

	local name = _G[element.."Name"]:GetText()

	if (string.sub(name, 1, 1)=="*") then
		name = string.sub(name, 2)
	end
	local color_s = ""
	local color_p = ""
	if (name and GLDG_DataChar[name]) then
		color_s = ""
		color_p = ""
		if GLDG_DataChar[name].enClass then
			color_s = "|c"..RAID_CLASS_COLORS[GLDG_DataChar[name].enClass].colorStr
			color_p = "|r"
		end
		local p = GLDG_DataChar[name]
		local head = color_s..name..color_p
		if p.alias then
			head = head..GLDG_ALIAS_COLOUR.." ("..p.alias..")|r"
		end

		GameTooltip:SetOwner(_G[element], "ANCHOR_CURSOR")
		GameTooltip:SetText(head, 1, 1, 0.5, 1.0, 1)

		if p.guild then
			if p.guild==GLDG_unique_GuildName then
				GameTooltip:AddLine("<"..GLDG.GuildName..">", 1, 1, 0.75)
			else
				GameTooltip:AddLine("<"..p.guild..">", 1, 1, 0.75)
			end
		end
		if p.ignore then
			GameTooltip:AddLine(L["Ignored"], 1, 0, 0)
		end

		GameTooltip:AddLine(" ", 1, 1, 0.75)

		local added = false

		if p.alias then
			GameTooltip:AddDoubleLine(L["Alias"], GLDG_ALIAS_COLOUR..p.alias.."|r", 1, 1, 0, 1, 1, 1)
			added = true
		end

		if p.main then
			local hasAlts = false
			local first = true
			for q in pairs(GLDG_DataChar) do
				if GLDG_DataChar[q].alt and GLDG_DataChar[q].alt == name then
					color_s = ""
					color_p = ""
					if GLDG_DataChar[q].enClass then
						color_s = "|c"..RAID_CLASS_COLORS[GLDG_DataChar[q].enClass].colorStr
						color_p = "|r"
					end
					if first then
						first = false
						GameTooltip:AddDoubleLine(L["Alts"], color_s..Ambiguate(q, "guild")..color_p, 1, 1, 0, 1, 1, 1)
					else
						GameTooltip:AddDoubleLine(" ", color_s..Ambiguate(q, "guild")..color_p, 1, 1, 0, 1, 1, 1)
					end
					added = true
					hasAlts = true
				end
			end
			if not hasAlts then
				GameTooltip:AddDoubleLine(L["Main"], L["Yes"], 1, 1, 0, 1, 1, 1)
			end
		elseif p.alt then
			color_s = ""
			color_p = ""
			if GLDG_DataChar[p.alt].enClass then
				color_s = "|c"..RAID_CLASS_COLORS[GLDG_DataChar[p.alt].enClass].colorStr
				color_p = "|r"
			end
			if (GLDG_DataChar[p.alt] and GLDG_DataChar[p.alt].alias) then
				GameTooltip:AddDoubleLine(L["Main"], color_s..Ambiguate(p.alt, "guild")..color_p.." "..GLDG_ALIAS_COLOUR.."("..GLDG_DataChar[p.alt].alias..")|r", 1, 1, 0, 1, 1, 1)
			else
				GameTooltip:AddDoubleLine(L["Main"], color_s..Ambiguate(p.alt, "guild")..color_p, 1, 1, 0, 1, 1, 1)
			end
			local first = true
			for q in pairs(GLDG_DataChar) do
				if GLDG_DataChar[q].alt and GLDG_DataChar[q].alt == p.alt and q ~= name then
					color_s = ""
					color_p = ""
					if GLDG_DataChar[q].enClass then
						color_s = "|c"..RAID_CLASS_COLORS[GLDG_DataChar[q].enClass].colorStr
						color_p = "|r"
					end
					if first then
						first = false
						GameTooltip:AddDoubleLine(L["Alts"], color_s..Ambiguate(q, "guild")..color_p, 1, 1, 0, 1, 1, 1)
						added = true
					else
						GameTooltip:AddDoubleLine(" ", color_s..Ambiguate(q, "guild")..color_p, 1, 1, 0, 1, 1, 1)
						added = true
					end
				end
			end
		end

		if added then
			GameTooltip:AddLine(" ", 1, 1, 0.75)
			added = false
		end

		if p.guild then
			if p.guild==GLDG_unique_GuildName then
				GameTooltip:AddDoubleLine(L["Guild"], GLDG.GuildName, 1, 1, 0, 1, 1, 1)
			else
				GameTooltip:AddDoubleLine(L["Guild"], p.guild, 1, 1, 0, 1, 1, 1)
			end
			added = true
			if p.new then
				GameTooltip:AddDoubleLine(" ", L["New in guild"], 1, 1, 0, 1, 1, 1)
			end
		end
		if p.rank and p.rankname then
			GameTooltip:AddDoubleLine(L["Rank"], p.rankname.." ("..tostring(p.rank)..")", 1, 1, 0, 1, 1, 1)
			added = true
		elseif p.rank then
			GameTooltip:AddDoubleLine(L["Rank"], tostring(p.rank), 1, 1, 0, 1, 1, 1)
			added = true
		elseif p.rankname then
			GameTooltip:AddDoubleLine(L["Rank"], p.rankname, 1, 1, 0, 1, 1, 1)
			added = true
		end
		if (p.rank or p.rankname) and p.newrank then
			GameTooltip:AddDoubleLine(" ", L["(new rank)"], 1, 1, 0, 1, 1, 1)
			added = true
		end
		if p.pNote then
			GameTooltip:AddDoubleLine(L["Player Note"], p.pNote, 1, 1, 0, 1, 1, 1)
			added = true
		end
		if p.oNote then
			GameTooltip:AddDoubleLine(L["Officer Note"], p.oNote, 1, 1, 0, 1, 1, 1)
			added = true
		end

		if p.class then
			GameTooltip:AddDoubleLine(L["Class"], p.class, 1, 1, 0, 1, 1, 1)
			added = true
		end
		if p.storedLvl then
			GameTooltip:AddDoubleLine(L["Level"], p.storedLvl, 1, 1, 0, 1, 1, 1)
			added = true
		elseif p.lvl then
			GameTooltip:AddDoubleLine(L["Level"], p.lvl, 1, 1, 0, 1, 1, 1)
			added = true
		end
		if p.achievment then
			GameTooltip:AddDoubleLine(L["Last achievment"], p.achievment, 1, 1, 0, 1, 1, 1)
			added = true
		end

		if added then
			GameTooltip:AddLine(" ", 1, 1, 0.75)
			added = false
		end

		if p.channels then
			local first = true
			for q in pairs(p.channels) do
				if first then
					first = false
					GameTooltip:AddDoubleLine(L["Channel(s)"], q, 1, 1, 0, 1, 1, 1)
					added = true
				else
					GameTooltip:AddDoubleLine(" ", q, 1, 1, 0, 1, 1, 1)
					added = true
				end
			end
		end
		if p.friends then
			GameTooltip:AddDoubleLine(L["Friends"], GLDG_TableSize(p.friends), 1, 1, 0, 1, 1, 1)
			for q in pairs(p.friends) do
				if p.friends[q] ~= "" then
					GameTooltip:AddDoubleLine(" ", q.." (|cFFFFFFBF"..p.friends[q].."|r)", 1, 1, 0, 1, 1, 1)	-- show friends note
				else
					GameTooltip:AddDoubleLine(" ", q, 1, 1, 0, 1, 1, 1)
				end
				added = true
			end
		end

		if added then
			GameTooltip:AddLine(" ", 1, 1, 0.75)
			added = false
		end

		if p.last then
			color_s = ""
			color_p = ""
			if GLDG_DataChar[p.last].enClass then
				color_s = "|c"..RAID_CLASS_COLORS[GLDG_DataChar[p.last].enClass].colorStr
				color_p = "|r"
			end
			GameTooltip:AddDoubleLine(L["Last on with"], color_s..Ambiguate(p.last, "guild")..color_p, 1, 1, 0, 1, 1, 1)
			added = true
		elseif p.alt and GLDG_DataChar[p.alt].last then
			color_s = ""
			color_p = ""
			if GLDG_DataChar[p.alt].enClass then
				color_s = "|c"..RAID_CLASS_COLORS[GLDG_DataChar[GLDG_DataChar[p.alt].last].enClass].colorStr
				color_p = "|r"
			end
			GameTooltip:AddDoubleLine(L["Last on with"], color_s..Ambiguate(GLDG_DataChar[p.alt].last..color_p, "guild"), 1, 1, 0, 1, 1, 1)
			added = true
		end

		if GLDG_Online[name] then
			GameTooltip:AddDoubleLine(L["Online"], L["Online"], 1, 1, 0, 1, 1, 1)
			added = true
		end
		if GLDG_Offline[name] then
			GameTooltip:AddDoubleLine(L["Offline"], GLDG_Offline[name], 1, 1, 0, 1, 1, 1)
			added = true
		end
		if GLDG_Queue[name] then
			GameTooltip:AddDoubleLine(L["In queue since"], GLDG_Queue[name], 1, 1, 0, 1, 1, 1)
			added = true
		end

		if p.note then
			if added then
				GameTooltip:AddLine(" ", 1, 1, 0.75)
				added = false
			end
			GameTooltip:AddDoubleLine(L["Note"], p.note, 1, 1, 0, 1, 1, 1)
			added = true
		end

		GameTooltip:Show()
	end
end

------------------------------------------------------------
-- Collection Management Functions
------------------------------------------------------------

function GLDG.GUI:ShowCollections(frame)
	if not frame then return end
	-- Update scrollbar
	local bar = _G[frame.."Collectbar"]
	FauxScrollFrame_Update(bar, GLDG_TableSize(GLDG_Data.Collections), GLDG_NumColRows, 15)
	local offset = FauxScrollFrame_GetOffset(bar)
	-- Sort the list of existing custom collections
	local sorted = {}
	local total = 0
	for col in pairs(GLDG_Data.Collections) do
		-- Look for the position in the list we need
		local loc = 1
		while sorted[loc] and (sorted[loc] < col) do loc = loc + 1 end
		-- We found the position: move everything beyond it
		for cnt = total, loc, -1 do sorted[cnt+1] = sorted[cnt] end
		-- Insert the collection
		total = total + 1
		sorted[loc] = col 
	end
	-- Show the collections visible
	for i = 1, GLDG_NumColRows do
		_G[frame.."Collect"..i]:UnlockHighlight()
		if sorted[i + offset] then
			_G[frame.."Collect"..i.."Text"]:SetText(sorted[i + offset])
			_G[frame.."Collect"..i]:Enable()
			if GLDG_SelColName and (GLDG_SelColName == sorted[i + offset]) then 
				_G[frame.."Collect"..i]:LockHighlight() 
			end
		else	
			_G[frame.."Collect"..i.."Text"]:SetText("")
			_G[frame.."Collect"..i]:Disable() 
		end 
	end
	-- Set buttons and text depending the selected collection
	local colhead = L["Global defaults"]
	if GLDG_SelColName then
		_G[frame.."ColNewDel"]:SetText(L["Remove selection"])
		colhead = string.format(L["Collection %q"], GLDG_SelColName)
	else 
		_G[frame.."ColNewDel"]:SetText(L["Create new collection"]) 
	end
	_G[frame.."GreetHeader"]:SetText(string.format(L["%s : select the greeting category you want to edit"], colhead))
end

function GLDG.GUI:ShowGreetings(frame)
	-- Show messages from selected category
	local list = GLDG_Data[GLDG_Selection]
	if GLDG_SelColName then
		list = GLDG_Data.Collections[GLDG_SelColName][GLDG_Selection]
		-- check to catch error reported by Baraknor
		if (list == nil) then
			GLDG_Data.Collections[GLDG_SelColName][GLDG_Selection] = {}
			list = GLDG_Data.Collections[GLDG_SelColName][GLDG_Selection]
		end
	end
	local cnt = 1
	local line = frame.."Line"
	while list[cnt + GLDG_GreetOffset] and _G[line..cnt] do
		_G[line..cnt.."Text"]:SetText(list[cnt + GLDG_GreetOffset])
		_G[line..cnt]:Enable()
		cnt = cnt + 1 
	end
	while _G[line..cnt] do
		_G[line..cnt.."Text"]:SetText("")
		_G[line..cnt]:Disable()
		cnt = cnt + 1 
	end
	-- Set highlight
	for cnt = 1, GLDG_NumSelRows do
		if GLDG_SelMsgNum and (GLDG_SelMsgNum == GLDG_GreetOffset + cnt) then 
			_G[line..cnt]:LockHighlight()
		else 
			_G[line..cnt]:UnlockHighlight() 
		end 
	end
	-- Set editbox
	if GLDG_SelMsgNum and list[GLDG_SelMsgNum] then 
		_G[frame.."Editbox"]:SetText(list[GLDG_SelMsgNum])
	else 
		_G[frame.."Editbox"]:SetText("") 
	end
	-- Set editbox buttons
	if GLDG_SelMsgNum then
		_G[frame.."MsgAdd"]:SetText(L["update"])
		_G[frame.."MsgDel"]:SetText(L["remove"])
	else	
		_G[frame.."MsgAdd"]:SetText(L["add"])
		_G[frame.."MsgDel"]:SetText(L["clear"]) 
	end
end

function GLDG.GUI:ShowCustom(frame)
	-- Display the current values
	local d = GLDG_Data.Custom[GLDG.Realm]
	if d and (d ~= "") and not GLDG_Data.Collections[d] then
		-- Collection no longer exists
		GLDG_Data.Custom[GLDG.Realm] = nil
		d = nil 
	end
	local f = _G[frame.."SubCustomRealm"]
	if not d then 
		f:SetText(L["not defined"])
	elseif (d == "") then 
		f:SetText(L["Global defaults"])
	else 
		f:SetText(d) 
	end
	d = GLDG_Data.Custom[GLDG_unique_GuildName]
	if d and (d ~= "") and not GLDG_Data.Collections[d] then
		-- Collection no longer exists
		GLDG_Data.Custom[GLDG_unique_GuildName] = nil
		d = nil 
	end
	f = _G[frame.."SubCustomGuild"]
	if not d then 
		f:SetText(L["not defined"])
	elseif (d == "") then 
		f:SetText(L["Global defaults"])
	else 
		f:SetText(d) 
	end
	d = GLDG_Data.Custom[GLDG.Realm.."-"..UnitName("player")]
	if d and (d ~= "") and not GLDG_Data.Collections[d] then
		-- Collection no longer exists
		GLDG_Data.Custom[GLDG.Realm.."-"..UnitName("player")] = nil
		d = nil 
	end
	f = _G[frame.."SubCustomChar"]
	if not d then 
		f:SetText(L["not defined"])
	elseif (d == "") then 
		f:SetText(L["Global defaults"])
	else 
		f:SetText(d) 
	end
	-- Set greetings section pointer at is possibly changed
	if GLDG_InitGreet(GLDG.Realm.."-"..UnitName("player")) and
	   GLDG_InitGreet(GLDG_unique_GuildName) and
	   GLDG_InitGreet(GLDG.Realm) then
		-- No custom collections are used
		GLDG_DataGreet = GLDG_Data 
	end
	-- Show the frame
	GLDG_ColButtonPressed(frame)
	_G[frame.."SubCustom"]:Show()
end

function GLDG.GUI:ClickCollection(self, col)
	-- Set new selected collection
	if GLDG_SelColName and (GLDG_SelColName == col) then 
		GLDG_SelColName = nil
	else 
		GLDG_SelColName = col 
	end
	-- Update change selection button
	local button = _G[self:GetParent():GetName().."SubChangeSelection"]
	if GLDG_SelColName then 
		button:Enable() 
	else 
		button:Disable() 
	end
	-- Refresh display
	GLDG_ShowCollections()
	GLDG_ShowGreetings(self:GetParent():GetName())
end

function GLDG.GUI:ColButtonPressed(frame)
	-- Enable all collections buttons
	_G[frame.."ColNewDel"]:Enable()
	_G[frame.."ColRealm"]:Enable()
	_G[frame.."ColGuild"]:Enable()
	_G[frame.."ColPlayer"]:Enable()
	-- Hide all subframes
	_G[frame.."SubCustom"]:Hide()
	_G[frame.."SubNew"]:Hide()
	_G[frame.."SubChange"]:Hide()
end