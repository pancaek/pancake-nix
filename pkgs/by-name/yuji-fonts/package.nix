{
  stdenvNoCC,
  lib,
  fetchzip,
}:

stdenvNoCC.mkDerivation (
  finalAttrs:
  let
    v = builtins.replaceStrings [ "." ] [ "_" ] finalAttrs.version;
  in
  {
    pname = "yuji-fonts";
    version = "3.000";

    src = fetchzip {
      url = "https://github.com/Kinutafontfactory/Yuji/releases/download/${finalAttrs.version}/Kinutafontfactory-Yuji-${v}.zip";
      hash = "sha256-eioefQ/P/TrFfFFu2H5V427F/zgcSEix73oDGlrs6SM=";
    };

    installPhase = ''
      runHook preInstall
      install -m444 -Dt $out/share/fonts/opentype *.otf
      runHook postInstall
    '';

    meta = {
      license = lib.licenses.ofl;
      maintainers = with lib.maintainers; [ pancaek ];
      platforms = lib.platforms.all;
    };
  }
)
