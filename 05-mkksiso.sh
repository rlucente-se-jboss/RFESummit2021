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
# Add the kickstart and command line options to the primary's boot ISO
#
podman run \
  --rm \
  --privileged \
  -v ${TEMP_DIR}:/data:Z \
  mkksiso:latest \
  /usr/sbin/mkksiso -c "inst.text console=ttyS0 vip_state=master vip_priority=200" \
  edge.ks ${ISO_NAME} primarybootwithks.iso

#
# Add the kickstart and command line options to the backup's boot ISO
#
podman run \
  --rm \
  --privileged \
  -v ${TEMP_DIR}:/data:Z \
  mkksiso:latest \
  /usr/sbin/mkksiso -c "inst.text console=ttyS0 vip_state=backup vip_priority=100" \
  edge.ks ${ISO_NAME} backupbootwithks.iso

#
# Copy ISOs to home directory and make sure all files owned by $SUDO_USER
#
cp ${TEMP_DIR}/*bootwithks.iso /home/${SUDO_USER}/
chown ${SUDO_USER} /home/${SUDO_USER}/*bootwithks.iso

rm -rf $(echo ${TEMP_DIR})
