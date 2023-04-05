{ stdenv, pkgs }: stdenv.mkDerivation {
  pname = "toggle";
  version = "unstable";
  src = ./.;
  installPhase = let
    script = pkgs.writeShellScriptBin "toggle" ''
      command=$(systemctl --user is-active $1 > /dev/null && echo "stop" || echo "start")
      systemctl --user $command $1
    '';
  in ''
    mkdir $out;
    cp -r ${script}/* $out
  '';
}
