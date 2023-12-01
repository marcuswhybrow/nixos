{ pkgs, inputs, mwpkgs, ... }: {

  services.udev.packages = [
    pkgs.light
  ];

  users.users.anne = {
    description = "Anne Whybrow";
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" ];
    shell = pkgs.fish; # using custom fish here breaks login
    packages = [
      pkgs.firefox
      pkgs.pcmanfm

      mwpkgs.anne-fish
      mwpkgs.anne-sway
      mwpkgs.alacritty
      mwpkgs.dunst
    ];
  };
}
