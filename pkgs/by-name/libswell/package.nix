{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  pkg-config,
  gtk3,
}:

stdenv.mkDerivation {
  pname = "libswell";
  version = "unstable-2024-09-13";

  src = fetchFromGitHub {
    owner = "justinfrankel";
    repo = "WDL";
    rev = "12c86f9061c0c517bb768c2593eb36670f34eb4d";
    hash = "sha256-om2bwIgFgo3F8QCeSL2W5ykThA9AAYq/3/kZPRII45Q=";
  };
  buildInputs = [
    pkg-config
    gtk3
  ];

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

  patches = [ ./libswell-patch.diff ];

  meta = with lib; {
    description = "WDL (by Cockos) mirror";
    homepage = "https://github.com/justinfrankel/WDL";
    license = licenses.unfree; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
