# SPDX-License-Identifier: MIT

# NOTE: These functions are used in the initramfs, so they must be ash/busybox compatible!

info() {
    quiet=0
    if [ -e /lib/dracut-lib.sh ]; then
        if grep -q "rd.debug" /proc/cmdline; then
            quiet=0
        elif grep -q "quiet" /proc/cmdline; then
            quiet=1
        fi
    fi

    [ "$quiet" -eq 0 ] && echo "$@" 1>&2
}

warn() {
    echo "$@" 1>&2
}

mount_sys_esp() {
    set -e
    mountpoint="$1"

    mkdir -p "$mountpoint"
    while grep -q " $mountpoint " /proc/mounts; do
        umount "$mountpoint"
    done

    esp_uuid="$(cat /proc/device-tree/chosen/asahi,efi-system-partition 2>/dev/null | sed 's/\x00//')"
    if [ -e /boot/efi/.builder ] || [ -e /boot/.builder ] || [ -z "$esp_uuid" ]; then
        if [ -e "/boot/efi/m1n1" ]; then
            bootmnt="/boot/efi"
        elif [ -e "/boot/m1n1" ]; then
            bootmnt="/boot"
        else
            warn "ESP not found and cannot determine ESP PARTUUID."
            warn "Make sure that your m1n1 has the right asahi,efi-system-partition configuration,"
            warn "or that your ESP is mounted at /boot/efi or /boot."
            return 1
        fi
        mount --bind "$bootmnt" "$mountpoint"
        warn "System ESP not identified in device tree, using $bootmnt"
    else
        mount "PARTUUID=$esp_uuid" "$mountpoint"
    fi
    dev="$(grep "$mountpoint" /proc/mounts | cut -d" " -f1)"
    info "Mounted System ESP $dev at $mountpoint"
}

mount_boot_esp() {
    set -e
    mountpoint="$1"

    mkdir -p "$mountpoint"
    while grep -q " $mountpoint " /proc/mounts; do
        umount "$mountpoint"
    done

    if [ -e "/boot/efi/efi/boot" ]; then
        mount --bind "/boot/efi" "$mountpoint"
    elif [ -e "/boot/efi/boot" ]; then
        mount --bind "/boot" "$mountpoint"
    else
        esp_uuid="$(cat /proc/device-tree/chosen/asahi,efi-system-partition | sed 's/\x00//')"

        if [ -z "$esp_uuid" ]; then
            echo "Boot ESP not found and cannot determine ESP PARTUUID."
            echo "Make sure your ESP is mounted at /boot/efi or /boot,"
            echo "or that your m1n1 has the right asahi,efi-system-partition configuration."
            return 1
        fi

        mount "PARTUUID=$esp_uuid" "$mountpoint"
    fi
    info "Mounted Boot ESP at $mountpoint"
}
