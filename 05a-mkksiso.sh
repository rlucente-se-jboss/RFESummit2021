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
# Create lightweight container to run mkksiso utility
#
TAG="33-x86_64"

podman rmi -f mkksiso:$TAG

CTR_ID=$(buildah from registry.fedoraproject.org/fedora:$TAG)
buildah run $CTR_ID -- dnf -y install lorax
buildah run $CTR_ID -- mkdir /data
buildah commit $CTR_ID mkksiso:$TAG

#
# Add the kickstart and command line options to the boot ISO
#
rm -f bootwithks.iso
podman run --privileged -v .:/data:Z mkksiso:$TAG \
    /usr/sbin/mkksiso -c "inst.text console=ttyS0" \
    /data/edge.ks /data/$(basename $ISO_PATH) /data/bootwithks.iso

#
# make sure all files owned by $SUDO_USER
#
chown -R $SUDO_USER: .

