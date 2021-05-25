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
    print("rounding")
	bracket = bracket or 1
	local a = math.floor(num/bracket) * bracket
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


return library
