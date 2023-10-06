{
  pkgs,

}: pkgs.callPackage ../../pkgs/git.nix {
  overrideConfig = ''
    [core]
      editor = vim
      pager = ${pkgs.delta}/bin/delta

    [credential "https://github.com"]
      helper = gh auth git-credential

    [delta]
      light = true
      navigate = true

    [diff]
      colorMoved = default

    [merge]
      conflictstyle = diff3

    [interactive]
      diffFilter = ${pkgs.delta}/bin/delta --color-only

    [user]
      name = "Marcus Whybrow"
      email = "marcus@whybrow.uk"

    [init]
      defaultBranch = "main"
  '';
}
