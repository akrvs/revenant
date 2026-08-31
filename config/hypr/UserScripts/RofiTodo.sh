#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Todo list via rofi. Replaces walker's todo provider without the elephant
# daemon. Plain-text store, one task per line, "x " marks a task done.
#
# Enter on the input line adds a task. Enter on a task toggles it.
# Alt+Delete removes the selected task. Alt+c clears everything done.

rofi_config="$HOME/.config/rofi/config-todo.rasi"
store="${XDG_DATA_HOME:-$HOME/.local/share}/todo.txt"

mkdir -p "$(dirname "$store")"
[ -f "$store" ] || : >"$store"

if pgrep -x "rofi" >/dev/null; then
	pkill rofi
	exit 0
fi

render() {
	local n=0
	while IFS= read -r line; do
		[ -n "$line" ] || continue
		n=$((n + 1))
		if [[ $line == x\ * ]]; then
			printf '%s\t󰄲  <s>%s</s>\n' "$n" "${line#x }"
		else
			printf '%s\t󰄱  %s\n' "$n" "$line"
		fi
	done <"$store"
}

toggle() {
	awk -v t="$1" 'NR==t { if ($0 ~ /^x /) sub(/^x /, ""); else $0 = "x " $0 } { print }' \
		"$store" >"$store.tmp" && mv "$store.tmp" "$store"
}

remove() {
	awk -v t="$1" 'NR!=t' "$store" >"$store.tmp" && mv "$store.tmp" "$store"
}

while true; do
	pending=$(grep -cv '^x ' "$store" 2>/dev/null || echo 0)
	choice=$(
		render | cut -f2- | rofi -dmenu -i -markup-rows \
			-config "$rofi_config" \
			-kb-custom-1 "Alt-Delete" \
			-kb-custom-2 "Alt-c" \
			-p "Todo" \
			-mesg "$pending pending  ·  enter: add/toggle  ·  alt+del: remove  ·  alt+c: clear done"
	)
	status=$?

	case "$status" in
	1) exit 0 ;;
	10 | 11)
		[ -n "$choice" ] || continue
		idx=$(render | grep -Fn -- "$choice" | head -1 | cut -d: -f1)
		[ -n "$idx" ] || continue
		if [ "$status" -eq 10 ]; then
			remove "$idx"
		else
			grep -v '^x ' "$store" >"$store.tmp" && mv "$store.tmp" "$store"
		fi
		continue
		;;
	esac

	[ -n "$choice" ] || exit 0

	idx=$(render | grep -Fn -- "$choice" | head -1 | cut -d: -f1)
	if [ -n "$idx" ]; then
		toggle "$idx"
	else
		printf '%s\n' "$choice" >>"$store"
	fi
done
