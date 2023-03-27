{ config, pkgs, ... }: {

  config = {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    programs.light.enable = true;

    customModule.bar = {
      enable = true;
      user = "marcus";
    };

    services.xserver.enable = true;
    services.xserver.autorun = false;

    # services.xserver.displayManager.gdm.enable = true;
    # services.xserver.desktopManager.gnome.enable = true;

    # services.xserver.displayManager.lightdm.enable = true;

    programs.fish.enable = true;

    services.xserver = {
      layout = "gb";
      xkbVariant = "";
    };
    console.keyMap = "uk";
    services.printing.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    security.sudo.wheelNeedsPassword = false;
    users.users.marcus = {
      isNormalUser = true;
      description = "Marcus Whybrow";
      extraGroups = [ "networkmanager" "wheel" "video" ];
      shell = pkgs.fish;
      packages = with pkgs; [
        firefox
      #  thunderbird
      ];
    };

    # Enable automatic login for the user.
    #services.xserver.displayManager.autoLogin.enable = true;
    #services.xserver.displayManager.autoLogin.user = "marcus";
  
    # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
    #systemd.services."getty@tty1".enable = false;
    #systemd.services."autovt@tty1".enable = false;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
       neovim
       git
       gh

       fish
       wget
       unixtools.ping
       pamixer
       wlogout

       trashy
       bat
       exa
       fd
       procs
       sd
       du-dust
       ripgrep
       ripgrep-all
       tealdeer
       bandwhich
       delta

       coreboot-configurator
       # megasync
    ];

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "22.11"; # Did you read the comment?
  };

}
