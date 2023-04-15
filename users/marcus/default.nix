{ pkgs, ... }: let
  terminalPadding = 20;
  primaryColor = "#1e88eb";
in {
  imports = [
    ./sway.nix
    ./fish.nix
  ];

  config.nixpkgs.overlays = [
    (final: prev: {
      marcus = let
        alacritty = "${final.marcus.alacritty}/bin/alacritty";
      in {
        alacritty = prev.custom.alacritty.override {
          padding = terminalPadding;
          opacity = 0.95;
        };

        neovim = prev.custom.neovim.override {
          beforeNeovimOpens = ''
             ${alacritty} msg config \
              window.padding.x=0 \
              window.padding.y=0
            ${final.wtype}/bin/wtype -M ctrl 0
          '';
          afterNeovimCloses = ''
            ${alacritty} msg config \
              window.padding.x=${toString terminalPadding} \
              window.padding.y=${toString terminalPadding}
            ${final.wtype}/bin/wtype -M ctrl 0
          '';
        };

        waybar = prev.custom.waybar.override {
          inherit primaryColor;
          warningColor = "#ff8800";
          criticalColor = "#ff0000";
          iconFont = "Font Awesome 6 Free";
          extraConfig = let 
            openInAlacritty = "${alacritty} --command";
            htop = "${pkgs.htop}/bin/htop";
            open = "${pkgs.xdg-utils}/bin/xdg-open";
          in rec {
            network.on-click = ''${pkgs.networking}/bin/networking'';
            wifiAlarm.on-click = network.on-click;
            cpu.on-click = ''${openInAlacritty} ${htop} --sort-key=PERCENT_CPU'';
            memory.on-click = ''${openInAlacritty} ${htop} --sort-key=PERCENT_MEM'';
            disk.on-click = ''${openInAlacritty} ${htop} --sort-key=IO_RATE'';
            date.on-click = ''${open} https://calendar.proton.me/u/1'';
          };
        };

        rofi = prev.custom.rofi.override {
          borderColor = primaryColor;
        };

        dunst = prev.custom.dunst.override {
          extraConfig.global = {
            dmenu = "${pkgs.marcus.rofi}/bin/rofi -show dmenu -p Notification";
            frame_color = primaryColor;
            foreground = primaryColor;
            highlight = primaryColor;
          };
        };
      };
    })
  ];

  config.users.users.marcus = {
    description = "Marcus Whybrow";
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];

    packages = with pkgs; [
      htop lsof # htop requires lsof when you press `l` on a processF
      # TODO wrap htop with lsof in path 

      brave
      vimb
      discord
      obsidian

      plex-media-player

      ranger

      marcus.alacritty
      marcus.neovim
      marcus.waybar
      marcus.rofi
      marcus.dunst

      git gh delta

      custom.private
    ];
  };
}
