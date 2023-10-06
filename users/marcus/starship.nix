{
  pkgs,

}: pkgs.callPackage ../../pkgs/starship.nix {
  init = ''
    [[nix_shell]]
    heuristic = true
  '';
}
