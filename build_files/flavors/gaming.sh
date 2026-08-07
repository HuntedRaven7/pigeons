#!/usr/bin/env bash

set -oue pipefail

# Gaming: RPM Fusion (steam), lutris, proton tools and the extra akmods
# (sim racing / peripheral drivers) from the akmods-extra image.

# Copy flavor-specific system overlay files
if [[ -d /ctx/system_files/gaming ]]; then
    cp -avf /ctx/system_files/gaming/. /
fi

# Enable RPM Fusion free + nonfree
dnf5 -y install --nogpgcheck \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

GAMING_PKGS=(
    steam
    lutris
    wine
    winetricks
    mangohud
    gamescope
    gamemode
    vkBasalt
    goverlay
    protontricks
    vulkan-tools
    libva-utils
)

dnf5 -y install --setopt=install_weak_deps=False "${GAMING_PKGS[@]}"

# Extra akmods prebuilt against the OGC kernel (mounted from akmods-extra)
/ctx/build_files/install-kmods \
    /tmp/rpms/{extra,kmods-extra}/*zenergy*.rpm \
    /tmp/rpms/{extra,kmods-extra}/*gcadapter*.rpm \
    /tmp/rpms/{extra,kmods-extra}/*kvmfr*.rpm \
    /tmp/rpms/{extra,kmods-extra}/*new-lg4ff*.rpm \
    /tmp/rpms/{extra,kmods-extra}/*hid-tmff2*.rpm \
    /tmp/rpms/{extra,kmods-extra}/*t150-driver*.rpm \
    /tmp/rpms/{extra,kmods-extra}/*hid-fanatecff*.rpm \
    /tmp/rpms/{extra,kmods-extra}/*ryzen_smu*.rpm \
    /tmp/rpms/{extra,kmods-extra}/*sc0710*.rpm \
    /tmp/rpms/{extra,kmods-extra}/*system76*.rpm
