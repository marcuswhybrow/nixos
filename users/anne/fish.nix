{
  pkgs,

}: pkgs.callPackage ../../pkgs/fish.nix {
  init = ''
    if status is-login
      ${pkgs.anne.sway}/bin/sway
    end

    if status is-interactive
      ${pkgs.custom.starship}/bin/starship init fish | source
    end
  '';

}
