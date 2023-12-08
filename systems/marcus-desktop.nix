{ config, lib, ... }: {

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

  # Audio
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services = {
    printing.enable = true;
    openssh.enable = true;
  };

  environment.sessionVariables = {
    # WLR_NO_HARDWARE_CURSORS = "1"; # can solve hidden cursor issues
    NIXOS_OZONE_WL = "1"; # encourages electron apps to use wayland
  };

  programs.hyprland = {
    enable = true;
    enableNvidiaPatches = true;
    xwayland.enable = true;
  };

  hardware = {
    opengl.enable = true;
  };

  services.xserver = {
    enable = true;
    layout = "gb";
    autorun = true;
    xkbVariant = "";
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    # videoDrivers = [ "amdgpu" ];
  };

  networking = {
    hostName = "marcus-desktop";
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" "repl-flake" ];

  # Proton VPN
  # networking.wg-quick.interfaces.protonvpn = {
  #   autostart = true;
  #   address = [ "10.2.0.2/32" ];
  #   dns = [ "10.2.0.1" ];
  #   privateKeyFile = "/etc/nixos/secrets/protonvpn-marcus-laptop-UK-86";
  #   peers = [
  #     {
  #       endpoint = "146.70.179.50:51820";
  #       publicKey = "zctOjv4DH2gzXtLQy86Tp0vnT+PNpMsxecd2vUX/i0U="; # UK#86
  #       allowedIPs = [ "0.0.0.0/0" "::/0" ]; # forward all ip traffic thru
  #     }
  #   ];
  # };


  # DANGER ZONE
  # -----------

  system.stateVersion = "23.11";
  nixpkgs = {
    hostPlatform = "x86_64-linux";
    config.allowUnfree = true;
  };

  boot = {
    initrd.availableKernelModules = [
      "ahci"
      "xhci_pci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    kernelModules = [ 
      "kvm-amd" "wl" 
      # "amdgpu"
    ];
    extraModulePackages = [ 
      config.boot.kernelPackages.broadcom_sta 
    ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/e0466cb8-19af-45d7-b9bb-948f48d924ac";
      fsType = "ext4";
    };
    "/boot" = { 
      device = "/dev/disk/by-uuid/B13C-CFE9";
      fsType = "vfat";
    };
  };

  swapDevices = [];

  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault true;
    enableRedistributableFirmware = true;
  };
}
