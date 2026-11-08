------------------------------------------------------------
-- GuildGreet Modern GUI - Profiles Management Tab
-- Full AceDB-3.0 profile switching, creation, copying,
-- deletion, and reset with confirmation dialogs
------------------------------------------------------------

local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", true)
local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
GuildGreet = GLDG

local UIStyle = GLDG.UIStyle

local selectedCopySource = nil
local selectedDeleteTarget = nil

StaticPopupDialogs["GUILDGREET_CONFIRM_DELETE_PROFILE"] = {
    text = "Are you sure you want to delete the profile '%s'?",
    button1 = YES or "Yes",
    button2 = NO or "No",
    OnAccept = function(_, data)
        if data and GLDG.db and data ~= GLDG.db:GetCurrentProfile() then
            GLDG.db:DeleteProfile(data, true)
            selectedDeleteTarget = nil
            GLDG:PrintInfo("Deleted profile: " .. tostring(data))
            GLDG:RefreshConfigUI()
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["GUILDGREET_CONFIRM_RESET_PROFILE"] = {
    text = "Are you sure you want to reset the current profile '%s' to default values?",
    button1 = YES or "Yes",
    button2 = NO or "No",
    OnAccept = function()
        if GLDG.db then
            GLDG.db:ResetProfile()
            GLDG:OnProfileChanged()
            GLDG:PrintInfo("Current profile reset to defaults.")
            GLDG:RefreshConfigUI()
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

local function GetAllProfilesMap(excludeCurrent)
    local map = {}
    if not GLDG.db then return map end
    local current = GLDG.db:GetCurrentProfile()
    local list = GLDG.db:GetProfiles({})
    for _, name in ipairs(list) do
        if not excludeCurrent or name ~= current then
            map[name] = name
        end
    end
    return map
end

function GLDG:CreateProfilesTab(container)
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    container:AddChild(scroll)

    local currentProfile = self.db and self.db:GetCurrentProfile() or "Default"
    local allProfiles = GetAllProfilesMap(false)
    local otherProfiles = GetAllProfilesMap(true)

    --------------------------------------------------------
    -- 1. Active Profile Selection & Reset
    --------------------------------------------------------
    local activeGroup = AceGUI:Create("InlineGroup")
    activeGroup:SetTitle(L["Active Profile"] or "Active Configuration Profile")
    activeGroup:SetFullWidth(true)
    activeGroup:SetLayout("Flow")
    scroll:AddChild(activeGroup)

    local descLabel = AceGUI:Create("Label")
    descLabel:SetFullWidth(true)
    descLabel:SetText(
        (L["Create and manage multiple setting profiles. Profiles allow you to save different configurations and switch between them easily."] or
        "Profiles store your settings, filters, and colour schemes.") .. "\n" ..
        UIStyle.Hex.gold .. (L["Current Profile"] or "Current Active Profile") .. ":|r " .. UIStyle.Hex.green .. currentProfile .. UIStyle.Hex.reset
    )
    activeGroup:AddChild(descLabel)

    local switchDrop = AceGUI:Create("Dropdown")
    switchDrop:SetLabel(L["Choose Profile"] or "Switch Active Profile")
    switchDrop:SetList(allProfiles)
    switchDrop:SetValue(currentProfile)
    switchDrop:SetRelativeWidth(0.65)
    switchDrop:SetCallback("OnValueChanged", function(_, _, newProfile)
        if newProfile and newProfile ~= currentProfile then
            self.db:SetProfile(newProfile)
            self:OnProfileChanged()
            self:PrintInfo("Switched to profile: " .. newProfile)
            self:RefreshConfigUI()
        end
    end)
    activeGroup:AddChild(switchDrop)

    local resetBtn = AceGUI:Create("Button")
    resetBtn:SetText(L["Restore default"] or "Reset Current Profile")
    resetBtn:SetRelativeWidth(0.35)
    resetBtn:SetCallback("OnClick", function()
        StaticPopup_Show("GUILDGREET_CONFIRM_RESET_PROFILE", currentProfile)
    end)
    activeGroup:AddChild(resetBtn)

    --------------------------------------------------------
    -- 2. Create New Profile
    --------------------------------------------------------
    local createGroup = AceGUI:Create("InlineGroup")
    createGroup:SetTitle(L["Create New Profile"] or "Create New Profile")
    createGroup:SetFullWidth(true)
    createGroup:SetLayout("Flow")
    scroll:AddChild(createGroup)

    local newProfileEdit = AceGUI:Create("EditBox")
    newProfileEdit:SetLabel(L["New Profile Name"] or "New Profile Name (Press Enter to Create & Activate)")
    newProfileEdit:SetFullWidth(true)
    newProfileEdit:SetCallback("OnEnterPressed", function(widget, _, name)
        name = strtrim(name or "")
        if name == "" then return end
        self.db:SetProfile(name)
        self:OnProfileChanged()
        widget:SetText("")
        self:PrintInfo("Created and activated profile: " .. name)
        self:RefreshConfigUI()
    end)
    createGroup:AddChild(newProfileEdit)

    --------------------------------------------------------
    -- 3. Copy From Existing Profile
    --------------------------------------------------------
    local copyGroup = AceGUI:Create("InlineGroup")
    copyGroup:SetTitle(L["Copy Profile"] or "Copy Settings From Another Profile")
    copyGroup:SetFullWidth(true)
    copyGroup:SetLayout("Flow")
    scroll:AddChild(copyGroup)

    local copyDrop = AceGUI:Create("Dropdown")
    copyDrop:SetLabel(L["Copy Profile"] or "Source Profile to Copy From")
    copyDrop:SetList(otherProfiles)
    copyDrop:SetValue(selectedCopySource)
    copyDrop:SetRelativeWidth(0.65)
    copyDrop:SetCallback("OnValueChanged", function(_, _, val)
        selectedCopySource = val
    end)
    copyGroup:AddChild(copyDrop)

    local copyBtn = AceGUI:Create("Button")
    copyBtn:SetText(L["Copy"] or "Copy Into Current")
    copyBtn:SetRelativeWidth(0.35)
    copyBtn:SetCallback("OnClick", function()
        if not selectedCopySource or selectedCopySource == currentProfile then
            self:PrintError("Please select a source profile to copy from.")
            return
        end
        self.db:CopyProfile(selectedCopySource)
        self:OnProfileChanged()
        self:PrintInfo("Copied settings from '" .. selectedCopySource .. "' into '" .. currentProfile .. "'.")
        self:RefreshConfigUI()
    end)
    copyGroup:AddChild(copyBtn)

    --------------------------------------------------------
    -- 4. Delete Existing Profile
    --------------------------------------------------------
    local deleteGroup = AceGUI:Create("InlineGroup")
    deleteGroup:SetTitle(L["Delete Profile"] or "Delete Inactive Profile")
    deleteGroup:SetFullWidth(true)
    deleteGroup:SetLayout("Flow")
    scroll:AddChild(deleteGroup)

    local delDrop = AceGUI:Create("Dropdown")
    delDrop:SetLabel(L["Delete Profile"] or "Select Inactive Profile to Delete")
    delDrop:SetList(otherProfiles)
    delDrop:SetValue(selectedDeleteTarget)
    delDrop:SetRelativeWidth(0.65)
    delDrop:SetCallback("OnValueChanged", function(_, _, val)
        selectedDeleteTarget = val
    end)
    deleteGroup:AddChild(delDrop)

    local delBtn = AceGUI:Create("Button")
    delBtn:SetText(L["Delete"] or "Delete Profile")
    delBtn:SetRelativeWidth(0.35)
    delBtn:SetCallback("OnClick", function()
        if not selectedDeleteTarget or selectedDeleteTarget == currentProfile then
            self:PrintError("Please select an inactive profile to delete.")
            return
        end
        local dialog = StaticPopup_Show("GUILDGREET_CONFIRM_DELETE_PROFILE", selectedDeleteTarget)
        if dialog then
            dialog.data = selectedDeleteTarget
        end
    end)
    deleteGroup:AddChild(delBtn)
end
