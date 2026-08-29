# CYVUI Library Documentation

**Version:** 1.0.0  
**Style:** Dark modern UI matching CYVHUB home layout

---

## Installation

```lua
local Library = loadstring(game:HttpGet("YOUR_RAW_URL/Library.lua"))()
```

Or place `Library.lua` in your project and require it.

---

## Quick Start

```lua
local Library = loadstring(...)()

local Window = Library:CreateWindow({
    Title    = "CYVHUB",
    GameName = "My Game",
    Version  = "v1.0",
    Size     = UDim2.new(0, 720, 0, 500),
})

local Home = Window:CreateTab({ Name = "Home", Icon = "⌂", Home = true })
Home:CreateHomeLayout({
    Username    = game.Players.LocalPlayer.DisplayName,
    Welcome     = "welcome back",
    AboutText   = "Your hub description here.",
    DiscordLink = "https://discord.gg/invite",
    Changelog   = {
        { Version = "v1.0", Text = "Release." },
    },
})

local Main = Window:CreateTab({ Name = "Main", Icon = "⚡" })
local Sec = Main:CreateSection("Features")
Sec:AddToggle({ Text = "Enabled", Flag = "Enabled", Callback = function(v) end })
```

---

## Window

### `Library:CreateWindow(config)`

| Key        | Type   | Default      | Description                    |
|------------|--------|--------------|--------------------------------|
| Title      | string | `"CYVHUB"`   | Left part of title bar         |
| GameName   | string | `"game name"`| Middle part of title bar       |
| Version    | string | `"v1.0"`     | Right part of title bar        |
| Size       | UDim2  | `720x480`    | Window size                    |

**Returns:** Window object

### Window methods

| Method | Description |
|--------|-------------|
| `:SetTitle(title, game, version)` | Update title bar text |
| `:CreateTab(config)` | Create a sidebar tab |

---

## Tabs

### `Window:CreateTab(config)`

| Key  | Type    | Default | Description                          |
|------|---------|---------|--------------------------------------|
| Name | string  | `"Tab"` | Sidebar label                        |
| Icon | string  | `"•"`   | Sidebar icon (emoji or text)         |
| Home | boolean | `false` | Marks as default selected home tab   |

**Returns:** Tab object

### Tab methods

| Method | Description |
|--------|-------------|
| `:CreateSection(name)` | Creates a card section with header |
| `:CreateHomeLayout(config)` | Builds the special Home dashboard |

---

## Home Layout

Matches the reference image exactly:

```
┌─────────────┬──────────────────────────┐
│  Avatar     │  About                   │
│  username   │  (description text)      │
│  welcome    │                          │
├──────┬──────┴───────────┬──────────────┤
│Discord│  Server Info    │  Executor    │
│[Copy] │  players / job  │  name        │
├──────┴──────────────────┴──────────────┤
│  Changelog                             │
│  [entries...]                          │
└────────────────────────────────────────┘
```

### `Tab:CreateHomeLayout(config)`

| Key          | Type   | Description                                      |
|--------------|--------|--------------------------------------------------|
| Username     | string | Display name under avatar                        |
| Welcome      | string | Subtitle (default: `"welcome back"`)             |
| AboutTitle   | string | About card header (default: `"About"`)           |
| AboutText    | string | About body text                                  |
| DiscordLink  | string | Link copied by the Copy Link button              |
| ServerInfo   | string | Multi-line server info text                      |
| ExecutorName | string | Executor display name                            |
| Changelog    | table  | Array of `{ Version = "v1.0", Text = "..." }`    |

**Returns:** table with setters (`SetUsername`, `SetAbout`, `SetServerInfo`, `SetExecutor`)

---

## Sections

### `Tab:CreateSection(name)`

Creates a rounded card with a bold header. All elements are added inside.

---

## Elements

### Toggle

```lua
section:AddToggle({
    Text     = "Aimbot",
    Default  = false,
    Flag     = "Aimbot",       -- stored in Library.Flags
    Callback = function(value) end,
})
```

Returns object with `:Set(bool)` and `:Get()`.

### Slider

```lua
section:AddSlider({
    Text     = "FOV",
    Min      = 50,
    Max      = 400,
    Default  = 120,
    Decimals = 0,
    Flag     = "FOV",
    Callback = function(value) end,
})
```

### Button

```lua
section:AddButton({
    Text     = "Click Me",
    Callback = function() end,
})
```

### Dropdown

```lua
section:AddDropdown({
    Text     = "Target",
    Options  = { "Head", "Torso", "HRP" },
    Default  = "Head",
    Flag     = "Target",
    Callback = function(selected) end,
})
```

### Textbox

```lua
section:AddTextbox({
    Text        = "Webhook",
    Placeholder = "https://...",
    Default     = "",
    Flag        = "Webhook",
    Callback    = function(text) end,
})
```

### Keybind

```lua
section:AddKeybind({
    Text     = "Fly Toggle",
    Default  = Enum.KeyCode.F,
    Flag     = "FlyKey",
    Callback = function(keyCode) end,
})
```

### Label / Paragraph

```lua
section:AddLabel("Short label text")
section:AddParagraph("Longer multi-line description that wraps.")
```

---

## Flags

All elements with a `Flag` string store their value in `Library.Flags`.

```lua
local value = Library:GetFlag("Aimbot")
Library:SetFlag("Aimbot", true)
```

---

## Notifications

```lua
Library:Notify("Title", "Message body", 3, "success")
-- types: "success" | "warning" | "error" | nil (accent)
```

Notifications slide in from the top-right.

---

## Theme

Accessible via `Library.Theme` table. Key colors:

| Key          | Default RGB          | Usage                |
|--------------|----------------------|----------------------|
| Background   | 12, 12, 14           | Main window          |
| Sidebar      | 16, 16, 18           | Left sidebar         |
| Card         | 28, 28, 34           | Cards / panels       |
| Accent       | 82, 190, 255         | Highlights / toggles |
| Text         | 235, 238, 245        | Primary text         |
| TextDim      | 140, 145, 155        | Secondary text       |

Change accent at runtime through the built-in Settings tab dropdown, or by editing `Library.Theme.Accent` before creating the window.

---

## Controls

| Input            | Action                |
|------------------|-----------------------|
| Right Control    | Toggle UI visibility  |
| Title bar drag   | Move window           |
| Yellow traffic   | Minimize / restore    |
| Red traffic      | Destroy UI            |

---

## File Structure

```
CYVUI Library/
├── Library.lua    -- Core library
├── Example.lua    -- Full usage example
└── DOCS.md        -- This file
```

---

## Notes

- Compatible with most executors (protect_gui / gethui / CoreGui fallback).
- Home layout is fixed-position cards to match the design reference.
- Other tabs use vertical scrolling sections.
- Settings tab is always available via the bottom sidebar button.
- Destroy previous instances automatically when creating a new window.
