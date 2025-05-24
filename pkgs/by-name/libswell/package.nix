{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  gtk3,
}:

stdenv.mkDerivation {
  pname = "libswell";
  version = "unstable-2024-05-09";

  src = fetchFromGitHub {
    owner = "justinfrankel";
    repo = "WDL";
    rev = "6df563d45ecf0b2b04dce867e5cfd222b162e9fe";
    hash = "sha256-oXbIdHH5HY48kFlOlLmSw7ltC4paA86deFpkt7G2hKA=";
    sparseCheckout = [
      "WDL/swell/**"
      "WDL/lice/**"
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
    mkdir -p $out/lib
    cp libSwell.so $out/lib/libSwell.so
    runHook postInstall
  '';

  patches = [ ./fix-xdg-open.diff ];

  meta = {
    description = "WDL (by Cockos) mirror";
    homepage = "https://github.com/justinfrankel/WDL";
    license = lib.licenses.unfree; # FIXME: figure out the actual license
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
