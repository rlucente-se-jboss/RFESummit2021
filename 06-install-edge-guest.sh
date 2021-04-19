#!/usr/bin/env bash

. $(dirname $0)/demo.conf

if [[ $EUID -ne 0 ]]
then
    echo
    echo "*** MUST RUN AS root ***"
    echo
    exit 1
fi

#
# make boot ISO accessible
#
cp /home/$SUDO_USER/bootwithks.iso /tmp

#
# Launch virtual edge device but use bridged networking
#
virt-install \
    --name edge-device \
    --memory $MEM_SIZE \
    --vcpus $NUM_CPUS \
    --network bridge=bridge0 \
    --cdrom /tmp/bootwithks.iso \
    --os-variant=$OS_VARIANT \
    --disk size=$HDD_SIZE \
    --graphics none

