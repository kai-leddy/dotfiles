/** A rounded frame around the actual editor, including pi-vim when available. */
import type { CustomEditor } from "@earendil-works/pi-coding-agent";
import { sliceByColumn, truncateToWidth, visibleWidth, type TuiMouseEvent } from "@earendil-works/pi-tui";
import { stripVTControlCharacters } from "node:util";
import { icons } from "./icons.ts";

const LEFT = 4;
const RIGHT = 2;
const MIN_RULE = 20;

type Label = (maxWidth: number) => string | undefined;

/**
 * Replace only an uninterrupted run of border dashes. This leaves Vim's mode
 * label and Pi's scroll hints intact, even when either is on the other edge.
 */
function putLabel(line: string, label: string | undefined, side: "left" | "right"): string {
	if (!label) return line;
	const text = stripVTControlCharacters(line);
	const width = visibleWidth(label) + 2;
	if (visibleWidth(line) - width < MIN_RULE) return line;
	const runs = [...text.matchAll(/─+/g)].filter((match) => match[0].length >= width);
	const run = side === "left" ? runs[0] : runs[runs.length - 1];
	if (!run || run.index === undefined) return line;
	// The prefix may contain wide characters (for example an EX command).
	const start = visibleWidth(text.slice(0, run.index)) + (side === "right" ? run[0].length - width : 0);
	return sliceByColumn(line, 0, start) + ` ${label} ` + sliceByColumn(line, start + width, visibleWidth(line) - start - width);
}

/**
 * Decorate the same editor instance Pi will configure and focus. The protected
 * border hook is observed only to locate the bottom rule before autocomplete;
 * input, focus, callbacks, Vim state and cursor handling stay on the original.
 */
export function frameEditor(editor: CustomEditor, topRight: Label, bottomLeft: Label, topLeft: Label): CustomEditor {
	const border = editor as unknown as { renderBottomBorder(width: number, hidden: number): string };
	const originalBottom = border.renderBottomBorder;
	const originalRender = editor.render;
	const originalMouse = editor.handleMouse;
	let bottomRule = "";
	let framed = false;

	border.renderBottomBorder = function (width, hidden) {
		bottomRule = originalBottom.call(editor, width, hidden);
		return bottomRule;
	};
	editor.render = function (width) {
		framed = width >= LEFT + RIGHT + 1;
		if (!framed) return originalRender.call(editor, width).map((line) => truncateToWidth(line, width, ""));
		const innerWidth = width - LEFT - RIGHT;
		const lines = originalRender.call(editor, innerWidth);
		let bottom = lines.indexOf(bottomRule, 1);
		// With a non-default Vim label position, the plugin may change the bottom
		// rule itself. Its default label position is only safe without completion.
		if (bottom < 0 && !editor.isShowingAutocomplete()) bottom = lines.length - 1;
		if (bottom < 1) {
			framed = false;
			return originalRender.call(editor, width).map((line) => truncateToWidth(line, width, ""));
		}

		const top = putLabel(putLabel(lines[0]!, topLeft(Math.max(0, innerWidth - MIN_RULE - 2)), "left"),
			topRight(Math.max(0, innerWidth - MIN_RULE - 2)), "right");
		const bottomLine = putLabel(lines[bottom]!, bottomLeft(Math.max(0, innerWidth - MIN_RULE - 2)), "left");
		const side = editor.borderColor("│");
		return lines.map((line, i) => {
			let result: string;
			if (i === 0) result = editor.borderColor("╭───") + top + editor.borderColor("─╮");
			else if (i === bottom) result = editor.borderColor("╰───") + bottomLine + editor.borderColor("─╯");
			else if (i > bottom) result = " ".repeat(LEFT) + line;
			else result = `${side} ${i === 1 ? editor.borderColor(icons.prompt) : " "} ${line} ${side}`;
			return truncateToWidth(result, width, "");
		});
	};
	editor.handleMouse = function (event: TuiMouseEvent) {
		return originalMouse.call(editor, framed ? { ...event, x: event.x - LEFT, width: event.width - LEFT - RIGHT } : event);
	};
	return editor;
}
