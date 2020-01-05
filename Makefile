# Inspiration: https://gist.github.com/DerekV/3030284

.PHONY: all
all: dotfiles fonts bashrc alacritty fasd i3 jq git-cola

BASE_DIR := $(realpath ./)
INFO_PRINT := \e[1;32m
RESET_PRINT := \e[0m

DOTFILES_DIR?=~/.dotfiles
DOTFILES_REPO?=git@github.com:baszalmstra/dotfiles.git

# 
# Utils
# 
.PHONY : checkplatform
checkplatform:
	@echo "$(INFO_PRINT)Installing dotfiles"
ifneq ($(shell uname),Linux) 
	@echo 'Platform unsupported, only available for Linux'  && exit 1
endif
ifeq ($(strip $(shell which apt-get)),)
	@echo 'apt-get not found, platform not supported' && exit 1
endif

update:
	sudo apt update

ssh-public-key: ~/.ssh/id_rsa.pub
	@echo "We need an ssh public key"

~/.ssh/id_rsa.pub:
	@ssh-keygen

github-configured: ssh-public-key
	@ssh -T git@github.com \
	|| (echo "You need to add your new public key to github" \
	&& cat ~/.ssh/id_rsa.pub \
	&& exit 1)

.PHONY: dotfiles
dotfiles : github-configured
	@if [ ! -d $(DOTFILES-DIR) ] ;\
	then \
	  echo "dotfiles does not exist, fetching"; \
	  git clone --recursive $(DOTFILES-REPO) $(DOTFILES-DIR); \
	fi

#
# Terminal 
#

.PHONY : bashrc alacritty

bashrc:
	@grep -qxF 'source ~/.dotfiles/setup.bash' ~/.bashrc || ( \
	 echo 'source ~/.dotfiles/setup.bash' >> ~/.bashrc && \
	 echo "$(INFO_PRINT)Added bash sourcing to .bashrc")

alacritty:
	ln -sf ${HOME}/.dotfiles/config/alacritty ${HOME}/.config/alacritty
	sudo add-apt-repository -y ppa:mmstick76/alacritty
	sudo apt install -y alacritty

#
# Sway
# 

sway: update sway-install i3-tools

sway-install: update wayland i3-config
	snap install --beta --devmode sway

wayland:
	sed -i 's/#WaylandEnable=false/WaylandEnable=true/' /etc/gdm3/custom.conf

# 
# i3
# 

i3: update i3-install i3-install compton

i3-tools: update
	sudo apt install -y dmenu j4-dmenu-desktop curl feh
	sudo apt install -y --no-install-recommends i3lock i3blocks

i3-install: update i3-config
	sudo apt install -y libxcb-xrm-dev libxcb1-dev libxcb-keysyms1-dev libxcb-shape0-dev \
		libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev \
		libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev \
		libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev \
		autoconf xutils-dev libtool automake && \
	cd ${HOME}/.dotfiles/external/i3-gaps && \
	autoreconf --force --install && \
	mkdir -p /tmp/i3-gaps-build && \
	cd /tmp/i3-gaps-build && \
	${HOME}/.dotfiles/external/i3-gaps/configure \
		--prefix=/usr --sysconfdir=/etc && \
	make && \
	sudo make install

i3-config: 
	mkdir -p ${HOME}/.config/i3
	ln -sf ${HOME}/.dotfiles/config/i3/config ${HOME}/.config/i3/config

compton: update
	sudo apt install -y libconfig-dev asciidoc libxcomposite-dev libxdamage-dev \
		libxcomposite-dev libxfixes-dev libxdamage-dev libxrandr-dev libxinerama-dev \
		libdbus-1-dev libdrm-dev libxcomposite-dev libxfixes-dev libxdamage-dev \
		libxrandr-dev libxinerama-dev libdbus-1-dev libgl1-mesa-dev

	sudo $(MAKE) -C external/compton
	sudo $(MAKE) -C external/compton install

#
# Tools
#

jq: update
	sudo apt install -y jq

fasd:
	sudo $(MAKE) -C external/fasd install

git-cola: update
	sudo apt install -y git-cola

#
# Fonts
#

FONT_DIR = ~/.local/share/fonts
NERD_FONT_DIR?=/tmp/nerd_fonts

nerd-fonts:
	@if [ ! -d $(NERD_FONT_DIR) ] ;\
	then \
		echo "$(INFO_PRINT)Checking out nerd fonts...$(RESET_PRINT)"; \
		git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git $(NERD_FONT_DIR); \
	fi

$(FONT_DIR)/NerdFonts/Iosevka\ Nerd\ Font\ Complete.ttf: | nerd-fonts
	@echo "$(INFO_PRINT)Installing Iosevka Nerd Fonts...$(RESET_PRINT)"; \
	$(NERD_FONT_DIR)/install.sh -q Iosevka
	@rm -f $(FONT_DIR)/NerdFonts/*Mono.ttf

iosevka: $(FONT_DIR)/NerdFonts/Iosevka\ Nerd\ Font\ Complete.ttf

fonts: iosevka
	sudo fc-cache -fv