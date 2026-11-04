/**
 * The pieces the footer and header are made of. Each returns a coloured
 * string, or undefined when there is nothing to show; footer.ts and
 * header.ts decide where they go.
 */

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import { formatCount, formatDuration, shortenPath } from "./format.ts";
import { icons, thinkingLevels } from "./icons.ts";
import { type CatppuccinColor, paint } from "./palette.ts";
import type { GitStatus, Runtime } from "./project.ts";
import type { TurnStats } from "./stats.ts";
import { progressBar, sparkline } from "./widgets.ts";

type Part = string | undefined | false | 0;

/** Join the parts that are set; empty strings, `undefined`, `false` and `0` are skipped. */
export function join(parts: Part[], sep = "  "): string {
	return parts.filter(Boolean).join(sep);
}

/** ` ~/src/app` */
export function cwdSegment(theme: Theme, cwd: string): string {
	return paint(theme, "sapphire", `${icons.folder} ${shortenPath(cwd)}`);
}

/** ` main 1 2 +3 !4 ?5 ~1`: ahead, behind, staged, modified, untracked, conflicted. */
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

/** ` 22.1.0`, with the runtime's own icon and colour. */
export function runtimeSegment(theme: Theme, runtime: Runtime | undefined): string | undefined {
	if (!runtime) return undefined;
	return paint(theme, runtime.color, `${runtime.icon} ${runtime.version ?? runtime.name}`);
}

/** `󰚩 claude-opus-5-5` */
export function modelSegment(theme: Theme, ctx: ExtensionContext): string {
	if (!ctx.model) return paint(theme, "subtext", `${icons.model} no model`);
	return paint(theme, "blue", `${icons.model} ${ctx.model.id}`);
}

/** `󰧑 󰪣`: a circle that fills up with the thinking level, in the level's colour. */
export function thinkingSegment(theme: Theme, pi: ExtensionAPI, ctx: ExtensionContext, withLabel = false): string | undefined {
	if (!ctx.model?.reasoning) return undefined;
	const level = pi.getThinkingLevel();
	const color = theme.getThinkingBorderColor(level);
	return color(`${icons.thinking} ${thinkingLevels[level]}${withLabel ? ` ${level}` : ""}`);
}

/** `󰊚 ━━━━━━━━━━ 42% 1M`, going yellow from 50% and red from 80%. */
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
 * `󰕒 12k  󰇚 3.4k  󱊩 94%  󰇁 0.42`: tokens sent and received, cache hit rate
 * and cost, totalled along the current branch.
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

/** ` 38 t/s ▂▄▆█▅  󰔟 1.2s  󰔛 8.4s`: speed and its recent history, time to first token, run time. */
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
