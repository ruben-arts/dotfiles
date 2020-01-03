BASE_DIR := $(realpath ./)

install: fasd i3 jq git-cola

update:
	apt update

jq: update
	apt install -y jq

feh: update
	apt install -y feh

autoconf: update
	apt install -y autoconf

fasd:
	$(MAKE) -C external/fasd install
	
i3: update i3lock i3blocks feh autoconf
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