#!/bin/sh

# krun.sh — execution dispatcher for Vim's terminal
# usage: krun.sh {c|go|sh|awk|scheme|r|nroff} file

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
    exec Rscript -e 'source(commandArgs(TRUE)[1])' "$1"
}

# ROFF HANDLER
run_roff() {
    command -v groff >/dev/null 2>&1 || exec less "$1"
    if grep -qE '^\.(TL|AU|NH|SH|PP|LP|IP|QP|DS|EQ|TS|nf)\b' "$1"; then
        cols=$(tput cols 2>/dev/null || echo 80)
        groff -e -t -ms -Tutf8 -rLL="${cols}n" -rPO=0 "$1" 2>/dev/null | less -R
        # to generate a PDF, use the -Tpdf flag and redirect output to a file:
        # groff -e -t -ms -Tpdf "$1" >"${1%.*}.pdf"
    else
        exec less "$1"
    fi
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
    nroff | text) run_roff "$2" ;;
    *) exit 1 ;;
esac
