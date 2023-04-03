[
  ({ config, pkgs, helpers, ... }: {
    environment.systemPackages = with pkgs; [
      vim

      # networking
      wget unixtools.ping
    ];

    time.timeZone = "Europe/London";
    i18n.defaultLocale = "en_GB.UTF-8";
    i18n.extraLocaleSettings = helpers.config.localeForAll config.i18n.defaultLocale;
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

    hardware.opengl.intelAccelerateVideoPlayback.enable = true;
  })

  # danger zone
  {
    system.stateVersion = "22.11";
    nixpkgs.hostPlatform = "x86_64-linux";
    nixpkgs.config.allowUnfree = true;

    boot.initrd.availableKernelModules = [
      "uhci_hcd"
      "ehci_pci"
      "ata_piix"
      "ahci"
      "firewire_ohci"
      "usb_storage"
      "sd_mod"
      "sr_mod"
      "sdhci_pci"
    ];
    boot.initrd.kernelModules = [ "kvm-intel" ];

    fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
    swapDevices = [ { device = "/dev/sda2"; } ];

    boot.loader.grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = true;
    };

    hardware.enableRedistributableFirmware = true;
    hardware.cpu.intel = {
      updateMicrocode = true;
      sgx.provision.enable = true; 
    };

    boot.plymouth.enable = false;
    services.getty.autologinUser = "anne";
  }
]
