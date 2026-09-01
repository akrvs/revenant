# Operations — What Breaks, and How To Fix It

Notes to future me. Everything here is a real failure mode of this setup, not a
hypothetical.

## First move when the desktop looks wrong

The Omarchy shell is additive. Nothing else depends on it, so it is always safe
to switch off and think later:

```
omarchy-shell-ctl stop      # panels, menu, agent usage go away
omarchy-shell-ctl start     # bring them back
```

Waybar, swaync, hyprlock, rofi and the wallpaper pipeline all keep working
without it.

## quickshell upgrades

**The three QML patches are written against quickshell's API.** A quickshell
release can break them, and the symptom is the bar and panels vanishing or the
shell refusing to start.

- Check with `omarchy-shell-ctl log`.
- If it is broken, `omarchy-shell-ctl stop` returns you to plain waybar
  instantly. The bar is waybar's, so it never disappears with the shell.
- Then either fix the patch or stay on the previous quickshell from
  `/var/cache/pacman/pkg`.

Patched files, all under `~/.local/share/omarchy/shell/`:

| File | Why |
| --- | --- |
| `Ui/KeyboardPanel.qml` | places every first-party panel below waybar and under the pointer |
| `Ui/PopupCard.qml` | same, for tray and media popups |
| `plugins/notifications/Service.qml` | toast clearance (inert while swaync owns notifications) |

All three are gated on `OMARCHY_EXTERNAL_BAR_OFFSET` and do nothing when it is
unset, so reverting is just removing the patch.

## Updating the omarchy checkout

`~/.local/share/omarchy` is a plain clone, not a package. Updating it
**overwrites the three patches and deletes the local opencode collector**.
After any update:

```
cd ~/.local/share/omarchy
patch -p1 < ~/Desktop/Projects/revenant/patches/omarchy-shell-hybrid.patch
cp ~/Desktop/Projects/revenant/omarchy-bin/* ~/.local/share/omarchy/bin/
chmod +x ~/.local/share/omarchy/bin/omarchy-agent-usage-*
omarchy-shell-ctl restart
```

## Hyprland upgrades

No Hyprland plugins are installed, which removes the usual breakage. Only
`grimblast-git` depends on Hyprland and it is a shell script, so an ABI change
does not touch it. What can still bite is deprecated config keys in the
JaKooLit tree: `hyprctl reload` and read the errors.

## Things that look broken but are not

- **A pill on waybar is unreadable.** The palette changed without
  `contrast.css` being regenerated. Run
  `~/.config/waybar/scripts/gen-contrast.sh` and restart waybar. Both theming
  paths call it, so this only happens if one is edited.
- **Panels open on top of waybar.** `OMARCHY_EXTERNAL_BAR_OFFSET` is unset, so
  the shell was started outside `omarchy-shell-ctl`. Restart it through the
  script, which derives the offset from waybar's own config.
- **Panels open in the wrong place horizontally.** `/tmp/omarchy-anchor-x` is
  the pointer hint `omarchy-panel` writes before summoning. Harmless if stale.
- **A panel does nothing.** Its widget has to be listed in `bar.layout` in
  `~/.config/omarchy/shell.json`, even though the bar itself is hidden, because
  the popup anchors to that widget.
- **The crash watcher is silent.** It skips every crash until a default agent
  is set (`~/.config/omarchy/defaults/agent`).

## Traps already hit, so they are not hit twice

- **`idle: {screensaver: 0, lock: 0}` in `shell.json` means "immediately", not
  "off".** It had the shell trying to lock the machine in a loop. Idle is
  hypridle's job here; `omarchy.idle` stays in `disabledPlugins`.
- **Omarchy ships its own `omarchy-theme-set` and `omarchy-theme-list`.** The
  local theme tooling is named `rice-theme-*` for that reason. Omarchy's `bin/`
  is deliberately kept off the global PATH; only the wrapper scripts prepend it.
- **`omarchy-notification-wait` waits on omarchy's notifications plugin**,
  which is disabled in favour of swaync, so it can never pass. The shim in
  `~/.local/bin` waits on the D-Bus server alone, and the crash-watch unit puts
  `~/.local/bin` first in PATH so the shim wins.
- **`omarchy-default-agent <name>` installs the agent through mise.** mise is
  not installed and the agents here are direct installs, so the default is set
  by writing `~/.config/omarchy/defaults/agent` directly.
- **PATH lives in `~/.zshenv`, not only `.zshrc`.** zsh reads `.zshrc` only for
  interactive shells, so anything launched by a keybind, a systemd unit or
  `ghostty -e` used to see only `/bin:/usr/bin`. Keep new PATH entries in
  `.zshenv`.
- **`xdg-terminal-exec` and `uwsm-app` are local shims**, not packages. Omarchy
  calls both and neither exists on Arch. They map onto ghostty and a direct
  exec respectively.

## Restoring the machine

`./restore.sh` is interactive and gated per stage. It reinstalls packages,
dotfiles, `~/.config`, `/etc`, the AI stack, the omarchy checkout (re-cloned,
patched, collector restored) and the tooling.

Not stored here, and needing manual work: BIOS settings, secrets (SSH, GnuPG,
cloud, engagement tokens), and `mkinitcpio -P` plus `grub-mkconfig` after any
`/etc` restore.

## Rollback

Root is BTRFS with `timeshift-autosnap`, so a snapshot is taken before every
pacman upgrade. `sudo timeshift --list` to see them. `/var/cache/pacman/pkg`
holds the previous versions for a targeted downgrade when a full rollback is
too blunt.

## graphical-session.target never activates

This session never reaches `graphical-session.target`, so a user unit that is
only `WantedBy=graphical-session.target` will sit `enabled` but `inactive`
forever after a reboot. swaync survives that because it is D-Bus activated;
`omarchy-crash-watch` did not, and came back dead after the first reboot even
though `systemctl --user is-enabled` said `enabled`.

It is started explicitly from `Startup_Apps.conf`, placed after the
`import-environment` line so its `ConditionEnvironment=WAYLAND_DISPLAY` can
pass. Any future user unit needs the same treatment — check with
`systemctl --user is-active <unit>` after a reboot, not just `is-enabled`.
