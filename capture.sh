#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME}"
RSYNC="rsync -a --delete --prune-empty-dirs"

log() { printf '\033[32m::\033[0m %s\n' "$1"; }

log "packages"
pacman -Qqe >"${REPO}/packages/pacman-explicit.txt"
pacman -Qqn >"${REPO}/packages/pacman-native.txt"
pacman -Qqm >"${REPO}/packages/aur.txt"
command -v pipx >/dev/null 2>&1 && pipx list --short 2>/dev/null | awk '{print $1}' >"${REPO}/packages/pipx.txt" || true
command -v flatpak >/dev/null 2>&1 && flatpak list --app --columns=application 2>/dev/null >"${REPO}/packages/flatpak.txt" || true
systemctl --user list-unit-files --state=enabled 2>/dev/null | awk 'NR>1 && $1 ~ /\.service|\.timer/ {print $1}' >"${REPO}/packages/systemd-user-enabled.txt" || true
systemctl list-unit-files --state=enabled 2>/dev/null | awk 'NR>1 && $1 ~ /\.service|\.timer/ {print $1}' >"${REPO}/packages/systemd-system-enabled.txt" || true

log "home dotfiles"
mkdir -p "${REPO}/home"
HOME_FILES=(
	.zshrc .zshrc.pre-oh-my-zsh .shell.pre-oh-my-zsh
	.bashrc .bash_profile .bash_logout
	.p10k.zsh .gitconfig .condarc .npmrc .default-gems
	.gtkrc-2.0 .notion-enhancer
)
for f in "${HOME_FILES[@]}"; do
	[ -e "${HOME_DIR}/${f}" ] && cp -a "${HOME_DIR}/${f}" "${REPO}/home/${f}"
done

log "config"
mkdir -p "${REPO}/config"
${RSYNC} --exclude-from="${REPO}/config-exclude.txt" "${HOME_DIR}/.config/" "${REPO}/config/"

log "system"
mkdir -p "${REPO}/system/etc/default" "${REPO}/system/etc/systemd/system" "${REPO}/system/etc/greetd"
cp /etc/default/grub "${REPO}/system/etc/default/grub"
cp /etc/mkinitcpio.conf "${REPO}/system/etc/mkinitcpio.conf"
cp /etc/greetd/config.toml "${REPO}/system/etc/greetd/config.toml"
[ -e /etc/systemd/system/cpu-powersave.service ] && cp /etc/systemd/system/cpu-powersave.service "${REPO}/system/etc/systemd/system/cpu-powersave.service"

log "ai stack"
mkdir -p "${REPO}/ai/etc" "${REPO}/ai/bin"
[ -e "${HOME_DIR}/ai/etc/llama-swap.yaml" ] && cp -a "${HOME_DIR}/ai/etc/llama-swap.yaml" "${REPO}/ai/etc/"
[ -e "${HOME_DIR}/ai/bin/qwen" ] && cp -a "${HOME_DIR}/ai/bin/qwen" "${REPO}/ai/bin/"
[ -e "${HOME_DIR}/.config/systemd/user/llama-swap.service" ] && cp -a "${HOME_DIR}/.config/systemd/user/llama-swap.service" "${REPO}/ai/"

log "omarchy + rice tooling"
mkdir -p "${REPO}/bin"
for s in "${HOME_DIR}"/.local/bin/omarchy-* "${HOME_DIR}"/.local/bin/rice-theme-* "${HOME_DIR}"/.local/bin/uwsm-app; do
	[ -e "${s}" ] && cp -a "${s}" "${REPO}/bin/"
done
for s in "${HOME_DIR}"/.config/waybar/scripts/omarchy-*.sh; do
	[ -f "${s}" ] && cp -a "${s}" "${REPO}/config/waybar/scripts/" 2>/dev/null || true
done

log "local-bin manifest"
ls -1 "${HOME_DIR}/.local/bin" 2>/dev/null >"${REPO}/packages/local-bin-manifest.txt" || true

log "done"
