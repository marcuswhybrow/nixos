{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkIf mkOption types mkDefault;
  cfg = config.custom.display;
  bright = cfg.adjustableBrightness;
  increaseBinding = if (bright.keycode.increase != null) then [{
    keys = [ bright.keycode.increase ];
    events = [ "key" ];
    command = "${pkgs.light}/bin/light -A 10";
  }] else [];
  decreaseBinding = if (bright.keycode.decrease != null) then [{
    keys = [ bright.keycode.decrease ];
    events = [ "key" ];
    command = "${pkgs.light}/bin/light -A 10";
  }] else [];

in {
  options.custom.display = {
    adjustableBrightness = {
      enable = mkEnableOption "Enable adjustable screen brightness";
      keycode.increase = mkOption { type = with types; nullOr int; default = null; };
      keycode.decrease = mkOption { type = with types; nullOr int; default = null; };
    };
  };

  config = {
    programs.light.enable = mkIf bright.enable true;
    services.actkbd = {
      enable = mkDefault (bright.keycode.increase != null || bright.keycode.decrease != null);
      bindings = increaseBinding ++ decreaseBinding;
    };
  };
}
