{ lib, stdenvNoCC }:

stdenvNoCC.mkDerivation {
  pname = "miku-wallpapers";
  version = "1.0.0";

  src = ../themes/miku/wallpapers;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/backgrounds/miku"
    cp "$src"/*.jpg "$out/share/backgrounds/miku/"
    ln -sf "$out/share/backgrounds/miku/miku-cosmic-night.jpg" \
      "$out/share/backgrounds/miku/default.jpg"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Hatsune Miku cosmic wallpaper collection";
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}