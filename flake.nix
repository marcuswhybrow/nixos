{
  inputs = {
    alacritty.url = "github:marcuswhybrow/alacritty";
    alarm.url = "github:marcuswhybrow/alarm";
    anne-sway.url = "github:whybrow/anne-sway";
    anne-fish.url = "github:whybrow/anne-fish";
    brightness.url = "github:marcuswhybrow/brightness";
    dunst.url = "github:marcuswhybrow/dunst";
    fish.url = "github:marcuswhybrow/fish";
    git.url = "github:marcuswhybrow/git";
    logout.url = "github:marcuswhybrow/logout";
    neovim.url = "github:marcuswhybrow/neovim";
    networking.url = "github:marcuswhybrow/networking";
    nixos-wsl = { url = "github:nix-community/NixOS-WSL"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-updates.url = "github:marcuswhybrow/nixpkgs-updates";
    private.url = "github:marcuswhybrow/private";
    starship.url = "github:marcuswhybrow/starship";
    sway.url = "github:marcuswhybrow/sway";
    tmux.url = "github:marcuswhybrow/tmux";
    rofi.url = "github:marcuswhybrow/rofi";
    volume.url = "github:marcuswhybrow/volume";
    waybar.url = "github:marcuswhybrow/waybar";
  };

  outputs = inputs: let
    lib = inputs.nixpkgs.lib;

    toNixosSystem = hostname: systemModules: lib.nixosSystem {
      modules = [
        ./modules/nix-flake-support.nix
        ({ lib, ... }: {
          networking.hostName = hostname; 
          networking.networkmanager.enable = lib.mkDefault true;
        })
      ] ++ systemModules;
      specialArgs = { inherit inputs; };
    };

    mountMarcusDesktop = import ./modules/samba-mount.nix {
      local = "/mnt/marcus-desktop/local";
      remote = "//192.168.0.23/Local";
    };
  in {
    nixosConfigurations = builtins.mapAttrs toNixosSystem {
      marcus-laptop = [
        ./systems/marcus-laptop.nix
        ./users/marcus.nix
        ./modules/intel-accelerated-video-playback.nix
        ./modules/coding-fonts.nix
        mountMarcusDesktop
      ];

      Marcus-Desktop = [
        inputs.nixos-wsl.nixosModules.wsl
        ./systems/marcus-desktop.nix
        ./users/marcus.nix
      ];

      anne-laptop = [
        ./systems/anne-laptop.nix
        ./modules/intel-accelerated-video-playback.nix
        ./users/anne.nix
        ./users/marcus.nix
      ];

    };
  };
}
