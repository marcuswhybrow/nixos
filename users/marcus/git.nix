{ config, pkgs, lib, ... }: {
  config.home-manager.users.marcus = {
    programs.gh.enable = true;
    programs.git = {
      enable = true;
      userName = "Marcus Whybrow";
      userEmail = "marcus@whybrow.uk";
    };
  };
}
