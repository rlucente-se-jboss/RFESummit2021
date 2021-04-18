#!/usr/bin/env bash

. $(dirname $0)/demo.conf

#
# Use EPEL to install something a bit more interesting than just
# plain text
#
sudo subscription-manager repos \
    --enable=codeready-builder-for-rhel-8-x86_64-rpms

sudo dnf -y install dnf-utils \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo dnf config-manager --disable epel epel-modular

sudo dnf -y install --enablerepo=epel cowsay figlet || exit 1

#
# Create containerized httpd application version 1
#
CTR_ID=$(buildah from registry.access.redhat.com/ubi8/ubi:latest)
buildah run $CTR_ID -- yum -y install httpd
echo "RHEL for Edge" | figlet > index.html
buildah copy $CTR_ID index.html /var/www/html/index.html
buildah config --cmd "/usr/sbin/httpd -D FOREGROUND" $CTR_ID
buildah config --port 80 $CTR_ID
buildah commit $CTR_ID $HOSTIP:5000/httpd:v1

podman push $HOSTIP:5000/httpd:v1

#
# Tag the image as "prod" in the local insecure registry
#
podman tag $HOSTIP:5000/httpd:v1 $HOSTIP:5000/httpd:prod
podman push $HOSTIP:5000/httpd:prod

#
# Create containerized httpd application version 2
#
CTR_ID=$(buildah from $HOSTIP:5000/httpd:v1)
cowthink -f tux 'Podman auto-update is awesome!' >> index.html
buildah copy $CTR_ID index.html /var/www/html/index.html
buildah commit $CTR_ID $HOSTIP:5000/httpd:v2

podman push $HOSTIP:5000/httpd:v2

