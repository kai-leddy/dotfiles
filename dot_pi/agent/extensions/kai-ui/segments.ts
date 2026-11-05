/**
 * The pieces the header, footer and editor are made of. Each returns a
 * coloured string, or undefined when there is nothing to show; footer.ts,
 * header.ts and index.ts decide where they go.
 */

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import { brandOf } from "./brands.ts";
import { formatCount, formatDuration, shortenPath } from "./format.ts";
import { icons } from "./icons.ts";
import { type CatppuccinColor, paint } from "./palette.ts";
import type { GitStatus, Runtime } from "./project.ts";
import type { TurnStats } from "./stats.ts";
import { progressBar, sparkline } from "./widgets.ts";

type Part = string | undefined | false | 0;

/** Join the parts that are set; empty strings, `undefined`, `false` and `0` are skipped. */
export function join(parts: Part[], sep = "  "): string {
	return parts.filter(Boolean).join(sep);
}

/** A dim dot between the segments of a footer or header line. */
export function separator(theme: Theme): string {
	return ` ${paint(theme, "overlay", icons.dot)} `;
}

/** The working directory, with a folder icon. */
export function cwdSegment(theme: Theme, cwd: string): string {
	return paint(theme, "sapphire", `${icons.folder} ${shortenPath(cwd)}`);
}

/** Branch icon and name, then counts of ahead, behind, staged, modified, untracked and conflicted. */
export function gitSegment(theme: Theme, branch: string | null, git: GitStatus | undefined): string | undefined {
	if (!branch) return undefined;
	const counts: Part[] = git
		? [
				git.ahead && paint(theme, "sky", `${icons.ahead}${git.ahead}`),
				git.behind && paint(theme, "sky", `${icons.behind}${git.behind}`),
				git.staged && paint(theme, "green", `${icons.staged}${git.staged}`),
				git.modified && paint(theme, "yellow", `${icons.modified}${git.modified}`),
				git.untracked && paint(theme, "subtext", `${icons.untracked}${git.untracked}`),
				git.conflicted && paint(theme, "red", `${icons.conflicted}${git.conflicted}`),
			]
		: [];
	return join([paint(theme, "mauve", `${icons.branch} ${branch}`), ...counts], " ");
}

/** The project's runtime version, with the runtime's own icon and colour. */
export function runtimeSegment(theme: Theme, runtime: Runtime | undefined): string | undefined {
	if (!runtime) return undefined;
	return paint(theme, runtime.color, `${runtime.icon} ${runtime.version ?? runtime.name}`);
}

/** The model's id, led by its maker's logo (see brands.ts). */
export function modelSegment(theme: Theme, ctx: ExtensionContext): string {
	if (!ctx.model) return paint(theme, "subtext", `${icons.model} no model`);
	const brand = brandOf(ctx.model.provider, ctx.model.id);
	return `${paint(theme, brand.color, brand.icon)} ${paint(theme, "blue", ctx.model.id)}`;
}

/** A brain and the thinking level in words, in the level's colour. Nothing for models that don't think. */
export function thinkingSegment(theme: Theme, pi: ExtensionAPI, ctx: ExtensionContext): string | undefined {
	if (!ctx.model?.reasoning) return undefined;
	const level = pi.getThinkingLevel();
	return theme.getThinkingBorderColor(level)(`${icons.thinking} ${level}`);
}

/** A gauge, a progress bar, the percentage and the window size. Yellow from 50%, red from 80%. */
export function contextSegment(theme: Theme, ctx: ExtensionContext): string | undefined {
	const usage = ctx.getContextUsage();
	if (!usage) return undefined;
	const size = paint(theme, "overlay", formatCount(usage.contextWindow));
	if (usage.percent === null) return `${paint(theme, "subtext", `${icons.context} ? `)}${size}`;

	const color: CatppuccinColor = usage.percent >= 80 ? "red" : usage.percent >= 50 ? "yellow" : "green";
	const bar = progressBar(theme, usage.percent / 100, 10, color);
	return `${paint(theme, color, icons.context)} ${bar} ${paint(theme, color, `${Math.round(usage.percent)}%`)} ${size}`;
}

/**
 * Tokens sent and received, the cache hit rate (database with a tick) and the
 * cost, totalled along the current branch.
 */
export function usageSegment(theme: Theme, ctx: ExtensionContext): string | undefined {
	const total = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0 };
	for (const entry of ctx.sessionManager.getBranch()) {
		if (entry.type !== "message" || entry.message.role !== "assistant") continue;
		const { usage } = entry.message as AssistantMessage;
		total.input += usage.input;
		total.output += usage.output;
		total.cacheRead += usage.cacheRead;
		total.cacheWrite += usage.cacheWrite;
		total.cost += usage.cost.total;
	}
	const prompt = total.input + total.cacheRead + total.cacheWrite;
	if (prompt + total.output === 0) return undefined;

	return join([
		paint(theme, "subtext", `${icons.tokensIn} ${formatCount(prompt)}`),
		paint(theme, "subtext", `${icons.tokensOut} ${formatCount(total.output)}`),
		total.cacheRead > 0 && cacheHitRate(theme, total.cacheRead / prompt),
		paint(theme, "peach", `${icons.cost} ${total.cost.toFixed(2)}`),
	]);
}

/** Share of prompt tokens read from the cache: green from 80%, yellow from 50%. */
function cacheHitRate(theme: Theme, rate: number): string {
	const color: CatppuccinColor = rate >= 0.8 ? "green" : rate >= 0.5 ? "yellow" : "red";
	return paint(theme, color, `${icons.cache} ${Math.round(rate * 100)}%`);
}

/** Tokens per second with its recent history, time to first token, and how long the run has taken. */
export function speedSegment(theme: Theme, stats: TurnStats): string | undefined {
	const { tokensPerSecond, timeToFirstTokenMs, runDurationMs, speedHistory } = stats;
	return (
		join([
			tokensPerSecond !== undefined &&
				`${paint(theme, "teal", `${icons.speed} ${Math.round(tokensPerSecond)} t/s`)} ${sparkline(theme, speedHistory, "teal")}`,
			timeToFirstTokenMs !== undefined && paint(theme, "sky", `${icons.firstToken} ${formatDuration(timeToFirstTokenMs)}`),
			runDurationMs !== undefined && paint(theme, "blue", `${icons.duration} ${formatDuration(runDurationMs)}`),
		]) || undefined
	);
}
