/**
 * Which logo goes next to a model name. The rules are tried in order against
 * "provider/model-id" and the first match wins, so a gateway (GitHub Copilot)
 * is listed before the model families it serves. To show a Claude logo for
 * Claude models served by Copilot too, move the GitHub rule below the Claude one.
 *
 * Models with no logo in Nerd Fonts (Mistral, Llama, DeepSeek, Grok...) get
 * the robot from icons.ts.
 */

import { icons } from "./icons.ts";
import type { CatppuccinColor } from "./palette.ts";

export interface Brand {
	icon: string;
	color: CatppuccinColor;
}

const BRANDS: Array<[pattern: RegExp, brand: Brand]> = [
	[/^github/, { icon: "\u{f02a4}", color: "text" }],
	[/claude|anthropic/, { icon: "\uec82", color: "peach" }],
	[/gpt|openai|codex|(^|\/)o\d/, { icon: "\uec81", color: "teal" }],
	[/gemini|gemma|google/, { icon: "\u{f02ad}", color: "blue" }],
	[/azure/, { icon: "\uebd8", color: "sapphire" }],
	[/bedrock|amazon|nova/, { icon: "\u{f0e0f}", color: "yellow" }],
];

const FALLBACK: Brand = { icon: icons.model, color: "subtext" };

export function brandOf(provider: string, modelId: string): Brand {
	const name = `${provider}/${modelId}`.toLowerCase();
	return BRANDS.find(([pattern]) => pattern.test(name))?.[1] ?? FALLBACK;
}
