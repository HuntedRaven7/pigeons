#!/bin/bash

set -ouex pipefail

cp -avf "/ctx/system_files"/. /

dnf -y copr enable lionheartp/Hyprland
dnf -y install hyprland
dnf -y copr disable lionheartp/Hyprland

systemctl enable podman.socket
