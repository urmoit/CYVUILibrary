# CYVUI Library v2.0

Dark modern Roblox UI library matching the CYVHUB dashboard mockup.  
**Home** and **Settings** share the same layout on every game — only content/text changes.

---

## Install

```lua
local Library = loadstring(game:HttpGet("YOUR_RAW_URL/Library.lua"))()
```

---

## Quick start

```lua
local Window = Library:CreateWindow({
    Title    = "CYVHUB",
    GameName = "My Game",
    Version  = "v2.0",
    Size     = UDim2.new(0, 900, 0, 560),
})

local Home = Window:CreateTab({ Name = "Home", Icon = "house", Home = true })
Home:CreateHomeLayout({
    Username    = game.Players.LocalPlayer.DisplayName,
    Welcome     = "welcome back",
    AboutText   = "Your hub description.",
    DiscordLink = "https://discord.gg/vTe3sNTsDM",
    ServerStats = {
        { Num = "12", Label = "PLAYERS" },
        { Num = "99%", Label = "UPTIME" },
        { Num = "20ms", Label = "PING" },
    },
    ExecutorName = identifyexecutor and identifyexecutor() or "Unknown",
    Changelog = {
        { Version = "v1.0.0", Date = "2026-08-29", Text = "Initial release." },
    },
})

local Main = Window:CreateTab({ Name = "Main", Icon = "layout" })
local Sec = Main:CreateSection("Player", { Icon = "user" })
Sec:AddToggle({ Text = "Speed", Flag = "Speed", Callback = function(v) end })
```

Settings tab is **built-in** (bottom of sidebar) with Theme / Config / General.

---

## Window

### `Library:CreateWindow(config)`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| Title | string | `"CYVHUB"` | Left title segment |
| GameName | string | `"game name"` | Middle segment |
| Version | string | `"v2.0"` | Right segment |
| Size | UDim2 | `900×560` | Window size |

**Returns:** Window  

Methods: `:SetTitle(title, game, version)`, `:CreateTab(config)`

---

## Tabs

### `Window:CreateTab(config)`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| Name | string | `"Tab"` | Sidebar label |
| Icon | string | `"house"` | **Lucide** icon name |
| Home | boolean | `false` | Default selected Home tab |
| Settings | boolean | `false` | Binds to bottom Settings button |

### Tab methods

| Method | Description |
|--------|-------------|
| `:CreateSection(name, { Icon = "..." })` | Widget card with header + Lucide icon |
| `:CreateHomeLayout(config)` | Fixed Home dashboard (profile, about, discord, server, executor, changelog) |
| `:CreateSettingsLayout(config)` | Standard Settings (Theme / Config / General) |

---

## Home layout

Same structure every UI:

```
[ Profile (avatar + @user + welcome) ] [ ABOUT text ]
[ Discord Copy Link ] [ Server stats ] [ Executor badge ]
[ Changelog list (custom entries) ]
```

### `Tab:CreateHomeLayout(config)`

| Key | Type | Description |
|-----|------|-------------|
| Username | string | Display name (prefixed with @) |
| Welcome | string | Status line under name |
| AboutTitle | string | Default `"ABOUT"` |
| AboutText | string | Body |
| DiscordLink | string | Copied by Copy Link |
| ServerStats | table | `{ { Num, Label }, ... }` — up to 3 |
| ExecutorName | string | Executor label |
| Changelog | table | `{ Version, Date, Text }` entries |

---

## Settings layout

Always available via sidebar **Settings**. Call `:CreateSettingsLayout` on a Settings tab to customize:

| Key | Description |
|-----|-------------|
| Themes | Array of `{ Name, Accent, Accent2 }` presets |
| Configs | Dropdown config names |
| OnSave / OnLoad | Callbacks |
| OnTheme | Fired when preset clicked |

Default Settings includes: accent presets, transparency slider, config dropdown, save/load, auto-load toggle, minimize keybind, watermark, notifications, destroy UI.

---

## Elements (sections)

| Method | Notes |
|--------|--------|
| `:AddToggle({ Text, Default, Flag, Callback })` | Returns `{ Set, Get }` |
| `:AddSlider({ Text, Min, Max, Default, Decimals, Flag, Callback })` | |
| `:AddButton({ Text, Accent, Callback })` | `Accent = true` → violet CTA |
| `:AddDropdown({ Text, Options, Default, Flag, Callback })` | |
| `:AddTextbox({ Text, Placeholder, Default, Flag, Callback })` | |
| `:AddKeybind({ Text, Default, Flag, Callback })` | |
| `:AddColorPicker({ Text, Default, Flag, Callback })` | Swatch + hex display |
| `:AddLabel` / `:AddParagraph` | Wrapped text |

Flags live in `Library.Flags` — use `Library:GetFlag` / `:SetFlag`.

---

## Lucide icons

Icons load from **Footagesus Icons v2** (Lucide pack). Fallback rbxassetids if CDN fails.

```lua
Library:GetIcon("house")  -- returns rbxassetid://...
```

Pass Lucide names into tab/section `Icon` fields: `house`, `layout`, `settings`, `user`, `eye`, `clock`, `message-circle`, `server`, `terminal`, etc.  
Browse names: [lucide.dev/icons](https://lucide.dev/icons)

---

## Notifications

```lua
Library:Notify("Title", "Body", 3, "success") -- success | warning | error | nil
```

---

## Theme

`Library.Theme` table (edit before `CreateWindow` or via Settings presets):

| Key | Role |
|-----|------|
| Background / Sidebar / Panel | Surfaces |
| Accent / Accent2 | Violet / cyan |
| Text / TextDim / TextFaint | Typography |

---

## Controls

| Input | Action |
|-------|--------|
| Right Control | Toggle UI |
| Title bar drag | Move window |
| Yellow traffic | Minimize |
| Red traffic | Destroy |

---

## File structure

```
CYVUI Library/
├── Library.lua   -- Core
├── Example.lua   -- Full demo
└── DOCS.md       -- This file
```

---

## Notes

- Home + Settings structure is **shared** across all games; only strings/stats/changelog differ.
- Main tabs are free-form sections (toggles, sliders, dropdowns, etc.).
- Compatible with most executors (`protect_gui` / `gethui` / CoreGui).
- Destroy previous windows when creating a new one.
