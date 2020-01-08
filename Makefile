# Inspiration: https://gist.github.com/DerekV/3030284

.PHONY: all
all: checkplatform git-submodules bashrc fonts alacritty fasd polybar i3 jq git-cola code-config

BASE_DIR := $(realpath ./)
INFO_PRINT := \e[1;32m
ERROR_PRINT := \e[1;31m
VERBOSE_PRINT := \e[90m
RESET_PRINT := \e[0m

DOTFILES_DIR?=~/.dotfiles
DOTFILES_REPO?=git@github.com:baszalmstra/dotfiles.git

REQUIRED_PACKAGES=alacritty asciidoc autoconf automake cmake cmake-data curl dmenu feh git i3blocks i3lock j4-dmenu-desktop libasound2-dev libcairo2-dev libconfig-dev libcurl4-openssl-dev libdbus-1-dev libdrm-dev libev-dev libevdev-dev libevdev2 libgl1-mesa-dev libjsoncpp-dev libmpdclient-dev libnl-genl-3-dev libpango1.0-dev libpcre2-dev libpixman-1-dev libpulse-dev libstartup-notification0-dev libtool libxcb-composite0-dev libxcb-cursor-dev libxcb-damage0-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-image0-dev libxcb-keysyms1-dev libxcb-present-dev libxcb-randr0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-shape0-dev libxcb-util0-dev libxcb-xfixes0-dev libxcb-xinerama0-dev libxcb-xkb-dev libxcb-xrm-dev libxcb1-dev libxcomposite-dev libxdamage-dev libxdg-basedir-dev libxext-dev libxfixes-dev libxinerama-dev libxkbcommon-dev libxkbcommon-x11-dev libxrandr-dev libyajl-dev meson ninja-build pkg-config python-xcbgen python3 python3-sphinx uthash-dev xcb-proto xutils-dev

#
# Misc
#
is-not-installed=! (dpkg -l | grep -q $(1))

define install-package-template
$(1): update
	@if ( $(call is-not-installed,$(1)) ) ; \
	then \
		echo "$(INFO_PRINT)Installing $(1)...$(RESET_PRINT)"; \
		sudo apt install -qq -y --no-install-recommends $(1); \
	else \
		echo "$(VERBOSE_PRINT)$(1) already installed$(RESET_PRINT)"; \
	fi
endef

$(foreach pkg,$(REQUIRED_PACKAGES), $(eval $(call install-package-template,$(pkg))))

#
# Utils
#
.PHONY : checkplatform git-update update
checkplatform:
ifneq ($(shell uname),Linux)
	@echo 'Platform unsupported, only available for Linux'  && exit 1
endif
ifeq ($(strip $(shell which apt-get)),)
	@echo 'apt-get not found, platform not supported' && exit 1
endif

git-submodules:
	@git submodule update --init --recursive

update:
	@@echo "$(INFO_PRINT)Updating package list...$(RESET_PRINT)"; \
	sudo apt update -qq

# ssh-public-key: ~/.ssh/id_rsa.pub
# 	@echo "We need an ssh public key"

# ~/.ssh/id_rsa.pub:
# 	@ssh-keygen

# github-configured: ssh-public-key
# 	@ssh -T git@github.com \
# 	|| (echo "You need to add your new public key to github" \
# 	&& cat ~/.ssh/id_rsa.pub \
# 	&& exit 1)

# .PHONY: dotfiles
# dotfiles : github-configured
# 	@if [ ! -d $(DOTFILES-DIR) ] ;\
# 	then \
# 	  echo "dotfiles does not exist, fetching"; \
# 	  git clone --recursive $(DOTFILES-REPO) $(DOTFILES-DIR); \
# 	fi


code-config:
	@mkdir -p ${HOME}/.config/Code/User && \
	ln -sf ${HOME}/.dotfiles/config/code/user/settings.json ${HOME}/.config/Code/User/settings.json

#
# Terminal
#

.PHONY : bashrc alacritty

bashrc:
	@grep -qxF 'source ~/.dotfiles/setup.bash' ~/.bashrc || ( \
	 echo 'source ~/.dotfiles/setup.bash' >> ~/.bashrc && \
	 echo "$(INFO_PRINT)Added bash sourcing to .bashrc")

${HOME}/.config/alacritty: ${HOME}/.dotfiles/config/alacritty
	@ln -sf ${HOME}/.dotfiles/config/alacritty ${HOME}/.config/alacritty

alacritty-apt:
	@sudo add-apt-repository -y ppa:mmstick76/alacritty

alacritty: alacritty-apt ${HOME}/.config/alacritty

#
# Sway
#

sway: sway-install i3-tools

sway-install: wayland i3-config
	@echo "$(INFO_PRINT)Installing sway...$(RESET_PRINT)" && \
	sudo snap install --beta --devmode sway

wayland:
	@sudo sed -i 's/#WaylandEnable=false/WaylandEnable=true/' /etc/gdm3/custom.conf

#
# i3
#

.PHONY: i3 i3-dependencies i3-tools picom picom-dependencies

i3: ${HOME}/.config/i3/config i3-dependencies /usr/bin/i3 i3-tools picom

${HOME}/.config/i3/config: ${HOME}/.dotfiles/config/i3/config
	@echo "$(INFO_PRINT)Installing i3 config...$(RESET_PRINT)" && \
	mkdir -p ${HOME}/.config/i3 && \
	ln -sf ${HOME}/.dotfiles/config/i3/config ${HOME}/.config/i3/config

i3-dependencies: libxcb-xrm-dev libxcb1-dev libxcb-keysyms1-dev libxcb-shape0-dev \
	libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev \
	libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev \
	libxkbcommon-x11-dev autoconf xutils-dev libtool automake

/usr/bin/i3: external/i3-gaps
	@echo "$(INFO_PRINT)Installing i3...$(RESET_PRINT)" && \
	cd ${HOME}/.dotfiles/external/i3-gaps && \
	autoreconf --force --install && \
	mkdir -p /tmp/i3-gaps-build && \
	cd /tmp/i3-gaps-build && \
	${HOME}/.dotfiles/external/i3-gaps/configure \
		--prefix=/usr --sysconfdir=/etc && \
	make && \
	sudo make install

i3-tools: update dmenu j4-dmenu-desktop curl feh i3lock i3blocks

picom: picom-dependencies /usr/local/bin/picom 
picom-dependencies: meson ninja-build libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libxdg-basedir-dev libgl1-mesa-dev libpcre2-dev libevdev-dev uthash-dev libevdev2
/usr/local/bin/picom: external/picom
	@mkdir -p /tmp/picom-build && \
	meson --buildtype=release external/picom /tmp/picom-build && \
	sudo ninja -C /tmp/picom-build install

#
# Polybar
#

polybar: polybar-dependencies /usr/local/bin/polybar
polybar-dependencies: python3 python3-sphinx pkg-config git cmake cmake-data pkg-config python3-sphinx libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev libxcb-composite0-dev python-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev libpulse-dev libjsoncpp-dev libmpdclient-dev libcurl4-openssl-dev libnl-genl-3-dev
/usr/local/bin/polybar: external/polybar
	@mkdir -p /tmp/polybar-build && \
	cd /tmp/polybar-build && \
	cmake $(BASE_DIR)/external/polybar && \
	make -j$$(nproc) && \
	sudo make install

#
# Tools
#

fasd:
	sudo $(MAKE) -C external/fasd install

$(eval $(call install-package-template,jq))
$(eval $(call install-package-template,git-cola))

#
# Fonts
#

${HOME}/.local/share/fonts/NerdFonts: external/nerd-fonts
	@echo "$(INFO_PRINT)Installing nerd fonts...$(RESET_PRINT)" && \
	external/nerd-fonts/install.sh -q --link && \
	sudo fc-cache -fv

.PHONY: fonts
fonts: ${HOME}/.local/share/fonts/NerdFonts
