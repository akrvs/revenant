#!/usr/bin/env python3
"""Rofi script mode: dynamic app search."""
import os, sys, glob, subprocess

query = sys.argv[1] if len(sys.argv) > 1 else ''
retv  = int(os.environ.get('ROFI_RETV', 0))
info  = os.environ.get('ROFI_INFO', '')

# User selected an entry — launch it
if retv in (1, 2) and info:
    subprocess.Popen(['gtk-launch', info], start_new_session=True)
    sys.exit(0)

search = query.strip().lower()

# Collect apps (filter if search is non-empty, return all if empty)
seen    = set()
results = []
dirs    = [
    os.path.expanduser('~/.local/share/applications'),
    '/usr/share/applications',
]

for d in dirs:
    for fpath in sorted(glob.glob(os.path.join(d, '*.desktop'))):
        try:
            props    = {}
            in_entry = False
            with open(fpath, encoding='utf-8', errors='ignore') as f:
                for line in f:
                    line = line.strip()
                    if line == '[Desktop Entry]':
                        in_entry = True
                        continue
                    if line.startswith('[') and in_entry:
                        break
                    if in_entry and '=' in line and not line.startswith('#'):
                        k, _, v = line.partition('=')
                        if k not in props:
                            props[k] = v

            if props.get('NoDisplay', '').lower() == 'true': continue
            if props.get('Type', '')                        != 'Application': continue
            if props.get('Hidden', '').lower()  == 'true': continue

            name = props.get('Name', '')
            if not name or name in seen:
                continue
            seen.add(name)

            if search:
                searchable = ' '.join([
                    name,
                    props.get('Comment', ''),
                    props.get('GenericName', ''),
                    props.get('Keywords', ''),
                ]).lower()
                if search not in searchable:
                    continue

            icon   = props.get('Icon', '')
            app_id = os.path.basename(fpath)[:-8]  # strip .desktop
            row    = name
            if icon: row += f'\x00icon\x1f{icon}'
            row   += f'\x00info\x1f{app_id}'
            results.append(row)

        except Exception:
            pass

# Always output all (or filtered) results so rofi keeps re-calling this script.
# Hide the listview when nothing has been typed yet.
if not search:
    print('\x00theme\x1flistview { lines: 0; }')
else:
    print('\x00theme\x1flistview { lines: 8; }')

for row in sorted(results):
    print(row)
