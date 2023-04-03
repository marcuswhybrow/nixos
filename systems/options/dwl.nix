{ config, lib, ... }: {
  options.programs.dwl = {
    conf = lib.mkOption { type = with lib.types; nullOr str; default = null; };
  };

  config = lib.mkIf (config.programs.dwl.conf != null) {
    nixpkgs.overlays = [
      (final: prev: {
        dwl = prev.dwl.override {
          inherit (config.programs.dwl) conf;
        };
      })
    ];
  };
}
