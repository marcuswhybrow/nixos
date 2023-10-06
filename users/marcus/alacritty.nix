{
  pkgs,
  padding ? 20,
}: pkgs.callPackage ../../pkgs/alacritty.nix {
  inherit padding;
  opacity = 0.95;
}
