#!/usr/bin/env bash
# Prints the remaining quota of each AI provider as JSON, for items/ai.lua:
#
#   ai_quota.sh [provider...]   (claude copilot openrouter deepinfra; default all)
#
#   {"claude":{"kind":"percent","remaining":50.3}, "deepinfra":{"kind":"usd","remaining":4.79,"stale":true}, ...}
#
# Uses the same endpoints and credentials as the pi usage bar
# (~/.pi/agent/extensions/pi-usage-bar.ts). Providers without credentials are
# left out. If a live request fails (or pi's Claude token has expired; it's only
# refreshed while pi uses it, and refreshing it here would log pi out), the last
# value pi cached in ~/.cache/pi-usage-bar.json is used and marked stale.

set -u
export PATH="/opt/homebrew/bin:$PATH"

AUTH="$HOME/.pi/agent/auth.json"
PI_CACHE="$HOME/.cache/pi-usage-bar.json"
SECRETS="$HOME/.config/fish/conf.d/secrets.fish"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
now_ms=$(($(date +%s) * 1000))

# An env var, or failing that its `set -gx NAME value` line in the fish secrets
# (sketchybar runs under launchd, so it doesn't get the shell environment).
secret() {
	local value="${!1:-}"
	[ -n "$value" ] || value=$(sed -n "s/^set -gx $1 //p" "$SECRETS" 2>/dev/null | tr -d "\"'")
	printf %s "$value"
}
auth() { jq -r "$1 // empty" "$AUTH" 2>/dev/null; }
get() { curl -sf -m 8 "$@"; }

# Each fetcher prints one JSON object, prints nothing on failure, or returns 99
# when there are no credentials.
claude() {
	local token expires
	token=$(auth '.anthropic.access')
	expires=$(auth '.anthropic.expires')
	[ -n "$token" ] || return 99
	[ "${expires:-0}" -gt "$now_ms" ] || return 0
	# The most-used window (5h, weekly, extra usage...) is the binding one.
	get https://api.anthropic.com/api/oauth/usage \
		-H "authorization: Bearer $token" \
		-H "anthropic-beta: oauth-2025-04-20" \
		-H "user-agent: claude-code/1.0.0" |
		jq -c '[.[]? | objects | .utilization? | numbers] | select(length > 0)
			| {kind: "percent", remaining: (100 - max)}'
}

copilot() {
	local token
	token=$(auth '."github-copilot".refresh')
	[ -n "$token" ] || return 99
	get https://api.github.com/copilot_internal/user \
		-H "authorization: Bearer $token" \
		-H "user-agent: pi-usage-bar" |
		jq -c '.quota_snapshots.premium_interactions
			| select(. != null and (.unlimited | not))
			| {kind: "percent", remaining: .percent_remaining}'
}

openrouter() {
	local key
	key=$(secret OPENROUTER_API_KEY)
	[ -n "$key" ] || return 99
	get https://openrouter.ai/api/v1/credits -H "Authorization: Bearer $key" |
		jq -c '.data | select(.total_credits | numbers)
			| {kind: "usd", remaining: ([0, .total_credits - .total_usage] | max)}'
}

deepinfra() {
	local key
	key=$(secret DEEPINFRA_TOKEN)
	[ -n "$key" ] || return 99
	# A negative stripe_balance is prepaid credit; `recent` is usage not yet
	# billed against it.
	get "https://api.deepinfra.com/payment/checklist?compute_owed=true" \
		-H "Authorization: Bearer $key" |
		jq -c 'select(.stripe_balance | numbers)
			| {kind: "usd", remaining: ([0, -(.stripe_balance + ([.recent // 0, 0] | max))] | max)}'
}

# Last value pi saw, converted to the same shape.
cached() {
	jq -c --arg key "$1" '.[$key] | select(. != null and .limit > 0)
		| if .remaining != null
			then {kind: "usd", remaining: .remaining}
			else {kind: "percent", remaining: (100 - .used / .limit * 100)}
			end
		+ {stale: true}' "$PI_CACHE" 2>/dev/null
}

providers=("$@")
[ ${#providers[@]} -gt 0 ] || providers=(claude copilot openrouter deepinfra)
for p in "${providers[@]}"; do
	(
		"$p" >"$tmp/$p"
		echo $? >"$tmp/$p.status"
	) &
done
wait

out='{}'
for p in "${providers[@]}"; do
	[ "$(cat "$tmp/$p.status")" = 99 ] && continue
	value=$(cat "$tmp/$p")
	if [ -z "$value" ]; then
		[ "$p" = claude ] && key=anthropic || key=$p
		value=$(cached "$key")
	fi
	[ -n "$value" ] && out=$(jq -c --arg p "$p" --argjson v "$value" '.[$p] = $v' <<<"$out")
done
printf '%s\n' "$out"
