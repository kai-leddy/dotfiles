/**
 * Input box: Pi's editor in a rounded frame, with a  prompt and a label
 * on the right of the top rule and one on the left of the bottom rule (index.ts passes the turn
 * stats, and the model with its thinking level).
 *
 *   ╭──── ⠋ Working... ────  38 t/s ▂▄▆  󰔟 1.2s ─╮
 *   │  first line of the prompt      │
 *   │   wrapped or second line        │
 *   ╰─── claude-sonnet-5-5  high ───────────────╯
 *
 * It extends Pi's CustomEditor, so every key binding and agent control keeps
 * working. Pi sets `borderColor` from the thinking level (or bash mode), so
 * the frame and the  follow it. The working spinner and scroll hints that Pi
 * draws in the editor's top and bottom rules end up inside the frame.
 */

import { CustomEditor, type KeybindingsManager } from "@earendil-works/pi-coding-agent";
import { type EditorTheme, type TUI, type TuiMouseEvent, type TuiMouseEventResult, visibleWidth } from "@earendil-works/pi-tui";
import { icons } from "./icons.ts";

/** Columns left of the text: "│  " */
const LEFT = 4;
/** Columns right of the text: " │" */
const RIGHT = 2;
/** Narrowest the rest of the top rule may get before the label is dropped. */
const MIN_RULE = 20;

export class FramedEditor extends CustomEditor {
	/** The last bottom rule, used to find where the text rows end. */
	private bottomBorder = "";

	constructor(
		tui: TUI,
		theme: EditorTheme,
		keybindings: KeybindingsManager,
		/**
		 * Coloured text for the right of the top rule, read on every render. It gets the columns
		 * it may use and returns something that fits, or nothing.
		 */
		private readonly topRightLabel: (maxWidth: number) => string | undefined = () => undefined,
		/** Same for the left of the bottom rule. */
		private readonly bottomLeftLabel: (maxWidth: number) => string | undefined = () => undefined,
		/** Same for the left of the top rule, before Pi's own spinner (pi-listen's hold and record state). */
		private readonly topLeftLabel: (maxWidth: number) => string | undefined = () => undefined,
	) {
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
			const gutter = i === 1 ? this.borderColor(icons.prompt) : " ";
			return `${side} ${gutter} ${line} ${side}`;
		});
	}

	protected override renderTopBorder(width: number, hiddenLineCount: number): string {
		let room = width - MIN_RULE;
		let left = this.topLeftLabel(Math.max(0, room - 2));
		if (left) room -= visibleWidth(left) + 2;
		let right = this.topRightLabel(Math.max(0, room - 2));
		if (right) room -= visibleWidth(right) + 2;
		// Drop labels that would squeeze Pi's part of the rule (the right one first).
		if (room < 0) {
			right = undefined;
			left = left && width - visibleWidth(left) - 2 >= MIN_RULE ? left : undefined;
		}
		const leftWidth = left ? visibleWidth(left) + 2 : 0;
		const rightWidth = right ? visibleWidth(right) + 2 : 0;
		// Pi draws its part of the rule (spinner, scroll hint) narrower, leaving room for the labels.
		const rule = super.renderTopBorder(width - leftWidth - rightWidth, hiddenLineCount);
		return (
			this.borderColor("╭───") +
			(left ? ` ${left} ` : "") +
			rule +
			(right ? ` ${right} ` : "") +
			this.borderColor("─╮")
		);
	}

	protected override renderBottomBorder(width: number, hiddenLineCount: number): string {
		const label = this.bottomLeftLabel(Math.max(0, width - MIN_RULE - 2));
		const labelWidth = label ? visibleWidth(label) + 2 : 0;
		if (!label || width - labelWidth < MIN_RULE) {
			this.bottomBorder = this.borderColor("╰───") + super.renderBottomBorder(width, hiddenLineCount) + this.borderColor("─╯");
		} else {
			// Pi draws its part of the rule (scroll hint) narrower, leaving room for the label.
			const rule = super.renderBottomBorder(width - labelWidth, hiddenLineCount);
			this.bottomBorder = `${this.borderColor("╰───")} ${label} ${rule}${this.borderColor("─╯")}`;
		}
		return this.bottomBorder;
	}

	/** Mouse clicks (fullscreen mode) arrive in frame coordinates; the editor expects text coordinates. */
	override handleMouse(event: TuiMouseEvent): TuiMouseEventResult | undefined {
		return super.handleMouse({ ...event, x: event.x - LEFT, width: event.width - LEFT - RIGHT });
	}
}
