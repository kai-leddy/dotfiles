/**
 * LSP reaper.
 *
 * @watercol/pi-lens-simple starts language servers (gopls, pyright, ...) on first use and
 * only stops them when the session ends, so in a long-running session they sit there
 * holding hundreds of MB each (its 240 s idle reset isn't wired up in Pi). This stops the
 * ones that have been idle for 10 minutes. pi-lens starts a server again on next use, at
 * the cost of one cold start.
 *
 * "Activity" is any lsp_* tool call and any write or edit (pi-lens checks diagnostics
 * after those). A server is stopped once nothing has been active for the idle time and
 * the server itself has been seen for that long, so one that was just started is left alone.
 *
 * A language server is a descendant of this Pi process whose executable is a known server
 * name (or looks like "*-language-server" / "*langserver") and that has no shell between it
 * and Pi, so commands you run through the bash tool are never touched. Its whole process
 * tree goes with it.
 *
 *   /lsp-reaper           show the servers it can see and how long until each is stopped
 *   /lsp-reaper now       stop them immediately
 *
 * Each time it stops servers it adds a card to the chat (a custom entry, so it stays in the
 * session history and is not sent to the model), not just a toast.
 *
 * Env: PI_LSP_REAPER_IDLE_SECONDS (default 600).
 */

import { execFile } from "node:child_process";
import path from "node:path";
import { promisify } from "node:util";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Box, Text } from "@earendil-works/pi-tui";

const run = promisify(execFile);

const idleSeconds = Number(process.env.PI_LSP_REAPER_IDLE_SECONDS);
const IDLE_MS = (Number.isFinite(idleSeconds) && idleSeconds > 0 ? idleSeconds : 600) * 1000;
const CHECK_MS = Math.min(30_000, Math.max(1000, IDLE_MS / 4));

/** Executables that are language servers whatever their arguments. */
const SERVERS = new Set([
	"gopls",
	"rust-analyzer",
	"clangd",
	"jdtls",
	"vtsls",
	"tsserver",
	"typescript-language-server",
	"pyright-langserver",
	"basedpyright-langserver",
	"pylsp",
	"jedi-language-server",
	"lua-language-server",
	"marksman",
	"taplo",
	"zls",
	"solargraph",
	"terraform-ls",
	"sourcekit-lsp",
	"elixir-ls",
	"nixd",
	"nil",
	"svelteserver",
	"intelephense",
]);
/** Tools that are only language servers when started in server mode. */
const AMBIGUOUS = new Set(["ruff", "ty", "biome", "dart", "ols"]);
const SERVER_MODE = /(^|\s)(server|lsp|--stdio|language-server)(\s|$)/;
const LOOKS_LIKE_SERVER = /(language[-_]?server|langserver)/;
const SHELLS = new Set(["bash", "sh", "zsh", "fish", "dash", "ksh"]);
const INTERPRETERS = new Set(["node", "bun", "deno", "python", "python3"]);

interface Proc {
	pid: number;
	ppid: number;
	rssKb: number;
	command: string;
}

interface Server {
	pid: number;
	name: string;
	tree: number[];
	rssKb: number;
}

async function listProcesses(): Promise<Map<number, Proc>> {
	const { stdout } = await run("ps", ["-Ao", "pid=,ppid=,rss=,command="], { maxBuffer: 16 * 1024 * 1024 });
	const procs = new Map<number, Proc>();
	for (const line of stdout.split("\n")) {
		const m = line.match(/^\s*(\d+)\s+(\d+)\s+(\d+)\s+(.*)$/);
		if (m) procs.set(Number(m[1]), { pid: Number(m[1]), ppid: Number(m[2]), rssKb: Number(m[3]), command: m[4]! });
	}
	return procs;
}

/** The executable a process really runs: pi-spawn's wrapper and interpreters are looked through. */
function executableOf(command: string): string {
	const tokens = command.trim().split(/\s+/);
	let exe = tokens[0] ?? "";
	let rest = tokens.slice(1);
	if (path.basename(exe) === "pi-spawn") {
		// pi-spawn <n> <n> <exe> <argv0> args...
		exe = tokens[3] ?? "";
		rest = tokens.slice(5);
	}
	let name = path.basename(exe);
	if (INTERPRETERS.has(name)) {
		const script = rest.find((t) => !t.startsWith("-"));
		if (script) name = path.basename(script);
	}
	return name.replace(/\.(c|m)?js$|\.py$/, "");
}

function isServer(command: string): string | undefined {
	const name = executableOf(command);
	if (SERVERS.has(name) || LOOKS_LIKE_SERVER.test(name)) return name;
	if (AMBIGUOUS.has(name) && SERVER_MODE.test(command)) return name;
	return undefined;
}

async function findServers(): Promise<Server[]> {
	const procs = await listProcesses();
	const children = new Map<number, number[]>();
	for (const p of procs.values()) children.set(p.ppid, [...(children.get(p.ppid) ?? []), p.pid]);

	// Descendants of this process, remembering whether a shell sits on the way down.
	const found: { proc: Proc; name: string; underShell: boolean }[] = [];
	const visit = (pid: number, underShell: boolean, matchedAbove: boolean) => {
		for (const childPid of children.get(pid) ?? []) {
			const proc = procs.get(childPid);
			if (!proc) continue;
			const name = matchedAbove ? undefined : isServer(proc.command);
			const shell = SHELLS.has(executableOf(proc.command));
			if (name && !underShell) found.push({ proc, name, underShell });
			visit(childPid, underShell || shell, matchedAbove || (!!name && !underShell));
		}
	};
	visit(process.pid, false, false);

	return found.map(({ proc, name }) => {
		const tree: number[] = [];
		const collect = (pid: number) => {
			tree.push(pid);
			for (const c of children.get(pid) ?? []) collect(c);
		};
		collect(proc.pid);
		return { pid: proc.pid, name, tree, rssKb: tree.reduce((sum, pid) => sum + (procs.get(pid)?.rssKb ?? 0), 0) };
	});
}

const alive = (pid: number) => {
	try {
		process.kill(pid, 0);
		return true;
	} catch {
		return false;
	}
};

async function stop(server: Server) {
	// Leaves first, so a parent can't respawn a child we just killed.
	for (const pid of [...server.tree].reverse()) {
		try {
			process.kill(pid, "SIGTERM");
		} catch {}
	}
	await new Promise((resolve) => setTimeout(resolve, 2000));
	for (const pid of server.tree) {
		if (alive(pid)) {
			try {
				process.kill(pid, "SIGKILL");
			} catch {}
		}
	}
}

const mb = (kb: number) => Math.round(kb / 1024);
const minutes = (ms: number) => (ms >= 60_000 ? `${Math.round(ms / 60_000)} min` : `${Math.round(ms / 1000)} s`);

const ENTRY_TYPE = "lsp-reaper";

interface ReapedEntry {
	why: string;
	timestamp: number;
	servers: { name: string; pid: number; mb: number }[];
}

// registerEntryRenderer is in Pi's runtime API; older type packages may not declare it yet.
type EntryApi = ExtensionAPI & {
	registerEntryRenderer<T>(
		customType: string,
		renderer: (
			entry: { data?: T },
			options: { expanded: boolean },
			theme: { fg(color: string, text: string): string; bg(color: string, text: string): string },
		) => unknown,
	): void;
};

export default function lspReaper(api: ExtensionAPI) {
	const pi = api as EntryApi;
	pi.registerEntryRenderer<ReapedEntry>(ENTRY_TYPE, (entry, { expanded }, theme) => {
		const data = entry.data;
		const box = new Box(1, 1, (text: string) => theme.bg("customMessageBg", text));
		if (!data) return box;
		const total = data.servers.reduce((sum, s) => sum + s.mb, 0);
		const count = data.servers.length;
		const names = data.servers.map((s) => s.name).join(", ");
		box.addChild(
			new Text(
				`${theme.fg("accent", "[lsp-reaper]")} Stopped ${count} language server${count === 1 ? "" : "s"} (${names}), about ${total} MB, ${data.why}. They start again on next use.`,
				0,
				0,
			),
		);
		if (expanded) {
			for (const s of data.servers) box.addChild(new Text(theme.fg("dim", `  ${s.name}  pid ${s.pid}  ${s.mb} MB`), 0, 0));
			box.addChild(new Text(theme.fg("dim", `  at ${new Date(data.timestamp).toLocaleTimeString()}`), 0, 0));
		}
		return box;
	});

	let lastActivity = Date.now();
	const firstSeen = new Map<number, number>();
	let timer: ReturnType<typeof setInterval> | undefined;
	let reaping = false;
	let latestCtx: ExtensionContext | undefined;

	const touch = (toolName: string) => {
		if (toolName.startsWith("lsp_") || toolName === "write" || toolName === "edit") lastActivity = Date.now();
	};

	/** Stop servers that have been idle long enough (all of them when `force`). Returns what was stopped. */
	async function reap(force: boolean): Promise<Server[]> {
		if (reaping) return [];
		reaping = true;
		try {
			const servers = await findServers();
			const now = Date.now();
			const current = new Set(servers.map((s) => s.pid));
			for (const pid of [...firstSeen.keys()]) if (!current.has(pid)) firstSeen.delete(pid);
			for (const s of servers) if (!firstSeen.has(s.pid)) firstSeen.set(s.pid, now);

			const due = servers.filter((s) => force || now - Math.max(lastActivity, firstSeen.get(s.pid)!) >= IDLE_MS);
			await Promise.all(due.map(stop));
			for (const s of due) firstSeen.delete(s.pid);
			return due;
		} catch {
			return [];
		} finally {
			reaping = false;
		}
	}

	/** Put a card in the chat history; fall back to a toast if the entry can't be written. */
	function notifyReaped(ctx: ExtensionContext | undefined, reaped: Server[], why: string) {
		if (reaped.length === 0) return;
		const entry: ReapedEntry = {
			why,
			timestamp: Date.now(),
			servers: reaped.map((s) => ({ name: s.name, pid: s.pid, mb: mb(s.rssKb) })),
		};
		try {
			pi.appendEntry(ENTRY_TYPE, entry);
		} catch {
			if (!ctx?.hasUI) return;
			const freed = entry.servers.reduce((sum, s) => sum + s.mb, 0);
			try {
				ctx.ui.notify(`Stopped ${reaped.length} language server(s) (${entry.servers.map((s) => s.name).join(", ")}), about ${freed} MB, ${why}.`, "info");
			} catch {}
		}
	}

	pi.on("session_start", async (_event, ctx) => {
		latestCtx = ctx;
		lastActivity = Date.now();
		firstSeen.clear();
		if (timer) clearInterval(timer);
		timer = setInterval(async () => {
			notifyReaped(latestCtx, await reap(false), `idle for ${minutes(IDLE_MS)}`);
		}, CHECK_MS);
		timer.unref?.();
	});

	pi.on("tool_call", async (event) => touch(event.toolName));
	pi.on("tool_result", async (event) => touch(event.toolName));

	pi.on("session_shutdown", async () => {
		if (timer) clearInterval(timer);
		timer = undefined;
	});

	pi.registerCommand("lsp-reaper", {
		description: "Show or stop idle language servers (/lsp-reaper [now])",
		getArgumentCompletions: (prefix: string) => ("now".startsWith(prefix) ? [{ value: "now", label: "now" }] : null),
		handler: async (args, ctx) => {
			latestCtx = ctx;
			if (args.trim() === "now") {
				const reaped = await reap(true);
				if (reaped.length === 0) ctx.ui.notify("No language servers running.", "info");
				else notifyReaped(ctx, reaped, "on request");
				return;
			}
			const servers = await findServers();
			if (servers.length === 0) {
				ctx.ui.notify(`No language servers running. Idle time is ${minutes(IDLE_MS)}.`, "info");
				return;
			}
			const now = Date.now();
			const lines = servers.map((s) => {
				const left = IDLE_MS - (now - Math.max(lastActivity, firstSeen.get(s.pid) ?? now));
				return `${s.name} (pid ${s.pid}, ${mb(s.rssKb)} MB): stops in ${left > 0 ? minutes(left) : "under a minute"} unless used`;
			});
			ctx.ui.notify(lines.join("\n"), "info");
		},
	});
}
