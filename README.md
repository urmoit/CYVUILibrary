# CYVUI

Dark modern Roblox UI library for script hubs. Dashboard-style **Home**, shared **Settings**, Lucide icons, live theme presets.

![Version](https://img.shields.io/badge/version-1.1.1-8b5cf6)
![Luau](https://img.shields.io/badge/luau-Roblox-00a2ff)
![License](https://img.shields.io/badge/license-MIT-22d3ee)
[![Changelog](https://img.shields.io/badge/changelog-v1.1.1-22d3ee)](./CHANGELOG.md)

📜 **[Latest release → CHANGELOG.md](./CHANGELOG.md)** · **v1.1.1** — dropdown redesign, Settings/config/watermark, themed notifies, always-on floating toggle, reload purge (on Ironite layout).

---

## Features

- **Ironite layout** — header, 75px sidebar, subtab row, two-column sections
- **Home dashboard** — profile, about, Discord, server stats, executor, changelog
- **Settings** — theme presets, UI transparency, config save/load (`CYVUI_<name>.json`), minimize keybind, watermark toggle, notifications toggle, destroy UI
- **Widgets** — toggle, slider, dropdown (search + Select All), textbox, keybind, color picker, button, label
- **Watermark** — title · hub · version + live fps/ping (draggable)
- **Floating toggle** — always on (PC + mobile), drag + click to show/hide UI
- **Notifications** — themed to main UI; type color on accent bar only
- **Reload-safe** — re-running a CYVUI script purges the previous UI
- **Lucide icons** + offline fallbacks
- **Flags** — `Library.Flags` for get/set

Home and Settings stay the same layout across games — only text, stats, and changelog entries change.

---

## Install

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/urmoit/CYVUILibrary/main/Library.lua"))()
```

Or drop `Library.lua` into your project and require / loadstring the file.

---

## Quick start

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/urmoit/CYVUILibrary/main/Library.lua"))()

local Window = Library:CreateWindow({
    Title    = "CYVHUB",
    GameName = "My Game",
    Version  = "v1.1.1",
})

local Home = Window:CreateTab({ Name = "Home", Icon = "house", Home = true })
Home:CreateHomeLayout({
    Username     = game.Players.LocalPlayer.DisplayName,
    Welcome      = "welcome back",
    AboutText    = "Your hub description.",
    DiscordLink  = "https://discord.gg/vTe3sNTsDM",
    ExecutorName = identifyexecutor and identifyexecutor() or "Unknown",
    Changelog    = {
        { Version = "v1.1.1", Date = "2026-09-20", Text = "Stability: dropdown, settings, watermark." },
    },
})

local Main = Window:CreateTab({ Name = "Main", Icon = "layout" })
local Combat = Main:CreateSection("Combat", { Icon = "swords" })
Combat:AddToggle({
    Text = "Aimbot",
    Flag = "Aimbot",
    Callback = function(value)
        print("Aimbot:", value)
    end,
})

Library:Notify("CYVUI", "Loaded.", 3, "success")
```

Full API and more examples: **[DOCS.md](./DOCS.md)** · runnable demo: **[Example.lua](./Example.lua)**

---

## Structure

```
CYVUI/
├── Library.lua   -- core UI library
├── Example.lua   -- full demo script
├── DOCS.md       -- API reference + examples
└── README.md
```

---

## Controls

| Input | Action |
|-------|--------|
| Right Control | Toggle UI visibility |
| Title bar drag | Move window |
| Yellow traffic light | Minimize / restore |
| Red traffic light | Destroy UI |

---

## Theme

Default palette (dashboard mockup):

| Token | Color |
|-------|--------|
| Background | `#0a0a0d` |
| Panel | `#18181e` |
| Accent | `#8b5cf6` |
| Accent 2 | `#22d3ee` |

Change at runtime:

```lua
Library:SetTheme(
    Color3.fromRGB(244, 114, 182), -- accent
    Color3.fromRGB(251, 146, 60)   -- accent2
)
```

Or use the built-in Settings → Theme swatches.

---

## Lucide icons

Pass Lucide icon names into tabs and sections:

```lua
Window:CreateTab({ Name = "Main", Icon = "layout" })
tab:CreateSection("Player", { Icon = "user" })
```

Browse names at [lucide.dev/icons](https://lucide.dev/icons). Icons resolve via Footagesus Icons v2 with local rbxassetid fallbacks.

---

## Discord

https://discord.gg/vTe3sNTsDM

---

## Changelog

See **[CHANGELOG.md](./CHANGELOG.md)** for every release.

## License

MIT — use in hubs, paid scripts, or personal projects. Credit appreciated, not required.
