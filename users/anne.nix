{ pkgs, inputs, ... }: {

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

      inputs.anne-fish.packages.x86_64-linux.fish
      inputs.anne-sway.packages.x86_64-linux.sway
      inputs.alacritty.packages.x86_64-linux.alacritty
      inputs.dunst.packages.x86_64-linux.dunst
    ];
  };
}
