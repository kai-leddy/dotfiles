/**
 * Small graphics built from text: pills, a progress bar and a sparkline.
 * Each returns a coloured string.
 */

import type { Theme } from "@earendil-works/pi-coding-agent";
import { icons, progress } from "./icons.ts";
import { type CatppuccinColor, paint } from "./palette.ts";

/**
 * `content` on a rounded background, like a status-bar pill. Colours
 * inside `content` are fine; only foreground colours should be used there,
 * because a background reset would end the pill early.
 */
export function pill(theme: Theme, content: string): string {
	const cap = (glyph: string) => theme.style(glyph, { fg: theme.colors.selectedBg });
	return cap(icons.pillLeft) + theme.bg("selectedBg", ` ${content} `) + cap(icons.pillRight);
}

/** Nerd Fonts' progress bar, `cells` wide, filled for `fraction` (0 to 1), rounded to the nearest cell. */
export function progressBar(theme: Theme, fraction: number, cells: number, color: CatppuccinColor): string {
	const filled = Math.round(Math.min(1, Math.max(0, fraction)) * cells);
	let bar = "";
	for (let i = 0; i < cells; i++) {
		const piece = i === 0 ? 0 : i === cells - 1 ? 2 : 1; // left end, middle, right end
		bar += i < filled ? paint(theme, color, progress.filled[piece]) : paint(theme, "overlay", progress.empty[piece]);
	}
	return bar;
}

// Nerd Fonts has no sparkline glyphs, so these are Unicode block elements.
const SPARKS = ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"];

/** `▂▄▆█▅`: one character per value, scaled to the largest. */
export function sparkline(theme: Theme, values: number[], color: CatppuccinColor): string {
	const max = Math.max(...values);
	if (values.length === 0 || max <= 0) return "";
	return paint(theme, color, values.map((v) => SPARKS[Math.round((v / max) * (SPARKS.length - 1))]).join(""));
}
