# MiKuOS identity + COSMIC theming module for freshly installed systems.
#
# The MiKuOS installer writes this alongside the generated configuration.nix
# and imports it, so a freshly installed system is branded and themed as MiKuOS
# instead of stock NixOS.  `./mikuos` (next to this file) holds the artwork and
# helper files shipped with the installer, and `./release.nix` (also next to
# this file) holds the version and codename.
{ config, pkgs, lib, ... }:

let
  cfg = config;
  assets = ./mikuos; # wallpapers/, plymouth/, miku7-icons.nix, motd.txt, logo.png

  release = import ./release.nix;

  wallpapers = pkgs.runCommand "miku-wallpapers" { src = assets; } ''
    mkdir -p $out/share/backgrounds/miku
    cp $src/wallpapers/*.jpg $out/share/backgrounds/miku/
    ln -sf $out/share/backgrounds/miku/3516132-ultrawide.jpg \
      $out/share/backgrounds/miku/default.jpg
  '';

  # Miku splash screen, built from the theme the installer ships.
  plymouth = pkgs.runCommand "miku-cosmic-plymouth" { src = assets + "/plymouth"; } ''
    runHook preInstall
    themeDir="$out/share/plymouth/themes/miku-cosmic"
    mkdir -p "$themeDir"
    cp "$src"/miku-cosmic.plymouth "$themeDir"/
    substituteInPlace "$themeDir/miku-cosmic.plymouth" \
      --replace-fail "@THEME_DIR@" "$themeDir"
    cp "$src"/*.png "$themeDir"/
    runHook postInstall
  '';

  # App icon set; the derivation is shipped so the installed system builds the
  # same icons the live session shows.
  icons = import ./mikuos/miku7-icons.nix {
    inherit lib pkgs;
    avatar = assets + "/wallpapers/miku-avatar.png";
  };

  hero = "${wallpapers}/share/backgrounds/miku/3516132-ultrawide.jpg";

  # ── COSMIC desktop config files ───────────────────────────
  # Formats mirror what cosmic-bg 1.2 reads, and match the live session:
  #   * `backgrounds` is a list of enum variants, i.e. `[All]` (not strings)
  #   * `all` uses `source: Path(...)` for a single image
  bg = pkgs.writeText "cosmic-bg-all.ron" ''
    (
        output: "all",
        source: Path("${hero}"),
        filter_by_theme: true,
        rotation_frequency: 3600,
        filter_method: Lanczos,
        scaling_mode: Zoom,
        sampling_method: Alphanumeric,
    )
  '';
  bgSame = pkgs.writeText "cosmic-bg-same-on-all" "true";
  bgList = pkgs.writeText "cosmic-bg-backgrounds" "[All]";
  accent = pkgs.writeText "miku-accent.ron" ''
    Some((
        red: 0.2235,
        green: 0.7725,
        blue: 0.7333,
    ))
  '';
  favorites = pkgs.writeText "miku-favorites" ''
    [
        "com.system76.CosmicFiles",
        "com.system76.CosmicTerm",
        "com.system76.CosmicSettings",
        "com.system76.CosmicStore",
        "com.system76.CosmicEdit",
        "firefox",
    ]
  '';
  radii = pkgs.writeText "miku-corner-radii.ron" ''
    (
        radius_0: (0.0, 0.0, 0.0, 0.0),
        radius_xs: (6.0, 6.0, 6.0, 6.0),
        radius_s: (12.0, 12.0, 12.0, 12.0),
        radius_m: (20.0, 20.0, 20.0, 20.0),
        radius_l: (40.0, 40.0, 40.0, 40.0),
        radius_xl: (160.0, 160.0, 160.0, 160.0),
    )
  '';
  gtk3 = pkgs.writeText "gtk3-settings.ini" ''
    [Settings]
    gtk-application-prefer-dark-theme=true
    gtk-icon-theme-name=miku7
    gtk-theme-name=adw-gtk3-dark
    gtk-font-name=Rounded Mgen+ 1c, 10
    gtk-cursor-theme-size=24
  '';
  gtk4 = pkgs.writeText "gtk4-settings.ini" ''
    [Settings]
    gtk-application-prefer-dark-theme=true
    gtk-icon-theme-name=miku7
    gtk-theme-name=adw-gtk3-dark
  '';

  # Per-user COSMIC config.  The installer lets you pick the account name, so
  # these are `systemd.user.tmpfiles` rules: they run in every user session and
  # resolve %h at that point.  `C` copies only when the destination is missing,
  # so these act as defaults the user can override from COSMIC Settings.
  cosmicDir = ".config/cosmic";
  cosmicUserRules =
    [ "d %h/${cosmicDir} 0755 - - -" ]
    ++ lib.concatMap (s: [ "d %h/${cosmicDir}/${s} 0755 - - -" "d %h/${cosmicDir}/${s}/v1 0755 - - -" ])
      [
        "com.system76.CosmicAppList"
        "com.system76.CosmicBackground"
        "com.system76.CosmicTheme.Dark"
        "com.system76.CosmicTheme.Dark.Builder"
        "com.system76.CosmicTheme.Light.Builder"
        # .w rules do not create parents, so CosmicTheme.Mode needs its own.
        "com.system76.CosmicTheme.Mode"
      ]
    ++ lib.map (entry:
      let parts = lib.splitString ":" entry;
      in "C %h/${cosmicDir}/${lib.head parts} 0644 - - - ${lib.last parts}")
      [
        "com.system76.CosmicAppList/v1/favorites:${favorites}"
        "com.system76.CosmicBackground/v1/all:${bg}"
        "com.system76.CosmicBackground/v1/same-on-all:${bgSame}"
        "com.system76.CosmicBackground/v1/backgrounds:${bgList}"
        "com.system76.CosmicTheme.Dark/v1/accent:${accent}"
        "com.system76.CosmicTheme.Dark/v1/corner_radii:${radii}"
        "com.system76.CosmicTheme.Dark.Builder/v1/accent:${accent}"
        "com.system76.CosmicTheme.Light.Builder/v1/accent:${accent}"
      ]
    ++ [ "w %h/${cosmicDir}/com.system76.CosmicTheme.Mode/v1/is_dark 0644 - - - true" ]
    # GTK apps follow COSMIC's look; there is no NixOS option for this, so
    # the per-user ini files are provisioned the same way.
    ++ [ "d %h/.config/gtk-3.0 0755 - - -" "d %h/.config/gtk-4.0 0755 - - -" ]
    ++ lib.map (entry:
      let parts = lib.splitString ":" entry;
      in "C %h/.config/${lib.head parts} 0644 - - - ${lib.last parts}")
      [ "gtk-3.0/settings.ini:${gtk3}" "gtk-4.0/settings.ini:${gtk4}" ];

  # ── COSMIC greeter (login screen) config ──────────────────
  # The greeter runs as its own fixed user, so system tmpfiles are enough.
  greeterHome = "/var/lib/cosmic-greeter/.config/cosmic";
  greeterDir = p: "${greeterHome}/${p}";
  greeterOwned = { user = "cosmic-greeter"; group = "cosmic-greeter"; };
  # The tmpfiles option keys are a single "path.type" string, which cannot be
  # written as a parenthesised attribute name, so build them with setAttr.
  greeterDirRule = p: lib.setAttrByPath [ (greeterDir p) "d" ]
    (greeterOwned // { mode = "0755"; });
  greeterCopy = p: arg: lib.setAttrByPath [ (greeterDir p) "C" ]
    (greeterOwned // { mode = "0644"; argument = arg; });
  greeterWrite = p: arg: lib.setAttrByPath [ (greeterDir p) "w" ]
    (greeterOwned // { mode = "0644"; argument = arg; });
in
{
  # ── Identity ──────────────────────────────────────────────
  system.nixos.distroName = "MiKuOS";
  system.nixos.distroId = "mikuos";
  system.nixos.vendorName = "MiKuOS";
  system.nixos.variantName = "MiKuOS Desktop ${release.version} \"${release.codeName}\"";
  system.nixos.variant_id = "desktop";
  system.nixos.extraOSReleaseArgs = {
    HOME_URL = "https://mikuos.local/";
    SUPPORT_URL = "https://mikuos.local/support";
    DOCUMENTATION_URL = "https://mikuos.local/manual";
    BUG_REPORT_URL = "https://github.com/MiKuOS-main/MiKuOS/issues";
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

  # ── Miku Plymouth splash ─────────────────────────────────
  boot.plymouth.enable = true;
  boot.plymouth.theme = "miku-cosmic";
  boot.plymouth.themePackages = [ plymouth ];

  # ── COSMIC theming for every user session ────────────────
  systemd.user.tmpfiles.rules = cosmicUserRules;

  # ── Miku themed greeter ──────────────────────────────────
  systemd.tmpfiles.settings."cosmic-greeter-miku" =
    lib.foldl' (a: kv: a // kv) { } [
      (greeterDirRule "com.system76.CosmicBackground")
      (greeterDirRule "com.system76.CosmicBackground/v1")
      (greeterCopy "com.system76.CosmicBackground/v1/all" "${bg}")
      (greeterCopy "com.system76.CosmicBackground/v1/same-on-all" "${bgSame}")
      (greeterCopy "com.system76.CosmicBackground/v1/backgrounds" "${bgList}")
      (greeterDirRule "com.system76.CosmicTheme.Dark.Builder")
      (greeterDirRule "com.system76.CosmicTheme.Dark.Builder/v1")
      (greeterCopy "com.system76.CosmicTheme.Dark.Builder/v1/accent" "${accent}")
      (greeterDirRule "com.system76.CosmicTheme.Mode")
      (greeterDirRule "com.system76.CosmicTheme.Mode/v1")
      (greeterWrite "com.system76.CosmicTheme.Mode/v1/is_dark" "true")
    ];

  # ── A usable default toolset ──────────────────────────────
  environment.systemPackages = with pkgs; [
    wallpapers
    icons
    papirus-icon-theme
    adw-gtk3
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

  # ── Miku login banner ────────────────────────────────────
  environment.etc.motd.source = assets + "/motd.txt";
  environment.etc.motd.mode = "0644";

  i18n.supportedLocales = [ "all" ];

  # Must track the nixpkgs base release, not the MiKuOS version.
  system.stateVersion = lib.mkDefault release.nixosBaseRelease;
}
