{
  pkgs,
  lib, 
  makeBinaryWrapper,

  beforeNeovimOpens ? "",
  afterNeovimCloses ? "",
  vimAlias ? false,
}: let
  xdgConfig = pkgs.stdenv.mkDerivation {
    name = "neovim-config";
    src = ./lua;

    installPhase = ''
      mkdir --parents $out/nvim/lua
      cp --recursive userconfig $out/nvim/lua
      echo 'require("userconfig")' > $out/nvim/init.lua
    '';
  };

  neovim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped (pkgs.neovimUtils.makeNeovimConfig {
    # https://github.com/NixOS/nixpkgs/blob/db24d86dd8a4769c50d6b7295e81aa280cd93f35/pkgs/applications/editors/neovim/utils.nix#L24
    withPython3 = false; # defaults to true
    extraPython3Packages = _: [ ];
    withNodeJs = false;
    withRuby = false; # defaults to true
    extraLuaPackages = _: [];
    customRC = '''';

    plugins = with pkgs.vimPlugins; [
      telescope-fzf-native-nvim
      nvim-web-devicons
      plenary-nvim
      telescope-nvim
      (nvim-treesitter.withPlugins (p: with p; [
        nix
        go
        rust
        bash
        fish
      ]))
      nvim-lspconfig
      (pkgs.vimUtils.buildVimPluginFrom2Nix {
        pname = "lsp-zero-nvim";
        version = "2.x";
        src = pkgs.fetchFromGitHub {
          owner = "VonHeikemen";
          repo = "lsp-zero.nvim";
          rev = "eb278c30b6c50e99fdfde52f7da0e0ff8d17c07e";
          sha256 = "sha256-C2LvhoNdNXRyG+COqVZv/BcUh6y82tajXipsqdySJJQ=";
        };
      })
      vim-nix
      lualine-nvim
      (pkgs.vimUtils.buildVimPluginFrom2Nix rec {
        pname = "github-nvim-theme";
        version = "0.0.7";
        src = pkgs.fetchFromGitHub {
          owner = "projekt0n";
          repo = pname;
          rev = "v${version}";
          sha256 = "sha256-Qm9ffdkHfG5+PLQ8PbOeFMywBbKVGqX8886clQbJzyg=";
        };
      })
      harpoon
      undotree
      vim-fugitive
      cmp-nvim-lsp
      cmp-nvim-lua
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp-cmdline-history
      nvim-cmp
      cmp-git
      gitsigns-nvim
    ];

    # https://github.com/NixOS/nixpkgs/blob/db24d86dd8a4769c50d6b7295e81aa280cd93f35/pkgs/applications/editors/neovim/wrapper.nix#L13
    extraName = "";
    withPython2 = false;
    vimAlias = false; # doing this manually in builder
    viAlias = false;
    wrapRc = false;
    neovimRcContent = "";
  });

  wrapperScript = pkgs.writeShellScript "neovim" ''
    ${beforeNeovimOpens}
    ${neovim}/bin/nvim "$@"
    ${afterNeovimCloses}
  '';
in pkgs.runCommand "neovim" {
  nativeBuildInputs = [ makeBinaryWrapper ];
} ''
  mkdir -p $out
  ln -s ${neovim}/* $out

  rm $out/bin
  mkdir $out/bin
  ln -s ${neovim}/bin/* $out/bin

  rm $out/bin/nvim
  makeWrapper ${wrapperScript} $out/bin/neovim \
    --set XDG_CONFIG_HOME ${xdgConfig} \
    --suffix PATH : ${lib.makeBinPath (with pkgs; [
      nil
      gopls
      nodePackages.bash-language-server
      nodePackages.vscode-langservers-extracted # html css json eslint
      nodePackages.yaml-language-server
      rust-analyzer
      marksman # markdown
      # https://github.com/hangyav/textLSP has no package
    ])}

  ${if vimAlias then "ln -s $out/bin/neovim $out/bin/vim" else ""}
''
