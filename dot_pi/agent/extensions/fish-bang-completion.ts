import { spawn } from "node:child_process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import type { AutocompleteProvider, AutocompleteSuggestions } from "@earendil-works/pi-tui";

const FISH = "/opt/homebrew/bin/fish";
const MAX_ITEMS = 50;

// Tab-complete `!` / `!!` shell commands using fish's own completion engine.
function fishComplete(line: string, cwd: string, signal: AbortSignal): Promise<string[]> {
  return new Promise((resolve) => {
    const child = spawn(FISH, ["-c", "complete -C $argv[1]", "--", line], {
      cwd,
      stdio: ["ignore", "pipe", "ignore"],
      signal,
    });
    let out = "";
    child.stdout.on("data", (d) => (out += d));
    child.on("error", () => resolve([]));
    child.on("close", () => resolve(out.split("\n").filter(Boolean)));
  });
}

// Returns the shell command text before the cursor, or undefined when not a `!` line.
function bangCommand(before: string): string | undefined {
  const m = before.match(/^!!?(.*)$/s);
  return m ? m[1].replace(/^\s+/, "") : undefined;
}

export default function (pi: ExtensionAPI): void {
  pi.on("session_start", (_event, ctx) => {
    ctx.ui.addAutocompleteProvider((current): AutocompleteProvider => ({
      triggerCharacters: current.triggerCharacters,

      async getSuggestions(lines, cursorLine, cursorCol, options): Promise<AutocompleteSuggestions | null> {
        const before = (lines[cursorLine] ?? "").slice(0, cursorCol);
        const cmd = cursorLine === 0 ? bangCommand(before) : undefined;
        if (cmd === undefined || cmd === "") return current.getSuggestions(lines, cursorLine, cursorCol, options);

        const results = await fishComplete(cmd, ctx.cwd, options.signal);
        if (options.signal.aborted || results.length === 0) return null;

        const prefix = cmd.match(/\S*$/)![0];
        const items = results.slice(0, MAX_ITEMS).map((r) => {
          const [value, description] = r.split("\t");
          return { value, label: value, description };
        });
        return { items, prefix };
      },

      applyCompletion(lines, cursorLine, cursorCol, item, prefix) {
        const line = lines[cursorLine] ?? "";
        const before = line.slice(0, cursorCol);
        if (cursorLine !== 0 || bangCommand(before) === undefined) {
          return current.applyCompletion(lines, cursorLine, cursorCol, item, prefix);
        }
        const start = cursorCol - prefix.length;
        const needsSpace = !/[\/=]$/.test(item.value);
        const inserted = item.value + (needsSpace ? " " : "");
        const next = [...lines];
        next[cursorLine] = line.slice(0, start) + inserted + line.slice(cursorCol);
        return { lines: next, cursorLine, cursorCol: start + inserted.length };
      },

      shouldTriggerFileCompletion(lines, cursorLine, cursorCol) {
        const before = (lines[cursorLine] ?? "").slice(0, cursorCol);
        if (cursorLine === 0 && bangCommand(before) !== undefined) return true;
        return current.shouldTriggerFileCompletion?.(lines, cursorLine, cursorCol) ?? true;
      },
    }));
  });
}
