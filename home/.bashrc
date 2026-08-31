#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='eza --icons=auto'
alias ll='eza -l --icons=auto'
alias la='eza -la --icons=auto'
alias grep='grep --color=auto'
alias cat='bat'
alias top='btop'
alias htop='btop'
alias claude-4.6="claude --model claude-opus-4-6 --dangerously-skip-permissions"
PS1='[\u@\h \W]\$ '

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/akrvs/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/akrvs/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/akrvs/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/akrvs/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<



# Added by Antigravity CLI installer
export PATH="/home/akrvs/.local/bin:$PATH"

# Added by GDK bootstrap
eval "$(/home/akrvs/.local/bin/mise activate bash)"
