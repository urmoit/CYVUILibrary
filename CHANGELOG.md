# CYVUI Changelog

Full release history. The README image highlights the latest UI releases.

---

## v1.0.6 — 2026-08-31

- **Fixed UI dragging** — title-bar dragging now remains reliable when the mouse moves quickly or leaves the header area

---

## v1.0.5 — 2026-08-31

- **Changelog redesign** — compact header, version pill, release cards, separators, Latest badge, and structured status rows
- **Improved notifications** — wider tinted cards, circular status icons, accent strips, responsive message height, smoother animations, and touch-safe dismissal
- **Better mobile support** — responsive viewport fitting, reliable touch dragging, draggable floating toggle with tap-versus-drag detection, and screen-bound positioning
- **Window dragging fix** — title-bar dragging now samples the cursor globally every frame, so fast mouse movement no longer loses the drag when the pointer leaves the header
- **Touch dragging preserved** — touch movement continues to follow global input while mouse dragging uses frame-sampled cursor positions
- **Touch-safe controls** — shared click binding fires once for mouse and touch across tabs, toggles, sliders, buttons, dropdowns, color picker triggers, and notification close buttons (no double-firing)
- **Theme-aware notifications** — tinted card backgrounds derive from the active accent color; `info` is the default notification type and duration defaults to 3 seconds
- Existing changelog configuration remains compatible with `Text`, plain `Items`, and structured `{ Text, Type }` items

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
