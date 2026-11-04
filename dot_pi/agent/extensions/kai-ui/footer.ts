/**
 * Footer, below the editor:
 *
 *   ~/src/app   main ⇡1 +2 !3 ?1   node 22.1.0          claude-sonnet-5 · high
 *   ctx 42% of 200k  ↑12k ↓3.4k R140k  $0.42       38 tok/s  ttft 1.2s  ⏱ 8.4s
 *   <statuses other extensions set with ctx.ui.setStatus()>
 */

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext, ExtensionUIContext, Theme } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";
import { formatCount, formatDuration, shortenPath, spread } from "./format.ts";
import { paint } from "./palette.ts";
import type { GitStatus, Project } from "./project.ts";
import type { TurnStats } from "./stats.ts";

type FooterFactory = NonNullable<Parameters<ExtensionUIContext["setFooter"]>[0]>;

const ICON_FOLDER = "\uf07b";
const ICON_BRANCH = "\ue0a0";

export function createFooter(pi: ExtensionAPI, ctx: ExtensionContext, project: Project, stats: TurnStats): FooterFactory {
	return (tui, theme, footerData) => {
		project.onUpdate = () => tui.requestRender();
		const stopWatchingBranch = footerData.onBranchChange(() => void project.refreshGit());

		return {
			render(width: number): string[] {
				const sep = "  ";
				const location = [
					paint(theme, "sapphire", `${ICON_FOLDER} ${shortenPath(ctx.cwd)}`),
					gitSegment(theme, footerData.getGitBranch(), project.git),
					project.runtime &&
						paint(theme, project.runtime.color, `${project.runtime.icon} ${project.runtime.version ?? project.runtime.name}`),
				];
				const usage = [contextSegment(theme, ctx), tokensSegment(theme, ctx)];

				const lines = [
					spread(join(location, sep), modelSegment(theme, pi, ctx), width),
					spread(join(usage, sep), join(statsSegments(theme, stats), sep), width),
				];

				const statuses = [...footerData.getExtensionStatuses().values()].filter(Boolean);
				if (statuses.length > 0) lines.push(truncateToWidth(statuses.join(sep), width));
				return lines;
			},
			invalidate() {},
			dispose() {
				stopWatchingBranch();
				project.onUpdate = undefined;
			},
		};
	};
}

/** Join the parts that are set; empty strings, `undefined`, `false` and `0` are skipped. */
function join(parts: Array<string | undefined | false | 0>, sep: string): string {
	return parts.filter(Boolean).join(sep);
}

/** `main ⇡1 ⇣2 +3 !4 ?5 ~1`: ahead, behind, staged, modified, untracked, conflicted. */
function gitSegment(theme: Theme, branch: string | null, git: GitStatus | undefined): string | undefined {
	if (!branch) return undefined;
	const counts = git
		? [
				git.ahead && paint(theme, "sky", `⇡${git.ahead}`),
				git.behind && paint(theme, "sky", `⇣${git.behind}`),
				git.staged && paint(theme, "green", `+${git.staged}`),
				git.modified && paint(theme, "yellow", `!${git.modified}`),
				git.untracked && paint(theme, "subtext", `?${git.untracked}`),
				git.conflicted && paint(theme, "red", `~${git.conflicted}`),
			]
		: [];
	return join([paint(theme, "mauve", `${ICON_BRANCH} ${branch}`), ...counts], " ");
}

function modelSegment(theme: Theme, pi: ExtensionAPI, ctx: ExtensionContext): string {
	if (!ctx.model) return paint(theme, "subtext", "no model");
	const model = paint(theme, "blue", ctx.model.id);
	if (!ctx.model.reasoning) return model;
	const level = pi.getThinkingLevel();
	return `${model}${paint(theme, "overlay", " · ")}${theme.getThinkingBorderColor(level)(level)}`;
}

/** `ctx 42% of 200k`, going yellow from 50% and red from 80%. */
function contextSegment(theme: Theme, ctx: ExtensionContext): string | undefined {
	const usage = ctx.getContextUsage();
	if (!usage) return undefined;
	const size = formatCount(usage.contextWindow);
	if (usage.percent === null) return paint(theme, "subtext", `ctx ? of ${size}`);
	const color = usage.percent >= 80 ? "red" : usage.percent >= 50 ? "yellow" : "green";
	return `${paint(theme, color, `ctx ${Math.round(usage.percent)}%`)}${paint(theme, "subtext", ` of ${size}`)}`;
}

/** Session totals along the current branch: `↑input ↓output Rcache-read Wcache-write $cost`. */
function tokensSegment(theme: Theme, ctx: ExtensionContext): string | undefined {
	let input = 0;
	let output = 0;
	let cacheRead = 0;
	let cacheWrite = 0;
	let cost = 0;
	for (const entry of ctx.sessionManager.getBranch()) {
		if (entry.type !== "message" || entry.message.role !== "assistant") continue;
		const { usage } = entry.message as AssistantMessage;
		input += usage.input;
		output += usage.output;
		cacheRead += usage.cacheRead;
		cacheWrite += usage.cacheWrite;
		cost += usage.cost.total;
	}
	if (input + output === 0) return undefined;

	const tokens = join(
		[`↑${formatCount(input)}`, `↓${formatCount(output)}`, cacheRead && `R${formatCount(cacheRead)}`, cacheWrite && `W${formatCount(cacheWrite)}`],
		" ",
	);
	return `${paint(theme, "subtext", tokens)}  ${paint(theme, "peach", `$${cost.toFixed(2)}`)}`;
}

function statsSegments(theme: Theme, stats: TurnStats): Array<string | undefined> {
	const { tokensPerSecond, timeToFirstTokenMs, runDurationMs } = stats;
	return [
		tokensPerSecond !== undefined ? paint(theme, "teal", `${Math.round(tokensPerSecond)} tok/s`) : undefined,
		timeToFirstTokenMs !== undefined ? paint(theme, "sky", `ttft ${formatDuration(timeToFirstTokenMs)}`) : undefined,
		runDurationMs !== undefined ? paint(theme, "blue", `⏱ ${formatDuration(runDurationMs)}`) : undefined,
	];
}
