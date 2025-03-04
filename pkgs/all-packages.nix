{ prev }:
{
  gnomeExtensions = prev.gnomeExtensions // {
    better-ibus = prev.pkgs.callPackage ./better-ibus/package.nix { };
  };

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
