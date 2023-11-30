{ pkgs, inputs, ... }: {
  environment.systemPackages = [
    pkgs.light
    pkgs.direnv 
    pkgs.nix-direnv
  ];
  services.udev.packages = [ 
    pkgs.light 
  ];

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
    shell = pkgs.fish; # don't use custom package here
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];

    packages = [
      pkgs.htop
      pkgs.lsof # htop requires lsof when you press `l` on a processF

      pkgs.brave
      pkgs.discord
      pkgs.obsidian
      pkgs.reaper

      pkgs.ranger
      pkgs.hyprland
      pkgs.gh

      inputs.fish.packages.x86_64-linux.fish
      inputs.alacritty.packages.x86_64-linux.alacritty
      inputs.neovim.packages.x86_64-linux.nvim
      inputs.waybar.packages.x86_64-linux.waybar
      inputs.rofi.packages.x86_64-linux.rofi
      inputs.dunst.packages.x86_64-linux.dunst
      inputs.logout.packages.x86_64-linux.logout
      inputs.networking.packages.x86_64-linux.networking
      inputs.git.packages.x86_64-linux.git
      inputs.tmux.packages.x86_64-linux.tmux
      inputs.private.packages.x86_64-linux.private
      inputs.alarm.packages.x86_64-linux.alarm
      inputs.volume.packages.x86_64-linux.volume
      inputs.brightness.packages.x86_64-linux.brightness
    ];
  };
}
