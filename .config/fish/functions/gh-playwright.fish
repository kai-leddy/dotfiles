function gh-playwright
    set selected_workflow (gh run list --status=failure --limit 100 --json name,displayTitle,headBranch,updatedAt,databaseId | jq -r '.[] | "\(.name)\t\(.headBranch)\t\(.displayTitle)\t\(.updatedAt)\t\(.databaseId)\n"' | column -t -s \t -x | fzf | awk 'NF{print $NF}')

    if test -n "$selected_workflow"
        set temp_dir (mktemp -d)
        gh run download $run_id --name playwright-report --dir $temp_dir
        pnpm dlx playwright show-report $temp_dir
        rm -rf $temp_dir
    else
        echo "No workflow selected."
    end
end
