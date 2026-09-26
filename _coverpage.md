# CYVUI

> A native-style, high-performance Roblox UI library. Twenty-plus widgets, a live theme engine, and built-in Home and Settings layouts — one file, no dependencies.

- v1.1.0
- 20+ widgets
- Live theme engine
- Home & Settings layouts
- Zero dependencies

[Get Started](#/DOCS)
[View on GitHub](https://github.com/urmoit/CYVUILibrary)

```lua
local CYVUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/urmoit/CYVUILibrary/main/Library.lua"))()

local Window = CYVUI:Window({ Title = "CYVUI", Theme = "Graphite" })
local Tab    = Window:Tab({ Title = "General", Icon = "sliders" })
local Group  = Tab:Section({ Title = "Aim" })

Group:Toggle({ Title = "Enabled", Value = true, Flag = "AimEnabled" })
Group:Slider({ Title = "FOV", Min = 0, Max = 120, Value = 60, Flag = "AimFOV" })
```

| | |
|---|---|
| Widgets | Toggle, slider, dropdown, textbox, keybind, color picker, paragraph, button |
| Layouts | Dashboard Home and a shared Settings view that render identically in every game |
| Theming | Swap accents at runtime; every bound element recolours on the same frame |
| Footprint | Single `Library.lua`, no external dependencies |

