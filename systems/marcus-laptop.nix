{ lib, pkgs, config, helpers, ... }: {
  environment.systemPackages = with pkgs; [
    vim

    # Networking
    wget unixtools.ping

    # Fast rust tools
    trashy bat exa fd procs sd du-dust ripgrep ripgrep-all tealdeer bandwhich

    # Utils
    coreboot-configurator

    # Mounting Windows Shares
    cifs-utils
    lxqt.lxqt-policykit
  ];

  # https://nixos.wiki/wiki/Samba
  fileSystems."/mnt/marcus-desktop/local" = {
    device = "//192.168.1.22/Local";
    fsType = "cifs";
    options = let
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in [ "${automount_opts},credentials=/etc/nixos/secrets/marcus-laptop-smb,uid=1000,gid=100" ];
  };
  networking.firewall.extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';
  services.gvfs.enable = true;

  # https://nixos.wiki/wiki/Fonts
  fonts.fonts = with pkgs; [
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

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  
  security.sudo.wheelNeedsPassword = false;

  hardware.opengl.intelAcceleratedVideoPlayback.enable = true;

  # DANGER ZONE
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
