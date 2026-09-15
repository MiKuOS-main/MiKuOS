{ config, lib, pkgs, ... }:

let
  themeDir = "/etc/nixos/themes/miku";

  mikuWallpapers = pkgs.callPackage /etc/nixos/pkgs/miku-wallpapers.nix { };
  mikuGrubTheme = pkgs.callPackage /etc/nixos/pkgs/hatsune-miku-grub.nix { };
  mikuPlymouth = pkgs.callPackage /etc/nixos/pkgs/miku-cosmic-plymouth.nix { };
  calamaresMikuOS = pkgs.callPackage /etc/nixos/pkgs/calamares-mikuos.nix { };
  calamaresAutostart = pkgs.makeAutostartItem {
    name = "calamares";
    package = calamaresMikuOS.calamares;
  };

  # ── Live desktop provisioning (COSMIC) for user "nixos" ──
  desktopBg = pkgs.writeText "cosmic-desktop-all.ron" ''
    (
        filter_by_theme: false,
        filter_method: Lanczos,
        output: "all",
        rotation_frequency: 600,
        sampling_method: Alphanumeric,
        scaling_mode: Zoom,
        source: File("${mikuWallpapers}/share/backgrounds/miku/default.jpg"),
    )
  '';
  desktopBgSame = pkgs.writeText "cosmic-desktop-same-on-all" "true";
  desktopBgList = pkgs.writeText "cosmic-desktop-backgrounds" "[ \"all\" ]";
  mikuAccent = pkgs.writeText "miku-accent.ron" ''
    Some((
        red: 0.2235,
        green: 0.7725,
        blue: 0.7333,
    ))
  '';

  favorites = pkgs.writeText "favorites" ''
    [
        "calamares",
        "firefox",
        "gparted",
        "com.system76.CosmicFiles",
        "com.system76.CosmicEdit",
        "com.system76.CosmicTerm",
        "com.system76.CosmicSettings",
    ]
  '';

  installLauncher = pkgs.writeText "install-mikuos.desktop" ''
    [Desktop Entry]
    Name=Install MiKuOS
    Comment=Install MiKuOS on this computer
    Exec=calamares
    Icon=system-software-install
    Terminal=false
    Categories=System;
    Type=Application
  '';

  homeDir = "/home/nixos";

in
{
  imports = [
    <nixos/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix>
  ];

  # ── MiKuOS identity (flows into os-release, GRUB, syslinux) ──
  system.nixos.distroName = "MiKuOS";
  system.nixos.distroId = "mikuos";
  system.nixos.vendorName = "MiKuOS";
  system.nixos.variantName = "MiKuOS Live";
  system.nixos.variant_id = "live";
  system.nixos.extraOSReleaseArgs = {
    HOME_URL = "https://mikuos.local/";
    BUG_REPORT_URL = "https://github.com/mikuos/mikuos/issues";
    DOCUMENTATION_URL = "https://mikuos.local/manual";
    SUPPORT_URL = "https://mikuos.local/support";
    ANSI_COLOR = "0;38;2;57;197;187";
  };

  # ── ISO image metadata ──────────────────────────────────
  isoImage.edition = "mikuos";
  isoImage.configurationName = "MiKuOS COSMIC Live";
  isoImage.volumeID = "MIKUOS";
  isoImage.grubTheme = mikuGrubTheme;
  isoImage.compressImage = true;
  image.baseName = lib.mkForce
    "mikuos-${config.system.nixos.release}-${pkgs.stdenv.hostPlatform.system}";
  image.fileName = lib.mkForce "${config.image.baseName}.iso";

  # Miku-styled SYSLINUX (BIOS) boot menu
  isoImage.syslinuxTheme = ''
    MENU TITLE ${config.system.nixos.distroName}
    MENU RESOLUTION 800 600
    MENU COLOR screen       37;40      #800b1226 #00000000 std
    MENU COLOR border       30;44      #8039c5bb #00000000 std
    MENU COLOR title        1;36;44    #ff39c5bb #00000000 std
    MENU COLOR unsel        37;44      #ffc3d4f2 #00000000 std
    MENU COLOR sel          7;37;40    #800b1226 #ff39c5bb all
    MENU COLOR timeout_msg  37;40      #ff8ffdff #00000000 std
    MENU COLOR timeout      1;37;40    #ff5b8dff #00000000 std
  '';

  # ── Miku Plymouth splash ────────────────────────────────
  boot.plymouth.enable = true;
  boot.plymouth.theme = "miku-cosmic";
  boot.plymouth.themePackages = [ mikuPlymouth ];

  # ── COSMIC desktop (live) ───────────────────────────────
  services.desktopManager.cosmic.enable = true;
  services.xserver.videoDrivers = [ "modesetting" ];

  # ── Live user + autologin ───────────────────────────────
  users.users.nixos = {
    isNormalUser = true;
    description = "MiKuOS Live User";
    extraGroups = [ "wheel" ];
    hashedPassword = "";
  };

  services.displayManager.cosmic-greeter.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "nixos";

  # ── Miku desktop provisioning for the live session ──────
  systemd.tmpfiles.settings."mikuos-live-desktop" = {
    "${homeDir}/Desktop".d = {
      user = "nixos";
      group = "users";
      mode = "0755";
    };
    "${homeDir}/Desktop/install-mikuos.desktop".C = {
      user = "nixos";
      group = "users";
      mode = "0644";
      argument = "${installLauncher}";
    };
    "${homeDir}/Desktop/calamares.desktop".C = {
      user = "nixos";
      group = "users";
      mode = "0644";
      argument = "${calamaresMikuOS.calamares}/share/applications/calamares.desktop";
    };
    "${homeDir}/Desktop/firefox.desktop".C = {
      user = "nixos";
      group = "users";
      mode = "0644";
      argument = "${pkgs.firefox}/share/applications/firefox.desktop";
    };
    "${homeDir}/Desktop/gparted.desktop".C = {
      user = "nixos";
      group = "users";
      mode = "0644";
      argument = "${pkgs.gparted}/share/applications/gparted.desktop";
    };
    "${homeDir}/.config".d = {
      user = "nixos";
      group = "users";
      mode = "0755";
    };
    "${homeDir}/.config/cosmic".d = {
      user = "nixos";
      group = "users";
      mode = "0755";
    };
    "${homeDir}/.config/cosmic/com.system76.CosmicBackground/v1/all".C = {
      user = "nixos";
      group = "users";
      mode = "0644";
      argument = "${desktopBg}";
    };
    "${homeDir}/.config/cosmic/com.system76.CosmicBackground/v1/same-on-all".C = {
      user = "nixos";
      group = "users";
      mode = "0644";
      argument = "${desktopBgSame}";
    };
    "${homeDir}/.config/cosmic/com.system76.CosmicBackground/v1/backgrounds".C = {
      user = "nixos";
      group = "users";
      mode = "0644";
      argument = "${desktopBgList}";
    };
    "${homeDir}/.config/cosmic/com.system76.CosmicAppList/v1/favorites".C = {
      user = "nixos";
      group = "users";
      mode = "0644";
      argument = "${favorites}";
    };
    "${homeDir}/.config/cosmic/com.system76.CosmicTheme.Dark/v1/accent".C = {
      user = "nixos";
      group = "users";
      mode = "0644";
      argument = "${mikuAccent}";
    };
    "${homeDir}/.config/cosmic/com.system76.CosmicTheme.Dark.Builder/v1/accent".C = {
      user = "nixos";
      group = "users";
      mode = "0644";
      argument = "${mikuAccent}";
    };
    "${homeDir}/.config/cosmic/com.system76.CosmicTheme.Light.Builder/v1/accent".C = {
      user = "nixos";
      group = "users";
      mode = "0644";
      argument = "${mikuAccent}";
    };
    "${homeDir}/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark".w = {
      user = "nixos";
      group = "users";
      mode = "0644";
      argument = "true";
    };
  };

  # ── Miku login MOTD ─────────────────────────────────────
  environment.etc.motd.source = "${themeDir}/motd.txt";
  environment.etc.motd.mode = "0644";

  # ── Locale / layout / timezone ──────────────────────────
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";
  time.timeZone = "Europe/London";

  # ── Fonts (Miku rounded UI font) ────────────────────────
  fonts.packages = with pkgs; [
    rounded-mgenplus
  ];
  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Rounded Mgen+ 1c" ];
    serif = [ "Rounded Mgen+ 1pp" ];
    monospace = [ "Rounded Mgen+ 2m" ];
  };

  # ── Live toolset (a real distro live media) ─────────────
  environment.pathsToLink = [ "/share/calamares" ];
  environment.defaultPackages = with pkgs; [
    calamaresMikuOS.calamares
    calamaresMikuOS.extensions
    calamaresAutostart
    glibcLocales
    kitty
    btop
    htop
    fastfetch
    cmatrix
    ncdu
    bat
    ripgrep
    neovim
    tree
    hw-probe
    git
    gparted
    vim
    nano
    firefox
    mesa-demos
  ];

  environment.systemPackages = with pkgs; [
    mikuWallpapers
    pcmanfm
    networkmanagerapplet
  ];

  services.dbus.enable = true;
  services.udisks2.enable = true;
  services.openssh.enable = true;

  # Required for the Calamares partition module (kpmcore).
  programs.partition-manager.enable = true;

  # Allow choosing any locale during install.
  i18n.supportedLocales = [ "all" ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
}