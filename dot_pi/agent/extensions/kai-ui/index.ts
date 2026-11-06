/**
 * kai-ui: a small UI layer for Pi, coloured from the active (Catppuccin) theme.
 *
 * - header.ts   startup header: model, thinking level, cwd, commands
 * - footer.ts   cwd, git, runtime on the left; context bar, tokens, cache, cost, usage quota on the right; extension statuses
 * - editor.ts   rounded frame around the input, with a  prompt and the turn stats on its top rule, the model and thinking level on its bottom rule
 * - tools.ts    tool cards with icons and one-line summaries, codemode's nested calls too; Ctrl+O shows Pi's full output
 * - segments.ts the pieces the header, footer and editor show
 * - widgets.ts  progress bar, sparkline
 * - icons.ts    Nerd Font glyphs by meaning
 * - brands.ts   model logos (Claude, GitHub, OpenAI, Google...)
 * - palette.ts  Catppuccin names for theme tokens, and the spinner
 * - project.ts  git status and runtime detection
 * - stats.ts    tokens/s, time to first token, run duration
 *
 * Only Pi's public extension API is used. `/kai-ui` switches it off and on to
 * compare with Pi's default UI.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { visibleWidth } from "@earendil-works/pi-tui";
import { FramedEditor } from "./editor.ts";
import { createFooter } from "./footer.ts";
import { createHeader } from "./header.ts";
import { icons } from "./icons.ts";
import { spinnerFrames } from "./palette.ts";
import { Project } from "./project.ts";
import { join, modelSegment, separator, speedSegment, thinkingSegment } from "./segments.ts";
import { TurnStats } from "./stats.ts";
import { attachVoice, detachVoice, VoiceIndicator } from "./voice.ts";
import { registerToolCards } from "./tools.ts";

/** A label if it fits in `maxWidth` columns, otherwise nothing. */
function fitting(label: string | undefined, maxWidth: number): string | undefined {
	return label && visibleWidth(label) <= maxWidth ? label : undefined;
}

export default function kaiUi(pi: ExtensionAPI) {
	let enabled = true;
	const stats = new TurnStats();
	const project = new Project(pi);
	const voice = new VoiceIndicator();

	function install(ctx: ExtensionContext): void {
		attachVoice(ctx.ui, voice);
		ctx.ui.setHeader(createHeader(pi, ctx));
		ctx.ui.setFooter(createFooter(pi, ctx, project));
		ctx.ui.setEditorComponent(
			(tui, theme, keybindings) => {
				voice.onChange = () => tui.requestRender();
				return new FramedEditor(
					tui,
					theme,
					keybindings,
					(maxWidth) => fitting(speedSegment(ctx.ui.theme, stats), maxWidth),
					(maxWidth) => fitting(modelLabel(ctx), maxWidth),
					// pi-listen's hold/record state, left of Pi's working spinner.
					(maxWidth) => fitting(voice.label(ctx.ui.theme), maxWidth),
				);
			},
		);
		ctx.ui.setWorkingIndicator({ frames: spinnerFrames(ctx.ui.theme), intervalMs: 80 });
	}

	/** The model and its thinking level, for the left of the input box's bottom rule. */
	function modelLabel(ctx: ExtensionContext): string {
		const theme = ctx.ui.theme;
		return join([modelSegment(theme, ctx), thinkingSegment(theme, pi, ctx)], separator(theme));
	}

	function uninstall(ctx: ExtensionContext): void {
		detachVoice(ctx.ui, voice);
		ctx.ui.setHeader(undefined);
		ctx.ui.setFooter(undefined);
		ctx.ui.setEditorComponent(undefined);
		ctx.ui.setWorkingIndicator();
	}

	// Rendering hooks: registered once, and they check `enabled` themselves.
	registerToolCards(pi, () => enabled);
	pi.registerMarkdownTransformer((markdown, { messageType }) =>
		enabled && messageType === "user" && markdown.trim() !== "" ? `${icons.prompt} ${markdown}` : markdown,
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
