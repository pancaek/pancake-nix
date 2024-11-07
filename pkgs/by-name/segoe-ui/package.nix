{
  stdenvNoCC,
  lib,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation {
  pname = "segoe-ui";
  version = "0-unstable-2024-11-04";

  src = fetchurl {
    url = "https://aka.ms/segoeuifont";
    hash = "sha256-g8ZnGi6JHaijAy0uCv+ZqFktMlegbJQ+VWwzIC8oA3Q=";
    curlOptsList = [
      "-L"
      "-H"
      "Accept:application/octet-stream"
    ];
  };

  unpackPhase = ''
    ${unzip}/bin/unzip $src -d .
  '';

  installPhase = ''
    mkdir -p $out/share/fonts/ttf
    mv *.ttf $out/share/fonts/ttf
  '';

  meta = with lib; {
    description = "Segoe UI font package";
    license = licenses.unfree;
    platforms = platforms.all;
  };
}
