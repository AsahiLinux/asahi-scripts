PREFIX=/usr/local
CONFIG_DIR=/etc/default
SCRIPTS=update-vendor-firmware update-grub first-boot update-m1n1
UNITS=first-boot.service
MULTI_USER_WANTS=first-boot.service
DRACUT_CONF_DIR=$(PREFIX)/lib/dracut/dracut.conf.d
BUILD_SCRIPTS=$(addprefix build/,$(SCRIPTS))

all: $(BUILD_SCRIPTS)

build/%: %
	@[ ! -e build ] && mkdir -p build || true
	sed -e s,/etc/default,$(CONFIG_DIR),g "$<" > "$@"
	chmod +x "$@"

install: all
	install -d $(DESTDIR)$(PREFIX)/bin/
	install -m0755 -t $(DESTDIR)$(PREFIX)/bin/ $(BUILD_SCRIPTS)
	install -dD $(DESTDIR)$(PREFIX)/lib/systemd/system
	install -dD $(DESTDIR)$(PREFIX)/lib/systemd/system/{multi-user,sysinit}.target.wants
	install -m0644 -t $(DESTDIR)$(PREFIX)/lib/systemd/system $(addprefix systemd/,$(UNITS))
	ln -sf $(addprefix $(PREFIX)/lib/systemd/system/,$(MULTI_USER_WANTS)) \
		$(DESTDIR)$(PREFIX)/lib/systemd/system/multi-user.target.wants/
	install -dD $(DESTDIR)/etc
	install -m0644 -t $(DESTDIR)/etc etc/m1n1.conf
	install -dD $(DESTDIR)$(PREFIX)/share/asahi-scripts
	install -m0644 -t $(DESTDIR)$(PREFIX)/share/asahi-scripts functions.sh

install-arch: install
	install -dD $(DESTDIR)$(PREFIX)/lib/initcpio/install
	install -m0644 -t $(DESTDIR)$(PREFIX)/lib/initcpio/install initcpio/install/asahi
	install -dD $(DESTDIR)$(PREFIX)/lib/initcpio/hooks
	install -m0644 -t $(DESTDIR)$(PREFIX)/lib/initcpio/hooks initcpio/hooks/asahi
	install -dD $(DESTDIR)$(PREFIX)/share/libalpm/hooks
	install -m0644 -t $(DESTDIR)$(PREFIX)/share/libalpm/hooks libalpm/hooks/95-m1n1-install.hook

install-fedora: install
	install -dD $(DESTDIR)$(DRACUT_CONF_DIR)
	install -m0644 -t $(DESTDIR)$(DRACUT_CONF_DIR) dracut/10-asahi.conf

uninstall:
	rm -f $(addprefix $(DESTDIR)$(PREFIX)/bin/,$(SCRIPTS))
	rm -f $(addprefix $(DESTDIR)$(PREFIX)/lib/systemd/system/,$(UNITS))
	rm -f $(addprefix $(DESTDIR)$(PREFIX)/lib/systemd/system/multi-user.target.wants/,$(MULTI_USER_WANTS))
	rm -rf $(DESTDIR)$(PREFIX)/share/asahi-scripts

uninstall-arch:
	rm -f $(DESTDIR)$(PREFIX)/lib/initcpio/install/asahi
	rm -f $(DESTDIR)$(PREFIX)/lib/initcpio/hooks/asahi
	rm -f $(DESTDIR)$(PREFIX)/share/libalpm/hooks/95-m1n1-install.hook

uninstall-fedora:
	rm -f $(DESTDIR)$(DRACUT_CONF_DIR)/10-asahi.conf

.PHONY: install install-arch install-fedora uninstall uninstall-arch uninstall-fedora
