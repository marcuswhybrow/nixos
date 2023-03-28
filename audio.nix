{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkIf mkOption types mkDefault;
  inherit (builtins) mapAttrs toString;
  inherit (import ./utils { inherit lib; }) bash options;
  cfg = config.custom.audio;

  step = bash.switch "${pkgs.pamixer}/bin/pamixer --get-volume" {
    "0" = 1;
    "1" = cfg.step - 1;
  } cfg.step;
in {
  options.custom.audio = {
    enable = options.mkTrue;
    step = options.mkInt 5;

    # These options define commands called from ./home-manager/sway.nix
    mute = options.mkStr "${pkgs.pamixer}/bin/pamixer --toggle-mute";
    lowerVolume = options.mkStr "${pkgs.pamixer}/bin/pamixer --decrease ${step}";
    raiseVolume = options.mkStr "${pkgs.pamixer}/bin/pamixer --increase ${step}";
    prev = options.mkStr "";
    play = options.mkStr "";
    next = options.mkStr "";
  };
  config = mkIf cfg.enable {
    sound.enable = true;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = false;
    };
    environment.systemPackages = with pkgs; [
      pamixer
    ];

    # If I was using Xserver I'd set keybindings for media keys here.
    # But I'm using Wayland, so my only option is Sway bindings under home-manager.
    # See ./home-manager/sway.nix for the real action.
    # TODO: Author swhkd (Simple Wayland HotKey Daemon) home-manager package.
  };
}

