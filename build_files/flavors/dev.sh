#!/usr/bin/env bash

set -oue pipefail

# Development tooling

# Copy flavor-specific system overlay files
if [[ -d /ctx/system_files/dev ]]; then
    cp -avf /ctx/system_files/dev/. /
fi

DEV_PKGS=(
    git
    git-lfs
    gh
    python3
    python3-pip
    python3-devel
    nodejs24
    nodejs24-npm
    golang
    rust
    cargo
    gcc
    gcc-c++
    make
    cmake
    ninja-build
    clang
    openssl-devel
    sqlite-devel
    libffi-devel
    zlib-devel
    podman-compose
    distrobox
    toolbox
)

dnf5 -y install --setopt=install_weak_deps=False "${DEV_PKGS[@]}"
