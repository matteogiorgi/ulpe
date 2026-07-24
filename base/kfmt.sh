#!/bin/sh

# kfmt.sh — formatter dispatcher for Vim
# usage: kfmt.sh {c|go|sh|awk|r|javascript|json|jsonc} file
# exit: 0 if formatted, 1 otherwise (Vim's Formatter falls back to gg=G)

# C HANDLER
fmt_c() {
    command -v indent >/dev/null 2>&1 || return 1
    indent -kr -nce -nut -i4 -l120 "$1" 2>/dev/null
}

# GO HANDLER
fmt_go() {
    command -v gofmt >/dev/null 2>&1 || return 1
    gofmt -w "$1" 2>/dev/null
}

# SH HANDLER
fmt_sh() {
    command -v shfmt >/dev/null 2>&1 || return 1
    case "$(head -n 1 "$1")" in
        *bash*) shfmt -ln bash -i 4 -ci -w "$1" 2>/dev/null ;;
        *) shfmt -ln posix -i 4 -ci -w "$1" 2>/dev/null ;;
    esac
}

# AWK HANDLER
fmt_awk() {
    command -v gawk >/dev/null 2>&1 || return 1
    TMP=$(mktemp) || return 1
    gawk --pretty-print="$TMP" -f "$1" 2>/dev/null && [ -s "$TMP" ] &&
        expand -t 4 "$TMP" >"$TMP.e" && cat "$TMP.e" >"$1"
    RET=$?
    rm -f "$TMP" "$TMP.e"
    return $RET
}

# R HANDLER
fmt_r() {
    command -v Rscript >/dev/null 2>&1 || return 1
    Rscript --vanilla -e '
args <- commandArgs(TRUE)
styler::style_file(args[1], transformers = styler::tidyverse_style(indent_by = 4))
' "$1" >/dev/null 2>&1
}

# JS HANDLER
fmt_js() {
    command -v prettier >/dev/null 2>&1 || return 1
    prettier --write --tab-width 4 --print-width 120 "$1" >/dev/null 2>&1
}

# OUTPUT
[ -n "$2" ] || exit 1
case "$1" in
    c) fmt_c "$2" ;;
    go) fmt_go "$2" ;;
    sh) fmt_sh "$2" ;;
    awk) fmt_awk "$2" ;;
    r) fmt_r "$2" ;;
    javascript | json | jsonc) fmt_js "$2" ;;
    *) exit 1 ;;
esac
