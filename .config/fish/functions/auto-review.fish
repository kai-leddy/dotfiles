function auto-review
set num (gh pr list --json number,headRefName,title | jq -r '.[] | "\(.number)\t\(.headRefName)\t\(.title)\n"' | column -t -s \t -x | fzf | awk '{ print $1 }')
set details (gh pr view $num)
set diff (gh pr diff $num)

llm -m gpt-4o "Review this github PR for me.\n## Details\n```\n$details\n```\n\n## Diff\n```\n$diff\n```"
end
