{ lib, pkgs, ... }:

let
  sizes    = [ 16 22 24 32 48 64 128 256 ];
  sizeStr  = s: "${toString s}x${toString s}";
  avatar   = /etc/nixos/themes/miku/wallpapers/miku-avatar.png;
  launcher = "com.system76.CosmicLauncher";
  appColors = [
    { name = "com.system76.CosmicFiles";     color = "#39C5BB"; }
    { name = "kitty";                        color = "#39C5BB"; }
    { name = "com.system76.CosmicTerm";      color = "#5B8DFF"; }
    { name = "steam";                        color = "#5B8DFF"; }
    { name = "vlc";                          color = "#5B8DFF"; }
    { name = "com.system76.CosmicSettings";  color = "#C58AFF"; }
    { name = "com.system76.CosmicEdit";      color = "#C58AFF"; }
    { name = "vesktop";                      color = "#C58AFF"; }
    { name = "com.system76.CosmicStore";     color = "#FF7D9C"; }
    { name = "firefox";                      color = "#FF7D9C"; }
    { name = "com.system76.CosmicPlayer";    color = "#FF7D9C"; }
    { name = "org.prismlauncher.PrismLauncher"; color = "#39C5BB"; }
    { name = "chromium";                         color = "#FF7D9C"; }
    { name = "com.system76.CosmicReader";        color = "#39C5BB"; }
    { name = "com.system76.CosmicScreenshot";    color = "#C58AFF"; }
    { name = "com.mattjakeman.ExtensionManager"; color = "#C58AFF"; }
    { name = "enteauth";                         color = "#C58AFF"; }
    { name = "nvidia-settings";                  color = "#C58AFF"; }
    { name = "proton-pass";                      color = "#5B8DFF"; }
    { name = "proton-vpn-logo";                  color = "#5B8DFF"; }
    { name = "rpi-imager";                       color = "#39C5BB"; }
    { name = "usbimager";                        color = "#FF7D9C"; }
    { name = "io.gitlab.adhami3310.Impression";  color = "#39C5BB"; }
  ];
  indexTheme = ''
    [Icon Theme]
    Name=miku7
    Comment=Miku app icon set over Papirus-Dark
    Inherits=Papirus-Dark
    Directories=${lib.concatMapStringsSep "," sizeStr sizes}

    ${lib.concatMapStrings (s: ''
      [${sizeStr s}]
      Size=${toString s}
      Context=Apps
      Type=Fixed

    '') sizes}
  '';
  indexFile = pkgs.writeText "miku7-index.theme" indexTheme;
in
pkgs.runCommand "miku7-icons" {
  nativeBuildInputs = [ pkgs.imagemagick ];
  src = avatar;
} ''
  for s in ${lib.concatStringsSep " " (map toString sizes)}; do
    d="''${s}x''${s}"
    pad=$(( s * 13 / 100 ))
    inner=$(( s - 2 * pad ))
    id="''${inner}x''${inner}"
    r=$(( s * 25 / 100 ))
    mkdir -p "$out/share/icons/miku7/''${d}/apps" \
             "$out/share/icons/hicolor/''${d}/apps"

    magick -size "''${d}" xc:#39C5BB \
      \( "$src" -auto-orient -thumbnail "''${id}^" -gravity center -extent "''${id}" \) \
      -gravity center -composite \
      \( +clone -alpha extract -fill black -colorize 100 \
         -fill white -draw "roundrectangle 0,0,$(( s - 1 )),$(( s - 1 )),''${r},''${r}" \) \
      -alpha off -compose CopyOpacity -composite \
      "$out/share/icons/miku7/''${d}/apps/${launcher}.png"
    cp "$out/share/icons/miku7/''${d}/apps/${launcher}.png" \
       "$out/share/icons/hicolor/''${d}/apps/${launcher}.png"

    ${lib.concatMapStrings (a: ''
      magick -size "''${d}" xc:${a.color} \
        \( "$src" -auto-orient -thumbnail "''${id}^" -gravity center -extent "''${id}" \) \
        -gravity center -composite \
        \( +clone -alpha extract -fill black -colorize 100 \
           -fill white -draw "roundrectangle 0,0,$(( s - 1 )),$(( s - 1 )),''${r},''${r}" \) \
        -alpha off -compose CopyOpacity -composite \
        "$out/share/icons/miku7/''${d}/apps/${a.name}.png"
    '') appColors}
  done
  mkdir -p "$out/share/icons/miku7"
  cp "${indexFile}" "$out/share/icons/miku7/index.theme"
''