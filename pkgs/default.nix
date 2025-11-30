{ prev }:

let
  system-arch = prev.stdenv.hostPlatform.system;
  electron-pin =
    (builtins.getFlake "github:NixOS/nixpkgs/9cb344e96d5b6918e94e1bca2d9f3ea1e9615545")
    .legacyPackages.${system-arch};
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
}
