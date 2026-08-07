#!/usr/bin/env bash

set -oue pipefail

# Copy pre-built system overlay files
if [[ -d /ctx/system_files/base ]]; then
    cp -avf /ctx/system_files/base/. /
fi

# Tooling used by the rest of the build (dnf5 copr / config-manager)
dnf5 -y install dnf5-plugins

# Common packages present on every pigeon image
dnf5 -y install --setopt=install_weak_deps=False \
    git \
    curl \
    wget2 \
    jq \
    pciutils \
    usbutils \
    unzip \
    ripgrep \
    fzf \
    vim \
    tmux \
    zsh \
    fish \
    fastfetch \
    btop

# Container tooling is useful everywhere
systemctl enable podman.socket
