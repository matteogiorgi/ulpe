# UNIX-Like Portable Environment

This repository contains configuration files and installation scripts for a complete and efficient minimal *UNIX-like* work environment based on any [Debian](https://www.debian.org) or [Debian-based](https://distrowatch.com/search.php?basedon=Debian&status=Active#distrosearch) distribution.

The purpose of this project is to provide a vim-loving, neckbeard-like, barebone environment, fancy enough to be used as a daily driver but not too fancy to be bloated with unnecessary software and dependencies.




## Install

The only prerequisite you need to cover is a working *Debian* in any version or form. There are two installers at your disposal to ease the setup process: [`ulpe_base`](https://github.com/matteogiorgi/ulpe/blob/main/ulpe_base) and [`ulpe_plug`](https://github.com/matteogiorgi/ulpe/blob/main/ulpe_plug).

> The installers do not symlink any file, they just copy the configurations in the right place, so they can be easily modified and eventually reset running the single installer again.

To full install ULPE, launch the two installers separately (as described below) or just run the [`install`](https://github.com/matteogiorgi/ulpe/blob/main/install) script, it will execute both installers for you.




### Base

This script installs the basic packages and configures *Bash*, *Vim* and *Tmux* for you: just run `./ulpe_base` from the root of the repository, relaunch your terminal and you are good to go.




### Plug

This one installs additional plugins for your *Vim* alongside a little *vimscript* configuration to glue them together: run `./ulpe_plug` from the root of the repository, launch *Vim* and see the magic happen.

> You need to have *Vim 9.0* or higher installed for the script to work, but it won't be an issue since you should have at least a working *Debian 12* by now with the 9.1 release available.




## No-Install

If you don't want to run any installer, you can just copy the main configuration files with the following command and you got yourself a minimal ULPE. Copy-pasta this in your terminal and hit enter 😎
```sh
sh -c '
    BASE="https://raw.githubusercontent.com/matteogiorgi/ulpe/refs/heads/main/base"
    FILES=".profile .bashrc .bash_logout .tmux.conf .vimrc"
    command -v wget >/dev/null 2>&1 || { echo "ERROR: install wget"; exit 1; }
    for FILE in $FILES; do
        [ -f "$HOME/$FILE" ] && cp "$HOME/$FILE" "$HOME/$FILE.bak"
        wget -qO "$HOME/$FILE" "$BASE/$FILE" && echo "$FILE copied"
    done
    echo "finish"
'
```




## Adding a language

For predetermined filetypes, *Vim* can lookup-doc, format and execute, all wired together in [`.vimrc`](https://github.com/matteogiorgi/ulpe/blob/main/base/.vimrc) through three dispatcher scripts: [`kdoc.sh`](https://github.com/matteogiorgi/ulpe/blob/main/base/kdoc.sh), [`kfmt.sh`](https://github.com/matteogiorgi/ulpe/blob/main/base/kfmt.sh) and [`krun.sh`](https://github.com/matteogiorgi/ulpe/blob/main/base/krun.sh). To support any new language you simply add one handler to each script and one entry to `.vimrc`. As an example, here is what adding *Octave* looks like.


### `kdoc.sh`

A `doc_<lang>` function that prints documentation for a symbol, piped through the `page` helper when the output can be long:
```sh
# OCTAVE HANDLER
doc_octave() {
    command -v octave >/dev/null 2>&1 || return 1
    octave --quiet --norc --eval "more off; help('$1');" 2>/dev/null | page
}

# OUTPUT
[ -n "$2" ] || exit 1
case "$1" in
    ...
    matlab | octave) doc_octave "$2" ;;
    *) exit 1 ;;
esac
```


### `kfmt.sh`

Same pattern, a `fmt_<lang>` function that formats the file in place and exits non-zero if the formatter is missing. *Octave* has no standard formatter, so this uses [`octfmt`](https://github.com/matteogiorgi/octfmt), a formatter written in *Go*:
```sh
# OCTAVE HANDLER
fmt_octave() {
    command -v octfmt >/dev/null 2>&1 || return 1
    octfmt -w "$1" 2>/dev/null
}

# OUTPUT
[ -n "$2" ] || exit 1
case "$1" in
    ...
    matlab | octave) fmt_octave "$2" ;;
    *) exit 1 ;;
esac
```


### `krun.sh`

Add a `run_<lang>` function and a matching case, mirroring the existing handlers (`exec` so the terminal buffer is replaced by the child process):
```sh
# OCTAVE HANDLER
run_octave() {
    command -v octave >/dev/null 2>&1 || return 1
    exec octave "$1"
}

# OUTPUT
[ -n "$2" ] || exit 1
case "$1" in
    ...
    matlab | octave) run_octave "$2" ;;
    *) exit 1 ;;
esac
```


### `.vimrc`

Finally, plug the *Vim* filetype into the `language_env` augroup so `<localleader>k` runs it, `<localleader>j` formats it and `K` looks up documentation via `kdoc.sh`:
```vim
for [ft, kw] in [
      ...
      \     ['matlab,octave', '.'],
      \ ]
    execute 'autocmd FileType ' . ft
          \ . ' nnoremap <buffer> <silent><localleader>k :call <SID>ExecScript(&filetype)<CR>|'
          \ . ' nnoremap <buffer> <silent><localleader>j :call <SID>Formatter(&filetype)<CR>|'
          \ . ' let &l:keywordprg = "kdoc.sh " . expand("<amatch>")|'
          \ . ' setlocal iskeyword+=' . kw . '|'
          \ . ' nnoremap <buffer> <silent>K K<CR>'
endfor
```
