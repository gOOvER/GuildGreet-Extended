--[[
	GuildGreet Profiles GUI Module
	Handles profile management (create, copy, delete, load, save)
]]--

local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", false)

local ProfilesGUI = GLDG:NewModule("ProfilesGUI")

--[[
	Create the Profiles tab content
]]
function ProfilesGUI:CreateTabContent(container)
	-- Main scroll frame
	local scrollFrame = AceGUI:Create("ScrollFrame")
	scrollFrame:SetFullWidth(true)
	scrollFrame:SetFullHeight(true)
	scrollFrame:SetLayout("Flow")
	
	-- Information section
	local infoGroup = AceGUI:Create("InlineGroup")
	infoGroup:SetTitle(L["Profile Management"] or "Profile Management")
	infoGroup:SetFullWidth(true)
	infoGroup:SetHeight(100)
	infoGroup:SetLayout("Flow")
	
	local infoText = AceGUI:Create("Label")
	infoText:SetText(L["Create and manage multiple setting profiles. Profiles allow you to save different configurations and switch between them easily."] or "Create and manage multiple setting profiles. Profiles allow you to save different configurations and switch between them easily.")
	infoText:SetFullWidth(true)
	infoGroup:AddChild(infoText)
	
	scrollFrame:AddChild(infoGroup)
	
	-- Current Profile Display
	local currentGroup = AceGUI:Create("InlineGroup")
	currentGroup:SetTitle(L["Current Profile"] or "Current Profile")
	currentGroup:SetFullWidth(true)
	currentGroup:SetHeight(60)
	currentGroup:SetLayout("Flow")
	
	local currentLabel = AceGUI:Create("Label")
	local currentProfile = GLDG.db:GetCurrentProfile()
	currentLabel:SetText(L["Active Profile"] .. ": |cffffff00" .. currentProfile .. "|r")
	currentLabel:SetFullWidth(true)
	currentGroup:AddChild(currentLabel)
	
	scrollFrame:AddChild(currentGroup)
	
	-- Profile Creation Section
	local createGroup = AceGUI:Create("InlineGroup")
	createGroup:SetTitle(L["Create New Profile"] or "Create New Profile")
	createGroup:SetFullWidth(true)
	createGroup:SetHeight(80)
	createGroup:SetLayout("Flow")
	
	local profileNameEdit = AceGUI:Create("EditBox")
	profileNameEdit:SetLabel(L["Profile Name"] or "Profile Name")
	profileNameEdit:SetRelativeWidth(0.7)
	createGroup:AddChild(profileNameEdit)
	
	local createBtn = AceGUI:Create("Button")
	createBtn:SetText(L["Create"] or "Create")
	createBtn:SetWidth(80)
	createBtn:SetCallback("OnClick", function()
		local name = profileNameEdit:GetText()
		if name and name:trim() ~= "" then
			self:CreateProfile(name)
			profileNameEdit:SetText("")
			self:RefreshProfileList(scrollFrame, currentLabel)
		else
			GLDG:Print(L["Please enter a profile name"] or "Please enter a profile name")
		end
	end)
	createGroup:AddChild(createBtn)
	
	scrollFrame:AddChild(createGroup)
	
	-- Profiles Dropdown Section
	local dropdownGroup = AceGUI:Create("InlineGroup")
	dropdownGroup:SetTitle(L["Existing Profiles"] or "Existing Profiles")
	dropdownGroup:SetFullWidth(true)
	dropdownGroup:SetHeight(120)
	dropdownGroup:SetLayout("Flow")
	
	-- Profile Dropdown
	local profileDropdown = AceGUI:Create("Dropdown")
	profileDropdown:SetLabel(L["Select Profile"] or "Select Profile")
	profileDropdown:SetWidth(200)
	
	-- Populate dropdown
	local profiles = GLDG.db:GetProfiles()
	local currentProfile = GLDG.db:GetCurrentProfile()
	local dropdownValues = {}
	
	if profiles and #profiles > 0 then
		for _, profileName in ipairs(profiles) do
			if profileName == currentProfile then
				dropdownValues[profileName] = profileName .. " (Active)"
			else
				dropdownValues[profileName] = profileName
			end
		end
	end
	
	profileDropdown:SetList(dropdownValues)
	profileDropdown:SetValue(currentProfile)
	profileDropdown:SetCallback("OnValueChanged", function(widget, event, value)
		self:LoadProfile(value, currentLabel)
	end)
	dropdownGroup:AddChild(profileDropdown)
	
	-- Load Button
	local loadBtn = AceGUI:Create("Button")
	loadBtn:SetText(L["Load"] or "Load")
	loadBtn:SetWidth(80)
	loadBtn:SetCallback("OnClick", function()
		self:LoadProfile(profileDropdown:GetValue(), currentLabel)
	end)
	dropdownGroup:AddChild(loadBtn)
	
	-- Copy Button
	local copyBtn = AceGUI:Create("Button")
	copyBtn:SetText(L["Copy"] or "Copy")
	copyBtn:SetWidth(80)
	copyBtn:SetCallback("OnClick", function()
		self:ShowCopyDialog(profileDropdown:GetValue())
	end)
	dropdownGroup:AddChild(copyBtn)
	
	-- Delete Button
	local deleteBtn = AceGUI:Create("Button")
	deleteBtn:SetText(L["Delete"] or "Delete")
	deleteBtn:SetWidth(80)
	if profileDropdown:GetValue() == currentProfile then
		deleteBtn:SetDisabled(true)
	end
	deleteBtn:SetCallback("OnClick", function()
		local selectedProfile = profileDropdown:GetValue()
		if selectedProfile == currentProfile then
			GLDG:Print(L["Cannot delete the currently active profile"] or "Cannot delete the currently active profile")
			return
		end
		StaticPopup_Show("GUILDGREET_CONFIRM_DELETE_PROFILE", selectedProfile)
	end)
	dropdownGroup:AddChild(deleteBtn)
	
	scrollFrame:AddChild(dropdownGroup)
	
	-- Store references
	self.scrollFrame = scrollFrame
	self.currentLabel = currentLabel
	self.profileNameEdit = profileNameEdit
	self.profileDropdown = profileDropdown
	self.deleteBtn = deleteBtn
	
	container:AddChild(scrollFrame)
end

--[[
	Refresh the profile list
]]
function ProfilesGUI:RefreshProfileList(scrollFrame, currentLabel, listGroup)
	if not self.profileDropdown then
		return
	end
	
	local profiles = GLDG.db:GetProfiles()
	local currentProfile = GLDG.db:GetCurrentProfile()
	
	-- Update dropdown
	local dropdownValues = {}
	if profiles and #profiles > 0 then
		for _, profileName in ipairs(profiles) do
			if profileName == currentProfile then
				dropdownValues[profileName] = profileName .. " (Active)"
			else
				dropdownValues[profileName] = profileName
			end
		end
	end
	
	self.profileDropdown:SetList(dropdownValues)
	self.profileDropdown:SetValue(currentProfile)
	
	-- Update delete button state
	if self.deleteBtn then
		if currentProfile == currentProfile then
			self.deleteBtn:SetDisabled(true)
		else
			self.deleteBtn:SetDisabled(false)
		end
	end
end

--[[
	Create a new profile
]]
function ProfilesGUI:CreateProfile(name)
	if not name or name:trim() == "" then
		GLDG:Print(L["Profile name cannot be empty"] or "Profile name cannot be empty")
		return
	end
	
	-- Check if profile already exists
	local profiles = GLDG.db:GetProfiles()
	for _, profile in ipairs(profiles) do
		if profile == name then
			GLDG:Print(string.format(L["Profile '%s' already exists"] or "Profile '%s' already exists", name))
			return
		end
	end
	
	-- Create profile by setting it as current
	GLDG.db:SetProfile(name)
	GLDG:Print(string.format(L["Profile '%s' created successfully"] or "Profile '%s' created successfully", name))
	
	-- Refresh UI
	self:RefreshProfileList()
end

--[[
	Load a profile
]]
function ProfilesGUI:LoadProfile(profileName, currentLabel)
	if not profileName or profileName:trim() == "" then
		GLDG:Print(L["Invalid profile name"] or "Invalid profile name")
		return
	end
	
	GLDG.db:SetProfile(profileName)
	GLDG:Print(string.format(L["Switched to profile '%s'"] or "Switched to profile '%s'", profileName))
	
	-- Update current profile display
	if self.currentLabel then
		self.currentLabel:SetText(L["Active Profile"] .. ": |cffffff00" .. profileName .. "|r")
	end
	
	-- Refresh profile list
	self:RefreshProfileList()
end

--[[
	Show copy profile dialog
]]
function ProfilesGUI:ShowCopyDialog(sourceProfile)
	local dialog = AceGUI:Create("Window")
	dialog:SetTitle(L["Copy Profile"] or "Copy Profile")
	dialog:SetWidth(400)
	dialog:SetHeight(150)
	dialog:SetLayout("Flow")
	
	local infoText = AceGUI:Create("Label")
	infoText:SetText(string.format(L["Enter a name for the copy of '%s'"] or "Enter a name for the copy of '%s'", sourceProfile))
	infoText:SetFullWidth(true)
	dialog:AddChild(infoText)
	
	local nameEdit = AceGUI:Create("EditBox")
	nameEdit:SetLabel(L["New Profile Name"] or "New Profile Name")
	nameEdit:SetRelativeWidth(1.0)
	dialog:AddChild(nameEdit)
	
	-- Button group
	local buttonGroup = AceGUI:Create("SimpleGroup")
	buttonGroup:SetFullWidth(true)
	buttonGroup:SetLayout("Flow")
	
	local copyBtn = AceGUI:Create("Button")
	copyBtn:SetText(L["Copy"] or "Copy")
	copyBtn:SetWidth(100)
	copyBtn:SetCallback("OnClick", function()
		local newName = nameEdit:GetText()
		if newName and newName:trim() ~= "" then
			self:CopyProfile(sourceProfile, newName)
			dialog:Release()
			self:RefreshProfileList()
		else
			GLDG:Print(L["Please enter a profile name"] or "Please enter a profile name")
		end
	end)
	buttonGroup:AddChild(copyBtn)
	
	local cancelBtn = AceGUI:Create("Button")
	cancelBtn:SetText(L["Cancel"] or "Cancel")
	cancelBtn:SetWidth(100)
	cancelBtn:SetCallback("OnClick", function()
		dialog:Release()
	end)
	buttonGroup:AddChild(cancelBtn)
	
	dialog:AddChild(buttonGroup)
	dialog:BringToFront()
end

--[[
	Copy a profile
]]
function ProfilesGUI:CopyProfile(sourceProfile, newName)
	if not sourceProfile or not newName or newName:trim() == "" then
		GLDG:Print(L["Invalid profile names"] or "Invalid profile names")
		return
	end
	
	-- Check if new profile already exists
	local profiles = GLDG.db:GetProfiles()
	for _, profile in ipairs(profiles) do
		if profile == newName then
			GLDG:Print(string.format(L["Profile '%s' already exists"] or "Profile '%s' already exists", newName))
			return
		end
	end
	
	-- Copy profile data using AceDB copy functionality
	GLDG.db:CopyProfile(sourceProfile, newName)
	GLDG:Print(string.format(L["Profile '%s' copied to '%s'"] or "Profile '%s' copied to '%s'", sourceProfile, newName))
end

--[[
	Delete a profile
]]
function ProfilesGUI:DeleteProfile(profileName, currentLabel)
	if not profileName or profileName:trim() == "" then
		GLDG:Print(L["Invalid profile name"] or "Invalid profile name")
		return
	end
	
	local currentProfile = GLDG.db:GetCurrentProfile()
	if profileName == currentProfile then
		GLDG:Print(L["Cannot delete the currently active profile"] or "Cannot delete the currently active profile")
		return
	end
	
	-- Show confirmation dialog
	local dialog = AceGUI:Create("Window")
	dialog:SetTitle(L["Delete Profile"] or "Delete Profile")
	dialog:SetWidth(400)
	dialog:SetHeight(120)
	dialog:SetLayout("Flow")
	
	local confirmText = AceGUI:Create("Label")
	confirmText:SetText(string.format(L["Are you sure you want to delete profile '%s'?"] or "Are you sure you want to delete profile '%s'?", profileName))
	confirmText:SetFullWidth(true)
	dialog:AddChild(confirmText)
	
	-- Button group
	local buttonGroup = AceGUI:Create("SimpleGroup")
	buttonGroup:SetFullWidth(true)
	buttonGroup:SetLayout("Flow")
	
	local deleteBtn = AceGUI:Create("Button")
	deleteBtn:SetText(L["Delete"] or "Delete")
	deleteBtn:SetWidth(100)
	deleteBtn:SetCallback("OnClick", function()
		GLDG.db:DeleteProfile(profileName)
		GLDG:Print(string.format(L["Profile '%s' deleted successfully"] or "Profile '%s' deleted successfully", profileName))
		dialog:Release()
		self:RefreshProfileList()
	end)
	buttonGroup:AddChild(deleteBtn)
	
	local cancelBtn = AceGUI:Create("Button")
	cancelBtn:SetText(L["Cancel"] or "Cancel")
	cancelBtn:SetWidth(100)
	cancelBtn:SetCallback("OnClick", function()
		dialog:Release()
	end)
	buttonGroup:AddChild(cancelBtn)
	
	dialog:AddChild(buttonGroup)
	dialog:BringToFront()
end
