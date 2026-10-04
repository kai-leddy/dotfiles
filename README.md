# Dotfiles

These dotfiles are managed by [`chezmoi`](https://www.chezmoi.io/).

## Setup on a new machine

Install `chezmoi`, then restore at least one private age identity corresponding
with the recipients configured in `.chezmoi.toml.tmpl` to
`~/.config/sops/age/keys.txt` with mode `600`. The identity is private key
material: never commit it or send it with the repository. The recipient set is
the same four-key set used by the homelab repository's `.sops.yaml`.

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

## Secrets

Use chezmoi's native age encryption for secrets. `.chezmoi.toml.tmpl` configures
the same four age recipients as the homelab repository's `.sops.yaml`, so any of
those identities can decrypt the encrypted source files. The local identity is
read from `~/.config/sops/age/keys.txt`; keep the private key outside the
Dotfiles repository and back it up securely. Do not generate a separate
recipient unless you also add it to the configured recipient list and
re-encrypt the managed files.

Encrypted source files are stored in the repository with the `encrypted_`
attribute in their source names; chezmoi decrypts them when applying to the
destination. Fish automatically loads `~/.config/fish/conf.d/*.fish`, so keep
shell secrets there. For example, the source entry
`dot_config/fish/conf.d/encrypted_secrets.fish.age` applies as
`~/.config/fish/conf.d/secrets.fish`.

### Add and edit encrypted secrets

Create a Fish file at its normal destination path, then add it to chezmoi with
encryption enabled:

```sh
$EDITOR "$HOME/.config/fish/conf.d/secrets.fish"
chezmoi add --encrypt "$HOME/.config/fish/conf.d/secrets.fish"
```

Write normal Fish code in the file, for example:

```fish
set -gx SERVICE_API_KEY 'replace-with-a-secret'
```

After it is managed, edit it through chezmoi so plaintext is handled in its
private temporary directory and the source is re-encrypted on save. `--encrypt`
is the `add` flag; `chezmoi edit` transparently handles an already-encrypted
managed file:

```sh
chezmoi edit "$HOME/.config/fish/conf.d/secrets.fish"
```

The repository includes the encrypted `secrets.fish` source for the API keys
previously loaded from the macOS keychain or `pass`. Repeat
`chezmoi add --encrypt` for other secret files, such as
`~/.config/fish/conf.d/work.fish`. The corresponding source files remain
encrypted; chezmoi applies them as ordinary Fish files. Review the source diff
and commit only encrypted files. Do not commit plaintext secrets or age private
keys.

To confirm decryption without printing secret contents, run `chezmoi verify`
after applying the encrypted files. Remove any stale Fish universal-variable
copies after migration (for example, `set -eU VAR_NAME` in Fish).
