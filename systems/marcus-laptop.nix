[

  # Packages 

  ({ pkgs, ... }: {
    # nixpkgs.config.permittedInsecurePackages = [
    #   "electron-25.9.0"
    # ];
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

      lxqt.lxqt-policykit

      # Image editing
      krita
    ];
  })

  # System Config

  ({ config, ... }: {
    nix.settings.experimental-features = [ "nix-command" "flakes" "repl-flake" ];
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
  })

  # Netowrking

  ({ ... }: {
    networking = {
      hostName = "marcus-laptop";
      networkmanager.enable = true;
    };
    services = {
      openssh.enable = true;
      printing.enable = true;
    };
  })

  # Console 

  ({ ... }: {
    console.keyMap = "uk";
    programs.fish.enable = true;
    security.sudo.wheelNeedsPassword = false;
  })

  # Graphics

  ({ ...}: {
    hardware = {
      opengl.enable = true;
      nvidia.modesetting.enable = true;
      opengl.intelAcceleratedVideoPlayback.enable = true;
    };
  })

  # Window Manger

  ({ ... }: {
    services.xserver = {
      enable = true;
      autorun = false;
      xkb.layout = "gb";
    };
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    environment.sessionVariables = {
      # WLR_NO_HARDWARE_CURSORS = "1"; # can solve hidden cursor issues
      NIXOS_OZONE_WL = "1"; # encourages electron apps to use wayland
    };
  })

  # Proton VPN 
  # Tip: Control with `systemctl [start|stop|restart] wg-quick-protonvpn`

  ({ ... }: {
    networking.wg-quick.interfaces.protonvpn = {
      autostart = true;
      address = [ "10.2.0.2/32" ];
      dns = [ "10.2.0.1" ];
      privateKeyFile = "/etc/nixos/secrets/protonvpn-marcus-laptop-UK-86";
      peers = [
        {
          endpoint = "146.70.179.50:51820";
          publicKey = "zctOjv4DH2gzXtLQy86Tp0vnT+PNpMsxecd2vUX/i0U="; # UK#86
          allowedIPs = [ "0.0.0.0/0" "::/0" ]; # forward all ip traffic thru
        }
      ];
    };
  })

  # Battery Life Improvements

  ({ ... }: {
    powerManagement = {
      enable = true; # Hibernate and suspend
      powertop.enable = true; # Analysis and auto tune
    };
    services.thermald.enable = true; # Prevents overheating
    services.power-profiles-daemon.enable = true; # User switchable power profiles
  })

  # Audio and Music

  ({ ... }: {
    musnix = {
      enable = true;
      alsaSeq.enable = true;
      ffado.enable = false;
      soundcardPciId = "00:0e.0"; # Integrated sound card
      kernel.realtime = false;
      das_watchdog.enable = true;
    };
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
    };
  })

  # DANGER ZONE

  ({ ... }: {
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
  })
]
