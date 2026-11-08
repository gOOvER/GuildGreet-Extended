------------------------------------------------------------
-- GuildGreet Modern GUI - Greetings & Collections Tab
-- Manages all 16 greeting categories and custom collections
------------------------------------------------------------

local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", true)
local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
GuildGreet = GLDG

local UIStyle = GLDG.UIStyle

local selectedCategory = "Greet"
local selectedCollection = "" -- "" = Default Realm Greetings
local selectedMsgIndex = nil

local CATEGORY_ORDER = {
    "Greet",
    "GreetBack",
    "Welcome",
    "NewLevel",
    "NewRank",
    "Achievment",
    "Bye",
    "Night",
    "Guild",
    "Channel",
    "ByeGuild",
    "NightGuild",
    "ByeChannel",
    "NightChannel",
    "LaterGuild",
    "LaterChannel",
}

local CATEGORY_LABELS = {
    Greet        = "1. Online Greeting (Default)",
    GreetBack    = "2. Relog Greeting (Welcome Back)",
    Welcome      = "3. New Guild Member (Welcome)",
    NewLevel     = "4. Level-Up Congratulations",
    NewRank      = "5. Promotion / New Rank",
    Achievment   = "6. Achievement Congratulations",
    Bye          = "7. Player Goodbye (Day)",
    Night        = "8. Player Good Night (20:00 - 05:00)",
    Guild        = "9. Greet Entire Guild",
    Channel      = "10. Greet Entire Channel",
    ByeGuild     = "11. Say Goodbye to Guild (Day)",
    NightGuild   = "12. Say Good Night to Guild",
    ByeChannel   = "13. Say Goodbye to Channel (Day)",
    NightChannel = "14. Say Good Night to Channel",
    LaterGuild   = "15. See You Later to Guild",
    LaterChannel = "16. See You Later to Channel",
}

local function GetActiveCategoryList(cat)
    cat = cat or selectedCategory
    if selectedCollection and selectedCollection ~= "" and GLDG_Data.Collections and GLDG_Data.Collections[selectedCollection] then
        local col = GLDG_Data.Collections[selectedCollection]
        col[cat] = col[cat] or {}
        return col[cat]
    end
    GLDG_DataGreet[cat] = GLDG_DataGreet[cat] or {}
    GLDG_Data[cat] = GLDG_DataGreet[cat]
    return GLDG_DataGreet[cat]
end

local function SyncGreetingAliases()
    if GLDG_DataGreet then
        GLDG_DataGreet.GreetGuild = GLDG_DataGreet.Guild
        GLDG_DataGreet.GreetChannel = GLDG_DataGreet.Channel
    end
end

function GLDG:CreateGreetingsTab(container)
    if self.Database and self.Database.InitializeGreetings then
        self.Database:InitializeGreetings()
    end

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    container:AddChild(scroll)

    local CATEGORY_LABELS = {
        Greet        = "1. " .. (L["Going online"] or "Online Greeting (Default)"),
        GreetBack    = "2. " .. (L["Coming back online"] or "Relog Greeting (Welcome Back)"),
        Welcome      = "3. " .. (L["Welcome to guild"] or "New Guild Member (Welcome)"),
        NewLevel     = "4. " .. (L["Level up"] or "Level-Up Congratulations"),
        NewRank      = "5. " .. (L["Promotion"] or "Promotion / New Rank"),
        Achievment   = "6. " .. (L["Achievment"] or "Achievement Congratulations"),
        Bye          = "7. " .. (L["Leaving char (day)"] or "Player Goodbye (Day)"),
        Night        = "8. " .. (L["Leaving char (night)"] or "Player Good Night (20:00 - 05:00)"),
        Guild        = "9. " .. (L["Greeting the guild"] or "Greet Entire Guild"),
        Channel      = "10. " .. (L["Greeting the channel"] or "Greet Entire Channel"),
        ByeGuild     = "11. " .. (L["Say goodbye to guild"] or "Say Goodbye to Guild (Day)"),
        NightGuild   = "12. " .. (L["Say good night to guild"] or "Say Good Night to Guild"),
        ByeChannel   = "13. " .. (L["Say goodbye to channel"] or "Say Goodbye to Channel (Day)"),
        NightChannel = "14. " .. (L["Say good night to channel"] or "Say Good Night to Channel"),
        LaterGuild   = "15. " .. (L["See you later to guild"] or "See You Later to Guild"),
        LaterChannel = "16. " .. (L["See you later to channel"] or "See You Later to Channel"),
    }

    --------------------------------------------------------
    -- 1. Collection & Category Selector Bar
    --------------------------------------------------------
    local topGroup = AceGUI:Create("InlineGroup")
    topGroup:SetTitle(L["Manage the messages you want to use for greeting"] or "Category & Collection Selection")
    topGroup:SetFullWidth(true)
    topGroup:SetLayout("Flow")
    scroll:AddChild(topGroup)

    local catDropdown = AceGUI:Create("Dropdown")
    catDropdown:SetLabel(L["Greeting Category"] or "Greeting Category")
    catDropdown:SetList(CATEGORY_LABELS, CATEGORY_ORDER)
    catDropdown:SetValue(selectedCategory)
    catDropdown:SetRelativeWidth(0.49)
    catDropdown:SetCallback("OnValueChanged", function(_, _, val)
        selectedCategory = val
        selectedMsgIndex = nil
        GLDG:RefreshConfigUI()
    end)
    topGroup:AddChild(catDropdown)

    local colList = { [""] = L["Global defaults"] or "Default Greetings (Active)" }
    if GLDG_Data and GLDG_Data.Collections then
        for colName in pairs(GLDG_Data.Collections) do
            colList[colName] = (L["Collection"] or "Collection") .. ": " .. colName
        end
    end

    local colDropdown = AceGUI:Create("Dropdown")
    colDropdown:SetLabel(L["Available custom collections"] or "Target Collection")
    colDropdown:SetList(colList)
    colDropdown:SetValue(selectedCollection or "")
    colDropdown:SetRelativeWidth(0.49)
    colDropdown:SetCallback("OnValueChanged", function(_, _, val)
        selectedCollection = val or ""
        selectedMsgIndex = nil
        GLDG:RefreshConfigUI()
    end)
    topGroup:AddChild(colDropdown)

    local newColEdit = AceGUI:Create("EditBox")
    newColEdit:SetLabel(L["Create new collection"] or "Create New Collection Name")
    newColEdit:SetRelativeWidth(0.44)
    newColEdit:SetCallback("OnEnterPressed", function(widget, _, text)
        text = strtrim(text or "")
        if text == "" then return end
        GLDG_Data.Collections = GLDG_Data.Collections or {}
        if not GLDG_Data.Collections[text] then
            local newCol = {}
            for _, cat in ipairs(CATEGORY_ORDER) do
                newCol[cat] = {}
            end
            GLDG_Data.Collections[text] = newCol
        end
        selectedCollection = text
        widget:SetText("")
        GLDG:RefreshConfigUI()
    end)
    topGroup:AddChild(newColEdit)

    if selectedCollection ~= "" then
        local assignGuildBtn = AceGUI:Create("Button")
        assignGuildBtn:SetText(L["Set guild"] or "Use for Current Guild")
        assignGuildBtn:SetRelativeWidth(0.27)
        assignGuildBtn:SetCallback("OnClick", function()
            if GLDG_unique_GuildName and GLDG_unique_GuildName ~= "" then
                GLDG_Data.Custom = GLDG_Data.Custom or {}
                GLDG_Data.Custom[GLDG_unique_GuildName] = selectedCollection
                GLDG_DataGreet = GLDG_Data.Collections[selectedCollection]
                GLDG:PrintInfo("Assigned collection '" .. selectedCollection .. "' to current guild.")
            end
        end)
        topGroup:AddChild(assignGuildBtn)

        local delColBtn = AceGUI:Create("Button")
        delColBtn:SetText(L["Remove collection"] or "Delete Collection")
        delColBtn:SetRelativeWidth(0.27)
        delColBtn:SetCallback("OnClick", function()
            if GLDG_Data.Collections and GLDG_Data.Collections[selectedCollection] then
                GLDG_Data.Collections[selectedCollection] = nil
                selectedCollection = ""
                selectedMsgIndex = nil
                GLDG:RefreshConfigUI()
            end
        end)
        topGroup:AddChild(delColBtn)
    end

    --------------------------------------------------------
    -- 2. Add / Edit Template Group
    --------------------------------------------------------
    local editGroup = AceGUI:Create("InlineGroup")
    local currentDesc = CATEGORY_LABELS[selectedCategory] or selectedCategory
    editGroup:SetTitle((L["Add New Message"] or "Add or Edit Template") .. " — " .. currentDesc)
    editGroup:SetFullWidth(true)
    editGroup:SetLayout("Flow")
    scroll:AddChild(editGroup)

    local list = GetActiveCategoryList(selectedCategory)
    local currentEditValue = (selectedMsgIndex and list[selectedMsgIndex]) or ""

    local msgEdit = AceGUI:Create("EditBox")
    msgEdit:SetLabel(selectedMsgIndex and ((L["EditSelected"] or "Editing Message") .. " #" .. selectedMsgIndex) or (L["Add New Message"] or "New Greeting Message (Press Enter to Save)"))
    msgEdit:SetText(currentEditValue)
    msgEdit:SetRelativeWidth(0.50)
    msgEdit:SetCallback("OnEnterPressed", function(widget, _, text)
        text = strtrim(text or "")
        if text == "" then return end
        if selectedMsgIndex and list[selectedMsgIndex] then
            list[selectedMsgIndex] = text
        else
            table.insert(list, text)
        end
        selectedMsgIndex = nil
        SyncGreetingAliases()
        widget:SetText("")
        GLDG:RefreshConfigUI()
    end)
    editGroup:AddChild(msgEdit)

    local saveBtn = AceGUI:Create("Button")
    saveBtn:SetText(selectedMsgIndex and (L["update"] or "Update") or (L["add"] or "Add Message"))
    saveBtn:SetRelativeWidth(0.20)
    saveBtn:SetCallback("OnClick", function()
        local text = strtrim(msgEdit:GetText() or "")
        if text == "" then return end
        if selectedMsgIndex and list[selectedMsgIndex] then
            list[selectedMsgIndex] = text
        else
            table.insert(list, text)
        end
        selectedMsgIndex = nil
        SyncGreetingAliases()
        GLDG:RefreshConfigUI()
    end)
    editGroup:AddChild(saveBtn)

    local clearSelBtn = AceGUI:Create("Button")
    clearSelBtn:SetText(selectedMsgIndex and (L["Remove selection"] or "Cancel Edit") or (L["Restore default"] or "Restore Defaults"))
    clearSelBtn:SetRelativeWidth(0.28)
    clearSelBtn:SetCallback("OnClick", function()
        if selectedMsgIndex then
            selectedMsgIndex = nil
            GLDG:RefreshConfigUI()
        else
            wipe(list)
            if GLDG.Database and GLDG.Database.InitializeGreetings then
                GLDG.Database:InitializeGreetings()
            end
            GLDG:RefreshConfigUI()
        end
    end)
    editGroup:AddChild(clearSelBtn)

    --------------------------------------------------------
    -- 3. Configured Messages List
    --------------------------------------------------------
    local listGroup = AceGUI:Create("InlineGroup")
    listGroup:SetTitle(string.format("%s (%d)", L["Greetings"] or "Configured Messages", #list))
    listGroup:SetFullWidth(true)
    listGroup:SetLayout("Flow")
    scroll:AddChild(listGroup)

    if #list == 0 then
        local emptyLabel = AceGUI:Create("Label")
        emptyLabel:SetText(UIStyle.Hex.textMuted .. (L["No greeting templates configured in this category."] or "No greeting templates configured in this category.") .. UIStyle.Hex.reset)
        emptyLabel:SetFullWidth(true)
        listGroup:AddChild(emptyLabel)
    else
        for idx, msgText in ipairs(list) do
            local row = AceGUI:Create("SimpleGroup")
            row:SetFullWidth(true)
            row:SetLayout("Flow")

            local isSelected = (selectedMsgIndex == idx)
            local prefixColor = isSelected and UIStyle.Hex.gold or UIStyle.Hex.textLight

            local lbl = AceGUI:Create("InteractiveLabel")
            lbl:SetText(string.format("%s#%d:|r %s%s|r", UIStyle.Hex.goldDim, idx, prefixColor, msgText))
            lbl:SetRelativeWidth(0.62)
            lbl:SetCallback("OnClick", function()
                if selectedMsgIndex == idx then
                    selectedMsgIndex = nil
                else
                    selectedMsgIndex = idx
                end
                GLDG:RefreshConfigUI()
            end)
            row:AddChild(lbl)

            local testBtn = AceGUI:Create("Button")
            testBtn:SetText(L["Test"] or "Preview")
            testBtn:SetRelativeWidth(0.18)
            testBtn:SetCallback("OnClick", function()
                local player = (GLDG.Player or UnitName("player") or "Player")
                local fullPlayer = player .. "-" .. string.gsub(GLDG.Realm or GetRealmName() or "Realm", " ", "")
                local parsed = GLDG_ParseCustomMessage(fullPlayer, player, msgText)
                local ok, formatted = pcall(string.format, parsed, player, "80")
                GLDG:PrintInfo("Preview: " .. (ok and formatted or parsed))
            end)
            row:AddChild(testBtn)

            local delBtn = AceGUI:Create("Button")
            delBtn:SetText(L["remove"] or "Delete")
            delBtn:SetRelativeWidth(0.18)
            delBtn:SetCallback("OnClick", function()
                table.remove(list, idx)
                if selectedMsgIndex == idx then
                    selectedMsgIndex = nil
                end
                SyncGreetingAliases()
                GLDG:RefreshConfigUI()
            end)
            row:AddChild(delBtn)

            listGroup:AddChild(row)
        end
    end

    --------------------------------------------------------
    -- 4. Placeholder Reference Card
    --------------------------------------------------------
    local helpGroup = AceGUI:Create("InlineGroup")
    helpGroup:SetTitle(L["Available Message Placeholders & Filters"] or "Available Message Placeholders & Filters")
    helpGroup:SetFullWidth(true)
    helpGroup:SetLayout("Flow")
    scroll:AddChild(helpGroup)

    local helpLabel = AceGUI:Create("Label")
    helpLabel:SetFullWidth(true)
    helpLabel:SetText(
        UIStyle.Hex.gold .. "%s / %n|r = " .. (L["Selected greet name (Char, Main, or Alias)"] or "Selected greet name (Char, Main, or Alias)") .. "    " ..
        UIStyle.Hex.gold .. "%c|r = " .. (L["Character name"] or "Character name") .. "    " ..
        UIStyle.Hex.gold .. "%m|r = " .. (L["Main name"] or "Main name") .. "\n" ..
        UIStyle.Hex.gold .. "%a|r = " .. (L["Character alias"] or "Character alias") .. "    " ..
        UIStyle.Hex.gold .. "%A|r = " .. (L["Main's alias"] or "Main's alias") .. "    " ..
        UIStyle.Hex.gold .. "%l|r = " .. (L["Level"] or "Level") .. "    " ..
        UIStyle.Hex.gold .. "%L|r = " .. (L["Levels left to cap"] or "Levels left to cap") .. "\n" ..
        UIStyle.Hex.gold .. "%C|r = " .. (L["Character class"] or "Character class") .. "    " ..
        UIStyle.Hex.gold .. "%r|r = " .. (L["Guild rank"] or "Guild rank") .. "    " ..
        UIStyle.Hex.gold .. "%v|r = " .. (L["Achievement link"] or "Achievement link") .. "    " ..
        UIStyle.Hex.gold .. "%g / %G|r = " .. (L["Guild alias / Guild name"] or "Guild alias / Guild name") .. "\n" ..
        UIStyle.Hex.cyan .. (L["Filters:"] or "Filters:") .. "|r " ..
        string.format(
            L["Prefix message with %s for level range (NewLevel) or %s for time of day."] or "Prefix message with %s for level range (NewLevel) or %s for time of day.",
            UIStyle.Hex.gold .. "{min:max}|r",
            UIStyle.Hex.gold .. "{HH:MM:HH:MM}|r"
        )
    )
    helpGroup:AddChild(helpLabel)
end
