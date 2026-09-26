# Dotfiles

These dotfiles are now managed by [`chezmoi`](https://www.chezmoi.io/). See their docs for
usage instructions.

## Setup on a new machine

```sh
chezmoi init --ssh --apply kai-leddy
```

Host-specific files (currently the Ghostty config and the pi agent settings) are chezmoi
templates keyed on `.chezmoi.hostname` - no extra prompts or config needed.
