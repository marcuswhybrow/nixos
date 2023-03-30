pkgs: rec {
  system = "x86_64-linux";
  stateVersion = "22.11";
  allowUnfree = true;
  hardware.cpu = "intel";
  kernel.modules.beforeMountingRoot = [ "ahci" "xhci_pci" "usb_storage" "sd_mod" "rtsx_usb_sdmmc" ];
  kernel.virtualisation.enable = true;
  filesystem = {
    boot = { device = "/dev/sda1"; fsType = "vfat"; mountPoint = "/boot/efi"; };
    root = { device = "/dev/sda2"; fsType = "ext4"; isEncrypted = true; };
    swap = { device = "/dev/sda3"; isEncrypted = true; };
  };
  boot.mountPoint = "/boot/efi";
  localisation = {
    timeZone = "Europe/London";
    locale = "en_GB.UTF-8";
    layout = "gb";
    keyMap = "uk";
  };
  gui = { enable = true; autorun = false; };
  packages = with pkgs; [
    vim

    # Networking
    wget unixtools.ping

    # Fast rust tools
    trashy bat exa fd procs sd du-dust ripgrep ripgrep-all tealdeer bandwhich

    # Utils
    coreboot-configurator
  ];
  extraConfig = {
    programs.fish.enable = true;
    services = {
      openssh.enable = true;
      printing.enable = true;
    };
  };
  users.marcus = {
    theme = "light";
    fullName = "Marcus Whybrow";
    groups = [ "networkmanager" "wheel" "video" ];
    shell = pkgs.fish;
    git = { 
      enable = true;
      userName = "Marcus Whybrow";
      userEmail = "marcus@whybrow.uk";
    };
    sway = {
      enable = true;
      terminal = "alacritty";
      disableBars = true;
    };
    waybar.enable = true;
    neovim.enable = true;
    rofi.enable = true;
    alacritty.enable = true;
    packages = with pkgs; [
      htop
      brave
      vimb
      discord
      obsidian
    ];
    audio.step = 5;
    extraHomeManagerConfig = {
      services.dunst = {
        enable = true;
      };
      programs.fish = {
        enable = true;
        shellAbbrs = {
          c = ''vim ~/.dotfiles/systems/(hostname).nix'';
          d = ''cd ~/.dotfiles'';
        };
      };
      programs.starship.enable = true;
      xdg.configFile = {
        "fish/functions/volume.fish".text = ''
          function volume
            pamixer $argv > /dev/null
            
            set msgTag volume
            set vol (pamixer --get-volume)
            set mute (pamixer --get-mute)

            if $mute == "true"
              dunstify \
                -a changeVolume \
                -u low \
                -i audio-volume-muted \
                -h string:x-dunst-stack-tag:$msgTag \
                "Volume muted"
            else
              dunstify \
                -a changeVolume \
                -u low \
                -i audio-volume-high \
                -h string:x-dunst-stack-tag:$msgTag \
                -h int:value:$vol \
                "Volume: $vol%"
            end
          end
        '';
        "fish/functions/logout.fish".text = ''
          function logout
            echo "\
            🔒 Lock (swaylock)
            🪵 Logout (loginctl terminate-user $USER)
            🌙 Suspend (systemctl suspend)
            🧸 Hibernate (systemctl hibernate)
            🐤 Restart (systemctl reboot)
            🪓 Shutdown (systemctl poweroff)
            Do Nothing" | \
            rofi \
              -dmenu \
              -p Logout | \
            rg "\((.*)\)" -or '$1' | \
            fish
          end
        '';
      };
    };
  };
}
