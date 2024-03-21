{
  # Fix Obsidian not opening with latest electron version
  # https://github.com/NixOS/nixpkgs/issues/263764#issuecomment-1782979513

  nixpkgs.overlays = [
    (final: prev: {
      obsidian-wayland = prev.obsidian.override { electron = final.electron_24; };
    })
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-24.8.6" # latest version of electron_24 package in nixpkgs
  ];
}
