import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";

type Gauge = { label: string; used: number; limit: number; updatedAt: number };
const REFRESH_MS = 120_000;
const CACHE_FILE = join(homedir(), ".cache", "pi-usage-bar.json");
const AUTH_FILE = join(homedir(), ".pi", "agent", "auth.json");
const gauges = new Map<string, Gauge>();

function loadCache() {
	try {
		const saved = JSON.parse(readFileSync(CACHE_FILE, "utf8")) as Record<string, Gauge>;
		for (const [key, value] of Object.entries(saved)) {
			if (value && Number.isFinite(value.used) && Number.isFinite(value.limit) && value.limit > 0) gauges.set(key, value);
		}
	} catch { /* A missing or corrupt cache is harmless. */ }
}

function saveCache() {
	try {
		mkdirSync(join(homedir(), ".cache"), { recursive: true });
		writeFileSync(CACHE_FILE, JSON.stringify(Object.fromEntries(gauges)), "utf8");
	} catch { /* Cache is best effort. */ }
}

function providerOf(model: unknown): string {
	const value = model as { provider?: unknown; id?: unknown } | undefined;
	return String(value?.provider ?? value?.id ?? "").toLowerCase();
}

async function openRouterGauge(): Promise<Gauge | undefined> {
	const key = process.env.OPENROUTER_API_KEY;
	if (!key) return undefined;
	try {
		const response = await fetch("https://openrouter.ai/api/v1/auth/key", {
			headers: { Authorization: "Bearer " + key },
			signal: AbortSignal.timeout(8_000),
		});
		if (!response.ok) return undefined;
		const body = await response.json() as { data?: { limit?: number | null; limit_remaining?: number | null } };
		const data = body.data;
		if (!data || typeof data.limit !== "number" || data.limit <= 0 || typeof data.limit_remaining !== "number") return undefined;
		return { label: "OpenRouter", used: Math.max(0, data.limit - data.limit_remaining), limit: data.limit, updatedAt: Date.now() };
	} catch { return undefined; }
}

async function copilotGauge(): Promise<Gauge | undefined> {
	try {
		const auth = JSON.parse(readFileSync(AUTH_FILE, "utf8")) as Record<string, Record<string, unknown>>;
		const token = (auth["github-copilot"]?.refresh ?? auth["github-copilot"]?.access) as string | undefined;
		if (!token) return undefined;
		const response = await fetch("https://api.github.com/copilot_internal/user", {
			headers: { authorization: "Bearer " + token, "user-agent": "pi-usage-bar" },
			signal: AbortSignal.timeout(8_000),
		});
		if (!response.ok) return undefined;
		const body = await response.json() as { quota_snapshots?: { premium_interactions?: { percent_remaining?: number; unlimited?: boolean } } };
		const quota = body?.quota_snapshots?.premium_interactions;
		if (!quota || quota.unlimited || typeof quota.percent_remaining !== "number") return undefined;
		return { label: "Copilot", used: 100 - quota.percent_remaining, limit: 100, updatedAt: Date.now() };
	} catch { return undefined; }
}

async function anthropicGauge(): Promise<Gauge | undefined> {
	// Claude Code's /usage command uses this OAuth-only internal endpoint.  The
	// public organizations/usage endpoint is billing/API-key usage, not Pro/Max
	// plan quota, and does not return the shape needed by this gauge.
	try {
		const auth = JSON.parse(readFileSync(AUTH_FILE, "utf8")) as Record<string, Record<string, unknown>>;
		const token = auth["anthropic"]?.access as string | undefined;
		if (!token) return undefined;

		const response = await fetch("https://api.anthropic.com/api/oauth/usage", {
			headers: {
				authorization: "Bearer " + token,
				"anthropic-beta": "oauth-2025-04-20",
				"anthropic-dangerous-direct-browser-access": "true",
				"user-agent": "claude-code/1.0.0",
			},
			signal: AbortSignal.timeout(8_000),
		});
		if (!response.ok) return undefined;

		// The endpoint returns windows such as five_hour and seven_day, each with
		// utilization as a percentage (and resets_at). Pick the most-used window.
		const body = await response.json() as Record<string, unknown>;
		const windows = Object.values(body).filter((value): value is { utilization?: unknown } =>
			typeof value === "object" && value !== null && "utilization" in value,
		);
		const utilization = windows
			.map((window) => typeof window.utilization === "number" ? window.utilization : undefined)
			.filter((value): value is number => value !== undefined && Number.isFinite(value));
		const used = utilization.length ? Math.max(...utilization) : undefined;
		return used === undefined ? undefined : { label: "Claude", used, limit: 100, updatedAt: Date.now() };
	} catch { return undefined; }
}

async function refresh(model: unknown) {
	const provider = providerOf(model);
	try {
		if (provider.includes("openrouter")) {
			const gauge = await openRouterGauge();
			if (gauge) gauges.set("openrouter", gauge);
		} else if (provider.includes("copilot") || provider.includes("github")) {
			const gauge = await copilotGauge();
			if (gauge) gauges.set("copilot", gauge);
		} else if (provider.includes("anthropic") || provider.includes("claude")) {
			const gauge = await anthropicGauge();
			if (gauge) gauges.set("anthropic", gauge);
		}
		saveCache();
	} catch { /* Never let a quota provider affect the agent. */ }
}

function renderGauge(gauge: Gauge, theme: any): string {
	const percent = Math.max(0, Math.min(100, (gauge.used / gauge.limit) * 100));
	const color = percent > 85 ? "error" : percent >= 50 ? "warning" : "success";
	const filled = Math.round(percent / 10);
	const bar = "▓".repeat(filled) + "░".repeat(10 - filled);
	return `${theme.fg(color, bar)} ${gauge.label} ${percent.toFixed(0)}%`;
}

export default function (pi: ExtensionAPI) {
	loadCache();
	let timer: ReturnType<typeof setInterval> | undefined;

	pi.on("session_start", (_event, ctx) => {
		ctx.ui.setFooter((tui, theme) => {
			let disposed = false;
			const update = () => {
				if (!disposed) {
					void refresh(ctx.model).then(() => tui.requestRender()).catch(() => undefined);
				}
			};
			update();
			timer = setInterval(update, REFRESH_MS);
			return {
				dispose() { disposed = true; if (timer) clearInterval(timer); },
				invalidate() {},
				render(width: number): string[] {
					const provider = providerOf(ctx.model);
					const key = provider.includes("openrouter") ? "openrouter" : provider.includes("copilot") || provider.includes("github") ? "copilot" : provider.includes("anthropic") || provider.includes("claude") ? "anthropic" : "";
					const gauge = key ? gauges.get(key) : undefined;
					if (!gauge) return [""];
					return [truncateToWidth("  " + renderGauge(gauge, theme), Math.max(1, width))];
				},
			};
		});
	});
}