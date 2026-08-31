# zsh reads this for every invocation; .zshrc only for interactive ones.
#
# All PATH entries used to live in .zshrc alone, so anything launched without
# an interactive shell — `ghostty -e cmd`, systemd units, scripts — saw only
# /bin:/usr/bin:/usr/ucb:/usr/local/bin. The same entries live here so they
# apply everywhere; .zshrc still exports them and typeset -U keeps the result
# free of duplicates.

typeset -U path PATH

path=(
  "$HOME/ai/bin"
  "$HOME/.local/bin"
  "$HOME/Downloads/external_hacking_tools/bin"
  "$HOME/.opencode/bin"
  "$HOME/.npm-global/bin"
  $path
  "$HOME/Downloads/external_hacking_tools"
)

export PATH
