import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

type Gauge = { label: string; used: number; limit: number; updatedAt: number };
const REFRESH_MS = 120_000;
const CACHE_FILE = join(homedir(), ".cache", "pi-usage-bar.json");
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

function envGauge(prefix: string, label: string): Gauge | undefined {
	const used = Number(process.env[`${prefix}_USED`]);
	const limit = Number(process.env[`${prefix}_LIMIT`]);
	return Number.isFinite(used) && Number.isFinite(limit) && limit > 0 ? { label, used: Math.max(0, used), limit, updatedAt: Date.now() } : undefined;
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
			headers: { Authorization: `Bearer ${key}` },
			signal: AbortSignal.timeout(8_000),
		});
		if (!response.ok) return undefined;
		const body = await response.json() as { data?: { limit?: number | null; limit_remaining?: number | null } };
		const data = body.data;
		if (!data || typeof data.limit !== "number" || data.limit <= 0 || typeof data.limit_remaining !== "number") return undefined;
		return { label: "OpenRouter", used: Math.max(0, data.limit - data.limit_remaining), limit: data.limit, updatedAt: Date.now() };
	} catch { return undefined; }
}

async function refresh(model: unknown) {
	const provider = providerOf(model);
	try {
		if (provider.includes("openrouter")) {
			const gauge = await openRouterGauge();
			if (gauge) gauges.set("openrouter", gauge);
		} else if (provider.includes("copilot") || provider.includes("github")) {
			const gauge = envGauge("GITHUB_COPILOT_QUOTA", "Copilot");
			if (gauge) gauges.set("copilot", gauge);
		} else if (provider.includes("anthropic") || provider.includes("claude")) {
			const gauge = envGauge("ANTHROPIC_QUOTA", "Claude");
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
				dispose() {
				disposed = true;
				if (timer) clearInterval(timer);
			},
				invalidate() {},
				render(width: number): string[] {
					const provider = providerOf(ctx.model);
					const key = provider.includes("openrouter") ? "openrouter" : provider.includes("copilot") || provider.includes("github") ? "copilot" : provider.includes("anthropic") || provider.includes("claude") ? "anthropic" : "";
					const gauge = key ? gauges.get(key) : undefined;
					if (!gauge) return [""];
					const content = renderGauge(gauge, theme);
					return [truncateToWidth("  " + content, Math.max(1, width))];
				},
			};
		});
	});
}
