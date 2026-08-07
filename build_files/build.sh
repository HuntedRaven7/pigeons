#!/bin/bash

set -ouex pipefail

cp -avf "/ctx/system_files"/. /

dnf -y install dnf5 dnf5-plugins

dnf5 -y copr enable --hub copr.fedorainfracloud.org lionheartp/Hyprland fedora-rawhide-x86_64
dnf5 -y install hyprland
dnf5 -y copr disable lionheartp/Hyprland

systemctl enable podman.socket
