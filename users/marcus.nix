{ pkgs, mwpkgs, config, ... }: let 
  onHost = host: value: if config.networking.hostName == host then value else [];
in {
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

    packages = with pkgs; [
      htop
      lsof # htop requires lsof when you press `l` on a processF
      brave
      firefox
      ranger
      gh
      megasync
      megacmd
      krita
      unzip
      vlc
      mpv
    ] ++ (with mwpkgs; [
      flake-updates
      hyprland
      fish
      alacritty
      starship
      neovim
      waybar
      rofi
      dunst
      logout
      networking
      git
      tmux
      private
      alarm
      volume
      brightness
    ]) ++ (onHost "marcus-laptop" [
      mwpkgs.hyprland-fish-auto-login
      pkgs.reaper
      pkgs.discord
      pkgs.obsidian
    ]);
  };
}
