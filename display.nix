{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkIf mkOption types mkDefault;
  cfg = config.custom.display;
  bright = cfg.adjustableBrightness;
  doIncrease = bright.keycode.increase != null;
  doDecrease = bright.keycode.decrease != null;
  doKeyBindings = bright.enable && (doIncrease || doDecrease);
  increaseBinding = if doIncrease then [{
    keys = [ bright.keycode.increase ];
    events = [ "key" ];
    command = "${pkgs.light}/bin/light -A 10";
  }] else [];
  decreaseBinding = if doDecrease then [{
    keys = [ bright.keycode.decrease ];
    events = [ "key" ];
    command = "${pkgs.light}/bin/light -U 10";
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
    programs.light.enable = mkDefault bright.enable;
    services.actkbd = mkIf doKeyBindings {
      enable = true;
      bindings = (increaseBinding ++ decreaseBinding);
    };
  };
}
