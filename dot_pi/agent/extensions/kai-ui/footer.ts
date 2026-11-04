/**
 * Footer, below the editor, as rows of pills (segments.ts draws each one):
 *
 *   ( ~/src/app) ( main 1 2) ( 22.1.0)          (󰚩 claude-opus-5-5  󰧑 󰪣)
 *   (󰊚 ━━━━━━━━━━ 42% 1M) (󰕒 140k 󰇚 3.4k 󱊩 94% 󰇁 0.42)
 *
 * The turn stats sit on the input box's top rule instead (see index.ts).
 *   <statuses other extensions set with ctx.ui.setStatus()>
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
	thinkingSegment,
	usageSegment,
} from "./segments.ts";
import { pill } from "./widgets.ts";

type FooterFactory = NonNullable<Parameters<ExtensionUIContext["setFooter"]>[0]>;

export function createFooter(pi: ExtensionAPI, ctx: ExtensionContext, project: Project): FooterFactory {
	return (tui, theme, footerData) => {
		project.onUpdate = () => tui.requestRender();
		const stopWatchingBranch = footerData.onBranchChange(() => void project.refreshGit());

		/** One pill per segment that has something to show. */
		const pills = (...segments: Array<string | undefined>) =>
			segments.flatMap((segment) => (segment ? [pill(theme, segment)] : [])).join(" ");

		return {
			render(width: number): string[] {
				const lines = [
					spread(
						pills(cwdSegment(theme, ctx.cwd), gitSegment(theme, footerData.getGitBranch(), project.git), runtimeSegment(theme, project.runtime)),
						pills(join([modelSegment(theme, ctx), thinkingSegment(theme, pi, ctx)])),
						width,
					),
					truncateToWidth(pills(contextSegment(theme, ctx), usageSegment(theme, ctx)), width),
				];

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
