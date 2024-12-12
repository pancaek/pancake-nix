{
  lib,
  stdenv,
  fetchFromGitHub,
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
    hash = "sha256-XR/p3QCs2imlk+YeyIBJ9gO0LSjwU0scmxZJQESUnec=";
    sparseCheckout = [
      "WDL/swell/**"
      "WDL/lice/**"
    ];
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

  patches = [ ./fix-xdg-open.diff ];

  meta = with lib; {
    description = "WDL (by Cockos) mirror";
    homepage = "https://github.com/justinfrankel/WDL";
    license = licenses.unfree; # FIXME: figure out the actual license
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
