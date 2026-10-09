function cz-reconcile --description 'Ask pi to fold live-file drift back into chezmoi templates'
    argparse h/help n/dry-run 'm/model=' -- $argv; or return 1

    if set -q _flag_help
        echo 'usage: cz-reconcile [-n|--dry-run] [-m|--model MODEL] [TARGET...]'
        echo
        echo 'For each drifted chezmoi file whose source is a template (*.tmpl), ask pi'
        echo 'to edit the template so that `chezmoi apply` keeps the live changes.'
        echo 'With no TARGET, every drifted template is processed. Non-template files'
        echo 'are skipped; use `chezmoi re-add` for those.'
        echo
        echo '  -n, --dry-run   list the templates that would be reconciled, then exit'
        echo '  -m, --model     model pattern passed to pi'
        return 0
    end

    for tool in chezmoi pi
        if not command -q $tool
            echo "cz-reconcile: $tool not found in PATH" >&2
            return 1
        end
    end

    set -l targets
    for f in $argv
        set -a targets (path resolve -- $f)
    end

    # `chezmoi status` prints "XY path". Y is the actual-vs-target column, so
    # Y == M means `chezmoi apply` would overwrite the live file.
    set -l templates
    set -l plain
    for line in (command chezmoi status --path-style absolute $targets)
        test (string sub --start 2 --length 1 -- $line) = M; or continue
        set -l target (string sub --start 4 -- $line)
        set -l source (command chezmoi source-path $target 2>/dev/null)
        if string match -q -- '*.tmpl' $source
            set -a templates $target
        else
            set -a plain $target
        end
    end

    if test (count $plain) -gt 0
        echo "Skipping non-template files (use `chezmoi re-add`):"
        printf '  %s\n' $plain
    end

    if test (count $templates) -eq 0
        echo 'No drifted templates to reconcile.'
        return 0
    end

    echo 'Drifted templates:'
    for target in $templates
        printf '  %s\n    -> %s\n' $target (command chezmoi source-path $target)
    end

    if set -q _flag_dry_run
        return 0
    end

    set -l pi_args -p --no-session
    set -q _flag_model; and set -a pi_args --model $_flag_model

    set -l machine (command chezmoi execute-template '{{ .machine }}' 2>/dev/null)
    set -l failed
    for target in $templates
        set -l source (command chezmoi source-path $target)
        set -l diff (command chezmoi diff --no-pager --color=false $target | string collect)

        set -l prompt "A chezmoi-managed file has been edited directly, and its source is a template. Update the TEMPLATE so that `chezmoi apply` reproduces the live file and no longer reverts my changes.

Live file (source of truth): $target
Template to edit: $source

`chezmoi diff` output follows. Lines starting with `-` are the live file; lines starting with `+` are what the template currently renders.

$diff

Rules:
- Edit only the template (and any file it directly includes, if that is where the value lives). Never edit the live file and never run `chezmoi apply`, `chezmoi re-add` or `chezmoi merge`.
- Preserve existing template logic (conditionals, variables, includes). Do not hardcode values that are deliberately templated.
- This machine is `$machine` in the template data (`.machine`), so the diff only reflects that machine. If a change sits inside a machine-specific branch, edit that branch. Otherwise make the change unconditional, and say so in your summary.
- Watch commas, trailing newlines and whitespace trimming (`{{-`, `-}}`) so the rendered output matches the live file byte for byte.
- When done, run `chezmoi diff $target`. It must print nothing. Fix the template until it does.
- Finish with a one-or-two line summary of what changed in the template."

        echo
        echo "==> Reconciling $target"
        pi $pi_args $prompt

        if test -n "$(command chezmoi diff --no-pager --color=false $target | string collect)"
            echo "cz-reconcile: $target still differs from its template" >&2
            set -a failed $target
        else
            echo "✔ $target is clean"
        end
    end

    if test (count $failed) -gt 0
        echo
        echo 'Still drifted (try `chezmoi merge` for these):' >&2
        printf '  %s\n' $failed >&2
        return 1
    end
end
