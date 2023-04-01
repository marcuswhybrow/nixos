{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: let
    inherit (builtins) mapAttrs map baseNameOf;
    inherit (nixpkgs.lib) nixosSystem mkDefault mkOption types mkEnableOption mkOptionDefault mkIf;
    utils = import ./utils nixpkgs.lib;

    marcus = [
      # Neovim
      ({ pkgs, ... }: {
        home-manager.users.marcus = {
          home.packages = [ pkgs.wl-clipboard ];
          programs.neovim = {
            enable = true;
            vimAlias = true;
            plugins = with pkgs.vimPlugins; [
              vim-fish
              vim-nix
            ];
          };
        };
      })

      # Wayland Window Manager testing
      ({ pkgs, ... }: {
        home-manager.users.marcus = {
          home.packages = with pkgs; [
            # Testing various tiling window managers
            cagebreak 
            river
            cardboard # scrolling wm
            #dwl foot # suckless
            # Hyperland requires nixos-unstable
            # github:jbuchermn/newm#newm
            #outputs.newm
            qtile
            # https://github.com/michaelforney/velox
            # https://github.com/inclement/vivarium
            # https://github.com/waymonad/waymonad
          ];

          xdg.configFile."river/init" = {
            text = ''
              #!/run/current-system/sw/bin/sh
              ${builtins.readFile (builtins.fetchurl {
                url = "https://raw.githubusercontent.com/riverwm/river/0.2.x/example/init";
                sha256 = "sha256:0dmk29gak0hqb6ghpzrqd15g0vmsk10wzkiw9qhz5l7gb0mfdsxf";
              })}
              riverctl map normal Super T spawn alacritty
            '';
            executable = true;
          };

          xdg.configFile."cardboard/cardboardrc" = {
            executable = true;
            text = ''
              #!/run/current-system/sw/bin/sh

              alias cutter=${pkgs.cardboard}/bin/cutter

              mod=alt

              cutter config gap 5
              cutter config focus_color 0 0 0

              cutter config mouse_mod $mod

              cutter bind $mod+shift+e quit
              cutter bind $mod+return exec alacritty


              cutter bind $mod+left focus left
              cutter bind $mod+right focus right
              
              cutter bind $mod+h focus left
              cutter bind $mod+l focus right


              cutter bind $mod+shift+left move -10 0
              cutter bind $mod+shift+right move 10 0
              cutter bind $mod+shift+up move 0 -10
              cutter bind $mod+shift+down move 0 10

              cutter bind $mod+shift+h move -10 0
              cutter bind $mod+shift+j move 0 10
              cutter bind $mod+shift+k move 0 -10
              cutter bind $mod+shift+l move 10 0

              cutter bind $mod+shift+p pop_from_column


              cutter bind $mod+shift+q close

              for i in $(seq 1 6); do
                      cutter bind $mod+$i workspace switch $(( i - 1 ))
                      cutter bind $mod+shift+$i workspace move $(( i - 1 ))
              done

              cutter bind $mod+shift+space toggle_floating
            '';
          };
        };
      })

      # Shell & Terminal
      ({ pkgs, ... }: {
        home-manager.users.marcus = {
          programs.alacritty = {
            enable = true;
            settings.window.padding = { x = 5; y = 5; };
          };

          programs.fish.enable = true;
          programs.fish.shellAbbrs = {
            c = ''vim ~/.dotfiles/systems/(hostname).nix'';
            d = ''cd ~/.dotfiles'';
            t = ''vim ~/obsidian/Personal/Timeline/(date +%Y-%m-%d).md'';
          };

          programs.starship.enable = true;
        };
      })

      # The Basics
      ({ pkgs, ... }: {
        users.users.marcus = {
          description = "Marcus Whybrow";
          isNormalUser = true;
          extraGroups = [ "networkmanager" "wheel" "video" ];
          shell = pkgs.fish;
        };

        custom.users.marcus = {
          theme = "light";
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
          audio.volume.step = 5;
          display.brightness.step = 5;
        };

        home-manager.users.marcus = {
          home.packages = with pkgs; [
            # htop requires lsof when you press `l` on a process
            htop lsof

            brave
            vimb
            discord
            obsidian

          ];
          
          programs.rofi.enable = true;
        };
      })
    ]; # marcus

    anne = [
      ({ pkgs, ... }: {
        users.users.anne = {
          description = "Anne Whybrow";
          isNormalUser = true;
          extraGroups = [ "networkmanager" "video" ];
          shell = pkgs.fish;
        };

        custom.users.anne = {
          theme = "light";
          audio.volume.step = 5;
          display.brightness.step = 5;
        };

        home-manager.users.anne = {
          home.packages = with pkgs; [
            brave
            cage
          ];

          programs.fish.enable = true;

          # Runs when fish starts
          xdg.configFile."fish/config.fish" = {
            executable = true;
            text = ''
              if status is-interactive
                cage brave
              end
            '';
          };
        };
      })
    ]; # anne

    marcus-laptop = marcus ++ anne ++ [
      ({ config, pkgs, ... }: {
        nixpkgs.overlays = [
          (import ./overlays/dwl.nix)
        ];

        custom.hardware.videoAcceleration.intel.enable = true;

        environment.systemPackages = with pkgs; [
          vim

          # Networking
          wget unixtools.ping

          # Fast rust tools
          trashy bat exa fd procs sd du-dust ripgrep ripgrep-all tealdeer bandwhich

          # Utils
          coreboot-configurator
        ];

        time.timeZone = "Europe/London";
        i18n.defaultLocale = "en_GB.UTF-8";
        i18n.extraLocaleSettings = utils.config.localeForAll config.i18n.defaultLocale;
        console.keyMap = "uk";

        services.xserver = {
          enable = true;
          autorun = false;
          layout = "gb";
        };

        services.getty.autologinUser = "marcus";
        programs.fish.enable = true;
        services = {
          openssh.enable = true;
          printing.enable = true;
        };
        
        security.sudo.wheelNeedsPassword = false;


        # DANGER ZONE

        system.stateVersion = "22.11";
        nixpkgs.hostPlatform = "x86_64-linux";
        nixpkgs.config.allowUnfree = true;

        boot.initrd.availableKernelModules = [
          "ahci"
          "xhci_pci"
          "usb_storage"
          "sd_mod"
          "rtsx_usb_sdmmc"

          # Enables CPU encryption instructions (speeds up LUKS)
          "aesni_intel"
          "cryptd"
        ];
        boot.kernelModules = [ "kvm-intel" ];

        boot.initrd.secrets = { "/crypto_keyfile.bin" = null; };
        boot.initrd.luks.devices.root.device = "/dev/sda2";
        boot.initrd.luks.devices.swap.device = "/dev/sda3";
        boot.initrd.luks.devices.swap.keyFile = "/crypto_keyfile.bin";

        fileSystems."/boot/efi" = { device = "/dev/sda1"; fsType = "vfat"; };
        fileSystems."/" = { device = "/dev/mapper/root"; fsType = "ext4"; };
        swapDevices = [ { device = "/dev/mapper/swap"; } ];

        boot.loader = {
          systemd-boot.enable = true;
          efi.efiSysMountPoint = "/boot/efi";
          efi.canTouchEfiVariables = true;
        };

        hardware.enableRedistributableFirmware
        hardware.cpu.intel = {
          updateMicrocode = mkDefault true;
          sgx.provision.enable = true; 
        };
      })
    ]; # marcus-laptop

    anne-laptop = anne ++ marcus ++ [
      ({ config, pkgs, ... }: {
        environment.systemPackages = with pkgs; [
          vim

          # Networking
          wget unixtools.ping
        ];

        custom = {
          hardware.videoAcceleration.intel.enable = true;
          users = [ anne marcus ];
        };

        time.timeZone = "Europe/London";
        i18n.defaultLocale = "en_GB.UTF-8";
        i18n.extraLocaleSettings = utils.localeForAll config.i18n.defaultLocale;
        console.keyMap = "uk";

        services.xserver = {
          enable = true;
          autorun = false;
          layout = "gb";
        };

        programs.fish.enable = true;
        services = {
          openssh.enable = true;
          printing.enable = true;
        };


        # DANGER ZONE

        system.stateVersion = "22.11";
        nixpkgs.hostPlatform = "x86_64-linux";
        nixpkgs.allowUnfree = true;

        boot.initrd.availableKernelModules = [
          "uhci_hcd"
          "ehci_pci"
          "ata_piix"
          "ahci"
          "firewire_ohci"
          "usb_storage"
          "sd_mod"
          "sr_mod"
          "sdhci_pci"
        ];
        boot.initrd.kernelModules = [ "kvm-intel" ];
        boot.kernelModules = [];
        boot.extraModulePackages = [];

        fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
        swapDevices = [ { device = "/dev/sda2"; } ];

        boot.loader.grub = {
          enable = true;
          device = "/dev/sda";
          useOSProber = true;
        };

        hardware.enableRedistributableFirmware = true;
        hardware.cpu.intel = {
          updateMicrocode = mkDefault true;
          sgx.provision.enable = true; 
        };

        boot.plymouth.enable = true;
        services.getty.autologinUser = "anne";
      })
    ]; # marcus-laptop


    toNixosSystem = hostname: systemConfigModuleList: nixosSystem {
      modules = systemConfigModuleList ++ [
        # Defaults for all systems
        {
          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];
          networking = {
            useDHCP = mkDefault true;
            hostName = hostname; 
            networkmanager.enable = mkDefault true;
            firewall.enable = mkDefault true;
          };
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
          };
        }

        # Home Manager
        home-manager.nixosModules.home-manager
        ({ config, ... }: {
          config.home-manager.users = utils.config.mkForEachUser config (user: {
            home.stateVersion = config.system.stateVersion;
          });
        })

        # Theme Module
        ({ config, lib, pkgs, ... }: {
          options.custom.users = utils.options.mkForEachUser {
            theme = utils.options.mkEnum "light" [ "light" ];
          };

          # Theme's only responsible for colors and fonts, not layout.
          config.home-manager.users = utils.config.mkForEachUser config (user: let
            theme = ./themes/${user.theme}.nix;
          in (
            import theme { inherit user config lib pkgs utils; }
          ));
        })

        # Hardware module
        ({ config, lib, pkgs, ... }: {
          options.custom.hardware = {
            videoAcceleration.intel.enable = mkEnableOption "Enable accelerated video playback for Intel graphics";
          };

          config = mkIf config.custom.hardware.videoAcceleration.intel.enable {
            # https://nixos.wiki/wiki/Accelerated_Video_Playback
            nixpkgs.overlays = [
              (final: prev: {
                vaapiIntel = prev.vaapiIntel.override {
                  enableHybridCodec = true;
                };
              })
            ];

            hardware.opengl = {
              enable = true;
              extraPackages = with pkgs; [
                intel-media-driver
                vaapiIntel
                vaapiVdpau
                libvdpau-va-gl
              ];
            };
          };
        })

        # Audio module
        ({ config, lib, pkgs, ... }: let
          pamixer = "${pkgs.pamixer}/bin/pamixer";
        in {
          options.custom.users = utils.options.mkForEachUser {
            audio.volume = {
              step = utils.options.mkInt 5;
              unmuteOnChange = utils.options.mkTrue;
            };
          };

          config = {
            sound.enable = true;
            security.rtkit.enable = true;
            services.pipewire = {
              enable = true;
              alsa.enable = true;
              alsa.support32Bit = true;
              pulse.enable = true;
              jack.enable = false;
            };
          };

          config.home-manager.users = utils.config.mkForEachUser config (user: {
            home.packages = [
              pkgs.pamixer
              pkgs.fish
            ];

            wayland.windowManager.sway.config = {
              keybindings = lib.mkOptionDefault (let 
                step = utils.smartStep "${pamixer} --get-volume" user.audio.step;
              in {
                XF86AudioMute = ''exec fish -c "@volume toggle-mute"'';
                XF86AudioLowerVolume = ''exec fish -c "@volume down"'';
                XF86AudioRaiseVolume = ''exec fish -c "@volume up"'';
                XF86AudioPrev = ''exec'';
                XF86AudioPlay = ''exec'';
                XF86AudioNext = ''exec'';
              });
            };

            xdg.configFile."fish/functions/@volume.fish".text = let
              inherit (user.audio.volume) step unmuteOnChange;
            in ''
              function @volume
                switch (pamixer --get-volume)
                  case 0
                    set step 1
                  case 1
                    set step ${toString (step - 1)}
                  case '*'
                    set step ${toString step}
                end

                switch $argv[1]
                  case up
                    pamixer ${if unmuteOnChange then "--unmute" else ""} --increase $step
                  case down
                    pamixer ${if unmuteOnChange then "--unmute" else ""} --decrease $step
                  case toggle-mute
                    pamixer --toggle-mute
                end

                set vol (pamixer --get-volume)
                set mute (pamixer --get-mute)
                set tag volume

                if test $vol = "0"; or test $mute = "true"
                  dunstify \
                    --appname changeVolume \
                    --urgency low \
                    --icon audio-volume-muted \
                    --hints string:x-dunst-stack-tag:$tag \
                    "Volume muted"
                else
                  dunstify \
                    --appname changeVolume \
                    --urgency low \
                    --icon audio-volume-high \
                    --hints string:x-dunst-stack-tag:$tag \
                    --hints int:value:$vol \
                    --timeout 2000 \
                    "Volume: $vol%"
                end
              end
            '';
          });
        })

        # Display Module
        ({ config, lib, pkgs, ... }: let
          light = "${pkgs.light}/bin/light";
          fish = "${pkgs.fish}/bin/fish";
          dunstify = "${pkgs.dunst}/bin/dunstify";
        in {
          options.custom.users = utils.options.mkForEachUser {
            display.brightness.step = utils.options.mkInt 5;
          };

          config.programs.light.enable = true;

          config.home-manager.users = utils.config.mkForEachUser config (user: {
            home.packages = [
              pkgs.fish
              pkgs.dunst
            ];

            wayland.windowManager.sway.config.keybindings = mkOptionDefault {
              XF86MonBrightnessUp = ''exec fish -c "@brightness up"'';
              XF86MonBrightnessDown = ''exec fish -c "@brightness down"'';
            };

            xdg.configFile."fish/functions/@brightness.fish".text = ''
              function @brightness
                switch (light -G)
                  case 0.00
                    set step 1
                  case 1.00
                    set step ${toString (user.display.brightness.step - 1)}
                  case '*'
                    set step ${toString user.display.brightness.step}
                end

                switch $argv[1]
                  case up
                    light -A $step
                  case down
                    light -U $step
                  case '*'
                    light -G
                end

                set val (light -G)

                dunstify \
                  --appname changeBrightness \
                  --urgency low \
                  --hints string:x-dunst-stack-tag:brightness \
                  --hints int:value:$val \
                  --timeout 1000 \
                  "Brightness $val%"
              end
            '';
          });
        })

        # Git Module
        ({ config, lib, pkgs, ... }: {
          options.custom.users = utils.options.mkForEachUser {
            git.enable = mkEnableOption "Enable git tool chain";
            git.userName = mkOption { type = types.str; };
            git.userEmail = mkOption { type = types.str; };
          };

          config.home-manager.users = utils.config.mkForEachUser config (user: {
            programs = mkIf user.git.enable {
              gh.enable = true;
              git = {
                enable = true;
                inherit (user.git) userName userEmail;
                extraConfig = {
                  init.defaultBranch = "main";
                  core.editor = "vim";
                };
                delta.enable = true;
              };
            };
          });
        })

        # Sway Module
        ({ config, lib, pkgs, ... }: {
          options.custom.users = utils.options.mkForEachUser {
            sway.enable = mkEnableOption "Enable sway window manager";
            sway.terminal = mkOption { type = types.str; };
            sway.disableBars = mkOption { type = types.bool; default = false; };
          };

          config.home-manager.users = utils.config.mkForEachUser config (user: {
            home.packages = with pkgs; [ wlogout ];
            wayland.windowManager.sway = {
              inherit (user.sway) enable;
              config = {
                bars = mkIf user.sway.disableBars [];
                menu = "${pkgs.rofi}/bin/rofi -show drun -show-icons -display-drun Launch";
                inherit (user.sway) terminal;
                input."*" = {
                  repeat_delay = "300";
                  xkb_layout = "gb";
                  natural_scroll = "enabled";
                  tap = "enabled";
                };

                gaps = {
                  smartBorders = "on";
                  smartGaps = true;
                  inner = 5;
                };

                keybindings = lib.mkOptionDefault (with config.custom; {
                  "Mod1+Escape" = utils.bash.exec ''fish -c "@logout"'';
                });
              };
            };
          });
        })

        # Waybar Module
        ({ config, lib, pkgs, ... }: let
          # Assume the alacritty, htop, wlogout, and pamixer, fish
          # TODO: Use options instead
          alacrittyCmd = "${pkgs.alacritty}/bin/alacritty --command";
          htop = "${pkgs.htop}/bin/htop";
          rofi = "${pkgs.rofi}/bin/rofi";
          pamixer = "${pkgs.pamixer}/bin/pamixer";
          fish = "${pkgs.fish}/bin/fish";
        in {
          options.custom.users = utils.options.mkForEachUser {
            waybar.enable = mkEnableOption "Marcus' Waybar config";
          };

          config.home-manager.users = utils.config.mkForEachUser config (user: {
            home.packages = [
              pkgs.fish
              pkgs.ripgrep
              pkgs.rofi
            ];

            xdg.configFile."fish/functions/@logout.fish".text = ''
              function @logout
                string join \n \
                  "🪵 Logout (loginctl terminate-user $USER)" \
                  "🔒 Lock (swaylock)" \
                  "🌙 Suspend (systemctl suspend)" \
                  "🧸 Hibernate (systemctl hibernate)" \
                  "🐤 Restart (systemctl reboot)" \
                  "🪓 Shutdown (systemctl poweroff)" \
                  "Do Nothing" | \
                rofi \
                  -dmenu \
                  -p Logout | \
                rg "\((.*)\)" -or '$1' | \
                fish
              end
            '';

            xdg.configFile."fish/functions/@networking.fish".text = ''
              function @networking
                if test (nmcli radio wifi) = "enabled"
                  set wifiOption "✅ Wifi (nmcli radio wifi off)"
                else
                  set wifiOption "❌ Wifi (nmcli networking on && nmcli radio wifi on)"
                end

                if test (nmcli networking) = "enabled"
                  set networkingOption "✅ Networking (nmcli radio wifi off && nmcli networking off)"
                else
                  set networkingOption "❌ Networking (nmcli networking on)"
                end

                set ipAddress "$(nmcli device show | \
                rg 'IP4.ADDRESS.* (([0-9]{1,3}\.){3}[0-9]{1,3})' \
                  --only-matching \
                  --replace '$1' \
                  --max-count 1)"

                set message $ipAddress

                string join \n \
                  "$wifiOption" \
                  "$networkingOption" \
                  "Do Nothing" | \
                rofi \
                  -dmenu \
                  -mesg "$message" \
                  -p Networking | \
                rg "\((.*)\)" -or '$1' | \
                fish
              end
            '';

            programs = mkIf user.waybar.enable {
              waybar = {
                enable = true;
                systemd.enable = true;
                settings.mainBar = {
                  layer = "bottom";
                  position = "top";
                  height = 30;

                  modules-left = [
                    "clock"
                  ];
                  modules-center = [
                    "sway/workspaces"
                    "sway/mode"
                  ];
                  modules-right = [
                    "tray"
                    "network"
                    "cpu"
                    "memory"
                    "temperature"
                    "disk"
                    "battery"
                    "custom/logout"
                  ];

                  tray = {
                    icon-size = 21;
                    spacing = 10;
                  };

                  network = {
                    interval = 5;
                    format-wifi = "{essid} {signalStrength}% {ipaddr}";
                    format-ethernet = "Wired {ipaddr}";
                    format-disconnected = "0.0.0.0";
                    on-click = ''exec ${fish} -c "@networking"'';
                  };

                  cpu = {
                    format = "{usage:03}";
                    interval = 5;
                    on-click = "exec ${alacrittyCmd} ${htop} --sort-key=PERCENT_CPU";
                    states = {
                      warning = 70;
                      critical = 90;
                    };
                  };

                  memory = {
                    interval = 5;
                    format = "{percentage:03}";
                    on-click = "exec ${alacrittyCmd} ${htop} --sort-key=PERCENT_MEM";
                    tooltip-format = "{used:0.1f}/{total:0.1f}GB RAM";
                    states = {
                      warning = 70;
                      critical = 90;
                    };
                  };

                  temperature = {
                    interval = 5;
                    format = "{temperatureC:03}";
                    tooltip-format = "{temperatureC}°C";
                    critical-threshold = 80;
                  };

                  disk = {
                    interval = 60;
                    format = "{percentage_free:03}";
                    tooltip-format = "{used} of {total} SSD";
                    on-click = "exec ${alacrittyCmd} ${htop} --sort-key=IO_RATE";
                  };

                  battery = {
                    format = "{capacity:03}";
                    tooltip-format = "Battery {timeTo}";
                    states = {
                      good = 95;
                      warning = 30;
                      critical = 15;
                    };
                  };

                  "clock" = {
                    tooltip = false;
                    format = "{:%Y-%m-%d %H:%M}";
                  };

                  "custom/logout" = {
                    format = "⏻";
                    tooltip = false;
                    on-click = ''exec ${fish} -c "@logout"'';
                  };
                };

              };
            };
          });
        })

        # End of modules
      ];
    };
  in {
    nixosConfigurations = mapAttrs toNixosSystem {
      inherit marcus-laptop anne-laptop;
    };
  };
}
