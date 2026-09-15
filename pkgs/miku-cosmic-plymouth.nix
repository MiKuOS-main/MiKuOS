{ lib, stdenvNoCC }:

stdenvNoCC.mkDerivation {
  pname = "miku-cosmic-plymouth";
  version = "1.0.0";

  src = ../themes/miku/plymouth;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    themeDir="$out/share/plymouth/themes/miku-cosmic"
    mkdir -p "$themeDir"

    cp "$src"/miku-cosmic.plymouth "$themeDir"/
    substituteInPlace "$themeDir/miku-cosmic.plymouth" \
      --replace-fail "@THEME_DIR@" "$themeDir"

    cp "$src"/background.png "$themeDir"/
    cp "$src"/watermark.png "$themeDir"/
    cp "$src"/box.png "$themeDir"/
    cp "$src"/entry.png "$themeDir"/
    cp "$src"/bullet.png "$themeDir"/
    cp "$src"/lock.png "$themeDir"/
    cp "$src"/keyboard.png "$themeDir"/
    cp "$src"/capslock.png "$themeDir"/
    cp "$src"/animation-*.png "$themeDir"/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Hatsune Miku cosmic Plymouth splash theme";
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}