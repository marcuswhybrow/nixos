lib: let
  inherit (builtins) toString replaceStrings mapAttrs removeAttrs foldl' attrNames listToAttrs map;
  inherit (lib.attrsets) mapAttrsToList recursiveUpdate;
  inherit (lib) mkOption types;
in {

  bash = rec {
    test = { test, onPass, onFail }: ''$([ ${test} ] && echo ${toString onPass} || echo "${toString onFail}")'';

    switch = expression: cases: default: let
      casesStr = toString (mapAttrsToList (name: value: ''${toString name}) echo ${toString value};;'') cases);
      defaultCaseStr = ''*) echo ${toString default};;'';
    in ''$(case $(${expression}) in ${casesStr} ${defaultCaseStr} esac)'';

    smartStep = command: step: switch command { "0" = 1; "1" = step - 1; } step;

    escapeDoubleQuotes = anything: replaceStrings [ ''"'' ] [ ''\"'' ] (toString anything);

    # https://i3wm.org/docs/userguide.html#exec
    exec = command: ''exec "${escapeDoubleQuotes command}"'';
  };

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
    mkForEachUser = options: mkOption {
      type = with types; attrsOf (submodule { inherit options; });
    };
  };

  config = {
    mkForEachUser = cfg: f: mapAttrs (username: userCfg: f (userCfg // { inherit username; })) cfg.custom.users;

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

  attrs = rec {
    merge = list: foldl' recursiveUpdate {} list;

    mapAttrsToListAndMerge = f: attrs: merge (mapAttrsToList f attrs);

    remapAttrs = attrs: remaps: (let
      base = removeAttrs attrs (attrNames remaps);
      results = merge (mapAttrsToList (attrName: remapFn: remapFn attrs.${attrName}) remaps);
    in recursiveUpdate base results);
  };
}
