{ lib, stdenvNoCC }:

stdenvNoCC.mkDerivation {
  pname = "miku-cosmic-grub";
  version = "1.0.0";

  src = ../themes/miku/grub;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp "$src"/theme.txt "$out"/
    cp "$src"/background.jpg "$out"/
    cp "$src"/unifont-32.pf2 "$out"/
    cp -r "$src"/icons "$out"/
    cp "$src"/select_*.png "$out"/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Hatsune Miku cosmic GRUB theme";
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}