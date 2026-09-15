{ lib, stdenv, fetchFromGitHub, cmake, ninja, pkg-config, makeWrapper, wrapGAppsHook3,
  libappindicator-gtk3, openssl, pipewire, pulseaudio, webkitgtk_4_1,
  libx11, libxtst,
  libpulseaudio, libwnck, sysprof,
  ffmpeg, yt-dlp
}:

let
  downloaderPath = lib.makeBinPath [ ffmpeg yt-dlp ];
  dynamicLibraries = lib.makeLibraryPath [ libpulseaudio pipewire libwnck ];
in
stdenv.mkDerivation rec {
  pname = "soundux";
  version = "0.2.7";

  src = fetchFromGitHub {
    owner = "Soundux";
    repo = "Soundux";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-aSCsg6nJt6F+6O7UeXnvYva0vllTfsxK/cjaeOhObZY=";
  };

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    "-DCMAKE_C_FLAGS=-Wno-error"
    "-DCMAKE_CXX_FLAGS=-Wno-error"
  ];

  dontWrapGApps = true;

  postPatch = ''
    sed -i '1i #include <cstdint>' lib/guardpp/guard/include/core/linux/guard.hpp
    sed -i '/#include "pipewire.hpp"/a #include <algorithm>' src/helper/audio/linux/pipewire/pipewire.cpp
  '';

  preConfigure = ''
    substituteInPlace src/ui/impl/webview/lib/webviewpp/CMakeLists.txt \
      --replace-fail 'webkit2gtk-4.0' 'webkit2gtk-4.1' \
      --replace-fail '-Werror' '-Wno-error'
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/opt $out/bin
    cp -r dist soundux-${version} $out/opt
    runHook postInstall
  '';

  postFixup = ''
    makeWrapper $out/opt/soundux-${version} $out/bin/soundux \
      --prefix LD_LIBRARY_PATH ":" ${dynamicLibraries} \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH ":" ${downloaderPath}
  '';

  nativeBuildInputs = [ cmake ninja pkg-config makeWrapper wrapGAppsHook3 ];

  buildInputs = [
    libappindicator-gtk3
    openssl
    pipewire
    pulseaudio
    webkitgtk_4_1
    libx11
    libxtst
    libwnck
    sysprof
  ];

  meta = with lib; {
    homepage = "https://soundux.rocks/";
    description = "A universal soundboard that uses PulseAudio modules or PipeWire linking";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
