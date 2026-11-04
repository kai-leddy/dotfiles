/**
 * Catppuccin colours, taken from the active Pi theme.
 *
 * Pi themes only expose semantic tokens (accent, success, ...), not raw
 * colours. Each Catppuccin name below points at a token that
 * ~/.pi/agent/themes/catppuccin-mocha.json sets to that colour, so this file
 * holds no hex codes and a theme change recolours the whole UI.
 */

import type { Theme, ThemeColor } from "@earendil-works/pi-coding-agent";
import { spinner } from "./icons.ts";

export const catppuccin = {
	mauve: "accent",
	pink: "thinkingXhigh",
	red: "error",
	peach: "mdCode",
	yellow: "warning",
	green: "success",
	teal: "mdLinkUrl",
	sky: "syntaxOperator",
	sapphire: "thinkingLow",
	blue: "toolTitle",
	text: "text",
	subtext: "muted",
	overlay: "dim",
} as const satisfies Record<string, ThemeColor>;

export type CatppuccinColor = keyof typeof catppuccin;

/** Colour `text` with a Catppuccin colour from the active theme. */
export function paint(theme: Theme, color: CatppuccinColor, text: string): string {
	return theme.fg(catppuccin[color], text);
}

const RAINBOW: CatppuccinColor[] = ["mauve", "pink", "peach", "yellow", "green", "sky"];

/** Nerd Fonts' spinner, with its colour walking through the Catppuccin accents, one per frame. */
export function spinnerFrames(theme: Theme): string[] {
	return spinner.map((frame, i) => paint(theme, RAINBOW[i % RAINBOW.length]!, frame));
}
