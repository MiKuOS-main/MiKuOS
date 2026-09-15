{ config, pkgs, lib, ... }:

let
  cachyos-kernel = import (builtins.fetchTarball {
    url = "https://github.com/xddxdd/nix-cachyos-kernel/archive/879f45ee15a3b06fdbbf9b6dc825c5fbca137fcd.tar.gz";
    sha256 = "0nk95wanrlqknpy2qgdq89iz4b9akk7vkl0j4lb1qkrx7ndm7r4p";
  });

  mikuWallpapers = pkgs.callPackage ./pkgs/miku-wallpapers.nix { };

  mikuBell = pkgs.writeShellScript "miku-bell" ''
    exec pw-play /home/luca/.local/share/sounds/miku/bell.wav
  '';

  greeterBg = pkgs.writeText "cosmic-greeter-all.ron" ''
    (
        filter_by_theme: false,
        filter_method: Lanczos,
        output: "all",
        rotation_frequency: 300,
        sampling_method: Alphanumeric,
        scaling_mode: Zoom,
        source: File("${mikuWallpapers}/share/backgrounds/miku/3516132-ultrawide.jpg"),
    )
  '';
  greeterBgSame = pkgs.writeText "cosmic-greeter-same-on-all" "true";
  greeterBgList = pkgs.writeText "cosmic-greeter-backgrounds" "[ \"all\" ]";
  greeterAccent = pkgs.writeText "cosmic-greeter-accent.ron" ''
    Some((
        red: 0.2235,
        green: 0.7725,
        blue: 0.7333,
    ))
  '';

  mikuAccent = pkgs.writeText "miku-accent.ron" ''
    Some((
        red: 0.2235,
        green: 0.7725,
        blue: 0.7333,
    ))
  '';

  desktopBg = pkgs.writeText "cosmic-desktop-all.ron" ''
    (
        filter_by_theme: false,
        filter_method: Lanczos,
        output: "all",
        rotation_frequency: 600,
        sampling_method: Alphanumeric,
        scaling_mode: Zoom,
        source: Directory("/home/luca/Pictures/Wallpapers/Miku"),
    )
  '';
  desktopBgSame = pkgs.writeText "cosmic-desktop-same-on-all" "true";
  desktopBgList = pkgs.writeText "cosmic-desktop-backgrounds" "[ \"all\" ]";
  desktopDarkAccent = pkgs.writeText "cosmic-desktop-dark-accent.ron" ''
    (
        base: (
            red: 0.2235,
            green: 0.7725,
            blue: 0.7333,
            alpha: 1,
        ),
        hover: (
            red: 0.3373,
            green: 0.8157,
            blue: 0.7765,
            alpha: 1,
        ),
        pressed: (
            red: 0.051,
            green: 0.5412,
            blue: 0.5098,
            alpha: 1,
        ),
        selected: (
            red: 0.2235,
            green: 0.7725,
            blue: 0.7333,
            alpha: 1,
        ),
        selected_text: (
            red: 0.0275,
            green: 0.0745,
            blue: 0.149,
            alpha: 1,
        ),
        focus: (
            red: 0.2941,
            green: 0.7843,
            blue: 0.749,
            alpha: 1,
        ),
        divider: (
            red: 0.4706,
            green: 0.7686,
            blue: 0.7333,
            alpha: 1,
        ),
        on: (
            red: 0.8627,
            green: 0.9216,
            blue: 1.0,
            alpha: 1,
        ),
        disabled: (
            red: 0.4706,
            green: 0.5294,
            blue: 0.6275,
            alpha: 1,
        ),
        on_disabled: (
            red: 0.0588,
            green: 0.0863,
            blue: 0.1255,
            alpha: 1,
        ),
        border: (
            red: 0.2235,
            green: 0.7725,
            blue: 0.7333,
            alpha: 1,
        ),
        disabled_border: (
            red: 0.4706,
            green: 0.5294,
            blue: 0.6275,
            alpha: 1,
        ),
    )
  '';
in

{
  imports = [
    ./hardware-configuration.nix
    <home-manager/nixos>
  ];

  # ── MiKuOS identity ──────────────────────────────────────
  system.nixos.distroName = "MiKuOS";
  system.nixos.distroId = "mikuos";
  system.nixos.variantName = "MiKuOS Desktop";
  system.nixos.variant_id = "desktop";
  system.nixos.extraOSReleaseArgs = {
    HOME_URL = "https://mikuos.local/";
    BUG_REPORT_URL = "https://github.com/mikuos/mikuos/issues";
    DOCUMENTATION_URL = "https://mikuos.local/manual";
    SUPPORT_URL = "https://mikuos.local/support";
    ANSI_COLOR = "0;38;2;57;197;187";
  };

  boot.kernel.sysctl."kernel.yama.ptrace_scope" = 0;

  # ── Hatsune Miku themed GRUB bootloader ──────────────────
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
    theme = pkgs.callPackage ./pkgs/hatsune-miku-grub.nix { };
  };
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.timeout = 8;

  # ── Hatsune Miku cosmic Plymouth splash ──────────────────
  boot.plymouth = {
    enable = true;
    theme = "miku-cosmic";
    themePackages = [ (pkgs.callPackage ./pkgs/miku-cosmic-plymouth.nix { }) ];
  };

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-zen4;

  nix.settings = {
    substituters = lib.mkAfter [ "https://attic.xuyh0120.win/lantian" ];
    trusted-public-keys = lib.mkAfter [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
  };

  networking.hostName = "miku-39";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";

  services.displayManager.cosmic-greeter.enable = true;

  # ── Hatsune Miku themed COSMIC greeter (login screen) ────
  systemd.tmpfiles.settings."cosmic-greeter-miku" = {
    "/var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicBackground".d = {
      user = "cosmic-greeter";
      group = "cosmic-greeter";
      mode = "0755";
    };
    "/var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicBackground/v1".d = {
      user = "cosmic-greeter";
      group = "cosmic-greeter";
      mode = "0755";
    };
    "/var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicBackground/v1/all".C = {
      user = "cosmic-greeter";
      group = "cosmic-greeter";
      mode = "0644";
      argument = "${greeterBg}";
    };
    "/var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicBackground/v1/same-on-all".C = {
      user = "cosmic-greeter";
      group = "cosmic-greeter";
      mode = "0644";
      argument = "${greeterBgSame}";
    };
    "/var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicBackground/v1/backgrounds".C = {
      user = "cosmic-greeter";
      group = "cosmic-greeter";
      mode = "0644";
      argument = "${greeterBgList}";
    };
    "/var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicTheme.Dark.Builder".d = {
      user = "cosmic-greeter";
      group = "cosmic-greeter";
      mode = "0755";
    };
    "/var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicTheme.Dark.Builder/v1".d = {
      user = "cosmic-greeter";
      group = "cosmic-greeter";
      mode = "0755";
    };
    "/var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicTheme.Dark.Builder/v1/accent".C = {
      user = "cosmic-greeter";
      group = "cosmic-greeter";
      mode = "0644";
      argument = "${greeterAccent}";
    };
    "/var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicTheme.Mode".d = {
      user = "cosmic-greeter";
      group = "cosmic-greeter";
      mode = "0755";
    };
    "/var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicTheme.Mode/v1".d = {
      user = "cosmic-greeter";
      group = "cosmic-greeter";
      mode = "0755";
    };
    "/var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark".w = {
      user = "cosmic-greeter";
      group = "cosmic-greeter";
      mode = "0644";
      argument = "true";
    };
  };

  # ── COSMIC login avatar (AccountsService + greeter) ────
  systemd.tmpfiles.settings."cosmic-avatar-miku" = {
    "/var/lib/AccountsService/icons".d = {
      mode = "0755";
    };
    "/var/lib/AccountsService/icons/luca".C = {
      mode = "0644";
      argument = "/etc/nixos/themes/miku/wallpapers/miku-avatar.png";
    };
  };

  # ── Hatsune Miku themed desktop COSMIC (provisioned at boot) ──
  # Real, writable files (re-created every boot) so COSMIC can keep its own
  # runtime state without clobbering read-only home-manager symlinks.
  systemd.tmpfiles.settings."cosmic-desktop-miku" = {
    "/home/luca/.config/cosmic/com.system76.CosmicBackground".d = {
      user = "luca";
      group = "users";
      mode = "0755";
    };
    "/home/luca/.config/cosmic/com.system76.CosmicBackground/v1".d = {
      user = "luca";
      group = "users";
      mode = "0755";
    };
    "/home/luca/.config/cosmic/com.system76.CosmicBackground/v1/all".C = {
      user = "luca";
      group = "users";
      mode = "0644";
      argument = "${desktopBg}";
    };
    "/home/luca/.config/cosmic/com.system76.CosmicBackground/v1/same-on-all".C = {
      user = "luca";
      group = "users";
      mode = "0644";
      argument = "${desktopBgSame}";
    };
    "/home/luca/.config/cosmic/com.system76.CosmicBackground/v1/backgrounds".C = {
      user = "luca";
      group = "users";
      mode = "0644";
      argument = "${desktopBgList}";
    };
    "/home/luca/.config/cosmic/com.system76.CosmicTheme.Dark".d = {
      user = "luca";
      group = "users";
      mode = "0755";
    };
    "/home/luca/.config/cosmic/com.system76.CosmicTheme.Dark/v1".d = {
      user = "luca";
      group = "users";
      mode = "0755";
    };
    "/home/luca/.config/cosmic/com.system76.CosmicTheme.Dark/v1/accent".C = {
      user = "luca";
      group = "users";
      mode = "0644";
      argument = "${desktopDarkAccent}";
    };
    "/home/luca/.config/cosmic/com.system76.CosmicTheme.Dark.Builder".d = {
      user = "luca";
      group = "users";
      mode = "0755";
    };
    "/home/luca/.config/cosmic/com.system76.CosmicTheme.Dark.Builder/v1".d = {
      user = "luca";
      group = "users";
      mode = "0755";
    };
    "/home/luca/.config/cosmic/com.system76.CosmicTheme.Dark.Builder/v1/accent".C = {
      user = "luca";
      group = "users";
      mode = "0644";
      argument = "${mikuAccent}";
    };
    "/home/luca/.config/cosmic/com.system76.CosmicTheme.Light.Builder".d = {
      user = "luca";
      group = "users";
      mode = "0755";
    };
    "/home/luca/.config/cosmic/com.system76.CosmicTheme.Light.Builder/v1".d = {
      user = "luca";
      group = "users";
      mode = "0755";
    };
    "/home/luca/.config/cosmic/com.system76.CosmicTheme.Light.Builder/v1/accent".C = {
      user = "luca";
      group = "users";
      mode = "0644";
      argument = "${mikuAccent}";
    };
    "/home/luca/.config/cosmic/com.system76.CosmicTheme.Mode".d = {
      user = "luca";
      group = "users";
      mode = "0755";
    };
    "/home/luca/.config/cosmic/com.system76.CosmicTheme.Mode/v1".d = {
      user = "luca";
      group = "users";
      mode = "0755";
    };
    "/home/luca/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark".w = {
      user = "luca";
      group = "users";
      mode = "0644";
      argument = "true";
    };
  };

  services.desktopManager.cosmic = {
    enable = true;
    xwayland.enable = true;
  };

  console.keyMap = "uk";

  services.printing.enable = true;

  hardware.bluetooth.enable = true;

  services.pulseaudio.enable = false;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ── NVIDIA GTX 1650 (hybrid graphics, render offload) ────
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      amdgpuBusId = "PCI:12:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # ── Docker with NVIDIA GPU support ───────────────────────
  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = true;

  # ── nix-ld: run prebuilt dynamic binaries (uv, pip wheels) ──
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      portaudio
      config.hardware.nvidia.package.bin
    ];
  };

  users.users.luca = {
    isNormalUser = true;
    description = "luca";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  services.flatpak.enable = true;

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("org.freedesktop.udisks2.") == 0 &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  programs.firefox.enable = true;
  # Give GTK apps an SVG icon loader (librsvg) so Adwaita's
  # image-missing icon can render -- fixes Firefox crashing with
  # "Icon 'image-missing' not present in theme Adwaita"
  # (gtkiconhelper.c:495, missing gdk-pixbuf svg loader).
  programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

  # ── Miku login MOTD (shown on ssh / tty logins) ─────────
  environment.etc."motd" = {
    source = ./themes/miku/motd.txt;
    mode = "0644";
  };

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    extraCompatPackages = [ pkgs.proton-cachyos ];
  };

  nixpkgs.config.allowUnfree = true;

  # Rounded Miku-styled UI font (M+ merged with Noto)
  fonts.packages = with pkgs; [
    rounded-mgenplus
  ];
  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Rounded Mgen+ 1c" ];
    serif = [ "Rounded Mgen+ 1pp" ];
    monospace = [ "Rounded Mgen+ 2m" ];
  };

  nixpkgs.overlays = [
    (final: prev: {
      soundux = final.callPackage ./pkgs/soundux.nix { };
      proton-cachyos = final.callPackage ./pkgs/proton-cachyos.nix { };
    })
    cachyos-kernel.overlays.pinned
  ];

  environment.systemPackages = with pkgs; [
    gh
    (pkgs.callPackage ./pkgs/miku-wallpapers.nix { })
    (pkgs.callPackage ./pkgs/miku7-icons.nix { })
    (pkgs.callPackage ./pkgs/miku-cursors.nix { })
    papirus-icon-theme
    adw-gtk3
    viu
    curl-impersonate
    vlc
    fuse2
    wget
    proton-vpn
    usbimager
    impression
    appimage-run
    ani-cli
    rpi-imager
    opencode
    tailscale
    neovim
    python3
    git
    kitty
    nerd-fonts.jetbrains-mono
    btop
    cmatrix
    pipes-rs
    cava
    starship
    gnome-extension-manager
    fastfetch
    htop
    vesktop
    soundux
    nix-index
    proton-pass
    ente-auth
    jdk
  ] ++ (let
    amazon-music = chromium.override {
      commandLineArgs = "--app=https://music.amazon.com --user-data-dir=/home/luca/.local/share/amazon-music";
    };
  in [
    (writeShellScriptBin "amazon-music" ''
      exec ${amazon-music}/bin/chromium "$@"
    '')
    (makeDesktopItem {
      name = "amazon-music";
      desktopName = "Amazon Music";
      exec = "${amazon-music}/bin/chromium";
      icon = "chromium";
      categories = [ "Audio" "Music" ];
      startupWMClass = "chromium-browser";
    })
  ]);

  # ── Playit tunneling agent (daemon) ──────────────────────
  systemd.services.playit = {
    description = "Playit tunneling agent";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "luca";
      ExecStart = "/home/luca/.local/bin/playit -s";
      Restart = "on-failure";
      RestartSec = "5s";
      Environment = "HOME=/home/luca";
    };
  };

  # ── Scripts in /etc/nixos/scripts ────────────────────────
  environment.etc."nixos/scripts/daily-git-push.sh" = {
    source = ./daily-git-push.sh;
    mode = "0755";
  };

  environment.etc."nixos/scripts/miku-bell" = {
    source = "${mikuBell}";
    mode = "0755";
  };

  environment.etc."nixos/scripts/miku-lock-sound" = {
    source = ./scripts/miku-lock-sound;
    mode = "0755";
  };

  environment.etc."nixos/scripts/miku-unlock-sound" = {
    source = ./scripts/miku-unlock-sound;
    mode = "0755";
  };

  environment.etc."nixos/scripts/miku-visualizer" = {
    source = ./scripts/miku-visualizer;
    mode = "0755";
  };

  environment.etc."nixos/scripts/miku-idle.py" = {
    source = ./scripts/miku-idle.py;
    mode = "0555";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      config = "sudo nixos-rebuild switch";
      update = "sudo nix-channel --update && sudo nixos-rebuild switch";
    };
  };

  # ── Tailscale client (official Tailscale account) ───────
  services.tailscale.enable = true;
  system.stateVersion = "26.05";

  # ── Home Manager ─────────────────────────────────────────
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.luca = import ./home.nix;

  # ── Systemd Timer for Daily Git Push ─────────────────────
  systemd.services."daily-git-push" = {
    description = "Daily git backup push";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/etc/nixos/scripts/daily-git-push.sh";
      User = "luca";
    };
    environment = {
      GIT_BACKUP_REPO = "/home/luca/Projects/NIX";
      GIT_BACKUP_BRANCH = "main";
    };
  };

  systemd.timers."daily-git-push" = {
    description = "Run daily git push at 23:00";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}
