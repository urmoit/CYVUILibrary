--[[
    CYVUI Library — Example Script
    Demonstrates Home tab layout matching the design reference
    + standard tabs with toggles, sliders, buttons, etc.
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_REPO/CYVUI/main/Library.lua"))()
-- Or require locally:
-- local Library = require(path.to.Library)

local Window = Library:CreateWindow({
    Title    = "CYVHUB",
    GameName = "game name",
    Version  = "v1.0",
    Size     = UDim2.new(0, 720, 0, 500),
})

-- ═══════════════════════════════════════════
-- HOME TAB (matches screenshot layout)
-- ═══════════════════════════════════════════
local Home = Window:CreateTab({
    Name = "Home",
    Icon = "⌂",
    Home = true,
})

local HomeLayout = Home:CreateHomeLayout({
    Username     = game.Players.LocalPlayer.DisplayName,
    Welcome      = "welcome back",
    AboutTitle   = "About",
    AboutText    = "CYVHUB is a multi-game script hub built with CYVUI. Clean, fast, and modular. Join the Discord for updates and support.",
    DiscordLink  = "https://discord.gg/cyvhub",
    ServerInfo   = string.format(
        "Players: %d / %d\nJobId: %s\nPlaceId: %d",
        #game.Players:GetPlayers(),
        game.Players.MaxPlayers,
        game.JobId:sub(1, 16) .. "...",
        game.PlaceId
    ),
    ExecutorName = (identifyexecutor and identifyexecutor()) or "Unknown",
    Changelog    = {
        { Version = "v1.0.0", Text = "Initial CYVUI Library release." },
        { Version = "v0.9.2", Text = "Home layout cards, Discord copy, server info." },
        { Version = "v0.9.0", Text = "Sidebar tabs, theme system, notifications." },
        { Version = "v0.8.0", Text = "Toggles, sliders, dropdowns, keybinds." },
    },
})

-- ═══════════════════════════════════════════
-- MAIN / FEATURES TAB
-- ═══════════════════════════════════════════
local Main = Window:CreateTab({
    Name = "Main",
    Icon = "⚡",
})

local Combat = Main:CreateSection("Combat")
Combat:AddToggle({
    Text = "Aimbot",
    Default = false,
    Flag = "Aimbot",
    Callback = function(v)
        print("Aimbot:", v)
    end,
})
Combat:AddToggle({
    Text = "Silent Aim",
    Default = false,
    Flag = "SilentAim",
    Callback = function(v)
        print("Silent Aim:", v)
    end,
})
Combat:AddSlider({
    Text = "FOV",
    Min = 50,
    Max = 400,
    Default = 120,
    Flag = "FOV",
    Callback = function(v)
        print("FOV:", v)
    end,
})
Combat:AddDropdown({
    Text = "Target Part",
    Options = { "Head", "Torso", "HumanoidRootPart" },
    Default = "Head",
    Flag = "TargetPart",
    Callback = function(v)
        print("Target:", v)
    end,
})

local Visuals = Main:CreateSection("Visuals")
Visuals:AddToggle({
    Text = "ESP",
    Default = false,
    Flag = "ESP",
})
Visuals:AddToggle({
    Text = "Tracers",
    Default = false,
    Flag = "Tracers",
})
Visuals:AddToggle({
    Text = "Box ESP",
    Default = false,
    Flag = "BoxESP",
})
Visuals:AddSlider({
    Text = "ESP Distance",
    Min = 100,
    Max = 2000,
    Default = 500,
    Flag = "ESPDistance",
})

-- ═══════════════════════════════════════════
-- PLAYER TAB
-- ═══════════════════════════════════════════
local Player = Window:CreateTab({
    Name = "Player",
    Icon = "👤",
})

local Movement = Player:CreateSection("Movement")
Movement:AddToggle({
    Text = "Speed Hack",
    Default = false,
    Flag = "Speed",
    Callback = function(v)
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = v and (Library:GetFlag("SpeedValue") or 50) or 16
        end
    end,
})
Movement:AddSlider({
    Text = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 50,
    Flag = "SpeedValue",
    Callback = function(v)
        if Library:GetFlag("Speed") then
            local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end
    end,
})
Movement:AddToggle({
    Text = "Infinite Jump",
    Default = false,
    Flag = "InfJump",
})
Movement:AddKeybind({
    Text = "Fly Key",
    Default = Enum.KeyCode.F,
    Flag = "FlyKey",
    Callback = function(key)
        print("Fly key set to", key.Name)
    end,
})

local Misc = Player:CreateSection("Misc")
Misc:AddButton({
    Text = "Reset Character",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char then char:BreakJoints() end
    end,
})
Misc:AddTextbox({
    Text = "Webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Flag = "Webhook",
    Callback = function(text)
        print("Webhook set")
    end,
})

-- ═══════════════════════════════════════════
-- TELEPORTS TAB
-- ═══════════════════════════════════════════
local TP = Window:CreateTab({
    Name = "Teleports",
    Icon = "📍",
})

local Locations = TP:CreateSection("Locations")
Locations:AddButton({
    Text = "Spawn",
    Callback = function()
        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(0, 10, 0) end
    end,
})
Locations:AddButton({
    Text = "Random Player",
    Callback = function()
        local players = game.Players:GetPlayers()
        local target = players[math.random(1, #players)]
        if target ~= game.Players.LocalPlayer and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = target.Character.HumanoidRootPart.CFrame end
        end
    end,
})

-- Notify on load
Library:Notify("CYVUI", "Library loaded successfully.", 3, "success")
