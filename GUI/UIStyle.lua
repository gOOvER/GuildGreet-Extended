------------------------------------------------------------
-- GuildGreet Modern UI Style System (Dark-Slate & Gold)
-- Shared design tokens, dynamic font scaling, auto-fitting buttons,
-- and AceGUI widget restyling
------------------------------------------------------------

local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
GuildGreet = GLDG

local UIStyle = {}
GLDG.UIStyle = UIStyle

UIStyle.MIN_FONT_SIZE = 10
UIStyle.MAX_FONT_SIZE = 18
UIStyle.DEFAULT_FONT_SIZE = 13

UIStyle.Colors = {
    bgMain          = { 0.06, 0.07, 0.09, 0.96 },
    bgPanel         = { 0.09, 0.10, 0.13, 0.95 },
    bgHeader        = { 0.12, 0.13, 0.17, 1.00 },
    bgSidebar       = { 0.07, 0.08, 0.11, 0.98 },
    bgInput         = { 0.05, 0.06, 0.08, 0.95 },
    bgRow           = { 0.11, 0.12, 0.16, 0.75 },
    bgRowAlt        = { 0.14, 0.15, 0.20, 0.75 },
    bgRowHover      = { 0.20, 0.22, 0.28, 0.92 },
    bgRowActive     = { 0.24, 0.21, 0.14, 0.95 },
    border          = { 0.22, 0.24, 0.30, 1.00 },
    borderSubtle    = { 0.16, 0.18, 0.23, 1.00 },
    borderHighlight = { 0.85, 0.71, 0.29, 0.85 },
    gold            = { 0.85, 0.71, 0.29, 1.00 },
    goldDim         = { 0.62, 0.52, 0.22, 1.00 },
    textLight       = { 0.92, 0.93, 0.95, 1.00 },
    textMuted       = { 0.58, 0.60, 0.66, 1.00 },
    green           = { 0.30, 0.85, 0.45, 1.00 },
    red             = { 0.90, 0.30, 0.30, 1.00 },
}

UIStyle.Hex = {
    gold      = "|cffd9b54a",
    goldDim   = "|cff9e8538",
    textLight = "|cffebedf2",
    textMuted = "|cff9499a8",
    green     = "|cff4cd973",
    red       = "|cffe64d4d",
    cyan      = "|cff5bc0be",
    reset     = "|r",
}

UIStyle.FlatBackdrop = {
    bgFile   = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    tile     = false,
    tileSize = 0,
    edgeSize = 1,
    insets   = { left = 1, right = 1, top = 1, bottom = 1 },
}

function UIStyle:GetFontSize()
    local size = GLDG and GLDG.db and GLDG.db.profile and tonumber(GLDG.db.profile.UIFontSize)
    if not size then
        size = self.DEFAULT_FONT_SIZE
    end
    return math.max(self.MIN_FONT_SIZE, math.min(self.MAX_FONT_SIZE, math.floor(size + 0.5)))
end

function UIStyle:SetFontSize(size)
    size = tonumber(size) or self.DEFAULT_FONT_SIZE
    size = math.max(self.MIN_FONT_SIZE, math.min(self.MAX_FONT_SIZE, math.floor(size + 0.5)))
    if GLDG and GLDG.db and GLDG.db.profile then
        GLDG.db.profile.UIFontSize = size
    end
    if GLDG and GLDG.ApplyUIFontSize then
        GLDG:ApplyUIFontSize()
    end
    return size
end

function UIStyle:ApplyFont(fontString, delta, flags)
    if not fontString or not fontString.SetFont then return end
    local existingFont, _, existingFlags = fontString:GetFont()
    local fontPath = existingFont or STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
    local targetSize = math.max(9, self:GetFontSize() + (delta or 0))
    fontString:SetFont(fontPath, targetSize, flags or existingFlags or "")
end

function UIStyle:ApplyBox(frame, bgColor, borderColor)
    if not frame or not frame.SetBackdrop then return end
    frame.callbackBackdropColor = nil
    if frame.iborder and frame.iborder.Hide then frame.iborder:Hide() end
    if frame.oborder and frame.oborder.Hide then frame.oborder:Hide() end
    frame:SetBackdrop(self.FlatBackdrop)
    local bg = bgColor or self.Colors.bgPanel
    local br = borderColor or self.Colors.border
    frame:SetBackdropColor(bg[1], bg[2], bg[3], bg[4] or 1)
    frame:SetBackdropBorderColor(br[1], br[2], br[3], br[4] or 1)
end

function UIStyle:CreateButton(parent, text, minWidth, height, onClick, isAccent)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn._minWidth = minWidth or 80
    btn._baseHeight = height or 26
    btn._isAccent = isAccent and true or false

    self:ApplyBox(
        btn,
        isAccent and self.Colors.bgRowActive or self.Colors.bgRow,
        isAccent and self.Colors.borderHighlight or self.Colors.border
    )

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("CENTER", 0, 0)
    self:ApplyFont(label, 0)
    label:SetText(text or "")
    if isAccent then
        label:SetTextColor(unpack(self.Colors.gold))
    else
        label:SetTextColor(unpack(self.Colors.textLight))
    end
    btn.label = label

    function btn:UpdateSize()
        UIStyle:ApplyFont(self.label, 0)
        local textW = math.ceil((self.label:GetStringWidth() or 0) + 26)
        local targetW = math.max(self._minWidth or 80, textW)
        local targetH = math.max(self._baseHeight or 26, UIStyle:GetFontSize() + 13)
        self:SetSize(targetW, targetH)
    end

    function btn:SetText(newText)
        self.label:SetText(newText or "")
        self:UpdateSize()
    end

    function btn:SetDisabledState(disabled)
        if disabled then
            self:Disable()
            self:SetAlpha(0.45)
        else
            self:Enable()
            self:SetAlpha(1.0)
        end
    end

    btn:UpdateSize()

    btn:SetScript("OnEnter", function(selfBtn)
        if not selfBtn:IsEnabled() then return end
        UIStyle:ApplyBox(selfBtn, UIStyle.Colors.bgRowHover, UIStyle.Colors.borderHighlight)
        selfBtn.label:SetTextColor(1, 0.9, 0.55, 1)
    end)
    btn:SetScript("OnLeave", function(selfBtn)
        if not selfBtn:IsEnabled() then return end
        UIStyle:ApplyBox(
            selfBtn,
            selfBtn._isAccent and UIStyle.Colors.bgRowActive or UIStyle.Colors.bgRow,
            selfBtn._isAccent and UIStyle.Colors.borderHighlight or UIStyle.Colors.border
        )
        if selfBtn._isAccent then
            selfBtn.label:SetTextColor(unpack(UIStyle.Colors.gold))
        else
            selfBtn.label:SetTextColor(unpack(UIStyle.Colors.textLight))
        end
    end)
    if onClick then
        btn:SetScript("OnClick", onClick)
    end
    return btn
end

------------------------------------------------------------
-- Shared Native Dark-Slate Components (Zero Taint)
------------------------------------------------------------
local sharedDropdownMenu = nil
local sharedDropdownCatcher = nil

function UIStyle:CloseDropdown()
    if sharedDropdownMenu then sharedDropdownMenu:Hide() end
    if sharedDropdownCatcher then sharedDropdownCatcher:Hide() end
end

function UIStyle:OpenDropdown(anchorBtn, items, selectedValue, onSelect)
    if sharedDropdownMenu and sharedDropdownMenu:IsShown() and sharedDropdownMenu._anchor == anchorBtn then
        self:CloseDropdown()
        return
    end

    if not sharedDropdownCatcher then
        sharedDropdownCatcher = CreateFrame("Button", nil, UIParent)
        sharedDropdownCatcher:SetFrameStrata("FULLSCREEN_DIALOG")
        sharedDropdownCatcher:SetFrameLevel(90)
        sharedDropdownCatcher:SetAllPoints(UIParent)
        sharedDropdownCatcher:EnableMouse(true)
        sharedDropdownCatcher:SetScript("OnClick", function() UIStyle:CloseDropdown() end)
    end

    if not sharedDropdownMenu then
        sharedDropdownMenu = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
        sharedDropdownMenu:SetFrameStrata("TOOLTIP")
        sharedDropdownMenu:SetFrameLevel(125)
        sharedDropdownMenu:SetClampedToScreen(true)
        sharedDropdownMenu:EnableMouse(true)
        self:ApplyBox(sharedDropdownMenu, self.Colors.bgSidebar, self.Colors.borderHighlight)

        local sf = CreateFrame("ScrollFrame", nil, sharedDropdownMenu, "UIPanelScrollFrameTemplate")
        sf:SetPoint("TOPLEFT", sharedDropdownMenu, "TOPLEFT", 4, -4)
        sf:SetPoint("BOTTOMRIGHT", sharedDropdownMenu, "BOTTOMRIGHT", -24, 4)
        sharedDropdownMenu.scrollFrame = sf

        local child = CreateFrame("Frame", nil, sf)
        child:SetSize(200, 20)
        sf:SetScrollChild(child)
        sharedDropdownMenu.scrollChild = child
        sharedDropdownMenu.optionButtons = {}
    end

    sharedDropdownMenu._anchor = anchorBtn
    local menuW = math.max(anchorBtn:GetWidth() or 200, 220)
    local rowH = math.max(24, self:GetFontSize() + 10)
    local totalH = #items * rowH
    local visibleH = math.min(math.max(totalH + 8, 32), 280)
    local needsScroll = (totalH + 8) > 280

    sharedDropdownMenu:SetSize(menuW, visibleH)
    sharedDropdownMenu:ClearAllPoints()
    sharedDropdownMenu:SetPoint("TOPLEFT", anchorBtn, "BOTTOMLEFT", 0, -2)

    local sf = sharedDropdownMenu.scrollFrame
    sf:ClearAllPoints()
    sf:SetPoint("TOPLEFT", sharedDropdownMenu, "TOPLEFT", 4, -4)
    sf:SetPoint("BOTTOMRIGHT", sharedDropdownMenu, "BOTTOMRIGHT", needsScroll and -24 or -4, 4)
    if sf.ScrollBar then
        if needsScroll then sf.ScrollBar:Show() else sf.ScrollBar:Hide() end
    end

    local childW = menuW - (needsScroll and 28 or 8)
    sharedDropdownMenu.scrollChild:SetSize(childW, math.max(totalH, 10))

    for idx, item in ipairs(items) do
        local opt = sharedDropdownMenu.optionButtons[idx]
        if not opt then
            opt = CreateFrame("Button", nil, sharedDropdownMenu.scrollChild, BackdropTemplateMixin and "BackdropTemplate" or nil)
            local txt = opt:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            txt:SetPoint("LEFT", opt, "LEFT", 8, 0)
            txt:SetPoint("RIGHT", opt, "RIGHT", -8, 0)
            txt:SetJustifyH("LEFT")
            txt:SetWordWrap(false)
            opt.label = txt
            sharedDropdownMenu.optionButtons[idx] = opt
        end

        opt:SetSize(childW, rowH)
        opt:ClearAllPoints()
        opt:SetPoint("TOPLEFT", sharedDropdownMenu.scrollChild, "TOPLEFT", 0, -(idx - 1) * rowH)
        self:ApplyFont(opt.label, 0)
        opt.label:SetText(item.label or "")

        local isSelected = (item.value == selectedValue)
        if isSelected then
            self:ApplyBox(opt, self.Colors.bgRowActive, self.Colors.borderSubtle)
            opt.label:SetTextColor(unpack(self.Colors.gold))
        else
            self:ApplyBox(opt, (idx % 2 == 0) and self.Colors.bgRowAlt or self.Colors.bgRow, self.Colors.borderSubtle)
            opt.label:SetTextColor(unpack(self.Colors.textLight))
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
            UIStyle:CloseDropdown()
            if onSelect then
                onSelect(item.value, item.label)
            end
        end)
        opt:Show()
    end

    for idx = #items + 1, #sharedDropdownMenu.optionButtons do
        sharedDropdownMenu.optionButtons[idx]:Hide()
    end

    sharedDropdownCatcher:Show()
    sharedDropdownMenu:Show()
end

function UIStyle:CreateDropdown(parent, width, height)
    local btn = CreateFrame("Button", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    btn:SetSize(width or 180, height or 28)
    self:ApplyBox(btn, self.Colors.bgInput, self.Colors.border)

    local txt = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    txt:SetPoint("LEFT", btn, "LEFT", 10, 0)
    txt:SetPoint("RIGHT", btn, "RIGHT", -24, 0)
    txt:SetJustifyH("LEFT")
    txt:SetWordWrap(false)
    self:ApplyFont(txt, 0)
    txt:SetTextColor(unpack(self.Colors.textLight))
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
            self:SetAlpha(0.50)
        else
            self:Enable()
            self:SetAlpha(1.0)
        end
    end

    return btn
end

function UIStyle:CreateEditBox(parent, height, placeholderText)
    local box = CreateFrame("EditBox", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    box:SetHeight(height or 28)
    box:SetAutoFocus(false)
    box:SetTextInsets(10, 26, 0, 0)
    box:SetFontObject(ChatFontNormal)
    self:ApplyFont(box, 0)
    box:SetTextColor(unpack(self.Colors.textLight))
    self:ApplyBox(box, self.Colors.bgInput, self.Colors.border)

    if placeholderText and placeholderText ~= "" then
        local ph = box:CreateFontString(nil, "ARTWORK", "GameFontDisable")
        ph:SetPoint("LEFT", box, "LEFT", 10, 0)
        ph:SetPoint("RIGHT", box, "RIGHT", -26, 0)
        ph:SetJustifyH("LEFT")
        ph:SetWordWrap(false)
        self:ApplyFont(ph, 0)
        ph:SetTextColor(unpack(self.Colors.textMuted))
        ph:SetText(placeholderText)
        box.placeholder = ph
    end

    local clearBtn = CreateFrame("Button", nil, box)
    clearBtn:SetSize(13, 13)
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

function UIStyle:CreateIconButton(parent, iconPath, size, tooltipTitle, onClick, isAccent)
    local btn = CreateFrame("Button", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    btn:SetSize(size or 24, size or 24)
    self:ApplyBox(
        btn,
        isAccent and self.Colors.bgRowActive or self.Colors.bgInput,
        isAccent and self.Colors.borderHighlight or self.Colors.border
    )

    local ic = btn:CreateTexture(nil, "ARTWORK")
    local icSize = math.max(13, (size or 24) - 10)
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

function UIStyle:CreateCard(parent, titleText)
    local card = CreateFrame("Frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    self:ApplyBox(card, self.Colors.bgPanel, self.Colors.borderSubtle)

    if titleText then
        local hdr = CreateFrame("Frame", nil, card, BackdropTemplateMixin and "BackdropTemplate" or nil)
        hdr:SetHeight(28)
        hdr:SetPoint("TOPLEFT", card, "TOPLEFT", 1, -1)
        hdr:SetPoint("TOPRIGHT", card, "TOPRIGHT", -1, -1)
        self:ApplyBox(hdr, self.Colors.bgHeader, self.Colors.borderSubtle)
        card.header = hdr

        local lbl = hdr:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lbl:SetPoint("LEFT", hdr, "LEFT", 12, 0)
        lbl:SetPoint("RIGHT", hdr, "RIGHT", -12, 0)
        lbl:SetJustifyH("LEFT")
        lbl:SetWordWrap(false)
        self:ApplyFont(lbl, 0)
        lbl:SetTextColor(unpack(self.Colors.gold))
        lbl:SetText(titleText)
        card.title = lbl
    end

    return card
end

function UIStyle:OpenColorPicker(r, g, b, a, hasAlpha, onChange)
    if not ColorPickerFrame then return end
    ColorPickerFrame:Hide()
    ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    ColorPickerFrame:SetClampedToScreen(true)

    local invertedAlpha = (WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE)
    local initR, initG, initB, initA = r or 1, g or 1, b or 1, (hasAlpha and (a or 1) or 1)

    if ColorPickerFrame.SetupColorPickerAndShow then
        local pickerOpacity = invertedAlpha and (1 - initA) or initA
        local function applyCurrent()
            local nr, ng, nb = ColorPickerFrame:GetColorRGB()
            local na = 1
            if hasAlpha and ColorPickerFrame.GetColorAlpha then
                local rawA = ColorPickerFrame:GetColorAlpha() or 1
                na = invertedAlpha and (1 - rawA) or rawA
            end
            if onChange then onChange(nr, ng, nb, na) end
        end
        ColorPickerFrame:SetupColorPickerAndShow({
            r = initR,
            g = initG,
            b = initB,
            hasOpacity = hasAlpha and true or false,
            opacity = pickerOpacity,
            swatchFunc = applyCurrent,
            opacityFunc = applyCurrent,
            cancelFunc = function()
                if onChange then onChange(initR, initG, initB, initA) end
            end,
        })
    else
        local function applyLegacy()
            local nr, ng, nb = ColorPickerFrame:GetColorRGB()
            local na = 1
            if hasAlpha and OpacitySliderFrame then
                na = 1 - (OpacitySliderFrame:GetValue() or 0)
            end
            if onChange then onChange(nr, ng, nb, na) end
        end
        ColorPickerFrame.func = applyLegacy
        ColorPickerFrame.hasOpacity = hasAlpha and true or false
        ColorPickerFrame.opacityFunc = applyLegacy
        if hasAlpha then
            ColorPickerFrame.opacity = 1 - initA
        end
        ColorPickerFrame:SetColorRGB(initR, initG, initB)
        ColorPickerFrame.cancelFunc = function()
            if onChange then onChange(initR, initG, initB, initA) end
        end
        ColorPickerFrame:Show()
    end
end

function UIStyle:StyleAceWidget(widget)
    if not widget or not widget.type then return end
    local wtype = widget.type
    local fontSize = self:GetFontSize()

    -- Guard against IEEE-754 floating-point sums (e.g. 0.65 + 0.18 + 0.17 > 1.0) wrapping rows in AceGUI Flow layout
    if widget.width == "relative" and type(widget.relWidth) == "number" and widget.relWidth > 0.01 then
        if not widget._ggOrigRelWidth or math.abs(widget.relWidth - widget._ggAdjustedRelWidth) > 0.001 then
            widget._ggOrigRelWidth = widget.relWidth
            widget._ggAdjustedRelWidth = math.floor(widget.relWidth * 10000 - 2) / 10000
            widget.relWidth = widget._ggAdjustedRelWidth
        end
    end

    if wtype == "ScrollFrame" then
        if not widget._ggWidthHooked and widget.OnWidthSet then
            widget._ggWidthHooked = true
            hooksecurefunc(widget, "OnWidthSet", function(selfWidget)
                if selfWidget.DoLayout then
                    pcall(function() selfWidget:DoLayout() end)
                end
            end)
        end
    elseif wtype == "InlineGroup" or wtype == "TabGroup" then
        local border = widget.border or widget.content and widget.content:GetParent()
        if wtype == "InlineGroup" and widget.titletext then
            self:ApplyFont(widget.titletext, 1)
            widget.titletext:SetTextColor(unpack(self.Colors.gold))
            widget.titletext:SetHeight(0)
            widget.titletext:SetWordWrap(true)
            local function updateInlineTitleOffset(grp, width)
                if not grp or not grp.titletext then return end
                local b = grp.border or (grp.content and grp.content:GetParent())
                local w = (width or (grp.frame and (grp.frame.width or grp.frame:GetWidth())) or 600) - 28
                if w > 60 then
                    grp.titletext:SetWidth(w)
                end
                local fs = UIStyle:GetFontSize()
                local th = math.max(18, math.ceil((grp.titletext:GetStringHeight() or (fs + 2)) + 4))
                local extra = math.max(0, th - 17)
                grp._ggTitleExtra = extra
                if b then
                    b:ClearAllPoints()
                    b:SetPoint("TOPLEFT", 0, -(17 + extra))
                    b:SetPoint("BOTTOMRIGHT", 0, 3)
                end
            end
            updateInlineTitleOffset(widget)
            if not widget._ggInlineHooked then
                widget._ggInlineHooked = true
                if widget.OnWidthSet then
                    hooksecurefunc(widget, "OnWidthSet", function(selfGroup, width)
                        updateInlineTitleOffset(selfGroup, width)
                    end)
                end
                if widget.LayoutFinished then
                    hooksecurefunc(widget, "LayoutFinished", function(selfGroup, _, height)
                        local extra = selfGroup._ggTitleExtra or 0
                        if extra > 0 and not selfGroup.noAutoHeight then
                            selfGroup:SetHeight((height or 0) + 40 + extra)
                        end
                    end)
                end
            end
        else
            if widget.titletext then
                self:ApplyFont(widget.titletext, 1)
                widget.titletext:SetTextColor(unpack(self.Colors.gold))
            end
        end
        if border and border.SetBackdrop then
            self:ApplyBox(border, self.Colors.bgPanel, self.Colors.borderSubtle)
        end
        if wtype == "TabGroup" and widget.tabs then
            for _, tab in ipairs(widget.tabs) do
                local fs = tab.text or (tab.GetFontString and tab:GetFontString())
                if fs then
                    self:ApplyFont(fs, 0)
                end
            end
            if widget.BuildTabs then
                pcall(function() widget:BuildTabs() end)
            end
        end
    elseif wtype == "Heading" then
        if widget.label then
            self:ApplyFont(widget.label, 1)
            widget.label:SetTextColor(unpack(self.Colors.gold))
        end
        if widget.left and widget.left.SetColorTexture then
            widget.left:SetColorTexture(0.85, 0.71, 0.29, 0.35)
            widget.left:SetHeight(1)
        end
        if widget.right and widget.right.SetColorTexture then
            widget.right:SetColorTexture(0.85, 0.71, 0.29, 0.35)
            widget.right:SetHeight(1)
        end
    elseif wtype == "Label" or wtype == "InteractiveLabel" then
        if widget.label then
            self:ApplyFont(widget.label, 0)
            local r, g, b = widget.label:GetTextColor()
            if r and r > 0.95 and g and g > 0.95 and b and b > 0.95 then
                widget.label:SetTextColor(unpack(self.Colors.textLight))
            end
            if widget.OnWidthSet then
                local w = (widget.frame and (widget.frame.width or widget.frame:GetWidth())) or 200
                pcall(widget.OnWidthSet, widget, w)
            end
        end
    elseif wtype == "CheckBox" then
        if widget.frame and widget.checkbg then
            local frame = widget.frame
            if not frame._ggCheckBoxBg then
                local box = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate" or nil)
                box:SetSize(18, 18)
                box:SetPoint("CENTER", widget.checkbg, "CENTER", 0, 0)
                self:ApplyBox(box, self.Colors.bgInput, self.Colors.border)
                frame._ggCheckBoxBg = box

                local icon = box:CreateTexture(nil, "OVERLAY", nil, 7)
                icon:SetSize(16, 16)
                icon:SetPoint("CENTER", box, "CENTER", 0, 0)
                icon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
                frame._ggCheckIcon = icon

                local function syncBoxState(w)
                    if not w or not w.frame or not w.frame._ggCheckBoxBg then return end
                    local b = w.frame._ggCheckBoxBg
                    local ic = w.frame._ggCheckIcon
                    if w.check then w.check:SetAlpha(0) end
                    if w.checkbg then w.checkbg:SetAlpha(0) end
                    if w.checkbg and w.checkbg.backdrop then
                        w.checkbg.backdrop:SetAlpha(0)
                        if w.checkbg.backdrop.Hide then w.checkbg.backdrop:Hide() end
                    end
                    if w.checked then
                        ic:Show()
                        UIStyle:ApplyBox(b, { 0.13, 0.23, 0.19, 1 }, UIStyle.Colors.borderHighlight)
                    else
                        ic:Hide()
                        UIStyle:ApplyBox(b, UIStyle.Colors.bgInput, UIStyle.Colors.border)
                    end
                    if w.disabled then
                        ic:SetDesaturated(true)
                        b:SetAlpha(0.45)
                    else
                        ic:SetDesaturated(false)
                        b:SetAlpha(1.0)
                    end
                end

                hooksecurefunc(widget, "SetValue", syncBoxState)
                hooksecurefunc(widget, "SetDisabled", syncBoxState)
                frame._ggSyncCheck = syncBoxState
            end
            if frame._ggSyncCheck then
                frame._ggSyncCheck(widget)
            end
        end
        if widget.text then
            self:ApplyFont(widget.text, 0)
            widget.text:SetTextColor(unpack(self.Colors.textLight))
            widget.text:SetHeight(0)
            widget.text:SetWordWrap(true)
            if widget.text.SetNonSpaceWrap then
                widget.text:SetNonSpaceWrap(true)
            end
            widget.text:SetJustifyV("TOP")
            local function anchorCheckText(w, dx, dy)
                if not w or not w.text or not w.checkbg then return end
                dx = dx or 0
                dy = dy or 0
                w.text:ClearAllPoints()
                if w.image and w.image:GetTexture() then
                    w.text:SetPoint("TOPLEFT", w.image, "TOPRIGHT", 4 + dx, -2 + dy)
                else
                    w.text:SetPoint("TOPLEFT", w.checkbg, "TOPRIGHT", 4 + dx, -4 + dy)
                end
                w.text:SetPoint("RIGHT", w.frame, "RIGHT", -6, 0)
            end
            anchorCheckText(widget)
            widget._ggStyledCheck = true

            local function updateCheckHeight(w, width)
                if not w or not w._ggStyledCheck or not w.text or not w.frame then return end
                local availW = (width or w.frame.width or w.frame:GetWidth() or 300) - 34
                if availW > 40 then
                    w.text:SetWidth(availW)
                end
                anchorCheckText(w)
                local fs = UIStyle:GetFontSize()
                local h = math.max(26, math.ceil((w.text:GetStringHeight() or fs) + 10))
                if w.SetHeight then
                    w:SetHeight(h)
                else
                    w.frame:SetHeight(h)
                    w.frame.height = h
                end
            end

            if not widget._ggCheckWidthHooked then
                widget._ggCheckWidthHooked = true
                if widget.OnWidthSet then
                    hooksecurefunc(widget, "OnWidthSet", function(selfCb, width)
                        updateCheckHeight(selfCb, width)
                    end)
                end
                if widget.frame then
                    widget.frame:HookScript("OnMouseDown", function()
                        if widget._ggStyledCheck and not widget.disabled then
                            anchorCheckText(widget, 1, -1)
                        end
                    end)
                    widget.frame:HookScript("OnMouseUp", function()
                        if widget._ggStyledCheck then
                            anchorCheckText(widget, 0, 0)
                        end
                    end)
                end
                local origRelease = widget.OnRelease
                widget.OnRelease = function(selfCb, ...)
                    selfCb._ggStyledCheck = nil
                    if selfCb.text then
                        selfCb.text:SetHeight(18)
                        selfCb.text:SetJustifyV("MIDDLE")
                    end
                    if origRelease then
                        return origRelease(selfCb, ...)
                    end
                end
            end
            updateCheckHeight(widget)
        end
    elseif wtype == "Button" then
        local frame = widget.frame
        if frame then
            if frame.backdrop and frame.backdrop.Hide then
                frame.backdrop:Hide()
            end
            if not frame._ggStyled then
                frame._ggStyled = true
                if frame.Left then frame.Left:SetAlpha(0) end
                if frame.Middle then frame.Middle:SetAlpha(0) end
                if frame.Right then frame.Right:SetAlpha(0) end
                local norm = frame:GetNormalTexture()
                if norm then norm:SetAlpha(0) end
                local high = frame:GetHighlightTexture()
                if high then high:SetAlpha(0) end
                local push = frame:GetPushedTexture()
                if push then push:SetAlpha(0) end

                if not frame.SetBackdrop and BackdropTemplateMixin then
                    Mixin(frame, BackdropTemplateMixin)
                end
                if frame.SetBackdrop then
                    self:ApplyBox(frame, self.Colors.bgRow, self.Colors.border)
                    frame:HookScript("OnEnter", function(f)
                        if f:IsEnabled() then
                            UIStyle:ApplyBox(f, UIStyle.Colors.bgRowHover, UIStyle.Colors.borderHighlight)
                        end
                    end)
                    frame:HookScript("OnLeave", function(f)
                        UIStyle:ApplyBox(f, UIStyle.Colors.bgRow, UIStyle.Colors.border)
                    end)
                end
            end
            if widget.text then
                widget.text:ClearAllPoints()
                widget.text:SetPoint("TOPLEFT", 6, -1)
                widget.text:SetPoint("BOTTOMRIGHT", -6, 1)
                widget.text:SetJustifyH("CENTER")
                widget.text:SetJustifyV("MIDDLE")
                self:ApplyFont(widget.text, 0)
                widget.text:SetTextColor(unpack(self.Colors.textLight))
                widget.text:SetWordWrap(false)
            end
            local btnHeight = math.max(26, fontSize + 13)
            if widget.SetHeight then
                widget:SetHeight(btnHeight)
            else
                frame:SetHeight(btnHeight)
                frame.height = btnHeight
            end
        end
    elseif wtype == "EditBox" then
        if widget.label then
            self:ApplyFont(widget.label, -1)
            widget.label:SetTextColor(unpack(self.Colors.goldDim))
        end
        if widget.editbox then
            local eb = widget.editbox
            self:ApplyFont(eb, 0)
            eb:SetTextColor(unpack(self.Colors.textLight))
            if not eb._ggFlatBox then
                local name = eb:GetName()
                if name then
                    if _G[name .. "Left"] then _G[name .. "Left"]:SetAlpha(0) end
                    if _G[name .. "Middle"] then _G[name .. "Middle"]:SetAlpha(0) end
                    if _G[name .. "Right"] then _G[name .. "Right"]:SetAlpha(0) end
                end
                if eb.Left then eb.Left:SetAlpha(0) end
                if eb.Middle then eb.Middle:SetAlpha(0) end
                if eb.Right then eb.Right:SetAlpha(0) end
                local bg = CreateFrame("Frame", nil, eb, BackdropTemplateMixin and "BackdropTemplate" or nil)
                bg:SetFrameLevel(math.max(1, eb:GetFrameLevel() - 1))
                bg:SetPoint("TOPLEFT", eb, "TOPLEFT", -4, 2)
                bg:SetPoint("BOTTOMRIGHT", eb, "BOTTOMRIGHT", 0, -2)
                self:ApplyBox(bg, self.Colors.bgInput, self.Colors.border)
                eb._ggFlatBox = bg
                eb:HookScript("OnEditFocusGained", function()
                    UIStyle:ApplyBox(bg, UIStyle.Colors.bgInput, UIStyle.Colors.borderHighlight)
                end)
                eb:HookScript("OnEditFocusLost", function()
                    UIStyle:ApplyBox(bg, UIStyle.Colors.bgInput, UIStyle.Colors.border)
                end)
            end
        end
    elseif wtype == "MultiLineEditBox" then
        if widget.label then
            self:ApplyFont(widget.label, -1)
            widget.label:SetTextColor(unpack(self.Colors.goldDim))
        end
        if widget.editBox then
            self:ApplyFont(widget.editBox, 0)
        end
        if widget.scrollBG and widget.scrollBG.SetBackdrop then
            self:ApplyBox(widget.scrollBG, self.Colors.bgInput, self.Colors.border)
        end
    elseif wtype == "Dropdown" then
        if widget.label then
            self:ApplyFont(widget.label, -1)
            widget.label:SetTextColor(unpack(self.Colors.goldDim))
        end
        if widget.dropdown and not widget.dropdown._ggFlatBox then
            local dd = widget.dropdown
            local dName = dd:GetName()
            if dName then
                if _G[dName .. "Left"] then _G[dName .. "Left"]:SetAlpha(0) end
                if _G[dName .. "Middle"] then _G[dName .. "Middle"]:SetAlpha(0) end
                if _G[dName .. "Right"] then _G[dName .. "Right"]:SetAlpha(0) end
            end
            if dd.Left then dd.Left:SetAlpha(0) end
            if dd.Middle then dd.Middle:SetAlpha(0) end
            if dd.Right then dd.Right:SetAlpha(0) end
            local bg = CreateFrame("Frame", nil, widget.frame, BackdropTemplateMixin and "BackdropTemplate" or nil)
            bg:SetFrameLevel(math.max(1, widget.frame:GetFrameLevel()))
            bg:SetPoint("BOTTOMLEFT", widget.frame, "BOTTOMLEFT", 0, 2)
            bg:SetPoint("TOPRIGHT", widget.frame, "BOTTOMRIGHT", 0, 26)
            self:ApplyBox(bg, self.Colors.bgInput, self.Colors.border)
            dd._ggFlatBox = bg
            if widget.button_cover then
                widget.button_cover:HookScript("OnEnter", function()
                    if not widget.disabled then
                        UIStyle:ApplyBox(bg, UIStyle.Colors.bgRowHover, UIStyle.Colors.borderHighlight)
                    end
                end)
                widget.button_cover:HookScript("OnLeave", function()
                    UIStyle:ApplyBox(bg, UIStyle.Colors.bgInput, UIStyle.Colors.border)
                end)
            end
        end
        if widget.text then
            self:ApplyFont(widget.text, 0)
            widget.text:SetTextColor(unpack(self.Colors.textLight))
            if widget.text.SetJustifyH then widget.text:SetJustifyH("LEFT") end
        end
    elseif wtype == "Slider" then
        if widget.label then
            self:ApplyFont(widget.label, -1)
            widget.label:SetTextColor(unpack(self.Colors.goldDim))
        end
        if widget.editbox then
            self:ApplyFont(widget.editbox, 0)
        end
    end
end

local function StyleAceTreeOnly(self, widget)
    if not widget then return end
    self:StyleAceWidget(widget)
    if widget.children then
        for i = 1, #widget.children do
            StyleAceTreeOnly(self, widget.children[i])
        end
    end
end

local function LayoutAceTreeTopDown(widget)
    if not widget then return end
    if widget.DoLayout then
        pcall(function() widget:DoLayout() end)
    end
    if widget.children then
        for i = 1, #widget.children do
            LayoutAceTreeTopDown(widget.children[i])
        end
    end
    if widget.DoLayout then
        pcall(function() widget:DoLayout() end)
    end
    if widget.FixScroll then
        pcall(function() widget:FixScroll() end)
    end
end

function UIStyle:StyleAceWidgetsRecursive(widget)
    if not widget then return end
    StyleAceTreeOnly(self, widget)
    LayoutAceTreeTopDown(widget)
end
