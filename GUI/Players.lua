------------------------------------------------------------
-- GuildGreet Modern GUI - Players Manager Tab
-- Full Main/Alt/Alias/Note/Ignore management on GLDG_DataChar
------------------------------------------------------------

local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", true)
local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
GuildGreet = GLDG

local UIStyle = GLDG.UIStyle

local searchFilter = ""
local roleFilter = "all"
local guildFilter = "__ALL__"
local currentPage = 1
local PAGE_SIZE = 25
local selectedPlayer = nil

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

local function CountAltsOf(mainName)
    local count = 0
    if not GLDG_DataChar then return 0 end
    for _, p in pairs(GLDG_DataChar) do
        if p and p.alt == mainName then
            count = count + 1
        end
    end
    return count
end

local function GetAllMainsMap()
    local mains = { ["__NONE__"] = L["-- Not an Alt (Unassigned) --"] or "-- Not an Alt (Unassigned) --" }
    if not GLDG_DataChar then return mains end
    for name, p in pairs(GLDG_DataChar) do
        if p and p.main then
            local label = Ambiguate(name, "guild")
            if p.alias and p.alias ~= "" then
                label = label .. " (" .. p.alias .. ")"
            end
            mains[name] = label
        end
    end
    return mains
end

local function GetAvailableGuildsMap()
    local guilds = {
        ["__ALL__"]     = L["No guild filter"] or "All Guilds",
        ["__CURRENT__"] = (L["Guild"] or "Current Guild") .. " (" .. tostring(GLDG.GuildName or GetGuildInfo("player") or "None") .. ")",
        ["__NOGUILD__"] = L["Guildless"] or "Guildless Characters",
    }
    if GLDG_DataChar then
        for _, p in pairs(GLDG_DataChar) do
            if p and p.guild and p.guild ~= "" then
                guilds[p.guild] = p.guild
            end
        end
    end
    return guilds
end

local function GetFilteredPlayers()
    local results = {}
    if not GLDG_DataChar then return results end

    local q = string.lower(strtrim(searchFilter or ""))
    for name, p in pairs(GLDG_DataChar) do
        if type(p) == "table" then
            local pass = true

            if not GLDG_Data.GuildSettings.IncludeOwn and p.own then
                pass = false
            end

            -- Guild filter
            if pass then
                if guildFilter == "__CURRENT__" then
                    pass = (p.guild and p.guild == GLDG_unique_GuildName)
                elseif guildFilter == "__NOGUILD__" then
                    pass = (not p.guild or p.guild == "")
                elseif guildFilter ~= "__ALL__" then
                    pass = (p.guild == guildFilter)
                end
            end

            -- Role filter
            if pass then
                if roleFilter == "mains" then
                    pass = (p.main == true)
                elseif roleFilter == "alts" then
                    pass = (p.alt ~= nil and p.alt ~= "")
                elseif roleFilter == "unassigned" then
                    pass = (not p.main and not p.alt)
                elseif roleFilter == "online" then
                    pass = (GLDG_Online and GLDG_Online[name] ~= nil)
                elseif roleFilter == "ignored" then
                    pass = (p.ignore == true)
                end
            end

            -- Search query
            if pass and q ~= "" then
                local nLower = string.lower(name)
                local aLower = p.alias and string.lower(p.alias) or ""
                local mLower = p.alt and string.lower(p.alt) or ""
                local rLower = p.rankname and string.lower(p.rankname) or ""
                local pnLower = p.pNote and string.lower(p.pNote) or ""
                local onLower = p.oNote and string.lower(p.oNote) or ""
                if not (string.find(nLower, q, 1, true)
                    or string.find(aLower, q, 1, true)
                    or string.find(mLower, q, 1, true)
                    or string.find(rLower, q, 1, true)
                    or string.find(pnLower, q, 1, true)
                    or string.find(onLower, q, 1, true)) then
                    pass = false
                end
            end

            if pass then
                table.insert(results, name)
            end
        end
    end

    table.sort(results, function(a, b)
        return string.lower(Ambiguate(a, "guild")) < string.lower(Ambiguate(b, "guild"))
    end)

    return results
end

function GLDG:CreatePlayersTab(container)
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    container:AddChild(scroll)

    --------------------------------------------------------
    -- 1. Filter & Search Toolbar
    --------------------------------------------------------
    local filterGroup = AceGUI:Create("InlineGroup")
    filterGroup:SetTitle(L["Filter"] or "Search, Filter & Roster Tools")
    filterGroup:SetFullWidth(true)
    filterGroup:SetLayout("Flow")
    scroll:AddChild(filterGroup)

    local searchBox = AceGUI:Create("EditBox")
    searchBox:SetLabel(L["Search Character / Alias / Main / Note"] or "Search Character / Alias / Main / Note")
    searchBox:SetText(searchFilter)
    searchBox:SetRelativeWidth(0.34)
    searchBox:SetCallback("OnEnterPressed", function(_, _, text)
        searchFilter = text or ""
        currentPage = 1
        GLDG:RefreshConfigUI()
    end)
    filterGroup:AddChild(searchBox)

    local roleDrop = AceGUI:Create("Dropdown")
    roleDrop:SetLabel(L["Filter"] or "Character Filter")
    roleDrop:SetList({
        all        = L["All Players"] or "All Characters",
        mains      = L["Main"] or "Mains Only",
        alts       = L["Alts"] or "Alts Only",
        unassigned = L["Not assigned"] or "Unassigned (No Main/Alt)",
        online     = L["Online"] or "Currently Online",
        ignored    = L["Ignored"] or "Ignored Characters",
    })
    roleDrop:SetValue(roleFilter)
    roleDrop:SetRelativeWidth(0.33)
    roleDrop:SetCallback("OnValueChanged", function(_, _, val)
        roleFilter = val or "all"
        currentPage = 1
        GLDG:RefreshConfigUI()
    end)
    filterGroup:AddChild(roleDrop)

    local guildDrop = AceGUI:Create("Dropdown")
    guildDrop:SetLabel(L["Guild"] or "Guild Filter")
    guildDrop:SetList(GetAvailableGuildsMap())
    guildDrop:SetValue(guildFilter)
    guildDrop:SetRelativeWidth(0.33)
    guildDrop:SetCallback("OnValueChanged", function(_, _, val)
        guildFilter = val or "__ALL__"
        currentPage = 1
        GLDG:RefreshConfigUI()
    end)
    filterGroup:AddChild(guildDrop)

    local importRosterBtn = AceGUI:Create("Button")
    importRosterBtn:SetText(L["Refresh"] or "Rescan Guild Roster")
    importRosterBtn:SetRelativeWidth(0.34)
    importRosterBtn:SetCallback("OnClick", function()
        GLDG_ReadNotes = 1
        GLDG_RosterImport()
        GLDG:RefreshConfigUI()
    end)
    filterGroup:AddChild(importRosterBtn)

    local checkBtn = AceGUI:Create("Button")
    checkBtn:SetText(L["Check consistency"] or "Check Main/Alt Consistency")
    checkBtn:SetRelativeWidth(0.33)
    checkBtn:SetCallback("OnClick", function()
        GLDG_Convert_Plausibility_Check(false)
    end)
    filterGroup:AddChild(checkBtn)

    local fixBtn = AceGUI:Create("Button")
    fixBtn:SetText(L["Fix inconsistencies"] or "Auto-Fix Inconsistencies")
    fixBtn:SetRelativeWidth(0.33)
    fixBtn:SetCallback("OnClick", function()
        GLDG_fixCount = 0
        GLDG_Convert_Plausibility_Fix(false)
        GLDG:RefreshConfigUI()
    end)
    filterGroup:AddChild(fixBtn)

    --------------------------------------------------------
    -- 2. Selected Character Inspector & Editor
    --------------------------------------------------------
    if selectedPlayer and GLDG_DataChar and GLDG_DataChar[selectedPlayer] then
        local p = GLDG_DataChar[selectedPlayer]
        local editGroup = AceGUI:Create("InlineGroup")
        local cHex = GetClassHex(p.enClass)
        editGroup:SetTitle((L["Character"] or "Selected Character") .. ": " .. cHex .. Ambiguate(selectedPlayer, "guild") .. "|r (" .. selectedPlayer .. ")")
        editGroup:SetFullWidth(true)
        editGroup:SetLayout("Flow")
        scroll:AddChild(editGroup)

        local roleTag = p.ignore and (UIStyle.Hex.red .. "IGNORED|r")
            or p.main and (UIStyle.Hex.green .. "MAIN (" .. CountAltsOf(selectedPlayer) .. " Alts)|r")
            or p.alt and (UIStyle.Hex.cyan .. "ALT of " .. Ambiguate(p.alt, "guild") .. "|r")
            or (UIStyle.Hex.textMuted .. "Unassigned|r")

        local infoLabel = AceGUI:Create("Label")
        infoLabel:SetFullWidth(true)
        infoLabel:SetText(string.format(
            "%sStatus:|r %s    %sLevel:|r %s %s    %sRank:|r %s    %sGuild:|r %s\n%sPublic Note:|r %s    %sOfficer Note:|r %s",
            UIStyle.Hex.gold, roleTag,
            UIStyle.Hex.gold, tostring(p.lvl or "?"), tostring(p.class or ""),
            UIStyle.Hex.gold, tostring(p.rankname or "---"),
            UIStyle.Hex.gold, tostring(p.guild or "---"),
            UIStyle.Hex.goldDim, tostring(p.pNote or "---"),
            UIStyle.Hex.goldDim, tostring(p.oNote or "---")
        ))
        editGroup:AddChild(infoLabel)

        -- Set/Promote/Unset Main Button
        local mainBtn = AceGUI:Create("Button")
        if p.alt then
            mainBtn:SetText(L["Promote to main"] or "Promote to Main")
        elseif p.main then
            mainBtn:SetText(L["Unset as main"] or "Unset as Main")
            mainBtn:SetDisabled(CountAltsOf(selectedPlayer) > 0)
        else
            mainBtn:SetText(L["Set as main"] or "Set as Main")
        end
        mainBtn:SetRelativeWidth(0.25)
        mainBtn:SetCallback("OnClick", function()
            GLDG_SelPlrName = selectedPlayer
            if p.alt then
                local oldMain = p.alt
                p.alt = nil
                p.main = true
                if GLDG_DataChar[oldMain] then
                    GLDG_DataChar[oldMain].main = nil
                    GLDG_DataChar[oldMain].alt = selectedPlayer
                end
                for _, charData in pairs(GLDG_DataChar) do
                    if charData.alt == oldMain then
                        charData.alt = selectedPlayer
                    end
                end
            elseif p.main then
                if CountAltsOf(selectedPlayer) == 0 then
                    p.main = nil
                end
            else
                p.main = true
            end
            GLDG:RefreshConfigUI()
        end)
        editGroup:AddChild(mainBtn)

        -- Assign to Main Dropdown (Alt Assignment)
        local altDrop = AceGUI:Create("Dropdown")
        altDrop:SetLabel(L["Assign as Alt of Main"] or "Assign as Alt of Main")
        altDrop:SetList(GetAllMainsMap())
        altDrop:SetValue(p.alt or "__NONE__")
        altDrop:SetDisabled(p.main == true)
        altDrop:SetRelativeWidth(0.35)
        altDrop:SetCallback("OnValueChanged", function(_, _, val)
            if val == "__NONE__" or not val then
                p.alt = nil
            elseif val ~= selectedPlayer then
                p.main = nil
                p.alt = val
                if GLDG_DataChar[val] then
                    p.ignore = GLDG_DataChar[val].ignore
                end
            end
            GLDG:RefreshConfigUI()
        end)
        editGroup:AddChild(altDrop)

        -- Alias EditBox
        local aliasEdit = AceGUI:Create("EditBox")
        aliasEdit:SetLabel(L["Alias"] or "Alias (Press Enter)")
        aliasEdit:SetText(p.alias or "")
        aliasEdit:SetRelativeWidth(0.40)
        aliasEdit:SetCallback("OnEnterPressed", function(_, _, text)
            text = strtrim(text or "")
            p.alias = (text ~= "") and text or nil
            GLDG:RefreshConfigUI()
        end)
        editGroup:AddChild(aliasEdit)

        -- Custom Note EditBox
        local noteEdit = AceGUI:Create("EditBox")
        noteEdit:SetLabel(L["Note"] or "Custom Note (Press Enter)")
        noteEdit:SetText(p.note or "")
        noteEdit:SetRelativeWidth(0.40)
        noteEdit:SetCallback("OnEnterPressed", function(_, _, text)
            text = strtrim(text or "")
            p.note = (text ~= "") and text or nil
            GLDG:RefreshConfigUI()
        end)
        editGroup:AddChild(noteEdit)

        -- Ignore / Unignore Button
        local ignoreBtn = AceGUI:Create("Button")
        ignoreBtn:SetText(p.ignore and (L["Unignore"] or "Unignore") or (L["Ignore"] or "Ignore"))
        ignoreBtn:SetRelativeWidth(0.20)
        ignoreBtn:SetCallback("OnClick", function()
            p.ignore = not p.ignore and true or nil
            if p.main then
                for _, altData in pairs(GLDG_DataChar) do
                    if altData.alt == selectedPlayer then
                        altData.ignore = p.ignore
                    end
                end
            end
            GLDG:RefreshConfigUI()
        end)
        editGroup:AddChild(ignoreBtn)

        -- Greet Now Button
        local greetBtn = AceGUI:Create("Button")
        greetBtn:SetText(L["Greeting"] or "Greet Now")
        greetBtn:SetRelativeWidth(0.20)
        greetBtn:SetCallback("OnClick", function()
            GLDG_SendGreet(selectedPlayer)
        end)
        editGroup:AddChild(greetBtn)

        -- Delete Character Button
        local removeBtn = AceGUI:Create("Button")
        removeBtn:SetText(L["Remove"] or "Remove")
        removeBtn:SetRelativeWidth(0.20)
        removeBtn:SetDisabled(p.main == true or p.alt ~= nil)
        removeBtn:SetCallback("OnClick", function()
            local removed = selectedPlayer
            GLDG_DataChar[removed] = nil
            selectedPlayer = nil
            GLDG:PrintInfo("Removed character " .. Ambiguate(removed, "guild"))
            GLDG:RefreshConfigUI()
        end)
        editGroup:AddChild(removeBtn)
    end

    --------------------------------------------------------
    -- 3. Paginated Character Roster Table
    --------------------------------------------------------
    local filtered = GetFilteredPlayers()
    local totalPlayers = #filtered
    local totalPages = math.max(1, math.ceil(totalPlayers / PAGE_SIZE))
    if currentPage > totalPages then currentPage = totalPages end
    if currentPage < 1 then currentPage = 1 end

    local startIdx = (currentPage - 1) * PAGE_SIZE + 1
    local endIdx = math.min(totalPlayers, currentPage * PAGE_SIZE)

    local listGroup = AceGUI:Create("InlineGroup")
    listGroup:SetTitle(string.format("%s (%d)", L["Players"] or "Characters", totalPlayers))
    listGroup:SetFullWidth(true)
    listGroup:SetLayout("Flow")
    scroll:AddChild(listGroup)

    -- Pagination Controls
    if totalPages > 1 then
        local navRow = AceGUI:Create("SimpleGroup")
        navRow:SetFullWidth(true)
        navRow:SetLayout("Flow")

        local prevBtn = AceGUI:Create("Button")
        prevBtn:SetText("< " .. (L["Previous"] or "Previous"))
        prevBtn:SetRelativeWidth(0.30)
        prevBtn:SetDisabled(currentPage <= 1)
        prevBtn:SetCallback("OnClick", function()
            currentPage = math.max(1, currentPage - 1)
            GLDG:RefreshConfigUI()
        end)
        navRow:AddChild(prevBtn)

        local pageLbl = AceGUI:Create("Label")
        pageLbl:SetText(string.format("   %d - %d / %d", startIdx, endIdx, totalPlayers))
        pageLbl:SetRelativeWidth(0.40)
        navRow:AddChild(pageLbl)

        local nextBtn = AceGUI:Create("Button")
        nextBtn:SetText((L["Next"] or "Next") .. " >")
        nextBtn:SetRelativeWidth(0.30)
        nextBtn:SetDisabled(currentPage >= totalPages)
        nextBtn:SetCallback("OnClick", function()
            currentPage = math.min(totalPages, currentPage + 1)
            GLDG:RefreshConfigUI()
        end)
        navRow:AddChild(nextBtn)

        listGroup:AddChild(navRow)
    end

    if totalPlayers == 0 then
        local empty = AceGUI:Create("Label")
        empty:SetFullWidth(true)
        empty:SetText(UIStyle.Hex.textMuted .. (L["No characters match the current filters."] or "No characters match the current filters.") .. UIStyle.Hex.reset)
        listGroup:AddChild(empty)
    else
        for i = startIdx, endIdx do
            local name = filtered[i]
            local p = GLDG_DataChar[name]
            if p then
                local row = AceGUI:Create("SimpleGroup")
                row:SetFullWidth(true)
                row:SetLayout("Flow")

                local isOnline = GLDG_Online and GLDG_Online[name]
                local statusDot = isOnline and (UIStyle.Hex.green .. "●|r ") or (UIStyle.Hex.textMuted .. "○|r ")
                local cHex = GetClassHex(p.enClass)
                local shortName = Ambiguate(name, "guild")
                local selMarker = (selectedPlayer == name) and (UIStyle.Hex.gold .. "» |r") or ""

                local roleText = ""
                if p.ignore then
                    roleText = UIStyle.Hex.red .. "[IGN]|r "
                elseif p.main then
                    roleText = UIStyle.Hex.green .. "[MAIN]|r "
                elseif p.alt then
                    roleText = UIStyle.Hex.cyan .. "[ALT -> " .. Ambiguate(p.alt, "guild") .. "]|r "
                end

                local aliasText = (p.alias and p.alias ~= "") and (UIStyle.Hex.gold .. " (" .. p.alias .. ")|r") or ""
                local lvlRank = string.format(
                    "%sLv%s %s — %s|r",
                    UIStyle.Hex.textMuted,
                    tostring(p.lvl or "?"),
                    tostring(p.class or ""),
                    tostring(p.rankname or p.guild or "---")
                )

                local charLabel = AceGUI:Create("InteractiveLabel")
                charLabel:SetText(selMarker .. statusDot .. cHex .. shortName .. "|r" .. aliasText .. "  " .. roleText .. lvlRank)
                charLabel:SetRelativeWidth(0.80)
                charLabel:SetCallback("OnClick", function()
                    if selectedPlayer == name then
                        selectedPlayer = nil
                    else
                        selectedPlayer = name
                    end
                    GLDG_SelPlrName = selectedPlayer
                    GLDG:RefreshConfigUI()
                end)
                row:AddChild(charLabel)

                local editBtn = AceGUI:Create("Button")
                editBtn:SetText((selectedPlayer == name) and (L["Close"] or CLOSE or "Close") or (L["Select"] or "Select"))
                editBtn:SetRelativeWidth(0.20)
                editBtn:SetCallback("OnClick", function()
                    if selectedPlayer == name then
                        selectedPlayer = nil
                    else
                        selectedPlayer = name
                    end
                    GLDG_SelPlrName = selectedPlayer
                    GLDG:RefreshConfigUI()
                end)
                row:AddChild(editBtn)

                listGroup:AddChild(row)
            end
        end
    end
end
