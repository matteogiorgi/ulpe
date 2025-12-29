# ~/.bash_logout
# --------------
# Script executed by bash(1) when login shell exits,
# the default is located in /etc/bash.bash_logout.


if [[ "$SHLVL" = 1 ]]; then
    [[ -x /usr/bin/clear_console ]] && /usr/bin/clear_console -q
fi
