------------------------------------------------------------
-- GuildGreet Modern GUI Core (Dark-Slate & Gold Theme)
-- Main configuration shell, sidebar navigation, font scaler,
-- minimap icon, and Blizzard Options integration
------------------------------------------------------------

local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", true)
local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
GuildGreet = GLDG

local UIStyle = GLDG.UIStyle

local mainWindow = nil
local headerFrame = nil
local footerFrame = nil
local sidebarFrame = nil
local statsBoxFrame = nil
local sectionBarFrame = nil
local verBadgeFrame = nil
local verBadgeText = nil
local contentHost = nil
local contentGroup = nil
local currentTab = "settings"
local sidebarButtons = {}
local sectionTitleText = nil
local sectionIconTex = nil
local sidebarStatsText = nil
local fontBadgeText = nil
local chromeButtons = {}
local footerFlowButtons = {}
local footerCloseButton = nil
local footerHintText = nil
local headerTitleText = nil
local headerSubText = nil
local navHeaderText = nil

local CATEGORIES = {
    {
        id    = "settings",
        label = L["Settings"] or "Settings",
        desc  = L["Configuration options to determine who, when and how to greet"] or "General, Chat, Greeting & Advanced options",
        icon  = "Interface\\Icons\\INV_Gizmo_02",
    },
    {
        id    = "greetings",
        label = L["Greetings"] or "Greetings",
        desc  = L["Manage the messages you want to use for greeting"] or "Manage greeting templates, categories & collections",
        icon  = "Interface\\Icons\\INV_Misc_Note_01",
    },
    {
        id    = "players",
        label = L["Players"] or "Players",
        desc  = L["Configure settings for characters: ignore them, set main/alt and enter alias"] or "Manage Main/Alt characters, aliases, notes & ignore list",
        icon  = "Interface\\Icons\\Achievement_GuildPerk_EverybodysFriend",
    },
    {
        id    = "cleanup",
        label = L["Cleanup"] or "Cleanup",
        desc  = L["Data cleanup"] or "Database maintenance, plausibility checks & backup",
        icon  = "Interface\\Icons\\INV_Misc_Bag_08",
    },
    {
        id    = "colour",
        label = L["Colour"] or "Colours",
        desc  = L["Colour Settings"] or "Customize chat & greeting queue colors",
        icon  = "Interface\\Icons\\INV_Enchant_EssenceAstralLarge",
    },
    {
        id    = "profiles",
        label = L["Profiles"] or "Profiles",
        desc  = L["Profile Management"] or "Manage AceDB configuration profiles",
        icon  = "Interface\\Icons\\INV_Misc_Book_09",
    },
}

local function UpdateSidebarStats()
    if not sidebarStatsText then return end
    UIStyle:ApplyFont(sidebarStatsText, -1)
    if GLDG.SyncDatabaseReferences then
        GLDG:SyncDatabaseReferences()
    end
    local curGuild = (GLDG.GetCurrentGuildName and GLDG:GetCurrentGuildName())
        or ((not IsInGuild or IsInGuild()) and ((GLDG.GuildName and GLDG.GuildName ~= "") and GLDG.GuildName or GetGuildInfo("player")) or "")
        or ""
    local playerCount = 0
    local mainCount = 0
    if curGuild ~= "" and GLDG_DataChar then
        for _, p in pairs(GLDG_DataChar) do
            playerCount = playerCount + 1
            if p and p.main then
                mainCount = mainCount + 1
            end
        end
    end
    local queueCount = 0
    if GLDG_Queue then
        for _ in pairs(GLDG_Queue) do
            queueCount = queueCount + 1
        end
    end
    local guildLabel = (curGuild ~= "") and curGuild or (L["No Guild"] or L["Guildless"] or "No Guild")
    sidebarStatsText:SetText(string.format(
        "%s%s:|r %s\n%s%s:|r %d (%d %s)\n%s%s:|r %d",
        UIStyle.Hex.gold, L["Guild"] or "Guild", guildLabel,
        UIStyle.Hex.gold, L["Players"] or "Players", playerCount, mainCount, L["Main"] or "Mains",
        UIStyle.Hex.gold, L["Queue"] or "Warteschlange", queueCount
    ))
end

function GLDG:RefreshSidebarStats()
    UpdateSidebarStats()
end

local function GetRecommendedWindowSize(fontSize)
    fontSize = fontSize or UIStyle:GetFontSize()
    local delta = math.max(0, fontSize - 12)
    local targetW = 1080 + delta * 52
    local targetH = 680 + delta * 26
    local maxW = math.max(960, (UIParent and UIParent:GetWidth() or 1920) - 40)
    local maxH = math.max(600, (UIParent and UIParent:GetHeight() or 1080) - 40)
    return math.min(targetW, maxW), math.min(targetH, maxH)
end

local function UpdateChromeFontsAndLayout(autoScaleWindow)
    if not mainWindow then return end

    local fontSize = UIStyle:GetFontSize()

    -- Scale window dimensions when font size changes or when first opened
    local recW, recH = GetRecommendedWindowSize(fontSize)
    if autoScaleWindow then
        if GLDG.db and GLDG.db.profile then
            GLDG.db.profile.UIWindowWidth = recW
            GLDG.db.profile.UIWindowHeight = recH
        end
        mainWindow:SetSize(recW, recH)
    else
        local savedW = GLDG.db and GLDG.db.profile and tonumber(GLDG.db.profile.UIWindowWidth)
        local savedH = GLDG.db and GLDG.db.profile and tonumber(GLDG.db.profile.UIWindowHeight)
        local w = math.max(recW, savedW or recW)
        local h = math.max(recH, savedH or recH)
        mainWindow:SetSize(w, h)
    end

    if headerFrame then
        headerFrame:SetHeight(math.max(56, fontSize * 2 + 30))
    end
    if footerFrame then
        footerFrame:SetHeight(math.max(44, fontSize + 30))
    end
    if sectionBarFrame then
        sectionBarFrame:SetHeight(math.max(40, fontSize + 26))
    end

    local sideW = math.max(215, math.floor(215 * (fontSize / 12.5)))
    if sidebarFrame then
        sidebarFrame:SetWidth(sideW)
    end
    if statsBoxFrame then
        statsBoxFrame:SetHeight(math.max(82, fontSize * 4 + 30))
    end

    if fontBadgeText then
        UIStyle:ApplyFont(fontBadgeText, -1)
        fontBadgeText:SetText(tostring(fontSize) .. "pt")
    end
    if headerTitleText then
        UIStyle:ApplyFont(headerTitleText, 3)
    end
    if headerSubText then
        UIStyle:ApplyFont(headerSubText, -1)
    end
    if verBadgeText and verBadgeFrame then
        UIStyle:ApplyFont(verBadgeText, -2)
        local vw = math.max(58, math.ceil((verBadgeText:GetStringWidth() or 40) + 18))
        local vh = math.max(20, fontSize + 6)
        verBadgeFrame:SetSize(vw, vh)
    end
    if navHeaderText then
        UIStyle:ApplyFont(navHeaderText, -1)
    end
    if sectionTitleText then
        UIStyle:ApplyFont(sectionTitleText, 1)
    end
    if footerHintText then
        UIStyle:ApplyFont(footerHintText, -1)
    end

    local btnH = math.max(38, fontSize + 24)
    local btnStep = btnH + 4
    for idx, cat in ipairs(CATEGORIES) do
        local btn = sidebarButtons[cat.id]
        if btn then
            btn:SetSize(sideW - 16, btnH)
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", sidebarFrame, "TOPLEFT", 8, -36 - (idx - 1) * btnStep)
            if btn.label then
                UIStyle:ApplyFont(btn.label, 0)
            end
        end
    end

    for _, btn in ipairs(chromeButtons) do
        if btn and btn.UpdateSize then
            btn:UpdateSize()
        end
    end

    -- Re-anchor footer buttons dynamically so long localized labels never overlap
    local prev = nil
    for _, btn in ipairs(footerFlowButtons) do
        if btn then
            btn:UpdateSize()
            btn:ClearAllPoints()
            if not prev then
                btn:SetPoint("LEFT", btn:GetParent(), "LEFT", 10, 0)
            else
                btn:SetPoint("LEFT", prev, "RIGHT", 8, 0)
            end
            prev = btn
        end
    end

    if footerCloseButton then
        footerCloseButton:UpdateSize()
        footerCloseButton:ClearAllPoints()
        footerCloseButton:SetPoint("RIGHT", footerCloseButton:GetParent(), "RIGHT", -24, 0)
    end

    UpdateSidebarStats()
end

function GLDG:ApplyUIFontSize()
    UpdateChromeFontsAndLayout(true)
    if self.RefreshConfigUI then
        self:RefreshConfigUI()
    end
    if self.ShowQueue then
        self:ShowQueue()
    end
end

local function SaveMainFramePosition(f)
    if not f or not GLDG.db or not GLDG.db.profile then return end
    local point, _, relativePoint, xOfs, yOfs = f:GetPoint(1)
    if point then
        GLDG.db.profile.ConfigFramePos = {
            point = point,
            relativePoint = relativePoint or point,
            x = math.floor((xOfs or 0) + 0.5),
            y = math.floor((yOfs or 0) + 0.5),
        }
    end
end

local function RestoreMainFramePosition(f)
    if not f then return end
    local pos = GLDG.db and GLDG.db.profile and GLDG.db.profile.ConfigFramePos
    f:ClearAllPoints()
    if type(pos) == "table" and pos.point then
        f:SetPoint(pos.point, UIParent, pos.relativePoint or pos.point, tonumber(pos.x) or 0, tonumber(pos.y) or 20)
    else
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
    end
end

local function CreateMainFrame()
    if mainWindow then
        return mainWindow
    end

    local frame = CreateFrame("Frame", "GuildGreetConfigFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    frame:Hide()
    local initW, initH = GetRecommendedWindowSize(UIStyle:GetFontSize())
    frame:SetSize(initW, initH)
    RestoreMainFramePosition(frame)
    frame:SetFrameStrata("HIGH")
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(940, 560, 1750, 1150)
    else
        if frame.SetMinResize then frame:SetMinResize(940, 560) end
        if frame.SetMaxResize then frame:SetMaxResize(1750, 1150) end
    end
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(f) f:StartMoving() end)
    frame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()
        SaveMainFramePosition(f)
    end)
    UIStyle:ApplyBox(frame, UIStyle.Colors.bgMain, UIStyle.Colors.border)

    -- Allow closing with ESC
    tinsert(UISpecialFrames, "GuildGreetConfigFrame")

    --------------------------------------------------------
    -- Top Header Bar (dynamic height, min 56px)
    --------------------------------------------------------
    local header = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    header:SetHeight(56)
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
    header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
    UIStyle:ApplyBox(header, UIStyle.Colors.bgHeader, UIStyle.Colors.borderSubtle)
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function() frame:StartMoving() end)
    header:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        SaveMainFramePosition(frame)
    end)
    headerFrame = header

    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("LEFT", header, "LEFT", 12, 0)
    icon:SetTexture("Interface\\Icons\\Achievement_GuildPerk_EverybodysFriend")
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 12, 3)
    title:SetText("GUILDGREET EXTENDED")
    title:SetTextColor(unpack(UIStyle.Colors.gold))
    headerTitleText = title

    local subtitle = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    subtitle:SetText(L["A tool to manage mains and alts in the guild and greet them"] or "Social Guild & Character Greeting Assistant")
    subtitle:SetTextColor(unpack(UIStyle.Colors.textMuted))
    headerSubText = subtitle

    -- Version Badge
    local ver = GLDG_GetAddOnMetadata and GLDG_GetAddOnMetadata("GuildGreet", "Version") or "13.0.0"
    local verBadge = CreateFrame("Frame", nil, header, "BackdropTemplate")
    verBadge:SetSize(64, 20)
    verBadge:SetPoint("LEFT", title, "RIGHT", 10, 0)
    UIStyle:ApplyBox(verBadge, UIStyle.Colors.bgRowActive, UIStyle.Colors.borderHighlight)
    verBadgeFrame = verBadge
    local verText = verBadge:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    verText:SetPoint("CENTER", 0, 0)
    verText:SetText("v" .. tostring(ver))
    verText:SetTextColor(unpack(UIStyle.Colors.gold))
    verBadgeText = verText

    -- Close Button (Icon)
    local closeBtn = CreateFrame("Button", nil, header, "BackdropTemplate")
    closeBtn:SetSize(28, 28)
    closeBtn:SetPoint("RIGHT", header, "RIGHT", -10, 0)
    UIStyle:ApplyBox(closeBtn, { 0.18, 0.14, 0.16, 1 }, { 0.38, 0.26, 0.30, 1 })
    local closeIcon = closeBtn:CreateTexture(nil, "OVERLAY")
    closeIcon:SetSize(14, 14)
    closeIcon:SetPoint("CENTER", 0, 0)
    closeIcon:SetTexture("Interface\\Buttons\\UI-StopButton")
    closeIcon:SetVertexColor(0.92, 0.75, 0.78, 1)
    closeBtn.Icon = closeIcon
    closeBtn:SetScript("OnEnter", function(btn)
        UIStyle:ApplyBox(btn, { 0.68, 0.18, 0.22, 1 }, { 0.95, 0.35, 0.40, 1 })
        closeIcon:SetVertexColor(1, 1, 1, 1)
    end)
    closeBtn:SetScript("OnLeave", function(btn)
        UIStyle:ApplyBox(btn, { 0.18, 0.14, 0.16, 1 }, { 0.38, 0.26, 0.30, 1 })
        closeIcon:SetVertexColor(0.92, 0.75, 0.78, 1)
    end)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    -- Header Quick Test Queue Button
    local testQueueBtn = UIStyle:CreateButton(header, L["Test trigger"] or "Test Queue", 96, 26, function()
        if GLDG_CreateTestChars then
            GLDG_CreateTestChars()
            UpdateSidebarStats()
        end
    end, false)
    testQueueBtn:SetPoint("RIGHT", closeBtn, "LEFT", -8, 0)
    table.insert(chromeButtons, testQueueBtn)

    -- Font Size Controls (A- | 13pt | A+)
    local fontPlusBtn = UIStyle:CreateButton(header, "A+", 34, 26, function()
        UIStyle:SetFontSize(UIStyle:GetFontSize() + 1)
    end, false)
    fontPlusBtn:SetPoint("RIGHT", testQueueBtn, "LEFT", -10, 0)
    table.insert(chromeButtons, fontPlusBtn)

    local fontBadge = CreateFrame("Frame", nil, header, "BackdropTemplate")
    fontBadge:SetSize(44, 26)
    fontBadge:SetPoint("RIGHT", fontPlusBtn, "LEFT", -4, 0)
    UIStyle:ApplyBox(fontBadge, UIStyle.Colors.bgInput, UIStyle.Colors.borderSubtle)
    fontBadgeText = fontBadge:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fontBadgeText:SetPoint("CENTER", 0, 0)
    fontBadgeText:SetTextColor(unpack(UIStyle.Colors.gold))
    fontBadgeText:SetText(tostring(UIStyle:GetFontSize()) .. "pt")

    local fontMinusBtn = UIStyle:CreateButton(header, "A-", 34, 26, function()
        UIStyle:SetFontSize(UIStyle:GetFontSize() - 1)
    end, false)
    fontMinusBtn:SetPoint("RIGHT", fontBadge, "LEFT", -4, 0)
    table.insert(chromeButtons, fontMinusBtn)

    -- Gold accent line at bottom of header
    local goldLine = header:CreateTexture(nil, "OVERLAY")
    goldLine:SetHeight(1)
    goldLine:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
    goldLine:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
    goldLine:SetColorTexture(0.85, 0.71, 0.29, 0.75)

    --------------------------------------------------------
    -- Bottom Footer Bar (dynamic height, min 44px)
    --------------------------------------------------------
    local footer = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    footer:SetHeight(44)
    footer:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
    footer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
    UIStyle:ApplyBox(footer, UIStyle.Colors.bgHeader, UIStyle.Colors.borderSubtle)
    footerFrame = footer

    local greetGuildBtn = UIStyle:CreateButton(footer, L["Greet Guild and Channel"] or "Greet Guild", 130, 26, function()
        if GLDG_KeyGreet then GLDG_KeyGreet() end
    end, true)

    local byeGuildBtn = UIStyle:CreateButton(footer, L["Good bye"] or "Say Goodbye", 110, 26, function()
        if GLDG_KeyBye then GLDG_KeyBye() end
    end, false)

    local laterGuildBtn = UIStyle:CreateButton(footer, L["Say see you later to guild and channel"] or "See You Later", 115, 26, function()
        if GLDG_KeyLater then GLDG_KeyLater() end
    end, false)

    local clearQueueBtn = UIStyle:CreateButton(footer, L["Clear greet list"] or "Clear Queue", 120, 26, function()
        if GLDG_ClearList then
            GLDG_ClearList()
            UpdateSidebarStats()
        end
    end, false)

    footerFlowButtons = { greetGuildBtn, byeGuildBtn, laterGuildBtn, clearQueueBtn }

    footerCloseButton = UIStyle:CreateButton(footer, L["Close"] or CLOSE or "Close", 90, 26, function()
        frame:Hide()
    end, false)

    local footerHint = footer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    footerHint:SetPoint("RIGHT", footerCloseButton, "LEFT", -14, 0)
    footerHint:SetText("|cff9499a8/gg|r | |cffd9b54a/guildgreet|r")
    footerHintText = footerHint

    -- Bottom-right Resize Grip Handle
    local resizeGrip = CreateFrame("Button", nil, footer)
    resizeGrip:SetSize(16, 16)
    resizeGrip:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
    resizeGrip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeGrip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeGrip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeGrip:SetScript("OnMouseDown", function(_, btn)
        if btn == "LeftButton" then
            frame:StartSizing("BOTTOMRIGHT")
        end
    end)
    resizeGrip:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
        if GLDG.db and GLDG.db.profile then
            GLDG.db.profile.UIWindowWidth = math.floor(frame:GetWidth() + 0.5)
            GLDG.db.profile.UIWindowHeight = math.floor(frame:GetHeight() + 0.5)
        end
        if contentGroup and contentGroup.DoLayout then
            pcall(function() contentGroup:DoLayout() end)
        end
    end)

    frame:SetScript("OnSizeChanged", function()
        if contentGroup then
            if contentHost then
                local w, h = contentHost:GetWidth(), contentHost:GetHeight()
                if w and w > 0 then contentGroup:SetWidth(w) end
                if h and h > 0 then contentGroup:SetHeight(h) end
            end
            if contentGroup.DoLayout then
                pcall(function() contentGroup:DoLayout() end)
            end
        end
    end)

    --------------------------------------------------------
    -- Left Category Sidebar (dynamic width, min 215px)
    --------------------------------------------------------
    local sidebar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    sidebar:SetWidth(215)
    sidebar:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
    sidebar:SetPoint("BOTTOMLEFT", footer, "TOPLEFT", 0, 0)
    UIStyle:ApplyBox(sidebar, UIStyle.Colors.bgSidebar, UIStyle.Colors.borderSubtle)
    sidebarFrame = sidebar

    local navHeader = sidebar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    navHeader:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 14, -14)
    navHeader:SetText("NAVIGATION")
    navHeader:SetTextColor(unpack(UIStyle.Colors.goldDim))
    navHeaderText = navHeader

    for idx, cat in ipairs(CATEGORIES) do
        local btn = CreateFrame("Button", nil, sidebar, "BackdropTemplate")
        btn:SetSize(199, 38)
        btn:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 8, -36 - (idx - 1) * 42)
        UIStyle:ApplyBox(btn, UIStyle.Colors.bgRow, UIStyle.Colors.borderSubtle)

        local activeBar = btn:CreateTexture(nil, "OVERLAY")
        activeBar:SetWidth(3)
        activeBar:SetPoint("TOPLEFT", btn, "TOPLEFT", 1, -1)
        activeBar:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 1, 1)
        activeBar:SetColorTexture(unpack(UIStyle.Colors.gold))
        activeBar:Hide()
        btn.activeBar = activeBar

        local catIcon = btn:CreateTexture(nil, "ARTWORK")
        catIcon:SetSize(22, 22)
        catIcon:SetPoint("LEFT", btn, "LEFT", 12, 0)
        catIcon:SetTexture(cat.icon)
        catIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        btn.icon = catIcon

        local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", catIcon, "RIGHT", 10, 0)
        label:SetPoint("RIGHT", btn, "RIGHT", -6, 0)
        label:SetJustifyH("LEFT")
        label:SetWordWrap(false)
        label:SetText(cat.label)
        label:SetTextColor(unpack(UIStyle.Colors.textLight))
        btn.label = label

        btn:SetScript("OnEnter", function(selfBtn)
            if currentTab ~= cat.id then
                UIStyle:ApplyBox(selfBtn, UIStyle.Colors.bgRowHover, UIStyle.Colors.border)
                selfBtn.label:SetTextColor(1, 0.92, 0.65, 1)
            end
        end)
        btn:SetScript("OnLeave", function(selfBtn)
            if currentTab ~= cat.id then
                UIStyle:ApplyBox(selfBtn, UIStyle.Colors.bgRow, UIStyle.Colors.borderSubtle)
                selfBtn.label:SetTextColor(unpack(UIStyle.Colors.textLight))
            end
        end)
        btn:SetScript("OnClick", function()
            GLDG:SelectTab(cat.id)
        end)

        sidebarButtons[cat.id] = btn
    end

    -- Sidebar Info Box at bottom
    local statsBox = CreateFrame("Frame", nil, sidebar, "BackdropTemplate")
    statsBox:SetPoint("BOTTOMLEFT", sidebar, "BOTTOMLEFT", 8, 10)
    statsBox:SetPoint("BOTTOMRIGHT", sidebar, "BOTTOMRIGHT", -8, 10)
    statsBox:SetHeight(82)
    UIStyle:ApplyBox(statsBox, UIStyle.Colors.bgPanel, UIStyle.Colors.borderSubtle)
    statsBoxFrame = statsBox

    sidebarStatsText = statsBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sidebarStatsText:SetPoint("TOPLEFT", statsBox, "TOPLEFT", 10, -10)
    sidebarStatsText:SetPoint("BOTTOMRIGHT", statsBox, "BOTTOMRIGHT", -10, 10)
    sidebarStatsText:SetJustifyH("LEFT")
    sidebarStatsText:SetJustifyV("TOP")
    sidebarStatsText:SetTextColor(unpack(UIStyle.Colors.textLight))

    --------------------------------------------------------
    -- Right Content Area
    --------------------------------------------------------
    local rightPane = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    rightPane:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 0, 0)
    rightPane:SetPoint("BOTTOMRIGHT", footer, "TOPRIGHT", 0, 0)
    UIStyle:ApplyBox(rightPane, UIStyle.Colors.bgPanel, UIStyle.Colors.borderSubtle)

    -- Section Bar (40px)
    local sectionBar = CreateFrame("Frame", nil, rightPane, "BackdropTemplate")
    sectionBar:SetHeight(40)
    sectionBar:SetPoint("TOPLEFT", rightPane, "TOPLEFT", 8, -8)
    sectionBar:SetPoint("TOPRIGHT", rightPane, "TOPRIGHT", -8, -8)
    UIStyle:ApplyBox(sectionBar, UIStyle.Colors.bgHeader, UIStyle.Colors.borderSubtle)
    sectionBarFrame = sectionBar

    sectionIconTex = sectionBar:CreateTexture(nil, "ARTWORK")
    sectionIconTex:SetSize(22, 22)
    sectionIconTex:SetPoint("LEFT", sectionBar, "LEFT", 10, 0)
    sectionIconTex:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local refreshBtn = UIStyle:CreateButton(sectionBar, L["Refresh"] or "Refresh", 86, 26, function()
        GLDG:RefreshConfigUI()
    end, false)
    refreshBtn:SetPoint("RIGHT", sectionBar, "RIGHT", -8, 0)
    table.insert(chromeButtons, refreshBtn)

    sectionTitleText = sectionBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sectionTitleText:SetPoint("LEFT", sectionIconTex, "RIGHT", 10, 0)
    sectionTitleText:SetPoint("RIGHT", refreshBtn, "LEFT", -10, 0)
    sectionTitleText:SetJustifyH("LEFT")
    sectionTitleText:SetWordWrap(false)
    sectionTitleText:SetTextColor(unpack(UIStyle.Colors.gold))

    -- Host Frame for AceGUI SimpleGroup
    contentHost = CreateFrame("Frame", nil, rightPane)
    contentHost:SetPoint("TOPLEFT", sectionBar, "BOTTOMLEFT", 0, -6)
    contentHost:SetPoint("BOTTOMRIGHT", rightPane, "BOTTOMRIGHT", -8, 8)

    frame:SetScript("OnShow", function()
        UpdateChromeFontsAndLayout()
        GLDG:SelectTab(currentTab or "settings")
    end)
    frame:SetScript("OnHide", function()
        if GLDG.HidePlayerEditPopup then
            GLDG:HidePlayerEditPopup()
        end
    end)

    mainWindow = frame
    UpdateChromeFontsAndLayout()
    return frame
end

function GLDG:SelectTab(tab)
    tab = string.lower(tostring(tab or "settings"))
    if tab == "colors" or tab == "color" or tab == "colours" then
        tab = "colour"
    elseif tab == "profile" then
        tab = "profiles"
    elseif tab == "player" then
        tab = "players"
    elseif tab == "greeting" then
        tab = "greetings"
    end

    currentTab = tab
    CreateMainFrame()
    UpdateChromeFontsAndLayout()

    -- Update sidebar button states
    local activeMeta = CATEGORIES[1]
    for _, cat in ipairs(CATEGORIES) do
        local btn = sidebarButtons[cat.id]
        if btn then
            if cat.id == tab then
                activeMeta = cat
                UIStyle:ApplyBox(btn, UIStyle.Colors.bgRowActive, UIStyle.Colors.borderHighlight)
                btn.activeBar:Show()
                btn.label:SetTextColor(unpack(UIStyle.Colors.gold))
            else
                UIStyle:ApplyBox(btn, UIStyle.Colors.bgRow, UIStyle.Colors.borderSubtle)
                btn.activeBar:Hide()
                btn.label:SetTextColor(unpack(UIStyle.Colors.textLight))
            end
        end
    end

    if sectionIconTex and activeMeta then
        sectionIconTex:SetTexture(activeMeta.icon)
    end
    if sectionTitleText and activeMeta then
        sectionTitleText:SetText(activeMeta.label .. "  |cff9499a8—  " .. activeMeta.desc .. "|r")
    end

    UpdateSidebarStats()

    -- Rebuild AceGUI container inside contentHost
    if contentGroup then
        contentGroup:ReleaseChildren()
        contentGroup:Release()
        contentGroup = nil
    end

    if tab ~= "players" and self.HidePlayersTabPanel then
        self:HidePlayersTabPanel()
    end

    if tab == "players" and self.ShowPlayersTabPanel then
        self:ShowPlayersTabPanel(contentHost)
        return
    end

    contentGroup = AceGUI:Create("SimpleGroup")
    contentGroup.frame:SetParent(contentHost)
    contentGroup.frame:ClearAllPoints()
    contentGroup.frame:SetAllPoints(contentHost)
    contentGroup.frame:Show()
    local hostW, hostH = contentHost:GetWidth(), contentHost:GetHeight()
    if hostW and hostW > 0 then
        contentGroup:SetWidth(hostW)
    end
    if hostH and hostH > 0 then
        contentGroup:SetHeight(hostH)
    end
    contentGroup:SetLayout("Fill")

    if tab == "settings" and self.CreateSettingsTab then
        self:CreateSettingsTab(contentGroup)
    elseif tab == "greetings" and self.CreateGreetingsTab then
        self:CreateGreetingsTab(contentGroup)
    elseif tab == "players" and self.CreatePlayersTab then
        self:CreatePlayersTab(contentGroup)
    elseif tab == "cleanup" and self.CreateCleanupTab then
        self:CreateCleanupTab(contentGroup)
    elseif tab == "colour" and self.CreateColourTab then
        self:CreateColourTab(contentGroup)
    elseif tab == "profiles" and self.CreateProfilesTab then
        self:CreateProfilesTab(contentGroup)
    end

    UIStyle:StyleAceWidgetsRecursive(contentGroup)
end

function GLDG:RefreshConfigUI()
    if mainWindow and mainWindow:IsShown() then
        self:SelectTab(currentTab or "settings")
    end
end

function GLDG:ShowConfigWindow(tab)
    local frame = CreateMainFrame()
    if tab then
        currentTab = tab
    end
    if frame:IsShown() then
        UpdateChromeFontsAndLayout()
        self:SelectTab(currentTab or "settings")
    else
        frame:Show()
    end
    frame:Raise()
end

function GLDG:HideConfigWindow()
    if mainWindow and mainWindow:IsShown() then
        mainWindow:Hide()
    end
end

function GLDG:ToggleConfigWindow(tab)
    if mainWindow and mainWindow:IsShown() then
        if tab and tab ~= currentTab then
            self:SelectTab(tab)
            mainWindow:Raise()
        else
            mainWindow:Hide()
        end
    else
        self:ShowConfigWindow(tab)
    end
end

------------------------------------------------------------
-- Addon Compartment & Minimap Button (LibDBIcon-1.0)
------------------------------------------------------------
function GuildGreet_OnAddonCompartmentClick(_, buttonName)
    if buttonName == "RightButton" then
        GLDG:ShowConfigWindow("players")
    else
        GLDG:ToggleConfigWindow()
    end
end

function GuildGreet_OnAddonCompartmentEnter(_, menuButtonFrame)
    GameTooltip:SetOwner(menuButtonFrame, "ANCHOR_LEFT")
    GameTooltip:SetText("|cffd9b54aGuildGreet Extended|r")
    GameTooltip:AddLine((L["Left-Click"] or "Linksklick") .. ": " .. (L["Toggle main window"] or "Hauptfenster umschalten"), 0.9, 0.9, 0.9)
    GameTooltip:AddLine((L["Right-Click"] or "Rechtsklick") .. ": " .. (L["Open players tab"] or "Spieler-Tab öffnen"), 0.9, 0.9, 0.9)
    GameTooltip:Show()
end

function GuildGreet_OnAddonCompartmentLeave()
    GameTooltip:Hide()
end

local function SetupMinimapAndBlizzardOptions()
    local LDB = LibStub("LibDataBroker-1.1", true)
    local LDBIcon = LibStub("LibDBIcon-1.0", true)
    if LDB then
        local dataObj = LDB:GetDataObjectByName("GuildGreet") or LDB:NewDataObject("GuildGreet", {
            type = "launcher",
            text = "GuildGreet",
            icon = "Interface\\Icons\\Achievement_GuildPerk_EverybodysFriend",
            OnClick = function(_, button)
                if button == "RightButton" then
                    if IsShiftKeyDown() and GLDG_ClearList then
                        GLDG_ClearList()
                    else
                        GLDG:ToggleConfigWindow("players")
                    end
                else
                    GLDG:ToggleConfigWindow()
                end
            end,
            OnTooltipShow = function(tt)
                tt:AddLine("|cffd9b54aGuildGreet Extended|r")
                tt:AddLine("|cff4cd973" .. (L["Left-Click"] or "Linksklick") .. ":|r " .. (L["Toggle main window"] or "Hauptfenster umschalten"), 0.9, 0.9, 0.9)
                tt:AddLine("|cff4cd973" .. (L["Right-Click"] or "Rechtsklick") .. ":|r " .. (L["Open players tab"] or "Spieler-Tab öffnen"), 0.9, 0.9, 0.9)
                tt:AddLine("|cff4cd973Shift + " .. (L["Right-Click"] or "Rechtsklick") .. ":|r " .. (L["Clear greet list"] or "Begrüßungsliste leeren"), 0.9, 0.9, 0.9)
            end,
        })
        if LDBIcon and GLDG.db and GLDG.db.profile then
            GLDG.db.profile.minimap = GLDG.db.profile.minimap or { hide = false }
            if not LDBIcon:IsRegistered("GuildGreet") then
                LDBIcon:Register("GuildGreet", dataObj, GLDG.db.profile.minimap)
            end
        end
    end

    if not GLDG._blizzOptionsPanel then
        local panel = CreateFrame("Frame", "GuildGreetBlizzOptionsPanel", UIParent, "BackdropTemplate")
        panel.name = "GuildGreet"
        UIStyle:ApplyBox(panel, UIStyle.Colors.bgMain, UIStyle.Colors.border)

        local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOPLEFT", 20, -20)
        title:SetText("|cffd9b54aGuildGreet Extended|r")

        local desc = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
        desc:SetWidth(520)
        desc:SetJustifyH("LEFT")
        desc:SetText(L["A tool to manage mains and alts in the guild and greet them"] or "Social guild & character greeting assistant.")

        local openBtn = UIStyle:CreateButton(panel, L["Open config window"] or "Open Configuration", 180, 30, function()
            GLDG:ShowConfigWindow("settings")
        end, true)
        openBtn:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -20)

        local playersBtn = UIStyle:CreateButton(panel, L["Players"] or "Manage Players", 160, 30, function()
            GLDG:ShowConfigWindow("players")
        end, false)
        playersBtn:SetPoint("LEFT", openBtn, "RIGHT", 10, 0)

        GLDG_OnLoadOptions(panel)
        GLDG._blizzOptionsPanel = panel
    end
end

function GLDG:InitializeGUI()
    SetupMinimapAndBlizzardOptions()
end
