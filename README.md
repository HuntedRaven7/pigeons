# pigeon

A [bootc](https://github.com/bootc-dev/bootc) image built on **Hummingbird OS**, layered with three Fedora 44 task images (KDE desktop, dev tooling, gaming) and the NVIDIA driver stack.

## Architecture

```
┌────────────────────────────── pigeon (bootable) ─────────────────────────────┐
│  Hummingbird OS base (quay.io/hummingbird-community/bootc-os:latest)        │
│  + KDE desktop layer        (ghcr.io/<owner>/kde)                            │
│  + Dev tooling layer        (ghcr.io/<owner>/dev)                            │
│  + Gaming layer             (ghcr.io/<owner>/gaming)                         │
│  + NVIDIA driver + kmod (OGC kernel)                                         │
└───────────────────────────────────────────────────────────────────────────────┘
```

- **`containerfiles/Containerfile`** builds the three task images from `quay.io/fedora/fedora-bootc:44`. A shared base stage:
  - installs common packages and `dnf5-plugins`
  - swaps the stock Fedora kernel for the ublue **OGC kernel** (`7.1.6-ogc4.1.fc44`) using the [Bazzite](https://github.com/ublue-os/bazzite) akmods approach
  - installs ublue akmods (framework-laptop, openrazer, v4l2loopback, vhba, xone, xpadneo, broadcom-wl) prebuilt against that kernel
  - regenerates the initramfs

  Each flavor stage adds its own packages:
  - `kde`: Plasma desktop (sddm, konsole, dolphin, kate, discover, …), boots to `graphical.target`
  - `dev`: git/gh, python, nodejs, golang, rust, gcc/clang toolchain, distrobox/toolbox
  - `gaming`: RPM Fusion free+nonfree (steam), lutris, wine, mangohud, gamescope, gamemode, protontricks + the extra akmods (sim racing/peripheral drivers)

- **`Containerfile`** (root) layers those three images onto the Hummingbird base with `COPY --from=... / /`, installs the NVIDIA driver stack from `ghcr.io/ublue-os/akmods-nvidia-open` (matching the OGC kernel), regenerates the initramfs (so `99-nvidia.conf` force-loads the driver) and restores the Hummingbird OS identity.

> [!NOTE]
> The task images must be built and pushed **before** the main image, since the main build pulls them from the registry. The `build.yml` workflow handles this ordering (flavor matrix job, then the pigeon job).

## Building locally

Requires `podman`.

```bash
# Build all task images (tags them as ghcr.io/<owner>/<flavor>:latest)
just build-flavor kde latest
just build-flavor dev latest
just build-flavor gaming latest

# Build the main Hummingbird image (pulls the flavors from the registry)
just build pigeon latest
```

To build the main image against flavors you have not pushed yet, tag them locally first:

```bash
podman build --target kde -f containerfiles/Containerfile -t ghcr.io/huntedraven7/kde:latest .
# ...then build the root Containerfile
```

## GitHub Actions

- `build.yml` builds, pushes and signs `kde`, `dev`, `gaming`, then `pigeon`. It runs on every push to `main` and on a daily schedule.
- `build-disk.yml` builds disk images (qcow2 / anaconda-iso) with [bootc-image-builder](https://github.com/osbuild/bootc-image-builder) on `workflow_dispatch`.

### Container signing

Signing only runs on `main` once a `SIGNING_SECRET` repository secret exists.

```bash
COSIGN_PASSWORD="" cosign generate-key-pair
```

Add `cosign.key` as a repository secret named `SIGNING_SECRET`. Never commit `cosign.key`.

## Notes / limitations

- The final image identifies as **Hummingbird OS** (`/etc/os-release` restored). Because of that, `dnf` layering at runtime uses `VERSION_ID=20251124` rather than a Fedora version; updates should come from new container images (`bootc upgrade`).
- The three task layers are merged at the filesystem level, so `rpm -qa` in the final image only lists packages from the last copied layer. Use the flavor images if you need per-flavor package manifests.
- The OGC kernel is version-locked, so `dnf` upgrades will not silently replace it with a stock Fedora kernel.
- `rechunk` (smaller delta updates via [chunkah](https://github.com/coreos/chunkah)) is intentionally not enabled in CI yet. Re-enable the `just rechunk` step in `build.yml` once you are comfortable with the pipeline.
