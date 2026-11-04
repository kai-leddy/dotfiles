/**
 * Nerd Font glyphs used across the UI, by meaning. All of them are in
 * FantasqueSansM Nerd Font; prefer a Nerd Font glyph to a generic Unicode
 * symbol. Tool and runtime icons live next to their tables in tools.ts and
 * project.ts.
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
	model: "\u{f06a9}", // robot
	thinking: "\u{f09d1}", // brain
	context: "\u{f029a}", // gauge
	tokensIn: "\u{f0552}", // upload
	tokensOut: "\u{f01da}", // download
	cache: "\u{f12a9}", // database with a tick
	cost: "\u{f01c1}", // dollar
	speed: "\uf0e7", // bolt
	firstToken: "\u{f051f}", // hourglass
	duration: "\u{f051b}", // timer
	ok: "\uf00c", // tick
	failed: "\uf00d", // cross
	cancelled: "\uf05e", // ban
	running: "\uf141", // ellipsis
	tool: "\uf013", // cog, for tools without their own icon
	pillLeft: "\ue0b6", // rounded powerline caps
	pillRight: "\ue0b4",
} as const;

/** Nerd Fonts' progress-bar pieces: [left end, middle, right end]. */
export const progress = {
	empty: ["\uee00", "\uee01", "\uee02"],
	filled: ["\uee03", "\uee04", "\uee05"],
} as const;

/** Nerd Fonts' spinner frames. */
export const spinner = ["\uee06", "\uee07", "\uee08", "\uee09", "\uee0a", "\uee0b"];

/** A circle that fills up with each thinking level, off to max. */
export const thinkingLevels = {
	off: "\u{f0766}", // empty circle
	minimal: "\u{f0a9e}", // circle slice 1 of 8
	low: "\u{f0a9f}",
	medium: "\u{f0aa1}",
	high: "\u{f0aa3}",
	xhigh: "\u{f0aa4}",
	max: "\u{f0aa5}", // full circle
} as const;
