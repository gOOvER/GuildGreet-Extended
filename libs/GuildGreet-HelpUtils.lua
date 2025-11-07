------------------------------------------------------------
-- GuildGreet Help & Utilities Library  
-- Handles help system, startup functions and miscellaneous utilities
------------------------------------------------------------

GLDG.HelpUtils = {}

------------------------------------------------------------
-- Display comprehensive help information
function GLDG.HelpUtils:Help()
	GLDG:Print(" ")
	GLDG:Print(self:GetColors().help..GLDG_NAME..":|r "..L["A tool to manage mains and alts in the guild and greet them"])
	GLDG:Print(self:GetColors().help..L["Usage"]..":|r /gg guild "..self:GetColors().help.."[|rshow"..self:GetColors().help.."] | |rguild all "..self:GetColors().help.."| |rguild list")
	GLDG:Print(self:GetColors().help..L["Usage"]..":|r /gg char "..self:GetColors().help.."[|rshow"..self:GetColors().help.."] | |rchar all "..self:GetColors().help.."| |rchar list")
	GLDG:Print(self:GetColors().help..L["Usage"]..":|r /gg "..self:GetColors().help.."[|rshow"..self:GetColors().help.."] <|r"..L["name"]..self:GetColors().help.."> | |rfull "..self:GetColors().help.."<|r"..L["name"]..self:GetColors().help.."> | |rdetail "..self:GetColors().help.."<|r"..L["name"]..self:GetColors().help..">|r")
	GLDG_Print(self:GetColors().help..L["Usage"]..":|r /gg help "..self:GetColors().help.."| |rabout "..self:GetColors().help.."| |rconfig "..self:GetColors().help.."| |rtest", true)
	GLDG_Print(self:GetColors().help..L["Usage"]..":|r /gg clear", true)
	GLDG_Print(self:GetColors().help..L["Usage"]..":|r /gg check", true)
	GLDG_Print(self:GetColors().help..L["Usage"]..":|r /gg alert", true)
	GLDG_Print(self:GetColors().help..L["Usage"]..":|r /gg aliasreset", true)
	GLDG_Print(self:GetColors().help..L["Usage"]..":|r /gg greet "..self:GetColors().help.."| |rbye "..self:GetColors().help.."| |rlater "..self:GetColors().help.."[|r guild "..self:GetColors().help.."| |rchannel "..self:GetColors().help.."| |rall "..self:GetColors().help.."| <|rname"..self:GetColors().help.."> ]|r", true)
	GLDG_Print(" - "..self:GetColors().help.."guild/all [show]:|r "..L["List alts of all members to chat"], true);
	GLDG_Print(" - "..self:GetColors().help.."guild/all all:|r "..L["List alts of members that are online to chat"], true);
	GLDG_Print(" - "..self:GetColors().help.."guild/all list:|r "..L["List alts of all members for copying"], true);
	GLDG_Print(" - "..self:GetColors().help.."[show] <name>:|r "..L["List main and alts for <name>"], true);
	GLDG_Print(" - "..self:GetColors().help.."full <name>:|r "..L["List main and alts for <name> with full class and level info"], true);
	GLDG_Print(" - "..self:GetColors().help.."detail <name>:|r "..L["Print a dump of internal data for character <name> to chat"], true);
	GLDG_Print(" - "..self:GetColors().help.."clear:|r "..L["Clear the greet list without greeting anyone"], true);
	GLDG_Print(" - "..self:GetColors().help.."check:|r "..L["Check if main-alt assignments are correct"], true);
	GLDG_Print(" - "..self:GetColors().help.."alert:|r "..L["Check if |cFFFFFF7FGuild member notification|r is enabled"], true);
	GLDG_Print(" - "..L["without argument, show config frame"], true);
	GLDG_Print(" ", true)
end

------------------------------------------------------------
-- Startup check for initialization completion
function GLDG.HelpUtils:StartupCheck()
	-- are we done?
	if bit.band(GLDG_InitCheck, 7) == 0 and bit.band(GLDG_InitCheck, 56) ~= 0 then
		-- nothing pending and at least one complete -> assume we're done
		--GLDG_Print("All done")

		if (GLDG_TableSize(GLDG_ChangesText)>0 and GLDG_Data.GuildSettings.DeltaPopup==true) then
			-- display text
			GLDG_list = GLDG_ChangesText
			GLDG_CreatePasteListFrame()
			GLDG_PasteList.List:Show();
		end
		GLDG_ChangesText = nil
	end
end

------------------------------------------------------------
-- Add entry to startup changes list
function GLDG.HelpUtils:AddToStartupList(entry)
	if not GLDG_ChangesText then return end
	local index = GLDG_TableSize(GLDG_ChangesText) + 1
	GLDG_ChangesText[index] = entry
end

------------------------------------------------------------
-- Process who information for character tracking
function GLDG.HelpUtils:TreatWhoInfo(charname, guildname, level, class)
	if not charname then return end

	if GLDG_DataChar[charname] then
		result = L["Who results for"].." ["..tostring(charname).."] "
		if guildname and guildname ~= "" then
			GLDG_DataChar[charname].guild = guildname
			result = result.."<"..tostring(guildname)..">"
		end
		if level then
			GLDG_DataChar[charname].lvl = level
			result = result..", "..L["Level"].." "..tostring(level)
			-- handle level up check
		end
		if class then
			GLDG_DataChar[charname].class = class
			result = result..", "..tostring(class)
		end
		if (GLDG_Data.GuildSettings.ShowWhoSpam==true) then
			GLDG:PrintHelp(result)
		end
	end
end