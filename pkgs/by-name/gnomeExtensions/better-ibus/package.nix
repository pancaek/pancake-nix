{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-shell-extension-better-ibus";
  version = "1";

  src = fetchFromGitHub {
    owner = "mechtifs";
    repo = "better-ibus";
    rev = "74b68095cabc556292b4459417ade9c80802ef78";
    hash = "sha256-G6V/PXyJ9KsdmZu3s3kEQLk7+8/WFlv/foCCC70gsmQ=";
  };

  nativeBuildInputs = [ glib ];

  buildPhase = ''
    runHook preBuild
    glib-compile-schemas --strict --targetdir="schemas/" "schemas/"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gnome-shell/extensions/better-ibus@mechtifs
    cp -r "." $out/share/gnome-shell/extensions/better-ibus@mechtifs
    runHook postInstall
  '';

  meta = with lib; {
    # description = "Unite is a GNOME Shell extension which makes a few layout tweaks to the top panel and removes window decorations to make it look like Ubuntu Unity Shell";
    license = licenses.gpl3Only;
    # maintainers = with maintainers; [ rhoriguchi ];
    # homepage = "https://github.com/hardpixel/unite-shell";
    # broken = versionOlder gnome-shell.version "3.32";
  };
})
