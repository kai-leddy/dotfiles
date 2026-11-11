/**
 * Live subagent rows for codemode cards.
 *
 * pi-subagents streams a foreground run's progress through its own tool call's update callback,
 * and shows background runs in a widget above the input box. A subagent started from a codemode
 * script has neither: the script's card only lists it as a nested call that says "running".
 * These rows fill that gap. They read the running agents from pi-subagents' service (which it
 * publishes on globalThis) and redraw on a short timer while a subagent call is in flight.
 *
 *   󰯁 codemode  2 calls  14s
 *     ⋯ subagent  Test model co-author commit
 *       ⠋ general-purpose  Test model co-author commit · 4 tool uses · 5.4k tokens · 12s
 */

import type { Theme } from "@earendil-works/pi-coding-agent";
import { type Component, truncateToWidth } from "@earendil-works/pi-tui";
import { formatCount, formatDuration } from "./format.ts";
import { spinner } from "./icons.ts";
import { paint } from "./palette.ts";

/** Where pi-subagents publishes its service (Symbol.for, so the key matches across module copies). */
const SERVICE_KEY = Symbol.for("@gotgenes/pi-subagents:service");

/** Nested calls that mean "a subagent is running": the live rows show while one is in flight. */
export const LIVE_CALLS: ReadonlySet<string> = new Set(["subagent", "get_subagent_result", "steer_subagent"]);

/** Most agents shown at once. */
const MAX_ROWS = 3;
/** Redraw interval, the same as the working spinner. */
const FRAME_MS = 80;
/** Redraws with nothing running before the timer stops itself (a safety net if the final update never arrives). */
const IDLE_FRAMES = 50;

/** The fields of pi-subagents' SubagentRecord that the rows read. */
interface LiveAgent {
	type: string;
	description: string;
	status: string;
	toolUses: number;
	startedAt: number;
	lifetimeUsage?: { input: number; output: number; cacheWrite: number };
}

/** Agents that are running or waiting for a slot, newest first. Empty if pi-subagents isn't loaded. */
export function liveAgents(): LiveAgent[] {
	try {
		const service = (globalThis as Record<symbol, unknown>)[SERVICE_KEY] as { listAgents?: () => LiveAgent[] } | undefined;
		return service?.listAgents?.().filter((agent) => agent.status === "running" || agent.status === "queued").slice(0, MAX_ROWS) ?? [];
	} catch {
		return [];
	}
}

/** The rows themselves. They read the agents at render time, so a redraw is all they need to stay current. */
export class LiveAgentRows implements Component {
	constructor(private readonly theme: Theme) {}

	render(width: number): string[] {
		const { theme } = this;
		const frame = spinner[Math.floor(Date.now() / FRAME_MS) % spinner.length]!;
		return liveAgents().map((agent) => {
			const queued = agent.status === "queued";
			const usage = agent.lifetimeUsage;
			const tokens = usage ? usage.input + usage.output + usage.cacheWrite : 0;
			const dot = paint(theme, "overlay", " \u00b7 ");
			const meta = [
				queued ? paint(theme, "subtext", "queued") : paint(theme, "subtext", agent.toolUses + (agent.toolUses === 1 ? " tool use" : " tool uses")),
				tokens > 0 && paint(theme, "subtext", formatCount(tokens) + " tokens"),
				paint(theme, "overlay", formatDuration(Date.now() - agent.startedAt)),
			].filter(Boolean);
			const line =
				"    " + paint(theme, "pink", queued ? "\u22ef" : frame) + " " + paint(theme, "pink", agent.type) + " " + agent.description + dot + meta.join(dot);
			return truncateToWidth(line, width, "\u2026");
		});
	}

	invalidate(): void {}
}

/** Holds the redraw timer for one tool row. */
export interface Ticker {
	ticker?: ReturnType<typeof setInterval>;
}

/** Start the redraw timer when `want` and it isn't running; stop it when not `want`. */
export function syncTicker(holder: Ticker, want: boolean, redraw: () => void): void {
	if (!want) {
		if (holder.ticker) clearInterval(holder.ticker);
		holder.ticker = undefined;
		return;
	}
	if (holder.ticker) return;
	let idle = 0;
	const timer = setInterval(() => {
		idle = liveAgents().length === 0 ? idle + 1 : 0;
		if (idle > IDLE_FRAMES) {
			clearInterval(timer);
			holder.ticker = undefined;
			return;
		}
		redraw();
	}, FRAME_MS);
	(timer as { unref?: () => void }).unref?.();
	holder.ticker = timer;
}
