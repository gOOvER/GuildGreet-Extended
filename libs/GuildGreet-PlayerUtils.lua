------------------------------------------------------------
-- GuildGreet Player Utilities Library
-- Handles player state management, filtering and utility functions
------------------------------------------------------------

GLDG.PlayerUtils = {}

------------------------------------------------------------
-- Clean up player data after greeting/interaction
function GLDG.PlayerUtils:CleanupPlayer(name)
	if not name then return end
	if (GLDG_DataChar[name]) then
		local player = GLDG_DataChar[name]
		player.new = nil
		player.newlvl = nil
		player.newrank = nil
		player.promoter = nil
		player.achievment = nil
	else
		-- take care of test chars
		GLDG_Online[name] = nil
		GLDG_Offline[name] = nil
	end
end

------------------------------------------------------------
-- Filter messages based on level requirements
-- Function submitted by lebanoncyberspace and modified by Urbin
function GLDG.PlayerUtils:FilterLevels(message, level)
	local _,_,min,max,msg = string.find(message, "^<levels:(%d*):(%d*)>%s*(.*)")
	--GLDG_Print("Checking levels ["..tostring(min).."] - ["..tostring(max).."] - level is ["..tostring(level).."] - remaining message is ["..tostring(msg).."] - original message was ["..tostring(message).."]")
	if (min and max) then
		if (not level) or (tonumber(min) > level) or (level > tonumber(max)) then
			--GLDG_Print(" --> level criteria failed, removing message")
			message = nil
		else
			--GLDG_Print(" --> level criteria fulfilled")
			message = msg
		end
	else
		--GLDG_Print(" --> no level found, keeping message ["..tostring(message).."] unchanged")
	end

	return message
end

------------------------------------------------------------
-- Filter messages based on time requirements  
function GLDG.PlayerUtils:FilterTime(message, hour, minute)
	local _,_,fromH,fromM,toH,toM,msg = string.find(message, "^<time:(%d*)%.(%d*):(%d*)%.(%d*)>%s*(.*)")
	--GLDG_Print("Checking time ["..tostring(fromH)..":"..tostring(fromM).."] - ["..tostring(toH)..":"..tostring(toM).."] - time is ["..tostring(hour)..":"..tostring(minute).."] - remaining message is ["..tostring(msg).."] - original message was ["..tostring(message).."]")
	if (fromH and fromM and toH and toM) then
		fromH = tonumber(fromH)
		fromM = tonumber(fromM)
		toH = tonumber(toH)
		toM = tonumber(toM)
		if (hour < fromH) or (hour > toH) or ((hour == fromH) and (minute < fromM)) or ((hour == toH) and (minute > toH)) then
			--GLDG_Print(" --> time criteria failed, removing message")
			message = nil
		else
			--GLDG_Print(" --> time criteria fulfilled")
			message = msg
		end
	else
		--GLDG_Print(" --> no time found, keeping message ["..tostring(message).."] unchanged")
	end

	return message
end