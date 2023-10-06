{
  pkgs,

}: pkgs.nix-direnv.override {
  enableFlakes = true;
}
