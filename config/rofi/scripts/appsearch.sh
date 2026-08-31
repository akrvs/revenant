#!/bin/bash

# On selection: launch the app
if [ "${ROFI_RETV}" = "1" ] && [ -n "${ROFI_INFO}" ]; then
    gtk-launch "${ROFI_INFO}"
    exit 0
fi

QUERY="$1"
[ -z "$QUERY" ] && exit 0

# Collect desktop files
mapfile -t files < <(
    find /usr/share/applications ~/.local/share/applications \
        -maxdepth 1 -name "*.desktop" 2>/dev/null | sort
)
[ ${#files[@]} -eq 0 ] && exit 0

# Single awk pass — uses FNR==1 to detect file boundaries (no ENDFILE needed)
awk -v q="$QUERY" '
BEGIN { ql = tolower(q) }

FNR == 1 {
    # Print previous file result if valid
    if (fn != "" && !skip && type == "Application" && name != "" && index(tolower(name), ql) > 0) {
        app = fn; sub(/.*\//, "", app); sub(/\.desktop$/, "", app)
        printf "%s\000icon\037%s\000info\037%s\n", name, icon, app
    }
    fn = FILENAME; name = ""; icon = ""; type = ""; skip = 0; in_entry = 0
}

/^\[Desktop Entry\]/  { in_entry = 1; next }
in_entry && /^\[/     { in_entry = 0 }
!in_entry             { next }

/^Type=/              { type = substr($0, 6) }
/^Name=/              { if (!name) name = substr($0, 6) }
/^Icon=/              { if (!icon) icon = substr($0, 6) }
/^NoDisplay=true/     { skip = 1 }
/^Hidden=true/        { skip = 1 }

END {
    if (!skip && type == "Application" && name != "" && index(tolower(name), ql) > 0) {
        app = FILENAME; sub(/.*\//, "", app); sub(/\.desktop$/, "", app)
        printf "%s\000icon\037%s\000info\037%s\n", name, icon, app
    }
}
' "${files[@]}" | sort
