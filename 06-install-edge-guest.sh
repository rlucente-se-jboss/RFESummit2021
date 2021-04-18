#!/usr/bin/env bash

. $(dirname $0)/demo.conf

#
# Launch virtual edge device but use bridged networking
#
virt-install \
    --name edge-device \
    --memory $MEM_SIZE \
    --vcpus $NUM_CPUS \
    --network bridge=bridge0 \
    --location bootwithks.iso \
    --os-variant=$OS_VARIANT \
    --disk size=$HDD_SIZE \
    --graphics none

