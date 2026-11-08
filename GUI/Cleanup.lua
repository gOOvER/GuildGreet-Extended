------------------------------------------------------------
-- GuildGreet Modern GUI - Cleanup & Maintenance Tab
-- Database statistics, orphan/guildless cleanup, plausibility fix,
-- and safe AceSerializer-3.0 export/import
------------------------------------------------------------

local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", true)
local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
GuildGreet = GLDG

local UIStyle = GLDG.UIStyle

local selectedGuildToRemove = nil
local selectedChannelToRemove = nil
local selectedFriendToRemove = nil

local function CollectStats()
    local total = 0
    local mains = 0
    local alts = 0
    local guildless = 0
    local orphans = 0
    local ignored = 0
    local guilds = {}
    local channels = {}
    local friends = {}

    if GLDG_DataChar then
        for _, p in pairs(GLDG_DataChar) do
            if type(p) == "table" then
                total = total + 1
                if p.main then mains = mains + 1 end
                if p.alt then alts = alts + 1 end
                if p.ignore then ignored = ignored + 1 end
                if not p.guild or p.guild == "" then
                    guildless = guildless + 1
                else
                    guilds[p.guild] = (guilds[p.guild] or 0) + 1
                end
                if p.channels then
                    for ch in pairs(p.channels) do
                        channels[ch] = (channels[ch] or 0) + 1
                    end
                end
                if p.friends then
                    for fr in pairs(p.friends) do
                        friends[fr] = (friends[fr] or 0) + 1
                    end
                end
                local hasFriends = p.friends and (GLDG_TableSize(p.friends) > 0)
                local hasChannels = p.channels and (GLDG_TableSize(p.channels) > 0)
                if not p.guild and not p.main and not p.alt and not p.alias and not hasFriends and not hasChannels then
                    orphans = orphans + 1
                end
            end
        end
    end

    return {
        total = total,
        mains = mains,
        alts = alts,
        guildless = guildless,
        orphans = orphans,
        ignored = ignored,
        guilds = guilds,
        channels = channels,
        friends = friends,
    }
end

function GLDG:CreateCleanupTab(container)
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    container:AddChild(scroll)

    local stats = CollectStats()

    --------------------------------------------------------
    -- 1. Database Statistics Overview
    --------------------------------------------------------
    local statsGroup = AceGUI:Create("InlineGroup")
    statsGroup:SetTitle(L["Data cleanup"] or "Database Overview")
    statsGroup:SetFullWidth(true)
    statsGroup:SetLayout("Flow")
    scroll:AddChild(statsGroup)

    local statLabel = AceGUI:Create("Label")
    statLabel:SetFullWidth(true)
    statLabel:SetText(string.format(
        "%s%s:|r %d    %s%s:|r %d    %s%s:|r %d    %s%s:|r %d\n" ..
        "%s%s:|r %d    %s%s:|r %d",
        UIStyle.Hex.gold, L["Players"] or "Total Characters", stats.total,
        UIStyle.Hex.green, L["Main"] or "Mains", stats.mains,
        UIStyle.Hex.cyan, L["Alts"] or "Alts", stats.alts,
        UIStyle.Hex.red, L["Ignored"] or "Ignored", stats.ignored,
        UIStyle.Hex.goldDim, L["Guildless"] or "Guildless", stats.guildless,
        UIStyle.Hex.goldDim, L["Orphan cleanup"] or "Orphans", stats.orphans
    ))
    statsGroup:AddChild(statLabel)

    --------------------------------------------------------
    -- 2. Automated Maintenance & Cleanup Actions
    --------------------------------------------------------
    local maintGroup = AceGUI:Create("InlineGroup")
    maintGroup:SetTitle(L["Data cleanup"] or "Database Maintenance & Cleanup")
    maintGroup:SetFullWidth(true)
    maintGroup:SetLayout("Flow")
    scroll:AddChild(maintGroup)

    local orphanBtn = AceGUI:Create("Button")
    orphanBtn:SetText((L["Orphan cleanup"] or "Clean Orphans") .. " (" .. stats.orphans .. ")")
    orphanBtn:SetRelativeWidth(0.33)
    orphanBtn:SetCallback("OnClick", function()
        GLDG_ClickOrphanCleanup()
        GLDG:RefreshConfigUI()
    end)
    maintGroup:AddChild(orphanBtn)

    local guildlessDispBtn = AceGUI:Create("Button")
    guildlessDispBtn:SetText((L["Guildless display"] or "List Guildless") .. " (" .. stats.guildless .. ")")
    guildlessDispBtn:SetRelativeWidth(0.33)
    guildlessDispBtn:SetCallback("OnClick", function()
        GLDG_ClickGuildlessDisplay()
    end)
    maintGroup:AddChild(guildlessDispBtn)

    local guildlessCleanBtn = AceGUI:Create("Button")
    guildlessCleanBtn:SetText(L["Guildless cleanup"] or "Remove Guildless")
    guildlessCleanBtn:SetRelativeWidth(0.34)
    guildlessCleanBtn:SetCallback("OnClick", function()
        GLDG_ClickGuildlessCleanup()
        GLDG:RefreshConfigUI()
    end)
    maintGroup:AddChild(guildlessCleanBtn)

    local checkBtn = AceGUI:Create("Button")
    checkBtn:SetText(L["Check consistency"] or "Check Main/Alt Relations")
    checkBtn:SetRelativeWidth(0.33)
    checkBtn:SetCallback("OnClick", function()
        GLDG_Convert_Plausibility_Check(false)
    end)
    maintGroup:AddChild(checkBtn)

    local fixBtn = AceGUI:Create("Button")
    fixBtn:SetText(L["Fix inconsistencies"] or "Auto-Fix Main/Alt Relations")
    fixBtn:SetRelativeWidth(0.33)
    fixBtn:SetCallback("OnClick", function()
        GLDG_fixCount = 0
        GLDG_Convert_Plausibility_Fix(false)
        GLDG:RefreshConfigUI()
    end)
    maintGroup:AddChild(fixBtn)

    local unnewBtn = AceGUI:Create("Button")
    unnewBtn:SetText(L["Clearing 'new in guild' flag for all characters"] or "Clear 'New in Guild' Flags")
    unnewBtn:SetRelativeWidth(0.34)
    unnewBtn:SetCallback("OnClick", function()
        GLDG_Convert_Unnew()
        GLDG:RefreshConfigUI()
    end)
    maintGroup:AddChild(unnewBtn)

    --------------------------------------------------------
    -- 3. Remove Specific Guild / Channel / Friend References
    --------------------------------------------------------
    local refGroup = AceGUI:Create("InlineGroup")
    refGroup:SetTitle(L["Guild cleanup"] or "Remove Stored Guild, Channel or Friend References")
    refGroup:SetFullWidth(true)
    refGroup:SetLayout("Flow")
    scroll:AddChild(refGroup)

    -- Guild removal
    local guildDrop = AceGUI:Create("Dropdown")
    guildDrop:SetLabel(L["Select a guild to remove"] or "Select Guild to Remove")
    local guildMap = {}
    for gName, cnt in pairs(stats.guilds) do
        guildMap[gName] = string.format("%s (%d)", gName, cnt)
    end
    guildDrop:SetList(guildMap)
    guildDrop:SetValue(selectedGuildToRemove)
    guildDrop:SetRelativeWidth(0.65)
    guildDrop:SetCallback("OnValueChanged", function(_, _, val)
        selectedGuildToRemove = val
    end)
    refGroup:AddChild(guildDrop)

    local removeGuildBtn = AceGUI:Create("Button")
    removeGuildBtn:SetText(L["Guild cleanup"] or "Remove Guild Ref")
    removeGuildBtn:SetRelativeWidth(0.35)
    removeGuildBtn:SetCallback("OnClick", function()
        if not selectedGuildToRemove then return end
        GLDG_CleanupList = { selectedGuildToRemove }
        GLDG_CleanupMode = "guild"
        GLDG_CleanupExecute(selectedGuildToRemove)
        selectedGuildToRemove = nil
        GLDG:RefreshConfigUI()
    end)
    refGroup:AddChild(removeGuildBtn)

    -- Channel removal
    local chanDrop = AceGUI:Create("Dropdown")
    chanDrop:SetLabel(L["Select a channel to remove"] or "Select Channel to Remove")
    local chanMap = {}
    for cName, cnt in pairs(stats.channels) do
        chanMap[cName] = string.format("%s (%d)", cName, cnt)
    end
    chanDrop:SetList(chanMap)
    chanDrop:SetValue(selectedChannelToRemove)
    chanDrop:SetRelativeWidth(0.65)
    chanDrop:SetCallback("OnValueChanged", function(_, _, val)
        selectedChannelToRemove = val
    end)
    refGroup:AddChild(chanDrop)

    local removeChanBtn = AceGUI:Create("Button")
    removeChanBtn:SetText(L["Channel cleanup"] or "Remove Channel Ref")
    removeChanBtn:SetRelativeWidth(0.35)
    removeChanBtn:SetCallback("OnClick", function()
        if not selectedChannelToRemove then return end
        GLDG_CleanupList = { selectedChannelToRemove }
        GLDG_CleanupMode = "channel"
        GLDG_CleanupExecute(selectedChannelToRemove)
        selectedChannelToRemove = nil
        GLDG:RefreshConfigUI()
    end)
    refGroup:AddChild(removeChanBtn)

    -- Friend char removal
    local friendDrop = AceGUI:Create("Dropdown")
    friendDrop:SetLabel(L["Select a friend to remove"] or "Select Friend List Owner to Remove")
    local friendMap = {}
    for fName, cnt in pairs(stats.friends) do
        friendMap[fName] = string.format("%s (%d)", fName, cnt)
    end
    friendDrop:SetList(friendMap)
    friendDrop:SetValue(selectedFriendToRemove)
    friendDrop:SetRelativeWidth(0.65)
    friendDrop:SetCallback("OnValueChanged", function(_, _, val)
        selectedFriendToRemove = val
    end)
    refGroup:AddChild(friendDrop)

    local removeFriendBtn = AceGUI:Create("Button")
    removeFriendBtn:SetText(L["Friends cleanup"] or "Remove Friend Ref")
    removeFriendBtn:SetRelativeWidth(0.35)
    removeFriendBtn:SetCallback("OnClick", function()
        if not selectedFriendToRemove then return end
        GLDG_CleanupList = { selectedFriendToRemove }
        GLDG_CleanupMode = "friends"
        GLDG_CleanupExecute(selectedFriendToRemove)
        selectedFriendToRemove = nil
        GLDG:RefreshConfigUI()
    end)
    refGroup:AddChild(removeFriendBtn)

    --------------------------------------------------------
    -- 4. Safe Export / Import via AceSerializer-3.0
    --------------------------------------------------------
    local ioGroup = AceGUI:Create("InlineGroup")
    ioGroup:SetTitle((L["Export settings"] or "Export") .. " / " .. (L["Import settings"] or "Import"))
    ioGroup:SetFullWidth(true)
    ioGroup:SetLayout("Flow")
    scroll:AddChild(ioGroup)

    local ioBox = AceGUI:Create("MultiLineEditBox")
    ioBox:SetLabel(L["Export settings"] or "Backup String")
    ioBox:SetNumLines(5)
    ioBox:SetFullWidth(true)
    ioBox:DisableButton(true)
    ioGroup:AddChild(ioBox)

    local exportBtn = AceGUI:Create("Button")
    exportBtn:SetText(L["Export settings"] or "Generate Export Backup")
    exportBtn:SetRelativeWidth(0.50)
    exportBtn:SetCallback("OnClick", function()
        local payload = {
            version = "3.1.0",
            greetings = GLDG_DataGreet,
            collections = GLDG_Data.Collections,
            colours = GLDG_Data.colours,
        }
        local serialized = GLDG:Serialize(payload)
        ioBox:SetText(serialized or "")
        GLDG:PrintInfo("Export string generated.")
    end)
    ioGroup:AddChild(exportBtn)

    local importBtn = AceGUI:Create("Button")
    importBtn:SetText(L["Import settings"] or "Import Backup String")
    importBtn:SetRelativeWidth(0.50)
    importBtn:SetCallback("OnClick", function()
        local raw = strtrim(ioBox:GetText() or "")
        if raw == "" then
            GLDG:PrintError("Please paste a valid backup string first.")
            return
        end
        local ok, data = GLDG:Deserialize(raw)
        if not ok or type(data) ~= "table" then
            GLDG:PrintError("Invalid backup string.")
            return
        end
        if type(data.greetings) == "table" then
            for k, v in pairs(data.greetings) do
                if type(v) == "table" then
                    GLDG_DataGreet[k] = v
                end
            end
        end
        if type(data.collections) == "table" then
            for k, v in pairs(data.collections) do
                if type(v) == "table" then
                    GLDG_Data.Collections[k] = v
                end
            end
        end
        if type(data.colours) == "table" then
            GLDG_Data.colours = data.colours
            if GLDG.Colors and GLDG.Colors.Initialize then
                GLDG.Colors:Initialize()
            end
        end
        GLDG:SyncDatabaseReferences()
        GLDG:PrintInfo("Backup imported successfully!")
        GLDG:RefreshConfigUI()
    end)
    ioGroup:AddChild(importBtn)
end
