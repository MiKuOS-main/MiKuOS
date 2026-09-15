# MiKuOS fork of the Calamares NixOS installer.
#
# Produces:
#   .extensions — a patched copy of calamares-nixos-extensions with MiKuOS
#                 module configs, a "cosmic" desktop choice, MiKuOS wording,
#                 and a "mikuos" branding component.
#   .calamares  — a calamares binary re-wrapped to pick up the patched
#                 extensions via XDG_DATA_DIRS/XDG_CONFIG_DIRS.
{ lib, stdenv, pkgs }:

let
  upstream = pkgs.calamares-nixos-extensions;
  src = upstream.src;

  overlayDir = ../calamares;
  walls = ../themes/miku/wallpapers;

  mikuAvatar = walls + "/miku-avatar.png";
  mikuNight = walls + "/miku-cosmic-night.jpg";
  mikuSpace = walls + "/miku-space.jpg";
  mikuStarfield = walls + "/miku-starfield.jpg";

  python = pkgs.python3;

  extensions = stdenv.mkDerivation {
    pname = "calamares-mikuos-extensions";
    version = "${upstream.version}-mikuos";

    inherit src;

    nativeBuildInputs = [ python ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/{etc,lib,share}/calamares

      # Upstream tree.
      cp -r ${src}/modules $out/lib/calamares/
      cp -r ${src}/config/* $out/etc/calamares/
      cp -r ${src}/branding $out/share/calamares/
      chmod -R u+w $out/etc/calamares $out/lib/calamares $out/share/calamares

      # MiKuOS module configs override the upstream ones.
      cp -r ${overlayDir}/etc/calamares/modules/* $out/etc/calamares/modules/

      # Add the COSMIC desktop option and MiKuOS wording to the nixos module.
      ${python}/bin/python3 ${overlayDir}/patch_main.py \
        $out/lib/calamares/modules/nixos/main.py

      # MiKuOS branding component + image assets.
      mkdir -p $out/share/calamares/branding/mikuos
      cp -r ${overlayDir}/branding/mikuos/* $out/share/calamares/branding/mikuos/
      chmod -R u+w $out/share/calamares/branding/mikuos
      cp ${mikuAvatar} $out/share/calamares/branding/mikuos/logo.png
      cp ${mikuNight} $out/share/calamares/branding/mikuos/miku-cosmic-night.jpg
      cp ${mikuSpace} $out/share/calamares/branding/mikuos/miku-space.jpg
      cp ${mikuStarfield} $out/share/calamares/branding/mikuos/miku-starfield.jpg
      cp ${mikuNight} $out/share/calamares/branding/mikuos/images/cosmic.jpg
      cp ${src}/branding/nixos/images/nodesktop.jpg \
        $out/share/calamares/branding/mikuos/images/nodesktop.jpg

      # settings.conf: expand the out path, switch branding, prompt before install.
      substituteInPlace $out/etc/calamares/settings.conf --replace-fail @out@ $out
      substituteInPlace $out/etc/calamares/settings.conf \
        --replace-fail "branding: nixos" "branding: mikuos"
      substituteInPlace $out/etc/calamares/settings.conf \
        --replace-fail "prompt-install: false" "prompt-install: true"
      substituteInPlace $out/etc/calamares/modules/locale.conf \
        --replace-fail @glibcLocales@ ${pkgs.glibcLocales}

      runHook postInstall
    '';
  };

  calamares = pkgs.calamares.override {
    extraWrapperArgs = [
      "--prefix XDG_DATA_DIRS : ${extensions}/share"
      "--prefix XDG_CONFIG_DIRS : ${extensions}/etc"
      "--add-flag --xdg-config"
    ];
  };

  # MiKuOS logo (the Miku avatar) installed as a proper XDG app icon so the
  # installer launchers and the dock/taskbar show it instead of the generic
  # Calamares icon.
  icons = pkgs.runCommand "mikuos-app-icons" { } ''
    mkdir -p $out/share/icons/hicolor/{48x48,64x64,128x128,256x256}/apps
    for s in 48x48 64x64 128x128 256x256; do
      cp ${mikuAvatar} $out/share/icons/hicolor/$s/apps/mikuos.png
    done
  '';

  # Patched copy of the Calamares desktop entry so any launcher and the
  # autostart item present the MiKuOS logo and name.
  desktop = pkgs.runCommand "calamares-mikuos-desktop" { } ''
    mkdir -p $out/share/applications
    sed 's/^Icon=calamares$/Icon=mikuos/' \
      '${calamares}/share/applications/calamares.desktop' \
      > $out/share/applications/calamares.desktop
  '';
in
{
  inherit extensions calamares icons desktop;
}