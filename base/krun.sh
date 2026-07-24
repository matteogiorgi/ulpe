#!/bin/sh

# krun.sh — execution dispatcher for Vim's terminal
# usage: krun.sh {c|go|sh|awk|scheme|r|javascript|json|jsonc} file

# C HANDLER
run_c() {
    command -v tcc >/dev/null 2>&1 || return 1
    exec tcc -run "$1"
}

# GO HANDLER
run_go() {
    command -v go >/dev/null 2>&1 || return 1
    exec go run "$1"
}

# SH HANDLER
run_sh() {
    case "$(head -n 1 "$1")" in
        *bash*) exec bash "$1" ;;
        *) exec sh "$1" ;;
    esac
}

# AWK HANDLER
run_awk() {
    command -v awk >/dev/null 2>&1 || return 1
    exec awk -f "$1"
}

# SCHEME HANDLER
run_scheme() {
    command -v guile >/dev/null 2>&1 || return 1
    exec guile --no-auto-compile "$1"
}

# R HANDLER
run_r() {
    command -v Rscript >/dev/null 2>&1 || return 1
    exec Rscript "$1"
}

# JS HANDLER
run_js() {
    command -v node >/dev/null 2>&1 || return 1
    exec node "$1"
}

# OUTPUT
[ -n "$2" ] || exit 1
case "$1" in
    c) run_c "$2" ;;
    go) run_go "$2" ;;
    sh) run_sh "$2" ;;
    awk) run_awk "$2" ;;
    scheme) run_scheme "$2" ;;
    r) run_r "$2" ;;
    javascript | json | jsonc) run_js "$2" ;;
    *) exit 1 ;;
esac
