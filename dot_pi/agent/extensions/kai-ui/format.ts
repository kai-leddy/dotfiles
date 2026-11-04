/** Small text helpers shared by the header, footer and tool rows. */

import { homedir } from "node:os";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

/** `/Users/kai/src/x` -> `~/src/x` */
export function shortenPath(path: string): string {
	const home = homedir();
	return path === home || path.startsWith(`${home}/`) ? `~${path.slice(home.length)}` : path;
}

/** 950 -> "950", 12_345 -> "12k", 1_234_567 -> "1.2M" */
export function formatCount(n: number): string {
	if (n < 1000) return `${n}`;
	if (n < 10_000) return `${(n / 1000).toFixed(1)}k`;
	if (n < 1_000_000) return `${Math.round(n / 1000)}k`;
	return `${(n / 1_000_000).toFixed(1)}M`;
}

/** 40 -> "40ms", 1234 -> "1.2s", 75_000 -> "1m 15s" */
export function formatDuration(ms: number): string {
	if (ms < 1000) return `${Math.round(ms)}ms`;
	if (ms < 10_000) return `${(ms / 1000).toFixed(1)}s`;
	if (ms < 60_000) return `${Math.round(ms / 1000)}s`;
	const minutes = Math.floor(ms / 60_000);
	return `${minutes}m ${Math.round((ms % 60_000) / 1000)}s`;
}

/** Put `left` and `right` on one line of `width` columns, cutting from the right when they don't fit. */
export function spread(left: string, right: string, width: number): string {
	const gap = width - visibleWidth(left) - visibleWidth(right);
	if (gap >= 2) return left + " ".repeat(gap) + right;
	return truncateToWidth(`${left}  ${right}`, width);
}
