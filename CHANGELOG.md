# CYVUI Changelog

Full release history. The README image only highlights the latest two versions.

---

## v1.0.4 — 2026-08-31

- **Mobile support** — on-screen draggable toggle button when `TouchEnabled` (or `MobileToggle = true`)
- **Floating color popup** — HSV picker opens on ScreenGui overlay (does not expand the section/menu)
- Color popup layout: preview swatch, SV square, vertical hue, HEX field, close button
- **Settings fixes** — tighter page/section padding; theme swatch white highlight ring on selected preset
- Minimize keybind from Settings flags honored

---

## v1.0.3 — 2026-08-30

- **Popup color picker** — compact trigger + HSV popup (square + vertical hue), hex input, click-outside to close
- **Two-column layouts** — `Tab:CreateRow()` then `row:Section(...)` for side-by-side cards
- `Tab:CreateGrid(columns)` for multi-column section grids
- Home changelog cards refined (Latest badge, accent border on current release)

---

## v1.0.2 — 2026-08-30

- **Working color picker** — HSV saturation/value panel + hue bar, live hex, open from swatch
- **Dropdown upgrade**
  - Search field when open
  - `Multi = true` for multi-select
  - **All** toggle selects/deselects every option
- **Live server stats** on Home — Players, session uptime, real server ping
- **Home changelog cards** — version pills, Latest badge, per-entry cards
- Settings save/load no longer error when callbacks are missing
- UI transparency slider applies soft panel opacity

---

## v1.0.1 — 2026-08-29

- Notification toasts redesigned (Success / Warning / Error cards with icons + close)
- Badge overflow fix on Executor Active and changelog version pills
- Example title set to `CYVUI | Example`
- New README banner artwork

---

## v1.0.0 — 2026-08-29

- Initial release
- Home dashboard (profile, about, Discord, server stats, executor, custom changelog)
- Built-in Settings (theme presets, config hooks, keybinds)
- Widgets: toggle, slider, dropdown, textbox, keybind, color picker, button, label
- Lucide icons (Footagesus Icons v2 + fallbacks)
- Live theme recolor via `Library:SetTheme`
- Flags system + notifications
