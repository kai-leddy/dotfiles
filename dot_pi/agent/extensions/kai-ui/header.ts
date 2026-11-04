/**
 * Startup header, shown above the chat: model, thinking level, working
 * directory and a few useful commands. It replaces Pi's logo and key hints.
 */

import type { ExtensionAPI, ExtensionContext, ExtensionUIContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";
import { shortenPath } from "./format.ts";
import { paint } from "./palette.ts";

type HeaderFactory = NonNullable<Parameters<ExtensionUIContext["setHeader"]>[0]>;

const COMMANDS = ["/model", "/settings", "/resume", "/tree", "/hotkeys", "/kai-ui"];

export function createHeader(pi: ExtensionAPI, ctx: ExtensionContext): HeaderFactory {
	return (_tui, theme) => ({
		// Reads the model and thinking level on every render, so it never shows stale values.
		render(width: number): string[] {
			const dot = paint(theme, "overlay", " · ");
			const level = pi.getThinkingLevel();
			const model = ctx.model
				? paint(theme, "blue", ctx.model.id) + (ctx.model.reasoning ? dot + theme.getThinkingBorderColor(level)(level) : "")
				: paint(theme, "subtext", "no model selected");

			const lines = [
				"",
				` ${paint(theme, "mauve", theme.bold("π"))}  ${model}`,
				`    ${paint(theme, "sapphire", shortenPath(ctx.cwd))}`,
				`    ${paint(theme, "overlay", COMMANDS.join("  "))}`,
				"",
			];
			return lines.map((line) => truncateToWidth(line, width));
		},
		invalidate() {},
	});
}
