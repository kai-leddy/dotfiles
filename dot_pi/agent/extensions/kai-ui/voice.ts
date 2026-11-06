/**
 * pi-listen's hold-to-talk indicator, drawn on the input box's top rule instead of the island widget
 * pi-listen mounts below the editor (that widget grows and shrinks the screen when you hold space).
 *
 * pi-listen talks to the UI through two calls on the shared `ctx.ui` object: setWidget("voice-recording")
 * and setStatus("voice", text). attachVoice() wraps both: the widget is dropped, and the status text is
 * parsed into a state that the editor draws in a fixed-width label, so nothing moves.
 *
 *   hold space:   󰍬 ▰▰▰▱▱▱▱▱ hold        recording:  󰍬 ⣀⣤⣶⣿⣶⣤⣀ 0:03        done:  󰍬 transcribing
 *
 * The footer keeps only the idle "MIC LOCAL" chip, as an icon (see statuses.ts).
 */

import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join as joinPath } from "node:path";
import type { ExtensionUIContext, Theme } from "@earendil-works/pi-coding-agent";
import { icons } from "./icons.ts";
import { paint } from "./palette.ts";
import { progressBar } from "./widgets.ts";

type VoiceState = "none" | "warmup" | "recording" | "transcribing";

const ANSI = /\u001b\[[0-9;]*m/g;
const WIDGET_KEY = "voice-recording";
const STATUS_KEY = "voice";
const DEFAULT_HOLD_MS = 700;
/** A hold shorter than this never shows, so ordinary spaces don't flicker the rule. */
const WARMUP_GRACE_MS = 150;
const FRAME_MS = 100;
const WAVE = ["⣀", "⣤", "⣶", "⣿", "⣶", "⣤"];
const WAVE_CELLS = 8;

/** Where pi-listen's current state is, parsed from its status text, with a timer for the animation. */
export class VoiceIndicator {
	state: VoiceState = "none";
	/** Called when the label changed; the editor points this at tui.requestRender. */
	onChange: (() => void) | undefined;

	private since = 0;
	private holdMs = DEFAULT_HOLD_MS;
	private timer: ReturnType<typeof setInterval> | undefined;

	/** Feed pi-listen's status text ("REC 3s ██░░", "MIC HOLD...", "STT...", "MIC LOCAL", or empty). */
	setStatus(raw: string | undefined): void {
		const text = (raw ?? "").replace(ANSI, "").trim();
		const next: VoiceState = text.startsWith("MIC HOLD")
			? "warmup"
			: text.startsWith("REC")
				? "recording"
				: text.startsWith("STT")
					? "transcribing"
					: "none";
		if (next === this.state) return;
		this.state = next;
		this.since = Date.now();
		if (next === "warmup") this.holdMs = readHoldMs();
		if (next === "warmup" || next === "recording") this.startTimer();
		else this.stopTimer();
		this.onChange?.();
	}

	reset(): void {
		this.state = "none";
		this.stopTimer();
	}

	/** The coloured label for the top rule, or undefined when pi-listen is idle. */
	label(theme: Theme): string | undefined {
		const elapsed = Date.now() - this.since;
		const mic = (color: "mauve" | "red" | "yellow") => paint(theme, color, icons.mic);
		switch (this.state) {
			case "warmup":
				if (elapsed < WARMUP_GRACE_MS) return undefined;
				return `${mic("mauve")} ${progressBar(theme, elapsed / this.holdMs, WAVE_CELLS, "mauve")} ${paint(theme, "subtext", "hold")}`;
			case "recording": {
				const tick = Math.floor(elapsed / FRAME_MS);
				const wave = Array.from({ length: WAVE_CELLS }, (_, i) => WAVE[(tick + i) % WAVE.length]).join("");
				const secs = Math.floor(elapsed / 1000);
				const time = `${Math.floor(secs / 60)}:${String(secs % 60).padStart(2, "0")}`;
				return `${mic("red")} ${paint(theme, "red", wave)} ${paint(theme, "text", time)}`;
			}
			case "transcribing":
				return `${mic("yellow")} ${paint(theme, "yellow", "transcribing")}`;
			default:
				return undefined;
		}
	}

	private startTimer(): void {
		if (this.timer) return;
		this.timer = setInterval(() => this.onChange?.(), FRAME_MS);
		this.timer.unref?.();
	}

	private stopTimer(): void {
		if (this.timer) clearInterval(this.timer);
		this.timer = undefined;
	}
}

/** pi-listen's `voice.holdThresholdMs` setting, bounded the way pi-listen bounds it. */
function readHoldMs(): number {
	try {
		const settings = JSON.parse(readFileSync(joinPath(homedir(), ".pi/agent/settings.json"), "utf8"));
		const ms = settings?.voice?.holdThresholdMs;
		return typeof ms === "number" && ms >= 200 && ms <= 3000 ? ms : DEFAULT_HOLD_MS;
	} catch {
		return DEFAULT_HOLD_MS;
	}
}

const ORIGINALS = Symbol.for("kai-ui.voice.originals");
type Patchable = ExtensionUIContext & { [ORIGINALS]?: Pick<ExtensionUIContext, "setWidget" | "setStatus"> };

/**
 * Wrap setWidget and setStatus on the shared UI object. Safe to call again after /reload: it always
 * wraps the original functions, never an earlier wrapper.
 */
export function attachVoice(ui: ExtensionUIContext, voice: VoiceIndicator): void {
	const target = ui as Patchable;
	const original = (target[ORIGINALS] ??= { setWidget: ui.setWidget, setStatus: ui.setStatus });
	target.setWidget = ((key: string, ...rest: unknown[]) => {
		if (key === WIDGET_KEY) return; // the island below the editor; drawn on the input's top-left rule instead
		return (original.setWidget as (...args: unknown[]) => void).call(ui, key, ...rest);
	}) as ExtensionUIContext["setWidget"];
	target.setStatus = ((key: string, text: string | undefined) => {
		if (key === STATUS_KEY) voice.setStatus(text);
		return original.setStatus.call(ui, key, text);
	}) as ExtensionUIContext["setStatus"];
}

/** Put the original setWidget and setStatus back. */
export function detachVoice(ui: ExtensionUIContext, voice: VoiceIndicator): void {
	const target = ui as Patchable;
	const original = target[ORIGINALS];
	if (original) {
		target.setWidget = original.setWidget;
		target.setStatus = original.setStatus;
		delete target[ORIGINALS];
	}
	voice.reset();
}
