outputs: pkgs: rec {
  system = "x86_64-linux";
  stateVersion = "22.11";
  allowUnfree = true;
  hardware.cpu = "intel";
  kernel.modules.beforeMountingRoot = [
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
  kernel.virtualisation.enable = true;
  filesystem = {
    root = { device = "/dev/sda1"; fsType = "ext4"; };
    swap = { device = "/dev/sda2"; };
  };
  boot.grub = {
    enable = true;
    device = "/dev/sda";
  };
  localisation = {
    timeZone = "Europe/London";
    locale = "en_GB.UTF-8";
    layout = "gb";
    keyMap = "uk";
  };
  gui = { enable = true; autorun = false; };
  packages = with pkgs; [
    vim

    # Networking
    wget unixtools.ping
  ];
  extraConfig = {
    # Hide boot messages behind NixOS logo
    boot.plymouth.enable = true;

    services.getty.autologinUser = "anne";
    programs.fish.enable = true;
    services = {
      openssh.enable = true;
      printing.enable = true;
    };
  };
  users = {
    anne = import ./users/anne.nix outputs pkgs;
    marcus = import ./users/marcus.nix outputs pkgs;
  };
}
