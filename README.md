# zsh-autoconfig

Automatic configuration tool for my shells.

I use [oh-my-zsh](https://ohmyz.sh/) with the [Honukai theme](https://github.com/oskarkrawczyk/honukai-iterm-zsh).

This tool uses [GNU Make](https://www.gnu.org/software/make/) to automate the installation and configuration of Oh My Zsh.

It depends on the `git`, `curl` and `zsh` packages and will check if they are already installed.
If not, the tool can automatically install them for you if you're using Debian, Ubuntu, CentOS, Fedora or an ArchLinux based distro. To do so, execute `make install_dependencies`.

Otherwise, you can install them yourself manually and re-run the tool (see below).

## How to use

Clone the repository and open a terminal from inside or download the **Makefile** and the **.zsh_config** files. Then, run `make`.

```sh
git clone https://github.com/simtrami/zsh-autoconfig.git
cd zsh-autoconfig
make
```

Then follow the instructions.

You will need to **reopen your terminal** for the changes to take effect.

## What it does

1. Checks whether you have `git`, `curl` and `zsh` installed and warns you otherwise.
For manual checking without running the rest of the script, use `make check_dependencies`.
1. Installs the dependencies for you if you distro is Debian, ArchLinux or CentOS based (tested on Ubuntu, Manjaro and CentOS).  
Use `make install_dependencies` to install them.
1. Downloads the latest version of [oh-my-zsh](https://ohmyz.sh/#install) and installs it.
1. Downloads and installs the [Honukai theme](https://github.com/oskarkrawczyk/honukai-iterm-zsh).
1. Enables the VCS helpers (for git, svn and svk) in the Zsh configuration.
1. Downloads and installs the [completions plugin](https://github.com/zsh-users/zsh-completions).
1. Downloads and installs the [autosuggestions plugin](https://github.com/zsh-users/zsh-autosuggestions).
1. Downloads and installs the [syntax highlighting plugin](https://github.com/zsh-users/zsh-syntax-highlighting).
1. Changes the default shell to Zsh

## Re-using the code

This project is under GPLv2 license.
You can fork it and change it with your favorite theme and plugins!

> I know my code is not perfect and I would love to have your feedback and fixes!
