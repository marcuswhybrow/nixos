{ pkgs, ... }: {
  # https://nixos.wiki/wiki/Fonts
  fonts.packages = with pkgs; [
    font-awesome

    (nerdfonts.override {
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

}
