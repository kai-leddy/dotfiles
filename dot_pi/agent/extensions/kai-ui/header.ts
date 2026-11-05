/**
 * Startup header, shown above the chat. It replaces Pi's logo and key hints:
 *
 *   pi icon  model, thinking level
 *            folder
 *            /model  /settings  /resume  /tree  /hotkeys  /kai-ui
 */

import type { ExtensionAPI, ExtensionContext, ExtensionUIContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";
import { icons } from "./icons.ts";
import { paint } from "./palette.ts";
import { cwdSegment, join, modelSegment, separator, thinkingSegment } from "./segments.ts";

type HeaderFactory = NonNullable<Parameters<ExtensionUIContext["setHeader"]>[0]>;

const COMMANDS = ["/model", "/settings", "/resume", "/tree", "/hotkeys", "/kai-ui"];

export function createHeader(pi: ExtensionAPI, ctx: ExtensionContext): HeaderFactory {
	return (_tui, theme) => ({
		// Reads the model and thinking level on every render, so it never shows stale values.
		render(width: number): string[] {
			const model = join([modelSegment(theme, ctx), thinkingSegment(theme, pi, ctx)], separator(theme));
			const lines = [
				"",
				` ${paint(theme, "mauve", theme.bold(icons.pi))}  ${model}`,
				`    ${cwdSegment(theme, ctx.cwd)}`,
				`    ${paint(theme, "overlay", COMMANDS.join("  "))}`,
				"",
			];
			return lines.map((line) => truncateToWidth(line, width));
		},
		invalidate() {},
	});
}
