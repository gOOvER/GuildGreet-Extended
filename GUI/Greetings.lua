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

-- Greeting categories
GreetingsGUI.categories = {
	"Greet", "Relog", "Join", "Level", "ByeChar", "NightChar", 
	"GreetGuild", "GreetChannel", "ByeGuild", "NightGuild", 
	"ByeChannel", "NightChannel", "LaterGuild", "LaterChannel"
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
	rightPanel:SetLayout("Fill")
	
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
	-- Collection dropdown
	local collectionDropdown = AceGUI:Create("Dropdown")
	collectionDropdown:SetLabel(L["Select Collection"] or "Select Collection")
	collectionDropdown:SetFullWidth(true)
	collectionDropdown:SetCallback("OnValueChanged", function(widget, event, key, value)
		self:SelectCollection(key)
	end)
	container:AddChild(collectionDropdown)
	
	-- Category list
	local categoryGroup = AceGUI:Create("InlineGroup")
	categoryGroup:SetTitle(L["Categories"] or "Categories")
	categoryGroup:SetFullWidth(true)
	categoryGroup:SetHeight(300)
	categoryGroup:SetLayout("List")
	
	for _, category in ipairs(self.categories) do
		local categoryButton = AceGUI:Create("InteractiveLabel")
		categoryButton:SetText(L[category] or category)
		categoryButton:SetFullWidth(true)
		categoryButton:SetCallback("OnClick", function()
			self:SelectCategory(category)
		end)
		categoryGroup:AddChild(categoryButton)
	end
	
	container:AddChild(categoryGroup)
	
	-- Store references
	self.collectionDropdown = collectionDropdown
	self.categoryGroup = categoryGroup
end

--[[
	Create messages list
]]
function GreetingsGUI:CreateMessagesList(container)
	-- Messages scroll frame
	local messagesFrame = AceGUI:Create("ScrollFrame")
	messagesFrame:SetFullWidth(true)
	messagesFrame:SetFullHeight(true)
	messagesFrame:SetLayout("Flow")
	
	-- Add/Edit controls
	local controlsGroup = AceGUI:Create("SimpleGroup")
	controlsGroup:SetFullWidth(true)
	controlsGroup:SetLayout("Flow")
	
	-- Add message button
	local addButton = AceGUI:Create("Button")
	addButton:SetText(L["Add Message"] or "Add Message")
	addButton:SetWidth(120)
	addButton:SetCallback("OnClick", function()
		self:ShowAddMessageDialog()
	end)
	controlsGroup:AddChild(addButton)
	
	-- Edit message button
	local editButton = AceGUI:Create("Button")
	editButton:SetText(L["Edit Message"] or "Edit Message")
	editButton:SetWidth(120)
	editButton:SetCallback("OnClick", function()
		self:ShowEditMessageDialog()
	end)
	controlsGroup:AddChild(editButton)
	
	-- Delete message button
	local deleteButton = AceGUI:Create("Button")
	deleteButton:SetText(L["Delete Message"] or "Delete Message")
	deleteButton:SetWidth(120)
	deleteButton:SetCallback("OnClick", function()
		self:DeleteSelectedMessage()
	end)
	controlsGroup:AddChild(deleteButton)
	
	messagesFrame:AddChild(controlsGroup)
	
	-- Messages list container
	local messagesList = AceGUI:Create("SimpleGroup")
	messagesList:SetFullWidth(true)
	messagesList:SetLayout("List")
	messagesFrame:AddChild(messagesList)
	
	container:AddChild(messagesFrame)
	
	-- Store references
	self.messagesFrame = messagesFrame
	self.messagesList = messagesList
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
	
	-- Add realm collections
	if GLDG_Data and GLDG_Data.GreetCollections then
		for name, collection in pairs(GLDG_Data.GreetCollections) do
			collections[name] = name
		end
	end
	
	self.collectionDropdown:SetList(collections)
	
	-- Select default if none selected
	if not self.selectedCollection then
		self.selectedCollection = "default"
		self.collectionDropdown:SetValue("default")
		self:SelectCollection("default")
	end
end

--[[
	Select a collection
]]
function GreetingsGUI:SelectCollection(collectionName)
	self.selectedCollection = collectionName
	self:RefreshMessagesList()
end

--[[
	Select a category
]]
function GreetingsGUI:SelectCategory(category)
	self.selectedCategory = category
	self:RefreshMessagesList()
	
	-- Update category selection visual feedback
	-- TODO: Add visual selection feedback
end

--[[
	Refresh messages list
]]
function GreetingsGUI:RefreshMessagesList()
	if not self.messagesList or not self.selectedCollection or not self.selectedCategory then
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
		messageLabel:SetText(string.format("%d. %s", i, message:sub(1, 80) .. (message:len() > 80 and "..." or "")))
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
		-- Use global default messages
		if GLDG_DataGreet and GLDG_DataGreet[category] then
			return GLDG_DataGreet[category]
		end
	else
		-- Use custom collection
		if GLDG_Data.GreetCollections and GLDG_Data.GreetCollections[collection] and 
		   GLDG_Data.GreetCollections[collection][category] then
			return GLDG_Data.GreetCollections[collection][category]
		end
	end
	return {}
end

--[[
	Select a message
]]
function GreetingsGUI:SelectMessage(index)
	self.selectedMessage = index
	-- TODO: Add visual selection feedback
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
		-- Initialize default messages if needed
		if not GLDG_DataGreet then GLDG_DataGreet = {} end
		if not GLDG_DataGreet[category] then GLDG_DataGreet[category] = {} end
		return GLDG_DataGreet[category]
	else
		-- Initialize custom collection if needed
		if not GLDG_Data.GreetCollections then GLDG_Data.GreetCollections = {} end
		if not GLDG_Data.GreetCollections[collection] then GLDG_Data.GreetCollections[collection] = {} end
		if not GLDG_Data.GreetCollections[collection][category] then 
			GLDG_Data.GreetCollections[collection][category] = {} 
		end
		return GLDG_Data.GreetCollections[collection][category]
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