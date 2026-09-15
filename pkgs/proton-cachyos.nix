{ lib, stdenv, fetchzip }:

let
  version = "11.0-20260703";
  archVersion = "x86_64_v3";
  fullname = "proton-cachyos-${version}-slr-${archVersion}";
in
stdenv.mkDerivation rec {
  pname = "proton-cachyos";
  inherit version;

  src = fetchzip {
    url = "https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-${version}-slr/${fullname}.tar.xz";
    sha256 = "04f2s67d388dy3fkx7j8fb5ndjcrmz6ar0iarnsf25779fnyi3pi";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  outputs = [ "out" "steamcompattool" ];

  installPhase = ''
    runHook preInstall

    echo "${pname} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > $out

    mkdir -p $steamcompattool
    ln -s $src/* $steamcompattool
    rm $steamcompattool/compatibilitytool.vdf
    cp $src/compatibilitytool.vdf $steamcompattool

    runHook postInstall
  '';

  preFixup = ''
    substituteInPlace "$steamcompattool/compatibilitytool.vdf" \
      --replace-fail "${fullname}" "Proton-CachyOS"
  '';

  meta = with lib; {
    description = "Compatibility tool for Steam Play based on Wine, patched and built by CachyOS";
    homepage = "https://github.com/CachyOS/proton-cachyos";
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
