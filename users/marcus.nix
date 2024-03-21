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
      pkgs.obsidian-wayland
    ]) ++ (onHost "marcus-desktop" [
      pkgs.reaper
      pkgs.discord
      pkgs.obsidian
      pkgs.wineWowPackages.waylandFull
      pkgs.yabridge
      pkgs.yabridgectl
    ]);
  };
}
