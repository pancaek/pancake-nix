{ prev }:

(prev.lib.packagesFromDirectoryRecursive {
  directory = ./by-name;
  inherit (prev.pkgs) callPackage;
})
// {

  praat = prev.praat.overrideAttrs (old: {
    version = "6.4.35";

    src = prev.fetchFromGitHub {
      owner = "praat";
      repo = "praat";
      tag = "v6.4.35";
      hash = "sha256-x3S7UxaAe+s85APBh3KHvPhbATpws6hL9N04GzIIWtI=";
    };

    configurePhase =
      builtins.replaceStrings [ "makefile.defs.linux.pulse" ] [ "makefile.defs.linux.pulse-gcc" ]
        old.configurePhase;
  });
  r2modman =
    let
      version = "3.2.2";
      src = prev.fetchFromGitHub {
        owner = "ebkr";
        repo = "r2modmanPlus";
        rev = "v${version}";
        hash = "sha256-EEKf95+pwgRrZTjqKXGGWDdY6yH93bJOjZcSiC5I0IQ=";
      };
    in
    prev.r2modman.overrideAttrs {
      inherit version src;
      offlineCache = prev.fetchYarnDeps {
        yarnLock = "${src}/yarn.lock";
        hash = "sha256-HLVHxjyymi0diurVamETrfwYM2mkUrIOHhbYCrqGkeg=";
      };
    };
  wrapApp =
    {
      pkg,
      flags ? "",
      binName ? null,
    }:
    let
      exe = if binName == null then prev.lib.getExe pkg else prev.lib.getExe' pkg binName;
    in
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
      '';
}
