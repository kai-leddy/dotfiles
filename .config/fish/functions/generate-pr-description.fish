function generate-pr-description --argument base_branch
    if test -z "$base_branch"
        set base_branch master
    end

    set branch (git branch --show-current)
    set merge_base (git merge-base $base_branch $branch)
    set changelog "$(git diff --unified=0 --abbrev=1 --no-prefix $merge_base..HEAD ':(exclude)**yarn.lock' ':(exclude)**pnpm-lock.yaml' ':(exclude)**package-lock.json' ':(exclude)**generated/**' ':(exclude)**__snapshots__/**' ':(exclude)**__tests__/**' ':(exclude)**__mocks__/**' ':(exclude)**.d.ts' ':(exclude)**.tsbuildinfo' ':(exclude)**.js.map' ':(exclude)**.css.map')"
    set ticket (string match -r '([A-Z]+-\d+)' $branch)[1]
    set changelog_tokens (echo $changelog | ttok)

    if test -n "$ticket"
        # if the changelog is larger than 10000 tokens, ask the user if they want to continue
        if test $changelog_tokens -gt 5000
            if gum confirm "The changelog is large ($changelog_tokens tokens). Are you sure you want to continue?"
                echo $changelog | llm -t pr-desc -p ticket $ticket -p branch $branch
            else
                echo "Aborting."
            end
        else
            echo $changelog | llm -t pr-desc -p ticket $ticket -p branch $branch
        end
    else
        echo "No ticket found in the branch name."
    end
end
