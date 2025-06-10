{ prev }:

(prev.lib.packagesFromDirectoryRecursive {
  directory = ./by-name;
  inherit (prev.pkgs) callPackage;
})
// {

  praat = prev.praat.overrideAttrs (old: {
    version = "6.4.14";

    src = prev.pkgs.fetchFromGitHub {
      owner = "praat";
      repo = "praat";
      tag = "v${prev.praat.version}";
      hash = "sha256-AY/OSoCWlWSjtLcve16nL72HidPlJqJgAOvUubMqvj0=";
    };
  });

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
