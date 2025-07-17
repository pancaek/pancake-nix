{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  cairo,
  fontconfig,
  gdk-pixbuf,
  glib,
  gtk3,
  libuuid,
  pango,
  xorg,
  zlib,
}:

stdenv.mkDerivation {
  pname = "fadein";
  version = "unstable-2025-06-12";

  src = fetchzip {
    url = "https://www.fadeinpro.com/download/demo/fadein-linux-amd64-demo.tar.gz";
    hash = "sha256-H86Wk70rcky65ZVNmid2E2MUjoDDBVRSZfAcxvBOHRM=";
  };

  strictDeps = true;

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    cairo
    fontconfig
    gdk-pixbuf
    glib
    gtk3
    libuuid
    pango
    stdenv.cc.cc.lib
    xorg.libSM
    xorg.libX11
    xorg.libXxf86vm
    zlib
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share
    cp -r usr/share/* $out/share

    # Fix icon
    install -m 444 -D usr/share/fadein/icon_app/fadein_icon_256x256.png $out/share/icons/hicolor/256x256/apps/fadein.png
    substituteInPlace $out/share/applications/fadein.desktop \
      --replace-fail 'Icon=/usr/share/fadein/icon_app/fadein_icon_256x256.png' 'Icon=fadein'

    mkdir -p $out/bin
    ln -s "$out/share/fadein/fadein" "$out/bin/fadein"
    runHook postInstall
  '';

  meta = {
    description = "A complete application for writing motion picture screenplays.";
    homepage = "https://www.fadeinpro.com/r";
    license = lib.licenses.unfree; # FIXME
    maintainers = with lib.maintainers; [ pancaek ];
    platforms = lib.platforms.linux;
  };
}
