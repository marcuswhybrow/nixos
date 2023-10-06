{
  pkgs,
  primaryColor ? "#1e88eb",

}: pkgs.callPackage ../../pkgs/dunst.nix {
  extraConfig.global = {
    dmenu = "${pkgs.marcus.rofi}/bin/rofi -show dmenu -p Notification";
    frame_color = primaryColor;
    foreground = primaryColor;
    highlight = primaryColor;
  };
  
}
