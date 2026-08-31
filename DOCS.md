# CYVUI Library v1.0.6 — Documentation

Dark modern Roblox UI library matching the CYVHUB dashboard mockup.  
**Home** and **Settings** share the same layout on every game — only content/text changes.

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

---

## Quick start

```lua
local Window = Library:CreateWindow({
    Title    = "CYVHUB",
    GameName = "My Game",
    Version  = "v1.0.6",
    Size     = UDim2.new(0, 900, 0, 560),
})

local Home = Window:CreateTab({ Name = "Home", Icon = "house", Home = true })
Home:CreateHomeLayout({
    Username    = game.Players.LocalPlayer.DisplayName,
    Welcome     = "welcome back",
    AboutText   = "Your hub description.",
    DiscordLink = "https://discord.gg/vTe3sNTsDM",
    ExecutorName = identifyexecutor and identifyexecutor() or "Unknown",
    Changelog = {
        { Version = "v1.0.6", Date = "2026-08-31", Text = "Fixed UI dragging when moving the mouse quickly or outside the header area." },
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
| Version | string | `"v1.0.6"` | Right segment |
| Size | UDim2 | `900×560` | Window size |

**Returns:** Window  

Methods: `:SetTitle(title, game, version)`, `:CreateTab(config)`

### Example — rename window after load

```lua
Window:SetTitle("CYVHUB", "Rivals", "v1.2")
```

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
| `:CreateSection(name, { Icon = "..." })` | Full-width widget card |
| `:CreateRow()` | Horizontal row for two-column layouts |
| `row:Section(name, { Icon })` | Half-width section inside a row |
| `:CreateGrid(columns?)` | Multi-column grid of sections; use `grid:Section(name, { Icon })` to add cells (default 2 columns) |
| `:CreateHomeLayout(config)` | Fixed Home dashboard |
| `:CreateSettingsLayout(config)` | Standard Settings blocks |

### Example — multiple feature tabs

```lua
local Main = Window:CreateTab({ Name = "Main", Icon = "layout" })
local Player = Window:CreateTab({ Name = "Player", Icon = "user" })
local Visuals = Window:CreateTab({ Name = "Visuals", Icon = "eye" })
```

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
| ExecutorName | string | Executor label |
| Changelog | table | `{ Version, Date, Text, Items? }` entries; `Items` may contain strings or `{ Text, Type = "added"|"fixed"|"changed"|"removed" }` rows |

The Server Info card always shows **live** stats (player count, session uptime, real server ping, refreshed every second) — there is no `ServerStats` option.

**Returns:** `{ ProfileCard, AboutCard, DiscordCard, ServerCard, ExecutorCard, ChangelogCard, SetUsername(name), SetAbout(text), SetExecutor(name) }`

### Example — Home layout with live server stats

```lua
Home:CreateHomeLayout({
    Username = game.Players.LocalPlayer.DisplayName,
    Welcome = "welcome back",
    AboutText = "Farm hub for Grow a Garden 2.",
    DiscordLink = "https://discord.gg/vTe3sNTsDM",
    ExecutorName = identifyexecutor and identifyexecutor() or "Unknown",
    Changelog = {
        { Version = "v1.0.6", Date = "2026-08-31", Text = "Fixed UI dragging when moving the mouse quickly or outside the header area." },
        { Version = "v1.0.0", Date = "2026-08-20", Text = "Initial game release." },
    },
})
```

---

## Settings layout

Always available via sidebar **Settings**. Customize with:

| Key | Description |
|-----|-------------|
| Themes | Array of `{ Name, Accent, Accent2 }` presets |
| Configs | Dropdown config names |
| OnSave / OnLoad | Callbacks |
| OnTheme | Fired when preset clicked |

### Example — custom settings

```lua
local Settings = Window:CreateTab({ Name = "Settings", Icon = "settings", Settings = true })
Settings:CreateSettingsLayout({
    Themes = {
        { Name = "Violet", Accent = Color3.fromRGB(139, 92, 246), Accent2 = Color3.fromRGB(34, 211, 238) },
        { Name = "Crimson", Accent = Color3.fromRGB(248, 113, 113), Accent2 = Color3.fromRGB(251, 191, 36) },
    },
    Configs = { "default", "farming", "pvp" },
    OnSave = function()
        if writefile then
            writefile("cyvui_config.json", game:GetService("HttpService"):JSONEncode(Library.Flags))
        end
        Library:Notify("Config", "Saved", 2, "success")
    end,
    OnLoad = function()
        Library:Notify("Config", "Loaded", 2, "success")
    end,
    OnTheme = function(preset)
        print("Theme:", preset.Name)
    end,
})
```

Default Settings (if you only use the built-in tab) includes: accent presets, transparency slider, config dropdown, save/load, auto-load, minimize keybind, watermark, notifications, destroy UI.

---

## Sections & elements

### `Tab:CreateSection(name, opts?)`

`opts.Icon` — Lucide name for the section header.

| Method | Notes | Returns |
|--------|--------|---------|
| `:AddToggle({ Text, Default, Flag, Callback })` | | `{ Set, Get, Frame }` |
| `:AddSlider({ Text, Min, Max, Default, Decimals, Flag, Callback })` | Defaults: `Min = 0`, `Max = 100`, `Default = Min`; integer unless `Decimals` set | Slider row `Frame` |
| `:AddButton({ Text, Accent, Callback })` | `Accent = true` → violet CTA | Button instance |
| `:AddDropdown({ Text, Options, Default, Flag, Callback, Multi })` | `Multi = true` enables multi-select + **All** toggle; search is always shown when open | `{ Frame, Set, Get }` (`Get` returns a list when `Multi`) |
| `:AddColorPicker({ Text, Default, Flag, Callback })` | Working HSV picker (sat/val square + hue bar) in a floating popup with hex input | `{ Frame, Set, Get }` |
| `:AddTextbox({ Text, Placeholder, Default, Flag, Callback })` | Fires on focus lost | TextBox instance |
| `:AddKeybind({ Text, Default, Flag, Callback })` | Click, then press a key (Esc clears) | Key button instance |
| `:AddLabel(text)` / `:AddParagraph(text)` | Wrapped text | TextLabel instance |

### Example — full widget section

```lua
local Combat = Main:CreateSection("Combat", { Icon = "crosshair" })

Combat:AddToggle({
    Text = "Aimbot",
    Default = false,
    Flag = "Aimbot",
    Callback = function(on)
        -- enable / disable
    end,
})

Combat:AddSlider({
    Text = "FOV",
    Min = 50,
    Max = 400,
    Default = 120,
    Flag = "FOV",
    Callback = function(v) end,
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
    Accent = true,
    Callback = function()
        Library:Notify("Combat", "Updated", 2, "success")
    end,
})
```

### Example — toggle API

```lua
local Sec = Player:CreateSection("Player")
local tog = Sec:AddToggle({ Text = "Speed", Flag = "Speed" })
tog:Set(true)
print(tog:Get()) -- true
```

---

## Flags

Elements with a `Flag` string store values on `Library.Flags`.

```lua
local enabled = Library:GetFlag("Aimbot")
Library:SetFlag("Aimbot", false)
```

### Example — save / load flags

```lua
local HttpService = game:GetService("HttpService")
local PATH = "cyvui_flags.json"

local function saveFlags()
    if writefile then
        writefile(PATH, HttpService:JSONEncode(Library.Flags))
    end
end

local function loadFlags()
    if isfile and isfile(PATH) then
        local data = HttpService:JSONDecode(readfile(PATH))
        for k, v in pairs(data) do
            Library:SetFlag(k, v)
        end
    end
end
```

---

## Theme

`Library.Theme` keys (edit before `CreateWindow`, or use `:SetTheme`):

| Key | Role |
|-----|------|
| Background / Sidebar / Panel | Surfaces |
| Accent / Accent2 | Violet / cyan |
| Text / TextDim / TextFaint | Typography |
| Success / Warning / Error | Notify colors |

```lua
Library:SetTheme(
    Color3.fromRGB(52, 211, 153),
    Color3.fromRGB(163, 230, 53)
)
```

Bound controls (toggles on, slider fills, accent buttons, icons, badges) update live.

---

## Lucide icons

```lua
Library:GetIcon("house") -- rbxassetid://...
```

Pass names into `Icon` fields. Common: `house`, `layout`, `settings`, `user`, `eye`, `clock`, `message-circle`, `server`, `terminal`, `swords`, `crosshair`.

Full list: [lucide.dev/icons](https://lucide.dev/icons)

---

## Notifications

### `Library:Notify(title, message, duration, notifType)`

Notifications use responsive rounded cards with status icons, accent strips, theme-aware tinted backgrounds, smooth enter/exit animations, automatic message height, and touch-safe close controls. Supported types are `success`, `warning`, `error`, and `info` (default). `duration` defaults to 3 seconds.

```lua
Library:Notify("Farm", "Auto farm enabled", 2, "success")
```

Max 4 stacked; auto fade-out.

---

## Controls

| Input | Action |
|-------|--------|
| Right Control | Toggle UI |
| Title bar drag | Move window |
| Yellow traffic | Minimize |
| Red traffic | Destroy |

---

## Full example script

See [Example.lua](./Example.lua) for a complete Home + Main (Player / Visuals / Automation / Info) + built-in Settings demo.

Minimal copy-paste:

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/urmoit/CYVUILibrary/main/Library.lua"))()

local Window = Library:CreateWindow({
    Title = "CYVHUB",
    GameName = "Demo",
    Version = "v1.0",
})

local Home = Window:CreateTab({ Name = "Home", Icon = "house", Home = true })
Home:CreateHomeLayout({
    Username = game.Players.LocalPlayer.DisplayName,
    AboutText = "Demo hub using CYVUI.",
    DiscordLink = "https://discord.gg/vTe3sNTsDM",
    Changelog = {
        { Version = "v1.0.6", Date = "2026-08-31", Text = "Fixed UI dragging when moving the mouse quickly or outside the header area." },
    },
})

local Main = Window:CreateTab({ Name = "Main", Icon = "layout" })
local Sec = Main:CreateSection("General", { Icon = "settings" })
Sec:AddToggle({ Text = "Enabled", Flag = "Enabled", Default = true })
Sec:AddSlider({ Text = "Value", Min = 0, Max = 100, Default = 50, Flag = "Value" })
Sec:AddButton({
    Text = "Notify",
    Accent = true,
    Callback = function()
        Library:Notify("Demo", "Button pressed", 2, "success")
    end,
})
```

---

## File structure

```
CYVUI/
├── Library.lua
├── Example.lua
├── DOCS.md
└── README.md
```

---

## Notes

- Home + Settings structure is **shared** across all games; only strings/stats/changelog differ.
- Compatible with most executors (`protect_gui` / `gethui` / CoreGui).
- Creating a new window destroys the previous one.
- Discord invite used in examples: `https://discord.gg/vTe3sNTsDM`


---

## Two-column layouts

```lua
local row = Main:CreateRow()
local Left = row:Section("Auto Clean", { Icon = "trash" })
local Right = row:Section("Visuals", { Icon = "eye" })

Left:AddToggle({ Text = "Auto Collect", Flag = "AutoCollect" })
Right:AddColorPicker({ Text = "Paper Color", Default = Color3.fromRGB(168, 85, 247), Flag = "PaperColor" })
```

Full-width sections still use:

```lua
local Full = Main:CreateSection("General", { Icon = "settings" })
```


---

## Mobile

When `UserInputService.TouchEnabled` is true (or `CreateWindow({ MobileToggle = true })`), the library fits the window to narrow viewports (under 700px wide, clamped to screen bounds) and keeps it centered when the viewport changes, and shows a draggable floating toggle (also exposed as `window.MobileToggle`). Window dragging samples the cursor globally every frame, so fast mouse movement never loses the drag. Touch dragging uses tap-versus-drag detection, the toggle stays within screen bounds, and tabs, sliders, toggles, buttons, dropdowns, color picker controls, and notification close buttons support touch activation without double-firing.

```lua
Library:CreateWindow({
    Title = "CYVUI",
    MobileToggle = true, -- force show even on desktop
})
```
