------------------------------------------------------------
-- GuildGreet Modern GUI - Players Manager Tab & Edit Popup
-- Structured multi-column roster table + floating Edit Popup
------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", true)
local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
GuildGreet = GLDG

local function Ambiguate(name)
    if type(name) ~= "string" then return tostring(name or "") end
    return string.match(name, "^([^%-]+)") or name
end

local strtrim = strtrim or function(s)
    return string.match(tostring(s or ""), "^%s*(.-)%s*$") or ""
end

local UIStyle = GLDG.UIStyle

local searchFilter = ""
local roleFilter = "all"
local editingPlayer = nil

local playersPanel = nil
local rowPool = {}
local dropdownMenu = nil
local dropdownCatcher = nil
local editPopup = nil

------------------------------------------------------------
-- Data & Formatting Helpers
------------------------------------------------------------
local function GetClassHex(enClass)
    if enClass and RAID_CLASS_COLORS and RAID_CLASS_COLORS[enClass] then
        local c = RAID_CLASS_COLORS[enClass]
        if c.colorStr then
            return "|c" .. c.colorStr
        end
        return string.format("|cff%02x%02x%02x", (c.r or 1) * 255, (c.g or 1) * 255, (c.b or 1) * 255)
    end
    return UIStyle.Hex.textLight
end

local function ApplyClassIcon(tex, enClass)
    if not tex then return end
    if enClass and CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[enClass] then
        local coords = CLASS_ICON_TCOORDS[enClass]
        tex:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
        tex:SetTexCoord(coords[1] + 0.02, coords[2] - 0.02, coords[3] + 0.02, coords[4] - 0.02)
        tex:Show()
    else
        tex:SetTexture("Interface\\Icons\\Achievement_GuildPerk_EverybodysFriend")
        tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        tex:Show()
    end
end

local function CountAltsOf(mainName)
    local count = 0
    if not GLDG_DataChar then return 0 end
    for _, p in pairs(GLDG_DataChar) do
        if type(p) == "table" and p.alt == mainName then
            count = count + 1
        end
    end
    return count
end

local function CleanGuildName(guildStr)
    if GLDG and GLDG.FormatGuildDisplay then
        return GLDG:FormatGuildDisplay(guildStr)
    end
    if type(guildStr) ~= "string" then return "" end
    return (string.gsub(guildStr, "^Guild:", ""))
end

local function GetActiveGuildName()
    if GLDG and GLDG.GetCurrentGuildName then
        return GLDG:GetCurrentGuildName()
    end
    if IsInGuild and not IsInGuild() then
        return ""
    end
    return CleanGuildName((GetGuildInfo and GetGuildInfo("player")) or GLDG.GuildName or "")
end

local function GetEffectiveAlias(p)
    if not p then return nil end
    if p.manualAlias and p.alias and p.alias ~= "" then
        return p.alias
    end
    if p.alt and GLDG_DataChar and GLDG_DataChar[p.alt] then
        local m = GLDG_DataChar[p.alt]
        if m.manualAlias and m.alias and m.alias ~= "" then
            return m.alias
        end
    end
    return nil
end

local function GetMainsDropdownItems(excludePlayer)
    local items = {
        {
            value = "__NONE__",
            label = L["-- Not an Alt (Unassigned) --"] or "-- Kein Twink (Nicht zugewiesen) --",
        },
    }
    if not GLDG_DataChar then return items end

    local mainsList = {}
    for name, p in pairs(GLDG_DataChar) do
        if type(p) == "table" and p.main and name ~= excludePlayer then
            local short = Ambiguate(name)
            local alias = (p.manualAlias and p.alias and p.alias ~= "") and p.alias or nil
            local cHex = GetClassHex(p.enClass)
            local text = cHex .. short .. "|r"
            if alias then
                text = text .. " " .. UIStyle.Hex.gold .. "[" .. alias .. "]|r"
            end
            table.insert(mainsList, {
                value = name,
                sortKey = string.lower(short),
                label = text,
            })
        end
    end
    table.sort(mainsList, function(a, b) return a.sortKey < b.sortKey end)
    for _, entry in ipairs(mainsList) do
        table.insert(items, entry)
    end
    return items
end

local function GetRoleFilterItems()
    return {
        { value = "all",        label = L["All Players"] or "Alle Spieler" },
        { value = "mains",      label = L["Main"] or "Main" },
        { value = "alts",       label = L["Alts"] or "Twinks" },
        { value = "unassigned", label = L["Not assigned"] or "Nicht zugewiesen" },
        { value = "online",     label = L["Online"] or "Online" },
        { value = "ignored",    label = L["Ignored"] or "Ignoriert" },
    }
end

local function GetFilteredPlayers()
    local results = {}
    local totalInGuild = 0
    if GLDG and GLDG.SyncDatabaseReferences then
        GLDG:SyncDatabaseReferences()
    end
    local curGuild = GetActiveGuildName()
    if curGuild == "" or not GLDG_DataChar then
        return results, 0
    end

    local q = string.lower(strtrim(searchFilter or ""))
    for name, p in pairs(GLDG_DataChar) do
        if type(p) == "table" then
            local inGuild = true
            local pGuild = CleanGuildName(p.guild)
            if pGuild ~= "" and pGuild ~= curGuild then
                inGuild = false
            end
            if not GLDG_Data.GuildSettings.IncludeOwn and p.own then
                inGuild = false
            end

            if inGuild then
                totalInGuild = totalInGuild + 1
                local pass = true

                if roleFilter == "mains" then
                    pass = (p.main == true)
                elseif roleFilter == "alts" then
                    pass = ((p.alt ~= nil and p.alt ~= "") or (p.twinkMainName ~= nil and p.twinkMainName ~= ""))
                elseif roleFilter == "unassigned" then
                    pass = (not p.main and not p.alt and not p.twinkMainName)
                elseif roleFilter == "online" then
                    pass = (GLDG_Online and GLDG_Online[name] ~= nil)
                elseif roleFilter == "ignored" then
                    pass = (p.ignore == true)
                end

                if pass and q ~= "" then
                    local effAlias = GetEffectiveAlias(p) or ""
                    local nLower = string.lower(name)
                    local aLower = string.lower(effAlias)
                    local mLower = string.lower((p.alt and Ambiguate(p.alt)) or p.twinkMainName or "")
                    local rLower = p.rankname and string.lower(p.rankname) or ""
                    local pnLower = p.pNote and string.lower(p.pNote) or ""
                    local onLower = p.oNote and string.lower(p.oNote) or ""
                    local cnLower = p.note and string.lower(p.note) or ""
                    if not (string.find(nLower, q, 1, true)
                        or string.find(aLower, q, 1, true)
                        or string.find(mLower, q, 1, true)
                        or string.find(rLower, q, 1, true)
                        or string.find(pnLower, q, 1, true)
                        or string.find(onLower, q, 1, true)
                        or string.find(cnLower, q, 1, true)) then
                        pass = false
                    end
                end

                if pass then
                    table.insert(results, name)
                end
            end
        end
    end

    table.sort(results, function(a, b)
        return string.lower(Ambiguate(a)) < string.lower(Ambiguate(b))
    end)

    return results, totalInGuild
end

------------------------------------------------------------
-- Custom Dark-Slate Dropdown Menu (Zero Taint, High Strata)
------------------------------------------------------------
local function CloseDropdownMenu()
    if dropdownMenu then dropdownMenu:Hide() end
    if dropdownCatcher then dropdownCatcher:Hide() end
end

local function OpenDropdownMenu(anchorBtn, items, selectedValue, onSelect)
    if dropdownMenu and dropdownMenu:IsShown() and dropdownMenu._anchor == anchorBtn then
        CloseDropdownMenu()
        return
    end

    if not dropdownCatcher then
        dropdownCatcher = CreateFrame("Button", nil, UIParent)
        dropdownCatcher:SetFrameStrata("FULLSCREEN_DIALOG")
        dropdownCatcher:SetFrameLevel(90)
        dropdownCatcher:SetAllPoints(UIParent)
        dropdownCatcher:EnableMouse(true)
        dropdownCatcher:SetScript("OnClick", CloseDropdownMenu)
    end

    if not dropdownMenu then
        dropdownMenu = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
        dropdownMenu:SetFrameStrata("TOOLTIP")
        dropdownMenu:SetFrameLevel(120)
        dropdownMenu:SetClampedToScreen(true)
        dropdownMenu:EnableMouse(true)
        UIStyle:ApplyBox(dropdownMenu, UIStyle.Colors.bgSidebar, UIStyle.Colors.borderHighlight)

        local sf = CreateFrame("ScrollFrame", nil, dropdownMenu, "UIPanelScrollFrameTemplate")
        sf:SetPoint("TOPLEFT", dropdownMenu, "TOPLEFT", 4, -4)
        sf:SetPoint("BOTTOMRIGHT", dropdownMenu, "BOTTOMRIGHT", -24, 4)
        dropdownMenu.scrollFrame = sf

        local child = CreateFrame("Frame", nil, sf)
        child:SetSize(200, 20)
        sf:SetScrollChild(child)
        dropdownMenu.scrollChild = child
        dropdownMenu.optionButtons = {}
    end

    dropdownMenu._anchor = anchorBtn
    local menuW = math.max(anchorBtn:GetWidth(), 220)
    local rowH = math.max(24, UIStyle:GetFontSize() + 10)
    local totalH = #items * rowH
    local visibleH = math.min(totalH + 8, 260)
    local needsScroll = (totalH + 8) > 260

    dropdownMenu:SetSize(menuW, visibleH)
    dropdownMenu:ClearAllPoints()
    dropdownMenu:SetPoint("TOPLEFT", anchorBtn, "BOTTOMLEFT", 0, -2)

    local sf = dropdownMenu.scrollFrame
    sf:ClearAllPoints()
    sf:SetPoint("TOPLEFT", dropdownMenu, "TOPLEFT", 4, -4)
    sf:SetPoint("BOTTOMRIGHT", dropdownMenu, "BOTTOMRIGHT", needsScroll and -24 or -4, 4)
    if sf.ScrollBar then
        if needsScroll then sf.ScrollBar:Show() else sf.ScrollBar:Hide() end
    end

    local childW = menuW - (needsScroll and 28 or 8)
    dropdownMenu.scrollChild:SetSize(childW, math.max(totalH, 10))

    for idx, item in ipairs(items) do
        local opt = dropdownMenu.optionButtons[idx]
        if not opt then
            opt = CreateFrame("Button", nil, dropdownMenu.scrollChild, BackdropTemplateMixin and "BackdropTemplate" or nil)
            local txt = opt:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            txt:SetPoint("LEFT", opt, "LEFT", 8, 0)
            txt:SetPoint("RIGHT", opt, "RIGHT", -8, 0)
            txt:SetJustifyH("LEFT")
            txt:SetWordWrap(false)
            opt.label = txt
            dropdownMenu.optionButtons[idx] = opt
        end

        opt:SetSize(childW, rowH)
        opt:ClearAllPoints()
        opt:SetPoint("TOPLEFT", dropdownMenu.scrollChild, "TOPLEFT", 0, -(idx - 1) * rowH)
        UIStyle:ApplyFont(opt.label, 0)
        opt.label:SetText(item.label or "")

        local isSelected = (item.value == selectedValue)
        if isSelected then
            UIStyle:ApplyBox(opt, UIStyle.Colors.bgRowActive, UIStyle.Colors.borderSubtle)
            opt.label:SetTextColor(unpack(UIStyle.Colors.gold))
        else
            UIStyle:ApplyBox(opt, (idx % 2 == 0) and UIStyle.Colors.bgRowAlt or UIStyle.Colors.bgRow, UIStyle.Colors.borderSubtle)
            opt.label:SetTextColor(unpack(UIStyle.Colors.textLight))
        end

        opt:SetScript("OnEnter", function(selfBtn)
            UIStyle:ApplyBox(selfBtn, UIStyle.Colors.bgRowHover, UIStyle.Colors.borderHighlight)
        end)
        opt:SetScript("OnLeave", function(selfBtn)
            if item.value == selectedValue then
                UIStyle:ApplyBox(selfBtn, UIStyle.Colors.bgRowActive, UIStyle.Colors.borderSubtle)
            else
                UIStyle:ApplyBox(selfBtn, (idx % 2 == 0) and UIStyle.Colors.bgRowAlt or UIStyle.Colors.bgRow, UIStyle.Colors.borderSubtle)
            end
        end)
        opt:SetScript("OnClick", function()
            CloseDropdownMenu()
            if onSelect then
                onSelect(item.value, item.label)
            end
        end)
        opt:Show()
    end

    for idx = #items + 1, #dropdownMenu.optionButtons do
        dropdownMenu.optionButtons[idx]:Hide()
    end

    dropdownCatcher:Show()
    dropdownMenu:Show()
end

local function CreateDropdownButton(parent, width, height)
    local btn = CreateFrame("Button", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    btn:SetSize(width or 180, height or 28)
    UIStyle:ApplyBox(btn, UIStyle.Colors.bgInput, UIStyle.Colors.border)

    local txt = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    txt:SetPoint("LEFT", btn, "LEFT", 10, 0)
    txt:SetPoint("RIGHT", btn, "RIGHT", -24, 0)
    txt:SetJustifyH("LEFT")
    txt:SetWordWrap(false)
    UIStyle:ApplyFont(txt, 0)
    txt:SetTextColor(unpack(UIStyle.Colors.textLight))
    btn.label = txt

    local arrow = btn:CreateTexture(nil, "ARTWORK")
    arrow:SetSize(12, 12)
    arrow:SetPoint("RIGHT", btn, "RIGHT", -8, -1)
    arrow:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    arrow:SetTexCoord(0.2, 0.8, 0.2, 0.8)
    btn.arrow = arrow

    btn:SetScript("OnEnter", function(selfBtn)
        if not selfBtn:IsEnabled() then return end
        UIStyle:ApplyBox(selfBtn, UIStyle.Colors.bgRowHover, UIStyle.Colors.borderHighlight)
    end)
    btn:SetScript("OnLeave", function(selfBtn)
        if not selfBtn:IsEnabled() then return end
        UIStyle:ApplyBox(selfBtn, UIStyle.Colors.bgInput, UIStyle.Colors.border)
    end)

    function btn:SetDisabledState(disabled)
        if disabled then
            self:Disable()
            self:SetAlpha(0.45)
        else
            self:Enable()
            self:SetAlpha(1.0)
        end
    end

    return btn
end

local function CreateStyledEditBox(parent, height, placeholderText)
    local box = CreateFrame("EditBox", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    box:SetHeight(height or 28)
    box:SetAutoFocus(false)
    box:SetTextInsets(10, 26, 0, 0)
    box:SetFontObject(ChatFontNormal)
    UIStyle:ApplyFont(box, 0)
    box:SetTextColor(unpack(UIStyle.Colors.textLight))
    UIStyle:ApplyBox(box, UIStyle.Colors.bgInput, UIStyle.Colors.border)

    if placeholderText and placeholderText ~= "" then
        local ph = box:CreateFontString(nil, "ARTWORK", "GameFontDisable")
        ph:SetPoint("LEFT", box, "LEFT", 10, 0)
        ph:SetPoint("RIGHT", box, "RIGHT", -26, 0)
        ph:SetJustifyH("LEFT")
        ph:SetWordWrap(false)
        UIStyle:ApplyFont(ph, 0)
        ph:SetTextColor(unpack(UIStyle.Colors.textMuted))
        ph:SetText(placeholderText)
        box.placeholder = ph
    end

    local clearBtn = CreateFrame("Button", nil, box)
    clearBtn:SetSize(14, 14)
    clearBtn:SetPoint("RIGHT", box, "RIGHT", -7, 0)
    local clearTex = clearBtn:CreateTexture(nil, "ARTWORK")
    clearTex:SetAllPoints()
    clearTex:SetTexture("Interface\\Buttons\\UI-StopButton")
    clearTex:SetVertexColor(0.65, 0.68, 0.75, 0.85)
    clearBtn.tex = clearTex
    clearBtn:Hide()
    clearBtn:SetScript("OnEnter", function() clearTex:SetVertexColor(1, 0.82, 0.35, 1) end)
    clearBtn:SetScript("OnLeave", function() clearTex:SetVertexColor(0.65, 0.68, 0.75, 0.85) end)
    clearBtn:SetScript("OnClick", function()
        box:SetText("")
        box:ClearFocus()
        if box._onClear then box._onClear() end
    end)
    box.clearBtn = clearBtn

    local function syncPlaceholder()
        local hasText = (box:GetText() or "") ~= ""
        if box.placeholder then
            if hasText or box:HasFocus() then
                box.placeholder:Hide()
            else
                box.placeholder:Show()
            end
        end
        if hasText then
            clearBtn:Show()
        else
            clearBtn:Hide()
        end
    end

    box:SetScript("OnEditFocusGained", function(selfBox)
        UIStyle:ApplyBox(selfBox, UIStyle.Colors.bgInput, UIStyle.Colors.borderHighlight)
        syncPlaceholder()
    end)
    box:SetScript("OnEditFocusLost", function(selfBox)
        UIStyle:ApplyBox(selfBox, UIStyle.Colors.bgInput, UIStyle.Colors.border)
        syncPlaceholder()
    end)
    box:SetScript("OnEscapePressed", function(selfBox)
        selfBox:ClearFocus()
    end)
    box:HookScript("OnTextChanged", syncPlaceholder)
    box._syncPlaceholder = syncPlaceholder

    return box
end

local function CreateIconButton(parent, iconPath, size, tooltipTitle, onClick, isAccent)
    local btn = CreateFrame("Button", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    btn:SetSize(size or 26, size or 26)
    UIStyle:ApplyBox(
        btn,
        isAccent and UIStyle.Colors.bgRowActive or UIStyle.Colors.bgInput,
        isAccent and UIStyle.Colors.borderHighlight or UIStyle.Colors.border
    )

    local ic = btn:CreateTexture(nil, "ARTWORK")
    local icSize = math.max(14, (size or 26) - 10)
    ic:SetSize(icSize, icSize)
    ic:SetPoint("CENTER", 0, 0)
    ic:SetTexture(iconPath)
    if isAccent then
        ic:SetVertexColor(1, 0.86, 0.42, 1)
    else
        ic:SetVertexColor(0.86, 0.88, 0.92, 1)
    end
    btn.icon = ic

    btn:SetScript("OnEnter", function(selfBtn)
        UIStyle:ApplyBox(selfBtn, UIStyle.Colors.bgRowHover, UIStyle.Colors.borderHighlight)
        selfBtn.icon:SetVertexColor(1, 0.92, 0.55, 1)
        if tooltipTitle and tooltipTitle ~= "" then
            GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
            GameTooltip:SetText(tooltipTitle, 0.95, 0.82, 0.35)
            GameTooltip:Show()
        end
    end)
    btn:SetScript("OnLeave", function(selfBtn)
        UIStyle:ApplyBox(
            selfBtn,
            isAccent and UIStyle.Colors.bgRowActive or UIStyle.Colors.bgInput,
            isAccent and UIStyle.Colors.borderHighlight or UIStyle.Colors.border
        )
        if isAccent then
            selfBtn.icon:SetVertexColor(1, 0.86, 0.42, 1)
        else
            selfBtn.icon:SetVertexColor(0.86, 0.88, 0.92, 1)
        end
        GameTooltip:Hide()
    end)
    if onClick then
        btn:SetScript("OnClick", onClick)
    end
    return btn
end

------------------------------------------------------------
-- Forward Declarations
------------------------------------------------------------
local RefreshPlayersList
local RefreshEditPopup

------------------------------------------------------------
-- Floating Player Edit Popup (GuildGreetPlayerEditPopup)
------------------------------------------------------------
local function EnsureEditPopup()
    if editPopup then return editPopup end

    local popup = CreateFrame("Frame", "GuildGreetPlayerEditPopup", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    popup:Hide()
    popup:SetSize(540, 410)
    popup:SetPoint("CENTER", UIParent, "CENTER", 0, 30)
    popup:SetFrameStrata("DIALOG")
    popup:SetFrameLevel(80)
    popup:SetToplevel(true)
    popup:SetClampedToScreen(true)
    popup:EnableMouse(true)
    popup:SetMovable(true)
    popup:RegisterForDrag("LeftButton")
    popup:SetScript("OnDragStart", function(f) f:StartMoving() end)
    popup:SetScript("OnDragStop", function(f) f:StopMovingOrSizing() end)
    popup:SetScript("OnHide", function()
        CloseDropdownMenu()
        editingPlayer = nil
        if playersPanel and playersPanel:IsShown() and RefreshPlayersList then
            RefreshPlayersList()
        end
    end)
    UIStyle:ApplyBox(popup, UIStyle.Colors.bgMain, UIStyle.Colors.borderHighlight)
    tinsert(UISpecialFrames, "GuildGreetPlayerEditPopup")

    -- Header Bar
    local header = CreateFrame("Frame", nil, popup, BackdropTemplateMixin and "BackdropTemplate" or nil)
    header:SetHeight(52)
    header:SetPoint("TOPLEFT", popup, "TOPLEFT", 1, -1)
    header:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -1, -1)
    UIStyle:ApplyBox(header, UIStyle.Colors.bgHeader, UIStyle.Colors.borderSubtle)
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function() popup:StartMoving() end)
    header:SetScript("OnDragStop", function() popup:StopMovingOrSizing() end)
    popup.header = header

    local classIcon = header:CreateTexture(nil, "ARTWORK")
    classIcon:SetSize(30, 30)
    classIcon:SetPoint("LEFT", header, "LEFT", 12, 0)
    popup.classIcon = classIcon

    local closeBtn = CreateFrame("Button", nil, header, BackdropTemplateMixin and "BackdropTemplate" or nil)
    closeBtn:SetSize(26, 26)
    closeBtn:SetPoint("RIGHT", header, "RIGHT", -10, 0)
    UIStyle:ApplyBox(closeBtn, UIStyle.Colors.bgRow, UIStyle.Colors.border)
    local closeIcon = closeBtn:CreateTexture(nil, "ARTWORK")
    closeIcon:SetSize(13, 13)
    closeIcon:SetPoint("CENTER", 0, 0)
    closeIcon:SetTexture("Interface\\Buttons\\UI-StopButton")
    closeIcon:SetVertexColor(0.92, 0.93, 0.95, 1)
    closeBtn:SetScript("OnEnter", function(selfBtn)
        UIStyle:ApplyBox(selfBtn, { 0.45, 0.14, 0.14, 0.95 }, UIStyle.Colors.red)
        closeIcon:SetVertexColor(1, 1, 1, 1)
    end)
    closeBtn:SetScript("OnLeave", function(selfBtn)
        UIStyle:ApplyBox(selfBtn, UIStyle.Colors.bgRow, UIStyle.Colors.border)
        closeIcon:SetVertexColor(0.92, 0.93, 0.95, 1)
    end)
    closeBtn:SetScript("OnClick", function() popup:Hide() end)

    local titleText = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("TOPLEFT", classIcon, "TOPRIGHT", 10, 1)
    titleText:SetPoint("RIGHT", closeBtn, "LEFT", -8, 0)
    titleText:SetJustifyH("LEFT")
    titleText:SetWordWrap(false)
    popup.titleText = titleText

    local subText = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    subText:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -3)
    subText:SetPoint("RIGHT", closeBtn, "LEFT", -8, 0)
    subText:SetJustifyH("LEFT")
    subText:SetWordWrap(false)
    subText:SetTextColor(unpack(UIStyle.Colors.textMuted))
    popup.subText = subText

    -- Read-Only Guild Info Card
    local infoBox = CreateFrame("Frame", nil, popup, BackdropTemplateMixin and "BackdropTemplate" or nil)
    infoBox:SetHeight(68)
    infoBox:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 12, -10)
    infoBox:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", -12, -10)
    UIStyle:ApplyBox(infoBox, UIStyle.Colors.bgPanel, UIStyle.Colors.borderSubtle)
    popup.infoBox = infoBox

    local infoText = infoBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    infoText:SetPoint("TOPLEFT", infoBox, "TOPLEFT", 12, -9)
    infoText:SetPoint("BOTTOMRIGHT", infoBox, "BOTTOMRIGHT", -12, 9)
    infoText:SetJustifyH("LEFT")
    infoText:SetJustifyV("MIDDLE")
    infoText:SetSpacing(4)
    popup.infoText = infoText

    -- Form Section: 1. First Name / Alias
    local aliasLbl = popup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    aliasLbl:SetPoint("TOPLEFT", infoBox, "BOTTOMLEFT", 2, -12)
    aliasLbl:SetTextColor(unpack(UIStyle.Colors.gold))
    aliasLbl:SetText(L["First Name / Alias"] or "Vorname / Alias")
    popup.aliasLbl = aliasLbl

    local aliasHint = popup:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    aliasHint:SetPoint("LEFT", aliasLbl, "RIGHT", 8, 0)
    aliasHint:SetTextColor(unpack(UIStyle.Colors.textMuted))
    aliasHint:SetText("(" .. (L["Synced across Main & all linked Alts"] or "Wird automatisch für Main & alle Twinks übernommen") .. ")")
    popup.aliasHint = aliasHint

    local aliasInput = CreateStyledEditBox(popup, 28, L["First Name / Alias"] or "Vorname / Alias")
    aliasInput:SetPoint("TOPLEFT", aliasLbl, "BOTTOMLEFT", -2, -5)
    aliasInput:SetPoint("TOPRIGHT", infoBox, "BOTTOMRIGHT", 0, -29)
    popup.aliasInput = aliasInput

    -- Form Section: 2. Assign as Alt of Main (left) + Custom Note (right)
    local mainDropLbl = popup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainDropLbl:SetPoint("TOPLEFT", aliasInput, "BOTTOMLEFT", 2, -12)
    mainDropLbl:SetTextColor(unpack(UIStyle.Colors.gold))
    mainDropLbl:SetText(L["Assign as Alt of Main"] or "Als Twink diesem Main zuweisen")
    popup.mainDropLbl = mainDropLbl

    local mainDropBtn = CreateDropdownButton(popup, 248, 28)
    mainDropBtn:SetPoint("TOPLEFT", mainDropLbl, "BOTTOMLEFT", -2, -5)
    popup.mainDropBtn = mainDropBtn

    local noteLbl = popup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    noteLbl:SetPoint("TOPLEFT", aliasInput, "BOTTOMLEFT", 264, -12)
    noteLbl:SetTextColor(unpack(UIStyle.Colors.gold))
    noteLbl:SetText(L["Custom Note"] or L["Note"] or "Eigene Notiz")
    popup.noteLbl = noteLbl

    local noteInput = CreateStyledEditBox(popup, 28, L["Custom Note"] or L["Note"] or "Eigene Notiz")
    noteInput:SetPoint("TOPLEFT", noteLbl, "BOTTOMLEFT", -2, -5)
    noteInput:SetPoint("RIGHT", infoBox, "RIGHT", 0, 0)
    popup.noteInput = noteInput

    -- Quick Action Buttons Bar (Main / Ignore / Greet / Remove)
    local actionBar = CreateFrame("Frame", nil, popup)
    actionBar:SetHeight(32)
    actionBar:SetPoint("TOPLEFT", mainDropBtn, "BOTTOMLEFT", 0, -14)
    actionBar:SetPoint("RIGHT", infoBox, "RIGHT", 0, 0)
    popup.actionBar = actionBar

    popup.mainRoleBtn = UIStyle:CreateButton(actionBar, L["Set as main"] or "Als Main setzen", 120, 26, nil, false)
    popup.ignoreBtn   = UIStyle:CreateButton(actionBar, L["Ignore"] or "Ignorieren", 105, 26, nil, false)
    popup.greetBtn    = UIStyle:CreateButton(actionBar, L["Greeting"] or "Begrüßung", 95, 26, nil, false)
    popup.removeBtn   = UIStyle:CreateButton(actionBar, L["Remove"] or "Entfernen", 95, 26, nil, false)

    -- Footer Bar (Save & Close)
    local footer = CreateFrame("Frame", nil, popup, BackdropTemplateMixin and "BackdropTemplate" or nil)
    footer:SetHeight(44)
    footer:SetPoint("BOTTOMLEFT", popup, "BOTTOMLEFT", 1, 1)
    footer:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -1, 1)
    UIStyle:ApplyBox(footer, UIStyle.Colors.bgHeader, UIStyle.Colors.borderSubtle)
    popup.footer = footer

    local cancelBtn = UIStyle:CreateButton(footer, L["Close"] or CLOSE or "Schließen", 100, 28, function()
        popup:Hide()
    end, false)
    cancelBtn:SetPoint("RIGHT", footer, "RIGHT", -12, 0)
    popup.cancelBtn = cancelBtn

    local saveBtn = UIStyle:CreateButton(footer, L["Save"] or SAVE or "Speichern", 120, 28, nil, true)
    saveBtn:SetPoint("RIGHT", cancelBtn, "LEFT", -8, 0)
    popup.saveBtn = saveBtn

    local function CommitPopupEdits(closeAfter)
        if not editingPlayer or not GLDG_DataChar or not GLDG_DataChar[editingPlayer] then
            if closeAfter then popup:Hide() end
            return
        end
        local p = GLDG_DataChar[editingPlayer]

        -- 1. Save Main assignment if modified via dropdown
        local pendingMain = popup._selectedMainValue
        if not p.main and pendingMain ~= nil then
            if pendingMain == "__NONE__" then
                p.alt = nil
            elseif pendingMain ~= editingPlayer then
                p.main = nil
                p.alt = pendingMain
                if GLDG_DataChar[pendingMain] then
                    p.ignore = GLDG_DataChar[pendingMain].ignore
                end
            end
        end

        -- 2. Save First Name / Alias across Main + all linked Alts
        local aliasVal = strtrim(aliasInput:GetText() or "")
        local newAlias = (aliasVal ~= "") and aliasVal or nil
        local isManual = (aliasVal ~= "") and true or nil
        if GLDG.PlayerManager and GLDG.PlayerManager.SyncFamilyAlias then
            GLDG.PlayerManager:SyncFamilyAlias(editingPlayer, newAlias, isManual)
        else
            p.alias = newAlias
            p.manualAlias = isManual
        end

        -- If newly assigned to a Main that already had a manualAlias and input was left empty, inherit Main's alias
        if not newAlias and p.alt and GLDG_DataChar[p.alt] then
            local mainObj = GLDG_DataChar[p.alt]
            if mainObj.manualAlias and mainObj.alias and mainObj.alias ~= "" then
                p.alias = mainObj.alias
                p.manualAlias = true
            end
        end

        -- 3. Save Custom Note
        local noteVal = strtrim(noteInput:GetText() or "")
        p.note = (noteVal ~= "") and noteVal or nil

        if GLDG.ShowQueue then GLDG:ShowQueue() end
        if closeAfter then
            popup:Hide()
        else
            RefreshEditPopup()
            if RefreshPlayersList then RefreshPlayersList() end
        end
    end

    saveBtn:SetScript("OnClick", function()
        CommitPopupEdits(true)
    end)
    aliasInput:SetScript("OnEnterPressed", function(selfBox)
        selfBox:ClearFocus()
        CommitPopupEdits(true)
    end)
    noteInput:SetScript("OnEnterPressed", function(selfBox)
        selfBox:ClearFocus()
        CommitPopupEdits(true)
    end)

    editPopup = popup
    return popup
end

RefreshEditPopup = function()
    if not editPopup or not editingPlayer or not GLDG_DataChar or not GLDG_DataChar[editingPlayer] then
        if editPopup then editPopup:Hide() end
        return
    end

    local p = GLDG_DataChar[editingPlayer]
    local fontSize = UIStyle:GetFontSize()
    local popupW = math.max(540, 500 + math.max(0, fontSize - 12) * 26)
    local popupH = math.max(395, 375 + math.max(0, fontSize - 12) * 18)
    editPopup:SetSize(popupW, popupH)

    ApplyClassIcon(editPopup.classIcon, p.enClass)
    UIStyle:ApplyFont(editPopup.titleText, 3)
    UIStyle:ApplyFont(editPopup.subText, -1)
    UIStyle:ApplyFont(editPopup.infoText, 0)
    UIStyle:ApplyFont(editPopup.aliasLbl, 0)
    UIStyle:ApplyFont(editPopup.aliasHint, -2)
    UIStyle:ApplyFont(editPopup.mainDropLbl, 0)
    UIStyle:ApplyFont(editPopup.noteLbl, 0)
    UIStyle:ApplyFont(editPopup.aliasInput, 0)
    UIStyle:ApplyFont(editPopup.noteInput, 0)
    UIStyle:ApplyFont(editPopup.mainDropBtn.label, 0)

    local cHex = GetClassHex(p.enClass)
    local shortName = Ambiguate(editingPlayer)
    editPopup.titleText:SetText(cHex .. shortName .. "|r")

    local dispClass = p.classDisplayName or p.class or ""
    local cleanGuild = CleanGuildName(p.guild)
    local rankStr = (p.rankname and p.rankname ~= "") and p.rankname or "---"
    editPopup.subText:SetText(string.format(
        "%s %s %s  •  %s%s",
        L["Level"] or "Stufe",
        tostring(p.lvl or "?"),
        dispClass,
        rankStr,
        cleanGuild ~= "" and ("  •  " .. cleanGuild) or ""
    ))

    local mainDisplay = (p.alt and p.alt ~= "" and Ambiguate(p.alt)) or p.twinkMainName
    local roleTag = p.ignore and (UIStyle.Hex.red .. (L["Ignored"] or "Ignoriert") .. "|r")
        or p.main and (UIStyle.Hex.green .. string.format(L["MAIN (%d Alts)"] or "MAIN (%d Twinks)", CountAltsOf(editingPlayer)) .. "|r")
        or (mainDisplay and mainDisplay ~= "") and (UIStyle.Hex.cyan .. string.format(L["ALT of %s"] or "Twink von %s", mainDisplay) .. "|r")
        or (UIStyle.Hex.textMuted .. (L["Not assigned"] or "Nicht zugewiesen") .. "|r")

    local pubNote = (p.pNote and strtrim(p.pNote) ~= "") and (UIStyle.Hex.textLight .. strtrim(p.pNote) .. "|r") or (UIStyle.Hex.textMuted .. "—|r")
    local offNote = (p.oNote and strtrim(p.oNote) ~= "") and (UIStyle.Hex.textLight .. strtrim(p.oNote) .. "|r") or (UIStyle.Hex.textMuted .. "—|r")

    editPopup.infoText:SetText(string.format(
        "%s%s:|r %s\n%s%s:|r %s      %s%s:|r %s",
        UIStyle.Hex.gold, L["Status"] or "Status", roleTag,
        UIStyle.Hex.goldDim, L["Public Note"] or "Öffentliche Notiz", pubNote,
        UIStyle.Hex.goldDim, L["Officer Note"] or "Offiziersnotiz", offNote
    ))

    -- Populate inputs
    local currentAlias = GetEffectiveAlias(p) or ""
    editPopup.aliasInput:SetText(currentAlias)
    editPopup.aliasInput._syncPlaceholder()

    editPopup.noteInput:SetText(p.note or "")
    editPopup.noteInput._syncPlaceholder()

    -- Main Assignment Dropdown
    local halfW = math.floor((popupW - 38) * 0.50)
    editPopup.mainDropBtn:SetWidth(halfW)
    editPopup.noteLbl:ClearAllPoints()
    editPopup.noteLbl:SetPoint("TOPLEFT", editPopup.aliasInput, "BOTTOMLEFT", halfW + 14, -12)

    local mainItems = GetMainsDropdownItems(editingPlayer)
    local curMainVal = p.alt or "__NONE__"
    editPopup._selectedMainValue = curMainVal

    local selectedMainLabel = mainItems[1].label
    for _, item in ipairs(mainItems) do
        if item.value == curMainVal then
            selectedMainLabel = item.label
            break
        end
    end
    if p.main then
        editPopup.mainDropBtn.label:SetText(UIStyle.Hex.green .. (L["Main"] or "Ist Hauptcharakter (Main)") .. "|r")
        editPopup.mainDropBtn:SetDisabledState(true)
    else
        editPopup.mainDropBtn.label:SetText(selectedMainLabel)
        editPopup.mainDropBtn:SetDisabledState(false)
    end

    editPopup.mainDropBtn:SetScript("OnClick", function(selfBtn)
        local items = GetMainsDropdownItems(editingPlayer)
        OpenDropdownMenu(selfBtn, items, editPopup._selectedMainValue or "__NONE__", function(val, lbl)
            editPopup._selectedMainValue = val
            selfBtn.label:SetText(lbl)
        end)
    end)

    -- Action Buttons (Main / Ignore / Greet / Remove)
    local mainBtn = editPopup.mainRoleBtn
    if p.alt then
        mainBtn:SetText(L["Promote to main"] or "Zum Main befördern")
        mainBtn:Enable()
        mainBtn:SetAlpha(1.0)
    elseif p.main then
        mainBtn:SetText(L["Unset as main"] or "Main-Status aufheben")
        if CountAltsOf(editingPlayer) > 0 then
            mainBtn:Disable()
            mainBtn:SetAlpha(0.45)
        else
            mainBtn:Enable()
            mainBtn:SetAlpha(1.0)
        end
    else
        mainBtn:SetText(L["Set as main"] or "Als Main setzen")
        mainBtn:Enable()
        mainBtn:SetAlpha(1.0)
    end
    mainBtn:SetScript("OnClick", function()
        -- Preserve unsaved text before toggling Main state
        local typedAlias = strtrim(editPopup.aliasInput:GetText() or "")
        if typedAlias ~= "" then
            if GLDG.PlayerManager and GLDG.PlayerManager.SyncFamilyAlias then
                GLDG.PlayerManager:SyncFamilyAlias(editingPlayer, typedAlias, true)
            else
                p.alias = typedAlias
                p.manualAlias = true
            end
        end
        local typedNote = strtrim(editPopup.noteInput:GetText() or "")
        p.note = (typedNote ~= "") and typedNote or nil

        GLDG_SelPlrName = editingPlayer
        if p.alt then
            local oldMain = p.alt
            p.alt = nil
            p.main = true
            if GLDG_DataChar[oldMain] then
                GLDG_DataChar[oldMain].main = nil
                GLDG_DataChar[oldMain].alt = editingPlayer
            end
            for _, charData in pairs(GLDG_DataChar) do
                if type(charData) == "table" and charData.alt == oldMain then
                    charData.alt = editingPlayer
                end
            end
        elseif p.main then
            if CountAltsOf(editingPlayer) == 0 then
                p.main = nil
            end
        else
            p.main = true
        end
        if GLDG.ShowQueue then GLDG:ShowQueue() end
        RefreshEditPopup()
        if RefreshPlayersList then RefreshPlayersList() end
    end)

    local ignoreBtn = editPopup.ignoreBtn
    ignoreBtn:SetText(p.ignore and (L["Unignore"] or "Nicht mehr ignorieren") or (L["Ignore"] or "Ignorieren"))
    ignoreBtn:SetScript("OnClick", function()
        p.ignore = not p.ignore and true or nil
        if p.main then
            for _, altData in pairs(GLDG_DataChar) do
                if type(altData) == "table" and altData.alt == editingPlayer then
                    altData.ignore = p.ignore
                end
            end
        end
        RefreshEditPopup()
        if RefreshPlayersList then RefreshPlayersList() end
    end)

    local greetBtn = editPopup.greetBtn
    greetBtn:SetText(L["Greeting"] or "Begrüßung")
    greetBtn:SetScript("OnClick", function()
        GLDG_SendGreet(editingPlayer)
    end)

    local removeBtn = editPopup.removeBtn
    removeBtn:SetText(L["Remove"] or "Entfernen")
    if p.main == true or p.alt ~= nil then
        removeBtn:Disable()
        removeBtn:SetAlpha(0.45)
    else
        removeBtn:Enable()
        removeBtn:SetAlpha(1.0)
    end
    removeBtn:SetScript("OnClick", function()
        local removed = editingPlayer
        GLDG_DataChar[removed] = nil
        editingPlayer = nil
        editPopup:Hide()
        GLDG:PrintInfo((L["Remove"] or "Removed") .. ": " .. Ambiguate(removed))
        if RefreshPlayersList then RefreshPlayersList() end
    end)

    -- Flow-layout the 4 action buttons cleanly
    local flowBtns = { mainBtn, ignoreBtn, greetBtn, removeBtn }
    local prev = nil
    for _, b in ipairs(flowBtns) do
        b:UpdateSize()
        b:ClearAllPoints()
        if not prev then
            b:SetPoint("LEFT", editPopup.actionBar, "LEFT", 0, 0)
        else
            b:SetPoint("LEFT", prev, "RIGHT", 6, 0)
        end
        prev = b
    end

    editPopup.saveBtn:UpdateSize()
    editPopup.cancelBtn:UpdateSize()
end

function GLDG:OpenPlayerEditPopup(playerName)
    if not playerName or not GLDG_DataChar or not GLDG_DataChar[playerName] then return end
    CloseDropdownMenu()
    editingPlayer = playerName
    GLDG_SelPlrName = playerName
    local popup = EnsureEditPopup()
    RefreshEditPopup()
    popup:Show()
    popup:Raise()
    if RefreshPlayersList then
        RefreshPlayersList()
    end
end

function GLDG:HidePlayerEditPopup()
    CloseDropdownMenu()
    if editPopup and editPopup:IsShown() then
        editPopup:Hide()
    end
end

------------------------------------------------------------
-- Structured Multi-Column Players Tab Panel
------------------------------------------------------------
local function CreatePlayerRow(parent, idx)
    local row = CreateFrame("Button", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    row:SetHeight(32)

    local accent = row:CreateTexture(nil, "OVERLAY")
    accent:SetWidth(3)
    accent:SetPoint("TOPLEFT", row, "TOPLEFT", 1, -1)
    accent:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 1, 1)
    accent:Hide()
    row.accent = accent

    local statusIcon = row:CreateTexture(nil, "ARTWORK")
    statusIcon:SetSize(13, 13)
    statusIcon:SetPoint("LEFT", row, "LEFT", 8, 0)
    row.statusIcon = statusIcon

    local classIcon = row:CreateTexture(nil, "ARTWORK")
    classIcon:SetSize(16, 16)
    classIcon:SetPoint("LEFT", statusIcon, "RIGHT", 5, 0)
    row.classIcon = classIcon

    local colName = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    colName:SetJustifyH("LEFT")
    colName:SetWordWrap(false)
    row.colName = colName

    local colAlias = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    colAlias:SetJustifyH("LEFT")
    colAlias:SetWordWrap(false)
    row.colAlias = colAlias

    local colRole = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    colRole:SetJustifyH("LEFT")
    colRole:SetWordWrap(false)
    row.colRole = colRole

    local colLvlRank = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    colLvlRank:SetJustifyH("LEFT")
    colLvlRank:SetWordWrap(false)
    row.colLvlRank = colLvlRank

    local colNote = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    colNote:SetJustifyH("LEFT")
    colNote:SetWordWrap(false)
    row.colNote = colNote

    -- Compact Edit Icon Button (Right-most)
    local editBtn = CreateIconButton(
        row,
        "Interface\\Buttons\\UI-OptionsButton",
        24,
        L["Edit player"] or "Spieler bearbeiten",
        function()
            if row._playerKey then
                GLDG:OpenPlayerEditPopup(row._playerKey)
            end
        end,
        true
    )
    editBtn:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    row.editBtn = editBtn

    -- Compact Quick-Greet Icon Button
    local greetBtn = CreateIconButton(
        row,
        "Interface\\GossipFrame\\ChatBubbleGossipIcon",
        24,
        L["Greet player now"] or "Spieler jetzt begrüßen",
        function()
            if row._playerKey then
                GLDG_SendGreet(row._playerKey)
            end
        end,
        false
    )
    greetBtn:SetPoint("RIGHT", editBtn, "LEFT", -4, 0)
    row.greetBtn = greetBtn

    row._idx = idx
    row:SetScript("OnEnter", function(selfRow)
        UIStyle:ApplyBox(selfRow, UIStyle.Colors.bgRowHover, UIStyle.Colors.borderHighlight)
        local key = selfRow._playerKey
        local p = key and GLDG_DataChar and GLDG_DataChar[key]
        if p then
            GameTooltip:SetOwner(selfRow, "ANCHOR_RIGHT")
            local cHex = GetClassHex(p.enClass)
            GameTooltip:SetText(cHex .. Ambiguate(key) .. "|r")
            local alias = GetEffectiveAlias(p)
            if alias then
                GameTooltip:AddDoubleLine(L["First Name"] or "Vorname", alias, 0.85, 0.71, 0.29, 1, 0.92, 0.55)
            end
            local mainDisp = (p.alt and p.alt ~= "" and Ambiguate(p.alt)) or p.twinkMainName
            if p.main then
                GameTooltip:AddDoubleLine(L["Status"] or "Status", string.format(L["MAIN (%d Alts)"] or "MAIN (%d Twinks)", CountAltsOf(key)), 0.85, 0.71, 0.29, 0.30, 0.85, 0.45)
            elseif mainDisp and mainDisp ~= "" then
                GameTooltip:AddDoubleLine(L["Status"] or "Status", string.format(L["ALT of %s"] or "Twink von %s", mainDisp), 0.85, 0.71, 0.29, 0.36, 0.75, 0.75)
            end
            local dispClass = p.classDisplayName or p.class or ""
            GameTooltip:AddDoubleLine(L["Level"] or "Stufe", tostring(p.lvl or "?") .. " " .. dispClass, 0.7, 0.72, 0.78, 1, 1, 1)
            if p.rankname and p.rankname ~= "" then
                GameTooltip:AddDoubleLine(L["Rank"] or "Rang", p.rankname, 0.7, 0.72, 0.78, 1, 1, 1)
            end
            if p.pNote and strtrim(p.pNote) ~= "" then
                GameTooltip:AddDoubleLine(L["Public Note"] or "Öffentliche Notiz", strtrim(p.pNote), 0.7, 0.72, 0.78, 0.9, 0.9, 0.9)
            end
            if p.oNote and strtrim(p.oNote) ~= "" then
                GameTooltip:AddDoubleLine(L["Officer Note"] or "Offiziersnotiz", strtrim(p.oNote), 0.7, 0.72, 0.78, 0.9, 0.9, 0.9)
            end
            if p.note and strtrim(p.note) ~= "" then
                GameTooltip:AddDoubleLine(L["Custom Note"] or "Eigene Notiz", strtrim(p.note), 0.85, 0.71, 0.29, 0.95, 0.9, 0.75)
            end
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("|cff4cd973" .. (L["Left-Click"] or "Linksklick") .. ":|r " .. (L["Edit player"] or "Spieler bearbeiten"), 0.85, 0.85, 0.85)
            GameTooltip:Show()
        end
    end)
    row:SetScript("OnLeave", function(selfRow)
        GameTooltip:Hide()
        if editingPlayer == selfRow._playerKey then
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
        if selfRow._playerKey then
            GLDG:OpenPlayerEditPopup(selfRow._playerKey)
        end
    end)

    return row
end

local function ComputeColumnLayout(totalWidth)
    local actionW = 64
    local usable = math.max(360, totalWidth - actionW - 14)
    local wName    = math.floor(usable * 0.25)
    local wAlias   = math.floor(usable * 0.14)
    local wRole    = math.floor(usable * 0.22)
    local wLvlRank = math.floor(usable * 0.19)
    local wNote    = math.max(60, usable - wName - wAlias - wRole - wLvlRank)

    local xName    = 6
    local xAlias   = xName + wName + 6
    local xRole    = xAlias + wAlias + 6
    local xLvlRank = xRole + wRole + 6
    local xNote    = xLvlRank + wLvlRank + 6

    return {
        xName = xName, wName = wName,
        xAlias = xAlias, wAlias = wAlias,
        xRole = xRole, wRole = wRole,
        xLvlRank = xLvlRank, wLvlRank = wLvlRank,
        xNote = xNote, wNote = wNote,
        actionW = actionW,
    }
end

RefreshPlayersList = function()
    if not playersPanel or not playersPanel:IsShown() then return end

    local fontSize = UIStyle:GetFontSize()
    local panelW = playersPanel:GetWidth()
    if not panelW or panelW < 200 then
        panelW = 820
    end

    -- Update Toolbar Fonts & Sizes
    UIStyle:ApplyFont(playersPanel.searchBox, 0)
    if playersPanel.searchBox.placeholder then
        UIStyle:ApplyFont(playersPanel.searchBox.placeholder, 0)
    end
    UIStyle:ApplyFont(playersPanel.filterDropBtn.label, 0)
    UIStyle:ApplyFont(playersPanel.countText, 0)

    local filterItems = GetRoleFilterItems()
    for _, item in ipairs(filterItems) do
        if item.value == roleFilter then
            playersPanel.filterDropBtn.label:SetText(item.label)
            break
        end
    end

    local toolBtns = { playersPanel.refreshBtn, playersPanel.checkBtn, playersPanel.fixBtn }
    local prevBtn = nil
    for _, b in ipairs(toolBtns) do
        b:UpdateSize()
        b:ClearAllPoints()
        if not prevBtn then
            b:SetPoint("BOTTOMLEFT", playersPanel.toolbar, "BOTTOMLEFT", 10, 8)
        else
            b:SetPoint("LEFT", prevBtn, "RIGHT", 8, 0)
        end
        prevBtn = b
    end

    local toolbarH = math.max(76, fontSize * 2 + 54)
    playersPanel.toolbar:SetHeight(toolbarH)

    -- Compute responsive table columns
    local scrollW = math.max(400, panelW - 28)
    local cols = ComputeColumnLayout(scrollW)

    -- Position Column Headers
    local hdr = playersPanel.colHeader
    local hdrH = math.max(26, fontSize + 13)
    hdr:SetHeight(hdrH)

    local function placeHdr(fs, x, w)
        UIStyle:ApplyFont(fs, -1)
        fs:ClearAllPoints()
        fs:SetPoint("LEFT", hdr, "LEFT", x, 0)
        fs:SetWidth(w)
    end
    placeHdr(hdr.hName, cols.xName, cols.wName)
    placeHdr(hdr.hAlias, cols.xAlias, cols.wAlias)
    placeHdr(hdr.hRole, cols.xRole, cols.wRole)
    placeHdr(hdr.hLvlRank, cols.xLvlRank, cols.wLvlRank)
    placeHdr(hdr.hNote, cols.xNote, cols.wNote)
    UIStyle:ApplyFont(hdr.hActions, -1)

    -- Filter & Sort Players
    local filtered, totalInGuild = GetFilteredPlayers()
    local shownCount = #filtered
    playersPanel.countText:SetText(string.format(
        UIStyle.Hex.gold .. (L["%d of %d players"] or "%d von %d Spielern") .. "|r",
        shownCount,
        totalInGuild
    ))

    local rowH = math.max(30, fontSize + 17)
    local rowStep = rowH + 2
    local iconBtnSize = math.max(22, math.min(28, rowH - 6))

    playersPanel.scrollChild:SetSize(scrollW, math.max(shownCount * rowStep + 4, 40))

    if shownCount == 0 then
        playersPanel.emptyText:Show()
        UIStyle:ApplyFont(playersPanel.emptyText, 0)
        local activeG = GetActiveGuildName()
        playersPanel.emptyText:SetText(
            (activeG == "")
                and (L["You are currently not in a guild."] or "Du bist aktuell in keiner Gilde.")
                or (L["No characters match the current filters."] or "Keine Charaktere entsprechen dem aktuellen Filter.")
        )
    else
        playersPanel.emptyText:Hide()
    end

    for i = 1, shownCount do
        local key = filtered[i]
        local p = GLDG_DataChar[key]
        local row = rowPool[i]
        if not row then
            row = CreatePlayerRow(playersPanel.scrollChild, i)
            rowPool[i] = row
        end

        row._idx = i
        row._playerKey = key
        row:SetSize(scrollW, rowH)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", playersPanel.scrollChild, "TOPLEFT", 0, -(i - 1) * rowStep)

        local isEditing = (editingPlayer == key)
        if isEditing then
            UIStyle:ApplyBox(row, UIStyle.Colors.bgRowActive, UIStyle.Colors.borderHighlight)
            row.accent:SetColorTexture(unpack(UIStyle.Colors.gold))
            row.accent:Show()
        else
            UIStyle:ApplyBox(row, (i % 2 == 0) and UIStyle.Colors.bgRowAlt or UIStyle.Colors.bgRow, UIStyle.Colors.borderSubtle)
            if p and p.main then
                row.accent:SetColorTexture(0.30, 0.85, 0.45, 0.85)
                row.accent:Show()
            elseif p and (p.alt or p.twinkMainName) then
                row.accent:SetColorTexture(0.36, 0.75, 0.75, 0.85)
                row.accent:Show()
            else
                row.accent:Hide()
            end
        end

        local isOnline = GLDG_Online and GLDG_Online[key] ~= nil
        row.statusIcon:SetTexture(
            isOnline
                and "Interface\\FriendsFrame\\StatusIcon-Online"
                or "Interface\\FriendsFrame\\StatusIcon-Offline"
        )
        ApplyClassIcon(row.classIcon, p and p.enClass)

        -- Col 1: Character Name (after status dot + class icon = 44px offset)
        UIStyle:ApplyFont(row.colName, 0)
        row.colName:ClearAllPoints()
        row.colName:SetPoint("LEFT", row, "LEFT", 44, 0)
        row.colName:SetWidth(math.max(50, cols.wName - 38))
        local cHex = GetClassHex(p and p.enClass)
        row.colName:SetText(cHex .. Ambiguate(key) .. "|r")

        -- Col 2: First Name / Alias
        UIStyle:ApplyFont(row.colAlias, 0)
        row.colAlias:ClearAllPoints()
        row.colAlias:SetPoint("LEFT", row, "LEFT", cols.xAlias, 0)
        row.colAlias:SetWidth(cols.wAlias)
        local effAlias = GetEffectiveAlias(p)
        if effAlias and effAlias ~= "" then
            row.colAlias:SetText(UIStyle.Hex.gold .. effAlias .. "|r")
        else
            row.colAlias:SetText(UIStyle.Hex.textMuted .. "—|r")
        end

        -- Col 3: Role / Main
        UIStyle:ApplyFont(row.colRole, -1)
        row.colRole:ClearAllPoints()
        row.colRole:SetPoint("LEFT", row, "LEFT", cols.xRole, 0)
        row.colRole:SetWidth(cols.wRole)
        local mainDisp = p and ((p.alt and p.alt ~= "" and Ambiguate(p.alt)) or p.twinkMainName) or nil
        if p and p.ignore then
            row.colRole:SetText(UIStyle.Hex.red .. (L["Ignored"] or "Ignoriert") .. "|r")
        elseif p and p.main then
            local altCnt = CountAltsOf(key)
            if altCnt > 0 then
                row.colRole:SetText(UIStyle.Hex.green .. string.format("Main (%d)", altCnt) .. "|r")
            else
                row.colRole:SetText(UIStyle.Hex.green .. "Main|r")
            end
        elseif mainDisp and mainDisp ~= "" then
            row.colRole:SetText(UIStyle.Hex.cyan .. (L["Alt"] or "Twink") .. " -> " .. mainDisp .. "|r")
        else
            row.colRole:SetText(UIStyle.Hex.textMuted .. "—|r")
        end

        -- Col 4: Level & Rank
        UIStyle:ApplyFont(row.colLvlRank, -1)
        row.colLvlRank:ClearAllPoints()
        row.colLvlRank:SetPoint("LEFT", row, "LEFT", cols.xLvlRank, 0)
        row.colLvlRank:SetWidth(cols.wLvlRank)
        local rankStr = (p and p.rankname and p.rankname ~= "") and p.rankname or "—"
        row.colLvlRank:SetText(string.format(
            "%sLv%s|r %s• %s|r",
            UIStyle.Hex.textLight,
            tostring(p and p.lvl or "?"),
            UIStyle.Hex.textMuted,
            rankStr
        ))

        -- Col 5: Public Note (single-line truncated, never wraps)
        UIStyle:ApplyFont(row.colNote, -1)
        row.colNote:ClearAllPoints()
        row.colNote:SetPoint("LEFT", row, "LEFT", cols.xNote, 0)
        row.colNote:SetWidth(cols.wNote)
        local pubNote = (p and p.pNote and strtrim(p.pNote) ~= "") and strtrim(p.pNote) or ""
        if pubNote ~= "" then
            row.colNote:SetText("|cff848a9c" .. pubNote .. "|r")
        else
            row.colNote:SetText(UIStyle.Hex.textMuted .. "—|r")
        end

        -- Col 6: Compact Action Icon Buttons
        row.editBtn:SetSize(iconBtnSize, iconBtnSize)
        row.editBtn.icon:SetSize(iconBtnSize - 9, iconBtnSize - 9)
        row.greetBtn:SetSize(iconBtnSize, iconBtnSize)
        row.greetBtn.icon:SetSize(iconBtnSize - 9, iconBtnSize - 9)

        row:Show()
    end

    for i = shownCount + 1, #rowPool do
        rowPool[i]:Hide()
    end

    if editPopup and editPopup:IsShown() then
        RefreshEditPopup()
    end
    if GLDG.RefreshSidebarStats then
        GLDG:RefreshSidebarStats()
    end
end

local function EnsurePlayersPanel(hostFrame)
    if playersPanel then
        playersPanel:SetParent(hostFrame)
        playersPanel:ClearAllPoints()
        playersPanel:SetAllPoints(hostFrame)
        return playersPanel
    end

    local panel = CreateFrame("Frame", nil, hostFrame)
    panel:SetAllPoints(hostFrame)

    -- 1. Top Filter & Roster Tools Card
    local toolbar = CreateFrame("Frame", nil, panel, BackdropTemplateMixin and "BackdropTemplate" or nil)
    toolbar:SetHeight(80)
    toolbar:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
    toolbar:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, 0)
    UIStyle:ApplyBox(toolbar, UIStyle.Colors.bgPanel, UIStyle.Colors.borderSubtle)
    panel.toolbar = toolbar

    -- Search Box with magnifying glass icon
    local searchBox = CreateStyledEditBox(toolbar, 28, L["Search: Name, First Name, Main, Note..."] or "Suche: Name, Vorname, Main, Notiz...")
    searchBox:SetPoint("TOPLEFT", toolbar, "TOPLEFT", 10, -10)
    searchBox:SetWidth(330)
    searchBox:SetTextInsets(26, 24, 0, 0)
    local searchIcon = searchBox:CreateTexture(nil, "ARTWORK")
    searchIcon:SetSize(14, 14)
    searchIcon:SetPoint("LEFT", searchBox, "LEFT", 8, -1)
    searchIcon:SetTexture("Interface\\Common\\UI-Searchbox-Icon")
    searchIcon:SetVertexColor(0.7, 0.72, 0.78, 0.9)
    if searchBox.placeholder then
        searchBox.placeholder:ClearAllPoints()
        searchBox.placeholder:SetPoint("LEFT", searchBox, "LEFT", 26, 0)
        searchBox.placeholder:SetPoint("RIGHT", searchBox, "RIGHT", -24, 0)
    end
    searchBox:SetText(searchFilter)
    searchBox._syncPlaceholder()
    searchBox:HookScript("OnTextChanged", function(selfBox, userInput)
        if userInput then
            searchFilter = selfBox:GetText() or ""
            RefreshPlayersList()
        end
    end)
    searchBox._onClear = function()
        searchFilter = ""
        RefreshPlayersList()
    end
    searchBox:SetScript("OnEnterPressed", function(selfBox)
        selfBox:ClearFocus()
    end)
    panel.searchBox = searchBox

    -- Role Filter Dropdown
    local filterDropBtn = CreateDropdownButton(toolbar, 200, 28)
    filterDropBtn:SetPoint("LEFT", searchBox, "RIGHT", 10, 0)
    filterDropBtn:SetScript("OnClick", function(selfBtn)
        OpenDropdownMenu(selfBtn, GetRoleFilterItems(), roleFilter, function(val, lbl)
            roleFilter = val or "all"
            selfBtn.label:SetText(lbl)
            RefreshPlayersList()
        end)
    end)
    panel.filterDropBtn = filterDropBtn

    -- Filtered Count Badge (top right of toolbar)
    local countText = toolbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    countText:SetPoint("RIGHT", toolbar, "RIGHT", -14, 0)
    countText:SetPoint("TOP", searchBox, "TOP", 0, 0)
    countText:SetPoint("BOTTOM", searchBox, "BOTTOM", 0, 0)
    countText:SetJustifyH("RIGHT")
    panel.countText = countText

    -- Roster Action Buttons (bottom row of toolbar)
    panel.refreshBtn = UIStyle:CreateButton(toolbar, L["Rescan Guild Roster"] or L["Refresh"] or "Aktualisieren", 150, 25, function()
        GLDG_ReadNotes = 1
        if GLDG.PlayerManager and GLDG.PlayerManager.RosterImport then
            GLDG.PlayerManager:RosterImport(false)
        else
            GLDG_RosterImport()
        end
        RefreshPlayersList()
    end, false)

    panel.checkBtn = UIStyle:CreateButton(toolbar, L["Check consistency"] or "Konsistenz prüfen", 150, 25, function()
        GLDG_Convert_Plausibility_Check(false)
    end, false)

    panel.fixBtn = UIStyle:CreateButton(toolbar, L["Fix inconsistencies"] or "Inkonsistenzen automatisch beheben", 190, 25, function()
        GLDG_fixCount = 0
        GLDG_Convert_Plausibility_Fix(false)
        RefreshPlayersList()
    end, false)

    -- 2. Column Header Bar
    local colHeader = CreateFrame("Frame", nil, panel, BackdropTemplateMixin and "BackdropTemplate" or nil)
    colHeader:SetHeight(28)
    colHeader:SetPoint("TOPLEFT", toolbar, "BOTTOMLEFT", 0, -6)
    colHeader:SetPoint("TOPRIGHT", toolbar, "BOTTOMRIGHT", 0, -6)
    UIStyle:ApplyBox(colHeader, UIStyle.Colors.bgHeader, UIStyle.Colors.borderSubtle)
    panel.colHeader = colHeader

    local function makeHdrLabel(text, justify)
        local fs = colHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetJustifyH(justify or "LEFT")
        fs:SetWordWrap(false)
        fs:SetTextColor(unpack(UIStyle.Colors.gold))
        fs:SetText(text)
        return fs
    end

    colHeader.hName    = makeHdrLabel(L["Character"] or "Charakter")
    colHeader.hAlias   = makeHdrLabel(L["First Name"] or "Vorname")
    colHeader.hRole    = makeHdrLabel(L["Role / Main"] or "Rolle / Main")
    colHeader.hLvlRank = makeHdrLabel(L["Level & Rank"] or "Stufe & Rang")
    colHeader.hNote    = makeHdrLabel(L["Public Note"] or "Öffentliche Notiz")
    colHeader.hActions = makeHdrLabel(L["Actions"] or "Aktion", "RIGHT")
    colHeader.hActions:SetPoint("RIGHT", colHeader, "RIGHT", -30, 0)
    colHeader.hActions:SetWidth(64)

    -- 3. Scrollable Roster Table Body
    local tableBox = CreateFrame("Frame", nil, panel, BackdropTemplateMixin and "BackdropTemplate" or nil)
    tableBox:SetPoint("TOPLEFT", colHeader, "BOTTOMLEFT", 0, -2)
    tableBox:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)
    UIStyle:ApplyBox(tableBox, UIStyle.Colors.bgPanel, UIStyle.Colors.borderSubtle)
    panel.tableBox = tableBox

    local scrollFrame = CreateFrame("ScrollFrame", nil, tableBox, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", tableBox, "TOPLEFT", 4, -4)
    scrollFrame:SetPoint("BOTTOMRIGHT", tableBox, "BOTTOMRIGHT", -24, 4)
    panel.scrollFrame = scrollFrame

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(780, 100)
    scrollFrame:SetScrollChild(scrollChild)
    panel.scrollChild = scrollChild

    local emptyText = tableBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    emptyText:SetPoint("CENTER", tableBox, "CENTER", -10, 0)
    emptyText:SetTextColor(unpack(UIStyle.Colors.textMuted))
    emptyText:Hide()
    panel.emptyText = emptyText

    panel:SetScript("OnSizeChanged", function()
        if panel:IsShown() then
            RefreshPlayersList()
        end
    end)

    playersPanel = panel
    return panel
end

function GLDG:ShowPlayersTabPanel(hostFrame)
    if self.SyncDatabaseReferences then
        self:SyncDatabaseReferences()
    end
    if self.PlayerManager and self.PlayerManager.RosterImport then
        self.PlayerManager:RosterImport(true)
    end
    local panel = EnsurePlayersPanel(hostFrame)
    panel:Show()
    RefreshPlayersList()
end

function GLDG:HidePlayersTabPanel()
    CloseDropdownMenu()
    if playersPanel then
        playersPanel:Hide()
    end
end

-- Legacy compatibility entry point
function GLDG:CreatePlayersTab(container)
    if container and container.frame then
        self:ShowPlayersTabPanel(container.frame)
    end
end
