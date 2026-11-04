/**
 * Tool cards. Every call sits on Pi's coloured card (pending, success or
 * error background) and starts with the same header line:
 *
 *    read ~/src/app/index.ts:1-80  80 lines  12ms
 *    bash npm test  exit 1  3.1s
 *   󰯁 codemode  3 calls  1.3s
 *
 * Built-in tools show nothing else until expanded. codemode adds its script
 * (the first lines, all of them when expanded) and its nested calls in the
 * same style, plus the script's output when it failed or is expanded.
 *
 * Expand with Ctrl+O, or a click. Only the drawing changes; the tools
 * themselves are untouched.
 */

import { highlightCode, type ExtensionAPI, type Theme, type ToolRenderers } from "@earendil-works/pi-coding-agent";
import { type Component, Box, Container, Spacer, Text, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { formatDuration, shortenPath } from "./format.ts";
import { icons } from "./icons.ts";
import { type CatppuccinColor, paint } from "./palette.ts";

type Args = Record<string, unknown>;
/** The context Pi passes to tool renderers (the type isn't exported by name). */
type ToolRenderContext = Parameters<NonNullable<ToolRenderers["renderCall"]>>[2];

interface ToolStyle {
	/** Nerd Font glyph. */
	icon: string;
	color: CatppuccinColor;
	/** What the call is about: a path, a command, a pattern. */
	summary(args: Args): string;
	/** What came back, for a successful call. */
	outcome?(text: string, details: unknown, args: Args): string;
}

const TOOLS: Record<string, ToolStyle> = {
	read: {
		icon: "\uf0f6",
		color: "blue",
		summary: (args) => path(args) + lineRange(args),
		outcome: (text) => count(countLines(text), "line"),
	},
	bash: {
		icon: "\uf120",
		color: "peach",
		summary: (args) => String(args.command ?? "").split("\n")[0]!,
		outcome: (text) => (countLines(text) > 0 ? count(countLines(text), "line") : "no output"),
	},
	edit: {
		icon: "\uf040",
		color: "yellow",
		summary: path,
		outcome: (_text, details) => diffStat(details),
	},
	write: {
		icon: "\uf0c7",
		color: "green",
		summary: path,
		outcome: (_text, _details, args) => count(countLines(String(args.content ?? "")), "line"),
	},
	grep: {
		icon: "\uf002",
		color: "teal",
		summary: (args) => `/${args.pattern ?? ""}/ in ${path(args)}${args.glob ? ` (${args.glob})` : ""}`,
		outcome: (text) => countResults(text, "match", "matches"),
	},
	find: {
		icon: "\uf0c5",
		color: "sky",
		summary: (args) => `${args.pattern ?? ""} in ${path(args)}`,
		outcome: (text) => countResults(text, "file"),
	},
	ls: {
		icon: "\uf03a",
		color: "sapphire",
		summary: path,
		outcome: (text) => countResults(text, "entry", "entries"),
	},
};

const CODEMODE: ToolStyle = { icon: "\u{f0bc1}", color: "mauve", summary: () => "" };

/** The first string argument: a good enough summary for tools we know nothing else about. */
const firstString = (args: Args) => String(Object.values(args).find((value) => typeof value === "string") ?? "");

/** Icons for other tools that show up as nested codemode calls, by name prefix; the first match wins. */
const OTHER_TOOLS: Array<[prefix: string, icon: string, color: CatppuccinColor]> = [
	["todo", "\uf0ae", "green"],
	["ask_user_question", "\uf059", "yellow"],
	["subagent", "\uf0c0", "pink"],
	["get_subagent_result", "\uf0c0", "pink"],
	["steer_subagent", "\uf0c0", "pink"],
	["mnemosyne_", "\u{f035b}", "mauve"],
	["recall", "\uf1da", "mauve"],
	["ctx7_", "\uf02d", "blue"],
	["lsp_", "\uf121", "sapphire"],
	["ast_grep_", "\u{f0645}", "teal"],
	["mcp__exa__", "\uf0ac", "sky"],
	["mcp__firefox_devtools__", "\uf269", "peach"],
	["mcp__zen_devtools__", "\uf269", "peach"],
	["mcp__", "\uf1e6", "subtext"],
];

function styleFor(name: string): ToolStyle {
	if (Object.hasOwn(TOOLS, name)) return TOOLS[name]!;
	const [, icon, color] = OTHER_TOOLS.find(([prefix]) => name.startsWith(prefix)) ?? ["", icons.tool, "subtext"];
	return { icon, color, summary: firstString };
}

/** Lines of a codemode script a collapsed card shows. */
const SCRIPT_LINES_SHOWN = 10;
/** How many nested codemode calls a collapsed card lists: the latest ones. */
const NESTED_CALLS_SHOWN = 8;
/** Lines of a failed script's output a collapsed card shows. */
const ERROR_LINES_SHOWN = 5;
/** The header codemode puts before a script's output. */
const SCRIPT_HEADER = /^Script (completed|failed)\nWall time [\d.]+ seconds\nOutput:\n$/;

export function registerToolCards(pi: ExtensionAPI, isEnabled: () => boolean): void {
	// Pi asks once per tool row. `next()` is what Pi would draw without us.
	pi.registerToolRenderer((toolName, next) => {
		const native = next();
		if (!native || !isEnabled()) return native;
		if (toolName === "codemode" && native.renderShell !== "self") return codemodeRenderers();
		return Object.hasOwn(TOOLS, toolName) ? builtInRenderers(toolName, TOOLS[toolName]!, native) : native;
	});
}

/**
 * Per-row state, in the row's shared renderer state under our own key. Pi
 * hands renderers the component they returned last time; we keep Pi's own
 * renderers' components here so each gets its own back.
 */
interface RowState {
	header?: Row;
	nativeCall?: Component;
	nativeResult?: Component;
}

function rowState(context: ToolRenderContext): RowState {
	context.state.kaiUi ??= {};
	return context.state.kaiUi;
}

// --- Built-in tools ---------------------------------------------------------

function builtInRenderers(name: string, style: ToolStyle, native: ToolRenderers): ToolRenderers {
	// Pi draws the card around most tools. edit draws its own, so we draw one
	// for it when collapsed and leave it to Pi when expanded.
	const drawsOwnCard = native.renderShell === "self";
	return {
		renderShell: native.renderShell,

		renderCall(args, theme, context) {
			const state = rowState(context);
			if (context.expanded && drawsOwnCard) {
				state.nativeCall = native.renderCall?.(args, theme, { ...context, lastComponent: state.nativeCall });
				return state.nativeCall ?? new Container();
			}
			state.header ??= new Row();
			state.header.parts = describeCall(theme, name, style, args as Args, { durationMs: context.durationMs });
			return drawsOwnCard ? card(theme, context, state.header) : state.header;
		},

		renderResult(result, options, theme, context) {
			const state = rowState(context);
			const text = textOf(result.content);
			// Fold the outcome into the header line rather than adding one.
			const args = context.args as Args;
			state.header ??= new Row();
			state.header.parts = describeCall(theme, name, style, args, {
				durationMs: context.durationMs,
				outcome: options.isPartial ? undefined : context.isError ? errorSummary(text) : style.outcome?.(text, result.details, args),
				failed: context.isError,
			});
			if (!options.expanded) return new Container();

			// Expanded: Pi's own output under our header.
			state.nativeResult = native.renderResult?.(result, options, theme, { ...context, lastComponent: state.nativeResult });
			const output = state.nativeResult ?? new Text(theme.fg("toolOutput", text), 0, 0);
			return drawsOwnCard ? output : stack(new Spacer(1), output);
		},
	};
}

/** Pi's tool card, for a tool that draws its own. */
function card(theme: Theme, context: ToolRenderContext, child: Component): Box {
	const bg = context.isPartial ? "toolPendingBg" : context.isError ? "toolErrorBg" : "toolSuccessBg";
	const box = new Box(context.outputPad, 1, (text) => theme.bg(bg, text));
	box.addChild(child);
	return box;
}

// --- codemode ---------------------------------------------------------------

/** A tool call made by a codemode script, as codemode records it in its result details. */
interface NestedCall {
	name: string;
	/** The arguments as JSON. */
	args: string;
	status: "running" | "ok" | "error" | "cancelled";
	durationMs?: number;
	error?: string;
}

function codemodeRenderers(): ToolRenderers {
	return {
		renderShell: "default",

		renderCall(args, theme, context) {
			const state = rowState(context);
			// Pi calls renderResult right after this, which adds the outcome and duration.
			state.header ??= new Row();
			state.header.parts = describeCall(theme, "codemode", CODEMODE, {}, {});
			const script = String((args as Args).code ?? "").replace(/\r/g, "").replace(/\t/g, "  ").trimEnd();
			return stack(state.header, new Spacer(1), scriptPreview(theme, script, context));
		},

		renderResult(result, options, theme, context) {
			const state = rowState(context);
			const calls = (result.details as { calls?: NestedCall[] } | undefined)?.calls ?? [];
			const output = scriptOutput(result.content);
			const failed = context.isError && !options.isPartial;

			state.header ??= new Row();
			state.header.parts = describeCall(theme, "codemode", CODEMODE, {}, {
				durationMs: context.durationMs,
				outcome: failed ? (output.split("\n")[0] ?? "failed") : calls.length > 0 ? count(calls.length, "call") : undefined,
				failed,
			});

			const body = new Container();
			if (calls.length > 0) {
				body.addChild(new Spacer(1));
				const shown = options.expanded ? calls : calls.slice(-NESTED_CALLS_SHOWN);
				if (shown.length < calls.length) {
					body.addChild(new Text(paint(theme, "subtext", `${icons.running} ${calls.length - shown.length} earlier calls`), 0, 0));
				}
				for (const call of shown) body.addChild(nestedCallRow(theme, call, options.expanded));
			}

			if (output && (options.expanded || failed)) {
				const lines = options.expanded ? output.split("\n") : output.split("\n").slice(0, ERROR_LINES_SHOWN);
				body.addChild(new Spacer(1));
				body.addChild(new Text(lines.map((line) => paint(theme, failed ? "red" : "text", line)).join("\n"), 0, 0));
			}
			return body;
		},
	};
}

/** The script, syntax-highlighted; only its first lines while collapsed. */
function scriptPreview(theme: Theme, script: string, context: ToolRenderContext): Component {
	const lines = highlightCode(script, "javascript");
	if (context.expanded || lines.length <= SCRIPT_LINES_SHOWN) return new Text(lines.join("\n"), 0, 0);
	const hint = paint(theme, "subtext", `${icons.running} ${lines.length - SCRIPT_LINES_SHOWN} more lines, ctrl+o to expand`);
	return new Text([...lines.slice(0, SCRIPT_LINES_SHOWN), hint].join("\n"), 0, 0);
}

/** The script's own output, without codemode's "Script completed / Wall time / Output:" header. */
function scriptOutput(content: ReadonlyArray<{ type: string; text?: string }>): string {
	const [first, ...rest] = content;
	const hasHeader = first?.type === "text" && SCRIPT_HEADER.test(first.text ?? "");
	return textOf(hasHeader ? rest : content).trim();
}

function nestedCallRow(theme: Theme, call: NestedCall, expanded: boolean): Component {
	const failed = call.status === "error";
	const row = new Row();
	row.parts = describeCall(theme, call.name, styleFor(call.name), parseArgs(call.args), {
		durationMs: call.durationMs,
		outcome: failed && call.error ? errorSummary(call.error) : undefined,
		failed,
		status: call.status,
	});
	if (!expanded || !failed || !call.error) return row;
	const error = call.error
		.split("\n")
		.filter((line) => line.trim() !== "")
		.map((line) => `    ${paint(theme, "red", line)}`);
	return stack(row, new Text(error.join("\n"), 0, 0));
}

function parseArgs(json: string): Args {
	try {
		const args: unknown = JSON.parse(json);
		return typeof args === "object" && args !== null ? (args as Args) : {};
	} catch {
		return {};
	}
}

// --- Rows -------------------------------------------------------------------

/** A line in three parts: head ` read `, summary `~/src/app.ts`, meta `  80 lines  12ms`. */
interface RowParts {
	head: string;
	summary: string;
	meta: string;
}

interface CallInfo {
	durationMs?: number;
	/** What came back, or the error when `failed`. */
	outcome?: string;
	failed?: boolean;
	/** Nested calls show their status as an icon; cards show it as their background. */
	status?: NestedCall["status"];
}

function describeCall(theme: Theme, name: string, style: ToolStyle, args: Args, info: CallInfo): RowParts {
	const nested = info.status !== undefined;
	const label = paint(theme, style.color, `${style.icon} ${nested ? name : theme.bold(name)}`);
	const meta = [
		info.outcome && paint(theme, info.failed ? "red" : "subtext", info.outcome),
		info.durationMs !== undefined && paint(theme, "overlay", formatDuration(info.durationMs)),
	].filter(Boolean);

	const dot = paint(theme, "overlay", ` ${icons.dot} `);
	return {
		head: `${nested ? `  ${statusIcon(theme, info.status!)} ` : ""}${label} `,
		summary: style.summary(args),
		meta: meta.map((part) => dot + part).join(""),
	};
}

function statusIcon(theme: Theme, status: NestedCall["status"]): string {
	switch (status) {
		case "running":
			return paint(theme, "yellow", icons.running);
		case "ok":
			return paint(theme, "green", icons.ok);
		case "error":
			return paint(theme, "red", icons.failed);
		case "cancelled":
			return paint(theme, "subtext", icons.cancelled);
	}
}

/** One line that never wraps: a long summary is shortened so the outcome stays visible. */
class Row implements Component {
	parts: RowParts = { head: "", summary: "", meta: "" };

	render(width: number): string[] {
		const { head, summary, meta } = this.parts;
		if (!summary) return [truncateToWidth(head.trimEnd() + meta, width)];
		const room = width - visibleWidth(head + meta);
		const line = room >= 10 ? head + truncateToWidth(summary, room) + meta : head + summary + meta;
		return [truncateToWidth(line, width)];
	}

	invalidate(): void {}
}

function stack(...children: Component[]): Container {
	const container = new Container();
	for (const child of children) container.addChild(child);
	return container;
}

// --- Summaries --------------------------------------------------------------

function textOf(content: ReadonlyArray<{ type: string; text?: string }>): string {
	return content.map((part) => (part.type === "text" ? (part.text ?? "") : "")).join("\n");
}

function path(args: Args): string {
	return shortenPath(String(args.path ?? "."));
}

/** `:40` for an offset, `:40-59` for an offset and a limit. */
function lineRange(args: Args): string {
	const offset = typeof args.offset === "number" ? args.offset : undefined;
	const limit = typeof args.limit === "number" ? args.limit : undefined;
	if (limit !== undefined) return `:${offset ?? 1}-${(offset ?? 1) + limit - 1}`;
	return offset !== undefined ? `:${offset}` : "";
}

function count(n: number, singular: string, plural = `${singular}s`): string {
	return `${n} ${n === 1 ? singular : plural}`;
}

function countLines(text: string): number {
	return text.split("\n").filter((line) => line.trim() !== "").length;
}

/** Count result lines, skipping Pi's `[...]` notices; "none" for "No matches found" and the like. */
function countResults(text: string, singular: string, plural?: string): string {
	const lines = text.split("\n").filter((line) => line.trim() !== "" && !line.startsWith("["));
	if (lines.length === 0 || /^(No |\(empty)/.test(lines[0]!)) return "none";
	return count(lines.length, singular, plural);
}

/** `+3 -1` from the edit tool's diff. */
function diffStat(details: unknown): string {
	const diff = (details as { diff?: unknown } | undefined)?.diff;
	if (typeof diff !== "string") return "applied";
	const lines = diff.split("\n");
	const added = lines.filter((line) => line.startsWith("+") && !line.startsWith("+++")).length;
	const removed = lines.filter((line) => line.startsWith("-") && !line.startsWith("---")).length;
	return `+${added} -${removed}`;
}

/** `exit 2` for a failed command, otherwise the first line of the error. */
function errorSummary(text: string): string {
	const exitCode = text.match(/exited with code (\d+)/)?.[1];
	if (exitCode) return `exit ${exitCode}`;
	return text.split("\n").find((line) => line.trim() !== "") ?? "failed";
}
