------------------------------------------------------------
-- GuildGreet Modern GUI Initialization
-- Hooks GUI setup (Minimap button + Blizzard Options panel)
------------------------------------------------------------

local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
GuildGreet = GLDG

if GLDG and GLDG.RegisterSlashCommands then
    GLDG:RegisterSlashCommands()
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    if GLDG and GLDG.RegisterSlashCommands then
        GLDG:RegisterSlashCommands()
    end
    if GLDG and GLDG.InitializeGUI then
        GLDG:InitializeGUI()
    end
end)
