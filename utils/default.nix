{ lib }: let
  inherit (builtins) toString replaceStrings mapAttrs removeAttrs foldl' attrNames;
  inherit (lib.attrsets) mapAttrsToList recursiveUpdate;
  inherit (lib) mkOption types;
  escapeDoubleQuotes = anything: replaceStrings [ ''"'' ] [ ''\"'' ] (toString anything); 
in rec {
  inherit escapeDoubleQuotes;
  bash = {
    test = { test, onPass, onFail }: ''$([ ${test} ] && echo "${escapeDoubleQuotes onPass}" || echo "${escapeDoubleQuotes onFail}")'';
    switch = expression: cases: default: let
      casesStr = toString (mapAttrsToList (name: value: ''"${escapeDoubleQuotes name}") echo "${escapeDoubleQuotes value}";;'') cases);
      defaultCaseStr = ''*) echo "${escapeDoubleQuotes default}";;'';
    in ''$(case $(${expression}) in ${casesStr} ${defaultCaseStr} esac)'';
  };
  options = {
    mkStr = default: mkOption {
      type = types.str;
      inherit default;
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

  forEachUser = cfg: f: mapAttrs (userName: userConfig: f (userConfig // {
    username = userName;
  })) cfg.custom.users;

  merge = list: foldl' recursiveUpdate {} list;

  mapAttrsToListAndMerge = f: attrs: merge (mapAttrsToList f attrs);

  remapAttrs = attrs: remaps: (let
    base = removeAttrs attrs (attrNames remaps);
    results = merge (mapAttrsToList (attrName: remapFn: remapFn attrs.${attrName}) remaps);
  in recursiveUpdate base results);
}
