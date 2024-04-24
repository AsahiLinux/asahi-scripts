#!/bin/bash

# called by dracut
installkernel() {
    # For NVMe & SMC
    hostonly='' instmods apple-mailbox

    # For NVMe
    hostonly='' instmods nvme_apple

    # For USB and HID
    hostonly='' instmods pinctrl-apple-gpio

    # SMC core
    hostonly='' instmods macsmc macsmc-rtkit

    # For USB
    hostonly='' instmods \
        i2c-apple \
        i2c-pasemi-platform \
        tps6598x \
        apple-dart \
        dwc3 \
        dwc3-of-simple \
        nvmem-apple-efuses \
        phy-apple-atc \
        xhci-plat-hcd \
        xhci-pci \
        pcie-apple \
        gpio_macsmc

    # For RTC
    hostonly='' instmods rtc-macsmc simple-mfd-spmi spmi-apple-controller nvmem_spmi_mfd

    # For HID
    hostonly='' instmods spi-apple spi-hid-apple spi-hid-apple-of

    # For MTP HID
    hostonly='' instmods apple-dockchannel dockchannel-hid apple-rtkit-helper

    # For DP / HDMI audio
    hostonly='' instmods apple-sio

    # For DPTX and HDMI displays
    hostonly='' instmods mux-apple-display-crossbar phy-apple-dptx
}
