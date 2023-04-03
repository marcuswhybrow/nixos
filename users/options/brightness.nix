{ config, pkgs, lib, types, ... }: let
  cfg = config.programs.brightness;
in {
  options.programs.brightness = {
    enable = lib.mkEnableOption "Whether to enable `light` and custom `brightness` cli helper";
    step = lib.mkOption { type = types.int; default = 5; };
    onChange = lib.mkOption {
      type = with types; functionTo str;
      description = "Bash to execute whenever brightness changes. Variables available: $brightness";
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      light
      (writeShellScriptBin "brightness" ''
        case `light -G` in
          0.00) step=1;;
          1.00) step=${toString (cfg.step - 1)};;
          *) step=${toString cfg.step};;
        esac

        brightness=`light -G`

        case $1 in
          up)
            light -A $step
            ${cfg.onChange { brightness = "$brightness"; }}
            ;;
          down)
            light -U $step
            ${cfg.onChange { brightness = "$brightness"; }}
            ;;
          *)
            light -G
            ;;
        esac
      '')
    ];

  };
}
