# kai-ui

My Pi UI layer, replacing `pi-open-tui` and `pi-pretty`. It only uses Pi's public extension API
and takes every colour from the active theme (Catppuccin Mocha).

```
 π  claude-opus-5-5 · high                       ← header (startup)
    ~/src/app
    /model  /settings  /resume  /tree  /hotkeys  /kai-ui

 ❯ my prompt                                      ← sent messages get a ❯

 ✓  read src/index.ts · 80 lines · 12ms           ← one row per built-in tool call
 ✗  bash npm test · exit 1 · 3.1s                    (Ctrl+O shows Pi's full output)

╭──── ⠋ Working ─────────────────────────────╮    ← framed editor; spinner in the frame
│ ❯ next prompt                              │
╰────────────────────────────────────────────╯
 ~/src/app   main ⇡1 !2 ?1   22.1.0     claude-opus-5-5 · high
ctx 42% of 200k  ↑12k ↓3.4k R140k  $0.42   38 tok/s  ttft 1.2s  ⏱ 8.4s
<statuses from other extensions>
```

## Files

| File | What it does |
|---|---|
| `index.ts` | Wires everything up, feeds turn stats from Pi's events, adds `/kai-ui` |
| `header.ts` | Startup header |
| `footer.ts` | Footer lines |
| `editor.ts` | `FramedEditor`, a `CustomEditor` with a rounded frame and ❯ |
| `tools.ts` | Compact rows for `read`, `bash`, `edit`, `write`, `grep`, `find`, `ls` |
| `palette.ts` | Catppuccin colour names → theme tokens, and the spinner frames |
| `project.ts` | Git status and runtime detection for the footer |
| `stats.ts` | Tokens/s, time to first token, run duration |
| `format.ts` | Path, number and duration helpers |

## Changing it

- **Colours:** use `paint(theme, "mauve", text)` from `palette.ts`. To change what a Catppuccin
  name means, change its token there or in `~/.pi/agent/themes/catppuccin-mocha.json`.
- **Tool rows:** each tool's icon, colour, summary and outcome are one entry in `TOOLS` in `tools.ts`.
- **Runtimes:** add a line to `RUNTIMES` in `project.ts`.
- Pi picks up changes after `/reload` or in a new session.
- `/kai-ui` switches the layer off and on to compare with Pi's default UI. Tool rows and messages
  already drawn keep their style.

## Type checking

The `devDependencies` are only for types and editor support; Pi supplies the real modules.

```fish
npm install; and npm run check
```

kai-ui is left out of `pi-bolt compile` (`--exclude kai-ui`) so edits load straight away. To
compile it in once it settles: `pb compile --include kai-ui`.

## Limits of the public API

- Pi puts a blank line above every tool row, so compact rows are one line plus a gap.
- The hidden-thinking label is Pi's default: the API sets one label for all rows at once.
