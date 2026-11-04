/**
 * Input box: Pi's editor in a rounded frame, with a ❯ prompt.
 *
 *   ╭──── ⠋ Working... ───────────────╮
 *   │ ❯ first line of the prompt      │
 *   │   wrapped or second line        │
 *   ╰─────────────────────────────────╯
 *
 * It extends Pi's CustomEditor, so every key binding and agent control keeps
 * working. Pi sets `borderColor` from the thinking level (or bash mode), so
 * the frame and the ❯ follow it. The working spinner and scroll hints that Pi
 * draws in the editor's top and bottom rules end up inside the frame.
 */

import { CustomEditor, type KeybindingsManager } from "@earendil-works/pi-coding-agent";
import type { EditorTheme, TUI, TuiMouseEvent, TuiMouseEventResult } from "@earendil-works/pi-tui";

const PROMPT = "❯";
/** Columns left of the text: "│ ❯ " */
const LEFT = 4;
/** Columns right of the text: " │" */
const RIGHT = 2;

export class FramedEditor extends CustomEditor {
	/** The last bottom rule, used to find where the text rows end. */
	private bottomBorder = "";

	constructor(tui: TUI, theme: EditorTheme, keybindings: KeybindingsManager) {
		super(tui, theme, keybindings, { embedWorkingStatus: true });
	}

	override render(width: number): string[] {
		// The editor lays out its text in the space inside the frame. Its rules
		// come back full width (see the border overrides below).
		const lines = super.render(Math.max(1, width - LEFT - RIGHT));
		const bottom = lines.indexOf(this.bottomBorder, 1);
		if (bottom === -1) return lines;

		const side = this.borderColor("│");
		return lines.map((line, i) => {
			if (i === 0 || i === bottom) return line;
			// Autocomplete suggestions sit below the frame, lined up with the text.
			if (i > bottom) return " ".repeat(LEFT) + line;
			const gutter = i === 1 ? this.borderColor(PROMPT) : " ";
			return `${side} ${gutter} ${line} ${side}`;
		});
	}

	protected override renderTopBorder(width: number, hiddenLineCount: number): string {
		return this.borderColor("╭───") + super.renderTopBorder(width, hiddenLineCount) + this.borderColor("─╮");
	}

	protected override renderBottomBorder(width: number, hiddenLineCount: number): string {
		this.bottomBorder = this.borderColor("╰───") + super.renderBottomBorder(width, hiddenLineCount) + this.borderColor("─╯");
		return this.bottomBorder;
	}

	/** Mouse clicks (fullscreen mode) arrive in frame coordinates; the editor expects text coordinates. */
	override handleMouse(event: TuiMouseEvent): TuiMouseEventResult | undefined {
		return super.handleMouse({ ...event, x: event.x - LEFT, width: event.width - LEFT - RIGHT });
	}
}
