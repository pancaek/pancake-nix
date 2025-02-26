{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  php,
  perl,
  git,
  pkg-config,
  gtk3,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "reaper-sws-extension";
  version = "2.14.0.3";

  src = fetchFromGitHub {
    owner = "reaper-oss";
    repo = "sws";
    tag = "v${finalAttrs.version}";
    hash = "sha256-n4L/5eCKoiQmUNfYxhtgxgflINS9yxr3MUPrrt4YYdY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    php
    perl
    git
    pkg-config
  ];
  buildInputs = [
    gtk3
  ];

  strictDeps = true;
  meta = with lib; {
    description = "A Reaper Plugin Extension";
    longDescription = ''
      The SWS / S&M extension is a collection of features that seamlessly integrate into REAPER, the Digital Audio Workstation (DAW) software by Cockos, Inc.
      It is a collaborative and open source project.
    '';
    homepage = "https://www.sws-extension.org/";
    maintainers = with maintainers; [ mrtnvgr ];
    license = licenses.mit;
    platforms = platforms.all;
  };
})
