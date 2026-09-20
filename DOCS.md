# CYVUI Library v1.1.1 — Documentation

Dark modern Roblox UI library, **Ironite-inspired** layout (header + 75px sidebar + subtab row + two-column page).  
**Home** and **Settings** share the same dashboard structure across games — only content varies.

> 📜 [CHANGELOG.md](./CHANGELOG.md) — v1.1.1 stability (dropdown redesign, Settings/config/watermark, themed notifies, reload purge) on top of the v1.1.0 redesign.

---

## Install

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/urmoit/CYVUILibrary/main/Library.lua"))()
```

Local file:

```lua
local Library = loadstring(readfile("CYVUI/Library.lua"))()
-- or require if you package as a ModuleScript
```

**Reload behavior:** every `CreateWindow` call destroys any previous CYVUI UI (tracked windows, watermark, notification holder, and leftover `CYVUI*` ScreenGuis under CoreGui / PlayerGui / `gethui()`). Safe to re-execute the same script.

---

## Quick start

```lua
local Window = Library:CreateWindow({
    Title    = "CYVHUB",
    GameName = "My Game",
    Version  = "v1.1.1",
    Size     = UDim2.fromOffset(695, 489),
})
Window:SetHeader("CYVHUB", "My Game", "v1.1.1")

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
        { Version = "v1.1.1", Date = "2026-09-20", Text = "Stability release." },
    },
})

local Main = Window:CreateTab({ Name = "Main", Icon = "layout" })
local Sec = Main:CreateSection("Player", { Icon = "user" })
Sec:AddToggle({ Text = "Speed", Flag = "Speed", Callback = function(v) end })
```

Settings tab is **built-in** (bottom of sidebar) with Theme / Config / General.  
A **floating toggle** (rounded square) is always created — drag to move, click to show/hide UI.  
A **watermark** (title · hub · version + fps/ping) is created top-left; toggle it in Settings → General.

---

## Window

### `Library:CreateWindow(config)`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| Title | string | `"CYVHUB"` | Header library name |
| GameName | string | `""` | Dimmed tag after the name |
| Version | string | `"v1.1.1"` | Version string (header / watermark) |
| Size | UDim2 | `695×489` | Window size |

**Returns:** Window  

Also destroys any previous CYVUI instance before building.

### Window methods

| Method | Description |
|--------|-------------|
| `:SetHeader(name, tag, updatedText?)` | Header rich-text name + tag + right-side text |
| `:SetTitle(...)` | Alias of `SetHeader` |
| `:CreateTab(config)` | Sidebar tab |
| `:SetWatermarkVisible(boolean)` | Show / hide watermark |
| `:SetWatermarkText(string)` | Override watermark label text |

```lua
Window:SetHeader("CYVHUB", "Rivals", "v1.2")
Window:SetWatermarkText("CYVHUB  ·  Rivals  ·  v1.2")
Window:SetWatermarkVisible(true)
```

---

## Tabs

### `Window:CreateTab(config)`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| Name | string | `"Tab"` | Sidebar label |
| Icon | string | `"house"` | Lucide icon name |
| Home | boolean | `false` | Default selected Home tab |
| Settings | boolean | `false` | Marks built-in Settings tab |

### Tab methods

| Method | Description |
|--------|-------------|
| `:AddSubtab(name)` | Horizontal subtab chip. Returns `Subtab` |
| `:CreateSection(name, { Icon, Toggle })` | Section (auto-routes to first subtab). `Toggle` = section master switch |
| `:CreateHomeLayout(config)` | Fixed Home dashboard |
| `:CreateSettingsLayout(config?)` | Theme / Config / General blocks |

### Subtabs

```lua
local Main = Window:CreateTab({ Name = "Main", Icon = "layout" })

local PlayerSub = Main:AddSubtab("Player")
local VisualsSub = Main:AddSubtab("Visuals")

PlayerSub:CreateSection("Movement", { Icon = "user" })
    :AddToggle({ Text = "Speed", Flag = "Speed" })

VisualsSub:CreateSection("ESP", { Icon = "eye" })
    :AddToggle({ Text = "ESP", Flag = "ESP" })
```

---

## Home layout

```
[ Profile (avatar + @user + welcome) ] [ ABOUT text ]
[ Discord Copy Link ] [ Server stats ] [ Executor badge ]
[ Changelog list ]
```

### `Tab:CreateHomeLayout(config)`

| Key | Type | Description |
|-----|------|-------------|
| Username | string | Display name (prefixed with @) |
| Welcome | string | Status under name |
| AboutTitle | string | Default `"ABOUT"` |
| AboutText | string | Body |
| DiscordLink | string | Copied by Copy Link |
| ServerStats | table | `{ { Num, Label }, ... }` — up to 3 |
| ExecutorName | string | Executor label |
| Changelog | table | `{ Version, Date, Text }` entries |

---

## Settings layout

Always available via sidebar **Settings**. Optional customization:

| Key | Description |
|-----|-------------|
| Themes | Array of `{ Name, Accent, Accent2 }` presets |
| Configs | Names for the Active Config dropdown |
| OnSave | `function(flags)` — overrides built-in save |
| OnLoad | `function(configName)` — overrides built-in load |
| OnTheme | Fired when a theme preset is clicked |

### Built-in blocks

**Theme**
- Accent presets (clickable swatches)
- UI Transparency slider (main frame + panels)

**Config**
- Active Config dropdown
- Save Config → `OnSave` **or** `writefile("CYVUI_<name>.json")` when available
- Load Config → `OnLoad` **or** `readfile` + JSON into `Library.Flags`
- Auto Load On Join flag

**General**
- Minimize Keybind (`Library.Flags.MinimizeKey`)
- Watermark toggle (`Window:SetWatermarkVisible`)
- Notifications toggle (gates `Library:Notify`)
- Destroy UI (main + watermark + notify holder)

### Example — custom settings hooks

```lua
-- Built-in Settings tab is created automatically.
-- To customize it before/around your tabs, call CreateSettingsLayout on the Settings tab
-- only if you create Settings yourself with Settings = true. Otherwise defaults apply.

-- Prefer hooks via a second pass if you own the Settings tab:
-- Settings:CreateSettingsLayout({
--     Themes = {
--         { Name = "Violet", Accent = Color3.fromRGB(139, 92, 246), Accent2 = Color3.fromRGB(34, 211, 238) },
--     },
--     Configs = { "default", "farming", "pvp" },
--     OnSave = function(flags)
--         -- custom persist
--     end,
--     OnLoad = function(name)
--         -- custom restore
--     end,
--     OnTheme = function(preset)
--         print("Theme:", preset.Name)
--     end,
-- })
```

Default file name pattern for built-in save/load: **`CYVUI_<ConfigName>.json`**.

---

## Sections & elements

### `Subtab:CreateSection(name, opts?)` / `Tab:CreateSection(...)`

`opts.Icon` — Lucide name.  
`opts.Toggle` — `{ Flag, Default, Callback }` master switch in the section header.

| Method | Notes |
|--------|--------|
| `:AddToggle({ Text, Default, Flag, Callback })` | Returns `{ Set, Get }` |
| `:AddSlider({ Text, Min, Max, Default, Decimals, Flag, Callback })` | |
| `:AddButton({ Text, Color?, Callback })` | Optional solid `Color` |
| `:AddDropdown({ Text, Options, Default, Flag, Callback, Multi })` | See **Dropdown** below |
| `:AddColorPicker({ Text, Default, Flag, Callback })` | Floating HSV popup |
| `:AddTextbox({ Text, Placeholder, Default, Flag, Callback })` | |
| `:AddKeybind({ Text, Default, Flag, Callback })` | |
| `:AddLabel` / `:AddParagraph` | Wrapped text |

### Dropdown (v1.1.1)

When open:
- **Search** field filters options
- **Multi = true** → Select All / Deselect All + multi selection
- Accent border while open
- Outside click closes
- List opens on the ScreenGui (not clipped by section)

```lua
Sec:AddDropdown({
    Text = "ESP Targets",
    Options = { "Players", "NPCs", "Bosses", "Items" },
    Default = { "Players" },
    Multi = true,
    Flag = "ESPTargets",
    Callback = function(list) end, -- array of strings when Multi
})

Sec:AddDropdown({
    Text = "Mode",
    Options = { "Off", "Box", "Skeleton" },
    Default = "Box",
    Flag = "Mode",
    Callback = function(value) end, -- single string
})
```

### Example — widgets

```lua
local Combat = Main:CreateSection("Combat", { Icon = "crosshair" })

Combat:AddToggle({
    Text = "Aimbot",
    Default = false,
    Flag = "Aimbot",
    Callback = function(on) end,
})

Combat:AddSlider({
    Text = "FOV",
    Min = 50, Max = 400, Default = 120,
    Flag = "FOV",
})

Combat:AddDropdown({
    Text = "Target Part",
    Options = { "Head", "Torso", "HumanoidRootPart" },
    Default = "Head",
    Flag = "TargetPart",
})

Combat:AddKeybind({
    Text = "Aim Key",
    Default = Enum.KeyCode.Q,
    Flag = "AimKey",
})

Combat:AddButton({
    Text = "Force Update",
    Color = Color3.fromRGB(34, 211, 238),
    Callback = function()
        Library:Notify("Combat", "Updated", 2, "success")
    end,
})
```

---

## Flags

Elements with a `Flag` store values on `Library.Flags`.

```lua
local enabled = Library:GetFlag("Aimbot")
Library:SetFlag("Aimbot", false)
```

Built-in Settings can persist the whole `Library.Flags` table to `CYVUI_<name>.json`.

---

## Theme

`Library.Theme` keys (edit before `CreateWindow`, or use `:SetTheme`):

| Key | Role |
|-----|------|
| Background / Sidebar / Panel / Input | Surfaces |
| Accent / Accent2 | Primary / secondary accent |
| Text / TextDim / TextFaint / Muted | Typography |
| Success / Warning / Error | Status + notify accents |
| Border / Liner | Separators |

```lua
Library:SetTheme(
    Color3.fromRGB(52, 211, 153),
    Color3.fromRGB(163, 230, 53)
)
```

`SetTheme` updates accent-bound surfaces and the floating toggle color.

---

## Notifications

```lua
Library:Notify("Title", "Body", 3, "success") -- success | warning | error | info
```

- Card uses **main UI theme** (panel / border / text)
- Type color only on side bar + bottom progress line
- Max 4 stacked; auto dismiss
- Suppressed when Settings → Notifications is off (`Library.Flags.Notifications == false`)

---

## Watermark

Created with every window:

- Text: `Title · GameName · Version` (overridable)
- Live **fps · ping**
- Draggable, top-left
- Default **on**

```lua
Window:SetWatermarkVisible(false)
Window:SetWatermarkText("MyHub  ·  Build 42")
```

Toggle also available in Settings → General → Watermark.

---

## Floating toggle

Always created (PC and mobile):

- Rounded square, accent colored
- Drag to reposition
- Click / tap (small movement) toggles main UI visibility
- No `MobileToggle` config flag required

Also: **Right Control** or the Minimize keybind (Settings → General) toggles UI.

---

## Lucide icons

```lua
Library:GetIcon("house") -- rbxassetid://...
```

Pass names into `Icon` fields. Common: `house`, `layout`, `settings`, `user`, `eye`, `clock`, `message-circle`, `server`, `terminal`, `swords`, `crosshair`, `palette`, `bookmark`.

Full list: [lucide.dev/icons](https://lucide.dev/icons)

---

## Controls

| Input | Action |
|-------|--------|
| Right Control | Toggle UI |
| Minimize keybind (Settings) | Toggle UI |
| Floating toggle click | Toggle UI |
| Title bar drag | Move window |
| Floating toggle / watermark drag | Reposition control |

---

## Two-column layouts

Sections pair into two columns automatically. Use subtabs to group:

```lua
local Main = Window:CreateTab({ Name = "Main", Icon = "layout" })

local PlayerSub = Main:AddSubtab("Player")
local Left  = PlayerSub:CreateSection("Auto Clean",  { Icon = "trash" })
local Right = PlayerSub:CreateSection("Visuals",     { Icon = "eye" })

Left:AddToggle({ Text = "Auto Collect", Flag = "AutoCollect" })
Right:AddColorPicker({ Text = "Paper Color", Default = Color3.fromRGB(168, 85, 247), Flag = "PaperColor" })
```

`Main:CreateSection("General", { Icon = "settings" })` still works — routes to the first subtab (creates one if needed).

---

## Full example

See **[Example.lua](./Example.lua)** in the repo (kept in sync with this version).

---

## File structure

```
CYVUI/
├── Library.lua
├── Example.lua
├── DOCS.md
├── CHANGELOG.md
├── README.md
├── TODO.md
└── assets/
```

---

## Notes

- Home + Settings structure is **shared** across games; only strings / stats / changelog differ.
- Compatible with most executors (`protect_gui` / `gethui` / CoreGui).
- Re-running a CYVUI script **always** clears the previous CYVUI UI.
- Config files: `CYVUI_<name>.json` when `writefile` / `readfile` exist.
- Discord invite used in examples: `https://discord.gg/vTe3sNTsDM`
