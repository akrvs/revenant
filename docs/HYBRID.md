# Omarchy Hybrid Shell

Waybar stays the bar. The Omarchy Quickshell shell runs alongside it with its own bar suppressed, contributing only its panels and menu.

## Why a hybrid

Omarchy 4 replaced Waybar with a Quickshell/QML desktop shell — one long-running process hosting the bar, menu, panels, notifications, lock, polkit and background as plugins. Its panels are far richer than Waybar modules (live network stats with a DNS switcher, per-app audio routing with a mic meter), but its bar is not the JaKooLit rice. So the shell runs headless and Waybar keeps the bar.

## Layout

| Piece | Owner |
| --- | --- |
| Bar | waybar (`config.jsonc`, `[Colored] Chroma Glow`) |
| Panels, menu | omarchy shell |
| Notifications | swaync |
| Lock | hyprlock |
| Polkit | `polkit-kde-authentication-agent-1` |
| Wallpaper | swww + `Ctrl+Alt+W` |

`omarchy.notifications`, `omarchy.lock`, `omarchy.polkit` and `omarchy.background` are listed in `disabledPlugins` in `~/.config/omarchy/shell.json` so they never contend with the tools above.

## Hiding the omarchy bar

There is no supported "no bar" setting — an unknown `bar.id` falls back to the built-in bar. Omarchy instead ships a `bar-off` flag:

```
~/.local/state/omarchy/toggles/bar-off
```

`omarchy-shell-ctl start` creates it. The bar window stays mapped but parks off-screen with its exclusion zone ignored, so it reserves no space and waybar is unobstructed.

## Panel placement

Because the bar window is off-screen, panels would anchor to it and land on top of waybar. Two adjustments fix that, both driven by `OMARCHY_EXTERNAL_BAR_OFFSET`:

- **Vertical** — panels and toasts clear the external bar's real height. `omarchy-shell-ctl` reads waybar's own `height` + `margin-top` from its config and exports the value, so restyling waybar keeps this correct.
- **Horizontal** — the hidden bar's widgets sit nowhere near waybar's buttons, so `omarchy-panel` writes the pointer position to `/tmp/omarchy-anchor-x` before summoning and the panel centres on it. Panels open under the button that was clicked.

Both live in `patches/omarchy-shell-hybrid.patch` (see below) and are inert when the variable is unset.

## Buttons

One panel per button; the module's original action moves to right-click.

| Waybar button | Left-click | Right-click |
| --- | --- | --- |
| `bluetooth` | Bluetooth panel | `rfkill toggle bluetooth` |
| `network` | Wi-Fi panel | `networkmanager_dmenu` |
| `pulseaudio` | Audio panel | `volume.sh` |
| `custom/brightness` | Display panel | `brightness.sh` |

`omarchy.monitor` is named "Display" — brightness, text size and scale — not system monitoring, so it belongs on the brightness button. The cpu, memory, temperature, disk and sysload modules keep their original behaviour.

## Keybinds

```
Super              rofi (unchanged)
Super + Alt + Space    omarchy search menu
Super + Ctrl + Escape  omarchy system menu (lock, suspend, restart, shutdown)
Super + Escape         wlogout (unchanged)
Super + Shift + T      theme picker
Super + Ctrl + T       cycle theme
```

`omarchy.power` is a battery/power-profile panel and renders nothing on a desktop with no battery, which is why the system menu route is used for power actions instead.

## Commands

| Command | Purpose |
| --- | --- |
| `omarchy-shell-ctl start\|stop\|restart\|status\|log` | Manage the shell |
| `omarchy-shell-ctl notifications-omarchy\|notifications-swaync` | Swap notification daemon |
| `omarchy-panel <id> [toggle\|summon\|hide]` | Open a panel |
| `omarchy-panel menu [route]` | Open the menu at a route |
| `omarchy-ipc <target> <method> [args]` | Raw shell IPC |

## Upstream patches

Three upstream files carry local changes:

- `shell/Ui/KeyboardPanel.qml` — panel placement (all first-party panels use this)
- `shell/Ui/PopupCard.qml` — same, for tray and media popups
- `shell/plugins/notifications/Service.qml` — toast clearance (inert while notifications are swaync's)

Updating the checkout overwrites them. Reapply with:

```
cd ~/.local/share/omarchy
patch -p1 < ~/Desktop/Projects/revenant/patches/omarchy-shell-hybrid.patch
omarchy-shell-ctl restart
```

## Name collisions

Omarchy ships 441 binaries, including its own `omarchy-theme-set` and `omarchy-theme-list`. The local theme tooling is therefore named `rice-theme-*`. Omarchy's `bin/` is deliberately kept out of the global PATH — only the wrapper scripts prepend it — so nothing shadows existing commands.

## Reinstalling the checkout

`~/.local/share/omarchy` (78 MB) is not stored in this repo:

```
git clone --depth 1 --branch quattro https://github.com/basecamp/omarchy.git ~/.local/share/omarchy
rm -rf ~/.local/share/omarchy/.git
cp ~/.local/share/omarchy/default/fonts/omarchy/omarchy.ttf ~/.local/share/fonts/ && fc-cache -f
cd ~/.local/share/omarchy && patch -p1 < ~/Desktop/Projects/revenant/patches/omarchy-shell-hybrid.patch
```

Requires the `quickshell` package.
