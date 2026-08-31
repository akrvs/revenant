# Keybinds Added

Everything below was added on top of the stock JaKooLit binds, in
`~/.config/hypr/UserConfigs/UserKeybinds.conf`. Existing binds were not moved:
`Super` is still rofi, `Super+Escape` is still wlogout, `Super+T` is still the
terminal.

## Theming

| Keys | Action |
| --- | --- |
| `Super + Shift + T` | Theme picker (rofi, 22 Omarchy palettes) |
| `Super + Ctrl + T` | Cycle to the next theme |
| `Ctrl + Alt + W` | Wallpaper-derived colors (pre-existing, unchanged) |

## Omarchy shell

| Keys | Action |
| --- | --- |
| `Super + Alt + Space` | Omarchy search menu |
| `Super + Ctrl + Escape` | System menu: lock, suspend, restart, shutdown |

## Overlays

| Keys | Action |
| --- | --- |
| `Super + V` | Omarchy clipboard history |
| `Super + Alt + V` | Rofi clipboard history (cliphist) |
| `Super + E` | Omarchy emoji picker |

## Capture

| Keys | Action |
| --- | --- |
| `Super + Shift + X` | OCR a screen region into the clipboard |
| `Super + Alt + Q` | Decode a QR code from a screen region |
| `Super + Ctrl + R` | Start / stop screen recording |
| `Super + Print` | Screenshot (pre-existing, swappy) |
| `Super + Shift + S` | Screenshot with annotation (pre-existing) |

## Misc

| Keys | Action |
| --- | --- |
| `Super + Alt + O` | Toggle nightlight (hyprsunset, 6500K ↔ 4000K) |

## Waybar buttons

Left-click opens an Omarchy panel; the module's original action moved to
right-click.

| Button | Left-click | Right-click |
| --- | --- | --- |
| Bluetooth | Bluetooth panel | `rfkill toggle bluetooth` |
| Network | Wi-Fi panel | `networkmanager_dmenu` |
| Volume | Audio panel | `volume.sh` |
| Brightness | Display panel | `brightness.sh` |
