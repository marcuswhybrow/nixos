lib: let
  inherit (builtins) toString replaceStrings mapAttrs removeAttrs foldl' attrNames listToAttrs map;
  inherit (lib.attrsets) mapAttrsToList recursiveUpdate;
  inherit (lib) mkOption types;
in {
  options = {
    mkStr = default: mkOption {
      type = types.str;
      inherit default;
    };
    mkNullStr = mkOption {
      type = with types; nullOr str;
    };
    mkInt = default: mkOption {
      type = types.int;
      inherit default;
    };
    mkAttrs = default: mkOption {
      type = types.attrs;
      inherit default;
    };
    mkTrue = mkOption {
      type = types.bool;
      default = true;
    };
    mkEnum = default: options: mkOption {
      type = types.enum options;
      inherit default;
    };
  };

  config = {
    localeForAll = locale: listToAttrs (map (name: {
      name = "LC_${name}";
      value = locale;
    }) [
      "ADDRESS"
      "IDENTIFICATION"
      "MEASUREMENT"
      "MONETARY"
      "NAME"
      "NUMERIC"
      "PAPER"
      "TELEPHONE"
      "TIME"
    ]);
  };

  homeManager = config: f: mapAttrs f config.home-manager.users;

  system = c: { config = c; };

  attrs = rec {
    merge = list: foldl' recursiveUpdate {} list;

    mapAttrsToListAndMerge = f: attrs: merge (mapAttrsToList f attrs);

    remapAttrs = attrs: remaps: (let
      base = removeAttrs attrs (attrNames remaps);
      results = merge (mapAttrsToList (attrName: remapFn: remapFn attrs.${attrName}) remaps);
    in recursiveUpdate base results);
  };
}
