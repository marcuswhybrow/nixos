# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  stateVersion = "22.11";
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    <home-manager/nixos>
    ./mw-home.nix
    ./mw-bar
  ];

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot/efi";
  };

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices = {
    "luks-5b1a5442-4619-44d8-94e7-3c3a96b97fb3" = {
      device = "/dev/disk/by-uuid/5b1a5442-4619-44d8-94e7-3c3a96b97fb3";
      keyFile = "/crypto_keyfile.bin";
    };
  };

  networking = {
    hostName = "marcus-starlite";
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Sway starts xserver with Wayland.
  # But unless xserver is enabled the mouse doesn't appear, and I can't exit Sway.
  services.xserver = {
    enable = true;
    autorun = false;
    #displayManager.lightdm.enable = false;
  };

  # Screen Brightness
  # Requires user to be in "video" group
  # See https://nixos.wiki/wiki/Backlight
  programs.light.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = false;
  };

  # Configure console keymap1
  console.keyMap = "uk";

  # Enable Nix Flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    cantarell-fonts   # for waybar
    font-awesome      # for waybar
  ];

  security.sudo.wheelNeedsPassword = false;
  users.users.marcus = {
    isNormalUser = true;
    description = "Marcus Whybrow";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [];
    shell = pkgs.fish;
  };

  mwBar.enable = true;
  mwHome.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = [
    pkgs.neovim
    pkgs.fish
    pkgs.wget
    pkgs.unixtools.ping
    pkgs.pamixer
    pkgs.coreboot-configurator
    pkgs.megasync
    unstable.avizo
    pkgs.wlogout
    pkgs.killall
  ];
  
  programs = {
    neovim.defaultEditor = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = stateVersion; # Did you read the comment?

}
