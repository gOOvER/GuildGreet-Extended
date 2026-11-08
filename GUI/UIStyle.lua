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
        if border then
            if wtype == "InlineGroup" then
                border:ClearAllPoints()
                border:SetPoint("TOPLEFT", 0, -17)
                border:SetPoint("BOTTOMRIGHT", 0, 3)
            end
            if border.SetBackdrop then
                self:ApplyBox(border, self.Colors.bgPanel, self.Colors.borderSubtle)
            end
        end
        if widget.titletext then
            self:ApplyFont(widget.titletext, 1)
            widget.titletext:SetTextColor(unpack(self.Colors.gold))
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
            if widget.AlignImage then
                pcall(function() widget:AlignImage() end)
            end
        end
        if widget.frame and widget.text then
            local h = math.max(26, (widget.text:GetStringHeight() or fontSize) + 10)
            if widget.SetHeight then
                widget:SetHeight(h)
            else
                widget.frame:SetHeight(h)
                widget.frame.height = h
            end
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
            self:ApplyFont(widget.editbox, 0)
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
        if widget.text then
            self:ApplyFont(widget.text, 0)
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
