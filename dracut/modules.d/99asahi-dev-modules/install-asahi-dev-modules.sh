#!/bin/sh
# SPDX-License-Identifier: MIT

type getarg > /dev/null 2>&1 || . /lib/dracut-lib.sh

if [ ! -d /$(uname -r) ]; then
    return 0
fi

DESTDIR="/sysroot/lib/modules/$(uname -r)"

info ":: Asahi: Installing dev kernel modules to root filesystem..."
if [ ! -e ${DESTDIR} ]; then
    if [ ! -w /sysroot ]; then
        error ":: Asahi: root fs not writable!"
        return 0
    fi

    mkdir -p ${DESTDIR}
fi

mount -t tmpfs -o mode=0755,size=192m dev-modules /${DESTDIR}
cp -pr /$(uname -r)/* ${DESTDIR}/
