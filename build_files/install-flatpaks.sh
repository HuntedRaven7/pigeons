#!/usr/bin/env bash

set -euo pipefail

FLATPAK_APPS_FILE="/ctx/build_files/flatpak-apps"

# Install the Flatpak runtime + portal support on the final image
dnf5 -y install flatpak

# Enable the Flathub system remote so apps can be installed at build time
flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo

# Install the baked-in apps, one Flatpak ref per non-comment line
if [[ -f "${FLATPAK_APPS_FILE}" ]]; then
    while IFS= read -r app; do
        [[ "${app}" =~ ^#.*$ || -z "${app}" ]] && continue
        flatpak install -y --noninteractive flathub "${app}"
    done < "${FLATPAK_APPS_FILE}"
fi

# Drop the install cache so it isn't baked into the image
rm -rf /var/lib/flatpak/repo/cache /var/tmp/flatpak-cache-*
