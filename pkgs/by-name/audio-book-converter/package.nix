{
  lib,
  fetchFromGitHub,
  maven,
  ffmpeg,
  mp4v2,
  jdk,
  makeWrapper,
  makeDesktopItem,
}:

let
  jdk' = jdk.override { enableJavaFX = true; };
in
maven.buildMavenPackage rec {
  pname = "audio-book-converter-uwu";
  version = "6.5.2";

  src = fetchFromGitHub {
    owner = "yermak";
    repo = "AudioBookConverter";
    rev = "version_${version}";
    hash = "sha256-VFV0jcQwh4gt+EnDoNrE+TKrJdW/qkF9d6kwyO2MQmI=";
  };
  mvnJdk = jdk';
  doCheck = false;
  mvnHash = "sha256-5b22Hy7JckmVo0okw4KCem+uiXgYgJZzoIbHqFCN/gI=";

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [
    ffmpeg
    mp4v2
  ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/audiobookconverter
    install -Dm644 target/audiobookconverter-#{APP_VERSION}#.jar $out/share/audiobookconverter/audiobookconverter-${version}-jar-with-dependencies.jar
    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${jdk'}/bin/java $out/bin/audiobookconverter \
      --add-flags "--module-path \"${jdk'}\lib\"" \
      --add-flags "--add-modules javafx.controls,javafx.fxml,javafx.media,javafx.base,javafx.swing,javafx.graphics" \
      --add-flags "-jar $out/share/audiobookconverter/audiobookconverter-${version}-jar-with-dependencies.jar" \
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "audiobookconverter";
      exec = "audiobookconverter";
      icon = "";
      comment = "";
      desktopName = "Audiobook Converter";
      mimeTypes = [
        "application/java"
        "application/java-vm"
        "application/java-archive"
      ];
    })
  ];

  meta = {
    description = "Improved AudioBookConverter based on freeipodsoftware release (mp3 to m4b converter";
    homepage = "https://github.com/yermak/AudioBookConverter";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "audio-book-converter";
    platforms = lib.platforms.all;
  };
}
