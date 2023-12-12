function generate-pr-description
    set branch (git branch --show-current)
    set merge_base (git merge-base master $branch)
    set changelog (git diff $merge_base..HEAD)

    if test -n "$ticket"
        echo $changelog | llm -t pr-desc -p branch $branch
    else
        echo "No ticket found in the branch name."
    end
end
