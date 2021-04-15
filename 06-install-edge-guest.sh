#!/usr/bin/env bash

. $(dirname $0)/demo.conf

#
# Create an empty disk for install
#
rm -f edge-disk.qcow2
qemu-img create -f qcow2 edge-disk.qcow2 $HDD_SIZE

#
# QEMU is running in user space with SLiRP networking. All output
# is redirected to the user terminal.
#
qemu-system-x86_64 \
    -serial mon:stdio \
    -nographic \
    -m $MEM_SIZE \
    -device virtio-net-pci,netdev=n0 \
    -netdev user,id=n0,net=$VM_NET \
    -drive file=edge-disk.qcow2 \
    -cdrom bootwithks.iso

