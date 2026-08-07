# pigeon: the bootable Hummingbird image.
#
# The f44 task images (kde / dev / gaming) are built and pushed first by
# containerfiles/Containerfile. This Containerfile layers their complete
# filesystems onto the Hummingbird bootc base, then adds the NVIDIA driver
# stack on top of the OGC fc44 kernel that the task images provide.

ARG IMAGE_REGISTRY="ghcr.io/huntedraven7"
ARG DEFAULT_TAG="latest"
ARG KERNEL_VERSION="7.1.6-ogc4.1.fc44.x86_64"
ARG BREW_IMAGE="ghcr.io/ublue-os/brew:latest"
ARG BREW_IMAGE_SHA=""

FROM quay.io/hummingbird-community/bootc-os:latest AS base

FROM ${IMAGE_REGISTRY}/kde:${DEFAULT_TAG} AS kde
FROM ${IMAGE_REGISTRY}/dev:${DEFAULT_TAG} AS dev
FROM ${IMAGE_REGISTRY}/gaming:${DEFAULT_TAG} AS gaming

# Homebrew package manager 
FROM ${BREW_IMAGE}@${BREW_IMAGE_SHA} AS brew

# NVIDIA driver + kmod, built against the OGC fc44 kernel
FROM ghcr.io/ublue-os/akmods-nvidia-open:ogc-44-${KERNEL_VERSION} AS akmods-nvidia

FROM base

# Layer the f44 task images onto the Hummingbird base + Brew
COPY --from=brew /system_files /system_files/shared
COPY --from=kde / /
COPY --from=dev / /
COPY --from=gaming / /

COPY . /ctx

# NVIDIA driver stack. Runs while /etc/os-release is still Fedora 44 so dnf
# can resolve the Fedora repos, then regenerates the initramfs so the driver
# is force-loaded at boot.
COPY --from=akmods-nvidia /rpms /tmp/akmods-rpms
RUN bash /tmp/akmods-rpms/ublue-os/nvidia-install.sh \
 && rm -rf /tmp/akmods-rpms \
 && /ctx/build_files/build-initramfs \
 && rm -rf /ctx

# Restore the Hummingbird OS identity
COPY --from=base /etc/os-release /etc/os-release
COPY --from=base /usr/lib/os-release /usr/lib/os-release

RUN bootc container lint
