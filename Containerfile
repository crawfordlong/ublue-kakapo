ARG IMAGE_NAME="${IMAGE_NAME:-silverblue}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-silverblue}"
ARG BASE_IMAGE="quay.io/fedora-ostree-desktops/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-37}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS builder

ARG IMAGE_NAME="${IMAGE_NAME}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION}"

ADD build.sh /tmp/build.sh
ADD post-install.sh /tmp/post-install.sh
ADD packages.json /tmp/packages.json

COPY --from=ghcr.io/ublue-os/config:latest /rpms /tmp/rpms

RUN /tmp/build.sh

RUN cd /etc/yum.repos.d/ && curl -LO https://pkgs.tailscale.com/stable/fedora/tailscale.repo && \
    rpm-ostree install tailscale && \
    systemctl enable tailscaled
    
RUN cd /etc/yum.repos.d/ && curl -LO https://copr.fedorainfracloud.org/coprs/varlad/helix/repo/fedora-${FEDORA_MAJOR_VERSION}/varlad-helix-fedora-${FEDORA_MAJOR_VERSION}.repo && \
    rpm-ostree install helix

RUN git clone --recursive https://github.com/hyprwm/Hyprland
    cd Hyprland
    sudo make install

RUN /tmp/post-install.sh
RUN rm -rf /tmp/* /var/*
RUN ostree container commit
RUN mkdir -p /var/tmp && chmod -R 1777 /var/tmp
