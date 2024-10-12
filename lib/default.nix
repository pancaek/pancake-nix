{ lib }:
{
  packageInList = name: x: (lib.any (e: lib.getName e == name) x);

  overrideAttrsIf =
    condition: f: package:
    (if condition then package.overrideAttrs f else package);

}
