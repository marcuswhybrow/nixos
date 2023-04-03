{ config, pkgs, lib, ... }: let
  cfg = config.programs.brightness;
in {
  options.programs.brightness = {
    enable = lib.mkEnableOption "Whether to enable `light` and custom `brightness` cli helper";
    step = lib.mkOption { type = lib.types.int; default = 5; };
    onChange = lib.mkOption {
      type = lib.types.str;
      description = "A fish command to execute whever brightness changes. Hint use (light -G) to get the current brightness level";
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      light
      fish
    ];

    # TODO Remove fish dependency
    programs.fish.functions.brightness = ''
      switch (light -G)
        case 0.00
          set step 1
        case 1.00
          set step ${toString (cfg.step - 1)}
        case '*'
          set step ${toString cfg.step}
      end

      switch $argv[1]
        case up
          light -A $step
          ${cfg.onChange}
        case down
          light -U $step
          ${cfg.onChange}
        case '*'
          light -G
      end

    '';
  };
}
