/**
 * Facts about the working directory for the footer: git status and the
 * project's runtime. Both are read asynchronously, and `onUpdate` fires
 * when either changes so the footer can redraw.
 */

import { existsSync } from "node:fs";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import type { CatppuccinColor } from "./palette.ts";

export interface GitStatus {
	ahead: number;
	behind: number;
	staged: number;
	modified: number;
	untracked: number;
	conflicted: number;
}

export interface Runtime {
	name: string;
	icon: string;
	color: CatppuccinColor;
	version: string | undefined;
}

/**
 * Checked in order; the first runtime with a marker file in the working
 * directory wins. Icons are Nerd Font glyphs.
 */
const RUNTIMES: Array<Omit<Runtime, "version"> & { files: string[]; versionCommand: string[] }> = [
	{ name: "bun", icon: "\ue76f", color: "peach", files: ["bun.lock", "bun.lockb"], versionCommand: ["bun", "--version"] },
	{ name: "deno", icon: "\ue7c0", color: "text", files: ["deno.json", "deno.jsonc"], versionCommand: ["deno", "--version"] },
	{ name: "node", icon: "\ue718", color: "green", files: ["package.json"], versionCommand: ["node", "--version"] },
	{ name: "rust", icon: "\ue7a8", color: "peach", files: ["Cargo.toml"], versionCommand: ["rustc", "--version"] },
	{ name: "go", icon: "\ue626", color: "sky", files: ["go.mod"], versionCommand: ["go", "version"] },
	{
		name: "python",
		icon: "\ue73c",
		color: "yellow",
		files: ["pyproject.toml", "requirements.txt", "setup.py", "uv.lock"],
		versionCommand: ["python3", "--version"],
	},
	{ name: "ruby", icon: "\ue739", color: "red", files: ["Gemfile"], versionCommand: ["ruby", "--version"] },
	{
		name: "java",
		icon: "\ue738",
		color: "red",
		files: ["pom.xml", "build.gradle", "build.gradle.kts"],
		versionCommand: ["java", "--version"],
	},
	{ name: "zig", icon: "\ue6a9", color: "peach", files: ["build.zig"], versionCommand: ["zig", "version"] },
	{ name: "php", icon: "\ue73d", color: "blue", files: ["composer.json"], versionCommand: ["php", "--version"] },
];

export class Project {
	git: GitStatus | undefined;
	runtime: Runtime | undefined;
	onUpdate: (() => void) | undefined;

	private cwd = "";

	constructor(private readonly pi: ExtensionAPI) {}

	/** Forget the old directory and read everything for `cwd`. */
	async load(cwd: string): Promise<void> {
		this.cwd = cwd;
		this.git = undefined;
		this.runtime = undefined;
		await Promise.all([this.refreshGit(), this.detectRuntime()]);
	}

	async refreshGit(): Promise<void> {
		const cwd = this.cwd;
		const result = await this.run(["git", "status", "--porcelain=v2", "--branch"], cwd);
		if (cwd !== this.cwd) return; // the session moved on while git ran
		this.git = result === undefined ? undefined : parseGitStatus(result);
		this.onUpdate?.();
	}

	private async detectRuntime(): Promise<void> {
		const cwd = this.cwd;
		const match = RUNTIMES.find((runtime) => runtime.files.some((file) => existsSync(join(cwd, file))));
		if (!match) return;

		const { files: _files, versionCommand, ...runtime } = match;
		const output = await this.run(versionCommand, cwd);
		if (cwd !== this.cwd) return;
		this.runtime = { ...runtime, version: output?.match(/\d+\.\d+(\.\d+)?/)?.[0] };
		this.onUpdate?.();
	}

	/** Run a command and return its stdout, or undefined when it fails. */
	private async run([command, ...args]: string[], cwd: string): Promise<string | undefined> {
		try {
			const result = await this.pi.exec(command!, args, { cwd, timeout: 3000 });
			return result.code === 0 ? result.stdout : undefined;
		} catch {
			return undefined;
		}
	}
}

/** Parse `git status --porcelain=v2 --branch`. */
function parseGitStatus(output: string): GitStatus {
	const status: GitStatus = { ahead: 0, behind: 0, staged: 0, modified: 0, untracked: 0, conflicted: 0 };
	for (const line of output.split("\n")) {
		if (line.startsWith("# branch.ab ")) {
			const [, ahead, behind] = line.match(/\+(\d+) -(\d+)/) ?? [];
			status.ahead = Number(ahead ?? 0);
			status.behind = Number(behind ?? 0);
		} else if (line.startsWith("1 ") || line.startsWith("2 ")) {
			// "1 XY ...": X is the staged state, Y the working-tree state, "." means unchanged.
			if (line[2] !== ".") status.staged++;
			if (line[3] !== ".") status.modified++;
		} else if (line.startsWith("u ")) {
			status.conflicted++;
		} else if (line.startsWith("? ")) {
			status.untracked++;
		}
	}
	return status;
}
