------------------------------------------------------------
-- GuildGreet Modern GUI - Colours Configuration Tab
-- Directly edits GLDG.Colors (guild, friends, channel, help, header)
------------------------------------------------------------

local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", true)
local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
GuildGreet = GLDG

local UIStyle = GLDG.UIStyle
local activeColourSet = "guild"

local COLOUR_KEYS = {
    { key = "online",     label = "Coming Online (Chat)" },
    { key = "goOff",      label = "Going Offline (Chat)" },
    { key = "isOff",      label = "Is Offline (Chat List)" },
    { key = "alias",      label = "Alias & Main Tag" },
    { key = "list",       label = "Queue: Default Online" },
    { key = "relog",      label = "Queue: Relog" },
    { key = "new",        label = "Queue: New Guild Member" },
    { key = "lvl",        label = "Queue: Level-Up" },
    { key = "rank",       label = "Queue: Promotion" },
    { key = "achievment", label = "Queue: Achievement" },
}

local function HexToRGBA(hexStr)
    if GLDG.Colors and GLDG.Colors.ColourToRGB_perc then
        local a, r, g, b = GLDG.Colors:ColourToRGB_perc(hexStr)
        return r or 1, g or 1, b or 1, a or 1
    end
    return 1, 1, 1, 1
end

local function RGBAToHex(r, g, b, a)
    if GLDG.Colors and GLDG.Colors.RGBToColour_perc then
        return GLDG.Colors:RGBToColour_perc(a or 1, r or 1, g or 1, b or 1)
    end
    return string.format("|c%02X%02X%02X%02X", (a or 1) * 255, (r or 1) * 255, (g or 1) * 255, (b or 1) * 255)
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
        GLDG_Data.colours = colors
    end
    GLDG:ShowQueue()
end

function GLDG:CreateColourTab(container)
    if self.Colors and self.Colors.Initialize then
        self.Colors:Initialize()
    end
    local colors = self:GetColors()

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    container:AddChild(scroll)

    local COLOUR_KEYS = {
        { key = "online",     label = L["Comes online"] or "Coming Online (Chat)" },
        { key = "goOff",      label = L["Going offline"] or "Going Offline (Chat)" },
        { key = "isOff",      label = L["Is offline"] or "Is Offline (Chat List)" },
        { key = "alias",      label = L["Alias"] or "Alias & Main Tag" },
        { key = "list",       label = L["Greeting"] or "Queue: Default Online" },
        { key = "relog",      label = L["Relog"] or "Queue: Relog" },
        { key = "new",        label = L["New member"] or "Queue: New Guild Member" },
        { key = "lvl",        label = L["Level up"] or "Queue: Level-Up" },
        { key = "rank",       label = L["Promotion"] or "Queue: Promotion" },
        { key = "achievment", label = L["Achievment"] or "Queue: Achievement" },
    }

    --------------------------------------------------------
    -- 1. Colour Set Selector (Guild / Friends / Channel)
    --------------------------------------------------------
    local setGroup = AceGUI:Create("InlineGroup")
    setGroup:SetTitle(L["Colour Settings"] or "Select Target Colour Set")
    setGroup:SetFullWidth(true)
    setGroup:SetLayout("Flow")
    scroll:AddChild(setGroup)

    local setDropdown = AceGUI:Create("Dropdown")
    setDropdown:SetLabel(L["Colour"] or "Colour Set")
    setDropdown:SetList({
        guild   = L["Guild"] or "Guild Members",
        friends = L["Friends"] or "Friends List",
        channel = L["Channel"] or "Custom Channel",
    })
    setDropdown:SetValue(activeColourSet)
    setDropdown:SetRelativeWidth(0.40)
    setDropdown:SetCallback("OnValueChanged", function(_, _, val)
        activeColourSet = val or "guild"
        if GLDG.Colors and GLDG.Colors.SetActiveColourSet then
            GLDG.Colors:SetActiveColourSet(activeColourSet)
        end
        GLDG:RefreshConfigUI()
    end)
    setGroup:AddChild(setDropdown)

    local copyToAllBtn = AceGUI:Create("Button")
    copyToAllBtn:SetText(L["Copy Set to Friends & Channel"] or "Copy Set to Friends & Channel")
    copyToAllBtn:SetRelativeWidth(0.32)
    copyToAllBtn:SetCallback("OnClick", function()
        local src = colors[activeColourSet]
        if src then
            for _, targetSet in ipairs({ "guild", "friends", "channel" }) do
                colors[targetSet] = colors[targetSet] or {}
                for k, v in pairs(src) do
                    colors[targetSet][k] = v
                end
            end
            SyncColorGlobals()
            GLDG:PrintInfo("Copied '" .. activeColourSet .. "' colours to all sets.")
            GLDG:RefreshConfigUI()
        end
    end)
    setGroup:AddChild(copyToAllBtn)

    local resetBtn = AceGUI:Create("Button")
    resetBtn:SetText(L["Restore default"] or "Restore Defaults")
    resetBtn:SetRelativeWidth(0.28)
    resetBtn:SetCallback("OnClick", function()
        if GLDG.Colors and GLDG.Colors.SetDefaults then
            GLDG.Colors:SetDefaults()
            SyncColorGlobals()
            GLDG:PrintInfo("Default colours restored.")
            GLDG:RefreshConfigUI()
        end
    end)
    setGroup:AddChild(resetBtn)

    --------------------------------------------------------
    -- 2. Set Specific Colors (Chat & Greeting Queue)
    --------------------------------------------------------
    local activeTable = colors[activeColourSet] or {}
    colors[activeColourSet] = activeTable

    local pickGroup = AceGUI:Create("InlineGroup")
    pickGroup:SetTitle((L["Character Colours"] or "Chat & Queue Colours") .. " — " .. string.upper(activeColourSet))
    pickGroup:SetFullWidth(true)
    pickGroup:SetLayout("Flow")
    scroll:AddChild(pickGroup)

    for _, item in ipairs(COLOUR_KEYS) do
        local cp = AceGUI:Create("ColorPicker")
        cp:SetLabel(item.label)
        cp:SetHasAlpha(false)
        local r, g, b, a = HexToRGBA(activeTable[item.key] or "|cFFFFFFFF")
        cp:SetColor(r, g, b, a)
        cp:SetRelativeWidth(0.50)
        cp:SetCallback("OnValueConfirmed", function(_, _, nr, ng, nb, na)
            activeTable[item.key] = RGBAToHex(nr, ng, nb, na or 1)
            SyncColorGlobals()
            GLDG:RefreshConfigUI()
        end)
        pickGroup:AddChild(cp)
    end

    --------------------------------------------------------
    -- 3. Global Addon Colors (Help Text & Queue Header)
    --------------------------------------------------------
    local globalGroup = AceGUI:Create("InlineGroup")
    globalGroup:SetTitle(L["System Messages"] or "Global AddOn Colours")
    globalGroup:SetFullWidth(true)
    globalGroup:SetLayout("Flow")
    scroll:AddChild(globalGroup)

    local helpPicker = AceGUI:Create("ColorPicker")
    helpPicker:SetLabel(L["Help"] or "Chat Help & Notification Accent")
    helpPicker:SetHasAlpha(false)
    local hr, hg, hb, ha = HexToRGBA(colors.help or GLDG_DEFAULT_HELP_COLOUR)
    helpPicker:SetColor(hr, hg, hb, ha)
    helpPicker:SetRelativeWidth(0.50)
    helpPicker:SetCallback("OnValueConfirmed", function(_, _, nr, ng, nb, na)
        colors.help = RGBAToHex(nr, ng, nb, na or 1)
        SyncColorGlobals()
        GLDG:RefreshConfigUI()
    end)
    globalGroup:AddChild(helpPicker)

    local headerPicker = AceGUI:Create("ColorPicker")
    headerPicker:SetLabel(L["Header"] or "Queue Header Tint")
    headerPicker:SetHasAlpha(true)
    local tr, tg, tb, ta = HexToRGBA(colors.header or GLDG_DEFAULT_HEADER_COLOUR)
    headerPicker:SetColor(tr, tg, tb, ta)
    headerPicker:SetRelativeWidth(0.50)
    headerPicker:SetCallback("OnValueConfirmed", function(_, _, nr, ng, nb, na)
        colors.header = RGBAToHex(nr, ng, nb, na or 0.5)
        SyncColorGlobals()
        GLDG:RefreshConfigUI()
    end)
    globalGroup:AddChild(headerPicker)

    --------------------------------------------------------
    -- 4. Live Preview Card
    --------------------------------------------------------
    local previewGroup = AceGUI:Create("InlineGroup")
    previewGroup:SetTitle((L["Current Colour"] or "Live Colour Preview") .. " (" .. string.upper(activeColourSet) .. ")")
    previewGroup:SetFullWidth(true)
    previewGroup:SetLayout("Flow")
    scroll:AddChild(previewGroup)

    local previewText = AceGUI:Create("Label")
    previewText:SetFullWidth(true)
    previewText:SetText(string.format(
        "%s[Online]|r PlayerName: Lv80 Paladin %s(Alias)|r\n" ..
        "%s[Going Offline]|r PlayerName %s(Alias)|r\n" ..
        "%s[Queue Default]|r [12:00] PlayerName    " ..
        "%s[Queue Relog]|r [12:05] PlayerName    " ..
        "%s[Queue New]|r [12:10] NewMember\n" ..
        "%s[Queue Level-Up]|r [12:15] PlayerName    " ..
        "%s[Queue Promotion]|r [12:20] Officer    " ..
        "%s[Queue Achievement]|r [12:25] Achiever",
        activeTable.online or "|cFFA0FFA0",
        activeTable.alias or "|cFFFFA0A0",
        activeTable.goOff or "|cFF7F7F7F",
        activeTable.alias or "|cFFFFA0A0",
        activeTable.list or "|cFFFF7F00",
        activeTable.relog or "|cFF3FFF3F",
        activeTable.new or "|cFFFF3F3F",
        activeTable.lvl or "|cFF7F7F7F",
        activeTable.rank or "|cFFCC00CC",
        activeTable.achievment or "|cFF001FFF"
    ))
    previewGroup:AddChild(previewText)
end
