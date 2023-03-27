{ config, pkgs, ... }: {

  config = {
    customModule.bar = {
      enable = true;
      user = "marcus";
    };

    programs.fish.enable = true;

    services.xserver = {
      layout = "gb";
      xkbVariant = "";
    };
    console.keyMap = "uk";

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

  };

}
