# Restore Runbook

## Fast path

```
git clone git@github.com:akrvs/revenant.git
cd revenant
./restore.sh
```

The script is interactive and gates every stage behind a prompt: package install, dotfiles, `~/.config`, AI stack, and `/etc` system files. Nothing is written until you confirm.

## Manual steps the script cannot do

- **BIOS / firmware.** Governor and VRR tuning assume the BIOS-level settings from the power-tuning pass. Re-apply those by hand.
- **Kernel regen after system files.** If you restored `/etc`, run:
  ```
  sudo mkinitcpio -P
  sudo grub-mkconfig -o /boot/grub/grub.cfg
  ```
- **Display manager.** Enable greetd if this is a fresh install: `sudo systemctl enable greetd.service`.
- **Spicetify themes.** `config/spicetify/Themes/` is excluded from the snapshot. Re-fetch the theme referenced in `config-xpui.ini`, then run `spicetify backup apply`.
- **Secrets never leave the machine.** SSH keys, GnuPG, browser profiles, cloud credentials, HTB/boot.dev/Qobuz tokens, and offensive-tool state are intentionally not captured. Restore them from your own secret store.

## What lives where

| Path | Restores to |
| --- | --- |
| `home/` | `~/` dotfiles |
| `config/` | `~/.config/` |
| `system/etc/` | `/etc/` |
| `ai/` | `~/ai/` and the user llama-swap unit |
| `packages/` | reference lists for pacman, AUR, pipx, flatpak, enabled units |

## Re-capturing

After changing your live setup, re-sync the snapshot with:

```
./capture.sh
git add -A && git commit -m "sync: <what changed>"
git push
```
