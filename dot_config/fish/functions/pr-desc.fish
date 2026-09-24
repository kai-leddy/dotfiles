function pr-desc --description 'draft a PR description with pi (Jira context + diff + repo template)'
    pi --provider anthropic --model claude-sonnet-5 --tools read,bash -p "/pr-description $argv"
end
