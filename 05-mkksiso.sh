#!/usr/bin/env bash

. $(dirname $0)/demo.conf

ISO_NAME=$(basename ${ISO_PATH})
TEMP_DIR=$(mktemp -d)

cp ${ISO_PATH} edge.ks Containerfile ${TEMP_DIR}

if [[ $EUID -ne 0 ]]; then
    echo
    echo "*** MUST RUN AS root ***"
    echo
    exit 1
fi

#
# Create lightweight container to run mkksiso utility
#
podman build \
  -t mkksiso:latest \
  ${TEMP_DIR}

#
# Add the kickstart and command line options to the boot ISO
#
podman run \
  --rm \
  --privileged \
  -v ${TEMP_DIR}:/data:Z \
  mkksiso:latest \
  /usr/sbin/mkksiso -c "inst.text console=ttyS0" edge.ks ${ISO_NAME} bootwithks.iso

#
# make sure all files owned by $SUDO_USER
#
chown -R $SUDO_USER: ${TEMP_DIR}

echo "Output directory: ${TEMP_DIR}"
