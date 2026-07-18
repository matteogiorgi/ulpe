#!/bin/sh

# krun.sh — execution dispatcher for Vim's terminal
# usage: krun.sh {c|sh|bash|go|js|r} file

# C HANDLER
run_c() {
    command -v tcc >/dev/null 2>&1 || return 1
    exec tcc -run "$1"
}

# SH HANDLER
run_sh() {
    exec sh "$1"
}

# BASH HANDLER
run_bash() {
    exec bash "$1"
}

# GO HANDLER
run_go() {
    command -v go >/dev/null 2>&1 || return 1
    exec go run "$1"
}

# JS HANDLER
run_js() {
    command -v node >/dev/null 2>&1 || return 1
    exec node "$1"
}

# R HANDLER
run_r() {
    command -v Rscript >/dev/null 2>&1 || return 1
    exec Rscript "$1"
}

# OUTPUT
[ -n "$2" ] || exit 1
case "$1" in
    c) run_c "$2" ;;
    sh) run_sh "$2" ;;
    bash) run_bash "$2" ;;
    go) run_go "$2" ;;
    js) run_js "$2" ;;
    r) run_r "$2" ;;
    *) exit 1 ;;
esac
