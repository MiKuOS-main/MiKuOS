# MiKuOS

**Current release: 1.0.0 "Tetu"** (built on NixOS 26.05)

MiKuOS is a **NixOS-based desktop** with a **COSMIC** desktop experience, a graphical installer (Calamares), and Miku-themed branding across boot, live session, and default theming. The repository includes the NixOS host configuration and a standalone ISO module to produce a bootable live/installer image.

## Versioning

The release number and codename are defined once, in [`release.nix`](release.nix), and consumed everywhere else:

| Field | Value | Notes |
| --- | --- | --- |
| `version` | `1.0.0` | MiKuOS's own release number |
| `codeName` | `Tetu` | Release nickname |
| `nixosBaseRelease` | `26.05` | NixOS release this is built on; also used for `system.stateVersion` |

MiKuOS's version is intentionally independent of the NixOS release it builds on, so the two can be read independently.

The nickname is **not** set via `system.nixos.codeName`: that option is `readOnly` in nixpkgs and is pinned to upstream's own codename. MiKuOS carries its nickname in `system.nixos.variantName` (surfaced as `VARIANT` in `os-release`), the Calamares branding component, and the ISO filename instead.

Bump the release by editing `release.nix`; do not hardcode the version anywhere else.

## What you get

- **Live COSMIC Desktop + Installer**
  A bootable live environment with a Calamares-based graphical installer and a Miku-themed desktop.

- **Miku branding throughout**
  - GRUB/EFI boot menus
  - Isolinux/BIOS boot menu
  - Plymouth boot splash
  - Miku wallpapers and accent color (`#39C5BB`)
  - COSMIC dark/light accent and background configuration

- **Practical live defaults**
  Terminal tools (Kitty, btop, htop, bat, ripgrep, ncdu, neovim, etc.), Firefox, GParted, Calamares installer, and a clean desktop layout.

## Download & reassemble

The ISO is split into `< 2 GB` chunks because GitHub Releases caps individual assets at 2 GB. Download **all** parts from the Releases page, then reassemble.

Substitute the release you downloaded; for 1.0.0 "Tetu" the name is `mikuos-1.0.0-Tetu-x86_64-linux.iso`:

```bash
cat mikuos-<version>-<codename>-x86_64-linux.iso.part* > mikuos-<version>-<codename>-x86_64-linux.iso
```

Verify integrity against the `sha256sum` published on the Releases page:

```bash
sha256sum mikuos-<version>-<codename>-x86_64-linux.iso
```

## Flash to a USB drive

Replace `/dev/sdX` with your USB device:

```bash
sudo dd if=mikuos-<version>-<codename>-x86_64-linux.iso of=/dev/sdX bs=4M status=progress conv=fsync
sync
```

You can also use a graphical tool like **USBImager**.

## Boot and install

1. Boot from the MiKuOS USB.
2. The live session starts as `nixos` and opens the COSMIC desktop.
3. Use the **Install MiKuOS** or **Calamares** launcher on the Desktop to begin installation.
4. Reboot into your new MiKuOS system.

## Repository layout

Classic NixOS setup (no flakes required).

- `release.nix` — single source of truth for the version, codename and NixOS base release
- `configuration.nix` — host-level NixOS configuration (MiKuOS branding options)
- `home.nix` — Home Manager configuration (theming, shell, terminal)
- `mikuos-iso.nix` — standalone module used to build the MiKuOS live/installer ISO
- `themes/miku/` — branding assets (wallpapers, GRUB/Plymouth theme sources, COSMIC configs)
- `pkgs/` — local packages (wallpapers, GRUB theme, Plymouth theme, etc.)

## Build the MiKuOS ISO

Evaluation is done via classic NixOS (no flakes). Note the fyi: `'<nixos/nixos>'` is the NixOS top-level of the channel; `'<nixos>'` alone resolves to the nixpkgs checkout.

```bash
# Sanity check the eval
nix-instantiate --eval --strict '<nixos/nixos>' \
  --arg configuration ./mikuos-iso.nix \
  -A config.system.nixos.distroName

# Build (background, 4 jobs; adjust --max-jobs to your host)
mkdir -p /tmp/opencode
setsid nix-build '<nixos/nixos>' \
  -A config.system.build.isoImage \
  --arg configuration ./mikuos-iso.nix \
  -o /tmp/opencode/mikuos-iso-out \
  --max-jobs 4 \
  > /tmp/opencode/mikuos-iso-build.log 2>&1 & disown
```

The uncompressed ISO is written to `iso/mikuos-<version>-<codename>-x86_64-linux.iso` inside the build output (or store) path — e.g. `iso/mikuos-1.0.0-Tetu-x86_64-linux.iso` for the current release.

## Notes

- This is **not a generic NixOS mirror**; the ISO is intentionally scoped to a live COSMIC desktop + installer.
- Live desktop provisioning (backgrounds, accent color, app launchers) is performed via `systemd-tmpfiles`.
- Host identity is set through NixOS options so branding shows up consistently in os-release, GRUB/EFI menus, and the live session.