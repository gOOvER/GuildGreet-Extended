--[[
	GuildGreet Greetings GUI Module
	Handles the Greetings tab interface
]]--

local GLDG = LibStub("AceAddon-3.0"):GetAddon("GuildGreet")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GuildGreet", false)

local GreetingsGUI = GLDG:NewModule("GreetingsGUI")

-- Current state
GreetingsGUI.selectedCollection = nil
GreetingsGUI.selectedCategory = "Greet"
GreetingsGUI.selectedMessage = nil

-- Greeting categories (must match defaults in GuildGreet.lua)
GreetingsGUI.categories = {
	"Greet", "GreetBack", "Welcome", "NewRank", "NewLevel", "Bye", "Night",
	"Guild", "Channel", "ByeGuild", "NightGuild", "ByeChannel", "NightChannel", 
	"LaterGuild", "LaterChannel", "Achievment"
}

--[[
	Create the Greetings tab content
]]
function GreetingsGUI:CreateTabContent(container)
	-- Main container with horizontal layout
	local mainGroup = AceGUI:Create("SimpleGroup")
	mainGroup:SetFullWidth(true)
	mainGroup:SetFullHeight(true)
	mainGroup:SetLayout("Flow")
	
	-- Left panel - Collections and Categories
	local leftPanel = AceGUI:Create("InlineGroup")
	leftPanel:SetTitle(L["Collections"] or "Collections")
	leftPanel:SetWidth(200)
	leftPanel:SetFullHeight(true)
	leftPanel:SetLayout("Flow")
	
	self:CreateCollectionsList(leftPanel)
	mainGroup:AddChild(leftPanel)
	
	-- Right panel - Messages
	local rightPanel = AceGUI:Create("InlineGroup")
	rightPanel:SetTitle(L["Messages"] or "Messages")
	rightPanel:SetRelativeWidth(0.75)
	rightPanel:SetFullHeight(true)
	rightPanel:SetLayout("Flow")
	
	self:CreateMessagesList(rightPanel)
	mainGroup:AddChild(rightPanel)
	
	container:AddChild(mainGroup)
	
	-- Store references
	self.leftPanel = leftPanel
	self.rightPanel = rightPanel
	
	-- Load initial data
	self:RefreshCollectionsList()
end

--[[
	Create collections list
]]
function GreetingsGUI:CreateCollectionsList(container)
	-- Collection dropdown and controls
	local collectionGroup = AceGUI:Create("SimpleGroup")
	collectionGroup:SetFullWidth(true)
	collectionGroup:SetLayout("Flow")
	
	local collectionDropdown = AceGUI:Create("Dropdown")
	collectionDropdown:SetLabel(L["Select Collection"] or "Select Collection")
	collectionDropdown:SetRelativeWidth(0.8)
	collectionDropdown:SetCallback("OnValueChanged", function(widget, event, key, value)
		self:SelectCollection(key)
	end)
	collectionGroup:AddChild(collectionDropdown)
	
	-- Add collection button
	local addCollectionBtn = AceGUI:Create("Button")
	addCollectionBtn:SetText(L["New"] or "New")
	addCollectionBtn:SetWidth(60)
	addCollectionBtn:SetCallback("OnClick", function()
		self:ShowAddCollectionDialog()
	end)
	collectionGroup:AddChild(addCollectionBtn)
	
	container:AddChild(collectionGroup)
	
	-- Category list
	local categoryGroup = AceGUI:Create("InlineGroup")
	categoryGroup:SetTitle(L["Categories"] or "Categories")
	categoryGroup:SetFullWidth(true)
	categoryGroup:SetHeight(300)
	categoryGroup:SetLayout("List")
	
	-- Store buttons for visual feedback updates
	self.categoryButtons = {}
	
	for _, category in ipairs(self.categories) do
		local categoryButton = AceGUI:Create("InteractiveLabel")
		local labelText = L[category] or category
		-- Color code selected category (yellow/gold)
		if category == self.selectedCategory then
			labelText = "|cffffff00" .. labelText .. "|r"  -- Yellow for selected
		else
			labelText = "|cffffffff" .. labelText .. "|r"  -- White for unselected
		end
		categoryButton:SetText(labelText)
		categoryButton:SetFullWidth(true)
		categoryButton:SetCallback("OnClick", function()
			self:SelectCategory(category)
		end)
		categoryGroup:AddChild(categoryButton)
		self.categoryButtons[category] = categoryButton
	end
	
	container:AddChild(categoryGroup)
	
	-- Store references
	self.collectionDropdown = collectionDropdown
	self.categoryGroup = categoryGroup
	
	-- Auto-select first category if none selected
	if not self.selectedCategory then
		self.selectedCategory = self.categories[1] or "Greet"
	end
end

--[[
	Create messages list
]]
function GreetingsGUI:CreateMessagesList(container)
	-- Messages frame with scroll
	local messagesFrame = AceGUI:Create("SimpleGroup")
	messagesFrame:SetFullWidth(true)
	messagesFrame:SetFullHeight(true)
	messagesFrame:SetLayout("Flow")
	
	-- Add/Edit controls group - horizontal layout
	local controlsGroup = AceGUI:Create("SimpleGroup")
	controlsGroup:SetFullWidth(true)
	controlsGroup:SetHeight(30)
	controlsGroup:SetLayout("Flow")
	
	-- Add message button
	local addButton = AceGUI:Create("Button")
	addButton:SetText(L["Add"] or "Add")
	addButton:SetWidth(80)
	addButton:SetCallback("OnClick", function()
		self:ShowAddMessageDialog()
	end)
	controlsGroup:AddChild(addButton)
	
	-- Edit message button
	local editButton = AceGUI:Create("Button")
	editButton:SetText(L["Edit"] or "Edit")
	editButton:SetWidth(80)
	editButton:SetCallback("OnClick", function()
		self:ShowEditMessageDialog()
	end)
	controlsGroup:AddChild(editButton)
	
	-- Delete message button
	local deleteButton = AceGUI:Create("Button")
	deleteButton:SetText(L["Delete"] or "Delete")
	deleteButton:SetWidth(80)
	deleteButton:SetCallback("OnClick", function()
		self:DeleteSelectedMessage()
	end)
	controlsGroup:AddChild(deleteButton)
	
	messagesFrame:AddChild(controlsGroup)
	
	-- Messages list container with scroll
	local messagesScroll = AceGUI:Create("ScrollFrame")
	messagesScroll:SetFullWidth(true)
	messagesScroll:SetHeight(400)
	messagesScroll:SetLayout("List")
	
	messagesFrame:AddChild(messagesScroll)
	
	container:AddChild(messagesFrame)
	
	-- Store references
	self.messagesFrame = messagesFrame
	self.messagesScroll = messagesScroll
	self.messagesList = messagesScroll  -- Keep both names for compatibility
	self.addButton = addButton
	self.editButton = editButton
	self.deleteButton = deleteButton
end

--[[
	Refresh collections list
]]
function GreetingsGUI:RefreshCollectionsList()
	if not self.collectionDropdown then return end
	
	local collections = {}
	collections["default"] = L["Default"] or "Default"
	
	-- Add custom collections
	if GLDG.db.global.GreetCollections then
		for name, collection in pairs(GLDG.db.global.GreetCollections) do
			collections[name] = name
		end
	end
	
	self.collectionDropdown:SetList(collections)
	
	-- Select default if none selected
	if not self.selectedCollection then
		self.selectedCollection = "default"
		self.collectionDropdown:SetValue("default")
		
		-- Ensure category is selected
		if not self.selectedCategory then
			self.selectedCategory = self.categories[1] or "Greet"
		end
		
		-- Refresh message list
		self:RefreshMessagesList()
	end
end

--[[
	Select a collection
]]
function GreetingsGUI:SelectCollection(collectionName)
	self.selectedCollection = collectionName
	
	-- If no category selected, select the first one
	if not self.selectedCategory then
		self.selectedCategory = self.categories[1]
	end
	
	self:RefreshMessagesList()
end

--[[
	Select a category
]]
function GreetingsGUI:SelectCategory(category)
	self.selectedCategory = category
	self:RefreshMessagesList()
	
	-- Update category selection visual feedback with colors
	if self.categoryButtons then
		for key, button in pairs(self.categoryButtons) do
			local labelText = L[key] or key
			if key == self.selectedCategory then
				labelText = "|cffffff00" .. labelText .. "|r"  -- Yellow for selected
			else
				labelText = "|cffffffff" .. labelText .. "|r"  -- White for unselected
			end
			button:SetText(labelText)
		end
	end
end

--[[
	Refresh messages list
]]
function GreetingsGUI:RefreshMessagesList()
	if not self.messagesList then
		return
	end
	
	if not self.selectedCollection or not self.selectedCategory then
		self.messagesList:ReleaseChildren()
		local noSelection = AceGUI:Create("Label")
		noSelection:SetText("No category selected")
		noSelection:SetFullWidth(true)
		self.messagesList:AddChild(noSelection)
		return
	end
	
	-- Clear current list
	self.messagesList:ReleaseChildren()
	
	-- Get messages for current collection and category
	local messages = self:GetMessages(self.selectedCollection, self.selectedCategory)
	
	if not messages or #messages == 0 then
		local noMessages = AceGUI:Create("Label")
		noMessages:SetText(L["No messages defined for this category"] or "No messages defined for this category")
		noMessages:SetFullWidth(true)
		self.messagesList:AddChild(noMessages)
		return
	end
	
	-- Add message entries
	for i, message in ipairs(messages) do
		local messageLabel = AceGUI:Create("InteractiveLabel")
		local labelText = string.format("%d. %s", i, message:sub(1, 80) .. (message:len() > 80 and "..." or ""))
		if i == self.selectedMessage then
			labelText = "> " .. labelText
		end
		messageLabel:SetText(labelText)
		messageLabel:SetFullWidth(true)
		messageLabel:SetCallback("OnClick", function()
			self:SelectMessage(i)
		end)
		self.messagesList:AddChild(messageLabel)
	end
end

--[[
	Get messages for collection and category
]]
function GreetingsGUI:GetMessages(collection, category)
	if collection == "default" then
		-- Use default messages from realm greetings
		if GLDG.db.realm.greetings and GLDG.db.realm.greetings[category] then
			return GLDG.db.realm.greetings[category]
		else
			-- Initialize if needed
			if not GLDG.db.realm.greetings then GLDG.db.realm.greetings = {} end
			if not GLDG.db.realm.greetings[category] then GLDG.db.realm.greetings[category] = {} end
			return GLDG.db.realm.greetings[category]
		end
	else
		-- Use custom collection from global
		if GLDG.db.global.GreetCollections and GLDG.db.global.GreetCollections[collection] and 
		   GLDG.db.global.GreetCollections[collection][category] then
			return GLDG.db.global.GreetCollections[collection][category]
		end
	end
	return {}
end

--[[
	Select a message
]]
function GreetingsGUI:SelectMessage(index)
	self.selectedMessage = index
	self:RefreshMessagesList()
end

--[[
	Show add collection dialog
]]
function GreetingsGUI:ShowAddCollectionDialog()
	local dialog = AceGUI:Create("Window")
	dialog:SetTitle(L["Create New Collection"] or "Create New Collection")
	dialog:SetWidth(400)
	dialog:SetHeight(150)
	dialog:SetLayout("Flow")
	
	-- Collection name input
	local nameEdit = AceGUI:Create("EditBox")
	nameEdit:SetLabel(L["Collection Name"] or "Collection Name")
	nameEdit:SetFullWidth(true)
	dialog:AddChild(nameEdit)
	
	-- Buttons
	local buttonGroup = AceGUI:Create("SimpleGroup")
	buttonGroup:SetFullWidth(true)
	buttonGroup:SetLayout("Flow")
	
	local createBtn = AceGUI:Create("Button")
	createBtn:SetText(L["Create"] or "Create")
	createBtn:SetWidth(100)
	createBtn:SetCallback("OnClick", function()
		local name = nameEdit:GetText()
		if name and name:trim() ~= "" then
			self:CreateCollection(name)
			dialog:Release()
		else
			GLDG:Print(L["Please enter a collection name"] or "Please enter a collection name")
		end
	end)
	buttonGroup:AddChild(createBtn)
	
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
	Create a new collection
]]
function GreetingsGUI:CreateCollection(collectionName)
	if not GLDG.db.global then GLDG.db.global = {} end
	if not GLDG.db.global.GreetCollections then GLDG.db.global.GreetCollections = {} end
	
	-- Check if collection already exists
	if GLDG.db.global.GreetCollections[collectionName] then
		GLDG:Print(L["Collection already exists"] or "Collection already exists")
		return
	end
	
	-- Create new empty collection with all categories
	GLDG.db.global.GreetCollections[collectionName] = {}
	for _, category in ipairs(self.categories) do
		GLDG.db.global.GreetCollections[collectionName][category] = {}
	end
	
	-- Refresh the dropdown and select the new collection
	self:RefreshCollectionsList()
	self:SelectCollection(collectionName)
	self.collectionDropdown:SetValue(collectionName)
	
	GLDG:Print(string.format(L["Collection created: %s"] or "Collection created: %s", collectionName))
end

--[[
	Show add message dialog
]]
function GreetingsGUI:ShowAddMessageDialog()
	local dialog = AceGUI:Create("Window")
	dialog:SetTitle(L["Add New Message"] or "Add New Message")
	dialog:SetWidth(500)
	dialog:SetHeight(300)
	dialog:SetLayout("Flow")
	
	-- Message text
	local messageEdit = AceGUI:Create("MultiLineEditBox")
	messageEdit:SetLabel(L["Message Text"] or "Message Text")
	messageEdit:SetFullWidth(true)
	messageEdit:SetHeight(150)
	dialog:AddChild(messageEdit)
	
	-- Buttons
	local buttonGroup = AceGUI:Create("SimpleGroup")
	buttonGroup:SetFullWidth(true)
	buttonGroup:SetLayout("Flow")
	
	local addBtn = AceGUI:Create("Button")
	addBtn:SetText(L["Add"] or "Add")
	addBtn:SetWidth(100)
	addBtn:SetCallback("OnClick", function()
		local text = messageEdit:GetText()
		if text and text:trim() ~= "" then
			self:AddMessage(text)
			dialog:Release()
		end
	end)
	buttonGroup:AddChild(addBtn)
	
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
	Add a new message
]]
function GreetingsGUI:AddMessage(messageText)
	-- Get or create message list
	local messages = self:GetMessagesRef(self.selectedCollection, self.selectedCategory)
	
	if messages then
		table.insert(messages, messageText)
		self:RefreshMessagesList()
	end
end

--[[
	Get reference to messages table for editing
]]
function GreetingsGUI:GetMessagesRef(collection, category)
	if collection == "default" then
		-- Initialize default messages if needed (realm greetings)
		if not GLDG.db.realm.greetings then GLDG.db.realm.greetings = {} end
		if not GLDG.db.realm.greetings[category] then GLDG.db.realm.greetings[category] = {} end
		return GLDG.db.realm.greetings[category]
	else
		-- Initialize custom collection if needed (global GreetCollections)
		if not GLDG.db.global.GreetCollections then GLDG.db.global.GreetCollections = {} end
		if not GLDG.db.global.GreetCollections[collection] then GLDG.db.global.GreetCollections[collection] = {} end
		if not GLDG.db.global.GreetCollections[collection][category] then 
			GLDG.db.global.GreetCollections[collection][category] = {} 
		end
		return GLDG.db.global.GreetCollections[collection][category]
	end
end

--[[
	Show edit message dialog
]]
function GreetingsGUI:ShowEditMessageDialog()
	if not self.selectedMessage then
		GLDG:Print(L["Please select a message to edit"] or "Please select a message to edit")
		return
	end
	
	local messages = self:GetMessages(self.selectedCollection, self.selectedCategory)
	if not messages or not messages[self.selectedMessage] then return end
	
	local dialog = AceGUI:Create("Window")
	dialog:SetTitle(L["Edit Message"] or "Edit Message")
	dialog:SetWidth(500)
	dialog:SetHeight(300)
	dialog:SetLayout("Flow")
	
	-- Message text
	local messageEdit = AceGUI:Create("MultiLineEditBox")
	messageEdit:SetLabel(L["Message Text"] or "Message Text")
	messageEdit:SetText(messages[self.selectedMessage])
	messageEdit:SetFullWidth(true)
	messageEdit:SetHeight(150)
	dialog:AddChild(messageEdit)
	
	-- Buttons
	local buttonGroup = AceGUI:Create("SimpleGroup")
	buttonGroup:SetFullWidth(true)
	buttonGroup:SetLayout("Flow")
	
	local saveBtn = AceGUI:Create("Button")
	saveBtn:SetText(L["Save"] or "Save")
	saveBtn:SetWidth(100)
	saveBtn:SetCallback("OnClick", function()
		local text = messageEdit:GetText()
		if text and text:trim() ~= "" then
			self:UpdateMessage(self.selectedMessage, text)
			dialog:Release()
		end
	end)
	buttonGroup:AddChild(saveBtn)
	
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
	Update a message
]]
function GreetingsGUI:UpdateMessage(index, newText)
	local messages = self:GetMessagesRef(self.selectedCollection, self.selectedCategory)
	
	if messages and messages[index] then
		messages[index] = newText
		self:RefreshMessagesList()
	end
end

--[[
	Delete selected message
]]
function GreetingsGUI:DeleteSelectedMessage()
	if not self.selectedMessage then
		GLDG:Print(L["Please select a message to delete"] or "Please select a message to delete")
		return
	end
	
	local messages = self:GetMessagesRef(self.selectedCollection, self.selectedCategory)
	
	if messages and messages[self.selectedMessage] then
		table.remove(messages, self.selectedMessage)
		self.selectedMessage = nil
		self:RefreshMessagesList()
	end
end