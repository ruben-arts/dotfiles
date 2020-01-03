BASE_DIR := $(realpath ./)

install: fasd i3 jq git-cola

update:
	apt update

jq: update
	apt install -y jq

feh: update
	apt install -y feh

fasd:
	$(MAKE) -C external/fasd install
	 
i3: update i3lock i3blocks feh
	apt install -y libxcb-xrm-dev libxcb1-dev libxcb-keysyms1-dev libxcb-shape0-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev autoconf xutils-dev libtool automake
	sh scripts/install/i3.sh

compton: libconfig asciidoc
	$(MAKE) -C external/compton install

libconfig: update
	apt install -y libconfig-dev

asciidoc: update
	apt install -y asciidoc

i3lock: update
	apt install -y --no-install-recommends i3lock

i3blocks: update
	apt install -y --no-install-recommends i3blocks

git-cola: update
	apt install -y git-cola