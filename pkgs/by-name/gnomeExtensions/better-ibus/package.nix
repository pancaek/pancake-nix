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
    rev = "fd54ed12d6e67a38dab7c581a54187548104bc93";
    hash = "sha256-dA7S4bJXi610+1Tsr/vaXYPsjjYhvW7uVpI8BPoFaPA=";
  };

  nativeBuildInputs = [ glib ];

  # buildInputs = [ xprop ];

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
