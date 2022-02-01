FROM registry.fedoraproject.org/fedora:34-x86_64

RUN dnf install -y lorax && \
    dnf clean all && \
    mkdir /data

WORKDIR /data
