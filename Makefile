BASE_DIR := $(realpath ./)

install: fasd i3 jq

update:
	apt update

jq: update
	apt install -y jq

feh: update
	apt install -y feh

fasd:
	$(MAKE) -C external/fasd install
	
i3: i3lock feh
	mkdir -p ~/.config/i3
	ln -sf $(BASE_DIR)/config/i3/config ~/.config/i3/config

compton: libconfig asciidoc
	$(MAKE) -C external/compton install

libconfig: update
	apt install -y libconfig-dev

asciidoc: update
	apt install -y asciidoc

i3lock: 

