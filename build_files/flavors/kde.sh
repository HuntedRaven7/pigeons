#!/usr/bin/env bash

set -oue pipefail

# KDE Plasma desktop

# Copy flavor-specific system overlay files
if [[ -d /ctx/system_files/kde ]]; then
    cp -avf /ctx/system_files/kde/. /
fi

KDE_PKGS=(
    plasma-desktop
    plasma-workspace
    plasma-systemsettings
    plasma-pa
    plasma-nm
    plasma-discover
    kdeplasma-addons
    kde-gtk-config
    sddm
    konsole
    dolphin
    kate
    ark
    spectacle
    gwenview
    okular
    ffmpegthumbs
    filelight
    bluedevil
    powerdevil
    PackageKit
    flatpak)

dnf5 -y install --setopt=install_weak_deps=False "${KDE_PKGS[@]}"

# Boot straight into the desktop
mkdir -p /usr/lib/systemd/system
ln -sf /usr/lib/systemd/system/graphical.target /usr/lib/systemd/system/default.target

systemctl enable sddm.service
