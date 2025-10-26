{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "darumadrop";
  version = "unstable-2021-12-07";

  src = fetchFromGitHub {
    owner = "ManiackersDesign";
    repo = "darumadrop";
    rev = "ddbe82834bdab1ecc24adad09cc122d6e8678a81";
    hash = "sha256-Phg0+7+Cs98LB2WWR13A0K83lUdgNCVRT3GB0pCJaho=";
    sparseCheckout = [ "fonts/ttf" ];
  };

  installPhase = ''
    install -D -t $out/share/fonts/ttf fonts/ttf/*.ttf
  '';
  meta = {
    description = "";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
