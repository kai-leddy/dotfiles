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
 * `/kai-ui` switches the layer off and on while retaining the previous editor.
 * The frame observes the editor's protected bottom-border hook for layout.
 */

import { CustomEditor, type ExtensionAPI, type ExtensionContext } from "@earendil-works/pi-coding-agent";
import { visibleWidth, type EditorComponent } from "@earendil-works/pi-tui";
import { homedir } from "node:os";
import { join as joinPath } from "node:path";
import { frameEditor } from "./editor.ts";
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

/** Only decorate editors exposing the hooks and text methods used by the frame. */
function isFrameable(editor: EditorComponent): editor is CustomEditor {
	return ["renderBottomBorder", "render", "handleMouse", "isShowingAutocomplete", "borderColor", "getLines", "getCursor", "insertTextAtCursor"]
		.every((name) => typeof (editor as unknown as Record<string, unknown>)[name] === "function");
}

export default async function kaiUi(pi: ExtensionAPI) {
	// Pi's package filter prevents a second registration. Register its hooks first
	// so its session_start installs the factory before kai-ui captures it.
	let vimError: string | undefined;
	try {
		const agentDir = process.env.PI_CODING_AGENT_DIR || joinPath(homedir(), ".pi/agent");
		const path = joinPath(agentDir, "npm/node_modules/pi-vim/index.ts");
		const plugin = await import(path);
		if (typeof plugin.default !== "function") throw new Error("missing default extension factory");
		await plugin.default(pi);
	} catch (error) {
		vimError = error instanceof Error ? error.message : String(error);
	}

	let enabled = true;
	const stats = new TurnStats();
	const project = new Project(pi);
	const voice = new VoiceIndicator();
	let editor: CustomEditor | undefined;
	let previousEditor: ReturnType<ExtensionContext["ui"]["getEditorComponent"]>;

	function install(ctx: ExtensionContext): void {
		previousEditor = ctx.ui.getEditorComponent();
		attachVoice(ctx.ui, voice, () => editor);
		ctx.ui.setHeader(createHeader(pi, ctx));
		ctx.ui.setFooter(createFooter(pi, ctx, project));
		ctx.ui.setEditorComponent(
			(tui, theme, keybindings) => {
				voice.onChange = () => tui.requestRender();
				const base = previousEditor?.(tui, theme, keybindings) ?? new CustomEditor(tui, theme, keybindings, { embedWorkingStatus: true });
				if (!isFrameable(base)) {
					detachVoice(ctx.ui, voice);
					voice.onChange = undefined;
					editor = undefined;
					ctx.ui.notify("kai-ui: editor cannot be framed; leaving it unchanged", "warning");
					return base;
				}
				editor = frameEditor(
					base,
					(maxWidth) => fitting(speedSegment(ctx.ui.theme, stats), maxWidth),
					(maxWidth) => fitting(modelLabel(ctx), maxWidth),
					// pi-listen's hold/record state on the top rule.
					(maxWidth) => fitting(voice.label(ctx.ui.theme), maxWidth),
				);
				return editor;
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
		ctx.ui.setEditorComponent(previousEditor);
		editor = undefined;
		voice.onChange = undefined;
		ctx.ui.setWorkingIndicator();
	}

	// Rendering hooks: registered once, and they check `enabled` themselves.
	registerToolCards(pi, () => enabled);
	pi.registerMarkdownTransformer((markdown, { messageType }) =>
		enabled && messageType === "user" && markdown.trim() !== "" ? `${icons.prompt} ${markdown}` : markdown,
	);

	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;
		if (vimError) ctx.ui.notify(`kai-ui: pi-vim unavailable; using Pi editor (${vimError})`, "warning");
		void project.load(ctx.cwd);
		if (enabled) install(ctx);
	});

	pi.on("session_shutdown", (_event, ctx) => {
		if (ctx.mode !== "tui") return;
		detachVoice(ctx.ui, voice);
		voice.onChange = undefined;
		editor = undefined;
	});

	// Turn telemetry for the footer.
	pi.on("agent_start", () => stats.startRun());
	pi.on("turn_start", () => stats.startTurn());
	pi.on("message_update", (event) => {
		const e = event.assistantMessageEvent;
		if (!e.type.endsWith("_delta") || !("delta" in e)) return;
		stats.sawToken(e.delta, e.partial.usage?.output ?? 0);
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
		description: "Switch kai-ui off or on, keeping the previous editor",
		handler: async (_args, ctx) => {
			if (ctx.mode !== "tui") return;
			enabled = !enabled;
			if (enabled) install(ctx);
			else uninstall(ctx);
			ctx.ui.notify(enabled ? "kai-ui on" : "kai-ui off: previous editor restored (new tool rows and messages use Pi's UI)", "info");
		},
	});
}
