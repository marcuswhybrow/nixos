{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-24-05.url = "github:NixOS/nixpkgs/nixos-24.05";

    # Helper to run NixOS under Windows Subsystem for Linux
    nixos-wsl = { 
      url = "github:nix-community/NixOS-WSL"; 
      inputs.nixpkgs.follows = "nixpkgs"; 
    };

    # The Zen Browser package for nixpkgs is experience difficulties but on the 
    # way, in the mean time this flake packages the official binary.
    zen-browser.url = "github:MarceColl/zen-browser-flake";

    # Optimisations for audio
    musnix.url = "github:musnix/musnix";

    # Custom utility packages
    volume.url = "github:marcuswhybrow/volume";
    logout.url = "github:marcuswhybrow/logout";
    networking.url = "github:marcuswhybrow/networking";
    flake-updates.url = "github:marcuswhybrow/flake-updates";
    brightness.url = "github:marcuswhybrow/brightness";
    alarm.url = "github:marcuswhybrow/alarm";
    nprm.url = "github:marcuswhybrow/nprm";

    # Packages themed and customised to Marcus' tastes
    marcus-dunst.url = "github:marcuswhybrow/dunst";
    marcus-fish.url = "github:marcuswhybrow/fish";
    marcus-git.url = "github:marcuswhybrow/git";
    marcus-hyprland.url = "github:marcuswhybrow/hyprland";
    marcus-alacritty.url = "github:marcuswhybrow/alacritty";
    marcus-neovim.url = "github:marcuswhybrow/neovim";
    marcus-private.url = "github:marcuswhybrow/private";
    marcus-starship.url = "github:marcuswhybrow/starship";
    marcus-sway.url = "github:marcuswhybrow/sway";
    marcus-tmux.url = "github:marcuswhybrow/tmux";
    marcus-rofi.url = "github:marcuswhybrow/rofi";
    marcus-waybar.url = "github:marcuswhybrow/waybar";

    # Packages themed and customised for Anne
    anne-sway.url = "github:whybrow/anne-sway"; 
    anne-fish.url = "github:whybrow/anne-fish"; 
  };

  outputs = inputs: let
    specialArgs = { 
      inherit inputs; 
      unstable = import inputs.nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    };

    # Marcus' personal requirements to be included in one or more NixOS systems 
    # defined below.
    marcus = [
      # Account details
      ({ unstable, ...}: {
        users.users.marcus = {
          description = "Marcus Whybrow";
          isNormalUser = true;
          shell = unstable.fish; # don't use custom package here
          extraGroups = [
            "networkmanager"
            "wheel"
            "video"
            "audio"
          ];
        };
      })

      # Nix is moving to a new standard called flakes which makes Nix & NixOS 
      # easier to work with. Although flakes were introduced in 2021 with Nix 
      # 2.4, it's still considered an experimental feature as not all legacy 
      # functionality has a direct replacement when using the newer flakes.
      #
      # However, many people are happy to move over to flakes right now, and 
      # this configuration does require flake support.
      ({ ... }: {
        nix.settings.experimental-features = [ 
          "nix-command" 
          "flakes" 
          "repl-flake" # Useful when developing and debugging flakes
        ];
      })

      # Direnv
      #
      # Direnv automates loading and unloading project dependencies as you 
      # enter and exit the directories of different coding projects.
      #
      # Any project that uses Nix to declare it's depencies will be 
      # automatically detected and loaded (and unloaded) in this fashion.
      #
      # https://github.com/marcuswhybrow/.nixos/issues/6
      # https://github.com/nix-community/nix-direnv
      ({ unstable, ... }: {
        nix.settings = {
          keep-outputs = true;
          keep-derivations = true;
        };
        environment.pathsToLink = [
          "/share/nix-direnv"
        ];
        environment.systemPackages = [
          unstable.direnv
          unstable.nix-direnv
        ];
      })

      # Display backlight support
      ({ unstable, ... }: {
        environment.systemPackages = [
          unstable.light
        ];
        services.udev.packages = [ 
          unstable.light 
        ];
      })

      # Packages on all systems
      ({ unstable, inputs, ... }: {
        users.users.marcus.packages = [
          unstable.htop # Interative process veiwer, like Windows Task Manager
          unstable.lsof # htop requires lsof when you press `l` on a processF
          unstable.firefox # Internet browser
          unstable.brave # Privacy focused internet browser similar to Firefox
          unstable.ranger # Terminal file manager inspired by vim
          unstable.gh # GitHub command line client
          unstable.megacmd # MEGA file storage's command line interface
          unstable.krita # Free photo editor and digital painting app
          unstable.unzip # Unzips .zip files
          unstable.vlc # Video player that supports every video format you need
          unstable.mpv # Simple video player that's command line friendly

          # Zen Browser offers a specific and a generic binary. The specifc 
          # binary is faster but is incompatible with older CPUs.
          inputs.zen-browser.packages.x86_64-linux.generic

          # Command to check if flake inputs have updates
          inputs.flake-updates.packages.x86_64-linux.flake-updates

          # Window Manager configured by Marcus
          inputs.marcus-hyprland.packages.x86_64-linux.hyprland

          # Shell replacement for BASH configured by Marcus
          inputs.marcus-fish.packages.x86_64-linux.fish

          # Graphical terminal configure by Marcus
          inputs.marcus-alacritty.packages.x86_64-linux.alacritty

          # Terminal prompt configured by Marcus
          inputs.marcus-starship.packages.x86_64-linux.starship

          # Powerful terminal text editor configured by Marcus
          inputs.marcus-neovim.packages.x86_64-linux.nvim

          # Graphical menu launcher configured by Marcus
          inputs.marcus-rofi.packages.x86_64-linux.rofi

          # Graphical notification manager configured by Marcus
          inputs.marcus-dunst.packages.x86_64-linux.dunst

          # Graphical logout menu
          inputs.logout.packages.x86_64-linux.logout

          # Graphical ethernet/wifi switcher
          inputs.networking.packages.x86_64-linux.networking

          # Git command configured for Marcus
          inputs.marcus-git.packages.x86_64-linux.git

          # Terminal tabs and windows configured for Marcus
          inputs.marcus-tmux.packages.x86_64-linux.tmux

          # Graphical terminal that doesn't record history
          inputs.marcus-private.packages.x86_64-linux.private

          # Command to send a notification after a specific time
          inputs.alarm.packages.x86_64-linux.alarm

          # Command to change volume in steps
          inputs.volume.packages.x86_64-linux.volume

          # Command to change brightness in steps
          inputs.brightness.packages.x86_64-linux.brightness

          # Fuzzy finder for removing nix profile packages
          inputs.nprm.packages.x86_64-linux.nprm
        ];
      })

      # System dependent packages
      ({ unstable, config, ... }: {
        users.users.marcus.packages = {
          "marcus-laptop" = [
            unstable.reaper # Digital Audio Workstation celebrated for live use
            unstable.discord # Voice, video and text chat
            unstable.obsidian # Markdown based note taking app
          ];
          "marcus-desktop" = [
            unstable.megasync # MEGA cloud storage syncronisation daemon
            unstable.reaper # Digital Audio Workstation celebrated forlive use
            unstable.discord # Voice, video and text chat
            unstable.obsidian # Markdown based note taking app
            unstable.wineWowPackages.waylandFull # Run Windows apps on Linux
            unstable.yabridge # Run Windows VST instruments on Linux
            unstable.yabridgectl # Command line interface for controlling Yabridge
          ];
          "marcus-wsl" = [];
        }."${config.networking.hostName}";
      })
    ];

    # Anne's personal requirements for inclusion in one or more NixOS systems 
    # defined below.
    anne = [
      # Account details
      ({ unstable, ... }: {
        users.users.anne = {
          description = "Anne Whybrow";
          isNormalUser = true;
          extraGroups = [ "networkmanager" "wheel" "video" ];
          shell = unstable.fish; # using custom fish here breaks login
        };
      })

      # Packages Anne wants on all systems 
      ({ unstable, inputs, ...}: {
        users.users.anne.packages = [
          unstable.firefox
          unstable.pcmanfm

          inputs.anne-fish.packages.x86_64-linux.fish
          inputs.anne-sway.packages.x86_64-linux.sway

          inputs.marcus-alacritty.packages.x86_64-linux.alacritty
          inputs.marcus-dunst.packages.x86_64-linux.dunst
        ];
      })

      # Display backlight support
      ({ unstable, ...}: {
        environment.systemPackages = [
          unstable.light
        ];
        services.udev.packages = [ 
          unstable.light 
        ];
      })
    ];
  in {
    # Marcus' black Starlabs Starlite Mk IV laptop
    nixosConfigurations.marcus-laptop = inputs.nixpkgs-24-05.lib.nixosSystem {
      inherit specialArgs;
      modules = marcus ++ [
        # Fix Obsidian not opening with latest electron version
        # https://github.com/NixOS/nixpkgs/issues/263764#issuecomment-1782979513
        ({ ... }: {
          nixpkgs.overlays = [
            (final: prev: {
              obsidian-wayland = prev.obsidian.override { 
                electron = final.electron_24; 
              };
            })
          ];

          nixpkgs.config.permittedInsecurePackages = [
            "electron-24.8.6" # latest version of electron_24 package in nixpkgs
          ];
        })

        # Coding Fonts improve upon normal fonts by including many extra glyphs 
        # that many coding programs and scripts expect to exist.
        # https://nixos.wiki/wiki/Fonts
        ({ unstable, ... }: {
          fonts.packages = [
            unstable.font-awesome
            (unstable.nerdfonts.override {
              fonts = [
                # https://github.com/NixOS/nixpkgs/blob/nixos-22.11/pkgs/data/fonts/nerdfonts/shas.nix
                "FiraCode"
                "FiraMono"
                "Terminus"
              ];
            })
          ];

          fonts.fontconfig.defaultFonts = {
            monospace = [ "FiraCode Nerd Font Mono" ];
          };
        })

        # Disable bluetooth at the kernel level
        # https://discourse.nixos.org/t/how-to-disable-bluetooth/9483
        ({ ... }: {
          hardware.bluetooth.enable = false;
          boot.blacklistedKernelModules = [
            "bluetooth"
            "btusb"
          ];
        })

        # Expose Marcus' home directory as a network SMB share
        # `smbpasswd -a [username]` to add SMB users
        ({ ...}: {
          services.samba = {
            enable = true;
            securityType = "user";
            openFirewall = true;
            extraConfig = ''
              workgroup = WORKGROUP 
              server string = marcus-laptop
              netbios name = marcus-laptop
              security = user 
              guest account = nobody
              map to guest = bad user
            '';
            shares.marcus = {
              path = "/home/marcus";
              browseable = "yes";
              "read only" = "no";
              "guest ok" = "no";
              "create mask" = "0644";
              "directory mask" = "0755";
              "force user" = "marcus";
              "force group" = "users";
            };
          };

          # Advertises shares on the network
          services.samba-wsdd = {
            enable = true;
            openFirewall = true;
          };

          networking.firewall.enable = true;
          networking.firewall.allowPing = true;
        })

        # Mount my Windows desktop via SMB
        # https://nixos.wiki/wiki/Samba
        ({ unstable, ... }: {
          fileSystems."/mnt/marcus-desktop/local" = {
            device = "//192.168.0.23/Local";
            fsType = "cifs"; # Common Internet File System
            options = [ 
              # "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,credentials=/etc/nixos/secrets/marcus-laptop-smb,uid=1000,gid=100"
              (builtins.concatStringsSep "," [
                "x-systemd.automount"
                "noauto"
                "x-systemd.idle-timeout=60"
                "x-systemd.device-timeout=5s"
                "x-systemd.mount-timeout=5s"
                "credentials=/etc/nixos/secrets/marcus-laptop-smb"
                "uid=1000"
                "gid=100"
              ])
            ];
          };

          environment.systemPackages = [
            unstable.cifs-utils # Required for CIFS file systems
          ];

          networking.firewall.extraCommands = (builtins.toString [
            "iptables"
            "-t raw"
            "-A OUTPUT"
            "-p udp"
            "-m udp"
            "--dport 137"
            "-j CT"
            "--helper netbios-ns"
          ]);

          # GNOME Virtual File System
          # Not sure if/why we need this
          services.gvfs.enable = true; 
        })

        # iOS Webkit Debugging 
        # https://jade.fyi/blog/debugging-ios-safari-from-linux
        ({ unstable, ... }: {
          services.usbmuxd.enable = true;
          environment.systemPackages = [ 
            unstable.ios-webkit-debug-proxy 
          ];
        })

        # System wide packages
        ({ unstable, ... }: {
          environment.systemPackages = [
            unstable.vim

            # Networking
            unstable.wget unstable.unixtools.ping

            # Fast rust tools
            unstable.trashy 
            unstable.bat 
            unstable.eza 
            unstable.fd 
            unstable.procs 
            unstable.sd 
            unstable.du-dust 
            unstable.tealdeer 
            unstable.bandwhich
            unstable.ripgrep 
            #pkgs.ripgrep-all

            unstable.lxqt.lxqt-policykit

            # Image editing
            unstable.krita
          ];
        })

        # Localisation
        ({ config, ... }: {
          time.timeZone = "Europe/London";
          i18n.defaultLocale = "en_GB.UTF-8";
          i18n.extraLocaleSettings = {
            "LC_ADDRESS" = config.i18n.defaultLocale;
            "LC_IDENTIFICATION" = config.i18n.defaultLocale;
            "LC_MEASUREMENT" = config.i18n.defaultLocale;
            "LC_MONETARY" = config.i18n.defaultLocale;
            "LC_NAME" = config.i18n.defaultLocale;
            "LC_NUMERIC" = config.i18n.defaultLocale;
            "LC_PAPER" = config.i18n.defaultLocale;
            "LC_TELEPHONE" = config.i18n.defaultLocale;
            "LC_TIME" = config.i18n.defaultLocale;
          };
        })

        # Netowrking
        ({ ... }: {
          networking = {
            hostName = "marcus-laptop";
            networkmanager.enable = true;
          };
          services = {
            openssh.enable = true;
            printing.enable = true;
          };
        })

        # Console 
        ({ ... }: {
          console.keyMap = "uk";
          programs.fish.enable = true;
          security.sudo.wheelNeedsPassword = false;
        })

        # Graphics 
        # The Starlabs Starlite Mk IV has a Pentium Silver N5030 with
        # integrated graphics only.
        ({ unstable, ... }: {
          hardware.opengl = {
            enable = true;
            extraPackages = [
              # The latest intel graphics driver
              unstable.intel-media-driver # iHD

              # Legacy intel graphics driver for older CPUs (like mine)
              unstable.intel-vaapi-driver # i965

              # Helps MPLayer and Flash Player as I understand
              unstable.libvdpau-va-gl

              # Enables Intel Quick Sync Video for hardware video conversions
              # https://nixos.wiki/wiki/Intel_Graphics
              unstable.intel-media-sdk 
            ];
          };

          # Use the legacy intel-vaapi-driver
          environment.sessionVariables = {
            LIBVA_DRIVER_NAME = "i965";
          };
        })

        # Window Manger
        ({ ... }: {
          services.xserver = {
            enable = true;
            autorun = false;
            xkb.layout = "gb";
          };

          programs.hyprland = {
            # Note: Adds Hyprland as an option to the login screen
            enable = true;

            # Fallback to XOrg for programs that don't support Wayland 
            xwayland.enable = true;
          };

          environment.sessionVariables = {
            # WLR_NO_HARDWARE_CURSORS = "1"; # can solve hidden cursor issues
            NIXOS_OZONE_WL = "1"; # encourages electron apps to use wayland
          };

          programs.sway = {
            # Note: Adds Sway as an option to the login screen
            enable = true;
          };
        })

        # Proton VPN 
        # Tip: Control with `systemctl [start|stop|restart] wg-quick-protonvpn`
        # Note: Currently disabled to attempt to save battery life

        # ({ ... }: {
        #   networking.wg-quick.interfaces.protonvpn = {
        #     autostart = true;
        #     address = [ "10.2.0.2/32" ];
        #     dns = [ "10.2.0.1" ];
        #     privateKeyFile = "/etc/nixos/secrets/protonvpn-marcus-laptop-UK-86";
        #     peers = [
        #       {
        #         endpoint = "146.70.179.50:51820";
        #         publicKey = "zctOjv4DH2gzXtLQy86Tp0vnT+PNpMsxecd2vUX/i0U="; # UK#86
        #         allowedIPs = [ "0.0.0.0/0" "::/0" ]; # forward all ip traffic thru
        #       }
        #     ];
        #   };
        # })

        # Power/Performance Management
        ({ ... }: {
          powerManagement = {
            enable = true; # Hibernate and suspend
            powertop.enable = true; # Analysis and auto tune
          };
          services.thermald.enable = true; # Prevents overheating
          services.upower.enable = true; # Battery status monitoring
          services.acpid.enable = true; # Battery events

          # Auto speed and power optimiser I couldn't get to work
          # services.auto-cpufreq = {
          #   enable = false; 
          #   settings.battery = {
          #     governor = "powersave";
          #     turbo = "never";
          #   };
          #   settings.charger = {
          #     governor = "performance";
          #     turbo = "auto";
          #   };
          # };

          # TLP is performance tweaking daemon alternative to auto-cpufreq that some
          # say is the better choice for maximising battery life.
          # It's the only solution I could get working as of 2024-07-15
          services.tlp = {
            enable = true;
            settings = {
              CPU_SCALING_GOVERNOR_ON_AC = "performance";
              CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
              PLATFORM_PROFILE_ON_AC = "performance";
              CPU_BOOST_ON_AC = 1;
              CPU_HWP_DYN_BOOST_ON_AC = 1;

              CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
              CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
              PLATFORM_PROFILE_ON_BAT = "low-power";
              CPU_BOOST_ON_BAT = 0;
              CPU_HWP_DYN_BOOST_ON_BAT = 0;
            };
          };

          # By default closing the lid suspends the system to RAM. However, opening 
          # the lid never resumes, and I'm forced to reboot witht the power button.
          # So for now, I'm ignore this feature.
          services.logind.lidSwitch = "ignore"; 

          # Diables the USB camera which powertop estimated as drawing 20W.
          # I now think this is a severe overestimate, but I cannot diagnose 
          # the true cause of my battery drain issues. Leaving camera disabled 
          # until I figure out the true cause.
          services.udev.extraRules = builtins.concatStringsSep ", " [
            ''SUBSYSTEM=="usb"''
            ''ATTRS{idVendor}=="0c45"''
            ''ATTRS{idProduct}=="6365"''
            ''ATTR{authorized}="0"''
          ];

          # Optimises process priorities to make apps more snappy whilst preserving 
          # battery life
          services.system76-scheduler = {
            enable = true;
            useStockConfig = true;
          };
        })

        # Audio and Music
        ({ ... }: {
          # May improve real time processes
          # Note: Not to be confused with a "Realtime Kernel" which I have 
          # tried in the past, but was not the limiting factor for me in 
          # achieving low latency audio (it was my USB audio interface).
          #
          # The Realtime Kernel is a trades overall computation throughput for 
          # stable computational latencies. Since I don't do any autio work 
          # on this latop, a Realtime Kernel would be a mistake.
          security.rtkit.enable = true; 

          # Linux audio is a battleground of competing standards. Pipewire is 
          # the latest solution which emulates all previous standards such as 
          # ALSA, Jack, & PulseAudio. Each standard has different trade offs,
          # and some programs may only support one of those standards.
          services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            jack.enable = true;
            pulse.enable = true;
          };
        })

        # NixOS Low-Level settings
        ({ ... }: {
          # This is the NixOS version used to *create* the first generation of 
          # of this NixOS system. It is not the NixOS version of the current 
          # generation.
          system.stateVersion = "22.11";

          # The CPU architecture for this computer: Intel (x86) 64bit
          nixpkgs.hostPlatform = "x86_64-linux";

          # Allows closed source programs such as Discord to be installed
          nixpkgs.config.allowUnfree = true;
        })

        # Encrypted Root & Swap + Unencrypted Bootloader
        ({ ... }: {
          # The encryption key was created by the NixOS install wizard
          boot.initrd.secrets = { "/crypto_keyfile.bin" = null; };

          # The root filesystem is encrypted using the above key
          boot.initrd.luks.devices.root.device = "/dev/sda2";
          fileSystems."/" = { device = "/dev/mapper/root"; fsType = "ext4"; };

          # I also chose to have a Swap partition. A Swap partition is a 
          # dedicated space for offloading data in RAM to the (slower) SSD.
          # Some say this is no longer needed with todays system. But I wasn't 
          # sure and stuck with the old approach of having a Swap partition.
          # 
          # The swap partition is also encrypted with the above key
          boot.initrd.luks.devices.swap = {
            device = "/dev/sda3";
            keyFile = "/crypto_keyfile.bin";
          };
          swapDevices = [ { device = "/dev/mapper/swap"; } ];

          # Modern CPUs have dedcicated instructions for encryption 
          # calculations. Enabling those kernel modules speeds up filesystem 
          # encryption (handled by LUKS) to the point where they say there is 
          # little if any performance cost to using encryption.
          boot.initrd.availableKernelModules = [
            "aesni_intel"
            "cryptd"
          ];

          # The boot loader is not encrypted
          fileSystems."/boot/efi" = { device = "/dev/sda1"; fsType = "vfat"; };
          boot.loader = {
            systemd-boot.enable = true;
            efi.efiSysMountPoint = "/boot/efi";
            efi.canTouchEfiVariables = true;
          };
        })

        # CPU specific config: Intel Pentium Silver N5030
        ({ ... }: {
          hardware.enableRedistributableFirmware = true;
          hardware.cpu.intel = {
            updateMicrocode = true;
            sgx.provision.enable = true; 
          };
        })

        # Kernel modules chosen by the Nixos install wizard
        ({ ... }: {
          boot.initrd.availableKernelModules = [
            "ahci"
            "xhci_pci"
            "usb_storage"
            "sd_mod"
            "rtsx_usb_sdmmc"
          ];
          boot.kernelModules = [ "kvm-intel" ];
        })
      ];
    };

    # Marcus' Windows Subsystem for Linux inside his Windows desktop
    nixosConfigurations.marcus-wsl = inputs.nixpkgs-24-05.lib.nixosSystem {
      inherit specialArgs;
      modules = marcus ++ [
        # Coding Fonts improve upon normal fonts by including many extra glyphs 
        # that many coding programs and scripts expect to exist.
        # https://nixos.wiki/wiki/Fonts
        ({ unstable, ... }: {
          fonts.packages = [
            unstable.font-awesome
            (unstable.nerdfonts.override {
              fonts = [
                # https://github.com/NixOS/nixpkgs/blob/nixos-22.11/pkgs/data/fonts/nerdfonts/shas.nix
                "FiraCode"
                "FiraMono"
                "Terminus"
              ];
            })
          ];

          fonts.fontconfig.defaultFonts = {
            monospace = [ "FiraCode Nerd Font Mono" ];
          };
        })

        # Allow SSH remote control
        ({ ... }: {
          services.openssh.enable = true;
        })

        # Localisation
        ({ config, ... }: {
          time.timeZone = "Europe/London";
          i18n.defaultLocale = "en_GB.UTF-8";
          i18n.extraLocaleSettings = {
            "LC_ADDRESS" = config.i18n.defaultLocale;
            "LC_IDENTIFICATION" = config.i18n.defaultLocale;
            "LC_MEASUREMENT" = config.i18n.defaultLocale;
            "LC_MONETARY" = config.i18n.defaultLocale;
            "LC_NAME" = config.i18n.defaultLocale;
            "LC_PAPER" = config.i18n.defaultLocale;
            "LC_TELEPHONE" = config.i18n.defaultLocale;

            # These two were causing an error for some reason I couldn't 
            # diagnose, so I just don't set them for WSL
            # "LC_NUMERIC" = config.i18n.defaultLocale;
            # "LC_TIME" = config.i18n.defaultLocale;
          };
        })

        # Console
        ({ ... }: {
          console.keyMap = "uk";
          programs.fish.enable = true;
          security.sudo.wheelNeedsPassword = false;
        })

        # NixOS specific config
        ({ ... }: {
          # This is the NixOS version used to create the first generation,
          # not the NixOS version of the current generation.
          system.stateVersion = "23.11";

          # Intel (x86) 64bit architecture
          nixpkgs.hostPlatform = "x86_64-linux";

          # Required to allow installing closed source programs such as Discord
          nixpkgs.config.allowUnfree = true;
        })

        # Windows Subsystem for Linux specific settings
        # It takes care of all the filesystem and kernel stuff you'd usually
        # have to declare for a normal system.
        ({ ... }: {
          wsl = {
            enable = true;
            defaultUser = "marcus";
            startMenuLaunchers = true;
            nativeSystemd = true;
            # useWindowsDriver = true; # Windows OpenGL driver
          };
        })

        {
          networking.hostName = "marcus-wsl";
        }

        # This third-party module enables NixOS to work inside of the 
        # Windows Subsystem for Linux
        inputs.nixos-wsl.nixosModules.wsl
      ];
    };

    # Anne's laptop for getting used to using laptops.
    #
    # Note: This computer is now no longer serving this purpose, and therefore 
    # this NixOS configuration is no longer being updated. Keeping the config 
    # around for potential future use.
    nixosConfigurations.anne-laptop = inputs.nixpkgs-24-05.lib.nixosSystem {
      inherit specialArgs;
      modules = marcus ++ anne ++ [
        # System wide packages
        ({ unstable, ... }: {
          environment.systemPackages = [ unstable.vim ];
        })

        # Auto login 
        ({ ... }: {
          services.getty.autologinUser = "anne";
        })

        # Localisation
        ({ config, ... }: {
          time.timeZone = "Europe/London";
          i18n.defaultLocale = "en_GB.UTF-8";
          i18n.extraLocaleSettings = {
            "LC_ADDRESS" = config.i18n.defaultLocale;
            "LC_IDENTIFICATION" = config.i18n.defaultLocale;
            "LC_MEASUREMENT" = config.i18n.defaultLocale;
            "LC_MONETARY" = config.i18n.defaultLocale;
            "LC_NAME" = config.i18n.defaultLocale;
            "LC_NUMERIC" = config.i18n.defaultLocale;
            "LC_PAPER" = config.i18n.defaultLocale;
            "LC_TELEPHONE" = config.i18n.defaultLocale;
            "LC_TIME" = config.i18n.defaultLocale;
          };

        })

        # Console
        ({ ... }: {
          console.keyMap = "uk";
        })

        # Window Manager
        ({ ... }: {
          services.xserver = {
            enable = true;
            autorun = false;
            layout = "gb";
          };
        })

        # Graphics 
        # The Dell Vostro 1700 has a discrete graphics card. Either the nVIDIA 
        # GeForce 8400M GS or the nVIDIA GeForce 8600M GT.
        # The processor is an Intel Core 2 Duo without integrated graphics.
        #
        # Note: We probably want nVIDIA specific graphics drivers here. But 
        # these drivers seemed to be working nonetheless.
        ({ unstable, ... }: {
          hardware.opengl = {
            enable = true;
            extraPackages = [
              # The latest intel graphics driver
              unstable.intel-media-driver # iHD

              # Legacy intel graphics driver for older CPUs (like mine)
              unstable.intel-vaapi-driver # i965

              # Helps MPLayer and Flash Player as I understand
              unstable.libvdpau-va-gl

              # Enables Intel Quick Sync Video for hardware video conversions
              # https://nixos.wiki/wiki/Intel_Graphics
              unstable.intel-media-sdk 
            ];
          };
          environment.sessionVariables = {
            LIBVA_DRIVER_NAME = "i965";
          };
        })

        # Audio
        ({ ... }: {
          # Pipewire is the modern solution that is able to emulate all 
          # previous Linux audio standards, including ALSA, Jack & PulseAudio.
          config.services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
          };

          # Some audio processes may request realtime scheduling.
          # Note: this is not the same as a Real Time Kernel.
          config.security.rtkit.enable = true;
        })

        # Netowrking 
        ({ ... }: {
          networking = {
            enable = true;
            hostName = "anne-laptop";
            networkmanager.enable = true;
          };
          services = {
            openssh.enable = true; # Remote console access over network
            printing.enable = true; # Network printing
          };
        })

        # NixOS Low Level settings
        ({ ... }: {
          # This is the NixOS verion used to create the first generation, not 
          # the NixOS version of the current generation.
          system.stateVersion = "22.11";

          # Intel (x86) 64bit architecture
          nixpkgs.hostPlatform = "x86_64-linux";

          # Required to install closed-source software such as Discord
          nixpkgs.config.allowUnfree = true;
        })

        # CPU specific config for Intel Core 2 Duo
        ({ ... }: {
          hardware.enableRedistributableFirmware = true;
          hardware.cpu.intel = {
            updateMicrocode = true;
            sgx.provision.enable = true; 
          };
        })

        # Unencrypted Root, Boot & Swap 
        # 
        # This computer has a CPU that doesn't support the more modern 
        # encryption instructions that make file system encryption perform 
        # very well. That and I didn't want users of this computer to have to 
        # remeber an encryption password.
        ({ ... }: {
          # The main file system is unencrypted
          fileSystems."/" = { 
            # SDA1 is a partition created by the NixOS install wizard
            device = "/dev/sda1"; 

            # EXT4 is a modern filesystem format recommended for general use.
            fsType = "ext4"; 
          };

          # Decided to use a Swap partition. This is a dedicated space for 
          # offloading data in RAM to improve performance. Some say a Swap 
          # partition is old hat, but I wasn't sure so stuck with the old ways.
          #
          # The swap partition is also unencrypted
          swapDevices = [ 
            # SDA2 is a partition created by the NixOS install wizard
            { device = "/dev/sda2"; } 
          ];

          # The boot partition is also unencrypted
          boot.loader.grub = {
            enable = true;

            # The boot partition created by the NixOS install wizard
            device = "/dev/sda"; 
 
            # Not sure what this does
            useOSProber = true;
          };

          # Not sure what this does`
          boot.plymouth.enable = false;
        })

        # Kernel modules chosen by the NixOS install wizard for this system
        ({ ... }: {
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
          boot.initrd.kernelModules = [ 
            "kvm-intel" 
          ];
        })
      ];
    };

    # Marcus' Live Audio Computer
    # 
    # Note: This system is currently back running Windows and therefore this
    # NixOS config for it is not longer in use and not maintained. The 
    # configuration is being preserved for potential future use.
    nixosConfigurations.marcus-desktop = inputs.nixpkgs-24-05.lib.nixosSystem {
      inherit specialArgs;
      modules = marcus ++ [
        inputs.musnix.nixosModules.musnix

        # Coding Fonts improve upon normal fonts by including many extra glyphs 
        # that many coding programs and scripts expect to exist.
        # https://nixos.wiki/wiki/Fonts
        ({ unstable, ... }: {
          fonts.packages = [
            unstable.font-awesome
            (unstable.nerdfonts.override {
              fonts = [
                # https://github.com/NixOS/nixpkgs/blob/nixos-22.11/pkgs/data/fonts/nerdfonts/shas.nix
                "FiraCode"
                "FiraMono"
                "Terminus"
              ];
            })
          ];

          fonts.fontconfig.defaultFonts = {
            monospace = [ "FiraCode Nerd Font Mono" ];
          };
        })

        # Localisation
        ({ config, ... }: {
          time.timeZone = "Europe/London";
          i18n.defaultLocale = "en_GB.UTF-8";
          i18n.extraLocaleSettings = {
            "LC_ADDRESS" = config.i18n.defaultLocale;
            "LC_IDENTIFICATION" = config.i18n.defaultLocale;
            "LC_MEASUREMENT" = config.i18n.defaultLocale;
            "LC_MONETARY" = config.i18n.defaultLocale;
            "LC_NAME" = config.i18n.defaultLocale;
            "LC_NUMERIC" = config.i18n.defaultLocale;
            "LC_PAPER" = config.i18n.defaultLocale;
            "LC_TELEPHONE" = config.i18n.defaultLocale;
            "LC_TIME" = config.i18n.defaultLocale;
          };
        })

        # Console
        ({ ... }: {
          console.keyMap = "uk";
          programs.fish.enable = true;
          security.sudo.wheelNeedsPassword = false;
        })

        # Audio 
        ({ ... }: {
          sound.enable = true;

          # MusNix makes drastic changes to the way processes are scheduled
          # to run on the CPU. It reduces overall computing throughput to 
          # achieve reliable latencies by replacing the Linux Kernel with a 
          # "Real Time" Linux Kernel. This is a questionable choice even for 
          # latency sensitive applications like live audio, and requires much 
          # comparitive testing to determine the best results for any 
          # application.
          musnix = {
            enable = true;
            alsaSeq.enable = true;
            ffado.enable = false; # firewire support
            soundcardPciId = "07:00.6"; # [AMD] Family 17h/19h HD Audio Controller
            kernel.realtime = false;
            das_watchdog.enable = true;
          };

          # Not sure if this is necessary
          hardware.pulseaudio.enable = false;

          # Allows processes to request real time scheduling
          security.rtkit.enable = true;

          # Pipewire is the modern Linux audio standard that emulates all the 
          # existing standards such as ALSA, Jack & PulseAudio.
          services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            jack.enable = true;
          };
        })

        # Window Manager
        ({ ... }: {
          services.xserver = {
            enable = true;
            layout = "gb";
            autorun = true;
            xkbVariant = "";
            displayManager.gdm.enable = true;
            desktopManager.gnome.enable = true;
            # videoDrivers = [ "amdgpu" ];
          };

          programs.hyprland = {
            enable = true;
            enableNvidiaPatches = true;
            xwayland.enable = true;
          };

          environment.sessionVariables = {
            # WLR_NO_HARDWARE_CURSORS = "1"; # can solve hidden cursor issues
            NIXOS_OZONE_WL = "1"; # encourages electron apps to use wayland
          };
        })

        # Graphics
        #
        # This probably needs to add graphics drivers for better performance.
        # See other systems in this flake for examples.
        ({ ... }: {
          hardware.opengl.enable = true;
        })

        # Networking
        ({ lib,  ... }: {
          networking = {
            hostName = "marcus-desktop";
            useDHCP = lib.mkDefault true;
            networkmanager.enable = true;
          };
          services = {
            printing.enable = true; 
            openssh.enable = true;
          };
        })

        # # Proton VPN support
        # ({ ... }: {
        #   networking.wg-quick.interfaces.protonvpn = {
        #     autostart = true;
        #     address = [ "10.2.0.2/32" ];
        #     dns = [ "10.2.0.1" ];
        #     privateKeyFile = "/etc/nixos/secrets/protonvpn-marcus-laptop-UK-86";
        #     peers = [
        #       {
        #         endpoint = "146.70.179.50:51820";
        #         publicKey = "zctOjv4DH2gzXtLQy86Tp0vnT+PNpMsxecd2vUX/i0U="; # UK#86
        #         allowedIPs = [ "0.0.0.0/0" "::/0" ]; # forward all ip traffic thru
        #       }
        #     ];
        #   };
        # })

        # NixOS Low Level config
        ({ ... }: {
          # This is the NixOS version used to create the first generation, not 
          # the NixOS version used in the current generation
          system.stateVersion = "23.11";

          # Intel (x86) 64 bit architecture
          nixpkgs.hostPlatform = "x86_64-linux";

          # Required to install closed-source programs such as Discord
          nixpkgs.config.allowUnfree = true;
        })

        # Kernel Modules chosen by the NixOS install wizard for this system
        ({ config, ... }: {
          boot.initrd.availableKernelModules = [
            "ahci"
            "xhci_pci"
            "nvme"
            "usbhid"
            "usb_storage"
            "sd_mod"
          ];
          boot.kernelModules = [ 
            "kvm-amd" 
            "wl" 
            # "amdgpu"
          ];
          boot.extraModulePackages = [ 
            config.boot.kernelPackages.broadcom_sta 
          ];
        })

        # CPU specific config for AMD Ryzen 5
        ({ lib, ... }: {
          hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
          hardware.enableRedistributableFirmware = true;
        })

        # Unencrypted Boot, Root, Swap & Storage
        ({ ... }: {
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          # The main partition created by the NixOS install wizard
          fileSystems."/" = {
            device = "/dev/disk/by-uuid/e0466cb8-19af-45d7-b9bb-948f48d924ac";
            fsType = "ext4";
          };

          # The boot partition created by the NixOS install wizard
          fileSystems."/boot" = { 
            device = "/dev/disk/by-uuid/B13C-CFE9";
            fsType = "vfat";
          };

          # An existing ex-Windows storage hard drive 
          fileSystems."/storage" = {
            device = "/dev/disk/by-label/Storage"; # nvme0n1p2
            fsType = "ntfs";
          };

          # Decided to not use a Swap parition, as some say that modern systems 
          # no longer require one. 
          swapDevices = [];
        })
      ];
    };

  };
}
