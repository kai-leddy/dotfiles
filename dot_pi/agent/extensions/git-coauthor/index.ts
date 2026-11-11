/**
 * Git co-author trailer.
 *
 * Adds a "Co-authored-by:" line naming the model that is running to every commit made from a Pi
 * session, so the agent writes a plain commit message and no model has to remember the trailer.
 * Subagents get their own model's name because Pi sets PI_PROVIDER and PI_MODEL per session.
 *
 * Nothing here touches your git config or your terminal. At load this puts two things in Pi's own
 * environment, which only Pi and the processes it starts inherit:
 *
 *   - git's core.hooksPath, through GIT_CONFIG_COUNT / GIT_CONFIG_KEY_n / GIT_CONFIG_VALUE_n, pointing at
 *     ./hooks. Its commit-msg hook adds the trailer (with `git interpret-trailers`, so it stays the
 *     last line and is never repeated), then runs the repository's own hook of the same name. Every other
 *     hook name just hands over to the repository's hooks (husky, .git/hooks, ...), so they keep working.
 *   - ./bin on PATH, for `pi-coauthor`, which prints the trailer line from PI_PROVIDER and PI_MODEL
 *     (`git commit --trailer "$(pi-coauthor)"` does it by hand, e.g. after --no-verify).
 *
 * Set PI_NO_COAUTHOR=1 to skip the trailer. A commit you make yourself with `!git commit` inside Pi
 * gets it too, as it is a Pi process.
 */

import { existsSync, lstatSync, symlinkSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/** The client-side hooks git runs; each name in ./hooks is a link to the one dispatcher script. */
const HOOKS = [
	"applypatch-msg",
	"pre-applypatch",
	"post-applypatch",
	"pre-commit",
	"pre-merge-commit",
	"prepare-commit-msg",
	"commit-msg",
	"post-commit",
	"pre-rebase",
	"post-checkout",
	"post-merge",
	"pre-push",
	"post-rewrite",
	"pre-auto-gc",
	"push-to-checkout",
	"sendemail-validate",
];

export default function gitCoauthor(_pi: ExtensionAPI): void {
	const here = path.dirname(fileURLToPath(import.meta.url));
	const hooks = path.join(here, "hooks");
	const bin = path.join(here, "bin");
	if (!existsSync(path.join(hooks, "_dispatch")) || !existsSync(path.join(bin, "pi-coauthor"))) return;

	// Create the hook links on first run (they are cheap, and keep the repo free of symlinks).
	for (const name of HOOKS) {
		const link = path.join(hooks, name);
		try {
			lstatSync(link);
		} catch {
			try {
				symlinkSync("_dispatch", link);
			} catch {
				// Read-only checkout: that hook name simply stays unlinked.
			}
		}
	}

	const env = process.env;
	if (!(env.PATH ?? "").split(path.delimiter).includes(bin)) env.PATH = bin + path.delimiter + (env.PATH ?? "");

	// Append to any git config the environment already carries.
	const count = Number.parseInt(env.GIT_CONFIG_COUNT ?? "0", 10) || 0;
	for (let i = 0; i < count; i++) {
		if (env[`GIT_CONFIG_KEY_${i}`] === "core.hooksPath" && env[`GIT_CONFIG_VALUE_${i}`] === hooks) return;
	}
	env[`GIT_CONFIG_KEY_${count}`] = "core.hooksPath";
	env[`GIT_CONFIG_VALUE_${count}`] = hooks;
	env.GIT_CONFIG_COUNT = String(count + 1);
}
