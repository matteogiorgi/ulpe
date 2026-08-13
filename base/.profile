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
export _PROFILE_LOADED=1




### Environment
###############

export SHELL='/usr/bin/bash'
export PAGER='/usr/bin/less'
export EDITOR='/usr/bin/vi'
export VISUAL='/usr/bin/vi'
export GOPATH="$HOME/go"
# ---
mkdir -p "$HOME/.local/bin"
for _BIN_DIRECTORY in "$HOME/.local/bin" "$GOPATH/bin"; do
	case ":$PATH:" in
		*":$_BIN_DIRECTORY:"*) ;;
		*) PATH="$PATH:$_BIN_DIRECTORY" ;;
	esac
done
# ---
unset _BIN_DIRECTORY
export PATH




### Session
###########

if [ "${XDG_SESSION_TYPE:-}" = 'x11' ] && [ -n "${DISPLAY:-}" ]; then
    export TERM='xterm-256color'
    setxkbmap -option 'caps:escape' >/dev/null 2>&1
fi




### Source .bashrc
##################

if [ -n "$BASH_VERSION" ] && [ -z "$_BASHRC_LOADED" ]; then
    export _BASHRC_LOADED=1
    [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
fi
