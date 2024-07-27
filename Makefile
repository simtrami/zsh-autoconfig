.DEFAULT_GOAL:=autoconfig
# Set shell colors
## NB: I use three "\b" characters to prevent echo's "-e " flag to show up in the terminal
##     I would love to know if there is a better way for fixing this!
ECHO_PREFIX_INFO=\b\b\b\033[1;32;40mINFO:
ECHO_PREFIX_ERROR=\b\b\b\033[1;31;40mERROR:
ECHO_RESET_COLOR=\033[0;0m
# UI messages
ERROR_DEPENDENCY_MISSING=missing, run 'make install_dependencies' before retrying
INFO_PM_DETECTED=package manager detected!
# Detect distro
FEDORA:=$(shell cat /etc/os-release | grep -E "Fedora" | wc -l)
CENTOS:=$(shell cat /etc/os-release | grep -E "CentOS" | wc -l)
DEBIAN:=$(shell cat /etc/os-release | grep -E "debian" | wc -l)
ARCH:=$(shell cat /etc/os-release | grep -E "arch" | wc -l)
# Set the permission elevation binary
DOAS=sudo

.PHONY: check_dependencies .check_git .check_curl .check_zsh install_dependencies .apt_install_dependencies .dnf_install_dependencies .pacman_install_dependencies

autoconfig: check_dependencies .omz_install .chsh

###
# DEPENDENCIES
###

# Makes sure the dependencies are installed
check_dependencies: .check_git .check_curl .check_zsh

# Check dependencies installation
.check_git:
	@echo -n -e "$(ECHO_PREFIX_INFO) Looking for a git executable... $(ECHO_RESET_COLOR)"
	@which git 2> /dev/null || (echo -e "$(ECHO_PREFIX_ERROR) git $(ERROR_DEPENDENCY_MISSING) $(ECHO_RESET_COLOR)" ; exit 1)
.check_curl:
	@echo -n -e "$(ECHO_PREFIX_INFO) Looking for a curl executable... $(ECHO_RESET_COLOR)"
	@which curl 2> /dev/null || (echo -e "$(ECHO_PREFIX_ERROR) curl $(ERROR_DEPENDENCY_MISSING) $(ECHO_RESET_COLOR)" ; exit 1)
.check_zsh:
	@echo -n -e "$(ECHO_PREFIX_INFO) Looking for a zsh executable... $(ECHO_RESET_COLOR)"
	@which zsh 2> /dev/null || (echo -e "$(ECHO_PREFIX_ERROR) zsh $(ERROR_DEPENDENCY_MISSING) $(ECHO_RESET_COLOR)" ; exit 1)

# Install the dependencies using your distro's package manager
ifneq ($(DEBIAN),0)
install_dependencies: .apt_install_dependencies
else ifneq ($(FEDORA),0)
install_dependencies: .dnf_install_dependencies
else ifneq ($(CENTOS),0)
install_dependencies: .dnf_install_dependencies
else ifneq ($(ARCH),0)
install_dependencies: .pacman_install_dependencies
else
install_dependencies: ; $(error Unrecognised GNU/Linux distro. This tool only supports Debian, Ubuntu, CentOS, Fedora and ArchLinux based distros)
endif

## Installation targets
.apt_install_dependencies:
	@echo -e "$(ECHO_PREFIX_INFO) APT $(INFO_PM_DETECTED) $(ECHO_RESET_COLOR)"
	$(DOAS) apt install -y zsh curl git
.dnf_install_dependencies:
	@echo -e "$(ECHO_PREFIX_INFO) DNF $(INFO_PM_DETECTED) $(ECHO_RESET_COLOR)"
	$(DOAS) dnf install -y zsh curl git
.pacman_install_dependencies:
	@echo -e "$(ECHO_PREFIX_INFO) Pacman $(INFO_PM_DETECTED) $(ECHO_RESET_COLOR)"
	$(DOAS) pacman -S --noconfirm zsh curl git

###
# ZSH CONFIGURATION
###

# Install Oh My Zsh
.omz_install:
	@echo -e "$(ECHO_PREFIX_INFO) Downloading and installing Oh My Zsh... $(ECHO_RESET_COLOR)"
ifeq "$(wildcard ~/.oh-my-zsh/*)" ""
	curl -L https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
	@echo -e "$(ECHO_PREFIX_INFO) Done. $(ECHO_RESET_COLOR)"
else
	@echo -e "$(ECHO_PREFIX_INFO) Oh My Zsh already installed, continue. $(ECHO_RESET_COLOR)"
endif

# Install the Honukai theme
.honukai:
	@echo -e "$(ECHO_PREFIX_INFO) Downloading and installing the Honukai theme $(ECHO_RESET_COLOR)"
ifeq "$(wildcard ~/.oh-my-zsh/themes/honukai.zsh-theme)" ""
	curl -o ~/.oh-my-zsh/themes/honukai.zsh-theme https://raw.githubusercontent.com/oskarkrawczyk/honukai-iterm-zsh/master/honukai.zsh-theme
else
	@echo -e "$(ECHO_PREFIX_INFO) Honukai theme already downloaded, continue. $(ECHO_RESET_COLOR)"
endif

ifneq "$(shell grep -L honukai ~/.zshrc)" ""
	sed -i 's/^ZSH_THEME=.*/ZSH_THEME=\"honukai\"/g' ~/.zshrc
	@echo -e "$(ECHO_PREFIX_INFO) Done. $(ECHO_RESET_COLOR)"
else
	@echo -e "$(ECHO_PREFIX_INFO) Honukai theme already installed, continue. $(ECHO_RESET_COLOR)"
endif

# Load VCS helpers
.vcs_helpers:
	@echo -e "$(ECHO_PREFIX_INFO) Enabling VCS helpers in Zsh $(ECHO_RESET_COLOR)"
ifneq "$(shell grep -L run-help ~/.zshrc)" ""
	cat vcs_helpers.zsh_config | tee -a ~/.zshrc
	@echo -e "$(ECHO_PREFIX_INFO) Done. $(ECHO_RESET_COLOR)"
else
	@echo -e "$(ECHO_PREFIX_INFO) VCS already enabled, continue.. $(ECHO_RESET_COLOR)"
endif

# Install the completions plugin
.completions:
	@echo -e "$(ECHO_PREFIX_INFO) Downloading and installing the completions plugin $(ECHO_RESET_COLOR)"
ifeq "$(wildcard ~/.oh-my-zsh/custom/plugins/zsh-completions/*)" ""
	git clone https://github.com/zsh-users/zsh-completions.git ~/.oh-my-zsh/custom/plugins/zsh-completions
else
	@echo -e "$(ECHO_PREFIX_INFO) Plugin already downloaded, continue. $(ECHO_RESET_COLOR)"
endif
ifneq "$(shell grep -L 'plugins/zsh-completions/src' ~/.zshrc)" ""
	sed -i '/^source \$$ZSH\/oh-my-zsh\.sh/i fpath+=\$${ZSH_CUSTOM:-\$${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src' ~/.zshrc
else
	@echo -e "$(ECHO_PREFIX_INFO) ... $(ECHO_RESET_COLOR)"
endif
ifneq "$(shell grep -L '# Zsh Completions' ~/.zshrc)" ""
	cat completions.zsh_config | tee -a ~/.zshrc
	@echo -e "$(ECHO_PREFIX_INFO) Done. $(ECHO_RESET_COLOR)"
else
	@echo -e "$(ECHO_PREFIX_INFO) Plugin already installed, continue. $(ECHO_RESET_COLOR)"
endif

# Install the autosuggestions plugin
.autosuggestions:
	@echo -e "$(ECHO_PREFIX_INFO) Downloading and installing the autosuggestions plugin $(ECHO_RESET_COLOR)"
ifeq "$(wildcard ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/*)" ""
	git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
else
	@echo -e "$(ECHO_PREFIX_INFO) Plugin already downloaded, continue. $(ECHO_RESET_COLOR)"
endif
ifneq "$(shell grep -L 'plugins=(git zsh-autosuggestions)' ~/.zshrc)" ""
	/bin/zsh -ic "omz plugin enable zsh-autosuggestions && exit 0" &
else
	@echo -e "$(ECHO_PREFIX_INFO) Plugin already enabled, continue. $(ECHO_RESET_COLOR)"
endif
ifneq "$(shell grep -L '# Zsh Autosuggestions' ~/.zshrc)" ""
	cat autosuggestions.zsh_config | tee -a ~/.zshrc
	@echo -e "$(ECHO_PREFIX_INFO) Done. $(ECHO_RESET_COLOR)"
else
	@echo -e "$(ECHO_PREFIX_INFO) Plugin already installed, continue. $(ECHO_RESET_COLOR)"
endif

# Install the syntax highlighting plugin (must be run last before .chsh)
.syntax_highlighting:
	@echo -e "$(ECHO_PREFIX_INFO) Downloading and installing the syntax highlighting plugin $(ECHO_RESET_COLOR)"
ifeq "$(wildcard ~/.oh-my-zsh/plugins/zsh-syntax-highlighting/*)" ""
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting
else
	@echo -e "$(ECHO_PREFIX_INFO) Plugin already downloaded, continue. $(ECHO_RESET_COLOR)"
endif
ifneq "$(shell grep -L 'source ~/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' ~/.zshrc)" ""
	cat syntax_highlighting.zsh_config | tee -a ~/.zshrc
	@echo -e "$(ECHO_PREFIX_INFO) Done. $(ECHO_RESET_COLOR)"
else
	@echo -e "$(ECHO_PREFIX_INFO) Plugin already installed, continue. $(ECHO_RESET_COLOR)"
endif

# Change the default shell to zsh
.chsh: .honukai .vcs_helpers .completions .autosuggestions .syntax_highlighting
	@echo -e "$(ECHO_PREFIX_INFO) Changing the default shell to Zsh $(ECHO_RESET_COLOR)"
	chsh -s $(shell which zsh)
	@echo -e "$(ECHO_PREFIX_INFO) Installation complete! $(ECHO_RESET_COLOR)"
	@echo -e "$(ECHO_PREFIX_INFO) *** YOU MUST LOG IN AGAIN TO SEE THE CHANGES ***\n $(ECHO_RESET_COLOR)"
