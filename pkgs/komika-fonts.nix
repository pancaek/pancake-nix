{
  stdenvNoCC,
  lib,
  fetchzip,
  variants ? [
    "display"
    "hands"
    "poster"
    "text"
    "title"
    "komikahuna"
    "komikandy"
    "komikazba"
    "komikaze"
    "komikazoom"
  ],
}:

let
  fetchFont =
    {
      url,
      hash,
      curlOptsList ? [ ],
    }:
    fetchzip {
      inherit url hash curlOptsList;
      name = lib.nameFromURL url ".";
      stripRoot = false;
    };
  fontMap = {
    "display" = {
      url = "https://www.1001fonts.com/download/komika-display.zip";
      hash = "sha256-6oNKuaoV+a/cFCKFXRV8gtWqvFtPGtrqg+vt8hQREMI=";
    };
    "hands" = {
      url = "https://www.1001fonts.com/download/komika.zip";
      hash = "sha256-yb5SWQj7BRCLYHL31m25bhCOuo8qAvkRzGH6UIo3Bbs=";
    };
    "poster" = {
      url = "https://www.1001freefonts.com/d/5010/komika-poster.zip";
      hash = "sha256-k1uUfHSh9kymCJrfuPtKHejFeZGl2PxL4C/3hpoPIc4=";
      curlOptsList = [
        "-H"
        "Referer: https://www.1001freefonts.com/komika-poster.font"
      ];
    };
    "text" = {
      url = "https://www.1001fonts.com/download/komika-text.zip";
      hash = "sha256-FdeFGw6MlYVTiYdvbfjSlQYq+UlKZTJ79HAdEEjMPQs=";
    };
    "title" = {
      url = "https://www.1001freefonts.com/d/5011/komika-title.zip";
      hash = "sha256-M/1NgsHjLR/w/ZxWEb5cebqEI1VKgPvtk75bhAPaw20=";
      curlOptsList = [
        "-H"
        "Referer: https://www.1001freefonts.com/komika-title.font"
      ];
    };
    "komikahuna" = {
      url = "https://www.1001fonts.com/download/komikahuna.zip";
      hash = "sha256-gjUeHE13UzNOzJ1GgeUJGK0IgUVOmFoCD6eMtN3f9lk=";
    };
    "komikandy" = {
      url = "https://www.1001fonts.com/download/komikandy.zip";
      hash = "sha256-NqpR+gM2giTHGUBYoJlO8vkzOD0ep7LzAry3nIagjLY=";
    };
    "komikazba" = {
      url = "https://www.1001fonts.com/download/komikazba.zip";
      hash = "sha256-QwlCje7bSDx2fTo1PydiwQ2hIRLZ96bNdijTgTKjvsA=";
    };
    "komikaze" = {
      url = "https://www.1001fonts.com/download/komikaze.zip";
      hash = "sha256-daJRwgkzL5v224KwkaGMK2FqVnfin8+8WvMTvXTkCGE=";
    };
    "komikazoom" = {
      url = "https://www.1001fonts.com/download/komikazoom.zip";
      hash = "sha256-/o2QPPPiQBkNU0XRxJyI0+5CKFEv4FKU3A5ku1zyVX4=";
    };

  };
  knownFonts = lib.attrNames fontMap;
  selectedFonts =
    if (variants == [ ]) then
      lib.warn "No variants selected, installing all instead" knownFonts
    else
      let
        unknown = lib.subtractLists knownFonts variants;
      in
      if (unknown != [ ]) then
        throw "Unknown variant(s): ${lib.concatStringsSep " " unknown}"
      else
        variants;

in
stdenvNoCC.mkDerivation {
  pname = "komika-fonts";
  version = "0-unstable-2024-08-11";
  sourceRoot = ".";

  srcs = map (variant: fetchFont fontMap.${variant}) selectedFonts;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fonts/ttf
    mv **/*.ttf $out/share/fonts/ttf
    runHook postInstall
  '';

}
