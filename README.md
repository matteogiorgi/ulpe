# Portable UNIX TUI Systen &nbsp;<a href="https://www.debian.org"><img src="https://www.debian.org/logos/officiallogo-nd.svg" style="height: 1em; vertical-align: top;"></a>

This repository contains configuration files and installation scripts for a complete and efficient minimal *UNIX* work environment based on any *Debian* or *Debian-based* distribution.

The purpose of this project is to provide a vim-loving, neckbeard-like, barebone environment, fancy enough to be used as a daily driver but not too fancy to be bloated with unnecessary software and dependencies.

For a simpler all-gui setup, take a look at [GUTS](https://github.com/matteogiorgi/guts/), it may fit your needs better.




## Install

The only prerequisite you need to cover is a working *Debian* in any version or form. There are two installers at your disposal (for now 😎) to easy the setup process: [`puts_base`](https://github.com/matteogiorgi/puts/blob/main/puts_base) and [`puts_plug`](https://github.com/matteogiorgi/puts/blob/main/puts_plug). Each of the installer is independent from the other and the two can be run in any order.

> The installers do not symlink any file, they just copy the configurations in the right place, so they can be easily modified end eventually resetted running the single installer again.

To full install PUTS, run the [`install`](https://github.com/matteogiorgi/puts/blob/main/install) script, it will execute both installers for you.




### Base

This script installs the basic packages and configures *Bash*, *Vim* and *Tmux* for you: just run `./puts_base` from the root of the repository, relaunch your terminal and you are good to go.

> If you are running [*Trixie*](https://www.debian.org/releases/trixie/), the script adds [*Forky*](https://www.debian.org/releases/forky/) repository to your sources-list; for any other running version (older, testing or unstable), it just updates and upgrades your system instead.




### Plug

This one installs additional plugins for your *Vim* alongside a little *vimscript* configuration to glue them together: run `./puts_plug` from the root of the repository, launch *Vim* and see the magic happen.

> You need to have *Vim 9.0* or higher installed for the script to work, but it won't be an issue since you should have at least a working *Debian 12* by now with the 9.1 release available.




## No-Install

If you don't want to run any installer, you can just copy the main configuration files with the following command and you got yourself a minimal PUTS. Copy-pasta this in your terminal and hit enter 😜
```sh
sh -c '
    BASE="https://raw.githubusercontent.com/matteogiorgi/podeen/refs/heads/main/base"
    FILES=".profile .bashrc .bash_logout .tmux.conf .vimrc"
    command -v wget >/dev/null 2>&1 || { echo "ERROR: install wget"; exit 1; }
    for FILE in $FILES; do
        [ -f "$HOME/$FILE" ] && cp "$HOME/$FILE" "$HOME/$FILE.bak"
        wget -qO "$HOME/$FILE" "$BASE/$FILE" && echo "$FILE copied"
    done
    echo "finish"
'
```
