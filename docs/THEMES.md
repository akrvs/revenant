# Omarchy Theme System

Omarchy's curated theming grafted onto the existing JaKooLit rice, without replacing it. Two theming modes now coexist.

| Mode | Trigger | Behaviour |
| --- | --- | --- |
| Dynamic | `Ctrl + Alt + W` | Cycles wallpaper, wallust derives the palette from the image, matugen feeds Spicetify/Cava. Unchanged from before. |
| Fixed | `Super + Shift + T` | Applies a curated Omarchy palette and that theme's wallpaper. |

## How it works

Every themed app already reads colors from a wallust template target (hyprland, waybar, rofi, swaync, dunst, kitty, cava, zathura, rmpc, neovim). Rather than duplicate per-app theming, the Omarchy palettes are converted into wallust colorschemes and applied through that same pipeline. One command reskins everything.

Palettes are ported verbatim from `basecamp/omarchy` (branch `quattro`), where each theme ships a single semantic `colors.toml`. `rice-theme-sync` fetches those, maps them onto wallust's 16-color scheme, and writes:

- `~/.config/wallust/colorschemes/omarchy-<theme>.json`
- `~/.config/omarchy/themes/<theme>/theme.conf`
- `~/.config/omarchy/themes/<theme>/colors.toml`
- `~/.config/omarchy/themes/<theme>/backgrounds/`

The raw `colors.toml` is kept because the Omarchy shell takes its palette the
same way upstream does: `rice-theme-set` base64-encodes it and calls the
shell's `applyTheme` IPC, so the panels, menu and toasts recolour with the bar.
See [`HYBRID.md`](HYBRID.md).

The tooling is named `rice-theme-*` rather than `omarchy-theme-*` because
Omarchy ships binaries of the latter name; see the collision note in
[`HYBRID.md`](HYBRID.md).

## Commands

| Command | Purpose |
| --- | --- |
| `rice-theme-sync` | Fetch and convert all themes from upstream. `--no-backgrounds` to skip wallpapers. |
| `rice-theme-set <name>` | Apply a theme. |
| `rice-theme-menu` | Rofi picker. |
| `rice-theme-next` | Cycle to the next theme. |
| `rice-theme-list` | List themes, current marked `*`. |

## Keybinds

Added to `~/.config/hypr/UserConfigs/UserKeybinds.conf`:

```
Super + Shift + T    theme picker
Super + Ctrl  + T    cycle theme
```

## Themes

22 themes: catppuccin, catppuccin-latte, ethereal, everforest, flexoki-light, gruvbox, hackerman, kanagawa, last-horizon, lumon, lupine, matte-black, miasma, nord, osaka-jade, retro-82, ristretto, rose-pine, solitude, tokyo-night, vantablack, white.

## Interaction between the two modes

Applying a fixed theme writes its name to `~/.config/omarchy/current-theme`. Running the wallpaper-driven pipeline overwrites the palette, so `WallustSwww.sh` now writes `dynamic` to that state file to keep it honest. That one line is the only edit made to a JaKooLit script; re-apply it if JaKooLit updates overwrite the file.

## Not captured in this repo

`~/.config/omarchy/themes/*/backgrounds/` is excluded — roughly 50 MB of upstream wallpapers, re-fetched with `rice-theme-sync`.
