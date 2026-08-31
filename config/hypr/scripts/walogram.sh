#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Theme Telegram from the current wallust palette. No-op when walogram is absent.

command -v walogram >/dev/null 2>&1 || exit 0

walogram
