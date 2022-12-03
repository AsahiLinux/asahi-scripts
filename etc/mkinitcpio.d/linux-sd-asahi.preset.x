# mkinitcpio preset file for the 'linux-sd-asahi' boot process

ALL_config="/etc/mkinitcpio.conf"
ALL_kver="/boot/vmlinuz-linux-asahi"

PRESETS=('default' 'fallback')

default_image="/boot/initramfs-linux-sd-asahi.img"
fallback_image="/boot/initramfs-linux-sd-asahi-fallback.img"
fallback_options="-S autodetect"
