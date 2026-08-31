```
██████╗ ███████╗██╗   ██╗███████╗███╗   ██╗ █████╗ ███╗   ██╗████████╗
██╔══██╗██╔════╝██║   ██║██╔════╝████╗  ██║██╔══██╗████╗  ██║╚══██╔══╝
██████╔╝█████╗  ██║   ██║█████╗  ██╔██╗ ██║███████║██╔██╗ ██║   ██║
██╔══██╗██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║██╔══██║██║╚██╗██║   ██║
██║  ██║███████╗ ╚████╔╝ ███████╗██║ ╚████║██║  ██║██║ ╚████║   ██║
╚═╝  ╚═╝╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝
                            a k r v s
```

> Every rice is one bad update away from a black screen. Revenant is the
> resurrection stone for arch-station: one private snapshot of the whole
> environment — dotfiles, Hyprland config, package manifests, system tweaks,
> the local-LLM stack — scrubbed of every secret and rebuildable with a single
> script. Break the machine on purpose. It comes back.

![status](https://img.shields.io/badge/status-ACTIVE-brightgreen)
![category](https://img.shields.io/badge/category-System%20%2F%20Dotfiles-9cf)
![host](https://img.shields.io/badge/host-Arch%20%C2%B7%20Hyprland-1793d1)
![shell](https://img.shields.io/badge/shell-zsh%20%2B%20p10k-yellow)
![secrets](https://img.shields.io/badge/secrets-scanned%20%26%20excluded-brightgreen)
![visibility](https://img.shields.io/badge/visibility-PRIVATE-red)

```
┌─[ TARGET ]──────────────────────────────────────────────────────┐
│ codename   : revenant                                           │
│ category   : System Restore / Dotfiles Snapshot                 │
│ host       : arch-station                                       │
│ stack      : Arch Linux · Hyprland · zsh · greetd               │
│ layers     : home dotfiles · ~/.config · /etc · ai stack        │
│ flags      : user [rice restored]   root [machine reborn]       │
│ status     : ACTIVE — full snapshot, secret-scanned, scripted   │
└─────────────────────────────────────────────────────────────────┘
```

## [ Briefing ]

A JaKooLit-style Hyprland setup on rolling Arch, captured in full so a broken
update, a wiped disk, or a fresh install never costs more than a clone and a
script. Two scripts drive it:

- `capture.sh` — snapshots the live machine into this repo. Allowlist for home
  dotfiles, denylist for `~/.config`, plus package manifests and `/etc` tweaks.
- `restore.sh` — rebuilds a machine from the snapshot. Interactive, gated per
  stage, writes nothing without confirmation.

## [ Loadout ]

```
home/        zsh · bash · p10k · git · gtk dotfiles
config/      hypr · waybar · rofi · wofi · dunst · swaync · wlogout
             kitty · foot · ghostty · fastfetch · btop · cava · mpv
             wallust · matugen · Kvantum · qt5ct/qt6ct · nvim · yazi
system/      grub · mkinitcpio · greetd · cpu-powersave.service
ai/          llama-swap.yaml · qwen launcher · user service unit
bin/         omarchy theme tooling (sync · set · menu · next · list)
packages/    pacman explicit + native · AUR · pipx · flatpak · units
```

## [ Theming ]

Two modes coexist. `Ctrl + Alt + W` keeps the original wallpaper-driven
wallust pipeline; `Super + Shift + T` applies one of 22 curated Omarchy
palettes, ported verbatim from upstream and pushed through the same wallust
templates so every app reskins at once. See [`docs/THEMES.md`](docs/THEMES.md).

## [ Hybrid Shell ]

Waybar keeps the bar. Omarchy's Quickshell shell runs beside it with its own
bar suppressed, lending only its panels and search menu — bluetooth, wifi,
audio and display open under the button that summoned them, themed in step
with everything else. See [`docs/HYBRID.md`](docs/HYBRID.md).

## [ Deploy ]

```
git clone git@github.com:akrvs/revenant.git
cd revenant
./restore.sh
```

Re-snapshot after tweaking the live setup:

```
./capture.sh
git add -A && git commit -m "sync: <what changed>"
git push
```

## [ Doctrine ]

Secrets never enter the snapshot. Browser profiles, SSH and GnuPG keys, cloud
credentials, wallet stores, and every engagement token (HTB, boot.dev, Qobuz)
are excluded by rule and verified by a secret scan before each commit. What
ships rebuilds the environment and nothing more.

Details in [`docs/RESTORE.md`](docs/RESTORE.md) and
[`docs/EXCLUDES.md`](docs/EXCLUDES.md).
```
┌──────────────────────────────────────────────────────────────────┐
│ break it. clone it. run it. reborn.                              │
└──────────────────────────────────────────────────────────────────┘
```
