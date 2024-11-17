{ stdenvNoCC, lib }:

stdenvNoCC.mkDerivation {
  pname = "my-terminfo";
  version = "0-unstable-2024-11-22";

  src = ./xterm-256color.terminfo;

  installPhase = ''
    mkdir -p $out/share/terminfo
    cp $src $out/share/terminfo
  '';
  dontUnpack = true;
  meta = with lib; {
    description = "custom terminfo";
    license = licenses.free;
    platforms = platforms.all;
  };
}
