{ config, pkgs, lib, ... }: let
  cfg = config.programs.volume;
in {
  options.programs.volume = {
    enable = lib.mkEnableOption "Whether to enable pamixer and volume cli helper.";
    step = lib.mkOption { type = lib.types.int; default = 5; };
    unmuteOnChange = lib.mkOption { type = lib.types.bool; default = true; };
    onChange = lib.mkOption {
      type = lib.types.str;
      description = "Fish command to be executed when the volume changes. Hint use (pamixer --get-volume).";
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      pamixer
      fish
    ];

    # TODO Remove fish dependency
    programs.fish.functions.volume = ''
      switch (pamixer --get-volume)
        case 0
          set step 1
        case 1
          set step ${toString (cfg.step - 1)}
        case '*'
          set step ${toString cfg.step}
      end

      switch $argv[1]
        case up
          pamixer ${if cfg.unmuteOnChange then "--unmute" else ""} --increase $step
        case down
          pamixer ${if cfg.unmuteOnChange then "--unmute" else ""} --decrease $step
        case toggle-mute
          pamixer --toggle-mute
      end

      ${cfg.onChange}
    '';
  };
}
