{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    home-manager.url = "github:nix-community/home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }: let
    lib = import ./lib { inherit nixpkgs home-manager; };
    inherit (lib) mkSystem;
  in { nixosConfigurations = {

    marcus-laptop = mkSystem "x86_64-linux" (pkgs: {
      stateVersion = "22.11";
      hardware.cpu = "intel";
      kernel.modules.beforeMountingRoot = [ "ahci" "xhci_pci" "usb_storage" "sd_mod" "rtsx_usb_sdmmc" ];
      kernel.virtualisation.enable = true;
      filesystem = {
        boot = { device = "/dev/sda1"; fsType = "vfat"; mountPoint = "/boot/efi"; };
        root = { device = "/dev/sda2"; fsType = "ext4"; isEncrypted = true; };
        swap = { device = "/dev/sda3"; isEncrypted = true; };
      };
      boot.mountPoint = "/boot/efi";
      networking.hostName = "marcus-laptop";
      localisation = {
        timeZone = "Europe/London";
        locale = "en_GB.UTF-8";
        layout = "gb";
        keyMap = "uk";
      };
      gui = { enable = true; autorun = false; };
      packages = with pkgs; [
        vim

        # Social
        discord

        # Networking
        wget unixtools.ping

        # Fast rust tools
        trashy bat exa fd procs sd du-dust ripgrep ripgrep-all tealdeer bandwhich

        # Utils
        coreboot-configurator
      ];
      programs.fish.enable = true;
      services = {
        openssh.enable = true;
        printing.enable = true;
      };
      users.marcus = {
        theme = "light";
        fullName = "Marcus Whybrow";
        groups = [ "networkmanager" "wheel" "video" ];
        shell = pkgs.fish;
        git = { 
          enable = true;
          userName = "Marcus Whybrow";
          userEmail = "marcus@whybrow.uk";
        };
        sway = {
          enable = true;
          terminal = "alacritty";
          disableBars = true;
        };
        waybar.enable = true;
        neovim.enable = true;
        rofi.enable = true;
        alacritty = {
          enable = true;
        };
        packages = with pkgs; [
          htop
          brave
          vimb
        ];
        programs = {
          fish.enable = true;
          starship.enable = true;
        };
      };
    });

  }; };
}
