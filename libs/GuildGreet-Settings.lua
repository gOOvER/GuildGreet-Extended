------------------------------------------------------------
-- GuildGreet Settings Library
-- Handles addon configuration, player settings and guild management
------------------------------------------------------------

-- Ensure GLDG exists (defensive loading for library modules)
GLDG = GLDG or {}
GLDG.Settings = {}

------------------------------------------------------------
-- Settings Update Functions
------------------------------------------------------------

function GLDG.Settings:UpdateRelog(self)
	-- Store the new value
	GLDG_Data.GuildSettings.RelogTime = self:GetValue()
	-- Update display
	local text = _G[self:GetParent():GetName().."RelogText"]
	if (GLDG_Data.GuildSettings.RelogTime == 0) then 
		text:SetText(L["Always show relogs"].."*")
	else 
		text:SetText(string.format(L["Only show relogs after more then %d min"], GLDG_Data.GuildSettings.RelogTime)) 
	end
	if GLDG_unique_GuildName then 
		GLDG_generateConfigString() 
	end
end

function GLDG.Settings:UpdateMinLevelUp(self)
	-- Store the new value
	GLDG_Data.GuildSettings.MinLevelUp = self:GetValue()
	-- Update display
	local text = _G[self:GetParent():GetName().."MinLevelUpText"]
	if (GLDG_Data.GuildSettings.MinLevelUp == 0) then 
		text:SetText(L["Always show level-up"].."*")
	else 
		text:SetText(string.format(L["Only show level-up for levels above %d"], GLDG_Data.GuildSettings.MinLevelUp).."*") 
	end
	if GLDG_unique_GuildName then 
		GLDG_generateConfigString() 
	end
end

function GLDG.Settings:UpdateUpdateTime(self)
	-- Store the new value
	GLDG_Data.UpdateTime = self:GetValue() * 10
	-- Update display
	local text = _G[self:GetParent():GetName().."UpdateTimeText"]
	if (GLDG_Data.UpdateTime == 0) then
		text:SetText(L["Only update guild roster on events"])
	else
		text:SetText(string.format(L["Update guild roster every %d seconds"], GLDG_Data.UpdateTime))
	end

	if GLDG_InitialGuildUpdate then
		if (GLDG_Data.UpdateTime >= 0) then
			GLDG_UpdateRequest = GetTime() + GLDG_Data.UpdateTime
		else
			GLDG_UpdateRequest = nil
		end
	end
	if GLDG_InitialFriendsUpdate then
		if (GLDG_Data.UpdateTime >= 0) then
			GLDG_UpdateRequestFriends = GetTime() + GLDG_Data.UpdateTime
		else
			GLDG_UpdateRequestFriends = nil
		end
	end
end

------------------------------------------------------------
-- Suppress Settings Functions
------------------------------------------------------------

function GLDG.Settings:SupressAll()
	GLDG_Data.GuildSettings.SupressGreet = true
	GLDG_Data.GuildSettings.SupressJoin = true
	GLDG_Data.GuildSettings.SupressLevel = true
	GLDG_Data.GuildSettings.SupressRank = true
	GLDG_Data.GuildSettings.SupressAchievment = true

	GLDG_UpdateSupressed()
end

function GLDG.Settings:SupressNone()
	GLDG_Data.GuildSettings.SupressGreet = false
	GLDG_Data.GuildSettings.SupressJoin = false
	GLDG_Data.GuildSettings.SupressLevel = false
	GLDG_Data.GuildSettings.SupressRank = false
	GLDG_Data.GuildSettings.SupressAchievment = false

	GLDG_UpdateSupressed()
end

function GLDG.Settings:UpdateSupressed()
	local name = GLDG_GUI.."SettingsGreeting";
	_G[name.."SupressGreetBox"]:SetChecked(GLDG_Data.GuildSettings.SupressGreet)
	_G[name.."SupressJoinBox"]:SetChecked(GLDG_Data.GuildSettings.SupressJoin)
	_G[name.."SupressLevelBox"]:SetChecked(GLDG_Data.GuildSettings.SupressLevel)
	_G[name.."SupressRankBox"]:SetChecked(GLDG_Data.GuildSettings.SupressRank)
	_G[name.."SupressAchievmentBox"]:SetChecked(GLDG_Data.GuildSettings.SupressAchievment)
end

------------------------------------------------------------
-- Channel Settings Functions
------------------------------------------------------------

function GLDG.Settings:DropDown_Initialize()
	GLDG_dropDownData = {}

	local info
	info = UIDropDownMenu_CreateInfo();
	info.func = GLDG_DropDown_OnClick
	local j = 1

	for i = 0, 10 do
		local id, name = GetChannelName(i)
		if (i==0 or id>0 and name) then
			if (i==0) then
				name = L["<none>"]
			end

			info.checked = nil
			info.text = name
			UIDropDownMenu_AddButton(info);
			GLDG_dropDownData[j] = string.lower(name)
			if (string.lower(name) == GLDG_ChannelName) or
			   (name == L["<none>"] and GLDG_ChannelName=="") then
				UIDropDownMenu_SetSelectedID(_G[GLDG_GUI.."SettingsGeneral".."ChannelNameDropboxButton"], j);
			end
			j = j + 1
		end
	end
end

function GLDG.Settings:DropDown_OnClick(self)
	if not GLDG_dropDownData then GLDG_dropDownData = {} end
	local i = self:GetID();
	local name = GLDG_dropDownData[i]
	if not name then name = "" end
	if name == L["<none>"] then name = "" end
	name = string.lower(name)

	local oldChannelName = GLDG_ChannelName
	GLDG_ChannelName = name;
	if (GLDG_ChannelName == "") then
		GLDG_inChannel = false
	else
		if GLDG_CheckChannel() then
			UIDropDownMenu_SetSelectedID(_G[GLDG_GUI.."SettingsGeneral".."ChannelNameDropboxButton"], i);
		else
			GLDG_ChannelName = oldChannelName
			if GLDG_CheckChannel() then
				GLDG_Print(self:GetColors().help..GLDG_NAME..":|r Channel ["..GLDG_ChannelName.."] does not exist, setting back to ["..oldChannelName.."]")
			else
				GLDG_Print(self:GetColors().help..GLDG_NAME..":|r Channel ["..GLDG_ChannelName.."] does not exist, nor does the previous channel ["..oldChannelName.."], clearing channel name")
				UIDropDownMenu_SetSelectedID(_G[GLDG_GUI.."SettingsGeneral".."ChannelNameDropboxButton"], 1);
				GLDG_ChannelName = ""
				GLDG_inChannel = false
			end
		end
	end

	-- store new channel name
	if not GLDG_Data.ChannelNames[GLDG.Realm.." - "..GLDG.Player] then
		GLDG_Data.ChannelNames[GLDG.Realm.." - "..GLDG.Player] = ""
	end
	-- set channel name pointer
	GLDG_Data.ChannelNames[GLDG.Realm.." - "..GLDG.Player] = GLDG_ChannelName
end