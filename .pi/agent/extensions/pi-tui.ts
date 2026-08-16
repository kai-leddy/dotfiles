import { execFileSync } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join, relative } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { CustomEditor } from "@earendil-works/pi-coding-agent";
import { Text, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

/** Dependency-free Catppuccin Mocha TUI for Pi. */
type Config = {
  enabled?: boolean;
  footerSegments?: Record<string, boolean>;
  telemetry?: Record<string, boolean>;
};
type Stats = { input: number; output: number; cost: number };

const HOME = homedir();
const CONFIG_FILE = join(HOME, ".pi", "agent", "open-tui.json");
const palette = {
  blue: "#89b4fa", mauve: "#cba6f7", teal: "#94e2d5", pink: "#f5c2e7",
  sky: "#89dceb", yellow: "#f9e2af", green: "#a6e3a1", text: "#cdd6f4",
  dim: "#6c7086", surface0: "#313244", surface1: "#45475a", crust: "#11111b",
};
const logoColors = ["blue", "mauve", "teal", "pink"] as const;
const defaults: Required<Config> = {
  enabled: true,
  footerSegments: { cwd: true, gitBranch: true, gitStatus: true, runtime: true, context: true, tokens: true, cost: true, extensionStatuses: true },
  telemetry: { enabled: true, tps: true, ttft: true, duration: true, tokens: true, stalls: true, cost: true },
};

function readConfig(): Required<Config> {
  try {
    const raw = JSON.parse(readFileSync(CONFIG_FILE, "utf8")) as Config;
    return {
      enabled: raw.enabled !== false,
      footerSegments: { ...defaults.footerSegments, ...(raw.footerSegments ?? {}) },
      telemetry: { ...defaults.telemetry, ...(raw.telemetry ?? {}) },
    };
  } catch { return defaults; }
}
function hex(value: string, text: string, background = false): string {
  const match = value.match(/^#(..)(..)(..)$/);
  if (!match) return text;
  const rgb = match.map((v, i) => i ? Number.parseInt(v, 16) : 0).slice(1).join(";");
  return `\x1b[${background ? 48 : 38};2;${rgb}m${text}\x1b[0m`;
}
function fmt(n: number): string {
  if (!Number.isFinite(n)) return "—";
  if (n >= 1000) return `${(n / 1000).toFixed(n >= 10000 ? 0 : 1)}k`;
  return Math.round(n).toString();
}
function seconds(n: number): string { return n < 60 ? `${n.toFixed(1)}s` : `${Math.floor(n / 60)}m ${(n % 60).toFixed(0)}s`; }
function shortCwd(cwd: string): string {
  const shown = cwd === HOME ? "~" : cwd.startsWith(`${HOME}/`) ? `~/${relative(HOME, cwd)}` : cwd;
  const parts = shown.split("/");
  return parts.length > 4 ? `${parts.slice(0, 2).join("/")}/…/${parts.at(-1)}` : shown;
}
function gitInfo(cwd: string): { branch?: string; status?: string } {
  try {
    const branch = execFileSync("git", ["branch", "--show-current"], { cwd, encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] }).trim() || "detached";
    const porcelain = execFileSync("git", ["status", "--porcelain", "--untracked-files=no"], { cwd, encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] });
    const staged = [...porcelain].some((_, i) => i === 0 || porcelain[i - 1] === "\n" ? porcelain[i] !== " " : false);
    const modified = porcelain.trim().length > 0;
    return { branch, status: `${staged ? "●" : ""}${modified ? "✚" : ""}` };
  } catch { return {}; }
}
function runtime(cwd: string): string {
  if (existsSync(join(cwd, "package.json"))) return "󰎙 node";
  if (existsSync(join(cwd, "pyproject.toml")) || existsSync(join(cwd, "requirements.txt"))) return " python";
  if (existsSync(join(cwd, "Cargo.toml"))) return " rust";
  if (existsSync(join(cwd, "go.mod"))) return " go";
  if (existsSync(join(cwd, "mix.exs"))) return " elixir";
  return "shell";
}
function modelName(model: any): string {
  if (!model) return "no model";
  return `${model.id ?? model.name ?? "unknown"} · ${model.provider ?? "local"}`;
}
function usageFrom(value: any): { input: number; output: number; cost: number } {
  const u = value?.usage ?? value?.message?.usage ?? {};
  return { input: Number(u.input ?? u.inputTokens ?? 0), output: Number(u.output ?? u.outputTokens ?? 0), cost: Number(u.cost ?? 0) };
}
function segment(icon: string, content: string, color: string, background = palette.surface0): string {
  return `${hex(color, ``)}${hex(background, ` ${icon} ${content} `, true)}${hex(background, "")}`;
}

class RoundedEditor extends CustomEditor {
  override render(width: number): string[] {
    const lines = super.render(width);
    if (!lines.length) return lines;
    const round = (line: string, left: string, right: string) => {
      if (visibleWidth(line) < 2) return line;
      return left + line.slice(1, -1) + right;
    };
    lines[0] = round(lines[0]!, "╭", "╮");
    let bottom = -1;
    for (let index = lines.length - 1; index >= 0; index--) {
      if (lines[index]!.includes("─")) { bottom = index; break; }
    }
    if (bottom >= 0) lines[bottom] = round(lines[bottom]!, "╰", "╯");
    return lines;
  }
}

export default function (pi: ExtensionAPI) {
  const config = readConfig();
  if (!config.enabled) return;
  let ctx: any;
  let stats: Stats = { input: 0, output: 0, cost: 0 };
  let started = 0;
  let firstToken = 0;
  let lastUpdate = 0;
  let stalls = 0;
  let stallSeconds = 0;
  let frame = 0;
  let animation: ReturnType<typeof setInterval> | undefined;
  let renderTui: any;

  const refresh = () => renderTui?.requestRender();
  const statusSegments = (footerData: any, theme: any): string => {
    if (!config.footerSegments.extensionStatuses) return "";
    const statuses = footerData.getExtensionStatuses?.() as ReadonlyMap<string, string> | undefined;
    if (!statuses?.size) return "";
    return [...statuses].map(([key, value]) => segment(key, value, palette.teal)).join(" ");
  };

  pi.on("session_start", (_event, nextCtx) => {
    ctx = nextCtx;
    stats = { input: 0, output: 0, cost: 0 };
    ctx.ui.setHeader((tui: any, theme: any) => {
      renderTui = tui;
      const logo = theme.fg(logoColors[frame % logoColors.length]!, "  π  ");
      return new Text(`${logo}\n${theme.fg("dim", "  let's build something great")}`, 0, 0);
    });
    ctx.ui.setFooter((tui: any, theme: any, footerData: any) => {
      renderTui = tui;
      const render = (width: number): string[] => {
        const parts: string[] = [];
        const add = (key: string, value: string, color: string, icon: string, bg?: string) => {
          if (config.footerSegments[key] !== false) parts.push(segment(icon, value, color, bg));
        };
        if (config.footerSegments.cwd !== false) add("cwd", shortCwd(ctx.cwd), palette.sky, "");
        const git = gitInfo(ctx.cwd);
        if (config.footerSegments.gitBranch !== false && git.branch) add("gitBranch", `${git.branch}${config.footerSegments.gitStatus !== false ? ` ${git.status ?? ""}` : ""}`, palette.yellow, "", palette.crust);
        if (config.footerSegments.runtime !== false) add("runtime", runtime(ctx.cwd), palette.green, "󰘧");
        const cu = ctx.getContextUsage?.();
        if (config.footerSegments.context !== false) {
          const pct = Math.max(0, Math.min(100, cu?.percent ?? 0));
          const filled = Math.round(pct / 25);
          add("context", `${"▓".repeat(filled)}${"░".repeat(4 - filled)} ${cu?.tokens ? fmt(cu.tokens) : "—"}`, palette.teal, "󰍛");
        }
        if (config.footerSegments.model !== false) add("model", modelName(ctx.model), palette.mauve, "󰚩");
        if (config.footerSegments.tokens !== false) add("tokens", `↑${fmt(stats.input)} ↓${fmt(stats.output)}`, palette.text, "󰆡");
        if (config.footerSegments.cost !== false) add("cost", `$${stats.cost.toFixed(2)}`, palette.pink, "$ ");
        if (config.footerSegments.timer !== false) add("timer", started ? (ctx.isIdle?.() ? seconds((lastUpdate || Date.now() - started) / 1000) : seconds((Date.now() - started) / 1000)) : "idle", palette.sky, "◷");
        const statuses = statusSegments(footerData, theme);
        if (statuses) parts.push(statuses);
        return [truncateToWidth(parts.join(" "), Math.max(1, width), "…")];
      };
      return { render, invalidate: refresh, dispose() {} } as any;
    });
    ctx.ui.setEditorComponent((tui: any, theme: any, keybindings: any) => {
      renderTui = tui;
      const editor = new RoundedEditor(tui, { ...theme, borderColor: (s: string) => hex(palette.surface1, s) }, keybindings, { paddingX: 1 });
      return editor;
    });
    if (!animation) animation = setInterval(() => { frame++; refresh(); }, 900);
  });

  pi.on("agent_start", () => { started = Date.now(); firstToken = 0; lastUpdate = started; stalls = 0; stallSeconds = 0; stats = { input: 0, output: 0, cost: 0 }; refresh(); });
  pi.on("message_update", (event: any) => {
    const now = Date.now();
    if (!firstToken) firstToken = now;
    if (lastUpdate && now - lastUpdate > 4000) { stalls++; stallSeconds += (now - lastUpdate) / 1000; }
    lastUpdate = now;
    const u = usageFrom(event);
    if (u.input || u.output || u.cost) { stats.input = Math.max(stats.input, u.input); stats.output = Math.max(stats.output, u.output); stats.cost = Math.max(stats.cost, u.cost); }
    refresh();
  });
  pi.on("message_end", (event: any) => {
    const u = usageFrom(event);
    stats.input += u.input; stats.output += u.output; stats.cost += u.cost;
    refresh();
  });
  pi.on("agent_settled", () => {
    if (!config.telemetry.enabled || !started) return;
    const duration = (Date.now() - started) / 1000;
    const tps = stats.output / Math.max(0.001, duration - (firstToken ? (firstToken - started) / 1000 : 0));
    const ttft = firstToken ? (firstToken - started) / 1000 : 0;
    const cpm = stats.input + stats.output > 0 ? stats.cost / (stats.input + stats.output) * 1e6 : 0;
    const fields = [config.telemetry.tps && `TPS ${tps.toFixed(1)} tok/s`, config.telemetry.ttft && `~ TTFT ${ttft.toFixed(1)}s`, config.telemetry.duration && `+ ${duration.toFixed(1)}s`, config.telemetry.tokens && `↑ ${fmt(stats.input)} | ↓ ${fmt(stats.output)}`, config.telemetry.stalls && `! stall ${stalls}x / ${stallSeconds.toFixed(1)}s`, config.telemetry.cost && `$ $${cpm.toFixed(2)}/M`].filter(Boolean);
    ctx?.ui.notify(fields.join(" | "), "info");
    refresh();
  });
  pi.on("session_shutdown", () => { if (animation) clearInterval(animation); animation = undefined; });

  const renderSideQuest = (entry: any, _options: any, theme: any) => {
    const d = entry.data ?? {};
    const icon = d.status === "completed" ? "✓" : d.status === "failed" ? "✗" : "…";
    const output = String(d.output ?? "").split("\n").map((line: string) => `  ${line}`).join("\n");
    return new Text(`${theme.fg(d.status === "failed" ? "error" : d.status === "completed" ? "success" : "warning", `${icon} ${d.status ?? "side quest"}`)}\n${theme.fg("dim", `  ${d.task ?? ""}`)}${output ? `\n${theme.fg("text", output)}` : ""}`, 0, 0);
  };
  pi.registerEntryRenderer("side-quest", renderSideQuest);
  const renderTodo = (entry: any, _options: any, theme: any) => {
    const d = entry.data ?? entry;
    const items = Array.isArray(d.items) ? d.items : Array.isArray(d.todos) ? d.todos : [];
    const lines = items.map((item: any) => `${item.status === "completed" || item.done ? theme.fg("success", "✓") : theme.fg("warning", "○")} ${theme.fg("text", String(item.content ?? item.title ?? item.text ?? item))}`);
    return new Text(`${theme.fg("accent", "TODO")}\n${lines.length ? lines.map((line: string) => `  ${line}`).join("\n") : theme.fg("dim", "  (empty)")}`, 0, 0);
  };
  pi.registerEntryRenderer("todo", renderTodo);
  pi.registerEntryRenderer("todos", renderTodo);
}
