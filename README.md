# Dotfiles

These dotfiles are managed by [`chezmoi`](https://www.chezmoi.io/).

## Setup on a new machine

Install `chezmoi`, then restore the age identity from a secure backup to
`~/.config/chezmoi/age.txt` with mode `600` before applying the dotfiles. The
identity is private key material: never commit it or send it with the repository.
See [Secrets](#secrets) for generating the first identity.

```sh
chezmoi init --apply kai-leddy
```

The first init prompts for the identity's public age recipient. Host-specific
files (currently the Ghostty config and the pi agent settings) are chezmoi
templates keyed on `.chezmoi.hostname`.

## Secrets

Use chezmoi's native age encryption for secrets. Encrypted source files are
stored in the repository with the `encrypted_` attribute in their source names;
chezmoi decrypts them when applying to the destination. Fish automatically
loads `~/.config/fish/conf.d/*.fish`, so keep shell secrets there. For example,
the source entry `dot_config/fish/conf.d/encrypted_secrets.fish.age` applies as
`~/.config/fish/conf.d/secrets.fish`. A separate `work.fish` can be encrypted
the same way.

### Generate an age identity

Generate one identity on a trusted machine and keep an offline backup. The
private key stays outside the dotfiles repository; the public recipient is safe
to store in the local chezmoi config.

```sh
mkdir -p "$HOME/.config/chezmoi"
chezmoi age-keygen --output="$HOME/.config/chezmoi/age.txt"
chmod 600 "$HOME/.config/chezmoi/age.txt"
```

`chezmoi age-keygen` prints the public recipient. On the first
`chezmoi init --apply kai-leddy`, enter that public `age1...` recipient when
prompted. Keep and securely back up the private identity. On each new machine,
copy that same identity to `~/.config/chezmoi/age.txt` with mode `600` before
running `chezmoi init --apply kai-leddy`; this lets chezmoi decrypt and apply
encrypted files. Do not generate a different key per machine unless you also
add its recipient to the chezmoi config and re-encrypt the files for it.

If chezmoi is already initialized, merge these settings into the existing config
with `chezmoi edit-config` (preserve its other settings):

```toml
encryption = "age"
[age]
    identity = "~/.config/chezmoi/age.txt"
    recipient = "age1..."
```

Use the public recipient printed by `chezmoi age-keygen`, not the placeholder
above.

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

Repeat `chezmoi add --encrypt` for other secret files, such as
`~/.config/fish/conf.d/work.fish`. The corresponding source files remain
encrypted; chezmoi applies them as ordinary Fish files. Review the source diff
and commit only encrypted files. Do not commit plaintext secrets or age private
keys.

To confirm decryption without printing secret contents, run `chezmoi verify`
after applying the encrypted files. Remove any stale Fish universal-variable
copies after migration (for example, `set -eU VAR_NAME` in Fish).

This replaces the previous keychain/`pass` lookups for `DEEPINFRA_TOKEN`,
`OPENROUTER_API_KEY`, `FIRECRAWL_API_KEY`, `CONTEXT7_API_KEY`, and
`ATLASSIAN_API_KEY`. Those uncommitted values are not in the repository; migrate
only the values still needed into the encrypted Fish file.
