# Fish completions for pi-bolt, the ahead-of-time compiled pi.
# `pi` is the same binary; see pi.fish.

function __fish_pi_bolt_needs_subcommand
    set -l words (commandline -opc)
    test (count $words) -eq 1
end

function __fish_pi_bolt_subcommand_is
    set -l words (commandline -opc)
    test (count $words) -ge 2
    and test "$words[2]" = "$argv[1]"
end

function __fish_pi_bolt_nth_word_is
    set -l words (commandline -opc)
    test (count $words) -eq $argv[1]
    and test "$words[2]" = "$argv[2]"
end

function __fish_pi_bolt_installed_packages
    # Keep this in sync with pi-bolt rather than duplicating package sources here.
    command pi-bolt list 2>/dev/null | string match --regex '^\s{2}(?:npm|git):.*$' | string trim
end

function __fish_pi_bolt_compile_names
    command pi-bolt compile --list 2>/dev/null | string match --regex --groups-only '^\s{2}(\S+) \('
end

# Top-level commands.
complete -c pi-bolt -n __fish_pi_bolt_needs_subcommand -f -a install -d 'Install a package'
complete -c pi-bolt -n __fish_pi_bolt_needs_subcommand -f -a remove -d 'Remove a package'
complete -c pi-bolt -n __fish_pi_bolt_needs_subcommand -f -a uninstall -d 'Alias for remove'
complete -c pi-bolt -n __fish_pi_bolt_needs_subcommand -f -a update -d 'Update Pi-Bolt, packages, or model catalogs'
complete -c pi-bolt -n __fish_pi_bolt_needs_subcommand -f -a list -d 'List installed packages'
complete -c pi-bolt -n __fish_pi_bolt_needs_subcommand -f -a config -d 'Configure package resources'
complete -c pi-bolt -n __fish_pi_bolt_needs_subcommand -f -a auth -d 'Print credentials or check provider readiness'
complete -c pi-bolt -n __fish_pi_bolt_needs_subcommand -f -a mcp -d 'Check MCP servers, sign in or out of OAuth servers'
complete -c pi-bolt -n __fish_pi_bolt_needs_subcommand -f -a doctor -d 'Print a report of this installation'
complete -c pi-bolt -n __fish_pi_bolt_needs_subcommand -f -a compile -d 'Compile the installed extensions into Pi-Bolt'

# Main options.
complete -c pi-bolt -s p -l print -d 'Print response and exit'
complete -c pi-bolt -s c -l continue -d 'Continue the most recent session'
complete -c pi-bolt -s r -l resume -d 'Select a session to resume'
complete -c pi-bolt -l provider -x -a 'anthropic openai azure-openai google vertex deepseek nvidia groq cerebras xai openrouter deepinfra bedrock mistral fireworks together baseten kimi minimax moonshot opencode cloudflare vercel zai github-copilot' -d 'Model provider'
complete -c pi-bolt -l model -x -d 'Model pattern or ID'
complete -c pi-bolt -l api-key -x -d 'API key'
complete -c pi-bolt -l system-prompt -x -d 'Replace the system prompt'
complete -c pi-bolt -l append-system-prompt -x -d 'Append text or a file to the system prompt'
complete -c pi-bolt -l mode -x -a 'text\tHuman-readable output json\tJSON Lines output rpc\tRPC over stdin/stdout acp\tAgent Client Protocol server mcp\tModel Context Protocol server' -d 'Output mode'
complete -c pi-bolt -l acp -d 'Agent Client Protocol server, for editors'
complete -c pi-bolt -l mcp -d 'Model Context Protocol server, for other agents'
complete -c pi-bolt -l session -x -d 'Session path or partial ID'
complete -c pi-bolt -l session-id -x -d 'Exact project session ID'
complete -c pi-bolt -l fork -x -d 'Session path or partial ID to fork'
complete -c pi-bolt -l session-dir -x -a '(__fish_complete_directories)' -d 'Session storage directory'
complete -c pi-bolt -l no-session -d 'Do not save a session'
complete -c pi-bolt -s n -l name -x -d 'Session display name'
complete -c pi-bolt -l models -x -d 'Comma-separated model patterns'
complete -c pi-bolt -o nt -l no-tools -d 'Disable all tools'
complete -c pi-bolt -o nbt -l no-builtin-tools -d 'Disable built-in tools'
complete -c pi-bolt -s t -l tools -x -a 'read bash edit write grep find ls' -d 'Enable these tools'
complete -c pi-bolt -o xt -l exclude-tools -x -a 'read bash edit write grep find ls' -d 'Disable these tools'
complete -c pi-bolt -l thinking -x -a 'off minimal low medium high xhigh max' -d 'Thinking level'
complete -c pi-bolt -s e -l extension -x -a '(__fish_complete_path)' -d 'Load an extension (or builtin:<name>)'
complete -c pi-bolt -o ne -l no-extensions -d 'Disable extension discovery and built-ins'
complete -c pi-bolt -l no-mcp -d 'Disable built-in MCP support'
complete -c pi-bolt -l skill -x -a '(__fish_complete_path)' -d 'Load a skill file or directory'
complete -c pi-bolt -o ns -l no-skills -d 'Disable skill discovery'
complete -c pi-bolt -l prompt-template -x -a '(__fish_complete_path)' -d 'Load a prompt template'
complete -c pi-bolt -o np -l no-prompt-templates -d 'Disable prompt template discovery'
complete -c pi-bolt -l theme -x -a '(__fish_complete_path)' -d 'Load a theme'
complete -c pi-bolt -l use-theme -x -d 'Initial interactive theme for this run'
complete -c pi-bolt -l no-themes -d 'Disable theme discovery'
complete -c pi-bolt -o nc -l no-context-files -d 'Disable AGENTS.md and CLAUDE.md discovery'
complete -c pi-bolt -l export -x -a '(__fish_complete_path)' -d 'Export a session to HTML'
complete -c pi-bolt -l list-models -d 'List available models'
complete -c pi-bolt -l verbose -d 'Force verbose startup'
complete -c pi-bolt -l tui-mode -x -a 'fullscreen regular' -d 'TUI mode'
complete -c pi-bolt -s a -l approve -d 'Trust project-local files'
complete -c pi-bolt -o na -l no-approve -d 'Ignore project-local files'
complete -c pi-bolt -l offline -d 'Disable startup network operations'
complete -c pi-bolt -s h -l help -d 'Show help'
complete -c pi-bolt -s v -l version -d 'Show version'

# Installed package sources are valid arguments for removal and targeted updates.
for subcommand in remove uninstall update
    complete -c pi-bolt -n "__fish_pi_bolt_subcommand_is $subcommand" -f -a '(__fish_pi_bolt_installed_packages)' -d 'Installed package'
end
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is update' -f -a 'self pi' -d 'Update Pi-Bolt itself'

# Package-management options.
for subcommand in install remove uninstall config
    complete -c pi-bolt -n "__fish_pi_bolt_subcommand_is $subcommand" -s l -l local -d 'Use project-local settings'
    complete -c pi-bolt -n "__fish_pi_bolt_subcommand_is $subcommand" -s a -l approve -d 'Trust project-local files'
    complete -c pi-bolt -n "__fish_pi_bolt_subcommand_is $subcommand" -o na -l no-approve -d 'Ignore project-local files'
end

complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is update' -l self -d 'Update Pi-Bolt only'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is update' -l extensions -d 'Update installed packages only'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is update' -l models -d 'Refresh model catalogs only'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is update' -l all -d 'Update Pi-Bolt and packages'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is update' -l extension -x -d 'Update one package'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is update' -l force -d 'Reinstall even when current'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is update' -l rollback -d 'Put back the build it replaced'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is update' -l channel -x -a 'stable beta' -d 'Release channel'
for subcommand in update list
    complete -c pi-bolt -n "__fish_pi_bolt_subcommand_is $subcommand" -s a -l approve -d 'Trust project-local files'
    complete -c pi-bolt -n "__fish_pi_bolt_subcommand_is $subcommand" -o na -l no-approve -d 'Ignore project-local files'
end

# Credential subcommands and their options.
complete -c pi-bolt -n '__fish_pi_bolt_nth_word_is 2 auth' -f -a print-api-key -d 'Print an API key'
complete -c pi-bolt -n '__fish_pi_bolt_nth_word_is 2 auth' -f -a print-bearer-token -d 'Print a bearer token'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is auth' -l provider -x -d 'Credential provider'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is auth' -l model -x -d 'Model ID'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is auth' -l min-expiry -x -d 'Minimum token lifetime (for example, 30m)'
complete -c pi-bolt -n '__fish_pi_bolt_nth_word_is 2 auth' -f -a check -d 'Check provider readiness'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is auth' -l json -d 'JSON output (check)'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is auth' -l credentials -d 'Show credential details (check)'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is auth' -l no-refresh -d 'Do not refresh tokens (check)'

# MCP servers.
complete -c pi-bolt -n '__fish_pi_bolt_nth_word_is 2 mcp' -f -a add -d 'Add or replace a server in mcp.json'
complete -c pi-bolt -n '__fish_pi_bolt_nth_word_is 2 mcp' -f -a remove -d 'Remove a server from mcp.json'
complete -c pi-bolt -n '__fish_pi_bolt_nth_word_is 2 mcp' -f -a list -d 'Show state, tools and errors'
complete -c pi-bolt -n '__fish_pi_bolt_nth_word_is 2 mcp' -f -a login -d 'Sign in through the browser'
complete -c pi-bolt -n '__fish_pi_bolt_nth_word_is 2 mcp' -f -a logout -d 'Delete stored OAuth credentials'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is mcp' -s l -l local -d 'Use the project .pi/mcp.json'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is mcp' -l url -x -d 'Streamable HTTP server URL'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is mcp' -l env -x -d 'KEY=VALUE for a stdio server'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is mcp' -l cwd -x -a '(__fish_complete_directories)' -d 'Working directory for a stdio server'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is mcp' -l header -x -d 'HTTP header KEY=VALUE'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is mcp' -l json -d 'JSON output (list)'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is mcp' -l timeout -x -d 'Login timeout in seconds'

# Compiling extensions in.
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is compile' -f -l list -d 'List the extensions a compile takes'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is compile' -f -l status -d 'Show what is compiled in'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is compile' -f -l off -d 'Go back to the release executable'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is compile' -f -l no-packages -d 'Leave out installed packages'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is compile' -f -l no-exclude -d 'Leave out none excluded before'
for flag in only exclude include
    complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is compile' -l $flag -x -a '(__fish_pi_bolt_compile_names)' -d 'Extension names (comma-separated)'
end
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is compile' -l kit -r -d 'Compile kit archive or folder'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is compile' -l runtime -r -d 'Runtime archive, folder or bun executable'
complete -c pi-bolt -n '__fish_pi_bolt_subcommand_is compile' -l out -x -a '(__fish_complete_directories)' -d 'Build into DIR and install nothing'
