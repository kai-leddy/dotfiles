/**
 * Turn telemetry: tokens per second and time to first token for the last
 * model response, and how long the current (or last) agent run took.
 *
 * index.ts feeds this from Pi's lifecycle events; the footer reads it.
 */

const HISTORY_LENGTH = 10;
/** Rough characters per output token, for the live estimate before the provider reports an exact count. */
const CHARS_PER_TOKEN = 4;
/** Seconds of streaming before the live rate is shown. */
const LIVE_MIN_SECONDS = 0.3;

export class TurnStats {
	/** Output tokens per second of the current response so far (estimated while it streams), then of the last one once it finished. */
	tokensPerSecond: number | undefined;
	/** Time from the start of the last turn to its first streamed token. */
	timeToFirstTokenMs: number | undefined;
	/** Tokens per second of recent responses, oldest first, for the sparkline. */
	readonly speedHistory: number[] = [];

	private runStartedAt: number | undefined;
	private runEndedAt: number | undefined;
	private turnStartedAt: number | undefined;
	private firstTokenAt: number | undefined;
	/** Characters streamed in the current response, for the live estimate. */
	private streamedChars = 0;
	/** Output tokens the provider has reported so far for the current response, if it reports them mid-stream. */
	private reportedTokens = 0;

	/** Called on `agent_start`. Pi can start several low-level runs before it settles; they count as one. */
	startRun(): void {
		if (this.runStartedAt !== undefined && this.runEndedAt === undefined) return;
		this.runStartedAt = Date.now();
		this.runEndedAt = undefined;
	}

	/** Called on `agent_settled`, when Pi has no more automatic work. */
	endRun(): void {
		if (this.runStartedAt !== undefined) this.runEndedAt ??= Date.now();
	}

	/** Called on `turn_start`, just before the model request. */
	startTurn(): void {
		this.turnStartedAt = Date.now();
		this.firstTokenAt = undefined;
		this.streamedChars = 0;
		this.reportedTokens = 0;
	}

	/**
	 * Called on each streamed delta with its text and the output token count the provider has reported
	 * so far (0 if it only reports at the end). Updates tokensPerSecond live, so the figure moves while
	 * the response streams instead of once at the end.
	 */
	sawToken(delta = "", reportedTokens = 0): void {
		if (this.turnStartedAt === undefined) return;
		const now = Date.now();
		if (this.firstTokenAt === undefined) {
			this.firstTokenAt = now;
			this.timeToFirstTokenMs = now - this.turnStartedAt;
		}
		this.streamedChars += delta.length;
		this.reportedTokens = Math.max(this.reportedTokens, reportedTokens);
		const seconds = (now - this.firstTokenAt) / 1000;
		// Too little data early on gives wild rates.
		if (seconds < LIVE_MIN_SECONDS) return;
		const tokens = Math.max(this.reportedTokens, this.streamedChars / CHARS_PER_TOKEN);
		if (tokens > 0) this.tokensPerSecond = tokens / seconds;
	}

	/** Called when an assistant message ends, with its output token count. */
	finishResponse(outputTokens: number): void {
		if (this.firstTokenAt === undefined) return;
		const seconds = (Date.now() - this.firstTokenAt) / 1000;
		// Very short responses give meaningless rates.
		if (seconds < 0.25 || outputTokens === 0) return;
		this.tokensPerSecond = outputTokens / seconds;
		this.speedHistory.push(this.tokensPerSecond);
		if (this.speedHistory.length > HISTORY_LENGTH) this.speedHistory.shift();
	}

	/** Length of the current run while it's going, or of the last one afterwards. */
	get runDurationMs(): number | undefined {
		if (this.runStartedAt === undefined) return undefined;
		return (this.runEndedAt ?? Date.now()) - this.runStartedAt;
	}
}
