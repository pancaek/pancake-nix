{
  appimageTools,
  fetchurl,
  lib,
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
in
appimageTools.wrapType2 {
  inherit pname version src;

  nativeBuildInputs = [ makeWrapper ];

  extraInstallCommands = ''
    mkdir -p $out/share
    cp -r ${appimageContents}/share/* $out/share/
    install -Dm444 ${appimageContents}/starc.desktop $out/share/applications/starc.desktop
    substituteInPlace $out/share/applications/starc.desktop \
      --replace 'Icon=starc' 'Icon=dev.storyapps.starc'
  '';

  meta = with lib; {
    description = "Starc AppImage";
    homepage = "https://starc.app/";
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
