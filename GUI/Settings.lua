------------------------------------------------------------
-- GuildGreet Modern GUI - Settings Tab
-- Sub-tabs: General, Chat, Greeting, Other
------------------------------------------------------------

local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", true)
local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
GuildGreet = GLDG

local UIStyle = GLDG.UIStyle
local activeSubTab = "general"

local function GetCharKey()
    local realm = GLDG.Realm or GetRealmName() or ""
    local player = GLDG.Player or UnitName("player") or ""
    return realm .. " - " .. player
end

local function GetChatFrameKey()
    local realm = GLDG.Realm or GetRealmName() or ""
    local player = GLDG.Player or UnitName("player") or ""
    return player .. "-" .. realm
end

local function SyncGuildSettings()
    if GLDG.Core and GLDG.Core.generateConfigString then
        GLDG.Core:generateConfigString()
    end
end

local function BuildGeneralSubTab(scroll)
    local gs = GLDG_Data.GuildSettings

    -- Guild Default Configuration Group
    local guildGroup = AceGUI:Create("InlineGroup")
    guildGroup:SetTitle(L["Guild Default Settings"] or "Guild Default Settings")
    guildGroup:SetFullWidth(true)
    guildGroup:SetLayout("Flow")
    scroll:AddChild(guildGroup)

    local useGuildDefault = AceGUI:Create("CheckBox")
    useGuildDefault:SetLabel(L["Read the guildsettings from the guild info |cFFFF0000You must reload your interface after change this manually!"] or "Use Guild Info Default Settings")
    useGuildDefault:SetValue(gs.UseGuildDefault == true)
    useGuildDefault:SetRelativeWidth(0.65)
    useGuildDefault:SetCallback("OnValueChanged", function(_, _, val)
        GLDG_readConfigString_change(val and true or false)
        GLDG:RefreshConfigUI()
    end)
    guildGroup:AddChild(useGuildDefault)

    if IsGuildLeader and IsGuildLeader() then
        local writeGuildBtn = AceGUI:Create("Button")
        writeGuildBtn:SetText(L["Write the config string"] or "Write Guild Info String")
        writeGuildBtn:SetRelativeWidth(0.35)
        writeGuildBtn:SetCallback("OnClick", function()
            SyncGuildSettings()
            GLDG_WriteGuildString()
        end)
        guildGroup:AddChild(writeGuildBtn)
    end

    -- Greeting Behavior Group
    local greetGroup = AceGUI:Create("InlineGroup")
    greetGroup:SetTitle(L["Basic Settings"] or "Greeting Behavior")
    greetGroup:SetFullWidth(true)
    greetGroup:SetLayout("Flow")
    scroll:AddChild(greetGroup)

    local greetAsMain = AceGUI:Create("CheckBox")
    greetAsMain:SetLabel(L["Greet alts with the same name as main by default"] or "Greet Alts with Main's name by default")
    greetAsMain:SetValue(gs.GreetAsMain == true)
    greetAsMain:SetFullWidth(true)
    greetAsMain:SetDisabled(gs.UseGuildDefault == true)
    greetAsMain:SetCallback("OnValueChanged", function(_, _, val)
        gs.GreetAsMain = val and true or false
        SyncGuildSettings()
    end)
    greetGroup:AddChild(greetAsMain)

    local randomize = AceGUI:Create("CheckBox")
    randomize:SetLabel(L["Randomly use alias and or main and alt names"] or "Randomize character & alias names when greeting")
    randomize:SetValue(gs.Randomize == true)
    randomize:SetFullWidth(true)
    randomize:SetDisabled(gs.UseGuildDefault == true)
    randomize:SetCallback("OnValueChanged", function(_, _, val)
        gs.Randomize = val and true or false
        SyncGuildSettings()
    end)
    greetGroup:AddChild(randomize)

    local whisper = AceGUI:Create("CheckBox")
    whisper:SetLabel(L["Whisper greetings and grats to players"] or "Always whisper greetings to players")
    whisper:SetValue(gs.Whisper == true)
    whisper:SetFullWidth(true)
    whisper:SetDisabled(gs.UseGuildDefault == true)
    whisper:SetCallback("OnValueChanged", function(_, _, val)
        gs.Whisper = val and true or false
        SyncGuildSettings()
    end)
    greetGroup:AddChild(whisper)

    local whisperLvl = AceGUI:Create("CheckBox")
    whisperLvl:SetLabel(L["Whisper level up messages"] or "Whisper level-up congratulations")
    whisperLvl:SetValue(gs.WhisperLevelup == true)
    whisperLvl:SetFullWidth(true)
    whisperLvl:SetDisabled(gs.UseGuildDefault == true)
    whisperLvl:SetCallback("OnValueChanged", function(_, _, val)
        gs.WhisperLevelup = val and true or false
        SyncGuildSettings()
    end)
    greetGroup:AddChild(whisperLvl)

    local includeOwn = AceGUI:Create("CheckBox")
    includeOwn:SetLabel(L["Display your own characters"] or "Display own characters in player list & notifications")
    includeOwn:SetValue(gs.IncludeOwn == true)
    includeOwn:SetFullWidth(true)
    includeOwn:SetDisabled(gs.UseGuildDefault == true)
    includeOwn:SetCallback("OnValueChanged", function(_, _, val)
        gs.IncludeOwn = val and true or false
        SyncGuildSettings()
    end)
    greetGroup:AddChild(includeOwn)

    local relogSlider = AceGUI:Create("Slider")
    relogSlider:SetLabel(L["Relog Suppression Time (Minutes)"] or "Relog Suppression Time (Minutes)")
    relogSlider:SetSliderValues(0, 60, 1)
    relogSlider:SetValue(tonumber(gs.RelogTime) or 2)
    relogSlider:SetRelativeWidth(0.5)
    relogSlider:SetDisabled(gs.UseGuildDefault == true)
    relogSlider:SetCallback("OnValueChanged", function(_, _, val)
        gs.RelogTime = math.floor(val)
        SyncGuildSettings()
    end)
    greetGroup:AddChild(relogSlider)

    local minLevelSlider = AceGUI:Create("Slider")
    minLevelSlider:SetLabel(L["Minimum Level for Level-Up Grats"] or "Minimum Level for Level-Up Grats")
    minLevelSlider:SetSliderValues(0, 80, 1)
    minLevelSlider:SetValue(tonumber(gs.MinLevelUp) or 0)
    minLevelSlider:SetRelativeWidth(0.5)
    minLevelSlider:SetDisabled(gs.UseGuildDefault == true)
    minLevelSlider:SetCallback("OnValueChanged", function(_, _, val)
        gs.MinLevelUp = math.floor(val)
        SyncGuildSettings()
    end)
    greetGroup:AddChild(minLevelSlider)

    -- Auto-Assignment from Guild Notes
    local assignGroup = AceGUI:Create("InlineGroup")
    assignGroup:SetTitle(L["Automatic Guild Note Parsing (Main / Alt / Alias)"] or "Automatic Guild Note Parsing (Main / Alt / Alias)")
    assignGroup:SetFullWidth(true)
    assignGroup:SetLayout("Flow")
    scroll:AddChild(assignGroup)

    local autoAssign = AceGUI:Create("CheckBox")
    autoAssign:SetLabel(L["Automatically assign main/alt based on guild note"] or "Automatically parse Main/Alt from Guild Notes")
    autoAssign:SetValue(gs.AutoAssign == true)
    autoAssign:SetFullWidth(true)
    autoAssign:SetDisabled(gs.UseGuildDefault == true)
    autoAssign:SetCallback("OnValueChanged", function(_, _, val)
        gs.AutoAssign = val and true or false
        if val then gs.AutoAssignEgp = false end
        SyncGuildSettings()
        GLDG:RefreshConfigUI()
    end)
    assignGroup:AddChild(autoAssign)

    local autoAssignEgp = AceGUI:Create("CheckBox")
    autoAssignEgp:SetLabel(L["(include EGP officer notes)"] or "Automatically parse Main/Alt (EPGP Officer Note)")
    autoAssignEgp:SetValue(gs.AutoAssignEgp == true)
    autoAssignEgp:SetFullWidth(true)
    autoAssignEgp:SetDisabled(gs.UseGuildDefault == true)
    autoAssignEgp:SetCallback("OnValueChanged", function(_, _, val)
        gs.AutoAssignEgp = val and true or false
        if val then gs.AutoAssign = false end
        SyncGuildSettings()
        GLDG:RefreshConfigUI()
    end)
    assignGroup:AddChild(autoAssignEgp)

    local autoAssignAlias = AceGUI:Create("CheckBox")
    autoAssignAlias:SetLabel(L["(Automatically assign Alias)"] or "Automatically assign Alias from Guild Notes")
    autoAssignAlias:SetValue(gs.AutoAssignAlias == true)
    autoAssignAlias:SetFullWidth(true)
    autoAssignAlias:SetDisabled(gs.UseGuildDefault == true)
    autoAssignAlias:SetCallback("OnValueChanged", function(_, _, val)
        gs.AutoAssignAlias = val and true or false
        SyncGuildSettings()
    end)
    assignGroup:AddChild(autoAssignAlias)

    -- Greeting Queue Frame Settings
    local queueGroup = AceGUI:Create("InlineGroup")
    queueGroup:SetTitle(L["Configuration options for displaying the players waiting for a greeting"] or "Greeting Queue Window (In-Game List)")
    queueGroup:SetFullWidth(true)
    queueGroup:SetLayout("Flow")
    scroll:AddChild(queueGroup)

    local listVisible = AceGUI:Create("CheckBox")
    listVisible:SetLabel(L["List header is always visible"] or "Always show Greeting Queue header even when empty")
    listVisible:SetValue(GLDG_Data.ListVisible == true)
    listVisible:SetFullWidth(true)
    listVisible:SetCallback("OnValueChanged", function(_, _, val)
        GLDG_Data.ListVisible = val and true or false
        GLDG:ShowQueue()
    end)
    queueGroup:AddChild(listVisible)

    local listUp = AceGUI:Create("CheckBox")
    listUp:SetLabel(L["List grows upwards instead of downwards"] or "Grow Greeting Queue upward instead of downward")
    listUp:SetValue(GLDG_Data.ListUp == true)
    listUp:SetFullWidth(true)
    listUp:SetCallback("OnValueChanged", function(_, _, val)
        GLDG_Data.ListUp = val and true or false
        GLDG:ShowQueue()
    end)
    queueGroup:AddChild(listUp)

    local listSize = AceGUI:Create("Slider")
    listSize:SetLabel(L["Maximum Visible Queued Players (1 - 15)"] or "Maximum Visible Queued Players (1 - 15)")
    listSize:SetSliderValues(1, 15, 1)
    listSize:SetValue(tonumber(GLDG_Data.ListSize) or 5)
    listSize:SetFullWidth(true)
    listSize:SetCallback("OnValueChanged", function(_, _, val)
        GLDG_Data.ListSize = math.floor(val)
        GLDG:ShowQueue()
    end)
    queueGroup:AddChild(listSize)
end

local function BuildChatSubTab(scroll)
    local gs = GLDG_Data.GuildSettings

    local notifyGroup = AceGUI:Create("InlineGroup")
    notifyGroup:SetTitle(L["Chat Status Notifications"] or "Chat Status Notifications")
    notifyGroup:SetFullWidth(true)
    notifyGroup:SetLayout("Flow")
    scroll:AddChild(notifyGroup)

    local listNames = AceGUI:Create("CheckBox")
    listNames:SetLabel(L["List alt and main names when player logs in"] or "Print info in chat when player comes online")
    listNames:SetValue(gs.ListNames == true)
    listNames:SetFullWidth(true)
    listNames:SetDisabled(gs.UseGuildDefault == true)
    listNames:SetCallback("OnValueChanged", function(_, _, val)
        gs.ListNames = val and true or false
        SyncGuildSettings()
    end)
    notifyGroup:AddChild(listNames)

    local listNamesOff = AceGUI:Create("CheckBox")
    listNamesOff:SetLabel(L["List alt and main names when player logs off"] or "Print info in chat when player goes offline")
    listNamesOff:SetValue(gs.ListNamesOff == true)
    listNamesOff:SetFullWidth(true)
    listNamesOff:SetDisabled(gs.UseGuildDefault == true)
    listNamesOff:SetCallback("OnValueChanged", function(_, _, val)
        gs.ListNamesOff = val and true or false
        SyncGuildSettings()
    end)
    notifyGroup:AddChild(listNamesOff)

    local listLevelUp = AceGUI:Create("CheckBox")
    listLevelUp:SetLabel(L["List to chat when a player levels up (online only)"] or "Print info in chat when online player levels up")
    listLevelUp:SetValue(gs.ListLevelUp == true)
    listLevelUp:SetFullWidth(true)
    listLevelUp:SetDisabled(gs.UseGuildDefault == true)
    listLevelUp:SetCallback("OnValueChanged", function(_, _, val)
        gs.ListLevelUp = val and true or false
        SyncGuildSettings()
    end)
    notifyGroup:AddChild(listLevelUp)

    local listLevelUpOff = AceGUI:Create("CheckBox")
    listLevelUpOff:SetLabel(L["List to chat when a player levels up (offline players, printed when you log in)"] or "Print info for players who leveled while offline")
    listLevelUpOff:SetValue(gs.ListLevelUpOff == true)
    listLevelUpOff:SetFullWidth(true)
    listLevelUpOff:SetDisabled(gs.UseGuildDefault == true)
    listLevelUpOff:SetCallback("OnValueChanged", function(_, _, val)
        gs.ListLevelUpOff = val and true or false
        SyncGuildSettings()
    end)
    notifyGroup:AddChild(listLevelUpOff)

    local listAchiev = AceGUI:Create("CheckBox")
    listAchiev:SetLabel(L["Show achievments of guild members with main/alt in chat"] or "Print main name when an alt earns an achievement")
    listAchiev:SetValue(gs.ListAchievments == true)
    listAchiev:SetFullWidth(true)
    listAchiev:SetDisabled(gs.UseGuildDefault == true)
    listAchiev:SetCallback("OnValueChanged", function(_, _, val)
        gs.ListAchievments = val and true or false
        SyncGuildSettings()
    end)
    notifyGroup:AddChild(listAchiev)

    local listQuit = AceGUI:Create("CheckBox")
    listQuit:SetLabel(L["List to chat when a player leaves the guild"] or "Print notification when a member leaves the guild")
    listQuit:SetValue(gs.ListQuit == true)
    listQuit:SetFullWidth(true)
    listQuit:SetDisabled(gs.UseGuildDefault == true)
    listQuit:SetCallback("OnValueChanged", function(_, _, val)
        gs.ListQuit = val and true or false
        SyncGuildSettings()
    end)
    notifyGroup:AddChild(listQuit)

    -- Chat Name Extension Group
    local extendGroup = AceGUI:Create("InlineGroup")
    extendGroup:SetTitle(L["Chat Message Name Extension"] or "Chat Message Name Extension")
    extendGroup:SetFullWidth(true)
    extendGroup:SetLayout("Flow")
    scroll:AddChild(extendGroup)

    local extendChat = AceGUI:Create("CheckBox")
    extendChat:SetLabel(L["Add main name to chat when an alt sends a message"] or "Append Main's name to Alt's chat messages")
    extendChat:SetValue(gs.ExtendChat == true)
    extendChat:SetFullWidth(true)
    extendChat:SetDisabled(gs.UseGuildDefault == true)
    extendChat:SetCallback("OnValueChanged", function(_, _, val)
        gs.ExtendChat = val and true or false
        SyncGuildSettings()
    end)
    extendGroup:AddChild(extendChat)

    local extendMain = AceGUI:Create("CheckBox")
    extendMain:SetLabel(L["Even re-add main name for main char (if the above option is enabled)"] or "Also append Main/Alias info to Main characters")
    extendMain:SetValue(gs.ExtendMain == true)
    extendMain:SetFullWidth(true)
    extendMain:SetDisabled(gs.UseGuildDefault == true)
    extendMain:SetCallback("OnValueChanged", function(_, _, val)
        gs.ExtendMain = val and true or false
        SyncGuildSettings()
    end)
    extendGroup:AddChild(extendMain)

    local extendAlias = AceGUI:Create("CheckBox")
    extendAlias:SetLabel(L["Add main's alias to chat (if it exists and the above option is enabled)"] or "Use Main's Alias instead of Main's character name")
    extendAlias:SetValue(gs.ExtendAlias == true)
    extendAlias:SetFullWidth(true)
    extendAlias:SetDisabled(gs.UseGuildDefault == true)
    extendAlias:SetCallback("OnValueChanged", function(_, _, val)
        gs.ExtendAlias = val and true or false
        SyncGuildSettings()
    end)
    extendGroup:AddChild(extendAlias)

    local extendIgnored = AceGUI:Create("CheckBox")
    extendIgnored:SetLabel(L["Add main name to chat when an alt sends a message, even if alt is ignored"] or "Also append Main info for ignored characters")
    extendIgnored:SetValue(gs.ExtendIgnored == true)
    extendIgnored:SetFullWidth(true)
    extendIgnored:SetDisabled(gs.UseGuildDefault == true)
    extendIgnored:SetCallback("OnValueChanged", function(_, _, val)
        gs.ExtendIgnored = val and true or false
        SyncGuildSettings()
    end)
    extendGroup:AddChild(extendIgnored)

    local addPostfix = AceGUI:Create("CheckBox")
    addPostfix:SetLabel(L["Show source of character info in curly braces when printing names to chat"] or "Show source tag ({g}, {f}, {c}) in chat notifications")
    addPostfix:SetValue(gs.AddPostfix == true)
    addPostfix:SetFullWidth(true)
    addPostfix:SetDisabled(gs.UseGuildDefault == true)
    addPostfix:SetCallback("OnValueChanged", function(_, _, val)
        gs.AddPostfix = val and true or false
        SyncGuildSettings()
    end)
    extendGroup:AddChild(addPostfix)

    local showWhoSpam = AceGUI:Create("CheckBox")
    showWhoSpam:SetLabel(L["Show /who request and response text in chat"] or "Show /who query notifications in chat")
    showWhoSpam:SetValue(gs.ShowWhoSpam == true)
    showWhoSpam:SetFullWidth(true)
    showWhoSpam:SetDisabled(gs.UseGuildDefault == true)
    showWhoSpam:SetCallback("OnValueChanged", function(_, _, val)
        gs.ShowWhoSpam = val and true or false
        SyncGuildSettings()
    end)
    extendGroup:AddChild(showWhoSpam)

    -- Output Chat Frame Selection
    local frameGroup = AceGUI:Create("InlineGroup")
    frameGroup:SetTitle(L["Output Chat Window"] or "Output Chat Window")
    frameGroup:SetFullWidth(true)
    frameGroup:SetLayout("Flow")
    scroll:AddChild(frameGroup)

    local chatFrames = { [0] = L["Using default chat frame"] or "Default Chat Frame" }
    for i = 1, (NUM_CHAT_WINDOWS or 10) do
        local name, _, _, _, _, _, shown, _, docked = GetChatWindowInfo(i)
        if name and name ~= "" and (shown or docked) then
            chatFrames[i] = string.format("ChatFrame %d (%s)", i, name)
        end
    end

    local cfKey = GetChatFrameKey()
    local cfDrop = AceGUI:Create("Dropdown")
    cfDrop:SetLabel(L["Redirect GuildGreet Output To"] or "Redirect GuildGreet Output To")
    cfDrop:SetList(chatFrames)
    cfDrop:SetValue(tonumber(GLDG_Data.PlayerChatFrame[cfKey]) or 0)
    cfDrop:SetFullWidth(true)
    cfDrop:SetCallback("OnValueChanged", function(_, _, val)
        GLDG_Data.PlayerChatFrame[cfKey] = tonumber(val) or 0
    end)
    frameGroup:AddChild(cfDrop)
end

local function BuildGreetingSubTab(scroll)
    local gs = GLDG_Data.GuildSettings
    local charKey = GetCharKey()

    local supGroup = AceGUI:Create("InlineGroup")
    supGroup:SetTitle(L["Greeting Trigger Suppression"] or "Greeting Trigger Suppression")
    supGroup:SetFullWidth(true)
    supGroup:SetLayout("Flow")
    scroll:AddChild(supGroup)

    local supGreet = AceGUI:Create("CheckBox")
    supGreet:SetLabel(L["Don't put players coming online on the greet list"] or "Suppress online/relog greetings")
    supGreet:SetValue(gs.SupressGreet == true)
    supGreet:SetFullWidth(true)
    supGreet:SetDisabled(gs.UseGuildDefault == true)
    supGreet:SetCallback("OnValueChanged", function(_, _, val)
        gs.SupressGreet = val and true or false
        SyncGuildSettings()
    end)
    supGroup:AddChild(supGreet)

    local supJoin = AceGUI:Create("CheckBox")
    supJoin:SetLabel(L["Don't put players joining the guild on the greet list"] or "Suppress welcome greetings for new guild members")
    supJoin:SetValue(gs.SupressJoin == true)
    supJoin:SetFullWidth(true)
    supJoin:SetDisabled(gs.UseGuildDefault == true)
    supJoin:SetCallback("OnValueChanged", function(_, _, val)
        gs.SupressJoin = val and true or false
        SyncGuildSettings()
    end)
    supGroup:AddChild(supJoin)

    local supLevel = AceGUI:Create("CheckBox")
    supLevel:SetLabel(L["Don't put players that level up on the greet list"] or "Suppress level-up congratulations")
    supLevel:SetValue(gs.SupressLevel == true)
    supLevel:SetFullWidth(true)
    supLevel:SetDisabled(gs.UseGuildDefault == true)
    supLevel:SetCallback("OnValueChanged", function(_, _, val)
        gs.SupressLevel = val and true or false
        SyncGuildSettings()
    end)
    supGroup:AddChild(supLevel)

    local supRank = AceGUI:Create("CheckBox")
    supRank:SetLabel(L["Don't put players that get promoted on the greet list"] or "Suppress rank promotion congratulations")
    supRank:SetValue(gs.SupressRank == true)
    supRank:SetFullWidth(true)
    supRank:SetDisabled(gs.UseGuildDefault == true)
    supRank:SetCallback("OnValueChanged", function(_, _, val)
        gs.SupressRank = val and true or false
        SyncGuildSettings()
    end)
    supGroup:AddChild(supRank)

    local supAchiev = AceGUI:Create("CheckBox")
    supAchiev:SetLabel(L["Don't put players that get achievments on the greet list"] or "Suppress achievement congratulations")
    supAchiev:SetValue(gs.SupressAchievment == true)
    supAchiev:SetFullWidth(true)
    supAchiev:SetDisabled(gs.UseGuildDefault == true)
    supAchiev:SetCallback("OnValueChanged", function(_, _, val)
        gs.SupressAchievment = val and true or false
        SyncGuildSettings()
    end)
    supGroup:AddChild(supAchiev)

    local noGratsOnLogin = AceGUI:Create("CheckBox")
    noGratsOnLogin:SetLabel(L["Don't congratulate players that just logged in"] or "Do not queue offline level-up/promo on login")
    noGratsOnLogin:SetValue(gs.NoGratsOnLogin == true)
    noGratsOnLogin:SetFullWidth(true)
    noGratsOnLogin:SetDisabled(gs.UseGuildDefault == true)
    noGratsOnLogin:SetCallback("OnValueChanged", function(_, _, val)
        gs.NoGratsOnLogin = val and true or false
        SyncGuildSettings()
    end)
    supGroup:AddChild(noGratsOnLogin)

    local supAllBtn = AceGUI:Create("Button")
    supAllBtn:SetText(L["Supress all"] or "Suppress All")
    supAllBtn:SetRelativeWidth(0.5)
    supAllBtn:SetDisabled(gs.UseGuildDefault == true)
    supAllBtn:SetCallback("OnClick", function()
        gs.SupressGreet = true
        gs.SupressJoin = true
        gs.SupressLevel = true
        gs.SupressRank = true
        gs.SupressAchievment = true
        SyncGuildSettings()
        GLDG:RefreshConfigUI()
    end)
    supGroup:AddChild(supAllBtn)

    local supNoneBtn = AceGUI:Create("Button")
    supNoneBtn:SetText(L["Supress none"] or "Enable All Greetings")
    supNoneBtn:SetRelativeWidth(0.5)
    supNoneBtn:SetDisabled(gs.UseGuildDefault == true)
    supNoneBtn:SetCallback("OnClick", function()
        gs.SupressGreet = false
        gs.SupressJoin = false
        gs.SupressLevel = false
        gs.SupressRank = false
        gs.SupressAchievment = false
        SyncGuildSettings()
        GLDG:RefreshConfigUI()
    end)
    supGroup:AddChild(supNoneBtn)

    -- Per-Character Auto-Greeting & Keybind Targets
    local charGroup = AceGUI:Create("InlineGroup")
    charGroup:SetTitle((L["Greeting the guild and channel (per character setting)"] or "Character Greeting & Keybind Targets") .. " (" .. charKey .. ")")
    charGroup:SetFullWidth(true)
    charGroup:SetLayout("Flow")
    scroll:AddChild(charGroup)

    GLDG_Data.AutoGreet = GLDG_Data.AutoGreet or {}
    GLDG_Data.GreetGuild = GLDG_Data.GreetGuild or {}
    GLDG_Data.GreetChannel = GLDG_Data.GreetChannel or {}

    local autoGreetBox = AceGUI:Create("CheckBox")
    autoGreetBox:SetLabel(L["Automatically greet guild and/or channel when logging in (depends on settings below)"] or "Automatically greet Guild / Channel when logging in")
    autoGreetBox:SetValue(GLDG_Data.AutoGreet[charKey] == true)
    autoGreetBox:SetFullWidth(true)
    autoGreetBox:SetCallback("OnValueChanged", function(_, _, val)
        GLDG_Data.AutoGreet[charKey] = val and true or false
    end)
    charGroup:AddChild(autoGreetBox)

    local greetGuildBox = AceGUI:Create("CheckBox")
    greetGuildBox:SetLabel(L["Greet Guild and Channel"] or "Include Guild in Greet / Bye / Later keybinds & buttons")
    greetGuildBox:SetValue(GLDG_Data.GreetGuild[charKey] == true)
    greetGuildBox:SetFullWidth(true)
    greetGuildBox:SetCallback("OnValueChanged", function(_, _, val)
        GLDG_Data.GreetGuild[charKey] = val and true or false
    end)
    charGroup:AddChild(greetGuildBox)

    local greetChanBox = AceGUI:Create("CheckBox")
    greetChanBox:SetLabel(L["Channel"] or "Include Channel in Greet / Bye / Later keybinds & buttons")
    greetChanBox:SetValue(GLDG_Data.GreetChannel[charKey] == true)
    greetChanBox:SetFullWidth(true)
    greetChanBox:SetCallback("OnValueChanged", function(_, _, val)
        GLDG_Data.GreetChannel[charKey] = val and true or false
    end)
    charGroup:AddChild(greetChanBox)

    -- Guild Alias Group
    local aliasGroup = AceGUI:Create("InlineGroup")
    aliasGroup:SetTitle(L["Can set guild alias"] or "Guild Alias (Used for %g / %G placeholders)")
    aliasGroup:SetFullWidth(true)
    aliasGroup:SetLayout("Flow")
    scroll:AddChild(aliasGroup)

    local aliasInput = AceGUI:Create("EditBox")
    aliasInput:SetLabel((L["Guild alias for: "] or "Guild Alias for ") .. tostring(GLDG.GuildName or "Current Guild"))
    aliasInput:SetText(tostring(GLDG_GuildAlias or ""))
    aliasInput:SetRelativeWidth(0.7)
    aliasInput:SetCallback("OnEnterPressed", function(_, _, text)
        text = strtrim(text or "")
        if text == "" then
            GLDG_GuildAlias = GLDG_unique_GuildName or ""
        else
            GLDG_GuildAlias = text
        end
        if GLDG_unique_GuildName and GLDG_unique_GuildName ~= "" then
            GLDG_Data.GuildAlias[GLDG_unique_GuildName] = GLDG_GuildAlias
        end
        GLDG:RefreshConfigUI()
    end)
    aliasGroup:AddChild(aliasInput)

    local clearAliasBtn = AceGUI:Create("Button")
    clearAliasBtn:SetText(L["Clear"] or "Reset to Guild Name")
    clearAliasBtn:SetRelativeWidth(0.3)
    clearAliasBtn:SetCallback("OnClick", function()
        GLDG_GuildAlias = GLDG_unique_GuildName or ""
        if GLDG_unique_GuildName and GLDG_unique_GuildName ~= "" then
            GLDG_Data.GuildAlias[GLDG_unique_GuildName] = GLDG_GuildAlias
        end
        GLDG:RefreshConfigUI()
    end)
    aliasGroup:AddChild(clearAliasBtn)
end

local function BuildOtherSubTab(scroll)
    local gs = GLDG_Data.GuildSettings
    local realm = GLDG.Realm or GetRealmName() or ""

    local trackGroup = AceGUI:Create("InlineGroup")
    trackGroup:SetTitle(L["Configuration options for managing optimized GuildRoster calls and channel"] or "Friends, Channel & Roster Polling")
    trackGroup:SetFullWidth(true)
    trackGroup:SetLayout("Flow")
    scroll:AddChild(trackGroup)

    local useFriends = AceGUI:Create("CheckBox")
    useFriends:SetLabel(L["Manage friend's list"] or "Track Friends List in addition to Guild")
    useFriends:SetValue(GLDG_Data.UseFriends == true)
    useFriends:SetFullWidth(true)
    useFriends:SetCallback("OnValueChanged", function(_, _, val)
        GLDG_Data.UseFriends = val and true or false
        if val and C_FriendList and C_FriendList.ShowFriends then
            C_FriendList.ShowFriends()
        end
    end)
    trackGroup:AddChild(useFriends)

    local autoWho = AceGUI:Create("CheckBox")
    autoWho:SetLabel(L["Automatically start /who request when channel member with lacking info logs on"] or "Auto /who query for channel members with unknown info")
    autoWho:SetValue(GLDG_Data.AutoWho == true)
    autoWho:SetFullWidth(true)
    autoWho:SetCallback("OnValueChanged", function(_, _, val)
        GLDG_Data.AutoWho = val and true or false
    end)
    trackGroup:AddChild(autoWho)

    local chanEdit = AceGUI:Create("EditBox")
    chanEdit:SetLabel((L["Channel name to monitor"] or "Monitored Custom Channel Name") .. " (" .. realm .. ")")
    chanEdit:SetText(tostring(GLDG_Data.ChannelNames and GLDG_Data.ChannelNames[realm] or ""))
    chanEdit:SetRelativeWidth(0.5)
    chanEdit:SetCallback("OnEnterPressed", function(_, _, text)
        text = strtrim(text or "")
        GLDG_Data.ChannelNames = GLDG_Data.ChannelNames or {}
        if text == "" then
            GLDG_Data.ChannelNames[realm] = nil
        else
            GLDG_Data.ChannelNames[realm] = text
        end
        GLDG_CheckChannel()
    end)
    trackGroup:AddChild(chanEdit)

    local updateSlider = AceGUI:Create("Slider")
    updateSlider:SetLabel(L["Roster Poll Interval in Seconds (0 = Event-Only)"] or "Roster Poll Interval in Seconds (0 = Event-Only)")
    updateSlider:SetSliderValues(0, 300, 5)
    updateSlider:SetValue(tonumber(GLDG_Data.UpdateTime) or 0)
    updateSlider:SetRelativeWidth(0.5)
    updateSlider:SetCallback("OnValueChanged", function(_, _, val)
        GLDG_Data.UpdateTime = math.floor(val)
    end)
    trackGroup:AddChild(updateSlider)

    -- System & Addon Features
    local sysGroup = AceGUI:Create("InlineGroup")
    sysGroup:SetTitle(L["Various settings"] or "System & AddOn Options")
    sysGroup:SetFullWidth(true)
    sysGroup:SetLayout("Flow")
    scroll:AddChild(sysGroup)

    local deltaPopup = AceGUI:Create("CheckBox")
    deltaPopup:SetLabel(L["Show popup box summarising offline changes at login"] or "Show summary popup of offline changes at login")
    deltaPopup:SetValue(gs.DeltaPopup == true)
    deltaPopup:SetFullWidth(true)
    deltaPopup:SetDisabled(gs.UseGuildDefault == true)
    deltaPopup:SetCallback("OnValueChanged", function(_, _, val)
        gs.DeltaPopup = val and true or false
        SyncGuildSettings()
    end)
    sysGroup:AddChild(deltaPopup)

    local useLocalTime = AceGUI:Create("CheckBox")
    useLocalTime:SetLabel(L["Use local time instead of server time"] or "Use Local Computer Time instead of Server Time")
    useLocalTime:SetValue(GLDG_Data.UseLocalTime == true)
    useLocalTime:SetFullWidth(true)
    useLocalTime:SetCallback("OnValueChanged", function(_, _, val)
        GLDG_Data.UseLocalTime = val and true or false
    end)
    sysGroup:AddChild(useLocalTime)

    local showNewer = AceGUI:Create("CheckBox")
    showNewer:SetLabel(L["Show if newer versions of addons are available"] or "Notify when a newer GuildGreet version is detected")
    showNewer:SetValue(GLDG_Data.ShowNewerVersions ~= false)
    showNewer:SetFullWidth(true)
    showNewer:SetCallback("OnValueChanged", function(_, _, val)
        GLDG_Data.ShowNewerVersions = val and true or false
    end)
    sysGroup:AddChild(showNewer)

    local fontSlider = AceGUI:Create("Slider")
    fontSlider:SetLabel(L["UI Font Size (10 - 18 pt)"] or "UI Font Size (10 - 18 pt)")
    fontSlider:SetSliderValues(UIStyle.MIN_FONT_SIZE or 10, UIStyle.MAX_FONT_SIZE or 18, 1)
    fontSlider:SetValue(UIStyle:GetFontSize())
    fontSlider:SetRelativeWidth(0.5)
    fontSlider:SetCallback("OnValueChanged", function(_, _, val)
        UIStyle:SetFontSize(math.floor(val + 0.5))
    end)
    sysGroup:AddChild(fontSlider)

    local LDBIcon = LibStub("LibDBIcon-1.0", true)
    if LDBIcon then
        GLDG.db.profile.minimap = GLDG.db.profile.minimap or { hide = false }
        local minimapToggle = AceGUI:Create("CheckBox")
        minimapToggle:SetLabel(L["Show Minimap Button"] or "Show Minimap Button")
        minimapToggle:SetValue(not GLDG.db.profile.minimap.hide)
        minimapToggle:SetRelativeWidth(0.5)
        minimapToggle:SetCallback("OnValueChanged", function(_, _, val)
            GLDG.db.profile.minimap.hide = not val
            if val then
                LDBIcon:Show("GuildGreet")
            else
                LDBIcon:Hide("GuildGreet")
            end
        end)
        sysGroup:AddChild(minimapToggle)
    end
end

function GLDG:CreateSettingsTab(container)
    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")
    tabGroup:SetFullWidth(true)
    tabGroup:SetFullHeight(true)
    tabGroup:SetTabs({
        { text = L["General"] or "General",   value = "general" },
        { text = L["Chat"] or "Chat",         value = "chat" },
        { text = L["Greeting"] or "Greeting", value = "greeting" },
        { text = L["Other"] or "Other",       value = "other" },
    })

    tabGroup:SetCallback("OnGroupSelected", function(group, _, subtab)
        activeSubTab = subtab
        group:ReleaseChildren()

        local scroll = AceGUI:Create("ScrollFrame")
        scroll:SetLayout("Flow")
        scroll:SetFullWidth(true)
        scroll:SetFullHeight(true)
        group:AddChild(scroll)

        if subtab == "general" then
            BuildGeneralSubTab(scroll)
        elseif subtab == "chat" then
            BuildChatSubTab(scroll)
        elseif subtab == "greeting" then
            BuildGreetingSubTab(scroll)
        elseif subtab == "other" then
            BuildOtherSubTab(scroll)
        end

        UIStyle:StyleAceWidgetsRecursive(group)
    end)

    container:AddChild(tabGroup)
    tabGroup:SelectTab(activeSubTab or "general")
end
