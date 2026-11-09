/**
 * Footer, below the editor: segments (segments.ts draws each one), with the status text other extensions
 * set with ctx.ui.setStatus() (shortened to icons where statuses.ts has a rule) after the runtime.
 *
 *   folder, git branch and counts, runtime, statuses     context bar, tokens in and out, cache hit rate, cost, usage quota
 *
 * Nothing is cut short. As the terminal narrows, the least important things go one at a time:
 * statuses (last first), the runtime, the cache hit rate, the progress bars (percentages stay). If it
 * still doesn't fit, the footer splits in two: folder, branch, runtime and statuses on the first line,
 * the usage figures on the second.
 *
 * The model, thinking level and turn stats sit on the input box's top rule instead (see index.ts).
 */

import type { ExtensionAPI, ExtensionContext, ExtensionUIContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { spread } from "./format.ts";
import type { Project } from "./project.ts";
import { quotaSegment, statusSegment } from "./statuses.ts";
import {
	contextSegment,
	cwdSegment,
	gitSegment,
	join,
	runtimeSegment,
	separator,
	usageSegment,
} from "./segments.ts";

type FooterFactory = NonNullable<Parameters<ExtensionUIContext["setFooter"]>[0]>;

/** What the left side shows: how many statuses, and whether the runtime is there. */
interface LeftPlan {
	statuses: number;
	runtime: boolean;
}

/** What the right side shows. */
interface RightPlan {
	cache: boolean;
	bars: boolean;
}

export function createFooter(_pi: ExtensionAPI, ctx: ExtensionContext, project: Project): FooterFactory {
	return (tui, theme, footerData) => {
		project.onUpdate = () => tui.requestRender();
		const stopWatchingBranch = footerData.onBranchChange(() => void project.refreshGit());

		return {
			render(width: number): string[] {
				const sep = separator(theme);
				const inner = width - 2; // a space of margin on each side
				const extStatuses = footerData.getExtensionStatuses();
				const statuses = [...extStatuses].map(([key, text]) => statusSegment(theme, key, text)).filter(Boolean) as string[];

				const left = (plan: LeftPlan): string =>
					join(
						[
							cwdSegment(theme, ctx.cwd),
							gitSegment(theme, footerData.getGitBranch(), project.git),
							plan.runtime && runtimeSegment(theme, project.runtime),
							...statuses.slice(0, plan.statuses),
						],
						sep,
					);
				const right = (plan: RightPlan): string =>
					join(
						[
							contextSegment(theme, ctx, plan.bars ? 10 : 0),
							usageSegment(theme, ctx, { cache: plan.cache }),
							quotaSegment(theme, extStatuses, plan.bars ? 10 : 0),
						],
						sep,
					);

				// Plans from fullest to barest.
				const leftPlans: LeftPlan[] = [];
				for (let n = statuses.length; n >= 0; n--) leftPlans.push({ statuses: n, runtime: true });
				leftPlans.push({ statuses: 0, runtime: false });
				const rightPlans: RightPlan[] = [
					{ cache: true, bars: true },
					{ cache: false, bars: true },
					{ cache: false, bars: false },
				];
				const barestLeft = leftPlans[leftPlans.length - 1]!;
				const barestRight = rightPlans[rightPlans.length - 1]!;

				// One line: statuses go first, then the runtime, then the cache rate, then the bars.
				const singleLine: Array<[LeftPlan, RightPlan]> = [
					...leftPlans.map((l): [LeftPlan, RightPlan] => [l, rightPlans[0]!]),
					...rightPlans.slice(1).map((r): [LeftPlan, RightPlan] => [barestLeft, r]),
				];
				for (const [l, r] of singleLine) {
					const a = left(l);
					const b = right(r);
					if (visibleWidth(a) + visibleWidth(b) + 2 <= inner) return [` ${spread(a, b, inner)} `];
				}

				// Two lines: the location, with as much as fits, above the usage figures.
				const a = leftPlans.map(left).find((text) => visibleWidth(text) <= inner) ?? left(barestLeft);
				const b = rightPlans.map(right).find((text) => visibleWidth(text) <= inner) ?? right(barestRight);
				return [` ${fit(a, inner)} `, ` ${" ".repeat(Math.max(0, inner - visibleWidth(b)))}${fit(b, inner)} `];
			},
			invalidate() {},
			dispose() {
				stopWatchingBranch();
				project.onUpdate = undefined;
			},
		};
	};
}

/** Last resort for a terminal narrower than even the barest line: cut it (only then). */
function fit(text: string, width: number): string {
	return visibleWidth(text) <= width ? text : truncateToWidth(text, width, "\u2026").replaceAll("\x1b[0m", "\x1b[39m");
}
