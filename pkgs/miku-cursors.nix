{ lib, fetchzip, runCommand, ... }:

let
  src = fetchzip {
    url = "https://github.com/supermariofps/hatsune-miku-windows-linux-cursors/archive/refs/heads/master.tar.gz";
    sha256 = "1w9i0h9kfsixspbs52m518spx9p7ymv8i3d5kkizhbhndkhfh88w";
  };
in
runCommand "miku-cursors" { } ''
  mkdir -p "$out/share/icons/Miku-Cursor"
  cp -a "${src}/miku-cursor-linux/cursors" "$out/share/icons/Miku-Cursor/"
  cp "${src}/miku-cursor-linux/index.theme" "$out/share/icons/Miku-Cursor/index.theme"
  chmod -R u+w "$out/share/icons/Miku-Cursor"
  sed -i 's/^Name=Miku Cursor/Name=Miku-Cursor/' "$out/share/icons/Miku-Cursor/index.theme"
  printf 'Comment=Hatsune Miku cursor theme\n' >> "$out/share/icons/Miku-Cursor/index.theme"
''