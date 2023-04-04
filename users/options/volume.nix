{ config, pkgs, lib, types, ... }: let
  cfg = config.programs.volume;
in {
  options.programs.volume = {
    enable = lib.mkEnableOption "Whether to enable pamixer and volume cli helper.";
    step = lib.mkOption { type = lib.types.int; default = 5; };
    unmuteOnChange = lib.mkOption { type = lib.types.bool; default = true; };
    onChange = lib.mkOption {
      type = with types; functionTo lines;
      description = "Multiline bash to be executed when the volume changes. Args: { volume, isMuted }";
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      pamixer
      (pkgs.writeShellScriptBin "volume" (let
        muteArgs = if cfg.unmuteOnChange then "--unmute" else "";
      in ''
        case `pamixer --get-volume` in
          0) step=1;;
          1) step=${toString (cfg.step - 1)};;
          *) step=${toString cfg.step};;
        esac

        case $1 in
          up)          pamixer ${muteArgs} --increase $step;;
          down)        pamixer ${muteArgs} --decrease $step;;
          toggle-mute) pamixer --toggle-mute;;
        esac

        volume=$(pamixer --get-volume)
        isMuted=$(pamixer --get-mute)

        ${cfg.onChange { volume = "$volume"; isMuted = "$isMuted"; }}
      ''))
    ];
  };
}
