{ config, lib, pkgs, ... }: let
  inherit (lib) mkIf mkOption types mkDefault;
  inherit (builtins) mapAttrs toString;
  inherit (import ./utils { inherit lib; }) bash options;
  cfg = config.custom.display.brightness;

  step = bash.switch "${pkgs.light}/bin/light -G" {
    "0.00" = 1;
    "1.00" = cfg.step - 1;
  } cfg.step; 
in {
  options.custom.display = {
    brightness = {
      enable = options.mkTrue;
      step = options.mkInt 5;
      up = options.mkStr "${pkgs.light}/bin/light -A ${step}";
      down = options.mkStr "${pkgs.light}/bin/light -U ${step}";
    };
  };

  config = {
    programs.light.enable = mkDefault cfg.enable;

    # For now keybindings are in ./home-manager/sway.nix
    # Once home-manager gets swhkd I'll move them here
  };
}
