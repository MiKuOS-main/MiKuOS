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

  mikuLogo = ../themes/miku/miku-logo.png;
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
      cp ${mikuLogo} $out/share/calamares/branding/mikuos/logo.png
      cp ${mikuNight} $out/share/calamares/branding/mikuos/miku-cosmic-night.jpg
      cp ${mikuSpace} $out/share/calamares/branding/mikuos/miku-space.jpg
      cp ${mikuStarfield} $out/share/calamares/branding/mikuos/miku-starfield.jpg
      cp ${mikuNight} $out/share/calamares/branding/mikuos/images/cosmic.jpg
      cp ${src}/branding/nixos/images/nodesktop.jpg \
        $out/share/calamares/branding/mikuos/images/nodesktop.jpg

      # Installed-system identity: the nixos module copies these into the
      # target's /etc/nixos and imports ./mikuos.nix.
      mkdir -p $out/share/calamares/mikuos-assets/wallpapers
      cp ${walls}/*.jpg $out/share/calamares/mikuos-assets/wallpapers/
      cp ${mikuLogo} $out/share/calamares/mikuos-assets/logo.png
      cp ${overlayDir}/mikuos-installed/mikuos.nix \
        $out/share/calamares/mikuos-assets/mikuos.nix

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

  # Launcher that elevates Calamares to root while keeping it on the live
  # session's display.
  #
  # Why this is needed: pkexec sanitizes the environment, and even if it did
  # not, libwayland refuses clients whose euid does not own XDG_RUNTIME_DIR,
  # so a root process cannot talk to the user's Wayland compositor. Qt then
  # falls back to the xcb backend against $DISPLAY and dies with "could not
  # connect to display" because the root process holds no X cookie. Solution:
  # run the Qt installer on the session's Xwayland display, authorize root via
  # xhost +SI:localuser:root (server-interpreted auth, no cookie needed), keep
  # XAUTHORITY as a fallback, and force the xcb backend.
  launcher = pkgs.writeShellScriptBin "mikuos-installer" ''
    DISPLAY="''${DISPLAY:-}"
    if [ -z "$DISPLAY" ]; then
      for sock in /tmp/.X11-unix/X*; do
        [ -S "$sock" ] || continue
        DISPLAY=":''${sock##*/X}"
        break
      done
    fi
    export DISPLAY

    if [ -n "$DISPLAY" ] && [ -x "${lib.getExe' pkgs.xhost "xhost"}" ]; then
      "${lib.getExe' pkgs.xhost "xhost"}" +SI:localuser:root >/dev/null 2>&1 || true
    fi

    exec "${lib.getExe' pkgs.polkit "pkexec"}" "${lib.getExe' pkgs.coreutils "env"}" \
      DISPLAY="$DISPLAY" \
      XAUTHORITY="''${XAUTHORITY:-''${HOME}/.Xauthority}" \
      XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/0}" \
      QT_QPA_PLATFORM=xcb \
      HOME=/root \
      ${calamares}/bin/calamares "$@"
  '';

  # MiKuOS logo (the Miku avatar) installed as a proper XDG app icon so the
  # installer launchers and the dock/taskbar show it instead of the generic
  # Calamares icon.
  icons = pkgs.runCommand "mikuos-app-icons" { } ''
    mkdir -p $out/share/icons/hicolor/{48x48,64x64,128x128,256x256}/apps
    for s in 48x48 64x64 128x128 256x256; do
      cp ${mikuLogo} $out/share/icons/hicolor/$s/apps/mikuos.png
    done
  '';

  # Patched copy of the Calamares desktop entry so any launcher and the
  # autostart item present the MiKuOS logo and name.
  desktop = pkgs.runCommand "calamares-mikuos-desktop" { } ''
    mkdir -p $out/share/applications
    sed -e 's/^Icon=calamares$/Icon=mikuos/' \
        -e 's|^Exec=.*$|Exec=${launcher}/bin/mikuos-installer|' \
        -e 's|^TryExec=.*$|TryExec=${launcher}/bin/mikuos-installer|' \
      '${calamares}/share/applications/calamares.desktop' \
      > $out/share/applications/calamares.desktop
  '';
in
{
  inherit extensions calamares icons desktop launcher;
}