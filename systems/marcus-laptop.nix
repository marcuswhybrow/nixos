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

  musnix = {
    enable = true;
    alsaSeq.enable = true;
    ffado.enable = false;
    soundcardPciId = "00:0e.0"; # Integrated sound card
    kernel.realtime = true;
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

  environment.etc = {
    "pipewire/pipewire.conf.d/92-low-latency.conf".text = let
      quantum = 128;
      rate = 48000;
      both = "${toString quantum}/${toString rate}";
    in builtins.toJSON {
      context.properties = {
        default.clock = {
          inherit quantum rate;
          min-quantum = quantum;
          max-quantum = quantum;
        };
      };
      context.modules = [
        {
          name = "libpipewire-module-protocol-pulse";
          args.pulse = {
            default.req = both;
            min = {
              req = both;
              quantum = both;
            };
            max = {
              req = both;
              quantum = both;
            };
          };
        }
      ];
      stream.properties = {
        node.latency = both;
        resample.quality = 1;
      };
    };
    # "wireplumber/main.lua.d/51-device-names.lua".text = ''
    #   alsa_monitor.rules = {
    #     {
    #       matches = {
    #         {
    #           { "node.name", "equals", "alsa_output.pci-0000_00_0e.0.analog-stereo" },
    #         },
    #       },
    #       apply_properties = {
    #         ["node.nick"] = "Speakers",
    #       },
    #     },
    #     {
    #       matches = {
    #         {
    #           { "node.name", "equals", "v4l2_input.pci-0000_00_15.0-usb-0_8_1.0" },
    #         },
    #       },
    #       apply_properties = {
    #         ["node.nick"] = "Camera Video",
    #       },
    #     },
    #     {
    #       matches = {
    #         {
    #           { "node.name", "equals", "alsa_input.usb-Sonix_Technology_Co.__Ltd._USB_2.0_Camera_SN0001-02.mono-fallback" },
    #         },
    #       },
    #       apply_properties = {
    #         ["node.nick"] = "Camera Audio",
    #       },
    #     },
    #   }
    # '';
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

  networking = {
    enable = true;
    hostName = "marcus-laptop";
    networkmanager.enable = true;

    # Proton VPN
    wg-quick.interfaces.protonvpn = {
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
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" "repl-flake" ];


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
