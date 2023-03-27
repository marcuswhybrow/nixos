{ config, pkgs, ... }: {

  config = {
    programs.light.enable = true;

    customModule.bar = {
      enable = true;
      user = "marcus";
    };

    services.xserver.enable = true;
    services.xserver.autorun = false;

    programs.fish.enable = true;

    services.xserver = {
      layout = "gb";
      xkbVariant = "";
    };
    console.keyMap = "uk";
    services.printing.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

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

  };

}
