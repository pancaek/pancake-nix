{
  spotify,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  xorg,
  zip,
  unzip,
  lib,
}:
let
  spotify-adblock =
    let
      version = "1.0.3";
    in
    rustPlatform.buildRustPackage {
      pname = "spotify-adblock";
      inherit version;
      src = fetchFromGitHub {
        owner = "abba23";
        repo = "spotify-adblock";
        tag = "v${version}";
        hash = "sha256-UzpHAHpQx2MlmBNKm2turjeVmgp5zXKWm3nZbEo0mYE=";
      };
      cargoHash = "sha256-wPV+ZY34OMbBrjmhvwjljbwmcUiPdWNHFU3ac7aVbIQ=";

      patchPhase = ''
        substituteInPlace src/lib.rs \
          --replace 'config.toml' $out/etc/spotify-adblock/config.toml
      '';

      buildPhase = ''
        make
      '';

      installPhase = ''
        install -Dm644 config.toml $out/etc/spotify-adblock
        install -Dsm644 target/release/libspotifyadblock.so -t $out/lib
      '';

    };

  spotifywm = stdenv.mkDerivation {
    name = "spotifywm";
    src = fetchFromGitHub {
      owner = "dasj";
      repo = "spotifywm";
      rev = "8624f539549973c124ed18753881045968881745";
      hash = "sha256-AsXqcoqUXUFxTG+G+31lm45gjP6qGohEnUSUtKypew0=";
    };
    buildInputs = [ xorg.libX11 ];
    installPhase = "install -Dm644 spotifywm.so -t $out/lib";
  };
in
spotify.overrideAttrs (old: {
  buildInputs = (old.buildInputs or [ ]) ++ [
    zip
    unzip
  ];
  postInstall =
    let
      ld = lib.concatStringsSep " " [
        "${spotify-adblock}/lib/libspotifyadblock.so"
        "${spotifywm}/lib/spotifywm.so"
      ];
    in
    (old.postInstall or "")
    + ''
      ln -s ${spotify-adblock}/lib/libspotifyadblock.so $libdir
      sed -i "s:^Name=Spotify.*:Name=Spotify-adblock:" "$out/share/spotify/spotify.desktop"
      wrapProgram $out/bin/spotify \
        --set LD_PRELOAD "${ld}"
      # Hide placeholder for advert banner
      ${lib.getExe unzip} -p $out/share/spotify/Apps/xpui.spa xpui.js | sed 's/adsEnabled:\!0/adsEnabled:false/' > $out/share/spotify/Apps/xpui.js
      ${lib.getExe zip} --junk-paths --update $out/share/spotify/Apps/xpui.spa $out/share/spotify/Apps/xpui.js
      rm $out/share/spotify/Apps/xpui.js
    '';
})
