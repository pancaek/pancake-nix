{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  zlib,
  git,
  ruby,
  php,
  libxml2,
  catch2_3,
  boost,
  sqlite,
}:

stdenv.mkDerivation rec {
  pname = "reapack";
  version = "1.2.4.6";

  src = fetchFromGitHub {
    owner = "cfillion";
    repo = "reapack";
    rev = "v${version}";
    hash = "sha256-hdx5Ur85uvvjDb5U1XLVnxqnM9Aqb+OpO16a8BJdtRo=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    curl
    zlib
    git
    ruby
    php
    libxml2
    catch2_3
    boost
    sqlite
  ];

  patches = [ ./system-wide-install.patch ];

  # installPhase = ''
  #   runHook preInstall

  #   mkdir -p $out/lib/REAPER/Plugins
  #   cp reaper_reapack-x86_64.so $out/lib/REAPER/Plugins

  #   runHook postInstall
  # '';

  meta = with lib; {
    description = "Package manager for REAPER";
    homepage = "https://github.com/cfillion/reapack";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
