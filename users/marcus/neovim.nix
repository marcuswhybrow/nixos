{
  pkgs,
  padding ? 20,

}: pkgs.callPackage ../../pkgs/neovim/default.nix {
  vimAlias = true;
  beforeNeovimOpens = ''
     ${pkgs.alacritty}/bin/alacritty msg config \
      window.padding.x=0 \
      window.padding.y=0
    ${pkgs.wtype}/bin/wtype -M ctrl 0
  '';
  afterNeovimCloses = ''
    ${pkgs.alacritty}/bin/alacritty msg config \
      window.padding.x=${toString padding} \
      window.padding.y=${toString padding}
    ${pkgs.wtype}/bin/wtype -M ctrl 0
  '';
}
