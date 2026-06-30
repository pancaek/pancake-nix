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
        --replace-fail '"48"' '"48","49","50"'
    '';
  });

  gnome-font-viewer = prev.gnome-font-viewer.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace data/gnome-font-viewer.thumbnailer \
        --replace-fail "font/woff;" "font/woff;font/woff2;"        
      substituteInPlace data/org.gnome.font-viewer.desktop.in.in \
        --replace-fail "font/woff;" "font/woff;font/woff2;"
    '';
  });

  nautilus = prev.nautilus.overrideAttrs (old: {
    # NOTE: https://github.com/NixOS/nixpkgs/issues/195936#issuecomment-1366902737
    # AND: https://github.com/NixOS/nixpkgs/issues/195936#issuecomment-1366902737

    buildInputs = (
      old.buildInputs or [ ]
      ++ (with prev.gst_all_1; [
        gst-plugins-good
        gst-plugins-bad
        gst-plugins-ugly
        gst-libav
      ])
    );
  });
  # r2modman = prev.r2modman.overrideAttrs (old: {
  #   # Hide update banner
  #   preBuild = ''
  #     substituteInPlace src/pages/Manager.vue \
  #       --replace-fail "<div class='notification is-warning' v-if=\"portableUpdateAvailable\">" \
  #          "<div style='display: none;'>"
  #   '';

  # });
}
