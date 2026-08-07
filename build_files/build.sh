#!/bin/bash

set -ouex pipefail

cp -avf "/ctx/system_files"/. /

dnf5 -y copr enable lionheartp/Hyprland
dnf5 -y install hyprland
dnf5 -y copr disable lionheartp/Hyprland

systemctl enable podman.socket
