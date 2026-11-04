/**
 * Turn telemetry: tokens per second and time to first token for the last
 * model response, and how long the current (or last) agent run took.
 *
 * index.ts feeds this from Pi's lifecycle events; the footer reads it.
 */

export class TurnStats {
	/** Output tokens per second of the last response, once it finished. */
	tokensPerSecond: number | undefined;
	/** Time from the start of the last turn to its first streamed token. */
	timeToFirstTokenMs: number | undefined;

	private runStartedAt: number | undefined;
	private runEndedAt: number | undefined;
	private turnStartedAt: number | undefined;
	private firstTokenAt: number | undefined;

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
	}

	/** Called on each streamed delta. */
	sawToken(): void {
		if (this.firstTokenAt !== undefined || this.turnStartedAt === undefined) return;
		this.firstTokenAt = Date.now();
		this.timeToFirstTokenMs = this.firstTokenAt - this.turnStartedAt;
	}

	/** Called when an assistant message ends, with its output token count. */
	finishResponse(outputTokens: number): void {
		if (this.firstTokenAt === undefined) return;
		const seconds = (Date.now() - this.firstTokenAt) / 1000;
		// Very short responses give meaningless rates.
		if (seconds >= 0.25 && outputTokens > 0) this.tokensPerSecond = outputTokens / seconds;
	}

	/** Length of the current run while it's going, or of the last one afterwards. */
	get runDurationMs(): number | undefined {
		if (this.runStartedAt === undefined) return undefined;
		return (this.runEndedAt ?? Date.now()) - this.runStartedAt;
	}
}
