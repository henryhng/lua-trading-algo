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

