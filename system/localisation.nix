{ config, lib, pkgs, ... }: let
  inherit (lib) mkOption types filter stringToCharacters;
  inherit (builtins) map listToAttrs;
  cfg = config.custom.localisation;

  # https://github.com/NixOS/nixpkgs/blob/da26ae9f6ce2c9ab380c0f394488892616fc5a6a/nixos/modules/config/locale.nix#L8
  nospace = str: filter (c: c == " ") (stringToCharacters str) == [];
  timezone = with types; nullOr (addCheck str nospace);

  localeForAll = list: listToAttrs (map (name: {
    name = "LC_${name}";
    value = cfg.locale;
  }) list);
in {
  options.custom.localisation = {
    timeZone = mkOption { type = timezone; };
    locale = mkOption { type = types.str; };
    keyMap = mkOption { type = types.str; };
    layout = mkOption { type = types.str; };
  };

  config = {
    time.timeZone = cfg.timeZone;
    i18n.defaultLocale = cfg.locale;
    i18n.extraLocaleSettings = localeForAll [
      "ADDRESS"
      "IDENTIFICATION"
      "MEASUREMENT"
      "MONETARY"
      "NAME"
      "NUMERIC"
      "PAPER"
      "TELEPHONE"
      "TIME"
    ];
    console.keyMap = cfg.keyMap;
    services.xserver.layout = cfg.layout;
  };
}
