[
  ({ hostname, lib, ... }: {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    networking = {
      useDHCP = lib.mkDefault true;
      hostName = hostname; 
      networkmanager.enable = lib.mkDefault true;
      firewall.enable = lib.mkDefault true;
    };
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  })
]
