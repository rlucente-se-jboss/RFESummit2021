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
# make sure all files owned by $USER
#
chown -R $SUDO_USER: .

#
# Create lightweight container to run mkksiso utility
#
TAG="33-x86_64"
CTR_ID=$(buildah from registry.fedoraproject.org/fedora:$TAG)
buildah run $CTR_ID -- dnf -y install lorax
buildah run $CTR_ID -- mkdir /data
buildah commit $CTR_ID mkksiso:$TAG

#
# Run mkksiso command
#
podman run --privileged -v .:/data:Z mkksiso:$TAG \
    /usr/sbin/mkksiso /data/edge.ks /data/$(basename $ISO_PATH) /data/bootwithks.iso

chown -R $SUDO_USER: .

