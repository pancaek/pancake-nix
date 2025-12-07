{ prev }:

let
  system-arch = prev.stdenv.hostPlatform.system;
in
(prev.lib.packagesFromDirectoryRecursive {
  directory = ./by-name;
  inherit (prev.pkgs) callPackage;
})
// {

  wrapApp =
    {
      pkg,
      flags ? "",
      binName ? null,
    }:
    let
      exe = if binName == null then prev.lib.getExe pkg else prev.lib.getExe' pkg binName;
    in
    if flags != "" then
      prev.runCommand (baseNameOf exe)
        {
          buildInputs = [ prev.makeWrapper ];
        }
        ''
          mkdir $out
          # Link every top-level folder from the app to our new target
          ln -s ${pkg}/* $out
          # Except the bin folder
          rm $out/bin
          mkdir $out/bin
          # We create the bin folder ourselves and link every binary in it
          ln -s ${pkg}/bin/* $out/bin
          # Except the main binary
          rm $out/bin/$(basename ${exe})
          # Because we create this ourself, by creating a wrapper
          makeWrapper ${exe} $out/bin/$(basename ${exe}) \
            ${flags}
        ''
    else
      pkg;

  gnomeExtensions.better-ibus = prev.gnomeExtensions.better-ibus.overrideAttrs (old: {

    preInstall = ''
      substituteInPlace metadata.json \
        --replace-fail "\"48\"" "\"48\",\"49\""
    '';
  });

  r2modman = prev.r2modman.overrideAttrs (old: {
    # Hide update banner
    preBuild = ''
      substituteInPlace src/pages/Manager.vue \
        --replace-fail "<div class='notification is-warning' v-if=\"portableUpdateAvailable\">" \
           "<div style='display: none;'>"
    '';

  });

  reaper = prev.reaper.overrideAttrs (
    old:
    let
      url_for_platform =
        version: arch:
        if prev.pkgs.stdenv.hostPlatform.isDarwin then
          "https://www.reaper.fm/files/${prev.lib.versions.major version}.x/reaper${
            builtins.replaceStrings [ "." ] [ "" ] version
          }_universal.dmg"
        else
          "https://www.reaper.fm/files/${prev.lib.versions.major version}.x/reaper${
            builtins.replaceStrings [ "." ] [ "" ] version
          }_linux_${arch}.tar.xz";
    in
    rec {
      version = "7.55";
      runtimeDependencies =
        (old.runtimeDependencies or [ ])
        ++ prev.lib.optionals prev.stdenv.hostPlatform.isLinux [ prev.pkgs.openssl ];

      installPhase =
        if prev.pkgs.stdenv.hostPlatform.isDarwin then
          old.installPhase
        else
          ''
            runHook preInstall

            HOME="$out/share" XDG_DATA_HOME="$out/share" ./install-reaper.sh \
              --install $out/opt \
              --integrate-user-desktop
            rm $out/opt/REAPER/uninstall-reaper.sh

            # Dynamic loading of plugin dependencies does not adhere to rpath of
            # reaper executable that gets modified with runtimeDependencies.
            # Patching each plugin with DT_NEEDED is cumbersome and requires
            # hardcoding of API versions of each dependency.
            # Setting the rpath of the plugin shared object files does not
            # seem to have an effect for some plugins.
            # We opt for wrapping the executable with LD_LIBRARY_PATH prefix.
            # Note that libcurl and libxml2 are needed for ReaPack to run.
            wrapProgram $out/opt/REAPER/reaper \
              --prefix LD_LIBRARY_PATH : "${
                prev.lib.makeLibraryPath (
                  with prev.pkgs;
                  [
                    curl
                    lame
                    libxml2
                    ffmpeg
                    vlc
                    xdotool
                    stdenv.cc.cc
                    openssl
                  ]
                )
              }"

            mkdir $out/bin
            ln -s $out/opt/REAPER/reaper $out/bin/

            # Avoid store path in Exec, since we already link to $out/bin
            substituteInPlace $out/share/applications/cockos-reaper.desktop \
              --replace-fail "Exec=\"$out/opt/REAPER/reaper\"" "Exec=reaper"

            runHook postInstall
          '';

      src = prev.fetchurl {
        url = url_for_platform version prev.stdenv.hostPlatform.qemuArch;
        hash = "sha256-BOjS39GySB6ptiEJvwlShL4ZcDot2nsKXCAU/CeMEIc=";
      };
    }
  );

  reaper-reapack-extension =
    let
      version = "1.2.6";
    in
    prev.reaper-reapack-extension.overrideAttrs {
      inherit version;
      src = prev.fetchFromGitHub {
        owner = "cfillion";
        repo = "reapack";
        tag = "v${version}";
        hash = "sha256-M1EUBksCCcGD6zRT0Kr32t+inyKMieGR/y+KGxt/qrc=";
        fetchSubmodules = true;
      };
    };
}
