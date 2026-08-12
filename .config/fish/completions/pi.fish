# Fish completions for pi, the AI coding assistant.

function __fish_pi_needs_subcommand
    set -l words (commandline -opc)
    test (count $words) -eq 1
end

function __fish_pi_subcommand_is
    set -l words (commandline -opc)
    test (count $words) -ge 2
    and test "$words[2]" = "$argv[1]"
end

function __fish_pi_auth_needs_subcommand
    set -l words (commandline -opc)
    test (count $words) -eq 2
    and test "$words[2]" = auth
end

function __fish_pi_installed_packages
    # Keep this in sync with pi rather than duplicating package sources here.
    command pi list 2>/dev/null | string match --regex '^\\s{2}(?:npm|git):.*$' | string trim
end

# Top-level package and credential commands.
complete -c pi -n __fish_pi_needs_subcommand -f -a install -d 'Install a package'
complete -c pi -n __fish_pi_needs_subcommand -f -a remove -d 'Remove a package'
complete -c pi -n __fish_pi_needs_subcommand -f -a uninstall -d 'Alias for remove'
complete -c pi -n __fish_pi_needs_subcommand -f -a update -d 'Update pi, packages, or model catalogs'
complete -c pi -n __fish_pi_needs_subcommand -f -a list -d 'List installed packages'
complete -c pi -n __fish_pi_needs_subcommand -f -a config -d 'Configure package resources'
complete -c pi -n __fish_pi_needs_subcommand -f -a auth -d 'Print configured credentials'

# Main options.
complete -c pi -s p -l print -d 'Print response and exit'
complete -c pi -s c -l continue -d 'Continue the most recent session'
complete -c pi -s r -l resume -d 'Select a session to resume'
complete -c pi -l provider -x -a 'anthropic openai azure-openai google vertex deepseek nvidia groq cerebras xai openrouter bedrock mistral fireworks together baseten kimi minimax moonshot opencode cloudflare vercel zai github-copilot' -d 'Model provider'
complete -c pi -l model -x -d 'Model pattern or ID'
complete -c pi -l api-key -x -d 'API key'
complete -c pi -l system-prompt -x -d 'Replace the system prompt'
complete -c pi -l append-system-prompt -x -d 'Append text or a file to the system prompt'
complete -c pi -l mode -x -a 'text\tHuman-readable output json\tJSON Lines output rpc\tRPC over stdin/stdout' -d 'Output mode'
complete -c pi -l session -x -d 'Session path or partial ID'
complete -c pi -l session-id -x -d 'Exact project session ID'
complete -c pi -l fork -x -d 'Session path or partial ID to fork'
complete -c pi -l session-dir -x -a '(__fish_complete_directories)' -d 'Session storage directory'
complete -c pi -l no-session -d 'Do not save a session'
complete -c pi -s n -l name -x -d 'Session display name'
complete -c pi -l models -x -d 'Comma-separated model patterns'
complete -c pi -o nt -l no-tools -d 'Disable all tools'
complete -c pi -o nbt -l no-builtin-tools -d 'Disable built-in tools'
complete -c pi -s t -l tools -x -a 'read bash edit write grep find ls' -d 'Enable these tools'
complete -c pi -o xt -l exclude-tools -x -a 'read bash edit write grep find ls' -d 'Disable these tools'
complete -c pi -l thinking -x -a 'off minimal low medium high xhigh max' -d 'Thinking level'
complete -c pi -s e -l extension -x -a '(__fish_complete_path)' -d 'Load an extension'
complete -c pi -o ne -l no-extensions -d 'Disable extension discovery'
complete -c pi -l skill -x -a '(__fish_complete_path)' -d 'Load a skill file or directory'
complete -c pi -o ns -l no-skills -d 'Disable skill discovery'
complete -c pi -l prompt-template -x -a '(__fish_complete_path)' -d 'Load a prompt template'
complete -c pi -o np -l no-prompt-templates -d 'Disable prompt template discovery'
complete -c pi -l theme -x -a '(__fish_complete_path)' -d 'Load a theme'
complete -c pi -l no-themes -d 'Disable theme discovery'
complete -c pi -o nc -l no-context-files -d 'Disable AGENTS.md and CLAUDE.md discovery'
complete -c pi -l export -x -a '(__fish_complete_path)' -d 'Export a session to HTML'
complete -c pi -l list-models -d 'List available models'
complete -c pi -l verbose -d 'Force verbose startup'
complete -c pi -l tui-mode -x -a 'regular fullscreen' -d 'TUI mode'
complete -c pi -s a -l approve -d 'Trust project-local files'
complete -c pi -o na -l no-approve -d 'Ignore project-local files'
complete -c pi -l offline -d 'Disable startup network operations'
complete -c pi -s h -l help -d 'Show help'
complete -c pi -s v -l version -d 'Show version'

# Installed package sources are valid arguments for removal and targeted updates.
for subcommand in remove uninstall update
    complete -c pi -n "__fish_pi_subcommand_is $subcommand" -f -a '(__fish_pi_installed_packages)' -d 'Installed package'
end
complete -c pi -n '__fish_pi_subcommand_is update' -f -a 'self pi' -d 'Update pi itself'

# Package-management options.
for subcommand in install remove uninstall config
    complete -c pi -n "__fish_pi_subcommand_is $subcommand" -s l -l local -d 'Use project-local settings'
    complete -c pi -n "__fish_pi_subcommand_is $subcommand" -s a -l approve -d 'Trust project-local files'
    complete -c pi -n "__fish_pi_subcommand_is $subcommand" -o na -l no-approve -d 'Ignore project-local files'
end

complete -c pi -n '__fish_pi_subcommand_is update' -l self -d 'Update pi only'
complete -c pi -n '__fish_pi_subcommand_is update' -l extensions -d 'Update installed packages only'
complete -c pi -n '__fish_pi_subcommand_is update' -l models -d 'Refresh model catalogs only'
complete -c pi -n '__fish_pi_subcommand_is update' -l all -d 'Update pi and packages'
complete -c pi -n '__fish_pi_subcommand_is update' -l extension -x -d 'Update one package'
complete -c pi -n '__fish_pi_subcommand_is update' -l force -d 'Reinstall even when current'
for subcommand in update list
    complete -c pi -n "__fish_pi_subcommand_is $subcommand" -s a -l approve -d 'Trust project-local files'
    complete -c pi -n "__fish_pi_subcommand_is $subcommand" -o na -l no-approve -d 'Ignore project-local files'
end

# Credential subcommands and their options.
complete -c pi -n __fish_pi_auth_needs_subcommand -f -a print-api-key -d 'Print an API key'
complete -c pi -n __fish_pi_auth_needs_subcommand -f -a print-bearer-token -d 'Print a bearer token'
complete -c pi -n '__fish_pi_subcommand_is auth' -l provider -x -d 'Credential provider'
complete -c pi -n '__fish_pi_subcommand_is auth' -l model -x -d 'Model ID'
complete -c pi -n '__fish_pi_subcommand_is auth' -l min-expiry -x -d 'Minimum token lifetime (for example, 30m)'
