--// Services
local serv = {
	TextService = game:GetService("TextService");
	UserInputService = game:GetService("UserInputService");
}

--// Libraries
local Highlighter = require(script.Highlighter)
local HighlighterLanguage = require(script.Highlighter.lexer.language)

--// Types
type AutocompleteTarget = Frame & { Text: TextLabel, Image: ImageLabel }

--// Variables
local AutocompleteCharacters = {
	["\""] = "\"";
	["'"] = "'";
	["("] = ")";
	["["] = "]";
}
local AutocompleteWords do
	AutocompleteWords = {}
	for word, _ in pairs(HighlighterLanguage.keyword) do
		table.insert(AutocompleteWords, word)
	end
	for word, _ in pairs(HighlighterLanguage.builtin) do
		table.insert(AutocompleteWords, word)
	end
end

--// Instance creation related functions
local function CreateEditorInstance()
	local LuaTextBox = Instance.new("ScrollingFrame")
	LuaTextBox.Name = "LuaTextBox"
	LuaTextBox.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
	LuaTextBox.CanvasSize = UDim2.fromScale(0, 1)
	LuaTextBox.ElasticBehavior = Enum.ElasticBehavior.Never
	LuaTextBox.ScrollBarImageColor3 = Color3.fromRGB(88, 88, 88)
	LuaTextBox.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
	LuaTextBox.Active = true
	LuaTextBox.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
	LuaTextBox.BorderSizePixel = 0
	LuaTextBox.Size = UDim2.fromScale(1, 1)

	local EditorInput = Instance.new("TextBox")
	EditorInput.Name = "EditorInput"
	EditorInput.ClearTextOnFocus = false
	EditorInput.MultiLine = true
	EditorInput.CursorPosition = -1
	EditorInput.FontFace = Font.fromEnum(Enum.Font.Code)
	EditorInput.Text = ""
	EditorInput.TextColor3 = Color3.fromRGB(204, 204, 204)
	EditorInput.TextSize = 16
	EditorInput.TextXAlignment = Enum.TextXAlignment.Left
	EditorInput.TextYAlignment = Enum.TextYAlignment.Top
	EditorInput.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
	EditorInput.BackgroundTransparency = 1
	EditorInput.Position = UDim2.fromOffset(53, 5)
	EditorInput.Size = UDim2.new(1, -53, 1, -5)
	EditorInput.Parent = LuaTextBox

	local LineMarkers = Instance.new("Frame")
	LineMarkers.Name = "LineMarkers"
	LineMarkers.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
	LineMarkers.BorderSizePixel = 0
	LineMarkers.Size = UDim2.new(0, 48, 1, 0)

	local LinesBG = Instance.new("Frame")
	LinesBG.Name = "LinesBG"
	LinesBG.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
	LinesBG.BorderSizePixel = 0
	LinesBG.Size = UDim2.new(1, -16, 1, 0)

	local Lines = Instance.new("Frame")
	Lines.Name = "Lines"
	Lines.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
	Lines.BorderSizePixel = 0
	Lines.Position = UDim2.fromOffset(0, 5)
	Lines.Size = UDim2.new(1, 0, 1, -5)

	local LinesUILL = Instance.new("UIListLayout")
	LinesUILL.Name = "LinesUILL"
	LinesUILL.Padding = UDim.new(0, 2)
	LinesUILL.SortOrder = Enum.SortOrder.LayoutOrder
	LinesUILL.Parent = Lines

	local L1 = Instance.new("TextButton")
	L1.Name = "L1"
	L1.FontFace = Font.fromEnum(Enum.Font.Code)
	L1.Text = "1"
	L1.TextColor3 = Color3.fromRGB(255, 255, 255)
	L1.TextSize = 16
	L1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	L1.BackgroundTransparency = 1
	L1.BorderSizePixel = 0
	L1.Size = UDim2.new(1, 0, 0, 16)
	L1.Parent = Lines

	Lines.Parent = LinesBG
	LinesBG.Parent = LineMarkers
	LineMarkers.Parent = LuaTextBox
	return LuaTextBox, EditorInput, L1
end

local function CreateAutocompleteFrame(maxats: number?)
	local AutocompleteFrame = Instance.new("Frame")
	AutocompleteFrame.Name = "AutocompleteFrame"
	AutocompleteFrame.BackgroundColor3 = Color3.fromRGB(46, 46, 46)
	AutocompleteFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	AutocompleteFrame.Size = UDim2.fromOffset(250, 125)
	
	local AutocompleteTargets = {}
	for i = 1, maxats or 5, 1 do
		local AutocompleteTarget = Instance.new("Frame")
		AutocompleteTarget.Name = "AutocompleteTarget"..i
		AutocompleteTarget.BackgroundColor3 = Color3.fromRGB(38, 90, 169)
		AutocompleteTarget.BackgroundTransparency = 1
		AutocompleteTarget.Size = UDim2.new(1, 0, 0, 25)
		AutocompleteTarget.Position = UDim2.new(0, 0, 0, (i * 25) - 25)

		local Text = Instance.new("TextLabel")
		Text.Name = "Text"
		Text.FontFace = Font.fromEnum(Enum.Font.Code)
		Text.TextColor3 = Color3.fromRGB(255, 255, 255)
		Text.TextSize = 16
		Text.TextXAlignment = Enum.TextXAlignment.Left
		Text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Text.BackgroundTransparency = 1
		Text.BorderSizePixel = 0
		Text.Position = UDim2.fromOffset(30, 0)
		Text.Size = UDim2.new(1, -30, 1, 0)
		Text.Parent = AutocompleteTarget

		local Image = Instance.new("ImageLabel")
		Image.Name = "Image"
		Image.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		Image.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Image.BackgroundTransparency = 1
		Image.BorderSizePixel = 0
		Image.Position = UDim2.fromOffset(5, 5)
		Image.Size = UDim2.new(1, -10, 1, -10)

		local ImageUIARC = Instance.new("UIAspectRatioConstraint")
		ImageUIARC.Name = "ImageUIARC"
		ImageUIARC.Parent = Image

		Image.Parent = AutocompleteTarget
		AutocompleteTarget.Parent = AutocompleteFrame
		table.insert(AutocompleteTargets, AutocompleteTarget)
	end
	
	return AutocompleteFrame, AutocompleteTargets
end

--// Misc/utility functions
local function DisconnectAll(connections)
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end
	return
end

--[[
local function ChangeTabsToSpaces(str: string)
	return string.gsub(str, "\t", "    ")
end
--]]

local function RemoveControlBytes(str: string)
	return string.gsub(str, "[\0\1\2\3\4\5\6\7\8\11\12\13\14\15\16\17\18\19\20\21\22\23\24\25\26\27\28\29\30\31]+", "")
end

--// https://devforum.roblox.com/t/stringfind-error-unfinished-capture/939588/14
--// To fix the "unfinished capture" error
local function EscapeSpecialChars(x)
	return (x:gsub('%%', '%%%%')
		:gsub('^%^', '%%^')
		:gsub('%$$', '%%$')
		:gsub('%(', '%%(')
		:gsub('%)', '%%)')
		:gsub('%.', '%%.')
		:gsub('%[', '%%[')
		:gsub('%]', '%%]')
		:gsub('%*', '%%*')
		:gsub('%+', '%%+')
		:gsub('%-', '%%-')
		:gsub('%?', '%%?'))
end

--// Autocomplete related functions
local function AutocompleteReplace(text: string, targetword: string, replacement: string, cpuaw: number, removefirsttab: boolean?)
	local AfterCPUAW = string.gsub(string.sub(text, cpuaw, #text), targetword, replacement, 1)
	if removefirsttab then
		AfterCPUAW = string.gsub(AfterCPUAW, "\t", "", 1)
	end
	return string.sub(text, 1, cpuaw)..AfterCPUAW, cpuaw + #replacement + 1
end

local function UpdateAutocompleteSelection(targets: { Frame }, index: number)
	for i, target in ipairs(targets) do
		target.BackgroundTransparency = if i == index then 0 else 1
	end
	return
end

local function FillAutocompleteSelections(acframe: Frame, targets: { AutocompleteTarget }, words: {string}, index: number, editorinput: TextBox?)
	--// If there are lesser words than the target then return
	if (#words - index) < #targets - 1 then return end
	
	--// Resetting everything
	for _, target in ipairs(targets) do
		if not target:FindFirstChild("Text") then continue end
		target.Visible = false
		target.Text.Text = ""
	end
	
	--// If there are no words then return
	if #words == 0 then return end

	--// Compute X offset for the frame size
	local FrameXOffset do
		FrameXOffset = 0
		for _, word in ipairs(words) do
			local FontSize = if editorinput then editorinput.TextSize else 16
			local Font = if editorinput then editorinput.Font else Enum.Font.Code
			local XBound = serv.TextService:GetTextSize(word, FontSize, Font, Vector2.new(0, math.huge)).X
			if FrameXOffset > XBound then
				FrameXOffset = XBound
			end
		end
	end
	
	--// Filling the selections
	local CurrentTargetIndex, MaxTargetIndex = 1, #targets
	for i = index, #words, 1 do
		local AutocompleteTarget = targets[CurrentTargetIndex]
		--// print(i, words[i])
		if words[i] then
			AutocompleteTarget.Text.Text = words[i]
			AutocompleteTarget.Visible = true
			acframe.Size = UDim2.new(0, FrameXOffset, 0, CurrentTargetIndex * 25)
		else
			break
		end
		if CurrentTargetIndex >= MaxTargetIndex then break end
		CurrentTargetIndex += 1
	end
	
	return
end

local LuaTextBox = {}
LuaTextBox.__index = LuaTextBox
LuaTextBox.__tostring = function(self) return if self.Instance then self.Instance.Name else "LuaTextBox" end
LuaTextBox.__metatable = "This metatable is locked"

function LuaTextBox:SetName(name: string)
	assert(typeof(name) == "string", "invalid argument #1 to 'SetName' (string expected, got "..typeof(name)..")")
	self.Name = name
	self.Instance.Name = name
	return
end

function LuaTextBox:SetParent(parent: Instance?)
	assert((typeof(parent) == "nil") or (typeof(parent) == "Instance"), "invalid argument #1 to 'SetParent' (Instance or nil expected, got "..typeof(parent)..")")
	self.Parent = parent
	self.Instance.Parent = parent
	return
end

function LuaTextBox:DoAutocomplete(word: string, cpuaw: number)
	--// Variables
	local AutocompleteFrame: Frame = self.AutocompleteFrame
	local AutocompleteTargets: { AutocompleteTarget } = self.AutocompleteTargets
	local AutocompleteConnections: { any } = self.AutocompleteConnections
	local EditorInput: TextBox = self.EditorInput
	local Text = RemoveControlBytes(EditorInput.Text)

	--// Resetting the frame state
	self:TerminateCurrentAutocompleteSession()

	--// If the word is something we can't autocomplete then return
	if (not word) or (word == "") or (word == " ") or (word == "   ") or (word == "\t") then return end

	--// Debounce check
	if not self.__WordAutocompleteDebounce then
		self.__WordAutocompleteDebounce = true
		return
	end

	--// Compile word array
	local PossibleWords = {}
	for _, v in ipairs(AutocompleteWords) do
		if string.find(EscapeSpecialChars(v), EscapeSpecialChars(word)) and #v >= #word then
			table.insert(PossibleWords, v)
		end
	end

	--// If no possible words then return
	if #PossibleWords == 0 then return end

	--// More variables
	--// TSI - 1 - 5 (in range of max usable autocomplete targets)
	--// TI - in the range of PossibleWords - max usable autocomplete targets
	--// WSI - in the range of PossibleWords
	--// local MaxUsableAutocompleteTargets = if #PossibleWords > #AutocompleteTargets then #AutocompleteTargets else #PossibleWords
	local MaxTargetIndexBoundByMaxUsableTargets = if (#PossibleWords - #AutocompleteTargets) > 0 then (#PossibleWords - #AutocompleteTargets) + 1 else #PossibleWords
	local TargetSelectionIndex = 1
	local TargetIndex = 1
	local WordSelectionIndex = 1
	FillAutocompleteSelections(AutocompleteFrame, AutocompleteTargets, PossibleWords, TargetIndex, EditorInput)
	UpdateAutocompleteSelection(AutocompleteTargets, TargetSelectionIndex)

	--// Disable multiline input temporarily
	EditorInput.MultiLine = false

	--// InputBegan hooks to up, down, return (enter), tab
	table.insert(AutocompleteConnections, serv.UserInputService.InputBegan:Connect(function(inputobj: InputObject)
		if (inputobj.KeyCode == Enum.KeyCode.Up) then
			TargetSelectionIndex -= 1
			WordSelectionIndex -= 1
			if TargetSelectionIndex < 1 then
				TargetSelectionIndex = 1
				TargetIndex -= 1
			end
			if TargetIndex < 1 then TargetIndex = 1 end
			if WordSelectionIndex < 1 then WordSelectionIndex = 1 end
		elseif (inputobj.KeyCode == Enum.KeyCode.Down) then
			TargetSelectionIndex += 1
			WordSelectionIndex += 1
			if TargetSelectionIndex > #AutocompleteTargets then
				TargetSelectionIndex = #AutocompleteTargets
				TargetIndex += 1
			end
			if TargetIndex > MaxTargetIndexBoundByMaxUsableTargets then TargetIndex = MaxTargetIndexBoundByMaxUsableTargets end
			if WordSelectionIndex >= #PossibleWords then WordSelectionIndex = #PossibleWords end
		elseif (inputobj.KeyCode == Enum.KeyCode.Return) or (inputobj.KeyCode == Enum.KeyCode.Tab) then
			self.__WordAutocompleteDebounce = false
			task.defer(function()
				self:TerminateCurrentAutocompleteSession()
				local Replacement, NewCursorPos = AutocompleteReplace(Text, word, PossibleWords[WordSelectionIndex], cpuaw, inputobj.KeyCode == Enum.KeyCode.Tab)
				EditorInput.Text = Replacement
				EditorInput.CursorPosition = NewCursorPos
			end)
			return
		elseif (inputobj.KeyCode == Enum.KeyCode.Escape) then
			self:TerminateCurrentAutocompleteSession()
			return
		end

		--// Refill and update selection as needed
		--// print("TI:", TargetIndex, "TSI:", TargetSelectionIndex, "WSI:", WordSelectionIndex)
		FillAutocompleteSelections(AutocompleteFrame, AutocompleteTargets, PossibleWords, TargetIndex, EditorInput)
		UpdateAutocompleteSelection(AutocompleteTargets, TargetSelectionIndex)
		return
	end))

	local AutocompleteFramePosition do
		local Bounds = serv.TextService:GetTextSize(string.sub(Text, 1, EditorInput.CursorPosition), EditorInput.TextSize, EditorInput.Font, Vector2.new(0, math.huge))
		local AbsolutePos = EditorInput.AbsolutePosition
		AutocompleteFramePosition = UDim2.new(0, AbsolutePos.X + Bounds.X, 0, AbsolutePos.Y + Bounds.Y)
	end
	AutocompleteFrame.Position = AutocompleteFramePosition
	AutocompleteFrame.Visible = true
	return
end

function LuaTextBox:IsAutocompleting()
	return self.AutocompleteFrame.Visible and #self.AutocompleteConnections >= 1
end

function LuaTextBox:TerminateCurrentAutocompleteSession()
	DisconnectAll(self.AutocompleteConnections)
	table.clear(self.AutocompleteConnections)
	self.EditorInput.MultiLine = true
	self.AutocompleteFrame.Visible = false
	return
end

local function constructor_LuaTextBox(autocompletetargetamount: number?): LuaTextBox
	local LEInstance, EditorInput, L1 = CreateEditorInstance()
	local AutocompleteFrame, AutocompleteTargets = CreateAutocompleteFrame(autocompletetargetamount or 5)
	local NewLE = setmetatable({
		Name = "LuaTextBox";
		Parent = nil;
		Instance = LEInstance;
		
		EditorInput = EditorInput;
		Text = "";
		CursorPosition = -1;
		SelectionStart = -1;
		
		AutocompleteFrame = AutocompleteFrame;
		AutocompleteTargets = AutocompleteTargets;
		AutocompleteConnections = {};
		__CharAutocompleteDebounce = true;
		__WordAutocompleteDebounce = true;
	}, LuaTextBox)
	
	EditorInput.ZIndex = 1
	AutocompleteFrame.ZIndex = 2
	AutocompleteFrame.Visible = false
	AutocompleteFrame.Parent = LEInstance
	
	EditorInput:GetPropertyChangedSignal("Text"):Connect(function()
		local Text = RemoveControlBytes(EditorInput.Text)
		local CursorPosition = EditorInput.CursorPosition
		local TotalLines = #(string.split(Text, "\n"))
		local MarkedLines = L1.Parent:GetChildren()
		local AddedChars = string.sub(Text, CursorPosition - 1, CursorPosition - 1)
		local AddedWord, CursorPosUntilAddedWord do
			local TextTable =  string.split(string.gsub(Text, "    ", "\n"), " ")
			AddedWord = table.remove(TextTable, #TextTable)
			AddedWord = string.gsub(AddedWord, "\t", "")
			AddedWord = string.gsub(AddedWord, "\n", "")
			TextTable = table.concat(TextTable, " ")
			CursorPosUntilAddedWord = if #TextTable == 0 then 0 else #TextTable + #(" ")
		end
		
		--// Simple character autocompletion
		if NewLE.__CharAutocompleteDebounce and AutocompleteCharacters[AddedChars] then
			NewLE.__CharAutocompleteDebounce = false
			EditorInput.Text = string.sub(Text, 1, CursorPosition - 1)..AutocompleteCharacters[AddedChars]..string.sub(Text, CursorPosition)
			return
		else
			NewLE.__CharAutocompleteDebounce = true
		end
		
		--// Trigger word autocomplete
		NewLE:DoAutocomplete(AddedWord, CursorPosUntilAddedWord)
		
		--// Line markers
		if (#MarkedLines - 1) < TotalLines then
			for i = #MarkedLines, TotalLines, 1 do
				local LineMarker = L1:Clone()
				LineMarker.Name = "L"..i
				LineMarker.Text = i
				LineMarker.Parent = L1.Parent
			end
		elseif (#MarkedLines - 1) > TotalLines then
			for i = TotalLines + 2, #MarkedLines do
				MarkedLines[i]:Destroy()
			end
		end
		
		--// Syntax highlighting
		Highlighter.highlight({
			textObject = EditorInput;
			src = Text;
			forceUpdate = false;
		})
		
		--// Update Text field in the object and return
		NewLE.Text = Text
		return
	end)
	
	--[[
	EditorInput.FocusLost:Connect(function()
		DisconnectAll(NewLE.AutocompleteConnections)
		EditorInput.MultiLine = true
		NewLE.AutocompleteFrame.Visible = false
	end)
	--]]
	
	EditorInput:GetPropertyChangedSignal("CursorPosition"):Connect(function()
		NewLE.CursorPosition = EditorInput.CursorPosition
		
		local AddedWord, CursorPosUntilAddedWord do
			local TextTable = string.split(string.gsub(string.sub(EditorInput.Text, 1, EditorInput.CursorPosition), "    ", "\n"), " ")
			AddedWord = table.remove(TextTable, #TextTable)
			AddedWord = string.gsub(AddedWord, "\t", "")
			AddedWord = string.gsub(AddedWord, "\n", "")
			TextTable = table.concat(TextTable, " ")
			CursorPosUntilAddedWord = if #TextTable == 0 then 0 else #TextTable + #(" ")
		end
		NewLE:DoAutocomplete(AddedWord, CursorPosUntilAddedWord)
		return
	end)
	
	EditorInput:GetPropertyChangedSignal("SelectionStart"):Connect(function()	
		NewLE.SelectionStart = EditorInput.SelectionStart
		return
	end)
	
	return NewLE
end
export type LuaTextBox = typeof(constructor_LuaTextBox())
return setmetatable({ new = constructor_LuaTextBox }, { __call = function(_, ...)  return constructor_LuaTextBox(...) end })