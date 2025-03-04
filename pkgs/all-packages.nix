{ prev }:
{
  gnomeExtensions = prev.gnomeExtensions // {
    better-ibus = prev.pkgs.callPackage ./better-ibus/package.nix { };
  };

}
