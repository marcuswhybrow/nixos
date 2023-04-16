{
  makeWrapper,
  pkgs,
  lib,
  symlinkJoin,

  init ? "", # config arg exist so used init instead
}: pkgs.runCommand "starship" {
  nativeBuildInputs = [ makeWrapper ];
} (let
  config = pkgs.writeText "starship.toml" init;
in ''
  mkdir -p $out

  ln -s ${pkgs.starship}/* $out

  rm $out/bin
  mkdir $out/bin
  ln -s ${pkgs.starship}/bin/* $out/bin

  rm $out/bin/starship
  makeWrapper ${pkgs.starship}/bin/starship $out/bin/starship \
    --set STARSHIP_CONFIG ${config}
'')
