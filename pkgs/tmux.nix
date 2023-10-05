{
  makeWrapper,
  pkgs,

  conf ? "",

}: pkgs.runCommand "tmux" {

  nativeBuildInputs = [ 
    makeWrapper 
  ];

} (
  let
    confFile = pkgs.writeText "tmux.conf" conf;
  in ''
    mkdir --parents $out
    makeWrapper ${pkgs.tmux}/bin/tmux $out/bin/tmux \
      --add-flags "-f ${confFile}"
  ''
)
