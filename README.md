# Dotfiles

These dotfiles are now managed by [`chezmoi`](https://www.chezmoi.io/). See their docs for
usage instructions.

## Setup on a new machine

Initialize chezmoi without applying yet:

```sh
chezmoi init --ssh kai-leddy
```

Before the first `chezmoi apply`, set the local machine identifier in
`~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
    machine = "work-laptop"
```

Use `machine = "main-pc"` on the main PC. This config file lives outside the
Dotfiles repository, so the value stays local to each machine. If the file
already has a `[data]` section, add `machine` to it instead of adding a second
section. On a reinstall, check or restore this value before applying the
Dotfiles, or host-specific templates will use their default settings.

Then apply the configuration:

```sh
chezmoi apply
```

The Ghostty config and Pi agent settings use `.machine` to select work-laptop
settings. Verify chezmoi sees the expected value with:

```sh
chezmoi execute-template '{{ .machine }}'
```
