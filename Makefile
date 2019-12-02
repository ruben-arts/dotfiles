BASE_DIR := $(realpath ./)

install: 
	$(MAKE) -C external/fasd install
	mkdir -p ~/.config/i3
	ln -s $(BASE_DIR)/config/i3/config ~/.config/i3/config

uninstall:
	$(MAKE) -C external/fasd uninstall
	rm ~/.config/i3/config

.PHONY: install uninstall
