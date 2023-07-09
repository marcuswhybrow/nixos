{ pkgs, ... }: {

  nixpkgs.overlays = [
    (final: prev: {
      anne = {
        fish = final.custom.fish.override {
          init = ''
            if status is-login
              ${final.anne.sway}/bin/sway
            end

            if status is-interactive
              ${pkgs.custom.starship}/bin/starship init fish | source
            end
          '';
        };

        sway = final.custom.sway.override {
          replaceConfig = ''
            font pango:monospace 8.000000
            floating_modifier Mod4
            default_border pixel 2
            default_floating_border pixel 2
            hide_edge_borders none
            focus_wrapping no
            focus_follows_mouse yes
            focus_on_window_activation smart
            mouse_warping output
            workspace_layout default
            workspace_auto_back_and_forth no

            client.focused #ff0000 #ff0000 #000000 #ff0000 #ff441e
            client.focused_inactive #ffffff #ffffff #000000 #0000ff #ffffff00
            client.unfocused #ffffff #ffffff #000000 #00ff00 #dddddd
            client.urgent #2f343a #900000 #ffffff #900000 #900000
            client.placeholder #000000 #0c0c0c #ffffff #000000 #0c0c0c
            client.background #ffffff

            input "*" {
              natural_scroll enabled
              repeat_delay 300
              tap enabled
              xkb_layout gb
            }

            output "*" {
              background #ffffff solid_color
            }

            bindsym --release Super_L exec ${final.rofi}/bin/rofi -show drun -show-icons -display-drun -i Apps
            bindsym Mod1+Control+Shift+Escape mode default
            bindsym Mod4+Escape kill
            bindsym Mod4+Left focus left
            bindsym Mod4+Right focus right
            bindsym Mod4+Shift+Escape exec ${final.custom.sway}/bin/swaynag -t warning -m "Shutdown?" -b "Shutdown" "systemctl poweroff"
            bindsym Mod4+Shift+Left move left
            bindsym Mod4+Shift+Right move right

            bindsym XF86AudioLowerVolume exec ${final.custom.volume}/bin/volume down
            bindsym XF86AudioMute exec ${final.custom.volume}/bin/volume toggle-mute
            bindsym XF86AudioRaiseVolume exec ${final.custom.volume}/bin/volume up
            bindsym XF86MonBrightnessDown exec ${final.custom.brightness}/bin/brightness down
            bindsym XF86MonBrightnessUp exec ${final.custom.brightness}/bin/brightness up

            gaps inner 5
            smart_gaps on
            smart_borders on

            exec "${final.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP XDG_SESSION_TYPE; systemctl --user start sway-session.target"
            exec ${final.brave}/bin/brave
          '';
        };
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
