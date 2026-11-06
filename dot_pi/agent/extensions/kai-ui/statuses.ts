/**
 * Compact footer text for other extensions' status lines (ctx.ui.setStatus()).
 *
 * Extensions set a key and some text, usually in their own words and colours
 * ("LSP Inactive", "2 running agents"). A rule below, found by key, turns that
 * into an icon and a short value. Statuses without a rule are shown as they are.
 *
 * pi-usage-bar's quota gauge is not shown here: quotaSegment() puts its bar and percentage on the
 * footer's right side, with the context and cost widgets (see footer.ts).
 *
 * To restyle another extension, add a rule keyed by the name it passes to
 * setStatus(); `text` is its message without colour codes.
 */

import type { Theme } from "@earendil-works/pi-coding-agent";
import { icons } from "./icons.ts";
import { type CatppuccinColor, paint } from "./palette.ts";
import { progressBar } from "./widgets.ts";

interface StatusRule {
	/** The coloured replacement for `raw`, which still has the extension's own colours; `text` has none. */
	(theme: Theme, text: string, raw: string): string | undefined;
}

const ANSI = /\u001b\[[0-9;]*m/g;

/** An icon, in a colour, with an optional value after it. */
function badge(theme: Theme, color: CatppuccinColor, icon: string, value?: string | number): string {
	return paint(theme, color, value === undefined ? icon : `${icon} ${value}`);
}

/** How many cells pi-blackhole draws its gauges with. */
const GAUGE_CELLS = 8;

/** The key pi-usage-bar passes to setStatus(): a memory chip glyph. */
const QUOTA_KEY = "\u{f035b}";

const RULES: Record<string, StatusRule> = {
	// pi-lens: "LSP Active (2)" or "LSP Inactive" become "</> LSP 2" (green) and "</> LSP 0" (grey).
	"pi-lens-lsp": (theme, text) => {
		const count = text.match(/Active \((\d+)\)/)?.[1];
		return count ? badge(theme, "green", icons.lsp, `LSP ${count}`) : badge(theme, "subtext", icons.lsp, "LSP 0");
	},

	// pi-subagents: "2 running, 1 queued agents" becomes the people icon and the running count, "+1" for the queue.
	subagents: (theme, text) => {
		const running = text.match(/(\d+) running/)?.[1] ?? "0";
		const queued = text.match(/(\d+) queued/)?.[1];
		return badge(theme, "pink", icons.agents, queued ? `${running}+${queued}` : running);
	},

	// pi-blackhole: a broom, its three gauges (O, P, X) as progress bars, then its workers as they are.
	blackhole: (theme, text, raw) => {
		const gauges = [...text.matchAll(/([A-Z])▕(█*)░*▏/g)].map(([, name, filled]) => {
			const cells = filled!.length;
			const color: CatppuccinColor = cells >= GAUGE_CELLS ? "red" : cells >= 6 ? "yellow" : "green";
			return `${paint(theme, "subtext", name!)} ${progressBar(theme, cells / GAUGE_CELLS, 6, color)}`;
		});
		if (gauges.length === 0) return undefined;
		// Whatever follows the last gauge (the workers), minus the colour reset that closed it.
		const workers = raw.slice(raw.lastIndexOf("▏") + 1).replace(/^(\u001b\[[0-9;]*m)+/, "");
		return `${paint(theme, "green", icons.cleanup)} ${gauges.join("  ")}${workers}`;
	},

	// pi-listen: idle "MIC LOCAL" becomes a mic and the mode; while holding, recording or transcribing the
	// input box's top rule shows it instead (see voice.ts), so the footer says nothing.
	voice: (theme, text) => {
		const mode = text.match(/^MIC (LOCAL|STREAM|SETUP)$/)?.[1];
		return mode ? badge(theme, mode === "SETUP" ? "yellow" : "subtext", icons.mic, mode.toLowerCase()) : "";
	},

	// pi-usage-bar: moved to the footer's right side when it has a bar and a percentage (not for DeepInfra's balance).
	[QUOTA_KEY]: (theme, text) => (parseQuota(theme, text) ? "" : undefined),
};

/**
 * Quota left as a progress bar and a percentage, from pi-usage-bar's text ("▓▓▓░░ Copilot 42%"); for
 * DeepInfra, which has a balance instead, the dollar amount ("$3.00", or "$1.20 owed" in red).
 */
function parseQuota(theme: Theme, text: string): string | undefined {
	if (text.startsWith("DeepInfra")) {
		const [, amount, state] = text.match(/\$([\d.]+) (available|owed)/) ?? [];
		if (!amount) return undefined;
		return state === "owed" ? paint(theme, "red", `${icons.quota} $${amount} owed`) : paint(theme, "green", `${icons.quota} $${amount}`);
	}
	const percent = text.match(/(\d+)%/)?.[1];
	const filled = text.match(/▓/g)?.length ?? 0;
	if (percent === undefined || !/[▓░]/.test(text)) return undefined;
	const left = Number(percent);
	const color: CatppuccinColor = left < 15 ? "red" : left <= 50 ? "yellow" : "green";
	return `${paint(theme, color, icons.quota)} ${progressBar(theme, filled / 10, 10, color)} ${paint(theme, color, `${left}%`)}`;
}

/** The usage quota for the footer, from the extension statuses; undefined when there is none to show. */
export function quotaSegment(theme: Theme, statuses: ReadonlyMap<string, string>): string | undefined {
	const text = statuses.get(QUOTA_KEY);
	return text ? parseQuota(theme, text.replace(ANSI, "")) : undefined;
}

/** The footer text for one status: the rule's version if there is one, otherwise the extension's own text. */
export function statusSegment(theme: Theme, key: string, raw: string): string | undefined {
	if (!raw) return undefined;
	const rule = Object.hasOwn(RULES, key) ? RULES[key] : undefined;
	return rule?.(theme, raw.replace(ANSI, ""), raw) ?? raw;
}
