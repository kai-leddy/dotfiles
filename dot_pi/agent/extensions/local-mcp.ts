/**
 * Local MCP toggle.
 *
 * Servers that start a local process (npx firefox-devtools-mcp and the like) cost a few
 * hundred MB each, and Pi connects every server in mcp.json at session start, even ones
 * only reached through codemode. So they live in ~/.pi/agent/local-mcp.json instead, off
 * by default, and this extension registers them for the current session on request.
 *
 *   /local-mcp                 panel: toggle servers on/off
 *   /local-mcp status          list servers and their state
 *   /local-mcp on <name|all>
 *   /local-mcp off <name|all>
 *   /local-mcp toggle <name>
 *
 * The footer shows a greyed "<plug> MCP" when none are on and a green "<plug> MCP 2" (the count) otherwise.
 *
 * Nothing is written to mcp.json: registrations last for the session. They survive
 * /reload (remembered in a session entry) but not a new, resumed or forked session.
 *
 * local-mcp.json has the same shape as mcp.json:
 *   { "mcpServers": { "name": { "command": "npx", "args": [...], "description": "..." } } }
 * It is re-read on every command, so edits need no reload. A server with the same name
 * in mcp.json would take precedence over the registration, so keep the names distinct.
 */

import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import path from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { getSettingsListTheme } from "@earendil-works/pi-coding-agent";
import { Container, type SettingItem, SettingsList } from "@earendil-works/pi-tui";

const CONFIG_PATH = path.join(homedir(), ".pi", "agent", "local-mcp.json");
const STATUS_KEY = "local-mcp";
const ICON = "\uf1e6"; // plug, the same glyph kai-ui uses for mcp__ tool calls
const ENTRY_TYPE = "local-mcp-state";

type ServerConfig = Record<string, unknown>;

interface Loaded {
	servers: Record<string, ServerConfig>;
	error?: string;
}

function loadServers(): Loaded {
	if (!existsSync(CONFIG_PATH)) return { servers: {}, error: `${CONFIG_PATH} not found` };
	try {
		const parsed = JSON.parse(readFileSync(CONFIG_PATH, "utf8"));
		const servers = parsed?.mcpServers;
		if (!servers || typeof servers !== "object") return { servers: {}, error: "no mcpServers object in local-mcp.json" };
		return { servers };
	} catch (error) {
		return { servers: {}, error: `could not read local-mcp.json: ${(error as Error).message}` };
	}
}

// registerMcpServer is in Pi's runtime API; older type packages may not declare it yet.
type McpApi = ExtensionAPI & {
	registerMcpServer(name: string, config: ServerConfig): void;
	unregisterMcpServer(name: string): void;
};

export default function localMcp(api: ExtensionAPI) {
	const pi = api as McpApi;
	const active = new Set<string>();

	function renderStatus(ctx: ExtensionContext) {
		if (!ctx.hasUI) return;
		const { servers } = loadServers();
		if (Object.keys(servers).length === 0 && active.size === 0) {
			ctx.ui.setStatus(STATUS_KEY, undefined);
			return;
		}
		const theme = ctx.ui.theme;
		ctx.ui.setStatus(
			STATUS_KEY,
			active.size > 0 ? theme.fg("success", `${ICON} MCP ${active.size}`) : theme.fg("dim", `${ICON} MCP`),
		);
	}

	function persist() {
		pi.appendEntry(ENTRY_TYPE, { active: [...active] });
	}

	/** Returns an error message, or undefined on success. */
	function enable(name: string): string | undefined {
		if (active.has(name)) return undefined;
		const config = loadServers().servers[name];
		if (!config) return `unknown server "${name}"`;
		const { enabled: _enabled, ...rest } = config;
		try {
			pi.registerMcpServer(name, { exposure: "codemode", ...rest });
		} catch (error) {
			return `could not start "${name}": ${(error as Error).message}`;
		}
		active.add(name);
		return undefined;
	}

	function disable(name: string): string | undefined {
		if (!active.has(name)) return undefined;
		try {
			pi.unregisterMcpServer(name);
		} catch (error) {
			return `could not stop "${name}": ${(error as Error).message}`;
		}
		active.delete(name);
		return undefined;
	}

	function apply(ctx: ExtensionContext, names: string[], on: boolean) {
		const changed: string[] = [];
		for (const name of names) {
			const wasOn = active.has(name);
			const error = on ? enable(name) : disable(name);
			if (error) ctx.ui.notify(error, "error");
			else if (wasOn !== on) changed.push(name);
		}
		if (changed.length > 0) {
			persist();
			ctx.ui.notify(
				on
					? `MCP on: ${changed.join(", ")}. It connects in the background and codemode finds it with searchTools().`
					: `MCP off: ${changed.join(", ")}`,
				"info",
			);
		}
		renderStatus(ctx);
	}

	function describeAll(): string {
		const { servers, error } = loadServers();
		const names = Object.keys(servers);
		if (names.length === 0) return error ?? "no servers in local-mcp.json";
		return names.map((name) => `${active.has(name) ? "●" : "○"} ${name}${active.has(name) ? " (on)" : ""}`).join("\n");
	}

	async function openPanel(ctx: ExtensionContext) {
		const { servers, error } = loadServers();
		const names = Object.keys(servers);
		if (names.length === 0) {
			ctx.ui.notify(error ?? "no servers in local-mcp.json", "warning");
			return;
		}
		await ctx.ui.custom((tui, theme, _kb, done) => {
			const items: SettingItem[] = names.map((name) => ({
				id: name,
				label: name,
				description: typeof servers[name]?.description === "string" ? (servers[name]!.description as string) : undefined,
				currentValue: active.has(name) ? "on" : "off",
				values: ["on", "off"],
			}));
			const container = new Container();
			container.addChild({
				render: () => [theme.fg("accent", theme.bold("Local MCP servers (this session)")), ""],
				invalidate() {},
			});
			const list = new SettingsList(
				items,
				Math.min(items.length + 2, 12),
				getSettingsListTheme(),
				(id, value) => apply(ctx, [id], value === "on"),
				() => done(undefined),
			);
			container.addChild(list);
			return {
				capturesViewportInput: (list as { capturesViewportInput?: boolean }).capturesViewportInput,
				render: (width: number) => container.render(width),
				invalidate: () => container.invalidate(),
				handleInput: (data: string) => {
					list.handleInput?.(data);
					tui.requestRender();
				},
			};
		});
	}

	pi.registerCommand("local-mcp", {
		description: "Toggle local MCP servers on or off for this session",
		getArgumentCompletions: (prefix: string) => {
			const words = prefix.split(/\s+/);
			const subcommands = ["status", "on", "off", "toggle"];
			if (words.length <= 1) {
				const items = subcommands.filter((s) => s.startsWith(words[0] ?? "")).map((s) => ({ value: s, label: s }));
				return items.length > 0 ? items : null;
			}
			if (!["on", "off", "toggle"].includes(words[0]!)) return null;
			const last = words[words.length - 1] ?? "";
			const candidates = [...Object.keys(loadServers().servers), ...(words[0] === "toggle" ? [] : ["all"])];
			const items = candidates
				.filter((n) => n.startsWith(last))
				.map((n) => ({ value: `${words.slice(0, -1).join(" ")} ${n}`, label: n }));
			return items.length > 0 ? items : null;
		},
		handler: async (args, ctx) => {
			const [command, ...targets] = args.trim().split(/\s+/).filter(Boolean);
			if (!command) {
				if (ctx.mode === "tui") await openPanel(ctx);
				else ctx.ui.notify(describeAll(), "info");
				return;
			}
			if (command === "status") {
				ctx.ui.notify(describeAll(), "info");
				return;
			}
			if (!["on", "off", "toggle"].includes(command)) {
				ctx.ui.notify("Usage: /local-mcp [status | on <name|all> | off <name|all> | toggle <name>]", "warning");
				return;
			}
			const known = Object.keys(loadServers().servers);
			const names = targets.includes("all") ? (command === "off" ? [...active] : known) : targets;
			if (names.length === 0) {
				ctx.ui.notify(`Usage: /local-mcp ${command} <name|all>. Known: ${known.join(", ") || "none"}`, "warning");
				return;
			}
			if (command === "toggle") for (const name of names) apply(ctx, [name], !active.has(name));
			else apply(ctx, names, command === "on");
		},
	});

	pi.on("session_start", async (event, ctx) => {
		// Registrations don't outlive the runtime. On /reload put back what was on; for a
		// new, resumed or forked session start with everything off.
		active.clear();
		if (event.reason === "reload") {
			let saved: string[] = [];
			for (const entry of ctx.sessionManager.getBranch()) {
				if (entry.type === "custom" && entry.customType === ENTRY_TYPE) {
					saved = (entry.data as { active?: string[] } | undefined)?.active ?? [];
				}
			}
			for (const name of saved) {
				const error = enable(name);
				if (error) ctx.ui.notify(error, "warning");
			}
		}
		renderStatus(ctx);
	});
}
