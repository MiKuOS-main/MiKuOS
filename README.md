MiKuOS
MiKuOS is a NixOS-based desktop with a COSMIC desktop experience, a graphical installer (Calamares), and Miku-themed branding across boot, live session, and default theming. The repository includes the NixOS host configuration and a standalone ISO module to produce a bootable live/installer image.
What you get
- Live COSMIC Desktop + Installer  
A bootable live environment with a Calamares-based graphical installer and a Miku-themed desktop.
- Miku branding throughout  
- GRUB/EFI boot menus  
- Isolinux/BIOS boot menu  
- Plymouth boot splash  
- Miku wallpapers and accent color (#39C5BB)  
- COSMIC dark/light accent and background configuration
- Practical live defaults  
Terminal tools (Kitty, btop, htop, bat, ripgrep, ncdu, neovim, etc.), Firefox, GParted, Calamares installer, and a clean desktop layout.
Repository layout (recommended)
This repo is structured around a classic NixOS setup (no flakes required).
- configuration.nix  
Host-level NixOS configuration (including MiKuOS branding options).
- home.nix  
Home Manager configuration for user environment (theming, shell, terminal, etc.)
- mikuos-iso.nix  
Standalone NixOS module used to build the MiKuOS live/installer ISO.
- themes/miku/  
Miku branding assets (wallpapers, GRUB/Plymouth theme sources, COSMIC configs).
- pkgs/  
Local packages (wallpaper package, GRUB theme, Plymouth theme, etc.)
Build the MiKuOS ISO
The ISO is built using classic NixOS evaluation (no flakes).
Eval the image (quick sanity check)
nix-instantiate --eval --strict '<nixos/nixos>' \
  --arg configuration ./mikuos-iso.nix \
  -A config.system.nixos.distroName
Build the ISO (background build recommended)
mkdir -p /tmp/opencode
setsid nix-build '<nixos/nixos>' \
  -A config.system.build.isoImage \
  --arg configuration ./mikuos-iso.nix \
  -o /tmp/opencode/mikuos-iso-out \
  --max-jobs 4 \
  > /tmp/opencode/mikuos-iso-build.log 2>&1 & disown
When complete, the uncompressed ISO path will typically be in:
/tmp/opencode/mikuos-iso-out/iso/mikuos-26.05-x86_64-linux.iso
If a zstd-compressed copy is produced, you can use the raw ISO for flashing.
Flash the ISO to a USB drive
Replace /dev/sdX with your USB device.
# Option A: use the compressed artifact (if you kept the .zst)
zstd -d /path/to/mikuos-26.05-x86_64-linux.iso.zst -o /tmp/mikuos.iso
# Option B: use the uncompressed ISO directly
# (from the build output path)
# Write to USB
sudo dd if=/tmp/mikuos.iso of=/dev/sdX bs=4M status=progress conv=fsync
sync
You can also use a graphical tool like USBImager if you prefer.
Boot and install
1. Boot from the MiKuOS USB.  
2. The live session starts as nixos and opens the COSMIC desktop.  
3. Use the Install MiKuOS or Calamares launcher on the Desktop to begin installation.  
4. After install, reboot into your new MiKuOS system.
Host configuration (on an installed system)
The host uses a classic NixOS setup. The main entrypoint is:
- /etc/nixos/configuration.nix
MiKuOS branding is handled via NixOS internal identity options so the distro name shows up consistently in:
- OS metadata (os-release)  
- GRUB/EFI boot menus  
- Plymouth and live session branding
Example host identity block (high level):
- NAME=MiKuOS
- ID=mikuos
- ID_LIKE=nixos
- PRETTY_NAME="MiKuOS 26.05 (Yarara)"
- Miku accent color and URL metadata
Notes
- This is not a generic NixOS mirror; the ISO is intentionally scoped to a live COSMIC desktop + installer.
- Live desktop provisioning (backgrounds, accent color, app launchers) is performed via systemd-tmpfiles for a clean, reproducible setup.
- Plymouth theming and GRUB theming are bundled from local theme packages under themes/ and pkgs/.
