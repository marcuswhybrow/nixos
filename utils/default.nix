{ lib }: let
  inherit (builtins) toString replaceStrings mapAttrs removeAttrs foldl';
  inherit (lib.attrsets) mapAttrsToList recursiveUpdate;
  inherit (lib) mkOption types;
  escapeDoubleQuotes = anything: replaceStrings [ ''"'' ] [ ''\"'' ] (toString anything); 
in {
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
  remapAttrs = attrs: remaps: let
    remapAttr = attrName: remapFn: let
      base = removeAttrs attrs [ attrName ];
      merge = foldl' recursiveUpdate {} (mapAttrsToList remapFn attrs.${attrName});
    in recursiveUpdate base merge;
    merges = mapAttrsToList (attrName: remapFn: (remapAttr attrName remapFn)) remaps;
  in foldl' recursiveUpdate {} merges;
}
