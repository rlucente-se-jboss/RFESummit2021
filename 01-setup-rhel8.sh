#!/usr/bin/env bash

. $(dirname $0)/demo.conf

if [[ $EUID -ne 0 ]]
then
    echo
    echo "*** MUST RUN AS root ***"
    echo
    exit 1
fi

subscription-manager register \
    --username $USERNAME --password $PASSWORD || exit 1
subscription-manager role --set="Red Hat Enterprise Linux Server"
subscription-manager service-level --set="Self-Support"
subscription-manager usage --set="Development/Test"
subscription-manager attach

dnf -y update
dnf -y clean all

#
# set up bridged network
#
ETHDEV="$(nmcli -t con show |grep $(ip route get 8.8.8.8 | awk '{print $5; exit}') | awk -F: '{print $1}')"
nmcli connection add type bridge con-name bridge0 ifname bridge0
nmcli connection modify "$ETHDEV" master bridge0
nmcli connection modify bridge0 ipv6.method ignore bridge.stp no
nmcli connection up bridge0

