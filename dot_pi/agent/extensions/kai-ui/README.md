# kai-ui

My Pi UI layer, replacing `pi-open-tui` and `pi-pretty`. It only uses Pi's public extension API,
takes every colour from the active theme (Catppuccin Mocha) and uses Nerd Font glyphs
(FantasqueSansM Nerd Font) wherever one exists.

```
 [pi]  [logo] claude-opus-5-5 · [brain] high       ← header (startup)
       [folder] ~/src/app
       /model  /settings  /resume  /tree  /hotkeys  /kai-ui

 > my prompt                                      ← sent messages get a >

 [script] codemode · 3 calls · 1.3s               ← every tool call is a card with the same header;
   ✓ [file] read package.json · 4ms                  codemode lists its nested calls, and shows its
   ✗ [term] bash npm test · exit 1 · 3.1s            script and output only when expanded (Ctrl+O)

╭───── ⠋ Working ────  38 t/s ▂▄▆  1.2s  8.4s ─╮    ← turn stats on the input's top rule
│ > next prompt                                   │
╰─────────────────────────────────────────────────╯
 [folder] ~/src/app  [branch] main  [node] 22.1.0  [code] LSP 2  [broom] O [bar] P [bar]     [gauge] [bar] 42% 1M  [up] 140k [down] 3.4k [db-tick] 94% [usd] 0.42  [wallet] [bar] 62%
```

## Files

| File | What it does |
|---|---|
| `index.ts` | Wires everything up, feeds turn stats from Pi's events, adds `/kai-ui` |
| `header.ts` | Startup header |
| `footer.ts` | Footer layout: a single row, with other extensions' status text after the runtime |
| `statuses.ts` | Rules that shorten other extensions' status text to icons (LSP, subagents, blackhole) and put the usage quota in the footer |
| `voice.ts` | Moves pi-listen's hold-to-talk island from below the editor onto the input's top rule (wraps `setWidget`/`setStatus` on the shared `ctx.ui`) |
| `editor.ts` | `FramedEditor`, a `CustomEditor` with a rounded frame, a prompt and a top-right label |
| `segments.ts` | The pieces the header, footer and editor show: cwd, git, model, thinking, context, usage, speed |
| `brands.ts` | Which logo goes next to a model name (Claude, GitHub, OpenAI, Google, Azure, AWS) |
| `tools.ts` | Tool cards for built-in tools and codemode, including codemode's nested calls |
| `widgets.ts` | Nerd Font progress bar, sparkline |
| `icons.ts` | Nerd Font glyphs by meaning, plus the progress-bar and spinner glyphs |
| `palette.ts` | Catppuccin colour names → theme tokens, and the spinner frames |
| `project.ts` | Git status and runtime detection |
| `stats.ts` | Tokens/s (with recent history), time to first token, run duration |
| `format.ts` | Path, number and duration helpers |

## Changing it

- **Colours:** use `paint(theme, "mauve", text)` from `palette.ts`. To change what a Catppuccin
  name means, change its token there or in `~/.pi/agent/themes/catppuccin-mocha.json`.
- **Glyphs:** add them to `icons.ts` by meaning. Look a glyph up by *name* in the Nerd Fonts cheat
  sheet, not by codepoint, and check the font has it.
- **Model logos:** `BRANDS` in `brands.ts`. The first matching rule wins, so GitHub Copilot comes
  before the model families it serves; move it down to show a Claude logo for Claude via Copilot.
- **Tool cards:** built-in tools are entries in `TOOLS` in `tools.ts`; other tools seen inside
  codemode get an icon from `OTHER_TOOLS` by name prefix. `ICON_GAP` sets the space after an icon.
- **Runtimes:** add a line to `RUNTIMES` in `project.ts`.
- Pi picks up changes after `/reload` or in a new session.
- `/kai-ui` switches the layer off and on to compare with Pi's default UI. Tool cards and messages
  already drawn keep their style.

## Type checking

The `devDependencies` are only for types and editor support; Pi supplies the real modules.

```fish
npm install; and npm run check
```

kai-ui is left out of `pi compile` (`--exclude kai-ui`) so edits load straight away. To
compile it in once it settles: `pi compile --include kai-ui`.

## Diagnosing a flash or dropped keystrokes

```fish
env PI_TUI_DEBUG_REDRAW=1 PI_TUI_WRITE_LOG=/tmp/pi-tui-raw.log pi
```

- `~/.pi/agent/pi-tui-debug.log` gets one line per full-screen redraw (the flash), with the reason.
  A flash with no line there came from the terminal or herdr, not Pi.
- `PI_TUI_WRITE_LOG` records everything Pi writes to the terminal.

## Limits of the public API

- Pi puts a blank line above every tool card.
- The hidden-thinking label is Pi's default: the API sets one label for all rows at once.
- Sparklines use Unicode block elements, because Nerd Fonts has no sparkline glyphs.
