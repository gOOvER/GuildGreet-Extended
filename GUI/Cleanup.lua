------------------------------------------------------------
-- GuildGreet Modern GUI - Cleanup & Maintenance Tab
-- KPI Tiles, Spacious Action Cards, Reference Remover & Backup I/O
------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", true)
local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
GuildGreet = GLDG

local strtrim = strtrim or function(s)
    return string.match(tostring(s or ""), "^%s*(.-)%s*$") or ""
end

local function Ambiguate(name)
    if type(name) ~= "string" then return tostring(name or "") end
    return string.match(name, "^([^%-]+)") or name
end

local UIStyle = GLDG.UIStyle

local cleanupPanel = nil
local selectedGuildToRemove = nil
local selectedChannelToRemove = nil
local selectedFriendToRemove = nil
local statusBannerText = nil

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
    local guildlessNames = {}

    if GLDG.SyncDatabaseReferences then
        GLDG:SyncDatabaseReferences()
    end
    if GLDG_DataChar then
        for charName, p in pairs(GLDG_DataChar) do
            if type(p) == "table" then
                total = total + 1
                if p.main then mains = mains + 1 end
                if p.alt then alts = alts + 1 end
                if p.ignore then ignored = ignored + 1 end
                if not p.guild or p.guild == "" then
                    guildless = guildless + 1
                    table.insert(guildlessNames, Ambiguate(charName))
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
    if GLDG.db and GLDG.db.realm and type(GLDG.db.realm.guildPlayers) == "table" then
        for gName, gTbl in pairs(GLDG.db.realm.guildPlayers) do
            if type(gTbl) == "table" then
                local cnt = 0
                for _ in pairs(gTbl) do cnt = cnt + 1 end
                if cnt > 0 then
                    guilds[gName] = cnt
                end
            end
        end
    end
    table.sort(guildlessNames)

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
        guildlessNames = guildlessNames,
    }
end

local function BuildSortedDropdownItems(mapTbl)
    local keys = {}
    for k in pairs(mapTbl) do
        table.insert(keys, k)
    end
    table.sort(keys)
    local items = {}
    for _, k in ipairs(keys) do
        local displayKey = GLDG.FormatGuildDisplay and GLDG:FormatGuildDisplay(k) or tostring(k)
        table.insert(items, {
            value = k,
            label = string.format("%s  %s(%d)|r", displayKey, UIStyle.Hex.goldDim, mapTbl[k]),
        })
    end
    return items
end

local RefreshCleanupPanel

RefreshCleanupPanel = function()
    if not cleanupPanel or not cleanupPanel:IsShown() then return end

    local stats = CollectStats()
    local fontSize = UIStyle:GetFontSize()
    local scrollW = math.max(520, (cleanupPanel:GetWidth() or 820) - 28)

    local yCursor = 0

    -- 1. KPI Stat Tiles Card
    local kpiCard = cleanupPanel.kpiCard
    UIStyle:ApplyFont(kpiCard.title, 0)
    local tileH = math.max(54, fontSize * 2 + 28)
    local kpiCardH = 38 + tileH + 10
    kpiCard:ClearAllPoints()
    kpiCard:SetPoint("TOPLEFT", cleanupPanel.scrollChild, "TOPLEFT", 0, yCursor)
    kpiCard:SetSize(scrollW, kpiCardH)

    local kpiValues = {
        { val = stats.total,     label = L["Players"] or "Spieler",   hex = UIStyle.Hex.gold },
        { val = stats.mains,     label = L["Main"] or "Mains",        hex = UIStyle.Hex.green },
        { val = stats.alts,      label = L["Alts"] or "Twinks",       hex = UIStyle.Hex.cyan },
        { val = stats.ignored,   label = L["Ignored"] or "Ignoriert", hex = UIStyle.Hex.red },
        { val = stats.guildless, label = L["Guildless"] or "Gildenlos", hex = UIStyle.Hex.textLight },
        { val = stats.orphans,   label = L["Orphans"] or "Waisen",    hex = UIStyle.Hex.textLight },
    }
    local gap = 8
    local tileW = math.floor((scrollW - 20 - gap * 5) / 6)
    for idx, kv in ipairs(kpiValues) do
        local tile = cleanupPanel.kpiTiles[idx]
        tile:SetSize(tileW, tileH)
        tile:ClearAllPoints()
        tile:SetPoint("TOPLEFT", kpiCard, "TOPLEFT", 10 + (idx - 1) * (tileW + gap), -36)
        UIStyle:ApplyFont(tile.numText, 4)
        UIStyle:ApplyFont(tile.lblText, -1)
        tile.numText:SetText(kv.hex .. tostring(kv.val) .. "|r")
        tile.lblText:SetText(kv.label)
    end
    yCursor = yCursor - (kpiCardH + 8)

    -- 2. Maintenance & Consistency Card (2x3 spacious grid + status bar)
    local maintCard = cleanupPanel.maintCard
    UIStyle:ApplyFont(maintCard.title, 0)
    local colW = math.floor((scrollW - 28) / 2)
    local actionCardH = math.max(52, fontSize * 2 + 26)

    local actionMeta = {
        {
            title = string.format("%s (%d)", L["Orphan cleanup"] or "Waisen bereinigen", stats.orphans),
            desc  = L["Remove characters without guild, main/alt link, or alias"] or "Charaktere ohne Gilde, Main/Twink oder Vorname entfernen",
            btn   = L["Clean"] or "Bereinigen",
            disabled = (stats.orphans == 0),
            onClick = function()
                local before = stats.orphans
                GLDG_ClickOrphanCleanup()
                statusBannerText = UIStyle.Hex.green .. string.format(L["Removed %d orphan character(s)."] or "%d verwaiste(r) Charakter(e) entfernt.", before) .. "|r"
                RefreshCleanupPanel()
                if GLDG.RefreshSidebarStats then GLDG:RefreshSidebarStats() end
            end,
        },
        {
            title = string.format("%s (%d)", L["Guildless display"] or "Gildenlose anzeigen", stats.guildless),
            desc  = L["List stored characters without a guild"] or "Gespeicherte Charaktere ohne Gilde anzeigen",
            btn   = L["Show"] or "Anzeigen",
            disabled = false,
            onClick = function()
                GLDG_ClickGuildlessDisplay()
                if #stats.guildlessNames > 0 then
                    statusBannerText = UIStyle.Hex.gold .. string.format(
                        L["Guildless characters (%d): %s"] or "Gildenlose Charaktere (%d): %s",
                        #stats.guildlessNames,
                        table.concat(stats.guildlessNames, ", ")
                    ) .. "|r"
                else
                    statusBannerText = UIStyle.Hex.green .. (L["No guildless characters found."] or "Keine gildenlosen Charaktere gefunden.") .. "|r"
                end
                RefreshCleanupPanel()
            end,
        },
        {
            title = string.format("%s (%d)", L["Guildless cleanup"] or "Gildenlose bereinigen", stats.guildless),
            desc  = L["Delete all stored guildless characters"] or "Alle gespeicherten gildenlosen Charaktere löschen",
            btn   = L["Remove"] or "Entfernen",
            disabled = (stats.guildless == 0),
            onClick = function()
                local before = stats.guildless
                GLDG_ClickGuildlessCleanup()
                statusBannerText = UIStyle.Hex.green .. string.format(L["Removed %d guildless character(s)."] or "%d gildenlose(r) Charakter(e) entfernt.", before) .. "|r"
                RefreshCleanupPanel()
                if GLDG.RefreshSidebarStats then GLDG:RefreshSidebarStats() end
            end,
        },
        {
            title = L["Check consistency"] or "Konsistenz prüfen",
            desc  = L["Verify Main/Alt links for errors"] or "Main-/Twink-Zuordnungen auf Fehler überprüfen",
            btn   = L["Check"] or "Prüfen",
            disabled = false,
            onClick = function()
                GLDG_Convert_Plausibility_Check(false)
                statusBannerText = UIStyle.Hex.cyan .. (L["Consistency check completed — see chat for details."] or "Konsistenzprüfung abgeschlossen (Details im Chat).") .. "|r"
                RefreshCleanupPanel()
            end,
        },
        {
            title = L["Fix inconsistencies"] or "Inkonsistenzen automatisch beheben",
            desc  = L["Automatically repair broken Main/Alt links"] or "Fehlerhafte Main-/Twink-Zuordnungen reparieren",
            btn   = L["Repair"] or "Reparieren",
            disabled = false,
            onClick = function()
                GLDG_fixCount = 0
                GLDG_Convert_Plausibility_Fix(false)
                statusBannerText = UIStyle.Hex.green .. string.format(L["Consistency auto-repair completed (%d fixed)."] or "Konsistenz-Reparatur abgeschlossen (%d behoben).", tonumber(GLDG_fixCount) or 0) .. "|r"
                RefreshCleanupPanel()
            end,
        },
        {
            title = L["Clear 'New in Guild' flag"] or "'Neu in der Gilde'-Markierung löschen",
            desc  = L["Reset 'new member' status on all characters"] or "Neumitglied-Markierung bei allen Charakteren zurücksetzen",
            btn   = L["Reset"] or "Zurücksetzen",
            disabled = false,
            onClick = function()
                GLDG_Convert_Unnew()
                statusBannerText = UIStyle.Hex.green .. (L["Cleared 'New in Guild' flag on all characters."] or "'Neu in der Gilde'-Markierung bei allen Charakteren zurückgesetzt.") .. "|r"
                RefreshCleanupPanel()
            end,
        },
    }

    for idx, meta in ipairs(actionMeta) do
        local box = cleanupPanel.actionBoxes[idx]
        local col = (idx - 1) % 2
        local row = math.floor((idx - 1) / 2)
        box:SetSize(colW, actionCardH)
        box:ClearAllPoints()
        box:SetPoint("TOPLEFT", maintCard, "TOPLEFT", 10 + col * (colW + 8), -36 - row * (actionCardH + 6))

        box.actionBtn:SetText(meta.btn)
        box.actionBtn:SetDisabledState(meta.disabled)
        box.actionBtn:SetScript("OnClick", meta.onClick)
        box.actionBtn:ClearAllPoints()
        box.actionBtn:SetPoint("RIGHT", box, "RIGHT", -10, 0)

        UIStyle:ApplyFont(box.titleText, 0)
        UIStyle:ApplyFont(box.descText, -2)
        box.titleText:SetText(meta.title)
        box.descText:SetText(meta.desc)
    end

    local statusY = -36 - 3 * (actionCardH + 6) - 2
    local statusH = math.max(28, fontSize + 14)
    cleanupPanel.statusBox:ClearAllPoints()
    cleanupPanel.statusBox:SetPoint("TOPLEFT", maintCard, "TOPLEFT", 10, statusY)
    cleanupPanel.statusBox:SetSize(scrollW - 20, statusH)
    UIStyle:ApplyFont(cleanupPanel.statusText, -1)
    cleanupPanel.statusText:SetText(statusBannerText or (UIStyle.Hex.textMuted .. (L["Ready. Choose a maintenance action above."] or "Bereit. Wähle oben eine Wartungsaktion aus.") .. "|r"))

    local maintCardH = math.abs(statusY) + statusH + 10
    maintCard:ClearAllPoints()
    maintCard:SetPoint("TOPLEFT", cleanupPanel.scrollChild, "TOPLEFT", 0, yCursor)
    maintCard:SetSize(scrollW, maintCardH)
    yCursor = yCursor - (maintCardH + 8)

    -- 3. Remove Stored Guild / Channel / Friend References
    local refCard = cleanupPanel.refCard
    UIStyle:ApplyFont(refCard.title, 0)
    local refRowH = math.max(32, fontSize + 18)
    local refSpecs = {
        {
            label = L["Guild"] or "Gilde",
            items = BuildSortedDropdownItems(stats.guilds),
            selected = selectedGuildToRemove,
            onSelect = function(v) selectedGuildToRemove = v; RefreshCleanupPanel() end,
            onRemove = function()
                if not selectedGuildToRemove then return end
                if GLDG.db and GLDG.db.realm and type(GLDG.db.realm.guildPlayers) == "table" then
                    GLDG.db.realm.guildPlayers[selectedGuildToRemove] = nil
                end
                GLDG_CleanupList = { selectedGuildToRemove }
                GLDG_CleanupMode = "guild"
                GLDG_CleanupExecute(selectedGuildToRemove)
                selectedGuildToRemove = nil
                if GLDG.SyncDatabaseReferences then GLDG:SyncDatabaseReferences() end
                RefreshCleanupPanel()
                if GLDG.RefreshSidebarStats then GLDG:RefreshSidebarStats() end
            end,
        },
        {
            label = L["Channel"] or "Kanal",
            items = BuildSortedDropdownItems(stats.channels),
            selected = selectedChannelToRemove,
            onSelect = function(v) selectedChannelToRemove = v; RefreshCleanupPanel() end,
            onRemove = function()
                if not selectedChannelToRemove then return end
                GLDG_CleanupList = { selectedChannelToRemove }
                GLDG_CleanupMode = "channel"
                GLDG_CleanupExecute(selectedChannelToRemove)
                selectedChannelToRemove = nil
                RefreshCleanupPanel()
            end,
        },
        {
            label = L["Friends"] or "Freunde",
            items = BuildSortedDropdownItems(stats.friends),
            selected = selectedFriendToRemove,
            onSelect = function(v) selectedFriendToRemove = v; RefreshCleanupPanel() end,
            onRemove = function()
                if not selectedFriendToRemove then return end
                GLDG_CleanupList = { selectedFriendToRemove }
                GLDG_CleanupMode = "friends"
                GLDG_CleanupExecute(selectedFriendToRemove)
                selectedFriendToRemove = nil
                RefreshCleanupPanel()
            end,
        },
    }

    local lblColW = math.max(110, fontSize * 8)
    for idx, spec in ipairs(refSpecs) do
        local rRow = cleanupPanel.refRows[idx]
        rRow:SetSize(scrollW - 20, refRowH)
        rRow:ClearAllPoints()
        rRow:SetPoint("TOPLEFT", refCard, "TOPLEFT", 10, -36 - (idx - 1) * (refRowH + 6))

        UIStyle:ApplyFont(rRow.lbl, 0)
        rRow.lbl:SetWidth(lblColW)
        rRow.lbl:SetText(spec.label)

        rRow.removeBtn:SetText(L["Remove"] or "Entfernen")
        rRow.removeBtn:ClearAllPoints()
        rRow.removeBtn:SetPoint("RIGHT", rRow, "RIGHT", 0, 0)

        rRow.dropBtn:ClearAllPoints()
        rRow.dropBtn:SetPoint("LEFT", rRow.lbl, "RIGHT", 8, 0)
        rRow.dropBtn:SetPoint("RIGHT", rRow.removeBtn, "LEFT", -8, 0)
        rRow.dropBtn:SetHeight(math.max(26, fontSize + 13))
        UIStyle:ApplyFont(rRow.dropBtn.label, 0)

        if #spec.items == 0 then
            rRow.dropBtn.label:SetText(UIStyle.Hex.textMuted .. (L["-- No entries available --"] or "-- Keine Einträge vorhanden --") .. "|r")
            rRow.dropBtn:SetDisabledState(true)
            rRow.removeBtn:SetDisabledState(true)
        else
            rRow.dropBtn:SetDisabledState(false)
            local foundLabel = nil
            for _, it in ipairs(spec.items) do
                if it.value == spec.selected then
                    foundLabel = it.label
                    break
                end
            end
            if foundLabel then
                rRow.dropBtn.label:SetText(foundLabel)
                rRow.removeBtn:SetDisabledState(false)
            else
                rRow.dropBtn.label:SetText(UIStyle.Hex.goldDim .. string.format(L["-- Select entry (%d) --"] or "-- Eintrag auswählen (%d) --", #spec.items) .. "|r")
                rRow.removeBtn:SetDisabledState(true)
            end
            rRow.dropBtn:SetScript("OnClick", function(selfBtn)
                UIStyle:OpenDropdown(selfBtn, spec.items, spec.selected, function(val)
                    spec.onSelect(val)
                end)
            end)
        end
        rRow.removeBtn:SetScript("OnClick", spec.onRemove)
    end

    local refCardH = 36 + 3 * (refRowH + 6) + 6
    refCard:ClearAllPoints()
    refCard:SetPoint("TOPLEFT", cleanupPanel.scrollChild, "TOPLEFT", 0, yCursor)
    refCard:SetSize(scrollW, refCardH)
    yCursor = yCursor - (refCardH + 8)

    -- 4. Backup & Restore (Export / Import)
    local ioCard = cleanupPanel.ioCard
    UIStyle:ApplyFont(ioCard.title, 0)
    local ioCardH = 176
    ioCard:ClearAllPoints()
    ioCard:SetPoint("TOPLEFT", cleanupPanel.scrollChild, "TOPLEFT", 0, yCursor)
    ioCard:SetSize(scrollW, ioCardH)

    cleanupPanel.ioBoxBg:ClearAllPoints()
    cleanupPanel.ioBoxBg:SetPoint("TOPLEFT", ioCard, "TOPLEFT", 10, -36)
    cleanupPanel.ioBoxBg:SetPoint("TOPRIGHT", ioCard, "TOPRIGHT", -10, -36)
    cleanupPanel.ioBoxBg:SetHeight(92)
    cleanupPanel.ioEditBox:SetWidth(math.max(300, scrollW - 56))
    UIStyle:ApplyFont(cleanupPanel.ioEditBox, -1)
    if cleanupPanel.ioPlaceholder then
        UIStyle:ApplyFont(cleanupPanel.ioPlaceholder, -1)
    end

    cleanupPanel.exportBtn:UpdateSize()
    cleanupPanel.selectAllBtn:UpdateSize()
    cleanupPanel.importBtn:UpdateSize()

    cleanupPanel.exportBtn:ClearAllPoints()
    cleanupPanel.exportBtn:SetPoint("BOTTOMLEFT", ioCard, "BOTTOMLEFT", 10, 10)
    cleanupPanel.selectAllBtn:ClearAllPoints()
    cleanupPanel.selectAllBtn:SetPoint("LEFT", cleanupPanel.exportBtn, "RIGHT", 8, 0)
    cleanupPanel.importBtn:ClearAllPoints()
    cleanupPanel.importBtn:SetPoint("BOTTOMRIGHT", ioCard, "BOTTOMRIGHT", -10, 10)

    yCursor = yCursor - (ioCardH + 8)
    cleanupPanel.scrollChild:SetSize(scrollW, math.abs(yCursor) + 6)
end

local function EnsureCleanupPanel(hostFrame)
    if cleanupPanel then
        cleanupPanel:SetParent(hostFrame)
        cleanupPanel:ClearAllPoints()
        cleanupPanel:SetAllPoints(hostFrame)
        return cleanupPanel
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

    -- 1. KPI Card
    local kpiCard = UIStyle:CreateCard(scrollChild, L["Database Overview"] or "Datenbank-Übersicht")
    panel.kpiCard = kpiCard
    panel.kpiTiles = {}
    for i = 1, 6 do
        local tile = CreateFrame("Frame", nil, kpiCard, BackdropTemplateMixin and "BackdropTemplate" or nil)
        UIStyle:ApplyBox(tile, UIStyle.Colors.bgInput, UIStyle.Colors.borderSubtle)
        local numText = tile:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        numText:SetPoint("TOP", tile, "TOP", 0, -8)
        tile.numText = numText
        local lblText = tile:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        lblText:SetPoint("BOTTOM", tile, "BOTTOM", 0, 7)
        lblText:SetTextColor(unpack(UIStyle.Colors.textMuted))
        lblText:SetWordWrap(false)
        tile.lblText = lblText
        panel.kpiTiles[i] = tile
    end

    -- 2. Maintenance Card
    local maintCard = UIStyle:CreateCard(scrollChild, L["Maintenance & Consistency"] or "Wartung & Konsistenzprüfung")
    panel.maintCard = maintCard
    panel.actionBoxes = {}
    for i = 1, 6 do
        local box = CreateFrame("Frame", nil, maintCard, BackdropTemplateMixin and "BackdropTemplate" or nil)
        UIStyle:ApplyBox(box, UIStyle.Colors.bgRow, UIStyle.Colors.borderSubtle)
        local actionBtn = UIStyle:CreateButton(box, "", 96, 26, nil, false)
        box.actionBtn = actionBtn

        local titleText = box:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        titleText:SetPoint("TOPLEFT", box, "TOPLEFT", 12, -9)
        titleText:SetPoint("RIGHT", actionBtn, "LEFT", -10, 0)
        titleText:SetJustifyH("LEFT")
        titleText:SetWordWrap(false)
        titleText:SetTextColor(unpack(UIStyle.Colors.textLight))
        box.titleText = titleText

        local descText = box:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        descText:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -3)
        descText:SetPoint("RIGHT", actionBtn, "LEFT", -10, 0)
        descText:SetJustifyH("LEFT")
        descText:SetWordWrap(false)
        descText:SetTextColor(unpack(UIStyle.Colors.textMuted))
        box.descText = descText

        panel.actionBoxes[i] = box
    end

    local statusBox = CreateFrame("Frame", nil, maintCard, BackdropTemplateMixin and "BackdropTemplate" or nil)
    UIStyle:ApplyBox(statusBox, UIStyle.Colors.bgInput, UIStyle.Colors.borderSubtle)
    local statusText = statusBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    statusText:SetPoint("LEFT", statusBox, "LEFT", 10, 0)
    statusText:SetPoint("RIGHT", statusBox, "RIGHT", -10, 0)
    statusText:SetJustifyH("LEFT")
    statusText:SetWordWrap(false)
    panel.statusBox = statusBox
    panel.statusText = statusText

    -- 3. Remove Stored References Card
    local refCard = UIStyle:CreateCard(scrollChild, L["Remove Stored References"] or "Gespeicherte Referenzen entfernen")
    panel.refCard = refCard
    panel.refRows = {}
    for i = 1, 3 do
        local rRow = CreateFrame("Frame", nil, refCard)
        local lbl = rRow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lbl:SetPoint("LEFT", rRow, "LEFT", 2, 0)
        lbl:SetJustifyH("LEFT")
        lbl:SetTextColor(unpack(UIStyle.Colors.gold))
        rRow.lbl = lbl

        local dropBtn = UIStyle:CreateDropdown(rRow, 280, 28)
        rRow.dropBtn = dropBtn

        local removeBtn = UIStyle:CreateButton(rRow, L["Remove"] or "Entfernen", 110, 28, nil, false)
        rRow.removeBtn = removeBtn

        panel.refRows[i] = rRow
    end

    -- 4. Backup & Restore Card
    local ioCard = UIStyle:CreateCard(scrollChild, L["Backup & Restore (Export / Import)"] or "Einstellungen sichern & wiederherstellen (Export / Import)")
    panel.ioCard = ioCard

    local ioBoxBg = CreateFrame("Frame", nil, ioCard, BackdropTemplateMixin and "BackdropTemplate" or nil)
    UIStyle:ApplyBox(ioBoxBg, UIStyle.Colors.bgInput, UIStyle.Colors.border)
    panel.ioBoxBg = ioBoxBg

    local ioScroll = CreateFrame("ScrollFrame", nil, ioBoxBg, "UIPanelScrollFrameTemplate")
    ioScroll:SetPoint("TOPLEFT", ioBoxBg, "TOPLEFT", 8, -6)
    ioScroll:SetPoint("BOTTOMRIGHT", ioBoxBg, "BOTTOMRIGHT", -26, 6)

    local ioEditBox = CreateFrame("EditBox", nil, ioScroll)
    ioEditBox:SetMultiLine(true)
    ioEditBox:SetAutoFocus(false)
    ioEditBox:SetFontObject(ChatFontNormal)
    ioEditBox:SetTextColor(unpack(UIStyle.Colors.textLight))
    ioEditBox:SetWidth(600)
    ioEditBox:SetScript("OnEscapePressed", function(selfBox) selfBox:ClearFocus() end)
    ioScroll:SetScrollChild(ioEditBox)
    panel.ioEditBox = ioEditBox

    local ioPlaceholder = ioBoxBg:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    ioPlaceholder:SetPoint("TOPLEFT", ioBoxBg, "TOPLEFT", 10, -8)
    ioPlaceholder:SetPoint("RIGHT", ioBoxBg, "RIGHT", -30, 0)
    ioPlaceholder:SetJustifyH("LEFT")
    ioPlaceholder:SetTextColor(unpack(UIStyle.Colors.textMuted))
    ioPlaceholder:SetText(L["Paste an export string above or click 'Generate Export' to create a backup."] or "Export-Text hier einfügen oder unten auf 'Export erzeugen' klicken...")
    panel.ioPlaceholder = ioPlaceholder

    local function syncIoPlaceholder()
        if (ioEditBox:GetText() or "") ~= "" or ioEditBox:HasFocus() then
            ioPlaceholder:Hide()
        else
            ioPlaceholder:Show()
        end
    end
    ioEditBox:SetScript("OnEditFocusGained", function()
        UIStyle:ApplyBox(ioBoxBg, UIStyle.Colors.bgInput, UIStyle.Colors.borderHighlight)
        syncIoPlaceholder()
    end)
    ioEditBox:SetScript("OnEditFocusLost", function()
        UIStyle:ApplyBox(ioBoxBg, UIStyle.Colors.bgInput, UIStyle.Colors.border)
        syncIoPlaceholder()
    end)
    ioEditBox:SetScript("OnTextChanged", function()
        syncIoPlaceholder()
    end)
    ioBoxBg:EnableMouse(true)
    ioBoxBg:SetScript("OnMouseDown", function() ioEditBox:SetFocus() end)

    panel.exportBtn = UIStyle:CreateButton(ioCard, L["Generate Export"] or L["Export settings"] or "Export erzeugen", 145, 28, function()
        local payload = {
            version = "3.1.0",
            greetings = GLDG_DataGreet,
            collections = GLDG_Data and GLDG_Data.Collections,
            colours = GLDG_Data and GLDG_Data.colours,
        }
        local serialized = GLDG:Serialize(payload)
        ioEditBox:SetText(serialized or "")
        syncIoPlaceholder()
        ioEditBox:SetFocus()
        ioEditBox:HighlightText()
        GLDG:PrintInfo(L["Copy this text to save your settings"] or "Export-String erzeugt.")
    end, true)

    panel.selectAllBtn = UIStyle:CreateButton(ioCard, L["Select All"] or "Alles markieren", 120, 28, function()
        ioEditBox:SetFocus()
        ioEditBox:HighlightText()
    end, false)

    panel.importBtn = UIStyle:CreateButton(ioCard, L["Import settings"] or "Einstellungen importieren", 165, 28, function()
        local raw = strtrim(ioEditBox:GetText() or "")
        if raw == "" then
            GLDG:PrintError(L["Paste your settings text here"] or "Bitte zuerst einen gültigen Backup-String einfügen.")
            return
        end
        local ok, data = GLDG:Deserialize(raw)
        if not ok or type(data) ~= "table" then
            GLDG:PrintError(L["Failed to import settings"] or "Ungültiger Backup-String.")
            return
        end
        if type(data.greetings) == "table" and GLDG_DataGreet then
            for k, v in pairs(data.greetings) do
                if type(v) == "table" then
                    GLDG_DataGreet[k] = v
                end
            end
        end
        if type(data.collections) == "table" and GLDG_Data then
            GLDG_Data.Collections = GLDG_Data.Collections or {}
            for k, v in pairs(data.collections) do
                if type(v) == "table" then
                    GLDG_Data.Collections[k] = v
                end
            end
        end
        if type(data.colours) == "table" and GLDG_Data then
            GLDG_Data.colours = data.colours
            if GLDG.Colors and GLDG.Colors.Initialize then
                GLDG.Colors:Initialize()
            end
        end
        if GLDG.SyncDatabaseReferences then GLDG:SyncDatabaseReferences() end
        GLDG:PrintInfo(L["Settings imported successfully"] or "Einstellungen erfolgreich importiert!")
        RefreshCleanupPanel()
    end, false)

    panel:SetScript("OnSizeChanged", function()
        if panel:IsShown() then
            RefreshCleanupPanel()
        end
    end)

    cleanupPanel = panel
    return panel
end

function GLDG:ShowCleanupTabPanel(hostFrame)
    if self.PlayerManager and self.PlayerManager.NormalizeStoredPlayers then
        self.PlayerManager:NormalizeStoredPlayers()
    end
    local panel = EnsureCleanupPanel(hostFrame)
    panel:Show()
    RefreshCleanupPanel()
end

function GLDG:HideCleanupTabPanel()
    if cleanupPanel then
        cleanupPanel:Hide()
    end
end

function GLDG:CreateCleanupTab(container)
    if container and container.frame then
        self:ShowCleanupTabPanel(container.frame)
    end
end
