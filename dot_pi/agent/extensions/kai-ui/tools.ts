/**
 * Compact tool rows for Pi's built-in tools.
 *
 * Collapsed (the default), each call is one line:
 *
 *   ✓  read ~/src/app/index.ts:1-80 · 80 lines · 12ms
 *   ✗  bash npm test · exit 1 · 3.1s
 *
 * Expanded (Ctrl+O, or a click), Pi's own renderers draw the full output.
 * Only the drawing changes; the tools themselves are untouched.
 */

import type { ExtensionAPI, Theme, ToolRenderers } from "@earendil-works/pi-coding-agent";
import { Box, type Component, Container, Spacer, Text, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { formatDuration, shortenPath } from "./format.ts";
import { type CatppuccinColor, paint } from "./palette.ts";

type Args = Record<string, unknown>;
/** The context Pi passes to tool renderers (the type isn't exported by name). */
type ToolRenderContext = Parameters<NonNullable<ToolRenderers["renderCall"]>>[2];

interface Outcome {
	text: string;
	details: unknown;
}

interface ToolStyle {
	/** Nerd Font glyph. */
	icon: string;
	color: CatppuccinColor;
	/** What the call is about: a path, a command, a pattern. */
	summary(args: Args): string;
	/** What came back, for a successful call. */
	outcome(result: Outcome, args: Args): string;
}

const TOOLS: Record<string, ToolStyle> = {
	read: {
		icon: "\uf0f6",
		color: "blue",
		summary: (args) => path(args) + lineRange(args),
		outcome: ({ text }) => count(countLines(text), "line"),
	},
	bash: {
		icon: "\uf120",
		color: "peach",
		summary: (args) => String(args.command ?? "").split("\n")[0]!,
		outcome: ({ text }) => (countLines(text) > 0 ? count(countLines(text), "line") : "no output"),
	},
	edit: {
		icon: "\uf040",
		color: "yellow",
		summary: path,
		outcome: ({ details }) => diffStat(details),
	},
	write: {
		icon: "\uf0c7",
		color: "green",
		summary: path,
		outcome: (_result, args) => count(countLines(String(args.content ?? "")), "line"),
	},
	grep: {
		icon: "\uf002",
		color: "teal",
		summary: (args) => `/${args.pattern ?? ""}/ in ${path(args)}${args.glob ? ` (${args.glob})` : ""}`,
		outcome: ({ text }) => countResults(text, "match", "matches"),
	},
	find: {
		icon: "\uf0c5",
		color: "sky",
		summary: (args) => `${args.pattern ?? ""} in ${path(args)}`,
		outcome: ({ text }) => countResults(text, "file"),
	},
	ls: {
		icon: "\uf03a",
		color: "sapphire",
		summary: path,
		outcome: ({ text }) => countResults(text, "entry", "entries"),
	},
};

export function registerCompactTools(pi: ExtensionAPI, isEnabled: () => boolean): void {
	// Pi asks once per tool row. `next()` is what Pi would draw without us.
	pi.registerToolRenderer((toolName, next) => {
		const native = next();
		const style = Object.hasOwn(TOOLS, toolName) ? TOOLS[toolName] : undefined;
		if (!native || !style || !isEnabled()) return native;
		return compactRenderers(toolName, style, native);
	});
}

/** Per-row state, kept in the row's shared renderer state under our own key. */
interface RowState {
	row?: Row;
	nativeCall?: Component;
	nativeResult?: Component;
}

function rowState(context: ToolRenderContext): RowState {
	context.state.kaiUi ??= {};
	return context.state.kaiUi;
}

function compactRenderers(name: string, style: ToolStyle, native: ToolRenderers): ToolRenderers {
	return {
		// We draw our own frame: none when collapsed, Pi's coloured card when expanded.
		renderShell: "self",

		renderCall(args, theme, context) {
			const state = rowState(context);
			if (context.expanded) {
				state.nativeCall = native.renderCall?.(args, theme, { ...context, lastComponent: state.nativeCall });
				const call = state.nativeCall ?? new Text(theme.fg("toolTitle", theme.bold(name)), 0, 0);
				return native.renderShell === "self" ? call : card(theme, context, [new Spacer(1), call]);
			}
			state.row ??= new Row(context.outputPad);
			state.row.parts = rowParts(theme, name, style, args as Args, context);
			return state.row;
		},

		renderResult(result, options, theme, context) {
			const state = rowState(context);
			const text = result.content.map((part) => (part.type === "text" ? part.text : "")).join("\n");
			if (options.expanded) {
				state.nativeResult = native.renderResult?.(result, options, theme, { ...context, lastComponent: state.nativeResult });
				const output = state.nativeResult ?? new Text(theme.fg("toolOutput", text), 0, 0);
				return native.renderShell === "self" ? output : card(theme, context, [output, new Spacer(1)]);
			}
			// Collapsed: fold the outcome into the call's row rather than adding a line.
			state.row ??= new Row(context.outputPad);
			state.row.parts = rowParts(theme, name, style, context.args as Args, context, { text, details: result.details });
			return new Container();
		},
	};
}

/** A row in three parts: head `✓  read `, summary `~/src/app.ts`, meta ` · 80 lines · 12ms`. */
interface RowParts {
	head: string;
	summary: string;
	meta: string;
}

function rowParts(theme: Theme, name: string, style: ToolStyle, args: Args, context: ToolRenderContext, result?: Outcome): RowParts {
	const done = result !== undefined && !context.isPartial;
	const status = !done ? paint(theme, "overlay", "•") : context.isError ? paint(theme, "red", "✗") : paint(theme, "green", "✓");

	const meta: string[] = [];
	if (done) meta.push(context.isError ? paint(theme, "red", errorSummary(result.text)) : paint(theme, "subtext", style.outcome(result, args)));
	if (context.durationMs !== undefined) meta.push(paint(theme, "overlay", formatDuration(context.durationMs)));

	const dot = paint(theme, "overlay", " · ");
	return {
		head: `${status} ${paint(theme, style.color, `${style.icon} ${theme.bold(name)}`)} `,
		summary: style.summary(args),
		meta: meta.map((part) => dot + part).join(""),
	};
}

/** Pi's coloured tool card, as drawn around tools that don't frame themselves. */
function card(theme: Theme, context: ToolRenderContext, children: Component[]): Box {
	const bg = context.isPartial ? "toolPendingBg" : context.isError ? "toolErrorBg" : "toolSuccessBg";
	const box = new Box(context.outputPad, 0, (text) => theme.bg(bg, text));
	for (const child of children) box.addChild(child);
	return box;
}

/** One line that never wraps: a long summary is shortened so the outcome stays visible. */
class Row implements Component {
	parts: RowParts = { head: "", summary: "", meta: "" };

	constructor(private readonly indent: number) {}

	render(width: number): string[] {
		const { head, summary, meta } = this.parts;
		const indent = " ".repeat(this.indent);
		const room = width - visibleWidth(indent + head + meta);
		const line = room >= 10 ? indent + head + truncateToWidth(summary, room) + meta : indent + head + summary + meta;
		return [truncateToWidth(line, width)];
	}

	invalidate(): void {}
}

// --- Summaries ----------------------------------------------------------

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
