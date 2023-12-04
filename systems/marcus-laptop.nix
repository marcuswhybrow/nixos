{ pkgs, config, ... }: {
  environment.systemPackages = with pkgs; [
    vim

    # Networking
    wget unixtools.ping

    # Fast rust tools
    trashy bat eza fd procs sd du-dust tealdeer bandwhich
    ripgrep 
    #ripgrep-all

    # Utils
    coreboot-configurator

    # Mounting Windows Shares
    cifs-utils
    lxqt.lxqt-policykit

    # Image editing
    krita
  ];

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

  services.xserver = {
    enable = true;
    autorun = false;
    layout = "gb";
  };

  programs.fish.enable = true;
  services = {
    openssh.enable = true;
    printing.enable = true;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  security.sudo.wheelNeedsPassword = false;

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
    nvidia.modesetting.enable = true;
    opengl.intelAcceleratedVideoPlayback.enable = true;
  };

  # DANGER ZONE
  # -----------

  system.stateVersion = "22.11";
  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "usb_storage"
    "sd_mod"
    "rtsx_usb_sdmmc"

    # Enables CPU encryption instructions (speeds up LUKS)
    "aesni_intel"
    "cryptd"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  boot.initrd.secrets = { "/crypto_keyfile.bin" = null; };
  boot.initrd.luks.devices.root.device = "/dev/sda2";
  boot.initrd.luks.devices.swap.device = "/dev/sda3";
  boot.initrd.luks.devices.swap.keyFile = "/crypto_keyfile.bin";

  fileSystems."/boot/efi" = { device = "/dev/sda1"; fsType = "vfat"; };
  fileSystems."/" = { device = "/dev/mapper/root"; fsType = "ext4"; };
  swapDevices = [ { device = "/dev/mapper/swap"; } ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.efiSysMountPoint = "/boot/efi";
    efi.canTouchEfiVariables = true;
  };

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel = {
    updateMicrocode = true;
    sgx.provision.enable = true; 
  };
}
