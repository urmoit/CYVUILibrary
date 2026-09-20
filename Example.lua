--[[
    CYVUI Library v1.1.1 — Example
    Ironite layout + stability features (dropdown search/Select All, watermark,
    themed notifies, always-on floating toggle, reload purge)
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/urmoit/CYVUILibrary/main/Library.lua"))()
-- Or: local Library = require(path.to.Library)

local Window = Library:CreateWindow({
    Title     = "CYVUI",
    GameName  = "Example",
    Version   = "v1.1.1",
    Size      = UDim2.fromOffset(695, 489),
})
Window:SetHeader("CYVUI", "Example Hub", "v1.1.1")

-- Optional: customize watermark text after create
if Window.SetWatermarkText then
    Window:SetWatermarkText("CYVUI  ·  Example  ·  v1.1.1")
end

-- ═══════════════════════════════════════════
-- HOME
-- ═══════════════════════════════════════════
local Home = Window:CreateTab({ Name = "Home", Icon = "house", Home = true })

Home:CreateHomeLayout({
    Username   = game.Players.LocalPlayer.DisplayName,
    Welcome    = "welcome back",
    AboutTitle = "ABOUT",
    AboutText  = "CYVUI v1.1.1 — Ironite layout, redesigned dropdowns (search + Select All), working Settings (theme / config / watermark), themed notifications, always-on floating toggle. Re-running this script destroys any previous CYVUI UI.",
    DiscordLink = "https://discord.gg/vTe3sNTsDM",
    ServerStats = {
        { Num = tostring(#game.Players:GetPlayers()), Label = "PLAYERS" },
        { Num = "99.8%",                              Label = "UPTIME" },
        { Num = "12ms",                               Label = "PING"    },
    },
    ExecutorName = (identifyexecutor and identifyexecutor()) or "Unknown",
    Changelog = {
        { Version = "v1.1.1", Date = "2026-09-20",
          Text = "Dropdown redesign, settings/config/watermark working, notifications themed, reload purges old CYVUI UIs." },
        { Version = "v1.1.0", Date = "2026-09-07",
          Text = "Ironite-inspired redesign: header + 75px sidebar + subtab row + two-column page. New Tab:AddSubtab API." },
        { Version = "v1.0.4", Date = "2026-08-31",
          Text = "Mobile toggle, floating color popup, Settings spacing/theme highlight fixes." },
        { Version = "v1.0.3", Date = "2026-08-30",
          Text = "Popup color picker, two-column CreateRow layouts, improved Home changelog cards." },
        { Version = "v1.0.2", Date = "2026-08-30",
          Text = "Working color picker, multi-select dropdown + search/All, live server stats." },
        { Version = "v1.0.1", Date = "2026-08-29",
          Text = "Notification redesign, badge overflow fix, new banner." },
        { Version = "v1.0.0", Date = "2026-08-29",
          Text = "Initial CYVUI release." },
    },
})

-- ═══════════════════════════════════════════
-- MAIN — subtabs + widgets
-- ═══════════════════════════════════════════
local Main = Window:CreateTab({ Name = "Main", Icon = "layout" })

-- Subtab: Player
local PlayerSub = Main:AddSubtab("Player")
local PlayerSec = PlayerSub:CreateSection("Movement", { Icon = "user" })
PlayerSec:AddToggle({ Text = "Infinite Jump", Flag = "InfJump", Default = false })
PlayerSec:AddToggle({ Text = "No Clip",      Flag = "NoClip",  Default = false })
PlayerSec:AddSlider({ Text = "Walk Speed",   Flag = "WalkSpeed", Min = 16, Max = 200, Default = 50 })
PlayerSec:AddSlider({ Text = "Jump Power",   Flag = "JumpPower", Min = 50, Max = 200, Default = 50 })
PlayerSec:AddKeybind({ Text = "Toggle UI", Flag = "ToggleUI", Default = Enum.KeyCode.RightShift })

local PlayerSec2 = PlayerSub:CreateSection("Quality of Life", { Icon = "settings" })
PlayerSec2:AddDropdown({
    Text = "Teleport Waypoint",
    Options = { "Spawn", "Shop", "Arena", "Boss" },
    Default = "Spawn",
    Flag = "Waypoint",
})
PlayerSec2:AddTextbox({ Text = "Custom Tag", Placeholder = "Enter display tag...", Flag = "CustomTag" })
PlayerSec2:AddButton({ Text = "Reset Character", Callback = function()
    local c = game.Players.LocalPlayer.Character
    if c then c:BreakJoints() end
end })

-- Subtab: Visuals
local VisualsSub = Main:AddSubtab("Visuals")
local VisSec = VisualsSub:CreateSection("ESP", { Icon = "eye" })
VisSec:AddToggle({ Text = "ESP",    Flag = "ESP",    Default = false })
VisSec:AddToggle({ Text = "Chams",  Flag = "Chams",  Default = false })
VisSec:AddDropdown({
    Text = "ESP Mode",
    Options = { "Off", "Box", "Skeleton", "Tracer" },
    Default = "Skeleton",
    Flag = "ESPMode",
})
VisSec:AddColorPicker({ Text = "ESP Color", Default = Color3.fromRGB(34, 211, 238), Flag = "ESPColor" })

local VisSec2 = VisualsSub:CreateSection("Targets", { Icon = "user" })
-- Multi dropdown: search + Select All / Deselect All when open
VisSec2:AddDropdown({
    Text = "ESP Targets",
    Options = { "Players", "NPCs", "Bosses", "Items", "Vehicles", "Pets", "Crates" },
    Default = { "Players", "Bosses" },
    Multi = true,
    Flag = "ESPTargets",
    Callback = function(list)
        -- list is array of selected option strings
    end,
})

-- Subtab: Automation
local AutoSub = Main:AddSubtab("Automation")
local AutoSec = AutoSub:CreateSection("Auto Farm", {
    Icon = "clock",
    Toggle = { Flag = "AutoFarmEnable", Default = true },
})
AutoSec:AddToggle({ Text = "Auto Farm", Flag = "AutoFarm", Default = true })
AutoSec:AddToggle({ Text = "Auto Sell", Flag = "AutoSell", Default = false })
AutoSec:AddSlider({ Text = "Sell Threshold", Flag = "SellThreshold", Min = 0, Max = 5000, Default = 500 })

local AutoInfoSec = AutoSub:CreateSection("Priority", { Icon = "info" })
AutoInfoSec:AddDropdown({
    Text = "Seed Priority",
    Options = { "Highest Value", "Fastest Growth", "Rarest First" },
    Default = "Highest Value",
    Flag = "SeedPriority",
})
AutoInfoSec:AddParagraph("Auto Farm respects priority order when picking seeds. Use Settings → Config to Save / Load flags (CYVUI_<name>.json when writefile exists).")

-- Built-in Settings tab (sidebar bottom): Theme presets, UI transparency,
-- Active Config + Save/Load, Auto Load, Minimize keybind, Watermark toggle,
-- Notifications toggle, Destroy UI.

Library:Notify("CYVUI", "Library loaded · v1.1.1", 3, "success")
Library:Notify("Hint", "Floating toggle is always on. Watermark top-left.", 4, "info")
