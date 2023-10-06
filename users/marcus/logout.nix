{
  pkgs,

}: pkgs.callPackage ../../pkgs/logout.nix {
  rofi = pkgs.marcus.rofi;
}
