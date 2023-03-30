{ config, lib, pkgs, ... }: let
  inherit (lib) mkIf mkDefault mkOptionDefault;
  inherit (builtins) mapAttrs toString;
  utils = import ../utils { inherit lib; };
  light = "${pkgs.light}/bin/light";
  rg = "${pkgs.ripgrep}/bin/rg";
in {
  options.custom.users = utils.options.mkForEachUser {
    display.brightness = {
      step = utils.options.mkInt 5;
    };
  };

  config = {
    programs.light.enable = true;

    home-manager.users = utils.config.mkForEachUser config (user: {
      home.packages = [ pkgs.ripgrep ];

      wayland.windowManager.sway.config.keybindings = mkOptionDefault (let 
        step = utils.smartStep "${light} -G | ${rg} '(.*)\.' -or '$1'" user.display.brightness.step;
      in {
        XF86MonBrightnessUp = utils.exec "${light} -A ${step}";
        XF86MonBrightnessDown = utils.exec "${light} -U ${step}";
      });
    });
  };
}
