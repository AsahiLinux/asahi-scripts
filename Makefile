PREFIX=/usr/local
SYS_PREFIX=$(PREFIX)
CONFIG_DIR=/etc/default
BIN_DIR=$(PREFIX)/bin
SCRIPTS=asahi-diagnose asahi-fwupdate update-m1n1
ARCH_SCRIPTS=update-grub first-boot
UNITS=first-boot.service
MULTI_USER_WANTS=first-boot.service
DRACUT_CONF_DIR=$(PREFIX)/lib/dracut/dracut.conf.d
DRACUT_MODULES_DIR=$(PREFIX)/lib/dracut/modules.d
SYSTEMD_UNIT_DIR=$(PREFIX)/lib/systemd/system
UDEV_RULES_DIR=$(PREFIX)/lib/udev/rules.d
BUILD_SCRIPTS=$(addprefix build/,$(SCRIPTS))
BUILD_ARCH_SCRIPTS=$(addprefix build/,$(ARCH_SCRIPTS))

all: $(BUILD_SCRIPTS) $(BUILD_ARCH_SCRIPTS)

build/%: %
	@[ ! -e build ] && mkdir -p build || true
	sed -e s,/etc/default,$(CONFIG_DIR),g "$<" > "$@"
	chmod +x "$@"

clean:
	rm -rf build

install: all
	install -d $(DESTDIR)$(BIN_DIR)/
	install -m0755 -t $(DESTDIR)$(BIN_DIR)/ $(BUILD_SCRIPTS)
	install -dD $(DESTDIR)/etc
	install -m0644 -t $(DESTDIR)/etc etc/m1n1.conf
	install -dD $(DESTDIR)$(PREFIX)/share/asahi-scripts
	install -m0644 -t $(DESTDIR)$(PREFIX)/share/asahi-scripts functions.sh
	install -dD $(DESTDIR)/$(SYS_PREFIX)/lib/firmware/vendor

install-mkinitcpio: install
	install -dD $(DESTDIR)$(PREFIX)/lib/initcpio/install
	install -m0644 -t $(DESTDIR)$(PREFIX)/lib/initcpio/install initcpio/install/asahi
	install -dD $(DESTDIR)$(PREFIX)/lib/initcpio/hooks
	install -m0644 -t $(DESTDIR)$(PREFIX)/lib/initcpio/hooks initcpio/hooks/asahi

install-dracut: install
	install -dD $(DESTDIR)$(DRACUT_CONF_DIR)
	install -m0644 -t $(DESTDIR)$(DRACUT_CONF_DIR) dracut/dracut.conf.d/10-asahi.conf
	install -dD $(DESTDIR)$(DRACUT_MODULES_DIR)/91kernel-modules-asahi
	install -m0755 -t $(DESTDIR)$(DRACUT_MODULES_DIR)/91kernel-modules-asahi dracut/modules.d/91kernel-modules-asahi/module-setup.sh
	install -dD $(DESTDIR)$(DRACUT_MODULES_DIR)/99asahi-firmware
	install -m0755 -t $(DESTDIR)$(DRACUT_MODULES_DIR)/99asahi-firmware dracut/modules.d/99asahi-firmware/install-asahi-firmware.sh
	install -m0755 -t $(DESTDIR)$(DRACUT_MODULES_DIR)/99asahi-firmware dracut/modules.d/99asahi-firmware/load-asahi-firmware.sh
	install -m0755 -t $(DESTDIR)$(DRACUT_MODULES_DIR)/99asahi-firmware dracut/modules.d/99asahi-firmware/module-setup.sh

install-macsmc-battery: install
	install -dD $(DESTDIR)$(SYSTEMD_UNIT_DIR)
	install -dD $(DESTDIR)$(UDEV_RULES_DIR)
	install -m0755 -t $(DESTDIR)$(SYSTEMD_UNIT_DIR) macsmc-battery/systemd/macsmc-battery-charge-control-end-threshold.path
	install -m0755 -t $(DESTDIR)$(SYSTEMD_UNIT_DIR) macsmc-battery/systemd/macsmc-battery-charge-control-end-threshold.service
	install -m0755 -t $(DESTDIR)$(UDEV_RULES_DIR) macsmc-battery/udev/93-macsmc-battery-charge-control.rules

install-arch: install install-mkinitcpio
	install -m0755 -t $(DESTDIR)$(BIN_DIR)/ $(BUILD_ARCH_SCRIPTS)
	install -dD $(DESTDIR)$(PREFIX)/lib/systemd/system
	install -dD $(DESTDIR)$(PREFIX)/lib/systemd/system/{multi-user,sysinit}.target.wants
	install -m0644 -t $(DESTDIR)$(PREFIX)/lib/systemd/system $(addprefix systemd/,$(UNITS))
	ln -sf $(addprefix $(PREFIX)/lib/systemd/system/,$(MULTI_USER_WANTS)) \
		$(DESTDIR)$(PREFIX)/lib/systemd/system/multi-user.target.wants/
	install -dD $(DESTDIR)$(PREFIX)/share/libalpm/hooks
	install -m0644 -t $(DESTDIR)$(PREFIX)/share/libalpm/hooks libalpm/hooks/95-m1n1-install.hook

install-fedora: install install-dracut install-macsmc-battery

uninstall:
	rm -f $(addprefix $(DESTDIR)$(BIN_DIR)/,$(SCRIPTS))
	rm -rf $(DESTDIR)$(PREFIX)/share/asahi-scripts

uninstall-mkinitcpio:
	rm -f $(DESTDIR)$(PREFIX)/lib/initcpio/install/asahi
	rm -f $(DESTDIR)$(PREFIX)/lib/initcpio/hooks/asahi

uninstall-dracut:
	rm -f $(DESTDIR)$(DRACUT_CONF_DIR)/10-asahi.conf

uninstall-macsmc-battery:
	rm -f $(DESTDIR)$(SYSTEMD_UNIT_DIR)/macsmc-battery-charge-control-end-threshold.path
	rm -f $(DESTDIR)$(SYSTEMD_UNIT_DIR)/macsmc-battery-charge-control-end-threshold.service
	rm -f $(DESTDIR)$(UDEV_RULES_DIR)/93-macsmc-battery-charge-control.rules

uninstall-arch: uninstall-mkinitcpio
	rm -f $(addprefix $(DESTDIR)$(BIN_DIR)/,$(ARCH_SCRIPTS))
	rm -f $(addprefix $(DESTDIR)$(PREFIX)/lib/systemd/system/,$(UNITS))
	rm -f $(addprefix $(DESTDIR)$(PREFIX)/lib/systemd/system/multi-user.target.wants/,$(MULTI_USER_WANTS))
	rm -f $(DESTDIR)$(PREFIX)/share/libalpm/hooks/95-m1n1-install.hook

uninstall-fedora: uninstall-dracut uninstall-macsmc-battery

.PHONY: clean install install-mkinitcpio install-dracut install-arch install-fedora uninstall uninstall-mkinitcpio uninstall-dracut uninstall-arch uninstall-fedora
