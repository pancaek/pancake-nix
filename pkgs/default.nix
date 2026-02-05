{ prev }:

let
  system-arch = prev.stdenv.hostPlatform.system;
  nixpkgs-pin = rev: (builtins.getFlake "github:NixOS/nixpkgs/${rev}").legacyPackages.${system-arch};

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
        prev.lib.optional prev.stdenv.hostPlatform.isLinux (old.runtimeDependencies or [ ])
        ++ [ prev.pkgs.xdg-utils ];

      postFixup = prev.lib.optionalString prev.stdenv.hostPlatform.isLinux (old.postFixup or "") + ''
        wrapProgram $out/opt/REAPER/reaper \
          --prefix LD_LIBRARY_PATH : ${prev.lib.makeLibraryPath [ prev.pkgs.openssl ]}
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
