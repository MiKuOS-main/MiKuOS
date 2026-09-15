{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
  pname = "hatsune-miku-grub";
  version = "2025-04-29";

  src = fetchFromGitHub {
    owner = "yorunoken";
    repo = "hatsune-miku-grub";
    rev = "main";
    sha256 = "05c4v6zg4m7h4nhvcvrf1qr6dsakb1zlnwq3fv743wc1jj2w8kns";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -r "$src/4k-HatsuneMiku/." "$out/"

    # Miku text accents (teal menu, pink selection)
    sed -i 's/item_color = "#cccccc"/item_color = "#39C5BB"/' "$out/theme.txt"
    sed -i 's/selected_item_color = "#ffffff"/selected_item_color = "#FF7D9C"/' "$out/theme.txt"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Hatsune Miku GRUB theme (4K)";
    longDescription = ''
      Hatsune Miku GRUB theme from yorunoken/hatsune-miku-grub,
      shipped with the 4K background variant.
    '';
    homepage = "https://github.com/yorunoken/hatsune-miku-grub";
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}