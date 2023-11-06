{ pkgs, ... }: let
  terminalPadding = 20;
  primaryColor = "#1e88eb";
in {
  nixpkgs.overlays = [
    (final: prev: {
      marcus = {
        alacritty = final.callPackage ./alacritty.nix {
          padding = terminalPadding; 
        };

        fish = final.callPackage ./fish.nix {};

        starship = final.callPackage ./starship.nix {};

        neovim = final.callPackage ./neovim.nix {
          pkgs = final;
          padding = terminalPadding;
        };

        waybar = final.callPackage ./waybar.nix {
          inherit primaryColor;
        };

        rofi = final.callPackage ./rofi.nix {
          borderColor = primaryColor;
        };

        dunst = final.callPackage ./dunst.nix {
          inherit primaryColor;
        };

        sway = final.callPackage ./sway.nix {};

        networking = final.callPackage ./networking.nix {};

        logout = final.callPackage ./logout.nix {};

        git = final.callPackage ./git.nix {};

        tmux = final.callPackage ./tmux.nix {};
      };
    })
  ];

  environment.systemPackages = with pkgs; [
    light
    direnv 
    nix-direnv
  ];
  services.udev.packages = with pkgs; [ light ];

  # Consider including this if packaging direnv and nix-direnv 
  # https://github.com/marcuswhybrow/.nixos/issues/6
  # https://github.com/nix-community/nix-direnv
  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
  };
  environment.pathsToLink = [
    "/share/nix-direnv"
  ];

  # Proton VPN
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

  users.users.marcus = {
    description = "Marcus Whybrow";
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];

    packages = with pkgs; [
      htop lsof # htop requires lsof when you press `l` on a processF
      # TODO wrap htop with lsof in path 

      brave
      vimb
      discord
      obsidian
      reaper
      protonvpn-gui protonvpn-cli protonmail-bridge

      plex-media-player

      ranger

      marcus.sway
      marcus.fish
      marcus.alacritty
      marcus.neovim
      marcus.waybar
      marcus.rofi
      marcus.dunst
      marcus.logout
      marcus.networking
      marcus.git gh
      marcus.tmux

      custom.private
    ];

  };
}
