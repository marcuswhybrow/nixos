{ config, ... }: {

  wsl = {
    enable = true;
    defaultUser = "marcus";
    startMenuLaunchers = true;
    nativeSystemd = true;
    wslConf.network.hostname = "marcus-wsl";
    # useWindowsDriver = true; # Windows OpenGL driver
  };

  # System
  nix.settings.experimental-features = [ "nix-command" "flakes" "repl-flake" ];
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    "LC_ADDRESS" = config.i18n.defaultLocale;
    "LC_IDENTIFICATION" = config.i18n.defaultLocale;
    "LC_MEASUREMENT" = config.i18n.defaultLocale;
    "LC_MONETARY" = config.i18n.defaultLocale;
    "LC_NAME" = config.i18n.defaultLocale;
    "LC_PAPER" = config.i18n.defaultLocale;
    "LC_TELEPHONE" = config.i18n.defaultLocale;
    # "LC_NUMERIC" = config.i18n.defaultLocale;
    # "LC_TIME" = config.i18n.defaultLocale;
  };

  # Console
  console.keyMap = "uk";
  programs.fish.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # SSH
  services.openssh = {
    enable = true;
  };

  # Window Manager
  # hardware.opengl.enable = true;
  # services.xserver = {
  #   enable = true;
  #   autorun = false;
  #   xkb.layout = "gb";
  # };
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  # environment.sessionVariables = {
  #   # WLR_NO_HARDWARE_CURSORS = "1"; # can solve hidden cursor issues
  #   NIXOS_OZONE_WL = "1"; # encourages electron apps to use wayland
  # };


  # DANGER ZONE
  # -----------

  system.stateVersion = "23.11";
  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;
}
