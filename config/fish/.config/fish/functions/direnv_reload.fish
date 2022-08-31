function direnv_reload --on-event fish_preexec
  if test -f .env || test -f .envrc
    direnv export fish | source;
  end
end
