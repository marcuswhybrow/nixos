{
  pkgs,
  makeWrapper,

  overrideConfig ? "",
}: pkgs.runCommand "git" {
  nativeBuildInputs = [ makeWrapper ];
} ''
  mkdir -p $out 
  ln -s ${pkgs.git}/* $out

  rm $out/bin
  mkdir $out/bin
  ln -s ${pkgs.git}/bin/* $out/bin

  rm $out/bin/git
  makeWrapper ${pkgs.git}/bin/git $out/bin/git \
    --set XDG_CONFIG_HOME ${pkgs.writeTextDir "git/config" overrideConfig}
''
