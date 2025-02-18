{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  catch2_3,
  cmake,
  curl,
  libxml2,
  php,
  sqlite,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "reapack";
  version = "1.2.5";

  src = fetchFromGitHub {
    owner = "cfillion";
    repo = "reapack";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RhXAjTNAJegeCJaYkvwJedZrXRA92dQ0EeHJr9ngeCg=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    boost
    catch2_3
    curl
    libxml2
    php
    sqlite
    zlib
  ];

  meta = {
    description = "Package manager for REAPER";
    homepage = "https://github.com/cfillion/reapack";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ pancaek ];
    platforms = lib.platforms.all;
  };
})
