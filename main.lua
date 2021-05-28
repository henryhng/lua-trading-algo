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

