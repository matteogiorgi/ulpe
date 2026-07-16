#!/bin/sh

# kdoc.sh — documentation dispatcher for Vim's K
# usage: kdoc.sh {c|sh|go|js} symbol

# PAGER HANDLER
page() {
    OUT=$(cat)
    [ -n "$OUT" ] && printf '%s\n' "$OUT" | less
}

# C DOCUMENTATION
doc_c() {
    man 3 "$1" 2>/dev/null || man 2 "$1" 2>/dev/null
}

# GO DOCUMENTATION
doc_go() {
    command -v go >/dev/null 2>&1 || return 0
    go doc "$1" 2>/dev/null | page
}

# SH DOCUMENTATION
doc_sh() {
    man "$1" 2>/dev/null
}

# JS DOCUMENTATION
doc_js() {
    command -v node >/dev/null 2>&1 || return 0
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

# OUTPUT
[ -n "$2" ] || exit 0
case "$1" in
    c) doc_c "$2" ;;
    sh) doc_sh "$2" ;;
    go) doc_go "$2" ;;
    js) doc_js "$2" ;;
    *) exit 0 ;;
esac
exit 0
