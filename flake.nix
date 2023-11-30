{
  inputs = {
    alacritty = {
      url = "github:marcuswhybrow/alacritty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    alarm = {
      url = "github:marcuswhybrow/alarm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    anne-sway = { 
      url = "github:whybrow/anne-sway"; 
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rofi.follows = "rofi";
        volume.follows = "volume";
        brightness.follows = "brightness";
        waybar.follows = "waybar";
      };
    };
    anne-fish = { 
      url = "github:whybrow/anne-fish"; 
      inputs = {
        nixpkgs.follows = "nixpkgs";
        sway.follows = "anne-sway";
        starship.follows = "starship";
      };
    };
    brightness = {
      url = "github:marcuswhybrow/brightness";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dunst = {
      url = "github:marcuswhybrow/dunst";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fish = {
      url = "github:marcuswhybrow/fish";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        neovim.follows = "neovim";
        git.follows = "git";
        starship.follows = "starship";
      };
    };
    git = {
      url = "github:marcuswhybrow/git";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        neovim.follows = "neovim";
      };
    };
    logout= {
      url = "github:marcuswhybrow/logout";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rofi.follows = "rofi";
      };
    };
    neovim = {
      url = "github:marcuswhybrow/neovim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    networking = {
      url = "github:marcuswhybrow/networking";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rofi.follows = "rofi";
      };
    };
    nixos-wsl = { 
      url = "github:nix-community/NixOS-WSL"; 
      inputs.nixpkgs.follows = "nixpkgs"; 
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-updates = {
      url = "github:marcuswhybrow/nixpkgs-updates";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    private = {
      url = "github:marcuswhybrow/private";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        alacritty.follows = "alacritty";
      };
    };
    starship = {
      url = "github:marcuswhybrow/starship";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sway = {
      url = "github:marcuswhybrow/sway";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        alacritty.follows = "alacritty";
        private.follows = "private";
        logout.follows = "logout";
        rofi.follows = "rofi";
        volume.follows = "volume";
        brightness.follows = "brightness";
        waybar.follows = "waybar";
      };
    };
    tmux = {
      url = "github:marcuswhybrow/tmux";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        fish.follows = "fish";
      };
    };
    rofi = {
      url = "github:marcuswhybrow/rofi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    volume = {
      url = "github:marcuswhybrow/volume";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    waybar = {
      url = "github:marcuswhybrow/waybar";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        networking.follows = "networking";
        nixpkgs-updates.follows = "nixpkgs-updates";
        alacritty.follows = "alacritty";
      };
    };
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
