#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Package search and install via rofi. Replaces walker's archlinuxpkgs provider
# without the elephant daemon: repo packages come from pacman, AUR from yay.

rofi_config="$HOME/.config/rofi/config-pkg.rasi"
term="kitty"

if pgrep -x "rofi" >/dev/null; then
	pkill rofi
	exit 0
fi

query=$(echo "" | rofi -dmenu -config "$rofi_config" -p "Package:")
[ -n "$query" ] || exit 0

results=$(
	{
		pacman -Ss -- "$query" 2>/dev/null | awk '
			/^[a-z]/ { split($1, p, "/"); repo=p[1]; name=p[2]; ver=$2
			           inst = /\[installed/ ? " [installed]" : ""
			           printf "%s\t%s  %s  %s%s\n", name, repo, name, ver, inst }'
		command -v yay >/dev/null 2>&1 && yay -Ss --aur -- "$query" 2>/dev/null | awk '
			/^aur\// { split($1, p, "/"); name=p[2]; ver=$2
			           inst = /\[installed/ ? " [installed]" : ""
			           printf "%s\taur  %s  %s%s\n", name, name, ver, inst }'
	} | sort -u -t$'\t' -k1,1
)

[ -n "$results" ] || {
	notify-send -a "pkg" "No packages found" "$query"
	exit 0
}

choice=$(printf '%s\n' "$results" | cut -f2- | rofi -dmenu -i -config "$rofi_config" -p "Install:")
[ -n "$choice" ] || exit 0

pkg=$(printf '%s\n' "$choice" | awk '{print $2}')
[ -n "$pkg" ] || exit 0

if printf '%s' "$choice" | grep -q '^aur'; then
	installer="yay -S --needed"
else
	installer="sudo pacman -S --needed"
fi

exec "$term" --title "Install $pkg" -e bash -c \
	"printf '\033[1;32m::\033[0m installing %s\n\n' '$pkg'; $installer '$pkg'; printf '\n\033[1;32m::\033[0m done, press enter to close'; read -r"
