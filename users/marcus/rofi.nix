{
  pkgs,
  borderColor ? "#1e88eb",

}: pkgs.callPackage ../../pkgs/rofi.nix {
  inherit borderColor;
}
