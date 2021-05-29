local function copyDiscord()
    setclipboard("https://www.discord.gg/arianagrande")
end

local StarterGui = game:GetService("StarterGui")
local bindable = Instance.new("BindableFunction")

local function sendNotification(titleText, descText)
    --print("notification")
    StarterGui:SetCore("SendNotification",{
        Title = titleText;
        Text = descText;
        Icon = "";
        Duration = 5;
    })
end

function bindable.OnInvoke(response)
    if response == "Yes" then
        copyDiscord()
        sendNotification("Link Copied!", "Thanks")
    else
        sendNotification("Join", "grande>>")
    end
end

StarterGui:SetCore("SendNotification", {
	Title = "Discord",
	Text = "Copy to clipboard?",
	Duration = 5,
	Callback = bindable,
	Button1 = "Yes",
	Button2 = "No"
})

local InfoModule = require(game.ReplicatedStorage.Modules.Info)
local MainFunctions = require(game:GetService("Players").LocalPlayer.PlayerGui.Gui.GuiModules.MainFunctions)
local inv = require(game:GetService("Players").LocalPlayer.PlayerGui.Gui.GuiModules.Inventory)
local AuctionFunctions = require(game:GetService("Players").LocalPlayer.PlayerGui.AuctionBoard.AuctionFunctions)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local List = LocalPlayer.PlayerGui.Gui.Frames.Inventory.SubInventory.Holder.List

local ClickRemote; do 
    local Clicker = LocalPlayer.PlayerGui.Gui.Hotbar.Clicker.Button
    if Clicker.Visible then
        for i,v in pairs(getconnections(Clicker.MouseButton1Click)) do
            ClickRemote = debug.getupvalue(v.Function,1)
        end
    end
end

local UpgradeClickRemote; local InventoryActionsRemote; local GamesActionsRemote; do 
    for i,v in pairs(getgc()) do 
        if type(v) == "function" and islclosure(v) and getfenv(v).script == game:GetService("Players").LocalPlayer.PlayerGui.Gui.GuiModules.Store then 
            local x = debug.getconstants(v)
            if table.find(x, "Upgrade") then
                UpgradeClickRemote = debug.getupvalue(v,1)
            end

        elseif type(v) == "function" and islclosure(v) and getfenv(v).script == LocalPlayer.PlayerGui.Gui.GuiModules.Inventory and not first then 
            local x = debug.getconstants(v)
            if table.find(x, "Equip") then
                InventoryActionsRemote = debug.getupvalue(v,2)
                first = true
            end

        elseif type(v) == "function" and islclosure(v) and getfenv(v).script == LocalPlayer.PlayerGui.AuctionBoard.Handler then 
            local x = debug.getconstants(v)
            if table.find(x, "AuctionBid") then
                GamesActionsRemote = debug.getupvalue(v,2)
            end
        end
    end
end

local OpenCaseRemote; do 
    local OpenCaseButton = game:GetService("Players").LocalPlayer.PlayerGui.Gui.Frames.Cases.Main.Display.Open
    if OpenCaseButton.Visible then
        for i,v in pairs(getconnections(OpenCaseButton.MouseButton1Click)) do
            OpenCaseRemote = debug.getupvalue(v.Function, 3)
        end
    end
end

        --      ["properties"] = {
        --          ["Price"]
        --      }
        --   }

local caseTypes = {}; do
    for caseName, caseInfo in pairs(InfoModule.Cases) do
     -- InfoModule:returnCaseBounds("name") to get bounds
        if caseInfo["Currency"] == "Robux" then
            caseTypes[caseName] = caseInfo
        end 
    end
end

local caseNames = {}; do
    for _, caseInfo in ipairs(MainFunctions:ReturnSortedDictionary(caseTypes, "Price", true)) do
        caseTypes[caseInfo.name] = caseInfo

        local price = caseInfo.properties.Price
        local name = caseInfo.name
        table.insert(caseNames, string.format("%s ($%d)", name, price))
    end
end

local lowestCaseToAutoBuy = caseNames[1]
local highestCaseToAutoBuy = caseNames[#caseNames]
local maxPrice = 50000
local jackpotTier = 1
local minJackpotChance = 95
local waitTime = .9
local quicksearch = false
local minAutomarketSell = 50000
local maxAutomarketSell = 9e9
local percentToMarketSell = 104/100
local maxPercentOfValueToBid = 70/100
local autoAuctionWaitTime = .9

local buyingCase = false

local function removeAllFromMarketPlace()
    for _, frame in pairs(LocalPlayer.PlayerGui.Gui.Frames.Market.SubMarket.Holder.List:GetChildren()) do
        if frame:IsA("Frame") and frame.Name == LocalPlayer.Name then
            local itemName = frame:WaitForChild("ItemName").Text
            spawn(function()
                local args = {
                    [1] = "Marketplace",
                    [2] = itemName
                }

                InventoryActionsRemote:InvokeServer(unpack(args))
            end)
        end
    end
    marketItemsLPInfo = {}
end

local function sellItem(itemName, amount)
    spawn(function()
	pcall(function()
       		List[itemName]:Destroy()
	end)
        local args = {
            [1] = "QuickSell",
            [2] = itemName,
            [3] = amount
        }
        InventoryActionsRemote:InvokeServer(unpack(args))
    end)
end

local function marketSellItem(itemName, amount, value)
    print(value)
    spawn(function()
        local args = {
            [1] = "Marketplace",
            [2] = itemName,
            [3] = value,
            [4] = amount
        }

        InventoryActionsRemote:InvokeServer(unpack(args))
    end)
end

local function getItemPrice(name, rolimonsVal)
    if rolimonsVal == "rolimonsValue" then
        return InfoModule:ReturnItemFromModule(name).rolimonsValue
    elseif rolimonsVal == "recentAveragePrice" then
        return InfoModule:ReturnItemFromModule(name).recentAveragePrice
    end
end

local function isValidItem(name, maxprice)
    local RAP = getItemPrice(name, "recentAveragePrice")
    local value = getItemPrice(name, "rolimonsValue")
    print(automarketplace, value >= minAutomarketSell, value <= maxAutomarketSell)
    if automarketplace and (value >= minAutomarketSell and value <= maxAutomarketSell) then
        return true, "marketsell", value * percentToMarketSell
    elseif (autosell and RAP <= maxPrice) and (not pureraponly or RAP == value) then
        return true, "sell"
    end
    return false
end

local items = {}
local function updateCurrentItems()
    --print("inventory scan")
    items = {}
    for i,v in pairs(List:GetChildren()) do
        if v:IsA("Frame") then
            if not items[v.Name] then
                items[v.Name] = 1
            else
                items[v.Name] = items[v.Name] + 1
            end
        end
    end
end
updateCurrentItems()

local function sellCurrentItems()
    updateCurrentItems()
    for itemName, amount in pairs(items) do
        local valid, sellType, value = isValidItem(itemName, maxPrice)
        if valid then
            if sellType == "sell" then
                sellItem(itemName, amount)
            elseif sellType == "marketsell" then
                marketSellItem(itemName, amount, value)
            end
        end
    end
end

List.ChildAdded:Connect(function(item)
    if item:IsA("Frame") then
        local valid, sellType, value = isValidItem(item.Name, maxPrice)
        if valid then
            if sellType == "sell" then
                sellItem(item.Name, amount)
            elseif sellType == "marketsell" then
                marketSellItem(item.Name, amount, value)
            end
        end
    end
end)

-- Keep the library files in the executor's workspace for local loading.
local MoneyLib = loadstring(readfile('moneylib.lua'))()

local NSumClosestLib = loadstring(readfile('NSumClosest.lua'))()

local function convertRobux(num)
    local shortValue = num
    local longValue = MoneyLib.ShortToLong(shortValue)
    return longValue 
end

