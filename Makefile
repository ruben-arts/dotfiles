BASE_DIR := $(realpath ./)

INFO_PRINT := \e[1;32m

install: bashrc fasd i3 jq git-cola

update:
	apt update

#
# Terminal 
#

bashrc:
	@grep -qxF 'source ~/.dotfiles/setup.bash' ~/.bashrc || ( \
	 echo 'source ~/.dotfiles/setup.bash' >> ~/.bashrc && \
	 echo "$(INFO_PRINT)Added bash sourcing to .bashrc")

#
# Sway
# 

sway: update sway-install i3-tools

sway-install: update i3-config
	snap install --beta --devmode sway

# 
# i3
# 

i3: update i3-install i3-install

i3-tools: update
	apt install -y dmenu j4-dmenu-desktop curl feh
	apt install -y --no-install-recommends i3lock i3blocks

i3-install: update i3-config
	apt install -y libxcb-xrm-dev libxcb1-dev libxcb-keysyms1-dev libxcb-shape0-dev \
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
	make install

i3-config: 
	mkdir -p ${HOME}/.config/i3
	ln -sf ${HOME}/.dotfiles/config/i3/config ${HOME}/.config/i3/config

compton: update
	apt install -y libconfig-dev asciidoc
	$(MAKE) -C external/compton install

#
# Tools
#

jq: update
	apt install -y jq

fasd:
	$(MAKE) -C external/fasd install

git-cola: update
	apt install -y git-cola