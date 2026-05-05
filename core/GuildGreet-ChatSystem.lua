------------------------------------------------------------
-- GuildGreet ChatSystem Library
-- Handles channel management, chat filtering and communication features
------------------------------------------------------------

-- Ensure GLDG exists (defensive loading for library modules)
GLDG = GLDG or {}
GLDG.ChatSystem = {}

------------------------------------------------------------
-- Check if player is in configured channel
function GLDG.ChatSystem:CheckChannel()
	GLDG_inChannel = false;
	if (GLDG_ChannelName and GLDG_ChannelName ~= "") then

		local id, name = GetChannelName(GLDG_ChannelName)
		local id2, name2 = GetChannelName(id)
		--GLDG_Print("Checking channels: Stored name ["..tostring(GLDG_ChannelName).."] - retrieved name ["..tostring(name2).."] - id ["..tostring(id).."] - id2 ["..tostring(id2).."]")
		if ((id>0) and (id2>0) and (id==id2) and (string.lower(name2)==GLDG_ChannelName)) then
			---- Debug statement removed

			GLDG_inChannel = true;

			-- get members of channel
			self:RegisterEvent("CHAT_MSG_CHANNEL_LIST")
			DEFAULT_CHAT_FRAME:UnregisterEvent("CHAT_MSG_CHANNEL_LIST")
			GLDG_unregister = GLDG_unregister + 1
			ListChannelByName(GLDG_ChannelName)

			if not bit.band(GLDG_InitCheck, 32)==32 then
				GLDG_InitCheck = bit.bor(GLDG_InitCheck, 4) -- start channel update
				--GLDG_Print("InitCheck is ["..tostring(GLDG_InitCheck).."] - channel started")
			end
		end
	end

	return GLDG_inChannel
end

------------------------------------------------------------
-- Initialize channel member list 
function GLDG.ChatSystem:InitChannel(data)
	-- now that we got a list of all people in the channel, we do not need to monitor this event
	if (GLDG_unregister > 0) then
		GLDG_unregister = GLDG_unregister - 1
		if (GLDG_unregister == 0) then
			self:UnregisterEvent("CHAT_MSG_CHANNEL_LIST")
			DEFAULT_CHAT_FRAME:RegisterEvent("CHAT_MSG_CHANNEL_LIST")
		end
	end

	if (GLDG_DataChar) then
		GLDG_checkedChannel = true

		-- split data by commas
		local splits = {strsplit(", ", data)}

		for i=1, table.getn(splits), 1 do
			local name = string.strip(splits[i])

			-- ignore ourselves
			if (name ~= GLDG.Player) then
				if not GLDG_DataChar[name] then
					GLDG_DataChar[name] = {}
				end
				if (not GLDG_DataChar[name].channels) then
					GLDG_DataChar[name].channels = {}
				end
				GLDG_DataChar[name].channels[GLDG_ChannelName] = GLDG_ChannelName

				if (GLDG_DataChar[name] and not GLDG_DataChar[name].ignore) then
					-- Debug statement removed.." was already in channel ["..GLDG_ChannelName.."]")

					GLDG_Online[name] = GetTime()
					-- this player is usually online, not a relog
					if (GLDG_Offline[name] == nil) then
						GLDG_Offline[name] = false
					end
					if (GLDG_Online[name] == nil) then
						GLDG_Online[name] = true
					end
				end
			end

			if bit.band(GLDG_InitCheck, 4)==4 then
				GLDG_InitCheck = bit.band(GLDG_InitCheck, bit.bnot(4))	-- channel no longer pending
				GLDG_InitCheck = bit.bor(GLDG_InitCheck, 32)
				--GLDG_Print("InitCheck is ["..tostring(GLDG_InitCheck).."] - channel done")
				GLDG_StartupCheck()
			end
		end
	end
end

------------------------------------------------------------
-- Update channel membership when player joins/leaves
function GLDG.ChatSystem:UpdateChannel(joined, player)
	if not player then return end

	if (GLDG_inChannel) then
		if not GLDG_DataChar[player] then
			GLDG_DataChar[player] = {}
		end
		if (not GLDG_DataChar[player].channels) then
			GLDG_DataChar[player].channels = {}
		end
		GLDG_DataChar[player].channels[GLDG_ChannelName] = GLDG_ChannelName

		if (joined) then
			-- Debug statement removed.."] joined channel ["..GLDG_ChannelName.."]")

			if (GLDG_DataChar[player] and not GLDG_DataChar[player].ignore) then
				-- Debug statement removed.." is a member of our channel")
				GLDG_Online[player] = GetTime()

				-- if player is in our guild or on our friend's list, we've already
				-- listed him above, otherwise, list him now
				if (not GLDG_DataChar[player].guild or GLDG_DataChar[player].guild ~= GLDG_unique_GuildName) and
				   (not GLDG_DataChar[player].friends or not GLDG_DataChar[player].friends[GLDG.Player]) then
					if GLDG_Data.GuildSettings.ListNames==true then
						if GLDG_DataChar[player].alt then
							--
							-- Alt von Main
							--
							local main = GLDG_DataChar[player].alt;
							local altsList = GLDG_FindAlts(main, player, 1)
							GLDG:PrintHelp(altsList)
						else
							--
							-- Main
							--
							local mainName = GLDG_findAlias(player, 1)
							GLDG:PrintHelp(mainName..L[" joined the channel"]..".")
						end
					end
				end
			end
		else
			-- Debug statement removed.."] left channel ["..GLDG_ChannelName.."]")
			if (GLDG_DataChar[player] and not GLDG_DataChar[player].ignore) then
				GLDG_Offline[player] = GetTime()
			end
		end
	end
end

------------------------------------------------------------
-- Force chat list display
function GLDG.ChatSystem:ForceChatlist()
	GLDG:PrintHelp(L["Forced chatlist to be displayed in chat"])
	GLDG_unregister = 0
	DEFAULT_CHAT_FRAME:RegisterEvent("CHAT_MSG_CHANNEL_LIST")
end

------------------------------------------------------------
-- Advanced chat filter for guild member names
function GLDG.ChatSystem:ChatFilter(chatFrame, event, ...)
	local msg, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13 = ...;

	--GLDG_Print("CHAT: event ["..tostring(event).."] - msg ["..tostring(msg).."] - arg2 ["..tostring(arg2).."] - arg3 ["..tostring(arg3).."]");

	if GLDG_Data.GuildSettings.ExtendChat==true then
		local main = ""
		local class = ""
		local treated = nil

		if (event) then
			-- guild members can post to all three (officers even four) channels
			if (((event == "CHAT_MSG_GUILD") and arg2) or
			    ((event == "CHAT_MSG_OFFICER") and arg2) or
			    ((event == "CHAT_MSG_CHANNEL") and arg9 and (arg9 == GLDG_ChannelName) and arg2) or
			    ((event == "CHAT_MSG_WHISPER") and arg2)) then
				--GLDG_Print("Event ["..event.."] from player ["..arg2.."]")
				treated = true
				if (GLDG_DataChar[arg2] and (not GLDG_DataChar[arg2].ignore or GLDG_Data.GuildSettings.ExtendIgnored==true)) then
					if GLDG_DataChar[arg2].alt then
						main = GLDG_DataChar[arg2].alt;
						if GLDG_Data.GuildSettings.ExtendAlias==true then
							if GLDG_DataChar[main] and GLDG_DataChar[main].alias then
								main = GLDG_DataChar[main].alias
							end
						end
					elseif GLDG_Data.GuildSettings.ExtendMain==true and GLDG_DataChar[arg2].main then
						main = arg2
						if GLDG_Data.GuildSettings.ExtendAlias==true then
							if GLDG_DataChar[main] and GLDG_DataChar[main].alias then
								main = GLDG_DataChar[main].alias
							end
						end
					end
				end
			end

			-- use this to discover any other events being sent
			if ((event ~= "CHAT_MSG_GUILD") and
			    (event ~= "CHAT_MSG_OFFICER") and
			    (event ~= "CHAT_MSG_CHANNEL") and
			    (event ~= "CHAT_MSG_WHISPER")) then
				--GLDG_Print("Event ["..event.."] is boring")
			end
		end

		if ((main ~= "") and msg and arg2 and (arg2 ~= GLDG.Player)) then
			msg = chatFrame:GetColors().help.."{"..Ambiguate(main, "guild").."}|r "..msg
		end
	end

	return false, msg, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13;
end