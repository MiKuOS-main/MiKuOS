# MiKuOS identity module.
#
# The MiKuOS installer writes this alongside the generated configuration.nix,
# and imports it, so a freshly installed system is branded MiKuOS instead of
# stock NixOS.  `./mikuos` (next to this file) holds the artwork shipped with
# the installer.
{ config, pkgs, lib, ... }:

let
  assets = ./mikuos;  # wallpapers/ and logo.png copied in by the installer

  mikuWallpapers = pkgs.runCommand "miku-wallpapers" { } ''
    mkdir -p $out/share/backgrounds/miku
    cp ${toString assets}/wallpapers/* $out/share/backgrounds/miku/
    ln -sf $out/share/backgrounds/miku/3516132-ultrawide.jpg \
      $out/share/backgrounds/miku/default.jpg
  '';
in
{
  # ── Identity ──────────────────────────────────────────────
  system.nixos.distroName = "MiKuOS";
  system.nixos.distroId = "mikuos";
  system.nixos.vendorName = "MiKuOS";
  system.nixos.extraOSReleaseArgs = {
    HOME_URL = "https://mikuos.local/";
    SUPPORT_URL = "https://mikuos.local/support";
    DOCUMENTATION_URL = "https://mikuos.local/manual";
    BUG_REPORT_URL = "https://github.com/MiKuOS-Main/MiKuOS/issues";
    ANSI_COLOR = "0;38;2;57;197;187";
  };

  # The installer may already write this when "allow unfree" was chosen.
  nixpkgs.config.allowUnfree = lib.mkDefault true;

  # ── The Miku rounded typeface ─────────────────────────────
  fonts.packages = with pkgs; [ rounded-mgenplus ];
  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Rounded Mgen+ 1c" ];
    serif = [ "Rounded Mgen+ 1pp" ];
    monospace = [ "Rounded Mgen+ 2m" ];
  };

  # ── A usable default toolset ──────────────────────────────
  environment.systemPackages = with pkgs; [
    mikuWallpapers
    kitty
    btop
    htop
    fastfetch
    cmatrix
    ncdu
    bat
    ripgrep
    git
    vim
    nano
    firefox
  ];

  i18n.supportedLocales = [ "all" ];

  system.stateVersion = lib.mkDefault "26.05";
}