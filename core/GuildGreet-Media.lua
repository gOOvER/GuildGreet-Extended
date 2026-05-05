--[[
GuildGreet-Media.lua - LibSharedMedia-3.0 Integration
Provides comprehensive media resource management (fonts, textures, sounds, colors)
]]--

local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet", true) or LibStub("AceAddon-3.0"):NewAddon("GuildGreet", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", false)

-- Initialize Media module
function GLDG:InitializeMedia()
	if not LibStub("LibSharedMedia-3.0", true) then
		return -- LibSharedMedia not available
	end
	
	self.Media = LibStub("LibSharedMedia-3.0")
	self.MediaReady = true
	
	-- Register custom fonts
	self:RegisterFonts()
	
	-- Register custom textures
	self:RegisterTextures()
	
	-- Register custom sounds
	self:RegisterSounds()
	
	-- Register custom colors
	self:RegisterColors()
	
	-- Initialize media defaults
	self:InitializeMediaDefaults()
end

-- Register fonts
function GLDG:RegisterFonts()
	if not self.Media then return end
	
	-- Standard fonts (usually built-in, but ensure availability)
	self.Media:Register("font", "Arial Narrow", [[Fonts\ARIALN.TTF]])
	self.Media:Register("font", "Friz Quadrata", [[Fonts\FRIZQT__.TTF]])
	self.Media:Register("font", "Skurri", [[Fonts\SKURRI.TTF]])
	self.Media:Register("font", "Morpheus", [[Fonts\MORPHEUS.TTF]])
	
	-- Store font names
	self.FontList = self.Media:GetDefault("font")
end

-- Register textures
function GLDG:RegisterTextures()
	if not self.Media then return end
	
	-- Status bar textures
	self.Media:Register("statusbar", "Minimalist", [[Interface\AddOns\GuildGreet-Extended\media\textures\minimalist.tga]])
	self.Media:Register("statusbar", "Solid", [[Interface\UNITFRAMESENEMYHEALTH]])
	self.Media:Register("statusbar", "Gradient", [[Interface\TARGETINGFRAME\UI-TargetingFrame-HealthBar-Fill]])
	
	-- Border textures
	self.Media:Register("border", "Simple Border", [[Interface\CHATFRAME\CHATFRAMEBACKGROUND]])
	self.Media:Register("border", "Tooltip", [[Interface\Tooltips\UI-Tooltip-Background]])
	
	-- Background textures
	self.Media:Register("background", "Solid Black", [[Interface\COMMON\COMMON-BLACK-001]])
	self.Media:Register("background", "Blurred", [[Interface\GLUESCREEN\GlueScreen-BlurMask]])
	
	-- Store texture names
	self.TextureList = self.Media:GetDefault("statusbar")
end

-- Register sounds
function GLDG:RegisterSounds()
	if not self.Media then return end
	
	-- Guild-related sounds
	self.Media:Register("sound", "Guild Event", [[Sound\Doodad\AlarmClockWarning3.wav]])
	self.Media:Register("sound", "Welcome Chime", [[Sound\Creature\Murloc\MurloctalkIdle1.wav]])
	self.Media:Register("sound", "Player Join", [[Sound\Character\FootSteps\HumanStep1.wav]])
	self.Media:Register("sound", "Player Leave", [[Sound\Character\FootSteps\HumanStep3.wav]])
	self.Media:Register("sound", "Greeting", [[Sound\Doodad\AlarmClockWarning2.wav]])
	self.Media:Register("sound", "Notification", [[Sound\Interface\UnknownSpellCast.ogg]])
	
	-- Store sound names
	self.SoundList = self.Media:GetDefault("sound")
end

-- Register colors
function GLDG:RegisterColors()
	if not self.Media then return end
	
	-- Guild rank colors
	self.Media:Register("color", "GM Color", { r = 1.0, g = 0.8, b = 0.0 })  -- Gold
	self.Media:Register("color", "Officer Color", { r = 0.9, g = 0.7, b = 0.1 })  -- Orange
	self.Media:Register("color", "Member Color", { r = 0.2, g = 0.8, b = 0.2 })  -- Green
	self.Media:Register("color", "Recruit Color", { r = 0.5, g = 0.5, b = 0.8 })  -- Light Blue
	
	-- System colors
	self.Media:Register("color", "Success", { r = 0.1, g = 0.8, b = 0.1 })
	self.Media:Register("color", "Warning", { r = 1.0, g = 0.8, b = 0.0 })
	self.Media:Register("color", "Error", { r = 1.0, g = 0.1, b = 0.1 })
	self.Media:Register("color", "Info", { r = 0.2, g = 0.7, b = 1.0 })
	
	-- Class colors (standard WoW)
	self.Media:Register("color", "Warrior", { r = 0.78, g = 0.61, b = 0.43 })
	self.Media:Register("color", "Paladin", { r = 0.96, g = 0.55, b = 0.73 })
	self.Media:Register("color", "Hunter", { r = 0.67, g = 0.83, b = 0.45 })
	self.Media:Register("color", "Rogue", { r = 1.0, g = 0.96, b = 0.41 })
	self.Media:Register("color", "Priest", { r = 1.0, g = 1.0, b = 1.0 })
	self.Media:Register("color", "Death Knight", { r = 0.77, g = 0.12, b = 0.23 })
	self.Media:Register("color", "Shaman", { r = 0.0, g = 0.44, b = 0.87 })
	self.Media:Register("color", "Mage", { r = 0.41, g = 0.8, b = 0.94 })
	self.Media:Register("color", "Warlock", { r = 0.53, g = 0.53, b = 0.93 })
	self.Media:Register("color", "Druid", { r = 1.0, g = 0.49, b = 0.04 })
	self.Media:Register("color", "Demon Hunter", { r = 0.64, g = 0.19, b = 0.79 })
	self.Media:Register("color", "Monk", { r = 0.0, g = 1.0, b = 0.59 })
	
	-- Store color names
	self.ColorList = self.Media:GetDefault("color")
end

-- Initialize media-related database defaults
function GLDG:InitializeMediaDefaults()
	if not self.db or not self.db.profile then return end
	
	-- Set default media choices
	self.db.profile.Font = "Friz Quadrata"
	self.db.profile.FontSize = 12
	self.db.profile.StatusBarTexture = "Minimalist"
	self.db.profile.BorderTexture = "Simple Border"
	self.db.profile.BackgroundTexture = "Solid Black"
	self.db.profile.GreetingSound = "Welcome Chime"
	self.db.profile.JoinSound = "Player Join"
	self.db.profile.LeaveSound = "Player Leave"
	self.db.profile.NotificationSound = "Notification"
	self.db.profile.EnableSounds = true
	self.db.profile.SoundVolume = 1.0
	
	-- Color scheme
	self.db.profile.TextColor = { r = 1.0, g = 1.0, b = 1.0 }
	self.db.profile.HighlightColor = { r = 1.0, g = 0.84, b = 0.0 }
	self.db.profile.WarningColor = { r = 1.0, g = 0.1, b = 0.1 }
end

-- Get font
function GLDG:GetFont()
	if not self.MediaReady or not self.Media then
		return "Fonts\\FRIZQT__.TTF", 12
	end
	
	local fontName = self.db.profile.Font or "Friz Quadrata"
	local fontSize = self.db.profile.FontSize or 12
	local fontPath = self.Media:Fetch("font", fontName)
	
	return fontPath, fontSize
end

-- Get texture
function GLDG:GetTexture(textureType)
	if not self.MediaReady or not self.Media then
		return nil
	end
	
	textureType = textureType or "statusbar"
	
	if textureType == "statusbar" then
		local textureName = self.db.profile.StatusBarTexture or "Minimalist"
		return self.Media:Fetch("statusbar", textureName)
	elseif textureType == "border" then
		local textureName = self.db.profile.BorderTexture or "Simple Border"
		return self.Media:Fetch("border", textureName)
	elseif textureType == "background" then
		local textureName = self.db.profile.BackgroundTexture or "Solid Black"
		return self.Media:Fetch("background", textureName)
	end
	
	return nil
end

-- Play sound
function GLDG:PlaySound(soundType)
	if not self.MediaReady or not self.Media then return end
	
	if not self.db.profile.EnableSounds then return end
	
	local soundName
	if soundType == "greeting" then
		soundName = self.db.profile.GreetingSound or "Welcome Chime"
	elseif soundType == "join" then
		soundName = self.db.profile.JoinSound or "Player Join"
	elseif soundType == "leave" then
		soundName = self.db.profile.LeaveSound or "Player Leave"
	elseif soundType == "notification" then
		soundName = self.db.profile.NotificationSound or "Notification"
	else
		soundName = soundType
	end
	
	local soundPath = self.Media:Fetch("sound", soundName)
	if soundPath then
		PlaySoundFile(soundPath, "Master")
	end
end

-- Get color
function GLDG:GetColor(colorName, default)
	if not self.MediaReady or not self.Media then
		return default or { r = 1.0, g = 1.0, b = 1.0 }
	end
	
	local color = self.Media:Fetch("color", colorName)
	return color or default or { r = 1.0, g = 1.0, b = 1.0 }
end

-- Get class color
function GLDG:GetClassColor(className)
	if not className then
		return { r = 1.0, g = 1.0, b = 1.0 }
	end
	
	return self:GetColor(className, { r = 1.0, g = 1.0, b = 1.0 })
end

-- Set text color on frame
function GLDG:SetFrameTextColor(frame, colorName, default)
	if not frame or not frame.SetTextColor then return end
	
	local color = self:GetColor(colorName, default)
	frame:SetTextColor(color.r, color.g, color.b)
end

-- Set texture on frame
function GLDG:SetFrameTexture(frame, textureType)
	if not frame or not frame.SetTexture then return end
	
	local texture = self:GetTexture(textureType)
	if texture then
		frame:SetTexture(texture)
	end
end

-- Get all available fonts
function GLDG:GetFontList()
	if not self.MediaReady or not self.Media then
		return {}
	end
	
	return self.Media:List("font")
end

-- Get all available textures
function GLDG:GetTextureList(textureType)
	if not self.MediaReady or not self.Media then
		return {}
	end
	
	textureType = textureType or "statusbar"
	return self.Media:List(textureType)
end

-- Get all available sounds
function GLDG:GetSoundList()
	if not self.MediaReady or not self.Media then
		return {}
	end
	
	return self.Media:List("sound")
end

-- Get all available colors
function GLDG:GetColorList()
	if not self.MediaReady or not self.Media then
		return {}
	end
	
	return self.Media:List("color")
end

-- Format color for string output
function GLDG:FormatColoredString(text, colorName)
	local color = self:GetColor(colorName)
	local hex = string.format("|cff%02x%02x%02x", 
		math.floor(color.r * 255),
		math.floor(color.g * 255),
		math.floor(color.b * 255)
	)
	return hex .. text .. "|r"
end

-- Reset media to defaults
function GLDG:ResetMediaDefaults()
	self:InitializeMediaDefaults()
end

-- Get media statistics
function GLDG:GetMediaStats()
	return {
		fonts = #self:GetFontList(),
		textures = #self:GetTextureList("statusbar"),
		borders = #self:GetTextureList("border"),
		backgrounds = #self:GetTextureList("background"),
		sounds = #self:GetSoundList(),
		colors = #self:GetColorList()
	}
end
