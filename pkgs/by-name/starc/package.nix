{
  appimageTools,
  fetchurl,
  lib,
  stdenvNoCC,
  makeWrapper,

}:

let
  pname = "starc";
  version = "0.7.5";

  src = fetchurl {
    url = "https://github.com/story-apps/starc/releases/download/v${version}/starc-setup.AppImage";
    hash = "sha256-KAY04nXVyXnjKJxzh3Pvi50Vs0EPbLk0VgfZuz7MQR0=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };

  finalApp = appimageTools.wrapType2 {
    inherit pname version src;

  };

in
stdenvNoCC.mkDerivation {
  inherit pname version;

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontBuild = true;

  installPhase =
    let
      desktopitem = builtins.readFile "${appimageContents}/starc.desktop";
      newItem = builtins.replaceStrings [ "Icon=starc" ] [ "Icon=dev.storyapps.starc.png" ] (
        desktopitem + "StartupWMClass=Story Architect"
      );
    in
    ''
      runHook preInstall
      mkdir -p $out/share/applications/

      echo "${newItem}" >> $out/share/applications/starc.desktop


      install -m 444 -D ${appimageContents}/share/icons/hicolor/512x512/apps/dev.storyapps.starc.png \
        $out/share/icons/hicolor/512x512/apps/dev.storyapps.starc.png
      install -m 444 -D ${appimageContents}/share/icons/hicolor/1024x1024/apps/dev.storyapps.starc.png \
        $out/share/icons/hicolor/1024x1024/apps/dev.storyapps.starc.png
      install -m 444 -D ${appimageContents}/starc.png \
        $out/share/icons/hicolor/1024x1024/apps/starc.png

      makeWrapper ${finalApp}/bin/starc $out/bin/starc \
        --unset QT_PLUGIN_PATH

      runHook postInstall
    '';
  meta = with lib; {
    description = "Starc AppImage";
    homepage = "https://starc.app/";
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
