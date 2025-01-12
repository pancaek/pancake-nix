{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "yuji-fonts";
  version = "3.000";

  src = fetchFromGitHub {
    src = "https://github.com/Kinutafontfactory/Yuji";
    rev = "releases/tag/${finalAttrs.version}";
    hash = "";
  };
  installPhase = ''
    runHook preInstall
    install -m444 -Dt $out/share/fonts/opentype/Kinutafontfactory-Yuji-${
      builtins.replaceStrings [ "." ] [ "_" ] finalAttrs.version
    }/*.otf
    runHook postInstall
  '';

  meta = {
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ pancaek ];
    platforms = lib.platforms.all;
  };
})
