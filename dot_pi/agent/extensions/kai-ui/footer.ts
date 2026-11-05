/**
 * Footer, below the editor: one row of segments (segments.ts draws each one),
 * then the status text other extensions set with ctx.ui.setStatus(), shortened to icons
 * where statuses.ts has a rule for them.
 *
 *   folder, git branch and counts, runtime          context bar, tokens in and out, cache hit rate, cost
 *
 * The model, thinking level and turn stats sit on the input box's top rule instead (see index.ts).
 */

import type { ExtensionAPI, ExtensionContext, ExtensionUIContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";
import { spread } from "./format.ts";
import type { Project } from "./project.ts";
import { statusSegment } from "./statuses.ts";
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
/** What Pi lets a footer read: git branch and extension statuses. */
export type FooterData = Parameters<FooterFactory>[2];

export function createFooter(
	_pi: ExtensionAPI,
	ctx: ExtensionContext,
	project: Project,
	/** Called with the footer data, so the input box can read the extension statuses too. */
	onFooterData: (data: FooterData | undefined) => void,
): FooterFactory {
	return (tui, theme, footerData) => {
		onFooterData(footerData);
		project.onUpdate = () => tui.requestRender();
		const stopWatchingBranch = footerData.onBranchChange(() => void project.refreshGit());

		return {
			render(width: number): string[] {
				const sep = separator(theme);
				const inner = width - 2; // a space of margin on each side

				const location = join([cwdSegment(theme, ctx.cwd), gitSegment(theme, footerData.getGitBranch(), project.git), runtimeSegment(theme, project.runtime)], sep);
				const usage = join([contextSegment(theme, ctx), usageSegment(theme, ctx)], sep);

				const lines = [` ${spread(location, usage, inner)} `];

				const statuses = [...footerData.getExtensionStatuses()].map(([key, text]) => statusSegment(theme, key, text)).filter(Boolean);
				if (statuses.length > 0) lines.push(truncateToWidth(` ${statuses.join(sep)}`, width));
				return lines;
			},
			invalidate() {},
			dispose() {
				stopWatchingBranch();
				onFooterData(undefined);
				project.onUpdate = undefined;
			},
		};
	};
}
