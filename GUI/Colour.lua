------------------------------------------------------------
-- GuildGreet Modern GUI - Colours Configuration Tab
-- Segmented Scope Selector, Structured Swatch Cards & Localized Preview
------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", true)
local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
GuildGreet = GLDG

local UIStyle = GLDG.UIStyle

local activeColourSet = "guild"
local colourPanel = nil

local SCOPES = {
    { id = "guild",   key = "Guild",   fallback = "Gilde" },
    { id = "friends", key = "Friends", fallback = "Freunde" },
    { id = "channel", key = "Channel", fallback = "Kanal" },
}

local CHAT_SWATCHES = {
    { key = "online", labelKey = "Comes online",  fallback = "Kommt online" },
    { key = "goOff",  labelKey = "Going offline", fallback = "Geht offline" },
    { key = "isOff",  labelKey = "Is offline",    fallback = "Ist offline" },
    { key = "alias",  labelKey = "First Name / Alias", fallback = "Vorname / Alias" },
}

local QUEUE_SWATCHES = {
    { key = "list",       labelKey = "Online Greeting", fallback = "Online-Begrüßung" },
    { key = "relog",      labelKey = "Relog",           fallback = "Wiedereinloggen (Relog)" },
    { key = "new",        labelKey = "New member",      fallback = "Neues Mitglied" },
    { key = "lvl",        labelKey = "Level up",        fallback = "Stufenaufstieg" },
    { key = "rank",       labelKey = "Promotion",       fallback = "Beförderung" },
    { key = "achievment", labelKey = "Achievment",      fallback = "Erfolg" },
}

local SYSTEM_SWATCHES = {
    { key = "help",   labelKey = "Help",   fallback = "Hilfe-Textfarbe",   hasAlpha = false },
    { key = "header", labelKey = "Header", fallback = "Kopfzeilen-Farbe",  hasAlpha = true },
}

local function HexToRGBA(hexStr)
    if GLDG.Colors and GLDG.Colors.ColourToRGB_perc then
        local a, r, g, b = GLDG.Colors:ColourToRGB_perc(hexStr)
        return r or 1, g or 1, b or 1, a or 1
    end
    if type(hexStr) == "string" then
        local a, r, g, b = string.match(hexStr, "|c(%x%x)(%x%x)(%x%x)(%x%x)")
        if r and g and b then
            return tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, (tonumber(a, 16) or 255) / 255
        end
    end
    return 1, 1, 1, 1
end

local function RGBAToHex(r, g, b, a)
    if GLDG.Colors and GLDG.Colors.RGBToColour_perc then
        return GLDG.Colors:RGBToColour_perc(a or 1, r or 1, g or 1, b or 1)
    end
    return string.format("|c%02X%02X%02X%02X", (a or 1) * 255, (r or 1) * 255, (g or 1) * 255, (b or 1) * 255)
end

local function FormatShortHexBadge(r, g, b)
    return string.format("#%02X%02X%02X", math.floor((r or 1) * 255 + 0.5), math.floor((g or 1) * 255 + 0.5), math.floor((b or 1) * 255 + 0.5))
end

local function GetScopeLabel(scopeId)
    for _, sc in ipairs(SCOPES) do
        if sc.id == scopeId then
            return L[sc.key] or sc.fallback
        end
    end
    return scopeId
end

local function SyncColorGlobals()
    local colors = GLDG:GetColors()
    if colors and colors.guild then
        GLDG_ONLINE_COLOUR = colors.guild.online or GLDG_DEFAULT_ONLINE_COLOUR
        GLDG_IS_OFFLINE_COLOUR = colors.guild.isOff or GLDG_DEFAULT_IS_OFFLINE_COLOUR
        GLDG_GOES_OFFLINE_COLOUR = colors.guild.goOff or GLDG_DEFAULT_GOES_OFFLINE_COLOUR
        GLDG_ALIAS_COLOUR = colors.guild.alias or GLDG_DEFAULT_ALIAS_COLOUR
    end
    if GLDG.db and GLDG.db.profile then
        GLDG.db.profile.colours = colors
        if GLDG_Data then
            GLDG_Data.colours = colors
        end
    end
    if GLDG.ShowQueue then
        GLDG:ShowQueue()
    end
end

local RefreshColourPanel

local function CreateSwatchButton(parent)
    local btn = CreateFrame("Button", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    btn:SetHeight(34)
    UIStyle:ApplyBox(btn, UIStyle.Colors.bgRow, UIStyle.Colors.borderSubtle)

    local swatchBorder = CreateFrame("Frame", nil, btn, BackdropTemplateMixin and "BackdropTemplate" or nil)
    swatchBorder:SetSize(22, 22)
    swatchBorder:SetPoint("LEFT", btn, "LEFT", 10, 0)
    UIStyle:ApplyBox(swatchBorder, { 0, 0, 0, 1 }, UIStyle.Colors.border)
    btn.swatchBorder = swatchBorder

    local swatchTex = swatchBorder:CreateTexture(nil, "ARTWORK")
    swatchTex:SetPoint("TOPLEFT", swatchBorder, "TOPLEFT", 2, -2)
    swatchTex:SetPoint("BOTTOMRIGHT", swatchBorder, "BOTTOMRIGHT", -2, 2)
    btn.swatchTex = swatchTex

    local hexBadge = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hexBadge:SetPoint("RIGHT", btn, "RIGHT", -10, 0)
    hexBadge:SetJustifyH("RIGHT")
    hexBadge:SetTextColor(unpack(UIStyle.Colors.textMuted))
    btn.hexBadge = hexBadge

    local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    lbl:SetPoint("LEFT", swatchBorder, "RIGHT", 10, 0)
    lbl:SetPoint("RIGHT", hexBadge, "LEFT", -8, 0)
    lbl:SetJustifyH("LEFT")
    lbl:SetWordWrap(false)
    lbl:SetTextColor(unpack(UIStyle.Colors.textLight))
    btn.label = lbl

    btn:SetScript("OnEnter", function(selfBtn)
        UIStyle:ApplyBox(selfBtn, UIStyle.Colors.bgRowHover, UIStyle.Colors.borderHighlight)
        GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
        GameTooltip:SetText(selfBtn._title or "", 0.95, 0.82, 0.35)
        GameTooltip:AddLine(L["Click to pick colour"] or "Klicken, um Farbe zu ändern", 0.85, 0.85, 0.85)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(selfBtn)
        UIStyle:ApplyBox(selfBtn, UIStyle.Colors.bgRow, UIStyle.Colors.borderSubtle)
        GameTooltip:Hide()
    end)

    return btn
end

RefreshColourPanel = function()
    if not colourPanel or not colourPanel:IsShown() then return end

    local colors = GLDG:GetColors() or {}
    colors[activeColourSet] = colors[activeColourSet] or {}
    local activeTable = colors[activeColourSet]

    local fontSize = UIStyle:GetFontSize()
    local scrollW = math.max(520, (colourPanel:GetWidth() or 820) - 28)
    local scopeName = GetScopeLabel(activeColourSet)
    local yCursor = 0

    -- 1. Top Scope Bar
    local scopeBar = colourPanel.scopeBar
    local barH = math.max(46, fontSize + 30)
    scopeBar:ClearAllPoints()
    scopeBar:SetPoint("TOPLEFT", colourPanel.scrollChild, "TOPLEFT", 0, yCursor)
    scopeBar:SetSize(scrollW, barH)

    UIStyle:ApplyFont(colourPanel.scopeLbl, 0)
    local prevScopeBtn = nil
    for idx, sc in ipairs(SCOPES) do
        local sBtn = colourPanel.scopeBtns[idx]
        sBtn:SetText(L[sc.key] or sc.fallback)
        sBtn:UpdateSize()
        local isSel = (activeColourSet == sc.id)
        sBtn._isAccent = isSel
        UIStyle:ApplyBox(
            sBtn,
            isSel and UIStyle.Colors.bgRowActive or UIStyle.Colors.bgRow,
            isSel and UIStyle.Colors.borderHighlight or UIStyle.Colors.border
        )
        sBtn.label:SetTextColor(unpack(isSel and UIStyle.Colors.gold or UIStyle.Colors.textLight))
        sBtn:ClearAllPoints()
        if not prevScopeBtn then
            sBtn:SetPoint("LEFT", colourPanel.scopeLbl, "RIGHT", 10, 0)
        else
            sBtn:SetPoint("LEFT", prevScopeBtn, "RIGHT", 6, 0)
        end
        prevScopeBtn = sBtn
    end

    colourPanel.resetBtn:UpdateSize()
    colourPanel.copyAllBtn:UpdateSize()
    colourPanel.resetBtn:ClearAllPoints()
    colourPanel.resetBtn:SetPoint("RIGHT", scopeBar, "RIGHT", -10, 0)
    colourPanel.copyAllBtn:ClearAllPoints()
    colourPanel.copyAllBtn:SetPoint("RIGHT", colourPanel.resetBtn, "LEFT", -8, 0)

    yCursor = yCursor - (barH + 8)

    local colW = math.floor((scrollW - 28) / 2)
    local swH = math.max(34, fontSize + 20)

    -- Helper to layout a Swatch Card
    local function layoutSwatchCard(card, btnList, metaList, targetTable)
        UIStyle:ApplyFont(card.title, 0)
        local rows = math.ceil(#metaList / 2)
        for idx, meta in ipairs(metaList) do
            local btn = btnList[idx]
            local col = (idx - 1) % 2
            local row = math.floor((idx - 1) / 2)
            btn:SetSize(colW, swH)
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", card, "TOPLEFT", 10 + col * (colW + 8), -36 - row * (swH + 6))

            local titleStr = L[meta.labelKey] or meta.fallback
            btn._title = titleStr
            UIStyle:ApplyFont(btn.label, 0)
            UIStyle:ApplyFont(btn.hexBadge, -2)
            btn.label:SetText(titleStr)

            local hexVal = targetTable[meta.key] or "|cFFFFFFFF"
            local r, g, b, a = HexToRGBA(hexVal)
            btn.swatchTex:SetColorTexture(r, g, b, meta.hasAlpha and a or 1)
            btn.hexBadge:SetText(FormatShortHexBadge(r, g, b))

            btn:SetScript("OnClick", function()
                local cr, cg, cb, ca = HexToRGBA(targetTable[meta.key] or "|cFFFFFFFF")
                UIStyle:OpenColorPicker(cr, cg, cb, ca, meta.hasAlpha, function(nr, ng, nb, na)
                    targetTable[meta.key] = RGBAToHex(nr, ng, nb, meta.hasAlpha and na or 1)
                    SyncColorGlobals()
                    RefreshColourPanel()
                end)
            end)
        end

        local cardH = 36 + rows * (swH + 6) + 6
        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", colourPanel.scrollChild, "TOPLEFT", 0, yCursor)
        card:SetSize(scrollW, cardH)
        yCursor = yCursor - (cardH + 8)
    end

    -- 2. Chat Notifications Card
    colourPanel.chatCard.title:SetText(string.format("%s — %s", L["Chat Notifications"] or "Chat-Benachrichtigungen", scopeName))
    layoutSwatchCard(colourPanel.chatCard, colourPanel.chatBtns, CHAT_SWATCHES, activeTable)

    -- 3. Greeting Queue Card
    colourPanel.queueCard.title:SetText(string.format("%s — %s", L["Greeting Queue (Waiting List)"] or "Begrüßungsliste (Warteschlange)", scopeName))
    layoutSwatchCard(colourPanel.queueCard, colourPanel.queueBtns, QUEUE_SWATCHES, activeTable)

    -- 4. System & Header Card
    colourPanel.sysCard.title:SetText(L["System & Header"] or "System & Kopfzeile")
    layoutSwatchCard(colourPanel.sysCard, colourPanel.sysBtns, SYSTEM_SWATCHES, colors)

    -- 5. Localized Live Preview Card
    local prevCard = colourPanel.prevCard
    UIStyle:ApplyFont(prevCard.title, 0)
    prevCard.title:SetText(string.format("%s (%s)", L["Live Preview"] or "Live-Farbvorschau", scopeName))

    local sampleChar = L["PreviewChar"] or "Aerandir"
    local sampleNew  = L["PreviewNewbie"] or "Neuling"
    local sampleAlias = "Sascha"

    local cOnline = activeTable.online or "|cFFA0FFA0"
    local cGoOff  = activeTable.goOff  or "|cFF7F7F7F"
    local cAlias  = activeTable.alias  or "|cFFFFA0A0"
    local cList   = activeTable.list   or "|cFFFF7F00"
    local cRelog  = activeTable.relog  or "|cFF3FFF3F"
    local cNew    = activeTable.new    or "|cFFFF3F3F"
    local cLvl    = activeTable.lvl    or "|cFF7F7F7F"
    local cRank   = activeTable.rank   or "|cFFCC00CC"
    local cAchv   = activeTable.achievment or "|cFF001FFF"

    UIStyle:ApplyFont(colourPanel.prevText, 0)
    colourPanel.prevText:SetText(string.format(
        "%s[%s]|r %s: %s 80 Paladin %s[%s]|r      %s[%s]|r %s %s[%s]|r\n" ..
        "%s[12:00] %s|r  •  %s    " ..
        "%s[12:05] %s|r  •  %s    " ..
        "%s[12:10] %s|r  •  %s\n" ..
        "%s[12:15] %s|r  •  %s 80!    " ..
        "%s[12:20] %s|r  •  %s    " ..
        "%s[12:25] %s|r  •  %s",
        cOnline, L["Online"] or "Online", sampleChar, L["Level"] or "Stufe", cAlias, sampleAlias,
        cGoOff, L["Going offline"] or "Geht offline", sampleChar, cAlias, sampleAlias,
        cList, sampleChar, L["Logged in"] or "Eingeloggt",
        cRelog, sampleChar, L["Relog"] or "Relog",
        cNew, sampleNew, L["New member"] or "Neues Mitglied",
        cLvl, sampleChar, L["Level"] or "Stufe",
        cRank, sampleChar, L["Promotion"] or "Beförderung",
        cAchv, sampleChar, L["Achievment"] or "Erfolg"
    ))

    local prevCardH = math.max(108, fontSize * 4 + 54)
    prevCard:ClearAllPoints()
    prevCard:SetPoint("TOPLEFT", colourPanel.scrollChild, "TOPLEFT", 0, yCursor)
    prevCard:SetSize(scrollW, prevCardH)
    colourPanel.prevBox:ClearAllPoints()
    colourPanel.prevBox:SetPoint("TOPLEFT", prevCard, "TOPLEFT", 10, -36)
    colourPanel.prevBox:SetPoint("BOTTOMRIGHT", prevCard, "BOTTOMRIGHT", -10, 10)

    yCursor = yCursor - (prevCardH + 8)
    colourPanel.scrollChild:SetSize(scrollW, math.abs(yCursor) + 6)
end

local function EnsureColourPanel(hostFrame)
    if colourPanel then
        colourPanel:SetParent(hostFrame)
        colourPanel:ClearAllPoints()
        colourPanel:SetAllPoints(hostFrame)
        return colourPanel
    end

    local panel = CreateFrame("Frame", nil, hostFrame)
    panel:SetAllPoints(hostFrame)

    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -24, 0)
    panel.scrollFrame = scrollFrame

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(780, 600)
    scrollFrame:SetScrollChild(scrollChild)
    panel.scrollChild = scrollChild

    -- 1. Scope Bar
    local scopeBar = CreateFrame("Frame", nil, scrollChild, BackdropTemplateMixin and "BackdropTemplate" or nil)
    UIStyle:ApplyBox(scopeBar, UIStyle.Colors.bgPanel, UIStyle.Colors.borderSubtle)
    panel.scopeBar = scopeBar

    local scopeLbl = scopeBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    scopeLbl:SetPoint("LEFT", scopeBar, "LEFT", 12, 0)
    scopeLbl:SetTextColor(unpack(UIStyle.Colors.gold))
    scopeLbl:SetText(L["Target Scope:"] or "Farbbereich:")
    panel.scopeLbl = scopeLbl

    panel.scopeBtns = {}
    for idx, sc in ipairs(SCOPES) do
        local btn = UIStyle:CreateButton(scopeBar, L[sc.key] or sc.fallback, 88, 26, function()
            activeColourSet = sc.id
            if GLDG.Colors and GLDG.Colors.SetActiveColourSet then
                GLDG.Colors:SetActiveColourSet(activeColourSet)
            end
            RefreshColourPanel()
        end, sc.id == activeColourSet)
        panel.scopeBtns[idx] = btn
    end

    panel.copyAllBtn = UIStyle:CreateButton(scopeBar, L["Copy to All Scopes"] or L["Copy Set to Friends & Channel"] or "Auf alle Bereiche übertragen", 160, 26, function()
        local colors = GLDG:GetColors()
        local src = colors and colors[activeColourSet]
        if src then
            for _, targetSet in ipairs({ "guild", "friends", "channel" }) do
                colors[targetSet] = colors[targetSet] or {}
                for k, v in pairs(src) do
                    colors[targetSet][k] = v
                end
            end
            SyncColorGlobals()
            RefreshColourPanel()
        end
    end, false)

    panel.resetBtn = UIStyle:CreateButton(scopeBar, L["Restore default"] or "Standard wiederherstellen", 150, 26, function()
        if GLDG.Colors and GLDG.Colors.SetDefaults then
            GLDG.Colors:SetDefaults()
            SyncColorGlobals()
            RefreshColourPanel()
        end
    end, false)

    -- 2. Swatch Cards
    panel.chatCard = UIStyle:CreateCard(scrollChild, L["Chat Notifications"] or "Chat-Benachrichtigungen")
    panel.chatBtns = {}
    for i = 1, #CHAT_SWATCHES do
        panel.chatBtns[i] = CreateSwatchButton(panel.chatCard)
    end

    panel.queueCard = UIStyle:CreateCard(scrollChild, L["Greeting Queue (Waiting List)"] or "Begrüßungsliste (Warteschlange)")
    panel.queueBtns = {}
    for i = 1, #QUEUE_SWATCHES do
        panel.queueBtns[i] = CreateSwatchButton(panel.queueCard)
    end

    panel.sysCard = UIStyle:CreateCard(scrollChild, L["System & Header"] or "System & Kopfzeile")
    panel.sysBtns = {}
    for i = 1, #SYSTEM_SWATCHES do
        panel.sysBtns[i] = CreateSwatchButton(panel.sysCard)
    end

    -- 3. Live Preview Card
    local prevCard = UIStyle:CreateCard(scrollChild, L["Live Preview"] or "Live-Farbvorschau")
    panel.prevCard = prevCard
    local prevBox = CreateFrame("Frame", nil, prevCard, BackdropTemplateMixin and "BackdropTemplate" or nil)
    UIStyle:ApplyBox(prevBox, UIStyle.Colors.bgInput, UIStyle.Colors.borderSubtle)
    panel.prevBox = prevBox
    local prevText = prevBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    prevText:SetPoint("TOPLEFT", prevBox, "TOPLEFT", 12, -8)
    prevText:SetPoint("BOTTOMRIGHT", prevBox, "BOTTOMRIGHT", -12, 8)
    prevText:SetJustifyH("LEFT")
    prevText:SetJustifyV("MIDDLE")
    prevText:SetSpacing(5)
    panel.prevText = prevText

    panel:SetScript("OnSizeChanged", function()
        if panel:IsShown() then
            RefreshColourPanel()
        end
    end)

    colourPanel = panel
    return panel
end

function GLDG:ShowColourTabPanel(hostFrame)
    if self.Colors and self.Colors.Initialize then
        self.Colors:Initialize()
    end
    local panel = EnsureColourPanel(hostFrame)
    panel:Show()
    RefreshColourPanel()
end

function GLDG:HideColourTabPanel()
    if colourPanel then
        colourPanel:Hide()
    end
end

function GLDG:CreateColourTab(container)
    if container and container.frame then
        self:ShowColourTabPanel(container.frame)
    end
end
