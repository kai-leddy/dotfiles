# sketchybar config

Lua config for [SketchyBar](https://github.com/FelixKratz/SketchyBar) using
[SbarLua](https://github.com/FelixKratz/SbarLua). `sketchybarrc` loads `init.lua`,
which loads `bar.lua`, `default.lua` and everything in `items/`. Hotload is on,
so saving a file reloads the bar.

## Layout

| File | What it is |
| --- | --- |
| `settings.lua` | Gaps, fonts, padding, and the settle timings. |
| `colors.lua`, `icons.lua`, `app_icons.lua` | Palette and glyphs. |
| `pill_group.lua`, `graph.lua` | Shared building blocks for the merged pills and the line graphs. |
| `utils.lua` | Display helpers (`get_display_lengths`, `watch_display_lengths`). |
| `debounce.lua` | `trailing` and `single_flight`, see below. |
| `settle.lua` | Shared "wait for the burst to end, then refresh once" event bus, see below. |
| `items/` | One file per item. `items/init.lua` sets the order. |
| `helpers/` | Shell scripts the items call. |

## Why there is a settle bus

After a wake, an unlock or a DisplayLink dock reconnecting, macOS sends a burst
of events: several `display_change`, plus `system_woke` and `wifi_change`.
WindowServer is already saturated at that point. Before the bus, every item
that listened to one of those events reacted on its own, so the same few seconds
ran the aerospace queries, five separate `sketchybar --query displays | jq`
calls, and the wifi, battery and AI quota refreshes all at once. Each one is a
spawned process, and they all landed together.

Now they go through `settle.lua`.

### `settle.subscribe(events, fn, opts)`

```lua
local settle = require("settle")

settle.subscribe({ "wifi_change", "system_woke" }, update_wifi_status, {
	delay = 0.5,    -- seconds after the window closes (stagger heavy handlers)
	name = "wifi",  -- shows up in the debug log
})
```

- All events share one quiet window. The window closes `settings.settle.wait`
  seconds (default 2) after the last event arrived. A continuous storm can push
  it back at most `settings.settle.max_wait` seconds (default 10) in total.
- When the window closes, each handler runs once, no matter how many of its
  events arrived or how many times. Four `display_change` events and one
  `system_woke` is one run for a handler subscribed to both.
- `fn` gets `env.SENDER` (the last matching event) and `env.EVENTS` (a set of
  every event seen in the burst).
- `delay` spreads the handlers out after the window closes so they don't all
  spawn processes in the same instant.

Current handlers and their delays:

| Handler | Events | Delay |
| --- | --- | --- |
| display lengths (`utils.lua`, feeds `task` and `meeting`) | `display_change` | 0 s |
| aerospace monitors and windows | `display_change` | 0.25 s |
| wifi | `wifi_change`, `system_woke` | 0.5 s |
| battery | `system_woke` | 0.75 s |
| AI quota (network fetch) | `system_woke` | 1.5 s |

Use the bus for things that react to the machine changing state. Do not use it
for anything the user is waiting on. Clicks, `aerospace_workspace_change` and
`aerospace_focus_change` stay as plain `item:subscribe` calls, because a
2 second lag there would feel broken. Wifi is the borderline case: its icon now
updates up to 2 s after a network change.

### `utils.watch_display_lengths(callback)`

`task.lua` and `meeting.lua` each need to know which displays are wide and
which are narrow. They used to query on load and on every `display_change`,
twice per file. They now register a callback with
`utils.watch_display_lengths`, and all callbacks share one query. Registrations
made while loading collapse into a single initial query, and display changes
re-run it once per settled burst.

## `debounce.lua`

Both helpers use `sbar.delay`, so they only work once the event loop is running.

- `debounce.trailing(wait, fn, { max_wait })` runs `fn` once, `wait` seconds
  after the last call. Each call restarts the timer. `max_wait` stops a
  never-ending burst from postponing it forever (whole-second resolution).
- `debounce.single_flight(fn, { timeout })` is for async work. `fn(done)` must
  call `done()` when it finishes. Only one run is in flight at a time, and any
  calls made meanwhile collapse into one follow-up run that starts after the
  current one ends, so it sees fresh state. If `done` is never called (a hung
  command, a callback that errors), the run is released after `timeout` seconds
  (default 15).

`items/aerospace.lua` wraps `updateWindows` in `single_flight`, since it chains
three `aerospace` calls and is triggered by both focus changes and display
changes.

## Adding an item that refreshes on wake or display changes

1. Subscribe normal timer events (`routine`, `forced`) on the item as usual.
2. Put the wake and display events through `settle.subscribe`, and give the
   handler a `delay` if it spawns something slow or hits the network.
3. If you need display widths, call `utils.watch_display_lengths` instead of
   querying yourself.

## Debugging

`settings.settle.debug` is `false`. Set it to `true` and it writes every raw
event and every flush to `/tmp/sketchybar-settle.log` (truncated on each reload):

```
11:10:08 event display_change
11:10:09 event display_change
11:10:10 event system_woke
11:10:12 settled after: display_change, system_woke
11:10:12   run aerospace monitors + windows (+0.25s)
```

To see what an unlock really produces, lock the screen, unlock it, and read the
file. `screen_locked` and `screen_unlocked` are registered from the
`com.apple.screenIsLocked` and `com.apple.screenIsUnlocked` distributed
notifications, and the log shows whether they arrive. Set `debug` back to
`false` when you are done.

You can simulate a burst with:

```fish
for i in (seq 4); sketchybar --trigger display_change; sleep 0.4; end
sketchybar --trigger system_woke
```

## Tuning

- Bar still busy right after unlock: raise `settle.wait`, or raise the `delay`
  of the heaviest handlers.
- Things feel slow to update after plugging in a monitor: lower `settle.wait`.
