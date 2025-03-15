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
}
