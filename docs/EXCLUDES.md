# What Is Deliberately Not Captured

`capture.sh` uses an allowlist for home dotfiles and a denylist (`config-exclude.txt`) for `~/.config`. Everything below is excluded on purpose. The rule: capture what rebuilds the environment, never what leaks an account or bloats the repo.

## Secrets and credential stores
`gh`, `keyrings`, `kwalletd`, `pulse`, `session`, `gnupg`, and the whole set of browser profiles (`BraveSoftware`, `chromium`, `google-chrome`, `microsoft-edge`, `opera`, `vivaldi`, `mozilla`) hold cookies, saved passwords, and session tokens.

Individually removed after being caught by the secret scan:
- `home/.bootdev.yaml` — boot.dev JWT + refresh token
- `config/htb/token-default` — Hack The Box API JWT
- `config/streamrip/config.toml` — Qobuz app secret
- `config/freerdp/server/*.pem` — cached RDP certs tied to target IPs

## Offensive-security tool state and loot
`nuclei`, `subfinder`, `httpx`, `katana`, `dnsx`, `uncover`, `bloodhound`, `ffuf`, `htb`, `freerdp`. Target-specific, regenerated per engagement, and out of scope for a desktop snapshot.

## Application data, not configuration
`discord`, `teams-for-linux`, `wasistlos`, `Notion`, `notion-app`, `obsidian`, `Claude`, `Codex`, `opencode`, `Antigravity`. Local vaults, chat history, and IDE state, some of it holding tokens.

## Regenerable blobs
`spicetify/Themes` (cloned theme repos), `mpv/subtitles`, and every `*cache*` / `GPUCache` directory. Re-fetched on restore.

## Binaries and models
`~/ai/bin/llama-swap`, `~/ai/src/llama.cpp`, and `~/ai/models/` are not stored. The `qwen` launcher and `llama-swap.yaml` are. `~/.local/bin` is captured as a name-only manifest, since those tools reinstall through pipx, uv, and pacman.
