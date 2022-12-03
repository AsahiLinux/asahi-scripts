# asahi-scripts

Asahi Linux maintenance scripts.

### Installation

The utilities are available from the Asahi Linux repositories via the `asahi-scripts` package and should be installed with pacman.

If additional non-default components of the package are wanted, `make` can be run manually to install the components. 

For dracut as an example:

```bash
make PREFIX=/usr DESTDIR=/ install-dracut
```

In most cases.

### Using the systemd hook instead of the usual hooks (udev ...)

If the systemd hook is desired, several easy steps must be taken as root:

- Edit `/etc/mkinitcpio.conf` based on the fact that in a basic systemd configuration HOOKS should start with `(base systemd sd-asahi...`. systemd replaces udev, and the basehook is there for the reason that the overhead of writing a C binary for the sd-asahi process is unnecessary if we can rely on the shell provided by the base hook (even though systemd overrides most behaviour).
- `mv /etc/mkinitcpio.d/linux-asahi.preset{,.x} && mv /etc/mkinitcpio.d/linux-sd-asahi.preset{.x,}`
- `systemctl daemon reload` - just in case units have not been picked up
- `mkinitcpio -P && update-m1n1`
- If you are not using `/etc/default/update-m1n1`, you are done, otherwise you might need to move files or other after the last step.

**WARNING:** 

Make sure you keep around at least 1 **WORKING** m1n1 stage 2 U-Boot + GRUB binary and 1 backup of your last working m1n1 stage 2 in the ESP such that you can mount ESP from mac os in the case of issues and boot normally again. The U-Boot and GRUB is there in the case you broke your initramfs or something else and need to recover from, say, Live USB.

### Manually managing m1n1 upgrades

m1n1 upgrades can be manually managed if a custom boot process is desired. The only thing necessary for this is to create a custom `/etc/default/update-m1n1` script, which is automatically recognized by the canonical `update-m1n1` and executed. If a variable `M1N1_MANAGED_MANUALLY` within the script is set to 1, then the upgrade process is stopped after running the custom script. Furthermore, `/etc/default/update-m1n1` can also be a sym/hardlink to another script somewhere within the system (if the user so desires).

Below, an example of a custom script which skips U-Boot and GRUB (I suppose in some way similar to an UEFI executable) in favour of a direct m1n1 stage 2 launch. The kernel arguments are not given so this won't work, you need to specify them. This is for the regular base hook.

```bash
#!/bin/bash
echo "zipping vmlinuz-linux-asahi..."

# for stage 2 boot the vmlinuz image has to be zipped

gzip -fk /boot/vmlinuz-linux-asahi

echo "...zipped to /boot/vmlinuz-linux-asahi.gz"

# add a date identifier
# note that only the file named `boot.bin` will be booted

NAME="$(date +"%Y%j%H%M")-m1n1.bin"

# concatenate all and save on ESP partition in m1n1 dir

cat /lib/asahi-boot/m1n1.bin \
	<(echo 'chosen.bootargs=<whatever kernel args you use>') \
	/lib/modules/*-ARCH/dtbs/*.dtb \
	/boot/initramfs-linux-asahi.img \
	/boot/vmlinuz-linux-asahi.gz \
	>/boot/efi/m1n1/$NAME

echo "New m1n1 binary built: $NAME"

# set so /usr/bin/update-m1n1 does not continue to default process

M1N1_MANAGED_MANUALLY=1
```

You would have to manually move `mv /boot/efi/m1n1/{*-m1n1,boot}.bin`.
