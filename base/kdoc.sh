#!/bin/sh

# kdoc.sh — documentation dispatcher for Vim's K
# usage: kdoc.sh {c|go|sh|awk|scheme|r} symbol

# NO DOC
nodoc() {
    printf "kdoc.sh: no documentation for '%s'\n" "$1" | less
}

# PAGER
page() {
    OUT=$(cat)
    if [ -n "$OUT" ]; then
        printf '%s\n' "$OUT" | less
        return 0
    fi
    nodoc "$1"
}

# C HANDLER
doc_c() {
    command -v man >/dev/null 2>&1 || {
        nodoc "$1"
        return 1
    }
    man 3 "$1" 2>/dev/null || man 2 "$1" 2>/dev/null || nodoc "$1"
}

# GO HANDLER
doc_go() {
    command -v go >/dev/null 2>&1 || {
        nodoc "$1"
        return 1
    }
    go doc "$1" 2>/dev/null | page "$1"
}

# SH HANDLER
doc_sh() {
    command -v man >/dev/null 2>&1 || {
        nodoc "$1"
        return 1
    }
    man "$1" 2>/dev/null || nodoc "$1"
}

# AWK HANDLER
doc_awk() {
    case "$1" in
        length | substr | index | split | sub | gsub | match | sprintf | printf | print | getline | close | system | fflush | \
            sin | cos | atan2 | exp | log | sqrt | int | rand | srand | tolower | toupper | \
            gensub | patsplit | asort | asorti | strtonum | systime | strftime | mktime | and | or | xor | compl | lshift | rshift | \
            NR | NF | FNR | FS | OFS | ORS | RS | FILENAME | SUBSEP | RSTART | RLENGTH | CONVFMT | OFMT | ENVIRON | ARGC | ARGV | \
            BEGIN | END | function | if | else | while | for | do | break | continue | next | nextfile | exit | return | delete | in) ;;
        *)
            nodoc "$1"
            return 1
            ;;
    esac
    command -v info >/dev/null 2>&1 || {
        nodoc "$1"
        return 1
    }
    info --vi-keys gawk --index-search="$1" 2>/dev/null || nodoc "$1"
}

# SCHEME HANDLER
doc_scheme() {
    command -v guile >/dev/null 2>&1 || {
        nodoc "$1"
        return 1
    }
    guile -q -c "(use-modules (ice-9 session)) (help $1)" 2>/dev/null |
        grep -v '^Did not find' | page "$1"
}

# R HANDLER
doc_r() {
    command -v Rscript >/dev/null 2>&1 || {
        nodoc "$1"
        return 1
    }
    Rscript --vanilla -e '
args <- commandArgs(TRUE)
h <- help(args[1])
if (length(h)) {
    options(pager = "cat")
    print(h)
}
' "$1" 2>/dev/null | page "$1"
}

# OUTPUT
[ -n "$2" ] || exit 1
case "$1" in
    c) doc_c "$2" ;;
    go) doc_go "$2" ;;
    sh) doc_sh "$2" ;;
    awk) doc_awk "$2" ;;
    scheme) doc_scheme "$2" ;;
    r) doc_r "$2" ;;
    *) exit 1 ;;
esac
