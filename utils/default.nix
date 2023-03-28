{ lib }: let
  inherit (builtins) toString replaceStrings;
  inherit (lib.attrsets) mapAttrsToList;
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
  };
}
