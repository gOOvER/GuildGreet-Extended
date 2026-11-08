------------------------------------------------------------
-- GuildGreet Core Library
-- Handles addon core logic, configuration generation and system functions
------------------------------------------------------------

-- Ensure GLDG exists (defensive loading for library modules)
GLDG = GLDG or {}
GLDG.Core = {}

------------------------------------------------------------
-- Configuration string generation for guild settings
function GLDG.Core:generateConfigString()
	local a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z, az
	if GLDG_Data.GuildSettings.GreetAsMain==true then a = 1 else a=0 end
	if GLDG_Data.GuildSettings.Randomize==true then b = 2 else b=0 end
	if GLDG_Data.GuildSettings.Whisper==true then c = 2^2 else c=0 end
	if GLDG_Data.GuildSettings.WhisperLevelup==true then d = 2^3 else d=0 end
	if GLDG_Data.GuildSettings.IncludeOwn==true then e = 2^4 else e=0 end
	if GLDG_Data.GuildSettings.AutoAssign==true then f = 2^5 else f=0 end
	if GLDG_Data.GuildSettings.AutoAssignEgp==true then g = 2^6 else g=0 end
	if GLDG_Data.GuildSettings.AutoAssignAlias==true then h = 2^7 else h=0 end
	if GLDG_Data.GuildSettings.ListNames==true then i = 2^8 else i=0 end
	if GLDG_Data.GuildSettings.ListNamesOff==true then j = 2^9 else j=0 end
	if GLDG_Data.GuildSettings.ListLevelUp==true then k = 2^10 else k=0 end
	if GLDG_Data.GuildSettings.ListLevelUpOff==true then l = 2^11 else l=0 end
	if GLDG_Data.GuildSettings.ListAchievments==true then m = 2^12 else m=0 end
	if GLDG_Data.GuildSettings.ListQuit==true then n = 2^13 else n=0 end
	if GLDG_Data.GuildSettings.ExtendChat==true then o = 2^14 else o=0 end
	if GLDG_Data.GuildSettings.ExtendIgnored==true then p = 2^15 else p=0 end
	if GLDG_Data.GuildSettings.ExtendMain==true then q = 2^16 else q=0 end
	if GLDG_Data.GuildSettings.ExtendAlias==true then r = 2^17 else r=0 end
	if GLDG_Data.GuildSettings.AddPostfix==true then s = 2^18 else s=0 end
	if GLDG_Data.GuildSettings.ShowWhoSpam==true then t = 2^19 else t=0 end
	if GLDG_Data.GuildSettings.SupressGreet==true then u = 2^20 else u=0 end
	if GLDG_Data.GuildSettings.SupressJoin==true then v = 2^21 else v=0 end
	if GLDG_Data.GuildSettings.SupressLevel==true then w = 2^22 else w=0 end
	if GLDG_Data.GuildSettings.SupressRank==true then x = 2^23 else x=0 end
	if GLDG_Data.GuildSettings.SupressAchievment==true then y = 2^24 else y=0 end
	if GLDG_Data.GuildSettings.NoGratsOnLogin==true then z = 2^25 else z=0 end
	if GLDG_Data.GuildSettings.DeltaPopup == true then az = 2^26 else az=0 end
	if GLDG_Data.GuildSettings.RelogTime then GLDG_CONFIG_STRING_B = string.format("%x",math.floor(GLDG_Data.GuildSettings.RelogTime)) end
	if GLDG_Data.GuildSettings.MinLevelUp then GLDG_CONFIG_STRING_C = string.format("%x",math.floor(GLDG_Data.GuildSettings.MinLevelUp)) end
	GLDG_CONFIG_STRING_A = string.format("%x",a+b+c+d+e+f+g+h+i+j+k+l+m+n+o+p+q+r+s+t+u+v+w+x+y+z+az)
	GLDG_CONFIG_STRING_D = mod((tonumber("0x"..GLDG_CONFIG_STRING_A, 16)+1) * (tonumber("0x"..GLDG_CONFIG_STRING_B, 16)+1) * (tonumber("0x"..GLDG_CONFIG_STRING_C, 16)+1),33)
	GLDG_CONFIG_STRING = "{GG:"..GLDG_CONFIG_STRING_A..":"..GLDG_CONFIG_STRING_B..":"..GLDG_CONFIG_STRING_C..":"..GLDG_CONFIG_STRING_D.."}"
	if GLDG.unique_GuildName then
		GLDG_Data[GLDG.unique_GuildName] = GLDG_Data.GuildSettings
		GLDG_Data[GLDG.unique_GuildName].GLDG_CONFIG_STRING = GLDG_CONFIG_STRING
	end
	local writeBtn = _G[GLDG_GUI.."SettingsGeneralWriteGuildString"]
	if writeBtn then
		if (GLDG_CONFIG_STRING ~= GLDG_config_from_guild) and IsGuildLeader() then
			writeBtn:Enable()
		else
			writeBtn:Disable()
		end
	end
end

------------------------------------------------------------
-- Initialize greetings section
function GLDG.Core:InitGreet(section)
	-- Set greetings section pointer if section exists
	local t = GLDG_Data.Custom
	if not t or not t[section] then return true
	elseif (t[section] == "") then GLDG_DataGreet = GLDG.db and GLDG.db.realm.greetings or GLDG_DataGreet
	else	GLDG_SelColName = t[section]
		if GLDG_Data.Collections and GLDG_Data.Collections[t[section]] then
			GLDG_DataGreet = GLDG_Data.Collections[t[section]]
		end
	end
end

------------------------------------------------------------
-- Guild alias management functions
function GLDG.Core:ClickGuildAliasSet()
	local name = GLDG_GUI.."SettingsGreeting"
	local box = _G[name.."GuildAliasEditbox"]
	if box then
		GLDG_GuildAlias = box:GetText()
		box:ClearFocus()
	end
	if GLDG.unique_GuildName and GLDG_Data.GuildAlias then
		GLDG_Data.GuildAlias[GLDG.unique_GuildName] = GLDG_GuildAlias
	end
end

------------------------------------------------------------
function GLDG.Core:ClickGuildAliasClear()
	GLDG_GuildAlias = GLDG.unique_GuildName
	if GLDG.unique_GuildName and GLDG_Data.GuildAlias then
		GLDG_Data.GuildAlias[GLDG.unique_GuildName] = GLDG_GuildAlias
	end

	local name = GLDG_GUI.."SettingsGreeting"
	local box = _G[name.."GuildAliasEditbox"]
	if box then
		box:SetText("")
		box:ClearFocus()
	end
end

------------------------------------------------------------
-- Time functions for logging and greetings
function GLDG.Core:GetLogtime(player)
	-- Helper function: mark playing coming online
	local hour, minute = GLDG_GetTime()
	if (hour < 10) then hour = "[0"..hour else hour = "["..hour end
	if (minute < 10) then minute = ":0"..minute.."] " else minute = ":"..minute.."] " end
	return hour..minute
end

------------------------------------------------------------
function GLDG.Core:GetTime()
	local hour, minute

	if GLDG_Data.UseLocalTime==true then
		local t = date('*t')		-- returns local time
		hour = t.hour
		minute = t.min
	else
		hour, minute = GetGameTime()	-- returns server time
	end

	return hour, minute
end

------------------------------------------------------------
-- Greeting trigger functions
function GLDG.Core:KeyGreet()
	if (GLDG_Data.GreetGuild[GLDG.Realm.." - "..GLDG.Player]) then
		self:GreetGuild()
	end
	if (GLDG_Data.GreetChannel[GLDG.Realm.." - "..GLDG.Player]) then
		self:GreetChannel()
	end
end

------------------------------------------------------------
function GLDG.Core:GreetGuild()
	if (GLDG.unique_GuildName=="") then return end

	local list = GLDG_DataGreet.Guild
	list = GLDG_FilterMessages(nil, list)

	local greetSize = GLDG_TableSize(list)
	if (greetSize ==0 ) then return end

	local msg = list[math.random(greetSize)]
	msg = GLDG_ParseCustomMessage("", "", msg)

	-- Send greeting (still parse for %s for backwards compatibility)
	SendChatMessage(string.format(msg, GLDG_GuildAlias), "GUILD")
end

------------------------------------------------------------
function GLDG.Core:GreetChannel()
	if not GLDG_ChannelName then return end
	local list = GLDG_DataGreet.Channel
	list = GLDG_FilterMessages(nil, list)

	local greetSize = GLDG_TableSize(list)
	if (greetSize == 0) then return end

	local msg = list[math.random(greetSize)]
	msg = GLDG_ParseCustomMessage("", "", msg)

	-- Send greeting
	local channel = GetChannelName(GLDG_ChannelName)
	if channel and channel > 0 then
		SendChatMessage(string.format(msg, GLDG_GuildAlias or ""), "CHANNEL", nil, tostring(channel))
	end
end

------------------------------------------------------------
-- Player interaction functions
function GLDG.Core:ClickName(button, name)
	if not name or name == "" then return end
	-- Strip timestamp "[HH:MM] " from name if present
	if string.sub(name, 1, 1) == "[" then
		name = string.sub(name, 9)
	end
	local _, uRealm = string.split("-", name)
	if not uRealm then
		local prefix = name.."-"
		local len = string.len(prefix)
		local matched = nil
		for i in pairs(GLDG_DataChar) do
			if string.sub(i, 1, len) == prefix and GLDG_DataChar[i].guild == GLDG_unique_GuildName then
				matched = i
				break
			end
		end
		if not matched then
			for i in pairs(GLDG_Queue) do
				if string.sub(i, 1, len) == prefix then
					matched = i
					break
				end
			end
		end
		if matched then
			name = matched
		elseif GLDG.Realm then
			name = prefix..string.gsub(GLDG.Realm, " ", "")
		end
	end
	-- Greet the player if left click
	if (button == "LeftButton") then
		GLDG_SendGreet(name)
	end
	-- Cleanup where needed
	GLDG_CleanupPlayer(name)
	-- Remove name from queue and refresh
	GLDG_Queue[name] = nil
	GLDG_ShowQueue()
end

------------------------------------------------------------
-- Goodbye greeting functions
function GLDG.Core:ByeGuild()
	if (GLDG.unique_GuildName=="") then return end

	local list = GLDG_DataGreet.ByeGuild
	-- if time is between 20:00 and 06:00 use night mode
	local hour,min = GLDG_GetTime();
	if ((hour >= 20) or (hour <=5)) then
		list = GLDG_DataGreet.NightGuild;
	end
	list = GLDG_FilterMessages(nil, list)

	local greetSize = GLDG_TableSize(list)
	if (greetSize ==0 ) then return end

	local msg = list[math.random(greetSize)]
	msg = GLDG_ParseCustomMessage("", "", msg)

	-- Send greeting (still parse for %s for backwards compatibility)
	SendChatMessage(string.format(msg, GLDG_GuildAlias), "GUILD")
end

------------------------------------------------------------
function GLDG.Core:ByeChannel()
	local list = GLDG_DataGreet.ByeChannel
	-- if time is between 20:00 and 05:00 use night mode
	local hour,min = GLDG_GetTime();
	if ((hour >= 20) or (hour <=5)) then
		list = GLDG_DataGreet.NightChannel;
	end
	list = GLDG_FilterMessages(nil, list)

	local greetSize = GLDG_TableSize(list)
	if (greetSize ==0 ) then return end

	local msg = list[math.random(greetSize)]
	msg = GLDG_ParseCustomMessage("", "", msg)

	-- Send greeting
	local channel = GetChannelName(GLDG_ChannelName)
	if (channel) then
		SendChatMessage(msg, "CHANNEL", nil, tostring(channel))
	end
end

------------------------------------------------------------
-- Later greeting functions
function GLDG.Core:KeyLater()
	if (GLDG_Data.GreetGuild[GLDG.Realm.." - "..GLDG.Player]) then
		self:LaterGuild()
	end
	if (GLDG_Data.GreetChannel[GLDG.Realm.." - "..GLDG.Player]) then
		self:LaterChannel()
	end
end

------------------------------------------------------------
function GLDG.Core:LaterGuild()
	if (GLDG.unique_GuildName=="") then return end

	local list = GLDG_DataGreet.LaterGuild
	list = GLDG_FilterMessages(nil, list)

	local greetSize = GLDG_TableSize(list)
	if (greetSize ==0 ) then return end

	local msg = list[math.random(greetSize)]
	msg = GLDG_ParseCustomMessage("", "", msg)

	-- Send greeting (still parse for %s for backwards compatibility)
	SendChatMessage(string.format(msg, GLDG_GuildAlias), "GUILD")
end

------------------------------------------------------------
function GLDG.Core:LaterChannel()
	local list = GLDG_DataGreet.LaterChannel
	list = GLDG_FilterMessages(nil, list)

	local greetSize = GLDG_TableSize(list)
	if (greetSize ==0 ) then return end

	local msg = list[math.random(greetSize)]
	msg = GLDG_ParseCustomMessage("", "", msg)

	-- Send greeting
	local channel = GetChannelName(GLDG_ChannelName)
	if (channel) then
		SendChatMessage(msg, "CHANNEL", nil, tostring(channel))
	end
end

------------------------------------------------------------
-- Key shortcut functions
function GLDG.Core:KeyBye()
	if (GLDG_Data.GreetGuild[GLDG.Realm.." - "..GLDG.Player]) then
		self:ByeGuild()
	end
	if (GLDG_Data.GreetChannel[GLDG.Realm.." - "..GLDG.Player]) then
		self:ByeChannel()
	end
end