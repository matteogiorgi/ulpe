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




## Extras

Since this environment is ment to be used inside a terminal, you may want to install a few extra programs to make your life easier. You don't need much, just a couple of tools to make your terminal experience more pleasant.
- **Terminal emulators**
    + [**Rio Terminal**](https://rioterm.com): minimal terminal emulator with the right features, very fast, and easy to setup.
    + [**Xfce4-Terminal**](https://docs.xfce.org/apps/terminal/start): feature-rich terminal emulator, with a GUI config and a lot of options to choose from.
- **AI assistant**
    + [**Open Code**](https://opencode.ai): AI assistant with both great CLI/GUI, lots of models to choose from and LSP support.
    + [**Claude Code**](https://claude.com/product/claude-code): Claude AI assistant with CLI/GUI, it integrates excellently with Claude's LLM.
    + [**Copilot CLI**](https://github.com/features/copilot/cli): GitHub AI assistant for the command line, simple and easy to use.
