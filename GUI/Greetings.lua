------------------------------------------------------------
-- GuildGreet Modern GUI - Greetings & Collections Tab
-- Master-Detail Split View: 16 Categories Sidebar + Template Editor
------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", true)
local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
GuildGreet = GLDG

local strtrim = strtrim or function(s)
    return string.match(tostring(s or ""), "^%s*(.-)%s*$") or ""
end

local UIStyle = GLDG.UIStyle

local selectedCategory = "Greet"
local selectedCollection = "" -- "" = Default Realm Greetings
local selectedMsgIndex = nil
local showNewColInput = false
local lastPreviewText = nil

local greetingsPanel = nil
local msgRowPool = {}

local CATEGORY_META = {
    -- Player Events
    { id = "Greet",        group = 1, icon = "Interface\\FriendsFrame\\StatusIcon-Online",          key = "Going online",          fallback = "Online Greeting" },
    { id = "GreetBack",    group = 1, icon = "Interface\\Buttons\\UI-RefreshButton",                key = "Coming back online",    fallback = "Relog Greeting" },
    { id = "Welcome",      group = 1, icon = "Interface\\Icons\\Achievement_GuildPerk_EverybodysFriend", key = "Welcome to guild", fallback = "New Guild Member" },
    { id = "NewLevel",     group = 1, icon = "Interface\\Icons\\Spell_Holy_ChampionsBond",          key = "Level up",              fallback = "Level-Up" },
    { id = "NewRank",      group = 1, icon = "Interface\\GroupFrame\\UI-Group-LeaderIcon",          key = "Promotion",             fallback = "Promotion / Rank" },
    { id = "Achievment",   group = 1, icon = "Interface\\AchievementFrame\\UI-Achievement-TinyShield", key = "Achievment",         fallback = "Achievement" },
    { id = "Bye",          group = 1, icon = "Interface\\FriendsFrame\\StatusIcon-Away",            key = "Leaving char (day)",    fallback = "Player Goodbye (Day)" },
    { id = "Night",        group = 1, icon = "Interface\\Icons\\Spell_Nature_Sleep",                key = "Leaving char (night)",  fallback = "Player Good Night" },
    -- Own Announcements
    { id = "Guild",        group = 2, icon = "Interface\\GossipFrame\\ChatBubbleGossipIcon",        key = "Greeting the guild",    fallback = "Greet Guild" },
    { id = "Channel",      group = 2, icon = "Interface\\GossipFrame\\ChatBubbleGossipIcon",        key = "Greeting the channel",  fallback = "Greet Channel" },
    { id = "ByeGuild",     group = 2, icon = "Interface\\FriendsFrame\\StatusIcon-Offline",         key = "Say goodbye to guild",  fallback = "Goodbye Guild (Day)" },
    { id = "NightGuild",   group = 2, icon = "Interface\\Icons\\Spell_Nature_Sleep",                key = "Say good night to guild", fallback = "Good Night Guild" },
    { id = "ByeChannel",   group = 2, icon = "Interface\\FriendsFrame\\StatusIcon-Offline",         key = "Say goodbye to channel", fallback = "Goodbye Channel (Day)" },
    { id = "NightChannel", group = 2, icon = "Interface\\Icons\\Spell_Nature_Sleep",                key = "Say good night to channel", fallback = "Good Night Channel" },
    { id = "LaterGuild",   group = 2, icon = "Interface\\FriendsFrame\\StatusIcon-Away",            key = "See you later to guild", fallback = "See You Later Guild" },
    { id = "LaterChannel", group = 2, icon = "Interface\\FriendsFrame\\StatusIcon-Away",            key = "See you later to channel", fallback = "See You Later Channel" },
}

local PLACEHOLDER_CHIPS = {
    { token = "%s",             label = "%s Name",  descKey = "Selected greet name (Char, Main, or Alias)", fallback = "Selected greet name (Char, Main, or Alias)" },
    { token = "%c",             label = "%c Char",  descKey = "Character name",                             fallback = "Character name" },
    { token = "%m",             label = "%m Main",  descKey = "Main name",                                  fallback = "Main name" },
    { token = "%a",             label = "%a Alias", descKey = "Character alias",                            fallback = "Character alias / First name" },
    { token = "%l",             label = "%l Lvl",   descKey = "Level",                                      fallback = "Current level" },
    { token = "%C",             label = "%C Class", descKey = "Character class",                            fallback = "Character class" },
    { token = "%r",             label = "%r Rank",  descKey = "Guild rank",                                 fallback = "Guild rank" },
    { token = "%v",             label = "%v Achv",  descKey = "Achievement link",                           fallback = "Achievement link" },
    { token = "%g",             label = "%g Guild", descKey = "Guild alias / Guild name",                   fallback = "Guild alias or Guild name" },
    { token = "<1:20>",         label = "<min:max>", descKey = nil,                                         fallback = "Level range filter prefix (e.g. <1:20>)" },
    { token = "<06:00:11:59>",  label = "<HH:MM>",  descKey = nil,                                          fallback = "Time-of-day filter prefix (e.g. <06:00:11:59>)" },
}

local function GetCategoryLabel(catId)
    for _, m in ipairs(CATEGORY_META) do
        if m.id == catId then
            return L[m.key] or m.fallback
        end
    end
    return catId
end

local function GetActiveCategoryList(cat)
    cat = cat or selectedCategory
    if selectedCollection and selectedCollection ~= "" and GLDG_Data.Collections and GLDG_Data.Collections[selectedCollection] then
        local col = GLDG_Data.Collections[selectedCollection]
        col[cat] = col[cat] or {}
        return col[cat]
    end
    GLDG_DataGreet = GLDG_DataGreet or {}
    GLDG_DataGreet[cat] = GLDG_DataGreet[cat] or {}
    if GLDG_Data then
        GLDG_Data[cat] = GLDG_DataGreet[cat]
    end
    return GLDG_DataGreet[cat]
end

local function SyncGreetingAliases()
    if GLDG_DataGreet then
        GLDG_DataGreet.GreetGuild = GLDG_DataGreet.Guild
        GLDG_DataGreet.GreetChannel = GLDG_DataGreet.Channel
    end
end

local function FormatPreviewSample(msgText)
    local player = (GLDG.Player or UnitName("player") or "Player")
    local fullPlayer = player .. "-" .. string.gsub(GLDG.Realm or GetRealmName() or "Realm", " ", "")
    local parsed = msgText
    if GLDG_ParseCustomMessage then
        local okP, resP = pcall(GLDG_ParseCustomMessage, fullPlayer, player, msgText)
        if okP and type(resP) == "string" then
            parsed = resP
        end
    end
    local ok, formatted = pcall(string.format, parsed, player, "80")
    return (ok and type(formatted) == "string") and formatted or parsed
end

local RefreshGreetingsPanel

local function CreateMessageRow(parent, idx)
    local row = CreateFrame("Button", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    row:SetHeight(32)

    local accent = row:CreateTexture(nil, "OVERLAY")
    accent:SetWidth(3)
    accent:SetPoint("TOPLEFT", row, "TOPLEFT", 1, -1)
    accent:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 1, 1)
    accent:Hide()
    row.accent = accent

    local idxText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    idxText:SetPoint("LEFT", row, "LEFT", 10, 0)
    idxText:SetWidth(30)
    idxText:SetJustifyH("LEFT")
    row.idxText = idxText

    local delBtn = UIStyle:CreateIconButton(
        row,
        "Interface\\Buttons\\UI-StopButton",
        24,
        L["Delete template"] or "Vorlage löschen",
        function()
            local list = GetActiveCategoryList(selectedCategory)
            local rIdx = row._msgIdx
            if rIdx and list[rIdx] then
                table.remove(list, rIdx)
                if selectedMsgIndex == rIdx then
                    selectedMsgIndex = nil
                elseif selectedMsgIndex and selectedMsgIndex > rIdx then
                    selectedMsgIndex = selectedMsgIndex - 1
                end
                SyncGreetingAliases()
                RefreshGreetingsPanel()
            end
        end,
        false
    )
    delBtn:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    row.delBtn = delBtn

    local editBtn = UIStyle:CreateIconButton(
        row,
        "Interface\\Buttons\\UI-OptionsButton",
        24,
        L["Edit template"] or "Vorlage bearbeiten",
        function()
            local list = GetActiveCategoryList(selectedCategory)
            local rIdx = row._msgIdx
            if rIdx and list[rIdx] then
                selectedMsgIndex = rIdx
                if greetingsPanel and greetingsPanel.msgInput then
                    greetingsPanel.msgInput:SetText(list[rIdx])
                    greetingsPanel.msgInput._syncPlaceholder()
                    greetingsPanel.msgInput:SetFocus()
                end
                RefreshGreetingsPanel()
            end
        end,
        true
    )
    editBtn:SetPoint("RIGHT", delBtn, "LEFT", -4, 0)
    row.editBtn = editBtn

    local previewBtn = UIStyle:CreateIconButton(
        row,
        "Interface\\GossipFrame\\ChatBubbleGossipIcon",
        24,
        L["Preview template"] or "Vorschau anzeigen",
        function()
            local list = GetActiveCategoryList(selectedCategory)
            local rIdx = row._msgIdx
            if rIdx and list[rIdx] then
                lastPreviewText = FormatPreviewSample(list[rIdx])
                RefreshGreetingsPanel()
            end
        end,
        false
    )
    previewBtn:SetPoint("RIGHT", editBtn, "LEFT", -4, 0)
    row.previewBtn = previewBtn

    local msgText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    msgText:SetPoint("LEFT", idxText, "RIGHT", 4, 0)
    msgText:SetPoint("RIGHT", previewBtn, "LEFT", -10, 0)
    msgText:SetJustifyH("LEFT")
    msgText:SetWordWrap(false)
    row.msgText = msgText

    row._idx = idx
    row:SetScript("OnEnter", function(selfRow)
        UIStyle:ApplyBox(selfRow, UIStyle.Colors.bgRowHover, UIStyle.Colors.borderHighlight)
        if selfRow._rawMsg then
            GameTooltip:SetOwner(selfRow, "ANCHOR_TOP")
            GameTooltip:SetText(selfRow._rawMsg, 1, 0.92, 0.55, 1, true)
            GameTooltip:AddLine((L["Preview:"] or "Vorschau:") .. " " .. FormatPreviewSample(selfRow._rawMsg), 0.78, 0.85, 0.95, true)
            GameTooltip:Show()
        end
    end)
    row:SetScript("OnLeave", function(selfRow)
        GameTooltip:Hide()
        if selectedMsgIndex == selfRow._msgIdx then
            UIStyle:ApplyBox(selfRow, UIStyle.Colors.bgRowActive, UIStyle.Colors.borderHighlight)
        else
            UIStyle:ApplyBox(
                selfRow,
                (selfRow._idx % 2 == 0) and UIStyle.Colors.bgRowAlt or UIStyle.Colors.bgRow,
                UIStyle.Colors.borderSubtle
            )
        end
    end)
    row:SetScript("OnClick", function(selfRow)
        local list = GetActiveCategoryList(selectedCategory)
        local rIdx = selfRow._msgIdx
        if rIdx and list[rIdx] then
            if selectedMsgIndex == rIdx then
                selectedMsgIndex = nil
                if greetingsPanel and greetingsPanel.msgInput then
                    greetingsPanel.msgInput:SetText("")
                    greetingsPanel.msgInput._syncPlaceholder()
                end
            else
                selectedMsgIndex = rIdx
                if greetingsPanel and greetingsPanel.msgInput then
                    greetingsPanel.msgInput:SetText(list[rIdx])
                    greetingsPanel.msgInput._syncPlaceholder()
                    greetingsPanel.msgInput:SetFocus()
                end
            end
            RefreshGreetingsPanel()
        end
    end)

    return row
end

RefreshGreetingsPanel = function()
    if not greetingsPanel or not greetingsPanel:IsShown() then return end

    local fontSize = UIStyle:GetFontSize()
    local catPaneW = math.max(235, math.floor(235 * (fontSize / 12.5)))
    greetingsPanel.catCard:SetWidth(catPaneW)

    -- 1. Layout Left Category List
    local catChildW = math.max(180, catPaneW - 28)
    local catRowH = math.max(28, fontSize + 14)
    local yOff = -4
    local lastGroup = nil

    for idx, meta in ipairs(CATEGORY_META) do
        if meta.group ~= lastGroup then
            lastGroup = meta.group
            local grpHdr = greetingsPanel.groupHeaders[meta.group]
            if grpHdr then
                if meta.group > 1 then yOff = yOff - 8 end
                UIStyle:ApplyFont(grpHdr, -2)
                grpHdr:ClearAllPoints()
                grpHdr:SetPoint("TOPLEFT", greetingsPanel.catScrollChild, "TOPLEFT", 6, yOff)
                grpHdr:SetWidth(catChildW - 8)
                grpHdr:Show()
                yOff = yOff - (fontSize + 8)
            end
        end

        local btn = greetingsPanel.catButtons[idx]
        if btn then
            btn:SetSize(catChildW, catRowH)
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", greetingsPanel.catScrollChild, "TOPLEFT", 0, yOff)
            UIStyle:ApplyFont(btn.label, -1)
            UIStyle:ApplyFont(btn.countBadge, -2)

            local cnt = #(GetActiveCategoryList(meta.id))
            btn.countBadge:SetText(tostring(cnt))
            btn.label:SetText(L[meta.key] or meta.fallback)

            local isSel = (selectedCategory == meta.id)
            if isSel then
                UIStyle:ApplyBox(btn, UIStyle.Colors.bgRowActive, UIStyle.Colors.borderHighlight)
                btn.accent:Show()
                btn.label:SetTextColor(unpack(UIStyle.Colors.gold))
                btn.countBadge:SetTextColor(unpack(UIStyle.Colors.gold))
            else
                UIStyle:ApplyBox(btn, UIStyle.Colors.bgRow, UIStyle.Colors.borderSubtle)
                btn.accent:Hide()
                btn.label:SetTextColor(unpack(UIStyle.Colors.textLight))
                btn.countBadge:SetTextColor(cnt > 0 and 0.30 or 0.58, cnt > 0 and 0.85 or 0.60, cnt > 0 and 0.45 or 0.66, 1)
            end
            yOff = yOff - (catRowH + 2)
        end
    end
    greetingsPanel.catScrollChild:SetSize(catChildW, math.abs(yOff) + 8)

    -- 2. Collection Top Bar
    UIStyle:ApplyFont(greetingsPanel.colLbl, 0)
    UIStyle:ApplyFont(greetingsPanel.colDrop.label, 0)
    local colItems = {
        { value = "", label = L["Global defaults"] or "Globale Standards" },
    }
    if GLDG_Data and type(GLDG_Data.Collections) == "table" then
        local sortedCols = {}
        for cName in pairs(GLDG_Data.Collections) do
            table.insert(sortedCols, cName)
        end
        table.sort(sortedCols)
        for _, cName in ipairs(sortedCols) do
            table.insert(colItems, { value = cName, label = cName })
        end
    end

    local curColLabel = colItems[1].label
    for _, it in ipairs(colItems) do
        if it.value == (selectedCollection or "") then
            curColLabel = it.label
            break
        end
    end
    greetingsPanel.colDrop.label:SetText(curColLabel)
    greetingsPanel.colDrop:SetScript("OnClick", function(selfBtn)
        UIStyle:OpenDropdown(selfBtn, colItems, selectedCollection or "", function(val)
            selectedCollection = val or ""
            selectedMsgIndex = nil
            lastPreviewText = nil
            if greetingsPanel.msgInput then
                greetingsPanel.msgInput:SetText("")
                greetingsPanel.msgInput._syncPlaceholder()
            end
            RefreshGreetingsPanel()
        end)
    end)

    greetingsPanel.newColToggleBtn:UpdateSize()
    greetingsPanel.createColBtn:UpdateSize()
    greetingsPanel.useGuildColBtn:UpdateSize()
    greetingsPanel.delColBtn:UpdateSize()

    if showNewColInput then
        greetingsPanel.newColInput:Show()
        greetingsPanel.createColBtn:Show()
        UIStyle:ApplyFont(greetingsPanel.newColInput, 0)
        if greetingsPanel.newColInput.placeholder then
            UIStyle:ApplyFont(greetingsPanel.newColInput.placeholder, 0)
        end
        greetingsPanel.colBar:SetHeight(78)
    else
        greetingsPanel.newColInput:Hide()
        greetingsPanel.createColBtn:Hide()
        greetingsPanel.colBar:SetHeight(44)
    end

    if selectedCollection and selectedCollection ~= "" then
        greetingsPanel.useGuildColBtn:Show()
        greetingsPanel.delColBtn:Show()
        greetingsPanel.useGuildColBtn:ClearAllPoints()
        greetingsPanel.useGuildColBtn:SetPoint("LEFT", greetingsPanel.newColToggleBtn, "RIGHT", 6, 0)
        greetingsPanel.delColBtn:ClearAllPoints()
        greetingsPanel.delColBtn:SetPoint("LEFT", greetingsPanel.useGuildColBtn, "RIGHT", 6, 0)
    else
        greetingsPanel.useGuildColBtn:Hide()
        greetingsPanel.delColBtn:Hide()
    end

    -- 3. Editor Card
    local catTitle = GetCategoryLabel(selectedCategory)
    UIStyle:ApplyFont(greetingsPanel.editorCard.title, 0)
    if selectedMsgIndex then
        greetingsPanel.editorCard.title:SetText(
            string.format("%s #%d — %s", L["Edit template"] or "Vorlage bearbeiten", selectedMsgIndex, catTitle)
        )
        greetingsPanel.addSaveBtn:SetText(L["Update"] or "Speichern")
        greetingsPanel.secondaryBtn:SetText(L["Cancel"] or "Abbrechen")
    else
        greetingsPanel.editorCard.title:SetText(
            string.format("%s — %s", L["Add New Message"] or "Neue Nachricht hinzufügen", catTitle)
        )
        greetingsPanel.addSaveBtn:SetText(L["Add"] or "Hinzufügen")
        greetingsPanel.secondaryBtn:SetText(L["Restore default"] or "Standard wiederherstellen")
    end

    UIStyle:ApplyFont(greetingsPanel.msgInput, 0)
    if greetingsPanel.msgInput.placeholder then
        UIStyle:ApplyFont(greetingsPanel.msgInput.placeholder, 0)
    end
    greetingsPanel.addSaveBtn:UpdateSize()
    greetingsPanel.secondaryBtn:UpdateSize()

    greetingsPanel.secondaryBtn:ClearAllPoints()
    greetingsPanel.secondaryBtn:SetPoint("TOPRIGHT", greetingsPanel.editorCard, "TOPRIGHT", -10, -36)
    greetingsPanel.addSaveBtn:ClearAllPoints()
    greetingsPanel.addSaveBtn:SetPoint("RIGHT", greetingsPanel.secondaryBtn, "LEFT", -6, 0)
    greetingsPanel.msgInput:ClearAllPoints()
    greetingsPanel.msgInput:SetPoint("TOPLEFT", greetingsPanel.editorCard, "TOPLEFT", 10, -36)
    greetingsPanel.msgInput:SetPoint("RIGHT", greetingsPanel.addSaveBtn, "LEFT", -8, 0)
    greetingsPanel.msgInput:SetHeight(math.max(28, fontSize + 14))

    -- Layout Placeholder Chips cleanly with automatic wrapping
    local editorW = math.max(380, (greetingsPanel.editorCard:GetWidth() or 540) - 20)
    local chipX = 10
    local chipY = -(42 + math.max(28, fontSize + 14))
    local chipH = math.max(21, fontSize + 8)

    UIStyle:ApplyFont(greetingsPanel.chipHint, -2)
    greetingsPanel.chipHint:ClearAllPoints()
    greetingsPanel.chipHint:SetPoint("TOPLEFT", greetingsPanel.editorCard, "TOPLEFT", 10, chipY - 3)
    local hintW = math.ceil((greetingsPanel.chipHint:GetStringWidth() or 80) + 8)
    chipX = 10 + hintW

    for _, chip in ipairs(greetingsPanel.chips) do
        UIStyle:ApplyFont(chip.label, -2)
        local cw = math.max(46, math.ceil((chip.label:GetStringWidth() or 36) + 14))
        chip:SetSize(cw, chipH)
        if (chipX + cw) > (editorW + 10) then
            chipX = 10
            chipY = chipY - (chipH + 4)
        end
        chip:ClearAllPoints()
        chip:SetPoint("TOPLEFT", greetingsPanel.editorCard, "TOPLEFT", chipX, chipY)
        chipX = chipX + cw + 4
    end

    local editorTotalH = math.abs(chipY) + chipH + 10
    if lastPreviewText and lastPreviewText ~= "" then
        greetingsPanel.previewBox:Show()
        UIStyle:ApplyFont(greetingsPanel.previewText, -1)
        greetingsPanel.previewText:SetText(UIStyle.Hex.gold .. (L["Preview:"] or "Vorschau:") .. "|r " .. UIStyle.Hex.textLight .. lastPreviewText .. "|r")
        greetingsPanel.previewBox:ClearAllPoints()
        greetingsPanel.previewBox:SetPoint("TOPLEFT", greetingsPanel.editorCard, "TOPLEFT", 10, -editorTotalH)
        greetingsPanel.previewBox:SetPoint("TOPRIGHT", greetingsPanel.editorCard, "TOPRIGHT", -10, -editorTotalH)
        local pvH = math.max(26, fontSize + 12)
        greetingsPanel.previewBox:SetHeight(pvH)
        editorTotalH = editorTotalH + pvH + 8
    else
        greetingsPanel.previewBox:Hide()
    end
    greetingsPanel.editorCard:SetHeight(editorTotalH)

    -- 4. Templates Table
    local list = GetActiveCategoryList(selectedCategory)
    UIStyle:ApplyFont(greetingsPanel.listCard.title, 0)
    greetingsPanel.listCard.title:SetText(string.format(L["Templates (%d)"] or "Gespeicherte Vorlagen (%d)", #list))

    local listScrollW = math.max(300, (greetingsPanel.listCard:GetWidth() or 520) - 28)
    local rowH = math.max(30, fontSize + 17)
    local rowStep = rowH + 2
    local iconSz = math.max(22, math.min(26, rowH - 6))

    greetingsPanel.listScrollChild:SetSize(listScrollW, math.max(#list * rowStep + 4, 40))

    if #list == 0 then
        greetingsPanel.emptyText:Show()
        UIStyle:ApplyFont(greetingsPanel.emptyText, 0)
        greetingsPanel.emptyText:SetText(L["No greeting templates configured in this category."] or "Keine Begrüßungsvorlagen in dieser Kategorie konfiguriert.")
    else
        greetingsPanel.emptyText:Hide()
    end

    for i = 1, #list do
        local row = msgRowPool[i]
        if not row then
            row = CreateMessageRow(greetingsPanel.listScrollChild, i)
            msgRowPool[i] = row
        end
        row._idx = i
        row._msgIdx = i
        row._rawMsg = list[i]
        row:SetSize(listScrollW, rowH)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", greetingsPanel.listScrollChild, "TOPLEFT", 0, -(i - 1) * rowStep)

        UIStyle:ApplyFont(row.idxText, -1)
        UIStyle:ApplyFont(row.msgText, 0)
        row.idxText:SetText(UIStyle.Hex.goldDim .. "#" .. tostring(i) .. "|r")

        local isEditing = (selectedMsgIndex == i)
        if isEditing then
            UIStyle:ApplyBox(row, UIStyle.Colors.bgRowActive, UIStyle.Colors.borderHighlight)
            row.accent:SetColorTexture(unpack(UIStyle.Colors.gold))
            row.accent:Show()
            row.msgText:SetText(UIStyle.Hex.gold .. tostring(list[i]) .. "|r")
        else
            UIStyle:ApplyBox(row, (i % 2 == 0) and UIStyle.Colors.bgRowAlt or UIStyle.Colors.bgRow, UIStyle.Colors.borderSubtle)
            row.accent:Hide()
            row.msgText:SetText(UIStyle.Hex.textLight .. tostring(list[i]) .. "|r")
        end

        for _, b in ipairs({ row.previewBtn, row.editBtn, row.delBtn }) do
            b:SetSize(iconSz, iconSz)
            b.icon:SetSize(iconSz - 9, iconSz - 9)
        end
        row:Show()
    end

    for i = #list + 1, #msgRowPool do
        msgRowPool[i]:Hide()
    end
end

local function EnsureGreetingsPanel(hostFrame)
    if greetingsPanel then
        greetingsPanel:SetParent(hostFrame)
        greetingsPanel:ClearAllPoints()
        greetingsPanel:SetAllPoints(hostFrame)
        return greetingsPanel
    end

    local panel = CreateFrame("Frame", nil, hostFrame)
    panel:SetAllPoints(hostFrame)

    -- Left Sidebar: Category List
    local catCard = UIStyle:CreateCard(panel, L["Greeting Category"] or "Begrüßungs-Kategorie")
    catCard:SetWidth(245)
    catCard:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
    catCard:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 0, 0)
    panel.catCard = catCard

    local catScroll = CreateFrame("ScrollFrame", nil, catCard, "UIPanelScrollFrameTemplate")
    catScroll:SetPoint("TOPLEFT", catCard.header, "BOTTOMLEFT", 4, -4)
    catScroll:SetPoint("BOTTOMRIGHT", catCard, "BOTTOMRIGHT", -24, 4)
    panel.catScroll = catScroll

    local catScrollChild = CreateFrame("Frame", nil, catScroll)
    catScrollChild:SetSize(210, 400)
    catScroll:SetScrollChild(catScrollChild)
    panel.catScrollChild = catScrollChild

    panel.groupHeaders = {}
    for gIdx, gTitle in ipairs({
        L["Player Events"] or "Spieler-Ereignisse",
        L["Own Announcements"] or "Eigene Ankündigungen",
    }) do
        local gh = catScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        gh:SetJustifyH("LEFT")
        gh:SetTextColor(unpack(UIStyle.Colors.goldDim))
        gh:SetText(string.upper(gTitle))
        panel.groupHeaders[gIdx] = gh
    end

    panel.catButtons = {}
    for idx, meta in ipairs(CATEGORY_META) do
        local btn = CreateFrame("Button", nil, catScrollChild, BackdropTemplateMixin and "BackdropTemplate" or nil)
        btn:SetSize(210, 28)
        UIStyle:ApplyBox(btn, UIStyle.Colors.bgRow, UIStyle.Colors.borderSubtle)

        local accent = btn:CreateTexture(nil, "OVERLAY")
        accent:SetWidth(3)
        accent:SetPoint("TOPLEFT", btn, "TOPLEFT", 1, -1)
        accent:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 1, 1)
        accent:SetColorTexture(unpack(UIStyle.Colors.gold))
        accent:Hide()
        btn.accent = accent

        local ic = btn:CreateTexture(nil, "ARTWORK")
        ic:SetSize(15, 15)
        ic:SetPoint("LEFT", btn, "LEFT", 8, 0)
        ic:SetTexture(meta.icon)
        btn.icon = ic

        local countBadge = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        countBadge:SetPoint("RIGHT", btn, "RIGHT", -8, 0)
        countBadge:SetJustifyH("RIGHT")
        btn.countBadge = countBadge

        local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        lbl:SetPoint("LEFT", ic, "RIGHT", 7, 0)
        lbl:SetPoint("RIGHT", countBadge, "LEFT", -6, 0)
        lbl:SetJustifyH("LEFT")
        lbl:SetWordWrap(false)
        btn.label = lbl

        btn:SetScript("OnEnter", function(selfBtn)
            if selectedCategory ~= meta.id then
                UIStyle:ApplyBox(selfBtn, UIStyle.Colors.bgRowHover, UIStyle.Colors.border)
            end
        end)
        btn:SetScript("OnLeave", function(selfBtn)
            if selectedCategory ~= meta.id then
                UIStyle:ApplyBox(selfBtn, UIStyle.Colors.bgRow, UIStyle.Colors.borderSubtle)
            end
        end)
        btn:SetScript("OnClick", function()
            selectedCategory = meta.id
            selectedMsgIndex = nil
            lastPreviewText = nil
            if panel.msgInput then
                panel.msgInput:SetText("")
                panel.msgInput._syncPlaceholder()
            end
            RefreshGreetingsPanel()
        end)
        panel.catButtons[idx] = btn
    end

    -- Right Pane: Collection Bar + Editor Card + Templates List
    local rightPane = CreateFrame("Frame", nil, panel)
    rightPane:SetPoint("TOPLEFT", catCard, "TOPRIGHT", 8, 0)
    rightPane:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)
    panel.rightPane = rightPane

    -- 1. Collection Bar
    local colBar = CreateFrame("Frame", nil, rightPane, BackdropTemplateMixin and "BackdropTemplate" or nil)
    colBar:SetHeight(44)
    colBar:SetPoint("TOPLEFT", rightPane, "TOPLEFT", 0, 0)
    colBar:SetPoint("TOPRIGHT", rightPane, "TOPRIGHT", 0, 0)
    UIStyle:ApplyBox(colBar, UIStyle.Colors.bgPanel, UIStyle.Colors.borderSubtle)
    panel.colBar = colBar

    local colLbl = colBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    colLbl:SetPoint("TOPLEFT", colBar, "TOPLEFT", 12, -13)
    colLbl:SetTextColor(unpack(UIStyle.Colors.gold))
    colLbl:SetText(L["Collection:"] or "Sammlung:")
    panel.colLbl = colLbl

    local colDrop = UIStyle:CreateDropdown(colBar, 210, 26)
    colDrop:SetPoint("LEFT", colLbl, "RIGHT", 8, 0)
    panel.colDrop = colDrop

    local newColToggleBtn = UIStyle:CreateButton(colBar, L["New Collection"] or "+ Neue Sammlung", 125, 26, function()
        showNewColInput = not showNewColInput
        RefreshGreetingsPanel()
        if showNewColInput and panel.newColInput then
            panel.newColInput:SetFocus()
        end
    end, false)
    newColToggleBtn:SetPoint("LEFT", colDrop, "RIGHT", 8, 0)
    panel.newColToggleBtn = newColToggleBtn

    local useGuildColBtn = UIStyle:CreateButton(colBar, L["Use for Guild"] or "Für Gilde nutzen", 115, 26, function()
        if selectedCollection ~= "" and GLDG_unique_GuildName and GLDG_unique_GuildName ~= "" then
            GLDG_Data.Custom = GLDG_Data.Custom or {}
            GLDG_Data.Custom[GLDG_unique_GuildName] = selectedCollection
            GLDG_DataGreet = GLDG_Data.Collections[selectedCollection]
            GLDG:PrintInfo((L["Collection"] or "Sammlung") .. " '" .. selectedCollection .. "' -> " .. tostring(GLDG_unique_GuildName))
        end
    end, false)
    panel.useGuildColBtn = useGuildColBtn

    local delColBtn = UIStyle:CreateButton(colBar, L["Delete Collection"] or "Sammlung löschen", 120, 26, function()
        if selectedCollection ~= "" and GLDG_Data.Collections and GLDG_Data.Collections[selectedCollection] then
            GLDG_Data.Collections[selectedCollection] = nil
            selectedCollection = ""
            selectedMsgIndex = nil
            RefreshGreetingsPanel()
        end
    end, false)
    panel.delColBtn = delColBtn

    local newColInput = UIStyle:CreateEditBox(colBar, 26, L["Collection name..."] or "Sammlungsname...")
    newColInput:SetPoint("TOPLEFT", colBar, "TOPLEFT", 12, -44)
    newColInput:SetWidth(240)
    panel.newColInput = newColInput

    local function createNewCollectionNow()
        local name = strtrim(newColInput:GetText() or "")
        if name == "" then return end
        GLDG_Data.Collections = GLDG_Data.Collections or {}
        if not GLDG_Data.Collections[name] then
            local newCol = {}
            for _, m in ipairs(CATEGORY_META) do
                newCol[m.id] = {}
            end
            GLDG_Data.Collections[name] = newCol
        end
        selectedCollection = name
        selectedMsgIndex = nil
        newColInput:SetText("")
        newColInput._syncPlaceholder()
        showNewColInput = false
        RefreshGreetingsPanel()
    end

    newColInput:SetScript("OnEnterPressed", function(selfBox)
        selfBox:ClearFocus()
        createNewCollectionNow()
    end)

    local createColBtn = UIStyle:CreateButton(colBar, L["Create"] or "Erstellen", 90, 26, createNewCollectionNow, true)
    createColBtn:SetPoint("LEFT", newColInput, "RIGHT", 8, 0)
    panel.createColBtn = createColBtn

    -- 2. Editor Card
    local editorCard = UIStyle:CreateCard(rightPane, L["Add New Message"] or "Neue Nachricht hinzufügen")
    editorCard:SetHeight(118)
    editorCard:SetPoint("TOPLEFT", colBar, "BOTTOMLEFT", 0, -6)
    editorCard:SetPoint("TOPRIGHT", colBar, "BOTTOMRIGHT", 0, -6)
    panel.editorCard = editorCard

    local msgInput = UIStyle:CreateEditBox(editorCard, 28, L["Enter greeting message... (e.g. Hello %s!)"] or "Begrüßungsnachricht eingeben... (z. B. Hallo %s!)")
    panel.msgInput = msgInput

    local function commitMessageEdit()
        local txt = strtrim(msgInput:GetText() or "")
        if txt == "" then return end
        local list = GetActiveCategoryList(selectedCategory)
        if selectedMsgIndex and list[selectedMsgIndex] then
            list[selectedMsgIndex] = txt
        else
            table.insert(list, txt)
        end
        selectedMsgIndex = nil
        SyncGreetingAliases()
        msgInput:SetText("")
        msgInput._syncPlaceholder()
        lastPreviewText = FormatPreviewSample(txt)
        RefreshGreetingsPanel()
    end

    msgInput:SetScript("OnEnterPressed", function(selfBox)
        selfBox:ClearFocus()
        commitMessageEdit()
    end)

    panel.addSaveBtn = UIStyle:CreateButton(editorCard, L["Add"] or "Hinzufügen", 95, 28, commitMessageEdit, true)
    panel.secondaryBtn = UIStyle:CreateButton(editorCard, L["Restore default"] or "Standard wiederherstellen", 140, 28, function()
        if selectedMsgIndex then
            selectedMsgIndex = nil
            msgInput:SetText("")
            msgInput._syncPlaceholder()
            RefreshGreetingsPanel()
        else
            local list = GetActiveCategoryList(selectedCategory)
            wipe(list)
            if GLDG.Database and GLDG.Database.InitializeGreetings then
                GLDG.Database:InitializeGreetings()
            end
            SyncGreetingAliases()
            RefreshGreetingsPanel()
        end
    end, false)

    -- Clickable Placeholder Chips
    local chipHint = editorCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    chipHint:SetTextColor(unpack(UIStyle.Colors.goldDim))
    chipHint:SetText(L["Insert Placeholder:"] or "Platzhalter einfügen:")
    panel.chipHint = chipHint

    panel.chips = {}
    for cIdx, cMeta in ipairs(PLACEHOLDER_CHIPS) do
        local chip = CreateFrame("Button", nil, editorCard, BackdropTemplateMixin and "BackdropTemplate" or nil)
        UIStyle:ApplyBox(chip, UIStyle.Colors.bgRow, UIStyle.Colors.borderSubtle)
        local cLbl = chip:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        cLbl:SetPoint("CENTER", 0, 0)
        cLbl:SetText(UIStyle.Hex.gold .. cMeta.label .. "|r")
        chip.label = cLbl

        chip:SetScript("OnEnter", function(selfChip)
            UIStyle:ApplyBox(selfChip, UIStyle.Colors.bgRowHover, UIStyle.Colors.borderHighlight)
            GameTooltip:SetOwner(selfChip, "ANCHOR_TOP")
            GameTooltip:SetText(cMeta.token, 0.95, 0.82, 0.35)
            local desc = (cMeta.descKey and L[cMeta.descKey]) or cMeta.fallback
            GameTooltip:AddLine(desc, 0.9, 0.9, 0.9, true)
            GameTooltip:AddLine(L["Click a placeholder chip to insert it into the message."] or "Klicken zum Einfügen", 0.45, 0.85, 0.55, true)
            GameTooltip:Show()
        end)
        chip:SetScript("OnLeave", function(selfChip)
            UIStyle:ApplyBox(selfChip, UIStyle.Colors.bgRow, UIStyle.Colors.borderSubtle)
            GameTooltip:Hide()
        end)
        chip:SetScript("OnClick", function()
            msgInput:SetFocus()
            msgInput:Insert(cMeta.token)
            msgInput._syncPlaceholder()
        end)
        panel.chips[cIdx] = chip
    end

    -- Inline Preview Strip inside Editor Card
    local previewBox = CreateFrame("Frame", nil, editorCard, BackdropTemplateMixin and "BackdropTemplate" or nil)
    UIStyle:ApplyBox(previewBox, UIStyle.Colors.bgInput, UIStyle.Colors.borderSubtle)
    previewBox:Hide()
    local previewText = previewBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    previewText:SetPoint("LEFT", previewBox, "LEFT", 10, 0)
    previewText:SetPoint("RIGHT", previewBox, "RIGHT", -10, 0)
    previewText:SetJustifyH("LEFT")
    previewText:SetWordWrap(false)
    previewBox.text = previewText
    panel.previewBox = previewBox
    panel.previewText = previewText

    -- 3. Templates List Card
    local listCard = UIStyle:CreateCard(rightPane, L["Greetings"] or "Vorlagen")
    listCard:SetPoint("TOPLEFT", editorCard, "BOTTOMLEFT", 0, -6)
    listCard:SetPoint("BOTTOMRIGHT", rightPane, "BOTTOMRIGHT", 0, 0)
    panel.listCard = listCard

    local listScroll = CreateFrame("ScrollFrame", nil, listCard, "UIPanelScrollFrameTemplate")
    listScroll:SetPoint("TOPLEFT", listCard.header, "BOTTOMLEFT", 4, -4)
    listScroll:SetPoint("BOTTOMRIGHT", listCard, "BOTTOMRIGHT", -24, 4)
    panel.listScroll = listScroll

    local listScrollChild = CreateFrame("Frame", nil, listScroll)
    listScrollChild:SetSize(480, 100)
    listScroll:SetScrollChild(listScrollChild)
    panel.listScrollChild = listScrollChild

    local emptyText = listCard:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    emptyText:SetPoint("CENTER", listCard, "CENTER", -8, -8)
    emptyText:SetTextColor(unpack(UIStyle.Colors.textMuted))
    emptyText:Hide()
    panel.emptyText = emptyText

    panel:SetScript("OnSizeChanged", function()
        if panel:IsShown() then
            RefreshGreetingsPanel()
        end
    end)

    greetingsPanel = panel
    return panel
end

function GLDG:ShowGreetingsTabPanel(hostFrame)
    if self.Database and self.Database.InitializeGreetings then
        self.Database:InitializeGreetings()
    end
    local panel = EnsureGreetingsPanel(hostFrame)
    panel:Show()
    RefreshGreetingsPanel()
end

function GLDG:HideGreetingsTabPanel()
    if greetingsPanel then
        greetingsPanel:Hide()
    end
end

function GLDG:CreateGreetingsTab(container)
    if container and container.frame then
        self:ShowGreetingsTabPanel(container.frame)
    end
end
