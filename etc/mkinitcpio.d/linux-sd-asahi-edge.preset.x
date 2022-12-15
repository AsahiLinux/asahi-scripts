# mkinitcpio preset file for the 'linux-sd-asahi' boot process

ALL_config="/etc/mkinitcpio.conf"
ALL_kver="/boot/vmlinuz-linux-asahi-edge"

PRESETS=('default' 'fallback')

default_image="/boot/initramfs-linux-sd-asahi-edge.img"
fallback_image="/boot/initramfs-linux-sd-asahi-edge-fallback.img"
fallback_options="-S autodetect"
