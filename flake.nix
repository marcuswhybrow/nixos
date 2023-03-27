{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    home-manager.url = "github:nix-community/home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations.marcus-laptop = let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./platform.nix
        ./hardware.nix
        ./kernel.nix
        ./filesystem.nix
        ./boot.nix
        ./networking.nix
        ./localisation.nix
        ./audio.nix
        ./users.nix
        ./display.nix
        ./gui.nix
        ./bar
        ./home-manager/git.nix
        ./home-manager/sway.nix
        ./home-manager/neovim.nix
        ./home-manager/rofi.nix
	home-manager.nixosModules.home-manager
        {
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          system.stateVersion = "22.11";
          environment.systemPackages = with pkgs; [
            vim

            # Networking
            wget unixtools.ping

            # Fast rust tools
            trashy bat exa fd procs sd du-dust ripgrep ripgrep-all tealdeer bandwhich

            # Utils
            coreboot-configurator
          ];
          programs.fish.enable = true;
          services.openssh.enable = true;
          services.printing.enable = true;
          custom = {
            platform = "x86_64-linux";
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
            audio.enable = true;
            display.adjustableBrightness = {
              enable = true;
              keycode.decrease = 232;
              keycode.increase = 233;
            };
            gui = { enable = true; autorun = false; };
            bar = { enable = true; user = "marcus"; };
            users.marcus = {
              fullName = "Marcus Whybrow";
              groups = [ "networkmanager" "wheel" "video" ];
              shell = pkgs.fish;
              git = { 
                enable = true;
                userName = "Marcus Whybrow";
                userEmail = "marcus@whybrow.uk";
              };
              sway = { enable = true; terminal = "alacritty"; };
              neovim.enable = true;
              rofi.enable = true;
              packages = with pkgs; [ htop alacritty brave ];
              programs = {
                fish.enable = true;
                starship.enable = true;
              };
            };
          };
	}
      ];
    };
  };
}
