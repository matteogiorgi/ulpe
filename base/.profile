# ~/.profile
# ----------
# Script executed by command interpreter for login shells and not read by Bash if
# ~/.bash_profile or ~/.bash_login exists. /etc/profile hold default umask, install
# and configure libpam-umask package (umask 022), to set the umask for ssh logins.




### Prevent multiple-sourcing
#############################

if [ -n "$_PROFILE_LOADED" ]; then
    return 0
fi
# ---
export _PROFILE_LOADED=1




### Environment
###############

mkdir -p "$HOME/.local/bin"
export PATH="$PATH:$HOME/.local/bin"
export SHELL='/usr/bin/bash'
export PAGER='/usr/bin/less'
export EDITOR='/usr/bin/vi'
export VISUAL='/usr/bin/vi'




### Session
###########

if [ "${XDG_SESSION_TYPE:-}" = 'x11' ] && [ -n "${DISPLAY:-}" ]; then
    export TERM='xterm-256color'
    setxkbmap -option 'caps:escape' >/dev/null 2>&1
fi
