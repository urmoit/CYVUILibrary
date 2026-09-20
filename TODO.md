# CYVUI Library TODO

Tracks validation gaps, known risks, and planned work for **CYVUI Library v1.1.1**.

> Runtime truth lives in Roblox / an executor. Static edits alone are not a release check.

## Priority legend

- **P0** — blocks reliable use or can break core flows
- **P1** — important quality / correctness
- **P2** — backlog / polish

---

## Done in v1.1.1 (Stability)

- [x] **Dropdown remake** — search, Select All / Deselect All (multi), open accent border, outside-click close, compact multi labels
- [x] **Floating toggle always on** — rounded square on PC + mobile, draggable, click toggles UI (no `MobileToggle` flag)
- [x] **Subtab polish** — chip-style active state
- [x] **Settings theme presets** — reliable click handlers; `SetTheme` updates accent surfaces + mobile toggle
- [x] **Notifications themed** — panel/border/text from main theme; type color on bar + progress; respects Notifications flag
- [x] **Watermark** — real on-screen bar (title · hub · version + fps/ping), draggable, Settings → General toggle
- [x] **Config Save/Load** — built-in `CYVUI_<name>.json` via writefile/readfile when available; `OnSave` / `OnLoad` hooks still work
- [x] **Reload purge** — `CreateWindow` destroys prior CYVUI ScreenGuis (tracked windows, watermark, notify holder, CoreGui / PlayerGui / gethui leftovers)
- [x] **Destroy UI** — cleans main UI, watermark, notify holder, windows table
- [x] **UI Transparency slider** — applies to main frame + panels
- [x] **Single active window** — only one CYVUI UI at a time

## Done in v1.1.0 (Redesign)

- [x] Ironite layout: header, 75px sidebar, subtab row, two-column sections
- [x] `Tab:AddSubtab` / `Subtab:CreateSection` API (+ legacy `Tab:CreateSection`)
- [x] Section master toggle, redesigned widgets, floating color popup
- [x] Home + Settings layouts restyled
- [x] Fixed Instance metadata crash (`rowMeta` table)
- [x] Fixed tab/subtab visibility, sidebar Settings order, geometry, section holder sizing
- [x] Global drag sampling for title-bar move

---

## Bugs and risks to validate (runtime)

- [ ] **P0 — Full Studio / executor pass.** Open window, switch tabs + subtabs, fire every widget callback, destroy + recreate.
- [ ] **P0 — Reload stress.** Execute the same hub script 5+ times in one session; confirm no stacked UIs, no leftover watermarks/toggles/notifies.
- [ ] **P0 — Settings end-to-end.** Theme presets, transparency, config save/load (with and without writefile), watermark toggle, notifications toggle, minimize keybind, Destroy UI.
- [ ] **P1 — Dropdown edge cases.** Empty options, long option lists, multi select all/none, search with no matches, open while scrolling section, open near screen edge.
- [ ] **P1 — Drag vs click on floating toggle.** Drag without accidental toggle; short click still toggles; works on touch.
- [ ] **P1 — Watermark.** Visibility follows flag; fps/ping update; drag stays on-screen; survives theme change; destroyed on reload.
- [ ] **P1 — Notification stack.** 4-cap, all kinds, long text, Notifications = false suppresses, theme colors after `SetTheme`.
- [ ] **P1 — Connection cleanup.** After Destroy / reload, no stale InputBegan / loops from previous window (esp. watermark fps loop, dropdown outside-click, keybind).
- [ ] **P1 — Title-bar drag.** Fast cursor exit still tracks; release ends drag; works with header-only handle.

---

## Documentation / consistency

- [ ] **P1 — Version lock.** Keep `Library.lua`, `Example.lua`, `README.md`, `DOCS.md`, `CHANGELOG.md` on the same version string before tagging.
- [ ] **P1 — DOCS pass for v1.1.1.** Document watermark API (`SetWatermarkVisible`, `SetWatermarkText`), config file naming, reload purge behavior, always-on floating toggle.
- [ ] **P1 — Example refresh.** Ensure Example exercises multi dropdown search, Settings theme, watermark toggle path.
- [ ] **P2 — Environment matrix.** Studio vs executors: `gethui`, `protect_gui`, `writefile` / `readfile` / `isfile`, touch vs mouse.

---

## Planned improvements

### Usability

- [ ] **P1 — Keyboard focus / navigation** for tabs, buttons, dropdowns, sliders, textboxes
- [ ] **P1 — Reduced-motion option** for notifies / panel animations
- [ ] **P1 — Small-screen layout** — clamp window, scroll all panels, keep toggle + watermark reachable
- [ ] **P2 — Configurable floating toggle** (corner, offset, size, icon)
- [ ] **P2 — Stronger pressed / disabled / validation states** on controls

### Reliability

- [ ] **P0 — Automated Luau parse / lint** on every change (local + CI)
- [ ] **P1 — Connection registry** per window (disconnect on destroy)
- [ ] **P1 — Minimal runtime demo harness** (create/destroy, widgets, flags, theme, notify, watermark, config)
- [ ] **P2 — Document callback `pcall` policy** consistently across widgets
- [ ] **P2 — Optional debug mode** (missing icons, bad options, callback errors)

### Feature backlog

- [ ] **P1 — Structured changelog items** (`{ Text, Type }` with added/fixed/changed/removed) — regressed in v1.1.0 rewrite
- [ ] **P1 — Notification position + queue options**
- [ ] **P1 — Collapsible / filterable Home changelog**
- [ ] **P2 — Reset-to-default** per control / section
- [ ] **P2 — Config versioning + migration hooks**
- [ ] **P2 — Theme export/import**
- [ ] **P2 — Localization hooks** for built-in strings

---

## Known regressions / follow-ups

Carried from the v1.1.0 redesign unless noted fixed in v1.1.1:

| Item | Status | Notes |
|------|--------|--------|
| Structured changelog `{ Text, Type }` rows | Open | Home only renders string `Text` / string `Items` |
| Full mobile viewport scaling | Partial | Floating toggle always on + basic shrink; no full clamp suite |
| Tap-vs-drag on floating toggle | Improved in 1.1.1 | Distance threshold added; still needs device testing |
| Dropdown search / Select All | Fixed in 1.1.1 | Redesigned |
| Settings theme / general dead controls | Fixed in 1.1.1 | Click handlers + real watermark/config |
| Stacked UIs on re-execute | Fixed in 1.1.1 | Global CYVUI ScreenGui purge |

---

## Release checklist (before next bump)

1. Version string identical across Library / Example / README / DOCS / CHANGELOG  
2. CHANGELOG entry lists user-visible changes only  
3. Example runs clean on a fresh executor session  
4. Reload 5× without leftover GUIs  
5. Settings: theme, transparency, save, load, watermark, notifications, destroy  
6. Dropdown: single + multi + search + select all  
7. Update this TODO — move finished items to **Done**
