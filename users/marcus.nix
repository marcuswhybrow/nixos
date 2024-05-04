{ pkgs, mwpkgs, config, ... }: {
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

  users.users.marcus = {
    description = "Marcus Whybrow";
    isNormalUser = true;
    shell = pkgs.fish; # don't use custom package here
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
    ];

    packages = let 
      onHost = host: value: if config.networking.hostName == host then value else [];
    in [
      pkgs.htop
      pkgs.lsof # htop requires lsof when you press `l` on a processF
      pkgs.brave
      pkgs.firefox
      pkgs.ranger
      pkgs.gh
      pkgs.megacmd
      pkgs.krita
      pkgs.unzip
      pkgs.vlc
      pkgs.mpv
      mwpkgs.flake-updates
      mwpkgs.hyprland
      mwpkgs.fish
      mwpkgs.alacritty
      mwpkgs.starship
      mwpkgs.neovim
      mwpkgs.waybar
      mwpkgs.rofi
      mwpkgs.dunst
      mwpkgs.logout
      mwpkgs.networking
      mwpkgs.git
      mwpkgs.tmux
      mwpkgs.private
      mwpkgs.alarm
      mwpkgs.volume
      mwpkgs.brightness
    ] ++ (onHost "marcus-laptop" [
      mwpkgs.hyprland-fish-auto-login
      pkgs.reaper
      pkgs.discord
      pkgs.obsidian-wayland
    ]) ++ (onHost "marcus-desktop" [
      pkgs.megasync
      pkgs.reaper
      pkgs.discord
      pkgs.obsidian
      pkgs.wineWowPackages.waylandFull
      pkgs.yabridge
      pkgs.yabridgectl
    ]) ++ (onHost "marcus-wsl" [
      # No WSL specific packages as yet
    ]);
  };
}
