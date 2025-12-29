# ~/.bashrc
# ---------
# Script executed by Bash at every interactive, non-login shell startup.
# Read /etc/bash.bashrc and /usr/share/doc/bash/examples/startup-files
# for system-wide configurations and examples (apt install bash-doc).




### Interactive-Shell
#####################

case $- in
    *i*) :;;
    *) return;;
esac




### History & Options
#####################

HISTCONTROL=ignoreboth
HISTTIMEFORMAT='%F %T '
HISTSIZE=1000
HISTFILESIZE=2000
# ---
shopt -s histappend
shopt -s checkwinsize
shopt -s globstar




### Lesspipe & Chroot
#####################

if [[ -x /usr/bin/lesspipe ]]; then
    eval "$(SHELL=/bin/sh lesspipe)"
fi
# ---
if [[ -z "${debian_chroot:-}" ]] && [[ -r /etc/debian_chroot ]]; then
    debian_chroot=$(</etc/debian_chroot)
fi




### Functions
#############

git_branch() {
    \git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' \
          -e "s/* \(.*\)/ (\1$( [[ -n $(\git status --porcelain 2>/dev/null) ]] && echo '*' ))/"
}
# ---
fexplore() {
    command -v fzy &>/dev/null || return
    local FEXPLORE TMP="/tmp/fexplore$$"
    (
        while FEXPLORE="$(\ls -aF --ignore="." --ignore=".git" --group-directories-first | `
              `\fzy -p "$(pwd | sed "s|^$HOME|~|")$(git_branch "(%s)") > ")"; do
            FEXPLORE="$PWD/${FEXPLORE%[@|*|/]}"
            if [[ -d "$FEXPLORE" ]]; then
                cd "$FEXPLORE" || return
                printf '%s\n' "$FEXPLORE" > "$TMP"
                continue
            fi
            case "$(file --mime-type "$FEXPLORE" -bL)" in
                text/* | application/json) "${EDITOR:=/usr/bin/vi}" "$FEXPLORE";;
                *) xdg-open "$FEXPLORE" &>/dev/null;;
            esac
        done
    )
    [[ -f "$TMP" ]] || return
    cd "$(<"$TMP")" || return
    rm -f "$TMP"
}
# ---
ffind() {
    command -v fzy &>/dev/null || return
    local FFIND="$(\fdfind . --type file 2>/dev/null)" || \
          FFIND="$(\find . -type f -not -path '*/\.*' -not -path '.')"
    FFIND="$(echo "$FFIND" | sed 's|^\./||' | `
          `\fzy -p "$(pwd | sed "s|^$HOME|~|")$(git_branch "(%s)") > ")"
    [[ -f "$FFIND" ]] || return
    case "$(file --mime-type "$FFIND" -bL)" in
        text/* | application/json) "${EDITOR:=/usr/bin/vi}" "$FFIND";;
        *) xdg-open "$FFIND" &>/dev/null;;
    esac
}
# ---
fjump() {
    command -v fzy &>/dev/null || return
    local TMP="/tmp/fjump$$"
    local FJUMP="$(\fdfind . --type directory 2>/dev/null)" || \
          FJUMP="$(find . -type d -not -path '*/\.*' -not -path '.')"
    (
        FJUMP="$(echo "$FJUMP" | sed 's|^\./||' | `
              `\fzy -p "$(pwd | sed "s|^$HOME|~|")$(git_branch "(%s)") > ")"
        [[ -d "$FJUMP" ]] && printf '%s\n' "$FJUMP" > "$TMP"
    )
    [[ -f "$TMP" ]] || return
    cd "$(<"$TMP")" || return
    rm -f "$TMP"
}
# ---
fhook() {
    (command -v tmux && command -v fzy) &>/dev/null || return
    if [[ -n "$TMUX" ]]; then
        \tmux display-message -p 'attached to #S'
        return
    fi
    local FHOOK BASENAME=${PWD##*/}; BASENAME=${BASENAME:0:37}
    local SESSIONS="$(\tmux list-sessions -F '#{session_name}' 2>/dev/null)"
    local SCOUNTER="$(\tmux list-sessions 2>/dev/null | wc -l)"
    if \tmux has-session -t "$BASENAME" 2>/dev/null; then
        if FHOOK="$(echo "$SESSIONS" | \fzy -p "tmux-sessions ($SCOUNTER) > ")"; then
            \tmux attach -t "$FHOOK"
        fi
    elif FHOOK="$( (echo "$BASENAME (new)"; echo "$SESSIONS") | `
          `\fzy -p "tmux-sessions ($SCOUNTER) > " )"; then
        if [[ "$FHOOK" == "$BASENAME (new)"  ]]; then
            \tmux new-session -c "$PWD" -s "$BASENAME"
            return
        fi
        \tmux attach -t "$FHOOK"
    fi
}
# ---
fgit() {
    (command -v git && command -v fzy) &>/dev/null || return
    if [[ $(\git rev-parse --is-inside-work-tree 2>/dev/null) != "true" ]]; then
        echo "'$PWD' is not a git repo"
        return
    fi
    local FGIT
    if FGIT="$(\git log --graph --format="%h%d %s %cr" "$@" | `
          `\fzy -p "$(pwd | sed "s|^$HOME|~|")$(git_branch "(%s)") > ")"; then
        FGIT="$(echo "$FGIT" | grep -o '[a-f0-9]\{7\}')"
        \git diff "$FGIT"
    fi
}
# ---
fbase() {
    command -v git &>/dev/null || return
    if [[ $(\git rev-parse --is-inside-work-tree 2>/dev/null) != "true" ]]; then
        echo "'$PWD' is not a git repo"
        return
    fi
    if [[ $(\git rev-parse --show-toplevel 2>/dev/null) == "$PWD" ]]; then
        echo "'$PWD' is already toplevel"
        return
    fi
    cd "$(\git rev-parse --show-toplevel 2>/dev/null)"
}
# ---
fkill() {
    command -v fzy &>/dev/null || return
    local FKILL
    if FKILL="$(ps --no-headers -H -u "$USER" -o pid,cmd | \fzy -p "$USER processes > ")"; then
        local PROCPID="$(echo "$FKILL" | awk '{print $1}')"
        local PROCCMD="$(echo "$FKILL" | awk '{$1=""; sub(/^ /, ""); print}')"
        local FKILLSIGNAL
        if FKILLSIGNAL="$(printf " 0 SIGNULL\n 1 SIGHUP\n 2 SIGINT\n 3 SIGQUIT\n 4 SIGILL\n`
              ` 5 SIGTRAP\n 6 SIGABRT\n 7 SIGBUS\n 8 SIGFPE\n 9 SIGKILL\n10 SIGUSR1\n`
              `11 SIGSEGV\n12 SIGUSR2\n13 SIGPIPE\n14 SIGALRM\n15 SIGTERM\n16 SIGSTKFLT\n`
              `17 SIGCHLD\n18 SIGCONT\n19 SIGSTOP\n20 SIGTSTP\n21 SIGTTIN\n22 SIGTTOU\n`
              `23 SIGURG\n24 SIGXCPU\n25 SIGXFSZ\n26 SIGVTALRM\n27 SIGPROF\n28 SIGWINCH\n`
              `29 SIGIO\n30 SIGPWR\n31 SIGSYS\n" | \
              \fzy -p "process '${PROCCMD:0:50}' selected > ")"; then
            if [[ "${FKILLSIGNAL:0:2}" == " 0" ]]; then
                echo "process '${PROCCMD:0:50}' intact"
                return
            fi
            kill -s "${FKILLSIGNAL:0:2}" "$PROCPID"
            echo "process '${PROCCMD:0:50}' signaled with ${FKILLSIGNAL:3}"
        fi
    fi
}




### PS1 (with color support)
############################

if [[ -x /usr/bin/tput ]] && tput setaf 1 >&/dev/null; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;90m\]\t\[\033[00m\] '
    PS1+='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;94m\]\w\[\033[00m\]'
    PS1+='\[\033[01;33m\]$(git_branch "(%s)")\[\033[00m\]\n '
else
    PS1='${debian_chroot:+($debian_chroot)}\t \u@\h:\w'
    PS1+='$(git_branch "(%s)")\n '
fi




### Color-Support
#################

export LESS_TERMCAP_mb=$'\e[01;31m'
export LESS_TERMCAP_md=$'\e[01;31m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;44;37m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_us=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
# ---
if [[ -x /usr/bin/dircolors ]]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
fi




### Aliases
###########

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" \
"$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
# ---
alias lf='ls -CF'
alias la='ls -A'
alias ll='ls -alFtr'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias fgrep='grep -F'
alias egrep='grep -E'
if [ "${XDG_SESSION_TYPE:-}" = 'x11' ] && [ -n "${DISPLAY:-}" ]; then
    alias xcopy='xclip -in -selection clipboard'
    alias xpasta='xclip -out -selection clipboard'
elif [ "${XDG_SESSION_TYPE:-}" = 'wayland' ] && [ -n "${WAYLAND_DISPLAY:-}" ]; then
    alias xcopy='wl-copy <'
    alias xpasta='wl-paste'
fi




### Completion
##############

if ! shopt -oq posix; then
    if [[ -f /usr/share/bash-completion/bash_completion ]]; then
        . /usr/share/bash-completion/bash_completion
    elif [[ -f /etc/bash_completion ]]; then
        . /etc/bash_completion
    fi
fi




## Mode & Binds (no ~/.inputrc)
###############################

set -o vi
bind 'set show-mode-in-prompt on'
bind 'set vi-ins-mode-string ">"'
bind 'set vi-cmd-mode-string "$"'
# ---
bind 'TAB:menu-complete'
bind '"\e[Z":menu-complete-backward'
# ---
bind 'set show-all-if-ambiguous on'
bind 'set show-all-if-unmodified on'
bind 'set completion-ignore-case on'
bind 'set completion-prefix-display-length 3'
bind 'set mark-symlinked-directories on'
bind 'set visible-stats on'
bind 'set colored-stats on'
# ---
bind -m vi-command -x '"\C-l": clear -x && echo ${PS1@P}'
bind -m vi-command -x '"\C-e": fexplore && echo ${PS1@P}'
bind -m vi-command -x '"\C-b": fbase && echo ${PS1@P}'
bind -m vi-command -x '"\C-j": fjump && echo ${PS1@P}'
bind -m vi-command -x '"\C-k": fhook'
bind -m vi-command -x '"\C-f": ffind'
bind -m vi-command -x '"\C-g": fgit'
bind -m vi-command -x '"\C-x": fkill'
bind -m vi-insert -x '"\C-l": clear -x && echo ${PS1@P}'
bind -m vi-insert -x '"\C-e": fexplore && echo ${PS1@P}'
bind -m vi-insert -x '"\C-b": fbase && echo ${PS1@P}'
bind -m vi-insert -x '"\C-j": fjump && echo ${PS1@P}'
bind -m vi-insert -x '"\C-k": fhook'
bind -m vi-insert -x '"\C-f": ffind'
bind -m vi-insert -x '"\C-g": fgit'
bind -m vi-insert -x '"\C-x": fkill'




### System-Fetcher
##################

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    mkdir -p "$HOME/.local/bin"
    export PATH="$PATH:$HOME/.local/bin"
fi
# ---
if command -v fetch.sh &>/dev/null; then
    fetch.sh 2>/dev/null
fi
