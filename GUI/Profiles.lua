------------------------------------------------------------
-- GuildGreet Modern GUI - Profiles Management Tab
-- Active Profile Hero Card, Quick Presets & Side-by-Side Copy/Delete
------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", true)
local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
GuildGreet = GLDG

local strtrim = strtrim or function(s)
    return string.match(tostring(s or ""), "^%s*(.-)%s*$") or ""
end

local UIStyle = GLDG.UIStyle

local profilesPanel = nil
local selectedCopySource = nil
local selectedDeleteTarget = nil

StaticPopupDialogs["GUILDGREET_CONFIRM_DELETE_PROFILE"] = {
    text = L["Are you sure you want to delete the profile '%s'?"] or "Are you sure you want to delete the profile '%s'?",
    button1 = YES or L["Yes"] or "Yes",
    button2 = NO or L["No"] or "No",
    OnAccept = function(_, data)
        if data and GLDG.db and data ~= GLDG.db:GetCurrentProfile() then
            GLDG.db:DeleteProfile(data, true)
            selectedDeleteTarget = nil
            GLDG:RefreshConfigUI()
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["GUILDGREET_CONFIRM_RESET_PROFILE"] = {
    text = L["Are you sure you want to reset the current profile '%s' to default values?"] or "Are you sure you want to reset the current profile '%s' to default values?",
    button1 = YES or L["Yes"] or "Yes",
    button2 = NO or L["No"] or "No",
    OnAccept = function()
        if GLDG.db then
            GLDG.db:ResetProfile()
            GLDG:OnProfileChanged()
            GLDG:RefreshConfigUI()
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

local function GetProfileDropdownItems(excludeCurrent)
    local items = {}
    if not GLDG.db then return items end
    local current = GLDG.db:GetCurrentProfile()
    local list = GLDG.db:GetProfiles({})
    table.sort(list)
    for _, name in ipairs(list) do
        if not excludeCurrent or name ~= current then
            local lbl = (name == current) and (UIStyle.Hex.green .. name .. " ★|r") or name
            table.insert(items, { value = name, label = lbl })
        end
    end
    return items
end

local RefreshProfilesPanel

RefreshProfilesPanel = function()
    if not profilesPanel or not profilesPanel:IsShown() then return end

    local fontSize = UIStyle:GetFontSize()
    local panelW = math.max(520, (profilesPanel:GetWidth() or 820) - 4)
    local currentProfile = (GLDG.db and GLDG.db:GetCurrentProfile()) or "Default"
    local allItems = GetProfileDropdownItems(false)
    local otherItems = GetProfileDropdownItems(true)

    -- Validate cached selections against existing profiles
    local validCopy, validDel = false, false
    for _, it in ipairs(otherItems) do
        if it.value == selectedCopySource then validCopy = true end
        if it.value == selectedDeleteTarget then validDel = true end
    end
    if not validCopy then selectedCopySource = nil end
    if not validDel then selectedDeleteTarget = nil end

    -- 1. Active Profile Hero Card
    local activeCard = profilesPanel.activeCard
    UIStyle:ApplyFont(activeCard.title, 0)
    UIStyle:ApplyFont(profilesPanel.descText, 0)
    UIStyle:ApplyFont(profilesPanel.curBadgeText, 0)
    UIStyle:ApplyFont(profilesPanel.switchLbl, 0)
    UIStyle:ApplyFont(profilesPanel.switchDrop.label, 0)

    profilesPanel.descText:SetText(
        L["Create and manage multiple setting profiles. Profiles allow you to save different configurations and switch between them easily."]
        or "Erstelle und verwalte mehrere Einstellungsprofile."
    )
    profilesPanel.curBadgeText:SetText(
        UIStyle.Hex.gold .. (L["Current Profile"] or "Aktuelles Profil") .. ":|r  " .. UIStyle.Hex.green .. currentProfile .. "|r"
    )
    local badgeW = math.max(150, math.ceil((profilesPanel.curBadgeText:GetStringWidth() or 120) + 24))
    profilesPanel.curBadge:SetSize(badgeW, math.max(26, fontSize + 12))

    profilesPanel.switchDrop.label:SetText(UIStyle.Hex.green .. currentProfile .. "|r")
    profilesPanel.switchDrop:SetScript("OnClick", function(selfBtn)
        UIStyle:OpenDropdown(selfBtn, allItems, currentProfile, function(newProf)
            if newProf and newProf ~= currentProfile and GLDG.db then
                GLDG.db:SetProfile(newProf)
                GLDG:OnProfileChanged()
                RefreshProfilesPanel()
            end
        end)
    end)

    profilesPanel.resetBtn:SetText(L["Restore default"] or "Standard wiederherstellen")
    profilesPanel.resetBtn:UpdateSize()
    profilesPanel.resetBtn:SetScript("OnClick", function()
        StaticPopup_Show("GUILDGREET_CONFIRM_RESET_PROFILE", currentProfile)
    end)

    local rowInputH = math.max(28, fontSize + 14)
    local activeCardH = math.max(128, fontSize * 3 + 92)
    activeCard:ClearAllPoints()
    activeCard:SetPoint("TOPLEFT", profilesPanel, "TOPLEFT", 0, 0)
    activeCard:SetSize(panelW, activeCardH)

    profilesPanel.curBadge:ClearAllPoints()
    profilesPanel.curBadge:SetPoint("TOPRIGHT", activeCard, "TOPRIGHT", -12, -36)
    profilesPanel.descText:ClearAllPoints()
    profilesPanel.descText:SetPoint("TOPLEFT", activeCard, "TOPLEFT", 12, -38)
    profilesPanel.descText:SetPoint("RIGHT", profilesPanel.curBadge, "LEFT", -12, 0)

    profilesPanel.resetBtn:ClearAllPoints()
    profilesPanel.resetBtn:SetPoint("BOTTOMRIGHT", activeCard, "BOTTOMRIGHT", -12, 12)
    profilesPanel.switchLbl:ClearAllPoints()
    profilesPanel.switchLbl:SetPoint("BOTTOMLEFT", activeCard, "BOTTOMLEFT", 12, 18)
    profilesPanel.switchDrop:SetHeight(rowInputH)
    profilesPanel.switchDrop:ClearAllPoints()
    profilesPanel.switchDrop:SetPoint("LEFT", profilesPanel.switchLbl, "RIGHT", 10, 0)
    profilesPanel.switchDrop:SetPoint("RIGHT", profilesPanel.resetBtn, "LEFT", -10, 0)

    -- 2. Create New Profile Card (with Quick Presets)
    local createCard = profilesPanel.createCard
    UIStyle:ApplyFont(createCard.title, 0)
    UIStyle:ApplyFont(profilesPanel.newProfInput, 0)
    if profilesPanel.newProfInput.placeholder then
        UIStyle:ApplyFont(profilesPanel.newProfInput.placeholder, 0)
    end
    UIStyle:ApplyFont(profilesPanel.presetLbl, -1)

    local createCardH = math.max(114, fontSize * 2 + 86)
    createCard:ClearAllPoints()
    createCard:SetPoint("TOPLEFT", activeCard, "BOTTOMLEFT", 0, -8)
    createCard:SetSize(panelW, createCardH)

    profilesPanel.createBtn:SetText(L["Create & Activate"] or "Erstellen & Aktivieren")
    profilesPanel.createBtn:UpdateSize()
    profilesPanel.createBtn:ClearAllPoints()
    profilesPanel.createBtn:SetPoint("TOPRIGHT", createCard, "TOPRIGHT", -12, -38)

    profilesPanel.newProfInput:SetHeight(rowInputH)
    profilesPanel.newProfInput:ClearAllPoints()
    profilesPanel.newProfInput:SetPoint("TOPLEFT", createCard, "TOPLEFT", 12, -38)
    profilesPanel.newProfInput:SetPoint("RIGHT", profilesPanel.createBtn, "LEFT", -10, 0)

    profilesPanel.presetLbl:ClearAllPoints()
    profilesPanel.presetLbl:SetPoint("BOTTOMLEFT", createCard, "BOTTOMLEFT", 12, 14)

    local prevPreset = nil
    for _, pBtn in ipairs(profilesPanel.presetBtns) do
        pBtn:UpdateSize()
        pBtn:ClearAllPoints()
        if not prevPreset then
            pBtn:SetPoint("LEFT", profilesPanel.presetLbl, "RIGHT", 10, 0)
        else
            pBtn:SetPoint("LEFT", prevPreset, "RIGHT", 6, 0)
        end
        prevPreset = pBtn
    end

    -- 3. Side-by-Side Copy & Delete Profile Cards
    local halfW = math.floor((panelW - 10) / 2)
    local subCardH = math.max(118, fontSize * 2 + 88)

    -- Left: Copy Profile
    local copyCard = profilesPanel.copyCard
    UIStyle:ApplyFont(copyCard.title, 0)
    UIStyle:ApplyFont(profilesPanel.copyDesc, -1)
    UIStyle:ApplyFont(profilesPanel.copyDrop.label, 0)
    copyCard:ClearAllPoints()
    copyCard:SetPoint("TOPLEFT", createCard, "BOTTOMLEFT", 0, -8)
    copyCard:SetSize(halfW, subCardH)

    profilesPanel.copyDesc:SetText(string.format(L["Copy settings from another profile into '%s'."] or "Einstellungen in '%s' übernehmen.", currentProfile))
    profilesPanel.copyBtn:SetText(L["Copy"] or "Kopieren")
    profilesPanel.copyBtn:UpdateSize()
    profilesPanel.copyBtn:ClearAllPoints()
    profilesPanel.copyBtn:SetPoint("BOTTOMRIGHT", copyCard, "BOTTOMRIGHT", -12, 12)

    profilesPanel.copyDrop:SetHeight(rowInputH)
    profilesPanel.copyDrop:ClearAllPoints()
    profilesPanel.copyDrop:SetPoint("BOTTOMLEFT", copyCard, "BOTTOMLEFT", 12, 12)
    profilesPanel.copyDrop:SetPoint("RIGHT", profilesPanel.copyBtn, "LEFT", -8, 0)

    if #otherItems == 0 then
        profilesPanel.copyDrop.label:SetText(UIStyle.Hex.textMuted .. (L["-- No other profiles available --"] or "-- Kein weiteres Profil vorhanden --") .. "|r")
        profilesPanel.copyDrop:SetDisabledState(true)
        profilesPanel.copyBtn:SetDisabledState(true)
    else
        profilesPanel.copyDrop:SetDisabledState(false)
        if selectedCopySource then
            profilesPanel.copyDrop.label:SetText(selectedCopySource)
            profilesPanel.copyBtn:SetDisabledState(false)
        else
            profilesPanel.copyDrop.label:SetText(UIStyle.Hex.goldDim .. (L["-- Select profile --"] or "-- Profil auswählen --") .. "|r")
            profilesPanel.copyBtn:SetDisabledState(true)
        end
        profilesPanel.copyDrop:SetScript("OnClick", function(selfBtn)
            UIStyle:OpenDropdown(selfBtn, otherItems, selectedCopySource, function(val)
                selectedCopySource = val
                RefreshProfilesPanel()
            end)
        end)
    end

    -- Right: Delete Profile
    local delCard = profilesPanel.delCard
    UIStyle:ApplyFont(delCard.title, 0)
    UIStyle:ApplyFont(profilesPanel.delDesc, -1)
    UIStyle:ApplyFont(profilesPanel.delDrop.label, 0)
    delCard:ClearAllPoints()
    delCard:SetPoint("TOPLEFT", copyCard, "TOPRIGHT", 10, 0)
    delCard:SetSize(panelW - halfW - 10, subCardH)

    profilesPanel.delDesc:SetText(L["Permanently remove an inactive profile."] or "Ein nicht aktives Profil dauerhaft löschen.")
    profilesPanel.delBtn:SetText(L["Delete"] or "Löschen")
    profilesPanel.delBtn:UpdateSize()
    profilesPanel.delBtn:ClearAllPoints()
    profilesPanel.delBtn:SetPoint("BOTTOMRIGHT", delCard, "BOTTOMRIGHT", -12, 12)

    profilesPanel.delDrop:SetHeight(rowInputH)
    profilesPanel.delDrop:ClearAllPoints()
    profilesPanel.delDrop:SetPoint("BOTTOMLEFT", delCard, "BOTTOMLEFT", 12, 12)
    profilesPanel.delDrop:SetPoint("RIGHT", profilesPanel.delBtn, "LEFT", -8, 0)

    if #otherItems == 0 then
        profilesPanel.delDrop.label:SetText(UIStyle.Hex.textMuted .. (L["-- No other profiles available --"] or "-- Kein weiteres Profil vorhanden --") .. "|r")
        profilesPanel.delDrop:SetDisabledState(true)
        profilesPanel.delBtn:SetDisabledState(true)
    else
        profilesPanel.delDrop:SetDisabledState(false)
        if selectedDeleteTarget then
            profilesPanel.delDrop.label:SetText(selectedDeleteTarget)
            profilesPanel.delBtn:SetDisabledState(false)
        else
            profilesPanel.delDrop.label:SetText(UIStyle.Hex.goldDim .. (L["-- Select profile --"] or "-- Profil auswählen --") .. "|r")
            profilesPanel.delBtn:SetDisabledState(true)
        end
        profilesPanel.delDrop:SetScript("OnClick", function(selfBtn)
            UIStyle:OpenDropdown(selfBtn, otherItems, selectedDeleteTarget, function(val)
                selectedDeleteTarget = val
                RefreshProfilesPanel()
            end)
        end)
    end
end

local function EnsureProfilesPanel(hostFrame)
    if profilesPanel then
        profilesPanel:SetParent(hostFrame)
        profilesPanel:ClearAllPoints()
        profilesPanel:SetAllPoints(hostFrame)
        return profilesPanel
    end

    local panel = CreateFrame("Frame", nil, hostFrame)
    panel:SetAllPoints(hostFrame)

    -- 1. Active Profile Hero Card
    local activeCard = UIStyle:CreateCard(panel, L["Active Profile"] or "Aktives Profil")
    panel.activeCard = activeCard

    local descText = activeCard:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    descText:SetJustifyH("LEFT")
    descText:SetTextColor(unpack(UIStyle.Colors.textLight))
    panel.descText = descText

    local curBadge = CreateFrame("Frame", nil, activeCard, BackdropTemplateMixin and "BackdropTemplate" or nil)
    UIStyle:ApplyBox(curBadge, UIStyle.Colors.bgRowActive, UIStyle.Colors.borderHighlight)
    panel.curBadge = curBadge
    local curBadgeText = curBadge:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    curBadgeText:SetPoint("CENTER", 0, 0)
    panel.curBadgeText = curBadgeText

    local switchLbl = activeCard:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    switchLbl:SetTextColor(unpack(UIStyle.Colors.gold))
    switchLbl:SetText((L["Choose Profile"] or "Profil auswählen") .. ":")
    panel.switchLbl = switchLbl

    panel.switchDrop = UIStyle:CreateDropdown(activeCard, 260, 28)
    panel.resetBtn = UIStyle:CreateButton(activeCard, L["Restore default"] or "Standard wiederherstellen", 160, 28, nil, false)

    -- 2. Create New Profile Card
    local createCard = UIStyle:CreateCard(panel, L["Create New Profile"] or "Neues Profil erstellen")
    panel.createCard = createCard

    local newProfInput = UIStyle:CreateEditBox(createCard, 28, L["Enter new profile name..."] or "Neuen Profilnamen eingeben...")
    panel.newProfInput = newProfInput

    local function activateOrCreateProfile(rawName)
        local name = strtrim(rawName or "")
        if name == "" or not GLDG.db then return end
        GLDG.db:SetProfile(name)
        GLDG:OnProfileChanged()
        newProfInput:SetText("")
        newProfInput._syncPlaceholder()
        RefreshProfilesPanel()
    end

    newProfInput:SetScript("OnEnterPressed", function(selfBox)
        selfBox:ClearFocus()
        activateOrCreateProfile(selfBox:GetText())
    end)

    panel.createBtn = UIStyle:CreateButton(createCard, L["Create & Activate"] or "Erstellen & Aktivieren", 150, 28, function()
        activateOrCreateProfile(newProfInput:GetText())
    end, true)

    local presetLbl = createCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    presetLbl:SetTextColor(unpack(UIStyle.Colors.goldDim))
    presetLbl:SetText(L["Quick Presets:"] or "Schnellvorlagen:")
    panel.presetLbl = presetLbl

    panel.presetBtns = {
        UIStyle:CreateButton(createCard, L["Character"] or "Charakter", 96, 24, function()
            local charName = UnitName("player") or GLDG.Player or "Character"
            local realmName = GetRealmName() or GLDG.Realm or "Realm"
            activateOrCreateProfile(charName .. " - " .. realmName)
        end, false),
        UIStyle:CreateButton(createCard, L["Guild"] or "Gilde", 86, 24, function()
            local gName = (GLDG.GetCurrentGuildName and GLDG:GetCurrentGuildName()) or (GetGuildInfo and GetGuildInfo("player")) or "Guild"
            if gName and gName ~= "" then
                activateOrCreateProfile(gName)
            end
        end, false),
        UIStyle:CreateButton(createCard, L["Class"] or "Klasse", 86, 24, function()
            local locClass = UnitClass and UnitClass("player") or "Class"
            if locClass and locClass ~= "" then
                activateOrCreateProfile(locClass)
            end
        end, false),
    }

    -- 3. Copy & Delete Cards
    local copyCard = UIStyle:CreateCard(panel, L["Copy Profile"] or "Profil kopieren")
    panel.copyCard = copyCard
    local copyDesc = copyCard:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    copyDesc:SetPoint("TOPLEFT", copyCard, "TOPLEFT", 12, -36)
    copyDesc:SetPoint("TOPRIGHT", copyCard, "TOPRIGHT", -12, -36)
    copyDesc:SetJustifyH("LEFT")
    copyDesc:SetTextColor(unpack(UIStyle.Colors.textMuted))
    panel.copyDesc = copyDesc
    panel.copyDrop = UIStyle:CreateDropdown(copyCard, 200, 28)
    panel.copyBtn = UIStyle:CreateButton(copyCard, L["Copy"] or "Kopieren", 100, 28, function()
        if selectedCopySource and GLDG.db and selectedCopySource ~= GLDG.db:GetCurrentProfile() then
            GLDG.db:CopyProfile(selectedCopySource)
            GLDG:OnProfileChanged()
            RefreshProfilesPanel()
        end
    end, false)

    local delCard = UIStyle:CreateCard(panel, L["Delete Profile"] or "Profil löschen")
    panel.delCard = delCard
    local delDesc = delCard:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    delDesc:SetPoint("TOPLEFT", delCard, "TOPLEFT", 12, -36)
    delDesc:SetPoint("TOPRIGHT", delCard, "TOPRIGHT", -12, -36)
    delDesc:SetJustifyH("LEFT")
    delDesc:SetTextColor(unpack(UIStyle.Colors.textMuted))
    panel.delDesc = delDesc
    panel.delDrop = UIStyle:CreateDropdown(delCard, 200, 28)
    panel.delBtn = UIStyle:CreateButton(delCard, L["Delete"] or "Löschen", 100, 28, function()
        if selectedDeleteTarget and GLDG.db and selectedDeleteTarget ~= GLDG.db:GetCurrentProfile() then
            local dialog = StaticPopup_Show("GUILDGREET_CONFIRM_DELETE_PROFILE", selectedDeleteTarget)
            if dialog then
                dialog.data = selectedDeleteTarget
            end
        end
    end, false)

    panel:SetScript("OnSizeChanged", function()
        if panel:IsShown() then
            RefreshProfilesPanel()
        end
    end)

    profilesPanel = panel
    return panel
end

function GLDG:ShowProfilesTabPanel(hostFrame)
    local panel = EnsureProfilesPanel(hostFrame)
    panel:Show()
    RefreshProfilesPanel()
end

function GLDG:HideProfilesTabPanel()
    if profilesPanel then
        profilesPanel:Hide()
    end
end

function GLDG:CreateProfilesTab(container)
    if container and container.frame then
        self:ShowProfilesTabPanel(container.frame)
    end
end
