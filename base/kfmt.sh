#!/bin/sh

# kfmt.sh — formatter dispatcher for Vim
# usage: kfmt.sh {c|sh|bash|go|js|r} file
# exit: 0 if formatted, 1 otherwise

# C HANDLER
fmt_c() {
    command -v indent >/dev/null 2>&1 || return 1
    indent -kr -nce -nut -i4 -l120 "$1" 2>/dev/null
}

# SH HANDLER
fmt_sh() {
    command -v shfmt >/dev/null 2>&1 || return 1
    shfmt -ln posix -i 4 -ci -w "$1" 2>/dev/null
}

# BASH HANDLER
fmt_bash() {
    command -v shfmt >/dev/null 2>&1 || return 1
    shfmt -ln bash -i 4 -ci -w "$1" 2>/dev/null
}

# GO HANDLER
fmt_go() {
    command -v gofmt >/dev/null 2>&1 || return 1
    gofmt -w "$1" 2>/dev/null
}

# JS HANDLER
fmt_js() {
    command -v prettier >/dev/null 2>&1 || return 1
    prettier --write --tab-width 4 --print-width 120 "$1" >/dev/null 2>&1
}

# R HANDLER
fmt_r() {
    command -v Rscript >/dev/null 2>&1 || return 1
    Rscript --vanilla -e '
args <- commandArgs(TRUE)
styler::style_file(args[1], transformers = styler::tidyverse_style(indent_by = 4))
' "$1" >/dev/null 2>&1
}

# OUTPUT
[ -n "$2" ] || exit 1
case "$1" in
    c) fmt_c "$2" ;;
    sh) fmt_sh "$2" ;;
    bash) fmt_bash "$2" ;;
    go) fmt_go "$2" ;;
    js) fmt_js "$2" ;;
    r) fmt_r "$2" ;;
    *) exit 1 ;;
esac
