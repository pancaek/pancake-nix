{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  gtk3,
}:

stdenv.mkDerivation {
  pname = "libswell-reaper";
  version = "0-unstable-2025-11-09";

  src = fetchFromGitHub {
    owner = "justinfrankel";
    repo = "WDL";
    rev = "0fb861b5385a6beb1add987183ef2c03221f5992";
    hash = "sha256-0QN4QHpvIbTGi1ukdlNRwkjcsvGx0eHDuEedL4p8bBg=";
    sparseCheckout = [
      "WDL/swell"
      "WDL/lice"
    ];
  };

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ gtk3 ];

  buildFlags = [ "PRELOAD_GDK=1" ];

  preBuild = ''
    cd WDL/swell
  '';

  installPhase = ''
    runHook preInstall
    install -D libSwell.so -t $out/lib
    runHook postInstall
  '';

  patches = [ ./fix-xdg-open.diff ];

  meta = {
    description = "Simple Windows Emulation Layer (patched for reaper)";
    homepage = "https://www.cockos.com/wdl/";
    license = lib.licenses.free; # See homepage for details
    maintainers = with lib.maintainers; [ pancaek ];
    platforms = lib.platforms.all;
  };
}
