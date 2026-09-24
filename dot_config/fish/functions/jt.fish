function jt --description 'draft a Jira ticket description with pi'
    pi --provider anthropic --model claude-sonnet-5 -p "/jira-ticket $argv"
end
