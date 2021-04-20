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
    echo "Usage: $(basename $0) <master|backup> <priority>"
    echo "  where priority is an integer between 1 and 254, inclusive"
    echo
    exit 1
}

#
# Make sure that two arguments are provided and that the first
# argument is either "master" or "backup" and second argument is an
# integer between 1 and 254, inclusive.
#
[[ $# -eq 2 ]] || usage

case "$1" in
  master)
    vip_state=master
    ;;

  backup)
    vip_state=backup
    ;;

  *)
    usage
    ;;
esac

[[ $2 =~ ^[0-9]+$ ]] || usage
[ $2 -ge 1 -a $2 -le 254 ] || usage

vip_priority=$2

#
# make boot ISO accessible
#
cp /home/$SUDO_USER/bootwithks.iso /tmp

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
    --extra-args "vip_state=$vip_state vip_priority=$vip_priority" \
    --network bridge=bridge0 \
    --cdrom /tmp/bootwithks.iso \
    --os-variant=$OS_VARIANT \
    --disk size=$HDD_SIZE \
    --graphics none \
    --noreboot

