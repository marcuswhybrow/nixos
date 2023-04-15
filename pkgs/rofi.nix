{
  stdenv,
  pkgs,
  makeBinaryWrapper,
  makeWrapper,

  borderWidth ? 4,
  borderColor ? "#000000",
  selectionColor ? "#000000",
}: stdenv.mkDerivation {
  pname = "rofi";
  version = "unstable";
  src = ./.;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = let
    config = pkgs.writeText "config.rasi" ''
      configuration {
        location: 0;
        xoffset: 0;
        yoffset: 0;
      }

      @theme "${theme}"
    '';

    theme = pkgs.writeText "theme.rasi" ''
      * {
        font: "FiraCode-Nerd-Font 12";
        spacing: 0px;
        margin: 0px;
        padding: 0px;
      }

      window {
        location: south;
        transparency: "real";
        background-color: transparent;
        width: 100%;
        margin: 100px; 
        spacing: 20px;
        children: [ horibox ];
      }

      horibox {
        orientation: horizontal;
        children: [ entry, listview ];
        background-color: #ffffff;
        border-color: ${borderColor};
        border: ${toString borderWidth}px;
        border-radius: ${toString borderWidth}px;
        padding: 24px 20px;
        spacing: 10px;
      }

      prompt {
        text-color: #000000;
        spacing: 0px;
      }

      entry {
        placeholder: "Filter...";
        placeholder-color: #888888;
        expand: false;
        width: 10em;
      }

      listview {
        layout: horizontal;
        spacing: 10px;
      }

      element {
        text-color: #888888;
        spacing: 10px;
        padding: 0;
      }

      element-icon {
        size: 1em;
        background-color: transparent;
      }

      element-text {
        text-color: inherit;
        background-color: transparent;
      }

      element normal urgent {
        text-color: #ff0000;
      }

      element normal active {
        text-color: #0000ff;
      }

      element selected {
        text-color: ${selectionColor};
      }

      element selected normal {}
      element selected urgent {}
      element selected active {}
    '';
  in ''
    mkdir -p $out/bin
    cp -r ${pkgs.rofi}/* $out
    rm $out/bin/rofi
    makeWrapper ${pkgs.rofi}/bin/rofi $out/bin/rofi \
      --add-flags "-config ${config}"
  '';
}
