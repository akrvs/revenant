#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME}"

log() { printf '\033[32m::\033[0m %s\n' "$1"; }
warn() { printf '\033[33m!!\033[0m %s\n' "$1"; }

confirm() {
	read -r -p "$1 [y/N] " ans
	[[ "${ans}" == "y" || "${ans}" == "Y" ]]
}

log "revenant :: system restore"
warn "this overwrites live dotfiles and config. back up anything you care about first."
confirm "proceed?" || exit 0

if ! command -v yay >/dev/null 2>&1; then
	log "bootstrapping yay"
	sudo pacman -S --needed --noconfirm base-devel git
	tmp="$(mktemp -d)"
	git clone https://aur.archlinux.org/yay.git "${tmp}/yay"
	(cd "${tmp}/yay" && makepkg -si --noconfirm)
	rm -rf "${tmp}"
fi

if confirm "install native + AUR packages?"; then
	log "native packages"
	sudo pacman -S --needed --noconfirm - <"${REPO}/packages/pacman-explicit.txt" || warn "some native packages failed"
	log "AUR packages"
	yay -S --needed --noconfirm - <"${REPO}/packages/aur.txt" || warn "some AUR packages failed"
fi

if [ -s "${REPO}/packages/pipx.txt" ] && confirm "reinstall pipx tools?"; then
	command -v pipx >/dev/null 2>&1 || sudo pacman -S --needed --noconfirm python-pipx
	while read -r p; do [ -n "${p}" ] && pipx install "${p}" || true; done <"${REPO}/packages/pipx.txt"
fi

if confirm "restore home dotfiles?"; then
	log "home dotfiles"
	for f in "${REPO}"/home/.*; do
		bn="$(basename "${f}")"
		[[ "${bn}" == "." || "${bn}" == ".." ]] && continue
		cp -a "${f}" "${HOME_DIR}/${bn}"
	done
fi

if confirm "restore ~/.config?"; then
	log "config"
	mkdir -p "${HOME_DIR}/.config"
	rsync -a "${REPO}/config/" "${HOME_DIR}/.config/"
fi

if [ -d "${REPO}/bin" ] && confirm "restore omarchy + theme tooling?"; then
	log "tooling"
	mkdir -p "${HOME_DIR}/.local/bin"
	cp -a "${REPO}"/bin/omarchy-* "${REPO}"/bin/rice-theme-* "${HOME_DIR}/.local/bin/" 2>/dev/null || true
	chmod +x "${HOME_DIR}"/.local/bin/omarchy-* "${HOME_DIR}"/.local/bin/rice-theme-* 2>/dev/null || true
	warn "run rice-theme-sync to re-fetch theme palettes and wallpapers"
fi

if confirm "reinstall the omarchy shell checkout (hybrid panels + menu)?"; then
	log "omarchy shell"
	sudo pacman -S --needed --noconfirm quickshell || warn "install quickshell manually"
	rm -rf "${HOME_DIR}/.local/share/omarchy"
	git clone --depth 1 --branch quattro https://github.com/basecamp/omarchy.git "${HOME_DIR}/.local/share/omarchy"
	rm -rf "${HOME_DIR}/.local/share/omarchy/.git"
	mkdir -p "${HOME_DIR}/.local/share/fonts"
	cp -f "${HOME_DIR}/.local/share/omarchy/default/fonts/omarchy/omarchy.ttf" "${HOME_DIR}/.local/share/fonts/" 2>/dev/null || true
	fc-cache -f >/dev/null 2>&1 || true
	if [ -f "${REPO}/patches/omarchy-shell-hybrid.patch" ]; then
		(cd "${HOME_DIR}/.local/share/omarchy" && patch -p1 <"${REPO}/patches/omarchy-shell-hybrid.patch") ||
			warn "hybrid patch did not apply, see docs/HYBRID.md"
	fi
	warn "start it with: omarchy-shell-ctl start"
fi

if confirm "restore AI stack (llama-swap)?"; then
	log "ai stack"
	mkdir -p "${HOME_DIR}/ai/etc" "${HOME_DIR}/ai/bin" "${HOME_DIR}/.config/systemd/user"
	cp -a "${REPO}/ai/etc/llama-swap.yaml" "${HOME_DIR}/ai/etc/" 2>/dev/null || true
	cp -a "${REPO}/ai/bin/qwen" "${HOME_DIR}/ai/bin/" 2>/dev/null || true
	cp -a "${REPO}/ai/llama-swap.service" "${HOME_DIR}/.config/systemd/user/" 2>/dev/null || true
	systemctl --user daemon-reload || true
	systemctl --user enable llama-swap.service || true
fi

if confirm "restore system files to /etc (grub, mkinitcpio, greetd, cpu-powersave)?"; then
	log "system files"
	sudo cp "${REPO}/system/etc/default/grub" /etc/default/grub
	sudo cp "${REPO}/system/etc/mkinitcpio.conf" /etc/mkinitcpio.conf
	sudo mkdir -p /etc/greetd
	sudo cp "${REPO}/system/etc/greetd/config.toml" /etc/greetd/config.toml
	sudo cp "${REPO}/system/etc/systemd/system/cpu-powersave.service" /etc/systemd/system/cpu-powersave.service
	sudo systemctl daemon-reload
	sudo systemctl enable cpu-powersave.service greetd.service || true
	warn "run: sudo mkinitcpio -P && sudo grub-mkconfig -o /boot/grub/grub.cfg"
fi

log "restore complete"
warn "manual steps remain, see docs/RESTORE.md"
