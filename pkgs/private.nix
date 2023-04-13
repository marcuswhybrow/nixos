{
  pkgs,
  stdenv,
  makeBinaryWrapper,

  padding ? 20,
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
    Terminal=false
    Type=Application
    Exec=$out/bin/private
    EOF
  '';
}
