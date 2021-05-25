--[[
	not my library but i eventually want to make the option holders text pink and have the windows text bigger than the folders text
    also added the ability to update the options
]]

--// Non-Synapse Users
if not pcall(function() return syn.protect_gui end) then
    syn = {}
    syn.protect_gui = function(egg)
        egg.Parent = game.CoreGui
    end
end

local library = {flags = {}, windows = {}, open = true}

--Services
local runService = game:GetService"RunService"
local tweenService = game:GetService"TweenService"
local textService = game:GetService"TextService"
local inputService = game:GetService"UserInputService"

--Locals
local dragging, dragInput, dragStart, startPos, dragObject

local blacklistedKeys = { --add or remove keys if you find the need to
	Enum.KeyCode.Unknown,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Slash,Enum.KeyCode.Tab,Enum.KeyCode.Backspace,Enum.KeyCode.Escape
}
local whitelistedMouseinputs = { --add or remove mouse inputs if you find the need to
	Enum.UserInputType.MouseButton1,Enum.UserInputType.MouseButton2,Enum.UserInputType.MouseButton3
}

--Functions
local function round(num, bracket)
    --print("rounding")
	bracket = bracket or 1
	local a = math.floor(num/bracket + (math.sign(num) * 0.5)) * bracket
	if a < 0 then
		a = a + bracket
	end
	return a
end

local function keyCheck(x,x1)
	for _,v in next, x1 do
		if v == x then
			return true
		end
	end
end

local function update(input)
	local delta = input.Position - dragStart
	local yPos = (startPos.Y.Offset + delta.Y) < -36 and -36 or startPos.Y.Offset + delta.Y
	dragObject:TweenPosition(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, yPos), "Out", "Quint", 0.1, true)
end

--From: https://devforum.roblox.com/t/how-to-create-a-simple-rainbow-effect-using-tweenService/221849/2
local chromaColor
local rainbowTime = 5
spawn(function()
	while wait() do
		chromaColor = Color3.fromHSV(tick() % rainbowTime / rainbowTime, 1, 1)
	end
end)

function library:Create(class, properties)
	properties = typeof(properties) == "table" and properties or {}
	local inst = Instance.new(class)
	for property, value in next, properties do
		inst[property] = value
	end
	return inst
end

local function createOptionHolder(holderTitle, parent, parentTable, subHolder)
	local size = subHolder and 32 or 32
	parentTable.main = library:Create("ImageButton", {
		LayoutOrder = subHolder and parentTable.position or 0,
		Position = UDim2.new(0, 20 + (250 * (parentTable.position or 0)), 0, 20),
		Size = UDim2.new(0, 230, 0, size),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(20, 20, 20),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.04,
		ClipsDescendants = true,
		Parent = parent
	})
	
	local round
	if not subHolder then
		round = library:Create("ImageLabel", {
			Size = UDim2.new(1, 0, 0, size),
			BackgroundTransparency = 1,
			Image = "rbxassetid://3570695787",
			ImageColor3 = parentTable.open and (subHolder and Color3.fromRGB(16, 16, 16) or Color3.fromRGB(10, 10, 10)) or (subHolder and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(6, 6, 6)),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(100, 100, 100, 100),
			SliceScale = 0.1,
			Parent = parentTable.main
		})
	end

	local title = library:Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, size),
		BackgroundTransparency = subHolder and 0 or 1,
		BackgroundColor3 = Color3.fromRGB(10, 10, 10),
		BorderSizePixel = 0,
		Text = holderTitle,
		TextSize = 15,
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Parent = parentTable.main
	})
	
	local closeHolder = library:Create("Frame", {
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(-1, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Parent = title
	})
	
	local close = library:Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, -size - 10, 1, -size - 10),
		Rotation = parentTable.open and 90 or 180,
		BackgroundTransparency = 1,
		Image = "rbxassetid://4918373417",
		ImageColor3 = parentTable.open and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30),
		ScaleType = Enum.ScaleType.Fit,
		Parent = closeHolder
	})
	
	parentTable.content = library:Create("Frame", {
		Position = UDim2.new(0, 0, 0, size),
		Size = UDim2.new(1, 0, 1, -size),
		BackgroundTransparency = 1,
		Parent = parentTable.main
	})
	
	local layout = library:Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = parentTable.content
	})
	
	layout.Changed:connect(function()
		parentTable.content.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
		parentTable.main.Size = #parentTable.options > 0 and parentTable.open and UDim2.new(0, 230, 0, layout.AbsoluteContentSize.Y + size) or UDim2.new(0, 230, 0, size)
	end)
	
	if not subHolder then
		library:Create("UIPadding", {
			Parent = parentTable.content
		})
		
		title.InputBegan:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragObject = parentTable.main
				dragging = true
				dragStart = input.Position
				startPos = dragObject.Position
			end
		end)
		title.InputChanged:connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				dragInput = input
			end
		end)
			title.InputEnded:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
	end
	
	closeHolder.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			parentTable.open = not parentTable.open
			tweenService:Create(close, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = parentTable.open and 90 or 180, ImageColor3 = parentTable.open and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30)}):Play()
			if subHolder then
				tweenService:Create(title, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = parentTable.open and Color3.fromRGB(16, 16, 16) or Color3.fromRGB(10, 10, 10)}):Play()
			else
				tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = parentTable.open and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(6, 6, 6)}):Play()
			end
			parentTable.main:TweenSize(#parentTable.options > 0 and parentTable.open and UDim2.new(0, 230, 0, layout.AbsoluteContentSize.Y + size) or UDim2.new(0, 230, 0, size), "Out", "Quad", 0.2, true)
		end
	end)

	function parentTable:SetTitle(newTitle)
		title.Text = tostring(newTitle)
	end
	
	return parentTable
end
	
local function createLabel(option, parent)
	local main = library:Create("TextLabel", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Text = " " .. option.text,
		TextSize = 15,
		Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(149, 86, 191),
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = parent.content
	})
	
	setmetatable(option, {__newindex = function(t, i, v)
		if i == "Text" then
			main.Text = " " .. tostring(v)
		end
	end})
end

function createToggle(option, parent)
    --print("toggle state")
	local main = library:Create("TextLabel", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 31),
		BackgroundTransparency = 1,
		Text = " " .. option.text,
		TextSize = 15,
		Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = parent.content
	})
	
	local tickboxOutline = library:Create("ImageLabel", {
		Position = UDim2.new(1, -6, 0, 4),
		Size = UDim2.new(-1, 10, 1, -10),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = option.state and Color3.fromRGB(159, 104, 196) or Color3.fromRGB(145, 66, 201),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = main
	})
	
	local tickboxInner = library:Create("ImageLabel", {
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = option.state and Color3.fromRGB(159, 104, 196) or Color3.fromRGB(20, 20, 20),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = tickboxOutline
	})
	
	local checkmarkHolder = library:Create("Frame", {
		Position = UDim2.new(0, 4, 0, 4),
		Size = option.state and UDim2.new(1, -8, 1, -8) or UDim2.new(0, 0, 1, -8),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = tickboxOutline
	})
	
	local checkmark = library:Create("ImageLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Image = "rbxassetid://4919148038",
		ImageColor3 = Color3.fromRGB(20, 20, 20),
		Parent = checkmarkHolder
	})
	
	local inContact
	main.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			option:SetState(not option.state)
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not option.state then
				tweenService:Create(tickboxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(159, 104, 196)}):Play()
			end
		end
	end)
	
	main.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not option.state then
				tweenService:Create(tickboxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(149, 86, 191)}):Play()
			end
		end
	end)
	
	function option:SetState(state)
		library.flags[self.flag] = state
		self.state = state
		checkmarkHolder:TweenSize(option.state and UDim2.new(1, -8, 1, -8) or UDim2.new(0, 0, 1, -8), "Out", "Quad", 0.2, true)
		tweenService:Create(tickboxInner, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = state and Color3.fromRGB(149, 86, 191) or Color3.fromRGB(20, 20, 20)}):Play()
		if state then
			tweenService:Create(tickboxOutline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(149, 86, 191)}):Play()
		else
			if inContact then
				tweenService:Create(tickboxOutline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(159, 104, 196)}):Play()
			else
				tweenService:Create(tickboxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(149, 86, 191)}):Play()
			end
		end
		self.callback(state)
	end

    function option:UpdateState()
		self:SetState(option.state)
	end

	if option.state then
		delay(1, function() option.callback(true) end)
	end
	
	setmetatable(option, {__newindex = function(t, i, v)
		if i == "Text" then
			main.Text = " " .. tostring(v)
		end
	end})
end


return library
