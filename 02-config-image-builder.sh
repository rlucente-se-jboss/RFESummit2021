#!/usr/bin/env bash

. $(dirname $0)/demo.conf

if [[ $EUID -ne 0 ]]
then
    echo
    echo "*** MUST RUN AS root ***"
    echo
    exit 1
fi

# install RHEL 8 virtualization module
dnf -y module install virt

# install image builder and other necessary packages
dnf -y install osbuild-composer composer-cli cockpit-composer \
    bash-completion jq virt-install virt-viewer cockpit-machines golang

# enable libvirtd
systemctl enable --now libvirtd

# enable image builder to start after reboot
systemctl enable --now cockpit.socket osbuild-composer.socket

# add user to weldr group so they don't need to be root to run image builder
[[ ! -z "$SUDO_USER" ]] && usermod -aG weldr $SUDO_USER

firewall-cmd --permanent --add-port=8000/tcp
firewall-cmd --reload

# prep the edge.ks file
envsubst '${HOSTIP} ${VIP_IP} ${VIP_MASK}' < edge.ks.orig > edge.ks

echo "Verify that system is prepared to be a virtualization host"
virt-host-validate


sudo virt-host-validate

echo
echo 'If you see "Checking if IOMMU is enabled by kernel : WARN" then'
echo 'enable it by adding either the option intel_iommu=on or amd_iommu=on'
echo 'to the GRUB_CMDLINE_LINUX line in /etc/default/grub and then'
echo 'running the following commands:'
echo
echo "    sudo vi /etc/default/grub"
echo "    sudo grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg"
echo "    sudo reboot"
echo

