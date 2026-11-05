/**
 * Footer, below the editor: a single row of segments (segments.ts draws each one), with
 * the status text other extensions set with ctx.ui.setStatus() (shortened to icons where
 * statuses.ts has a rule) after the runtime. When the row is too narrow, statuses are
 * dropped from the end first.
 *
 *   folder, git branch and counts, runtime, statuses     context bar, tokens in and out, cache hit rate, cost, usage quota
 *
 * The model, thinking level and turn stats sit on the input box's top rule instead (see index.ts).
 */

import type { ExtensionAPI, ExtensionContext, ExtensionUIContext } from "@earendil-works/pi-coding-agent";
import { visibleWidth } from "@earendil-works/pi-tui";
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

export function createFooter(_pi: ExtensionAPI, ctx: ExtensionContext, project: Project): FooterFactory {
	return (tui, theme, footerData) => {
		project.onUpdate = () => tui.requestRender();
		const stopWatchingBranch = footerData.onBranchChange(() => void project.refreshGit());

		return {
			render(width: number): string[] {
				const sep = separator(theme);
				const inner = width - 2; // a space of margin on each side

				const location = join([cwdSegment(theme, ctx.cwd), gitSegment(theme, footerData.getGitBranch(), project.git), runtimeSegment(theme, project.runtime)], sep);
				const quota = quotaSegment(theme, footerData.getExtensionStatuses());
				const usage = join([contextSegment(theme, ctx), usageSegment(theme, ctx), quota], sep);

				const statuses = [...footerData.getExtensionStatuses()].map(([key, text]) => statusSegment(theme, key, text)).filter(Boolean) as string[];
				// Keep as many statuses as fit beside the usage widgets; the rest are left out.
				let left = join([location, ...statuses], sep);
				while (statuses.length > 0 && visibleWidth(left) + visibleWidth(usage) + 2 > inner) {
					statuses.pop();
					left = join([location, ...statuses], sep);
				}
				return [` ${spread(left, usage, inner)} `];
			},
			invalidate() {},
			dispose() {
				stopWatchingBranch();
				project.onUpdate = undefined;
			},
		};
	};
}
