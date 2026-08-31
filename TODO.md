# CYVUI Library TODO

This file tracks confirmed validation gaps, known risks, and planned improvements for CYVUI Library v1.0.5.

## Priority legend

- **P0** — blocks reliable release or can break core usage
- **P1** — important quality/usability work
- **P2** — future enhancement or maintenance

## Bugs and risks to validate

- [ ] **P0 — Run Luau syntax validation.** No Lua/Luau interpreter is currently installed in the development environment. Validate `Library.lua` and `Example.lua` with a Luau-compatible parser before the next release.
- [ ] **P0 — Test in Roblox/executor environments.** The library depends on Roblox services, CoreGui/gethui/protect-gui behavior, executor APIs, and Roblox input events; local static checks cannot confirm runtime compatibility.
- [ ] **P1 — Verify fast mouse dragging at runtime.** Confirm that title-bar dragging continues when the cursor leaves the header rapidly and stops only after mouse release. Test across different frame rates and window positions.
- [ ] **P1 — Verify touch dragging and mobile fitting.** Test narrow portrait and landscape viewports, viewport changes, touch drag cancellation, and window bounds. Confirm the floating toggle remains reachable and does not double-toggle.
- [ ] **P1 — Verify notification lifecycle.** Test all notification types (`success`, `warning`, `error`, `info`), long messages, four simultaneous notifications, manual close, auto-dismiss, theme changes, and repeated close/expiry events.
- [ ] **P1 — Verify structured changelog rendering.** Test release entries with plain `Text`, string `Items`, and structured `{ Text, Type }` items using `added`, `fixed`, `changed`, and `removed` types. Test an empty or missing changelog safely.
- [ ] **P1 — Audit event connections during destruction.** Confirm that window input, render-step, viewport, notification, and mobile-toggle connections are disconnected or harmless after the UI is destroyed and recreated.

## Documentation and consistency checks

- [ ] **P1 — Add a release checklist.** Before each version bump, verify `Library.lua`, `README.md`, `DOCS.md`, `Example.lua`, and `CHANGELOG.md` use the same version and describe the same public behavior.
- [ ] **P1 — Keep API examples executable.** Periodically run the examples in a Roblox test place and update examples when method signatures or return values change.
- [ ] **P2 — Add a supported-environment matrix.** Document Roblox Studio limitations, executor-specific APIs, optional filesystem APIs, `gethui`, `protect_gui`, and fallback behavior.
- [ ] **P2 — Add API type/reference coverage.** Document defaults, callback timing, return values, and edge cases for every widget, especially sliders, dropdowns, color pickers, keybinds, and settings callbacks.

## Planned improvements

### Usability and accessibility

- [ ] **P1 — Add keyboard focus states and navigation.** Make tabs, buttons, dropdowns, sliders, and textboxes usable without relying only on mouse input.
- [ ] **P1 — Add reduced-motion support.** Provide a setting or automatic preference to reduce notification and panel animations.
- [ ] **P1 — Improve small-screen scrolling.** Ensure every mobile panel, dropdown, color popup, changelog list, and settings page remains reachable without clipping or overlap.
- [ ] **P2 — Make mobile toggle placement configurable.** Allow users to choose the edge, offset, scale, and visibility of the floating toggle.
- [ ] **P2 — Add clearer input feedback.** Improve pressed, focused, disabled, and validation states across all interactive controls.

### Reliability and maintainability

- [ ] **P0 — Add automated Luau parsing/linting.** Run it in local development and CI for every change.
- [ ] **P1 — Add a minimal runtime test/demo harness.** Cover window creation/destruction, tabs, all widgets, flags, themes, notifications, changelog layouts, and mobile paths.
- [ ] **P1 — Centralize connection cleanup.** Track RBXScriptConnections and background loops per window so recreation cannot leave stale behavior behind.
- [ ] **P2 — Add defensive callback isolation.** Decide whether user callbacks should be protected with `pcall`, then document the chosen behavior consistently.
- [ ] **P2 — Add optional debug diagnostics.** Provide a development-only mode for missing icons, invalid options, callback errors, and unsupported executor APIs.
- [ ] **P2 — Reduce repeated UI construction code.** Refactor only after behavior is covered by tests, keeping the public API backward compatible.

### Feature backlog

- [ ] **P1 — Add changelog filtering or collapsible releases** for long release histories.
- [ ] **P1 — Add configurable notification position** and optional notification queue behavior.
- [ ] **P2 — Add widget reset-to-default support** for individual controls and full sections.
- [ ] **P2 — Add config versioning and migration hooks** for saved flags after library updates.
- [ ] **P2 — Add optional localization support** for built-in labels, settings text, notifications, and status badges.
- [ ] **P2 — Add theme export/import** alongside config save/load.

## Completed in v1.0.5

- Redesigned changelog cards with version/date metadata, Latest badge, separators, and structured status rows.
- Improved notifications with tinted status cards, accent strips, circular icons, responsive height, animations, and touch-safe dismissal.
- Improved mobile behavior with responsive viewport fitting, global touch dragging, draggable floating toggle bounds, and tap-versus-drag detection.
- Added touch-safe activation for tabs, toggles, dropdowns, color picker controls, buttons, notification close controls, and sliders.
- Fixed fast mouse dragging by sampling cursor position globally each render frame while dragging.
