{ config, pkgs, lib, ... }: {
  imports = [
    ./alacritty.nix
  ];

  config.home-manager.users.marcus = {
    programs.networking.enable = true;
    programs.alacritty.enable = true;
    programs.htop.enable = true;

    programs.waybar = let
      alacritty = "${pkgs.alacritty}/bin/alacritty";
    in {
      enable = true;
      marcusBar = rec {
        enable = true;
        network.onClick =   ''${pkgs.networking}/bin/networking'';
        wifiAlarm.onClick = network.onClick;
        cpu.onClick =       ''${alacritty} -e htop --sort-key=PERCENT_CPU'';
        memory.onClick =    ''${alacritty} -e htop --sort-key=PERCENT_MEM'';
        disk.onClick =      ''${alacritty} -e htop --sort-key=IO_RATE'';
        date.onClick =      ''${pkgs.xdg-utils}/bin/xdg-open https://calendar.proton.me/u/1'';
      };
    };
  };
}
