/**
 * kai-ui: a small UI layer for Pi, coloured from the active (Catppuccin) theme.
 *
 * - header.ts   startup header: model, thinking level, cwd, commands
 * - footer.ts   cwd, git, runtime, model, context, tokens, cost, turn stats, extension statuses
 * - editor.ts   rounded frame around the input, with a ❯ prompt
 * - tools.ts    one-line rows for built-in tool calls; Ctrl+O shows Pi's full output
 * - palette.ts  Catppuccin names for theme tokens, and the spinner
 * - project.ts  git status and runtime detection
 * - stats.ts    tokens/s, time to first token, run duration
 *
 * Only Pi's public extension API is used. `/kai-ui` switches it off and on to
 * compare with Pi's default UI.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { FramedEditor } from "./editor.ts";
import { createFooter } from "./footer.ts";
import { createHeader } from "./header.ts";
import { spinnerFrames } from "./palette.ts";
import { Project } from "./project.ts";
import { TurnStats } from "./stats.ts";
import { registerCompactTools } from "./tools.ts";

export default function kaiUi(pi: ExtensionAPI) {
	let enabled = true;
	const stats = new TurnStats();
	const project = new Project(pi);

	function install(ctx: ExtensionContext): void {
		ctx.ui.setHeader(createHeader(pi, ctx));
		ctx.ui.setFooter(createFooter(pi, ctx, project, stats));
		ctx.ui.setEditorComponent((tui, theme, keybindings) => new FramedEditor(tui, theme, keybindings));
		ctx.ui.setWorkingIndicator({ frames: spinnerFrames(ctx.ui.theme), intervalMs: 80 });
	}

	function uninstall(ctx: ExtensionContext): void {
		ctx.ui.setHeader(undefined);
		ctx.ui.setFooter(undefined);
		ctx.ui.setEditorComponent(undefined);
		ctx.ui.setWorkingIndicator();
	}

	// Rendering hooks: registered once, and they check `enabled` themselves.
	registerCompactTools(pi, () => enabled);
	pi.registerMarkdownTransformer((markdown, { messageType }) =>
		enabled && messageType === "user" && markdown.trim() !== "" ? `❯ ${markdown}` : markdown,
	);

	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;
		void project.load(ctx.cwd);
		if (enabled) install(ctx);
	});

	// Turn telemetry for the footer.
	pi.on("agent_start", () => stats.startRun());
	pi.on("turn_start", () => stats.startTurn());
	pi.on("message_update", (event) => {
		if (event.assistantMessageEvent.type.endsWith("_delta")) stats.sawToken();
	});
	pi.on("message_end", (event) => {
		if (event.message.role === "assistant") stats.finishResponse(event.message.usage.output);
	});
	pi.on("agent_settled", () => stats.endRun());

	// Tools may have changed files, so refresh the git counts after each turn.
	pi.on("turn_end", (_event, ctx) => {
		if (ctx.mode === "tui") void project.refreshGit();
	});

	pi.registerCommand("kai-ui", {
		description: "Switch kai-ui off or on, to compare with Pi's default UI",
		handler: async (_args, ctx) => {
			enabled = !enabled;
			if (enabled) install(ctx);
			else uninstall(ctx);
			ctx.ui.notify(enabled ? "kai-ui on" : "kai-ui off: Pi's default UI (for new tool rows and messages)", "info");
		},
	});
}
