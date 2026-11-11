function jt --description 'draft a Jira ticket description with pi-bolt'
    pi-bolt --provider anthropic --model claude-sonnet-5 --no-lsp -p "/jira-ticket $argv"
end
