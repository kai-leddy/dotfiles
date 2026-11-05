/**
 * Footer, below the editor: two rows of segments (segments.ts draws each one),
 * separated by a dim dot, then the status text other extensions set with
 * ctx.ui.setStatus().
 *
 *   folder, git branch and counts, runtime                        model, thinking level
 *   context bar, tokens in and out, cache hit rate, cost
 *
 * The turn stats sit on the input box's top rule instead (see index.ts).
 */

import type { ExtensionAPI, ExtensionContext, ExtensionUIContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";
import { spread } from "./format.ts";
import type { Project } from "./project.ts";
import {
	contextSegment,
	cwdSegment,
	gitSegment,
	join,
	modelSegment,
	runtimeSegment,
	separator,
	thinkingSegment,
	usageSegment,
} from "./segments.ts";

type FooterFactory = NonNullable<Parameters<ExtensionUIContext["setFooter"]>[0]>;

export function createFooter(pi: ExtensionAPI, ctx: ExtensionContext, project: Project): FooterFactory {
	return (tui, theme, footerData) => {
		project.onUpdate = () => tui.requestRender();
		const stopWatchingBranch = footerData.onBranchChange(() => void project.refreshGit());

		return {
			render(width: number): string[] {
				const sep = separator(theme);
				const inner = width - 2; // a space of margin on each side

				const location = join([cwdSegment(theme, ctx.cwd), gitSegment(theme, footerData.getGitBranch(), project.git), runtimeSegment(theme, project.runtime)], sep);
				const model = join([modelSegment(theme, ctx), thinkingSegment(theme, pi, ctx)], sep);
				const usage = join([contextSegment(theme, ctx), usageSegment(theme, ctx)], sep);

				const lines = [` ${spread(location, model, inner)} `, ` ${truncateToWidth(usage, inner)}`];

				const statuses = [...footerData.getExtensionStatuses().values()].filter(Boolean);
				if (statuses.length > 0) lines.push(truncateToWidth(` ${statuses.join("  ")}`, width));
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
