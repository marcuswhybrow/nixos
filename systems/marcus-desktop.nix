{ pkgs, config, ... }: {

  wsl = {
    enable = true;
    defaultUser = "marcus";
    startMenuLaunchers = true;
    nativeSystemd = true;
    # docker-native.enable = true;
    # docker-desktop.enable = true;
  };

  # Not sure if I need fonts. I think Windows Terminal manages fonts.
  # https://nixos.wiki/wiki/Fonts
  fonts.packages = with pkgs; [
    font-awesome

    (nerdfonts.override {
      fonts = [
        # https://github.com/NixOS/nixpkgs/blob/nixos-22.11/pkgs/data/fonts/nerdfonts/shas.nix
        "FiraCode"
        "FiraMono"
        "Terminus"
      ];
    })
  ];
  fonts.fontconfig.defaultFonts = {
    monospace = [ "FiraCode Nerd Font Mono" ];
  };

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    "LC_ADDRESS" = config.i18n.defaultLocale;
    "LC_IDENTIFICATION" = config.i18n.defaultLocale;
    "LC_MEASUREMENT" = config.i18n.defaultLocale;
    "LC_MONETARY" = config.i18n.defaultLocale;
    "LC_NAME" = config.i18n.defaultLocale;
    "LC_NUMERIC" = config.i18n.defaultLocale;
    "LC_PAPER" = config.i18n.defaultLocale;
    "LC_TELEPHONE" = config.i18n.defaultLocale;
    "LC_TIME" = config.i18n.defaultLocale;
  };

  console.keyMap = "uk";

  programs.fish.enable = true;
  security.sudo.wheelNeedsPassword = false;


  # DANGER ZONE
  # -----------

  system.stateVersion = "22.05";
  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;
}
