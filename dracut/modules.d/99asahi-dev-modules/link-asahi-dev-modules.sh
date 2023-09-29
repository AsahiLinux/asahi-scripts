#!/bin/sh
# SPDX-License-Identifier: MIT

type getarg > /dev/null 2>&1 || . /lib/dracut-lib.sh

if [ -d /$(uname -r) ]; then
    info ":: Asahi: dev modules present, link them into system"
    ln -s /$(uname -r) /lib/modules/
fi
