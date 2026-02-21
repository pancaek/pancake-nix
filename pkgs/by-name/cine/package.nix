{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  meson,
  ninja,
  wrapGAppsHook4,
  appstream,
  blueprint-compiler,
  desktop-file-utils,
  gettext,
  glib,
  gtk4,
  libadwaita,
  libGL,
  pkg-config,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cine";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "diegopvlk";
    repo = "Cine";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aw+M1wCGSbRRmKKcgyM4luEr0WtPLw/v7SqBE1B5H9U=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    meson
    ninja
    cmake
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gettext
    blueprint-compiler
    desktop-file-utils
    glib
    gtk4
    libadwaita
    appstream
    (python3.withPackages (
      ps: with ps; [
        pygobject3
        mpv
      ]
    ))
  ];

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
    )

    wrapProgram $out/bin/cine \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libGL ]} \
      ''${makeWrapperArgs[@]}
  '';

  meta = {
    description = "Video Player for Linux";
    homepage = "https://github.com/diegopvlk/Cine";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ pancaek ];
    mainProgram = "cine";
    platforms = lib.platforms.linux;
  };
})
