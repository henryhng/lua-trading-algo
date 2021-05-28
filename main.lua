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

