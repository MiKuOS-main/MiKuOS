{ config, pkgs, lib, ... }:

let
  # Python with pywayland for the empty-desktop music watcher
  mikuIdlePython = pkgs.python3.withPackages (ps: [ ps.pywayland ps.cffi ]);
in

{
  home.username = "luca";
  home.homeDirectory = "/home/luca";
  home.stateVersion = "26.05";

  # Miku cursor theme
  home.sessionVariables = {
    XCURSOR_THEME = "Miku-Cursor";
    # Millennium (Steam theming) 32-bit runtime location
    MILLENNIUM_RUNTIME_PATH = "/home/luca/.local/share/millennium/lib/libmillennium_x86.so";
  };
  dconf.settings."org/gnome/desktop/interface" = {
    cursor-theme = "Miku-Cursor";
  };

  home.packages = with pkgs; [
    lsd
    glow
    lazygit
    tmux
    mikuIdlePython
  ];

  # ── Git ─────────────────────────────────────────────────
  programs.git = {
    enable = true;
    settings = {
      safe.directory = "/etc/nixos";
      init.defaultBranch = "main";
      color.ui = true;
      color.branch = {
        current = "cyan bold";
        local = "cyan";
        upstream = "yellow";
      };
      color.diff = {
        meta = "cyan bold";
        frag = "magenta bold";
        old = "red bold";
        new = "green bold";
      };
      color.status = {
        added = "cyan";
        changed = "magenta";
        untracked = "magenta bold";
      };
    };
  };

  # ── Lazygit (Miku Cosmic palette) ──────────────────────
  home.file.".config/lazygit/config.yml".text = ''
    gui:
      theme:
        activeBorderColor: ["#39C5BB", "bold"]
        inactiveBorderColor: ["#39466B"]
        optionsTextColor: ["#C58AFF"]
        selectedLineBgColor: ["#1B2A4D"]
        cherryPickedCommitBgColor: ["#FF7D9C"]
        cherryPickedCommitFgColor: ["#0B1226"]
        unstagedChangesColor: ["#FF7D9C"]
        defaultFgColor: ["#DCEBFF"]
        searchingActiveBorderColor: ["#5B8DFF"]
        selectedRangeBgColor: ["#22304F"]
  '';

  # ── Tmux ────────────────────────────────────────────────
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    extraConfig = ''
      set -ga terminal-overrides ",xterm-256color:Tc"
      set -g mouse on
      set -g history-limit 50000
      set -g base-index 1
      setw -g pane-base-index 1
      set -g renumber-windows on
      set -sg escape-time 0
      set -g focus-events on

      # ── Key Bindings ─────────────────────────────────────
      unbind C-b
      set -g prefix C-Space
      bind C-Space send-prefix

      # Split panes
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # Navigate panes
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Resize panes
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Windows
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5

      # Reload config
      bind r source-file ~/.tmux.conf \; display "Config reloaded!"

      # ── Miku Cosmic Theme ───────────────────────────────
      set -g @catppuccin_flavor 'mocha'

      # Status bar
      set -g status-position bottom
      set -g status-interval 1
      set -g status-justify left

      set -g status-style "bg=#0b1226"

      # Left status
      set -g status-left-length 40
      set -g status-left "#{#[bg=#39c5bb,fg=#0b1226,bold]  #S }#[bg=#0b1226,fg=#39c5bb] "

      # Right status
      set -g status-right-length 60
      set -g status-right "#{#[bg=#0b1226,fg=#56688c]  }#[bg=#22304f,fg=#dcebff] %H:%M #[bg=#1a2440,fg=#dcebff] %d-%b-%y #[bg=#39c5bb,fg=#0b1226,bold] #h "

      # Window status
      setw -g window-status-format "#[bg=#0b1226,fg=#56688c] #I:#W "
      setw -g window-status-current-format "#[bg=#c58aff,fg=#0b1226,bold] #I:#W "
      setw -g window-status-separator ""

      # Pane borders
      set -g pane-border-style "fg=#39466b"
      set -g pane-active-border-style "fg=#39c5bb"

      # Pane number display
      set -g display-panes-active-colour "#39c5bb"
      set -g display-panes-colour "#ff7d9c"

      # Clock mode
      setw -g clock-mode-colour "#5b8dff"

      # Message style
      set -g message-style "bg=#22304f,fg=#dcebff"
      set -g message-command-style "bg=#22304f,fg=#dcebff"

      # Bell
      setw -g window-status-bell-style "bg=#ff7d9c,fg=#0b1226,bold"
    '';
  };

  # ── Kitty ───────────────────────────────────────────────
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12.0;
    };
    settings = {
      # Cursor
      cursor_shape = "beam";
      cursor_blink_interval = "0.5";

      # Scrollback
      scrollback_lines = 10000;

      # Mouse
      copy_on_select = "clipboard";
      mouse_hide_wait = "3.0";

      # Window
      window_padding_width = 8;
      hide_window_decorations = "no";
      background_opacity = "0.85";
      dynamic_background_opacity = "yes";
      remember_window_size = "yes";
      initial_window_width = "120c";
      initial_window_height = "35c";

      # Miku bell SFX
      bell_command = "/etc/nixos/scripts/miku-bell";

      # Tab Bar
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_bar_min_tabs = "1";

      # Bell
      enable_audio_bell = "no";
      visual_bell_duration = "0.0";

      # Miku Cosmic palette
      foreground = "#DCEBFF";
      background = "#0B1226";
      selection_foreground = "#0B1226";
      selection_background = "#39C5BB";

      # Cursor colors
      cursor = "#39C5BB";
      cursor_text_color = "#0B1226";

      # URL underline color when hovering with mouse
      url_color = "#39C5BB";

      # Tab bar colors
      active_tab_foreground = "#0B1226";
      active_tab_background = "#39C5BB";
      inactive_tab_foreground = "#C3D4F2";
      inactive_tab_background = "#171F38";
      tab_bar_background = "#0A1020";

      # Colors for marks
      mark1_foreground = "#0B1226";
      mark1_background = "#5B8DFF";
      mark2_foreground = "#0B1226";
      mark2_background = "#C58AFF";
      mark3_foreground = "#0B1226";
      mark3_background = "#7DF0C8";

      # The 16 terminal colors
      # black
      color0 = "#202640";
      color8 = "#46527A";

      # red
      color1 = "#FF7D9C";
      color9 = "#FF9EB4";

      # green
      color2 = "#7DF0C8";
      color10 = "#9FF7DC";

      # yellow
      color3 = "#FFD866";
      color11 = "#FFE08A";

      # blue
      color4 = "#5B8DFF";
      color12 = "#84ACFF";

      # magenta
      color5 = "#C58AFF";
      color13 = "#D6A8FF";

      # cyan
      color6 = "#39C5BB";
      color14 = "#6FE0D9";

      # white
      color7 = "#C3D4F2";
      color15 = "#E8F1FF";

      # Tab
      active_tab_font_style = "bold";
      inactive_tab_font_style = "normal";
    };
  };

  # ── Starship ────────────────────────────────────────────
  programs.starship = {
    enable = true;
    settings = {
      palette = "catppuccin_mocha";

      palettes = {
        catppuccin_mocha = {
          rosewater = "#ffe4f0";
          flamingo = "#ffd2df";
          pink = "#ffb3d9";
          mauve = "#c58aff";
          red = "#ff7d9c";
          maroon = "#eb7a9c";
          peach = "#ffb37a";
          yellow = "#ffd866";
          green = "#7df0c8";
          teal = "#39c5bb";
          sky = "#6fe0d9";
          sapphire = "#5fd7ff";
          blue = "#5b8dff";
          lavender = "#9db5ff";
          text = "#dcebff";
          subtext1 = "#c3d4f2";
          subtext0 = "#b0c3e6";
          overlay2 = "#93a6cc";
          overlay1 = "#7588ad";
          overlay0 = "#56688c";
          surface2 = "#39466b";
          surface1 = "#22304f";
          surface0 = "#1a2440";
          base = "#0e1630";
          mantle = "#0a1020";
          crust = "#070c18";
        };
      };

      format = ">";

      username = {
        show_always = true;
        style_user = "bg:catppuccin_mocha.blue fg:catppuccin_mocha.base";
        style_root = "bg:catppuccin_mocha.blue fg:catppuccin_mocha.base";
        format = "[$user]($style)";
      };

      directory = {
        style = "bg:catppuccin_mocha.teal fg:catppuccin_mocha.base";
        format = "[ $path]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = "󰝚 ";
          "Pictures" = " ";
          "Developer" = "󰲋 ";
        };
      };

      git_branch = {
        symbol = "";
        style = "bg:catppuccin_mocha.surface0 fg:catppuccin_mocha.pink";
        format = "[[  $symbol $branch]($style)]($styled_prefix)";
      };

      git_status = {
        style = "bg:catppuccin_mocha.green fg:catppuccin_mocha.base";
        format = "[[($all_status$ahead_behind )]($style)]()";
      };

      nodejs = {
        symbol = "";
        style = "bg:catppuccin_mocha.surface1 fg:catppuccin_mocha.green";
        format = "[[  $symbol ($version)]($style)]()";
      };

      rust = {
        symbol = "🦀";
        style = "bg:catppuccin_mocha.surface1 fg:catppuccin_mocha.peach";
        format = "[[  $symbol ($version)]($style)]()";
      };

      python = {
        symbol = " ";
        style = "bg:catppuccin_mocha.surface1 fg:catppuccin_mocha.yellow";
        format = "[[  $symbol ($version)]($style)]()";
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:catppuccin_mocha.surface2 fg:catppuccin_mocha.text";
        format = "[[  $time]($style)]()";
      };
    };
  };

  # ── Zsh ─────────────────────────────────────────────────
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      config = "sudo nixos-rebuild switch";
      update = "sudo nixos-rebuild switch --upgrade";
    };

    initContent = ''
      export PATH="$HOME/.local/bin:/etc/nixos/scripts:$PATH"
      export GLVND_LIB="$(dirname "$(ls -d /nix/store/*-libglvnd-*/lib/libGL.so.1 2>/dev/null | head -1)")"
      [ -n "$GLVND_LIB" ] && export LD_LIBRARY_PATH="$GLVND_LIB''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      fastfetch
    '';
  };

  # ── Bash ────────────────────────────────────────────────
  programs.bash = {
    enable = true;
    shellAliases = {
      ls = "lsd";
      l = "ls -la";
      ll = "ls -l";
      la = "ls -a";
      lt = "ls --tree";
      glow = "glow -p";
      tm = "tmux";
      tma = "tmux attach";
      tmn = "tmux new-session";
      tmd = "tmux detach";
      lg = "lazygit";
      bt = "btop";
    };

    initExtra = ''
      export PATH="$HOME/.local/bin:/etc/nixos/scripts:$PATH"
      export GLVND_LIB="$(dirname "$(ls -d /nix/store/*-libglvnd-*/lib/libGL.so.1 2>/dev/null | head -1)")"
      [ -n "$GLVND_LIB" ] && export LD_LIBRARY_PATH="$GLVND_LIB''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      eval "$(starship init bash)"
      fastfetch
    '';
  };

  # ── Firefox (Miku startpage + new-tab wallpaper) ────────
  home.file.".config/firefox/startpage.html".source = ./themes/miku/firefox/startpage.html;
  home.file.".config/mozilla/firefox/ykf3b0xp.default/wallpaper/miku-wallpaper.jpg".source = ./themes/miku/wallpapers/miku-cosmic-night.jpg;
  home.file.".config/mozilla/firefox/ykf3b0xp.default/user.js".text = ''
    user_pref("browser.startup.homepage", "file:///home/luca/.config/firefox/startpage.html");
    user_pref("browser.startup.page", 1);
    user_pref("browser.newtabpage.activity-stream.newtabWallpapers.enabled", true);
    user_pref("browser.newtabpage.activity-stream.newtabWallpapers.v2.enabled", true);
    user_pref("browser.newtabpage.activity-stream.feeds.wallpaperfeed", true);
    user_pref("browser.newtabpage.activity-stream.newtabWallpapers.customWallpaper.uuid", "miku-wallpaper.jpg");
    user_pref("browser.newtabpage.activity-stream.newtabWallpapers.wallpaper", "custom");
    user_pref("browser.toolbars.bookmarks.visibility", "never");
    user_pref("browser.shell.checkDefaultBrowser", false);
    user_pref("ui.systemUsesDarkTheme", 1);
    user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
    user_pref("browser.tabs.tabMinWidth", 90);
  '';
  home.file.".config/mozilla/firefox/ykf3b0xp.default/user.js".force = true;
  home.file.".config/mozilla/firefox/ykf3b0xp.default/chrome/userChrome.css".source = ./themes/miku/firefox/userChrome.css;
  home.file.".config/mozilla/firefox/ykf3b0xp.default/chrome/userChrome.css".force = true;
  home.file.".config/nvim/init.vim".source = ./themes/miku/nvim/init.vim;
  home.file.".config/nvim/colors/miku.vim".source = ./themes/miku/nvim/colors/miku.vim;
  home.file.".local/share/PrismLauncher/themes/Miku/theme.json".source = ./themes/miku/prism/theme.json;
  home.file.".local/share/PrismLauncher/themes/Miku/themeStyle.css".source = ./themes/miku/prism/themeStyle.css;
  home.file.".local/share/PrismLauncher/themes/Miku/background.png".source = ./themes/miku/prism/background.png;
  home.file.".local/share/sounds/miku-login.wav".source = ./themes/miku/sounds/miku-login.wav;
  home.file.".local/share/sounds/miku-lock.wav".source = ./themes/miku/sounds/miku-lock.wav;
  home.file.".local/share/sounds/miku-launch.wav".source = ./themes/miku/sounds/miku-launch.wav;
  home.file.".local/share/sounds/miku-unlock.wav".source = ./themes/miku/sounds/miku-unlock.wav;
  home.file.".local/share/sounds/miku/bell.wav".source = ./themes/miku/sounds/bell.wav;
  home.file.".local/share/sounds/miku/dialog-information.wav".source = ./themes/miku/sounds/dialog-information.wav;
  home.file.".local/share/sounds/miku/dialog-warning.wav".source = ./themes/miku/sounds/dialog-warning.wav;
  home.file.".local/share/sounds/miku/dialog-error.wav".source = ./themes/miku/sounds/dialog-error.wav;
  home.file.".local/share/sounds/miku/message-new-instant.wav".source = ./themes/miku/sounds/message-new-instant.wav;

  # ── Firefox Miku profile (userChrome accents) ─────────────
  home.file.".mozilla/firefox/profiles.ini".text = ''
    [General]
    StartWithLastProfile=1

    [Profile0]
    Name=Miku
    IsRelative=1
    Path=Miku
    Default=1
  '';
  home.file.".mozilla/firefox/Miku/user.js".text = ''
    user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
  '';
  home.file.".mozilla/firefox/Miku/chrome/userChrome.css".text = ''
    :root{
      --toolbar-bgcolor: #0B1226 !important;
      --toolbar-color: #E8F1FF !important;
      --tab-line-color: #39C5BB !important;
      --tab-selected-bgcolor: #101A33 !important;
    }
    #navigator-toolbox{ border-bottom: 1px solid #1B2A4D !important; }
    #urlbar-background, #searchbar{ background: #101A33 !important; border: 1px solid #1B2A4D !important; }
    #urlbar[focused=true] > #urlbar-background{ background: #0A1120 !important; border: 1px solid #39C5BB !important; }
    .tab-background[selected="true"]{ outline: 1px solid #FF7D9C !important; }
    .toolbarbutton-1:hover{ background-color: rgba(57,197,187,0.12) !important; }
    toolbarbutton#panic-button{ fill: #FF7D9C !important; }
  '';
  home.file.".mozilla/firefox/Miku/chrome/userContent.css".text = ''
    @-moz-document url(about:newtab), url(about:home) {
      body {
        background-image: url("file:///home/luca/Pictures/Wallpapers/Miku/miku-space.jpg") !important;
        background-size: cover !important;
        background-position: center !important;
        background-repeat: no-repeat !important;
        background-attachment: fixed !important;
      }
    }
  '';
  home.file.".local/share/sounds/miku/index.theme".source = ./themes/miku/sounds/index.theme;

  # Point GTK event sounds at the Miku theme (non-destructive patch)
  home.activation.mikuSoundTheme = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    for f in "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"; do
      [ -f "$f" ] || continue
      if grep -q '^gtk-sound-theme-name=' "$f"; then
        sed -i 's/^gtk-sound-theme-name=.*/gtk-sound-theme-name=miku/' "$f"
      else
        printf '\ngtk-sound-theme-name=miku\n' >> "$f"
      fi
      grep -q '^gtk-enable-event-sounds=' "$f" || printf 'gtk-enable-event-sounds=1\n' >> "$f"
      grep -q '^gtk-enable-input-feedback-sounds=' "$f" || printf 'gtk-enable-input-feedback-sounds=1\n' >> "$f"
    done
  '';

  # ── Miku login chime (plays once at desktop start) ──────
  systemd.user.services."miku-login-sound" = {
    Unit = {
      Description = "Play Hatsune Miku login chime";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.pipewire}/bin/pw-play /home/luca/.local/share/sounds/miku-launch.wav";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # ── Miku lock chime (plays when the session locks) ────────
  systemd.user.services."miku-lock-sound" = {
    Unit = {
      Description = "Play Hatsune Miku lock chime on session lock";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "/etc/nixos/scripts/miku-lock-sound";
      Environment = [ "PATH=/run/current-system/sw/bin:/usr/bin:/bin" ];
      Restart = "on-failure";
      RestartSec = "3";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # ── Miku unlock chime (plays when the session unlocks) ───
  systemd.user.services."miku-unlock-sound" = {
    Unit = {
      Description = "Play Hatsune Miku unlock chime on session unlock";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "/etc/nixos/scripts/miku-unlock-sound";
      Environment = [ "PATH=/run/current-system/sw/bin:/usr/bin:/bin" ];
      Restart = "on-failure";
      RestartSec = "3";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # ── Pin default audio output to the HDMI TV ──────────────
  systemd.user.services."miku-default-sink" = {
    Unit = {
      Description = "Set default audio sink to the HDMI output";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.pulseaudio}/bin/pactl set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # ── Miku idle song (plays when no apps are open) ─────────
  systemd.user.services."miku-idle" = {
    Unit = {
      Description = "Play Anamanaguchi - Miku when the desktop has no open windows";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${mikuIdlePython}/bin/python3 /etc/nixos/scripts/miku-idle.py";
      Restart = "on-failure";
      RestartSec = "5";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # ── Miku Wallpapers ─────────────────────────────────────
  home.file."Pictures/Wallpapers/Miku/miku-cosmic-night.jpg".source = ./themes/miku/wallpapers/miku-cosmic-night.jpg;
  home.file."Pictures/Wallpapers/Miku/miku-astronaut.jpg".source = ./themes/miku/wallpapers/miku-astronaut.jpg;
  home.file."Pictures/Wallpapers/Miku/miku-starfield.jpg".source = ./themes/miku/wallpapers/miku-starfield.jpg;
  home.file."Pictures/Wallpapers/Miku/miku-space.jpg".source = ./themes/miku/wallpapers/miku-space.jpg;
  home.file."Pictures/Wallpapers/Miku/miku-sleeping.jpg".source = ./themes/miku/wallpapers/miku-sleeping.jpg;

  # ── COSMIC Desktop Theme (wallpaper + teal accent) ──────
  # Boot-provisioned as real, writable files via systemd.tmpfiles
  # ("cosmic-desktop-miku") so COSMIC can't clobber them. See configuration.nix.

  # ── Papirus icons for COSMIC + GTK ──────────────────────
  home.file.".config/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-application-prefer-dark-theme=true
    gtk-button-images=true
    gtk-cursor-blink=true
    gtk-cursor-blink-time=1000
    gtk-cursor-theme-name=Miku-Cursor
    gtk-cursor-theme-size=24
    gtk-decoration-layout=:minimize,maximize,close
    gtk-enable-animations=true
    gtk-font-name=Rounded Mgen+ 1c,  10
    gtk-icon-theme-name=miku7
    gtk-menu-images=true
    gtk-modules=colorreload-gtk-module
    gtk-primary-button-warps-slider=true
    gtk-sound-theme-name=miku
    gtk-theme-name=adw-gtk3-dark
    gtk-toolbar-style=3
    gtk-xft-dpi=98304
    gtk-enable-event-sounds=1
    gtk-enable-input-feedback-sounds=1
  '';
  home.file.".config/gtk-3.0/settings.ini".force = true;
  home.file.".config/gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-application-prefer-dark-theme=true
    gtk-icon-theme-name=miku7
    gtk-cursor-theme-name=Miku-Cursor
    gtk-cursor-theme-size=24
    gtk-sound-theme-name=miku
    gtk-enable-event-sounds=1
    gtk-enable-input-feedback-sounds=1
  '';
  home.file.".config/gtk-4.0/settings.ini".force = true;

  # ── Rename audio output, keeping per-device distinction ──
  # Distinct descriptions so OpenAL apps (Minecraft) can resolve a real
  # output instead of many identical "Miku's Output" devices.
  home.file.".config/wireplumber/wireplumber.conf.d/50-miku-output.conf".text = ''
    monitor.alsa.rules = [
      {
        matches = [
          {
            node.name = "~alsa_output.pci.*.hdmi-stereo"
          }
        ]
        actions = {
          update-props = {
            node.description = "Miku's Output (HDMI)"
            node.nick = "Miku's Output (HDMI)"
            node.priority.session = 1000000
            node.priority.driver = 1000000
          }
        }
      }
      {
        matches = [
          {
            node.name = "~alsa_output.usb.*HiFi__SPDIF__sink"
          }
        ]
        actions = {
          update-props = {
            node.description = "Miku's Output (SPDIF)"
            node.nick = "Miku's Output (SPDIF)"
          }
        }
      }
      {
        matches = [
          {
            node.name = "~alsa_output.usb.*HiFi__Speaker__sink"
          }
        ]
        actions = {
          update-props = {
            node.description = "Miku's Output (Speakers)"
            node.nick = "Miku's Output (Speakers)"
          }
        }
      }
      {
        matches = [
          {
            node.name = "~alsa_output.usb.*HiFi__Headphones__sink"
          }
        ]
        actions = {
          update-props = {
            node.description = "Miku's Output (Headphones)"
            node.nick = "Miku's Output (Headphones)"
          }
        }
      }
    ]

    monitor.bluez.rules = [
      {
        matches = [
          {
            device.name = "~bluez_card.*"
          }
        ]
        actions = {
          update-props = {
            device.description = "Miku's Output (Bluetooth)"
            device.nick = "Miku's Output (Bluetooth)"
          }
        }
      }
    ]
  '';
  home.file.".config/wireplumber/wireplumber.conf.d/50-miku-output.conf".force = true;

  # ── Miku login avatar + GTK theme for Flatpak / GTK apps ──
  home.file.".face".source = ./themes/miku/wallpapers/miku-avatar.png;
  home.file.".face".force = true;
  home.file.".local/share/themes/adw-gtk3-dark".source =
    "${pkgs.adw-gtk3}/share/themes/adw-gtk3-dark";
  home.file.".local/share/themes/adw-gtk3-dark".force = true;

  # ── Cuter Miku window corners (COSMIC theme) ──────────────
  home.file.".config/cosmic/com.system76.CosmicTheme.Dark/v1/corner_radii".text = ''
    (
        radius_0: (0.0, 0.0, 0.0, 0.0),
        radius_xs: (6.0, 6.0, 6.0, 6.0),
        radius_s: (12.0, 12.0, 12.0, 12.0),
        radius_m: (20.0, 20.0, 20.0, 20.0),
        radius_l: (40.0, 40.0, 40.0, 40.0),
        radius_xl: (160.0, 160.0, 160.0, 160.0),
    )
  '';
  home.file.".config/cosmic/com.system76.CosmicTheme.Dark/v1/corner_radii".force = true;

  # ── Miku cava visualizer ────────────────────────────────
  home.file.".config/cava/config".source = ./themes/miku/cava/config;
  home.file.".local/share/applications/miku-visualizer.desktop".source = ./themes/miku/desktop/miku-visualizer.desktop;

  # ── Btop (Miku Cosmic theme) ────────────────────────────
  home.file.".config/btop/btop.conf".text = ''
    theme_background = False
    theme_name = "miku"
    color_theme = "Default"
    vim_keys = False
    rounded_corners = True
    background_dark = True
  '';
  home.file.".config/btop/btop.conf".force = true;
  home.file.".config/btop/themes/miku.theme".text = ''
    main_bg = "#0b1226"
    main_fg = "#dcebff"
    title = "#39c5bb"
    hi_fg = "#ffe08a"
    selected_bg = "#39c5bb"
    selected_fg = "#0b1226"
    inactive_fg = "#56688c"
    graph_text = "#c3d4f2"
    meter_bg = "#202640"
    proc_misc = "#5b8dff"
    cpu_box = "#39c5bb"
    mem_box = "#5b8dff"
    net_box = "#c58aff"
    proc_box = "#7df0c8"
    div_line = "#22304f"
    temp_start = "#ffe08a"
    temp_mid = "#ff9eb4"
    temp_end = "#ff6e96"
    cpu_start = "#39c5bb"
    cpu_mid = "#6fe0d9"
    cpu_end = "#5b8dff"
    free_start = "#7df0c8"
    free_mid = "#39c5bb"
    free_end = "#5b8dff"
    used_start = "#5b8dff"
    used_mid = "#c58aff"
    used_end = "#ff7d9c"
    download_start = "#7df0c8"
    download_mid = "#39c5bb"
    download_end = "#5b8dff"
    upload_start = "#ffd866"
    upload_mid = "#ff9eb4"
    upload_end = "#ff6e96"
  '';

  # ── Fastfetch ───────────────────────────────────────────
  home.file.".config/fastfetch/miku-logo.png".source = ./themes/miku/fastfetch/miku-logo.png;
  home.file.".config/fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "display": {
        "separator": " : ",
        "color": "blue"
      },
      "logo": {
        "type": "kitty",
        "source": "/home/luca/.config/fastfetch/miku-logo.png",
        "width": 22
      },
      "colors": {
        "color1": "#39C5BB",
        "color2": "#5B8DFF",
        "color3": "#C58AFF",
        "color4": "#7DF0C8",
        "color5": "#FFD866",
        "color6": "#FF7D9C",
        "color7": "#C3D4F2",
        "color8": "#46527A"
      },
      "modules": [
        { "type": "title" },
        { "type": "os", "key": "        OS" },
        { "type": "kernel", "key": "   Kernel" },
        { "type": "uptime", "key": "  Uptime" },
        { "type": "packages", "key": "Packages" },
        { "type": "shell", "key": "    Shell" },
        { "type": "de", "key": "       DE" },
        { "type": "wm", "key": "       WM" },
        { "type": "terminal", "key": "Terminal" },
        { "type": "cpu", "key": "      CPU" },
        { "type": "gpu", "key": "      GPU" },
        { "type": "memory", "key": "  Memory" },
        { "type": "disk", "key": "    Disk" },
        { "type": "break" },
        { "type": "colors" },
        { "type": "break" }
      ]
    }
  '';

  # ── Scripts ─────────────────────────────────────────────
  home.file."scripts/daily-git-push.sh" = {
    source = ./daily-git-push.sh;
    executable = true;
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;
}
