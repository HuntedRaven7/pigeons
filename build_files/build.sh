#!/bin/bash

set -ouex pipefail

cp -avf "/ctx/system_files"/. /

dnf -y install dnf5-plugins 

dnf -y copr enable --hub copr.fedorainfracloud.org lionheartp/Hyprland fedora-rawhide-x86_64
dnf repolist --enabled
dnf repoquery cairo
dnf repoquery mesa-libEGL
dnf repoquery xorg-x11-server-Xwayland
dnf -y install hyprland
dnf -y copr disable lionheartp/Hyprland

systemctl enable podman.socket
