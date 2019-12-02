BASE_DIR := $(realpath ./)

install: fasd i3

update:
	apt update

fasd:
	$(MAKE) -C external/fasd install
	
i3: i3lock
	mkdir -p ~/.config/i3
	ln -sf $(BASE_DIR)/config/i3/config ~/.config/i3/config

i3lock: 

