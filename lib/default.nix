{ lib }:
{
  packageInList = name: x: (lib.any (e: lib.getName e == name) x);
}
