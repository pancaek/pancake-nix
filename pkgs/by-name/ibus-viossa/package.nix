{
  stdenvNoCC,
  ibus,
  ibus-engines,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ibus-viossa";
  version = "7";

  src = ./src;

  buildInputs = [
    ibus
    ibus-engines.table
  ];

  preBuild = ''
    export HOME=$TMPDIR
  '';

  buildPhase = ''
    runHook preBuild
    mkdir -p $out/share/ibus-table/tables
    ibus-table-createdb -n $out/share/ibus-table/tables/viossa-zankaku.db -s viossa-zankaku.txt
    runHook postBuild
  '';

  meta = {
    isIbusEngine = true;
  };
})
