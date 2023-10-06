{ pkgs, ... }: {

  nixpkgs.overlays = [
    (final: prev: {
      anne = {
        fish = final.callPackage ./fish.nix {};
        sway = final.callPackage ./sway.nix {};
      };
    })
  ];

  services.udev.packages = with pkgs; [
    light
  ];

  users.users.anne = {
    description = "Anne Whybrow";
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" ];
    shell = pkgs.fish;

    packages = with pkgs; [
      brave
      pcmanfm

      anne.sway

      marcus.alacritty
      marcus.rofi
      marcus.dunst
    ];
  };
}
