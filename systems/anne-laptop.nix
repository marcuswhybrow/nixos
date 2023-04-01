[
  ({ config, pkgs, helpers, ... }: {
    environment.systempackages = with pkgs; [
      vim

      # networking
      wget unixtools.ping
    ];

    custom = {
      hardware.videoacceleration.intel.enable = true;
      users = [ anne marcus ];
    };

    time.timezone = "europe/london";
    i18n.defaultlocale = "en_gb.utf-8";
    i18n.extralocalesettings = helpers.config.localeForAll config.i18n.defaultlocale;
    console.keymap = "uk";

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
  })

  # danger zone
  {
    system.stateversion = "22.11";
    nixpkgs.hostplatform = "x86_64-linux";
    nixpkgs.allowunfree = true;

    boot.initrd.availablekernelmodules = [
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
    boot.initrd.kernelmodules = [ "kvm-intel" ];
    boot.kernelmodules = [];
    boot.extramodulepackages = [];

    filesystems."/" = { device = "/dev/sda1"; fstype = "ext4"; };
    swapdevices = [ { device = "/dev/sda2"; } ];

    boot.loader.grub = {
      enable = true;
      device = "/dev/sda";
      useosprober = true;
    };

    hardware.enableredistributablefirmware = true;
    hardware.cpu.intel = {
      updatemicrocode = mkdefault true;
      sgx.provision.enable = true; 
    };

    boot.plymouth.enable = true;
    services.getty.autologinuser = "anne";
  }
]
