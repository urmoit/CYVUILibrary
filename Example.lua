--[[
    CYVUI Library v1.0.6 — Example
    Home + Main (widgets) + Settings match dashboard mockup
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/urmoit/CYVUILibrary/main/Library.lua"))()
-- Or: local Library = require(path.to.Library)

local Window = Library:CreateWindow({
    Title    = "CYVUI",
    GameName = "Example",
    Version  = "v1.0.6",
    Size     = UDim2.new(0, 900, 0, 560),
})

-- ═══════════════════════════════════════════
-- HOME (same layout every game — only content changes)
-- ═══════════════════════════════════════════
local Home = Window:CreateTab({ Name = "Home", Icon = "house", Home = true })

Home:CreateHomeLayout({
    Username   = game.Players.LocalPlayer.DisplayName,
    Welcome    = "welcome back",
    AboutTitle = "ABOUT",
    AboutText  = "CYVUI example — dashboard Home, widgets, Settings themes, Lucide icons. Clean, fast, modular.",
    DiscordLink = "https://discord.gg/vTe3sNTsDM",
    ExecutorName = (identifyexecutor and identifyexecutor()) or "Unknown",
    Changelog = {
        {
            Version = "v1.0.6",
            Date = "2026-08-31",
            Text = "Fixed UI dragging when moving the mouse quickly or outside the header area.",
            Items = {
                { Text = "Title-bar dragging now remains reliable during fast mouse movement.", Type = "fixed" },
            },
        },
        {
            Version = "v1.0.3",
            Date = "2026-08-30",
            Text = "CreateRow layouts, improved Home changelog.",
        },
        {
            Version = "v1.0.0",
            Date = "2026-08-29",
            Text = "Initial CYVUI release.",
        },
    },
})

-- ═══════════════════════════════════════════
-- MAIN (feature widgets — 2-column style sections)
-- ═══════════════════════════════════════════
local Main = Window:CreateTab({ Name = "Main", Icon = "layout" })

-- Two-column layout example
local row = Main:CreateRow()
local Left = row:Section("Player", { Icon = "user" })
local Right = row:Section("Visuals", { Icon = "eye" })

Left:AddToggle({ Text = "Infinite Jump", Flag = "InfJump" })
Left:AddSlider({ Text = "Walk Speed", Min = 16, Max = 200, Default = 50, Flag = "WalkSpeed" })
Right:AddToggle({ Text = "ESP", Flag = "ESP" })
Right:AddColorPicker({ Text = "ESP Color", Default = Color3.fromRGB(34, 211, 238), Flag = "ESPColor" })

local Player = Main:CreateSection("Player (full width)", { Icon = "user" })
Player:AddToggle({ Text = "No Clip", Default = false, Flag = "NoClip" })
Player:AddSlider({ Text = "Jump Power", Min = 50, Max = 200, Default = 50, Flag = "JumpPower" })
Player:AddButton({
    Text = "Reset Character",
    Callback = function()
        local c = game.Players.LocalPlayer.Character
        if c then c:BreakJoints() end
    end,
})

local Visuals = Main:CreateSection("Visuals", { Icon = "eye" })
Visuals:AddToggle({ Text = "Chams", Default = false, Flag = "Chams" })
Visuals:AddDropdown({
    Text = "ESP Mode",
    Options = { "Off", "Box", "Skeleton", "Tracer" },
    Default = "Skeleton",
    Flag = "ESPMode",
})
Visuals:AddDropdown({
    Text = "ESP Targets",
    Options = { "Players", "NPCs", "Bosses", "Items", "Vehicles" },
    Default = { "Players", "Bosses" },
    Multi = true,
    Flag = "ESPTargets",
})
Visuals:AddTextbox({ Text = "Custom Tag", Placeholder = "Enter display tag...", Flag = "CustomTag" })

local Auto = Main:CreateSection("Automation", { Icon = "clock" })
Auto:AddToggle({ Text = "Auto Farm", Default = true, Flag = "AutoFarm" })
Auto:AddToggle({ Text = "Auto Sell", Default = false, Flag = "AutoSell" })
Auto:AddDropdown({
    Text = "Seed Priority",
    Options = { "Highest Value", "Fastest Growth", "Rarest First" },
    Default = "Highest Value",
    Flag = "SeedPriority",
})
Auto:AddSlider({ Text = "Sell Threshold", Min = 0, Max = 5000, Default = 500, Flag = "SellThreshold" })

local Info = Main:CreateSection("Info", { Icon = "info" })
Info:AddParagraph("This tab controls player movement, visual overlays and farm automation. Toggles apply instantly. Save from Settings.")
Info:AddKeybind({ Text = "Toggle UI", Default = Enum.KeyCode.RightShift, Flag = "ToggleUI" })

-- Settings tab is built-in (bottom sidebar) with Theme / Config / General

Library:Notify("CYVUI", "Library loaded.", 3, "success")
