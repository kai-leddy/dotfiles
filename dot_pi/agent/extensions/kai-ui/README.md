# kai-ui

My Pi UI layer, replacing `pi-open-tui` and `pi-pretty`. It only uses Pi's public extension API,
takes every colour from the active theme (Catppuccin Mocha) and uses Nerd Font glyphs
(FantasqueSansM Nerd Font) wherever one exists.

```
 󰏿  (󰚩 claude-opus-5-5  󰧑 󰪣 high)                ← header (startup)
    ( ~/src/app)
    /model  /settings  /resume  /tree  /hotkeys  /kai-ui

  my prompt                                      ← sent messages get a 

┌ 󰯁 codemode  3 calls  1.3s ───────────────┐      ← every tool call is a card with the same
│ const r = await tools.read({ … });          │         header line; codemode adds its script
│    read package.json  4ms                │         and its nested calls
│    bash npm test  exit 1  3.1s           │
└─────────────────────────────────────────────┘

╭──── ⠋ Working ──────  38 t/s ▂▄▆  󰔟 1.2s  󰔛 8.4s ─╮   ← turn stats on the input's top rule
│  next prompt                                     │
╰────────────────────────────────────────────────────╯
( ~/src/app) ( main 1 2) ( 22.1.0)      (󰚩 claude-opus-5-5  󰧑 󰪣)
(󰊚 [progress bar] 42% 1M) (󰕒 140k 󰇚 3.4k 󱊩 94% 󰇁 0.42)
<statuses from other extensions>
```

## Files

| File | What it does |
|---|---|
| `index.ts` | Wires everything up, feeds turn stats from Pi's events, adds `/kai-ui` |
| `header.ts` | Startup header |
| `footer.ts` | Footer layout: rows of pills |
| `editor.ts` | `FramedEditor`, a `CustomEditor` with a rounded frame,  prompt and a top-right label |
| `segments.ts` | The pieces the header, footer and editor show: cwd, git, model, context, usage, speed… |
| `tools.ts` | Tool cards for built-in tools and codemode, including codemode's nested calls |
| `widgets.ts` | Pills, Nerd Font progress bar, sparkline |
| `icons.ts` | Nerd Font glyphs by meaning, plus the progress, spinner and thinking-level glyphs |
| `palette.ts` | Catppuccin colour names → theme tokens, and the spinner frames |
| `project.ts` | Git status and runtime detection |
| `stats.ts` | Tokens/s (with recent history), time to first token, run duration |
| `format.ts` | Path, number and duration helpers |

## Changing it

- **Colours:** use `paint(theme, "mauve", text)` from `palette.ts`. To change what a Catppuccin
  name means, change its token there or in `~/.pi/agent/themes/catppuccin-mocha.json`.
- **Glyphs:** add them to `icons.ts` by meaning. Check the font has the glyph, or the terminal
  borrows it from another font.
- **Tool cards:** built-in tools are entries in `TOOLS` in `tools.ts`; other tools seen inside
  codemode get an icon from `OTHER_TOOLS` by name prefix.
- **Runtimes:** add a line to `RUNTIMES` in `project.ts`.
- Pi picks up changes after `/reload` or in a new session.
- `/kai-ui` switches the layer off and on to compare with Pi's default UI. Tool cards and messages
  already drawn keep their style.

## Type checking

The `devDependencies` are only for types and editor support; Pi supplies the real modules.

```fish
npm install; and npm run check
```

kai-ui is left out of `pi-bolt compile` (`--exclude kai-ui`) so edits load straight away. To
compile it in once it settles: `pb compile --include kai-ui`.

## Limits of the public API

- Pi puts a blank line above every tool card.
- The hidden-thinking label is Pi's default: the API sets one label for all rows at once.
- Sparklines use Unicode block elements, because Nerd Fonts has no sparkline glyphs.
