/**
 * Nerd Font glyphs used across the UI, by meaning. All of them are in
 * FantasqueSansM Nerd Font; prefer a Nerd Font glyph to a generic Unicode
 * symbol, and look a new one up by name (nerdfonts.com/cheat-sheet) rather
 * than by codepoint. Model logos live in brands.ts; tool and runtime icons
 * live next to their tables in tools.ts and project.ts.
 */

export const icons = {
	pi: "\u{f03ff}",
	prompt: "\uf054", // chevron right
	dot: "\uf444", // separator
	folder: "\uf07b",
	branch: "\ue0a0",
	ahead: "\uf062", // arrow up
	behind: "\uf063", // arrow down
	staged: "\uf457", // diff added
	modified: "\uf459", // diff modified
	untracked: "\uf128", // question mark
	conflicted: "\uf071", // warning
	model: "\u{f06a9}", // robot, for models without a logo of their own
	thinking: "\u{f09d1}", // brain
	context: "\u{f029a}", // gauge
	tokensIn: "\u{f0552}", // upload
	tokensOut: "\u{f01da}", // download
	cache: "\u{f0aa9}", // database with a tick
	cost: "\u{f01c1}", // dollar
	speed: "\uf0e7", // bolt
	firstToken: "\u{f051f}", // hourglass
	duration: "\u{f051b}", // timer
	ok: "\uf00c", // tick
	failed: "\uf00d", // cross
	cancelled: "\uf05e", // ban
	running: "\uf141", // ellipsis
	tool: "\uf013", // cog, for tools without their own icon
	lsp: "\uf121", // code, for the language server status
	agents: "\uf0c0", // people, for running subagents
	quota: "\u{f0584}", // wallet, for the usage quota left
	cleanup: "\u{f00e2}", // broom, for pi-blackhole's memory cleanup
} as const;

/** Nerd Fonts' progress-bar pieces: [left end, middle, right end]. */
export const progress = {
	empty: ["\uee00", "\uee01", "\uee02"],
	filled: ["\uee03", "\uee04", "\uee05"],
} as const;

/** Nerd Fonts' spinner frames. */
export const spinner = ["\uee06", "\uee07", "\uee08", "\uee09", "\uee0a", "\uee0b"];
