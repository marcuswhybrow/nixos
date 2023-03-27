{ config, lib, pkgs, ... }: let
  inherit (lib) mkOption types mkEnableOption mkIf;
  cfg = config.custom.kernel;
  virtualisationModules = if cfg.virtualisation.enable then [ "kvm-${config.custom.hardware.cpu}" ] else [];
in {
  options.custom.kernel = {
    modules = {
      packages = mkOption {
        type = with types; listOf package;
        default = [];
      };
      beforeMountingRoot = mkOption {
        type = with types; listOf str;
        default = [];
      };
      beforeMountingRootForce = mkOption {
        type = with types; listOf str;
        default = [];
      };
      afterMountingRoot = mkOption {
        type = with types; listOf str;
        default = [];
      };
    };
    virtualisation.enable = mkEnableOption "Enable virtualisation kernel modules";
  };

  config = {
    boot.extraModulePackages = cfg.modules.packages;
    boot.initrd.availableKernelModules = cfg.modules.beforeMountingRoot;
    boot.initrd.kernelModules = cfg.modules.beforeMountingRootForce;
    boot.kernelModules = cfg.modules.afterMountingRoot ++ virtualisationModules;
  };
}
