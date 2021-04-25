#!/usr/bin/env bash

. $(dirname $0)/demo.conf

if [[ $EUID -ne 0 ]]
then
    echo
    echo "*** MUST RUN AS root ***"
    echo
    exit 1
fi

function usage {
    echo
    echo "Usage: $(basename $0) < primary | backup >"
    echo
    exit 1
}

#
# Make sure that one argument is provided that is either "primary"
# or "backup"
#
[[ $# -eq 1 ]] || usage

case "$1" in
  primary)
    PRIORITY=$1
    ;;

  backup)
    PRIORITY=$1
    ;;

  *)
    usage
    ;;
esac

#
# make boot ISO accessible
#
cp /home/$SUDO_USER/${PRIORITY}bootwithks.iso /tmp

#
# Determine unique edge device name
#
EDGENUM=$(virsh list --all | grep edge | sed 's/..*device-\([0-9]*\)..*/\1/g' | sort | tail -1)
EDGENUM=$(($EDGENUM + 1))

#
# Launch virtual edge device but use bridged networking
#
virt-install \
    --name edge-device-$EDGENUM \
    --memory $MEM_SIZE \
    --vcpus $NUM_CPUS \
    --network bridge=bridge0 \
    --cdrom /tmp/${PRIORITY}bootwithks.iso \
    --os-variant=$OS_VARIANT \
    --disk size=$HDD_SIZE \
    --graphics vnc,keymap=en-us \
    --noautoconsole \
    --noreboot
