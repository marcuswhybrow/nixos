{
  pkgs,
  stdenv,
  makeBinaryWrapper,

  padding ? 0,
  opacity ? 1,
  fish ? pkgs.fish,
}: let
  alacrittyConfig = let
    font = "FiraCode Nerd Font";
  in pkgs.writeText "alacritty.yml" ''
    window:
      padding:
        x: ${toString padding}
        y: ${toString padding}
      opacity: ${toString opacity}
    font:
      normal:
        family: ${font}
        style: 'Regular'
      bold:
        family: ${font}
        style: 'Bold'
      italic:
        family: ${font}
        style: 'Light'
  '';
        /*
      primary:
        background: '0xffffff'
        foreground: '0x000000'
      normal:
        white: '0xbbbbbb'
        black: '0x000000'
        red: '0xde3d35'
        green: '0x3e953a'
        yellow: '0xd2b67b'
        blue: '0x2f5af3'
        magenta: '0xa00095'
        cyan: '0x3e953a'
      bright:
        white: '0xffffff'
        black: '0x000000'
        red: '0xde3d35'
        green: '0x3e953a'
        yellow: '0xd2b67b'
        blue: '0x2f5af3'
        magenta: '0xa00095'
        cyan: '0x3e953a'
        */
in stdenv.mkDerivation {
  pname = "private";
  version = "unstable";
  src = ./.;

  nativeBuildInputs = [ makeBinaryWrapper ];
  installPhase = ''
    mkdir -p $out/bin

    makeWrapper ${pkgs.alacritty}/bin/alacritty $out/bin/private \
      --add-flags "\
        --config-file ${alacrittyConfig} \
        --command ${fish}/bin/fish --private"

    mkdir -p $out/share/applications

    cat > $out/share/applications/private.desktop << EOF
    [Desktop Entry]
    Version=1.0
    Name=Private
    GenericName=Private fish shell with dark Alacritty theme
    Terminal=true
    Type=Application
    Exec=$out/bin/private
    EOF
  '';
}
