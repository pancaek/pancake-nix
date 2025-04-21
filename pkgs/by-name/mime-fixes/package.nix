{
  lib,
  stdenvNoCC,
  shared-mime-info,
}:

stdenvNoCC.mkDerivation {
  pname = "mime-fixes";
  version = "7.0";

  src = ./src;

  nativeBuildInputs = [ shared-mime-info ];

  installPhase = ''
    runHook preInstall
    install -Dm444 *.xml -t $out/share/mime/packages
    update-mime-database $out/share/mime
    runHook postInstall
  '';

  meta = {
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ pancaek ];
    platforms = lib.platforms.linux;
  };
}
