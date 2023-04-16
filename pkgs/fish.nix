{
  pkgs,
  lib,
  symlinkJoin,

  init ? "",
  functions ? {}, 
}: symlinkJoin {
  name = "fish";
  paths = [
    pkgs.fish
    (pkgs.writeTextDir "share/fish/vendor_conf.d/config.fish" init)
  ] ++ (lib.mapAttrsToList
    (name: def: pkgs.writeTextDir "share/fish/vendor_functions.d/${name}.fish" ''
      function ${name}
        ${def}
      end
    '')
    functions
  );
}
