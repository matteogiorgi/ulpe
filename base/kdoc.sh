#!/bin/sh

# kdoc.sh — documentation dispatcher for Vim's K
# usage: kdoc.sh {c|go|sh|js|r} symbol

# PAGER
page() {
    OUT=$(cat)
    [ -n "$OUT" ] && printf '%s\n' "$OUT" | less
}

# C HANDLER
doc_c() {
    man 3 "$1" 2>/dev/null || man 2 "$1" 2>/dev/null
}

# GO HANDLER
doc_go() {
    command -v go >/dev/null 2>&1 || return 1
    go doc "$1" 2>/dev/null | page
}

# SH HANDLER
doc_sh() {
    man "$1" 2>/dev/null
}

# JS HANDLER
doc_js() {
    command -v node >/dev/null 2>&1 || return 1
    node -e '
const id = process.argv[1];
let obj;
try { obj = (0, eval)(id); } catch (e) {
    try { obj = require(id); } catch (e2) { process.exit(1); }
}
console.log("=== " + id + " ===");
console.log("type: " + typeof obj);
if (typeof obj === "function") {
    console.log("arity: " + obj.length + "\n\n" + obj.toString());
}
if (obj !== null && (typeof obj === "object" || typeof obj === "function")) {
    const props = Object.getOwnPropertyNames(obj).sort();
    if (props.length) console.log("\nproperties:\n  " + props.join(", "));
}
' "$1" 2>/dev/null | page
}

# R HANDLER
doc_r() {
    command -v Rscript >/dev/null 2>&1 || return 1
    Rscript --vanilla -e '
args <- commandArgs(TRUE)
h <- help(args[1])
if (length(h)) {
    options(pager = "cat")
    print(h)
}
' "$1" 2>/dev/null | page
}

# OUTPUT
[ -n "$2" ] || exit 1
case "$1" in
    c) doc_c "$2" ;;
    go) doc_go "$2" ;;
    sh) doc_sh "$2" ;;
    javascript | json | jsonc) doc_js "$2" ;;
    r) doc_r "$2" ;;
    *) exit 1 ;;
esac
exit 0
