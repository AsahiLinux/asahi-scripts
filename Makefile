V=20220225
PREFIX=/usr/local

SCRIPTS=update-vendor-firmware update-grub first-boot
UNITS=first-boot.service update-vendor-firmware.service systemd-udev-trigger-early.service
MULTI_USER_WANTS=first-boot.service
SYSINIT_WANTS=update-vendor-firmware.service systemd-udev-trigger-early.service

install:
	install -d $(DESTDIR)$(PREFIX)/bin/
	install -m0755 -t $(DESTDIR)$(PREFIX)/bin/ $(SCRIPTS)
	install -dD $(DESTDIR)$(PREFIX)/lib/systemd/system
	install -dD $(DESTDIR)$(PREFIX)/lib/systemd/system/{multi-user,sysinit}.target.wants
	install -m0644 -t $(DESTDIR)$(PREFIX)/lib/systemd/system $(addprefix systemd/,$(UNITS))
	ln -sf $(addprefix $(PREFIX)/lib/systemd/system/,$(MULTI_USER_WANTS)) \
		$(DESTDIR)$(PREFIX)/lib/systemd/system/multi-user.target.wants/
	ln -sf $(addprefix $(PREFIX)/lib/systemd/system/,$(SYSINIT_WANTS)) \
		$(DESTDIR)$(PREFIX)/lib/systemd/system/sysinit.target.wants/

uninstall:
	rm -f $(addprefix $(DESTDIR)$(PREFIX)/bin/,$(SCRIPTS))
	rm -f $(addprefix $(DESTDIR)$(PREFIX)/lib/systemd/system/,$(UNITS))
	rm -f $(addprefix $(DESTDIR)$(PREFIX)/lib/systemd/system/multi-user.target.wants/,$(MULTI_USER_WANTS))
	rm -f $(addprefix $(DESTDIR)$(PREFIX)/lib/systemd/system/sysinit.target.wants/,$(SYSINIT_WANTS))

.PHONY: install uninstall
