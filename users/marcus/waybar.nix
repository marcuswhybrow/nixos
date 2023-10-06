{
  pkgs,
  primaryColor ? "#1e88eb",

}: pkgs.callPackage ../../pkgs/waybar.nix {
  inherit primaryColor;
  warningColor = "#ff8800";
  criticalColor = "#ff0000";
  iconFont = "Font Awesome 6 Free";
  extraConfig = let 
    openInAlacritty = "${pkgs.marcus.alacritty}/bin/alacritty --command";
    htop = "${pkgs.htop}/bin/htop";
    open = "${pkgs.xdg-utils}/bin/xdg-open";
  in rec {
    network.on-click = ''${pkgs.marcus.networking}/bin/networking'';
    wifiAlarm.on-click = network.on-click;
    cpu.on-click = ''${openInAlacritty} ${htop} --sort-key=PERCENT_CPU'';
    memory.on-click = ''${openInAlacritty} ${htop} --sort-key=PERCENT_MEM'';
    disk.on-click = ''${openInAlacritty} ${htop} --sort-key=IO_RATE'';
    date.on-click = ''${open} https://calendar.proton.me/u/1'';
  };
}
