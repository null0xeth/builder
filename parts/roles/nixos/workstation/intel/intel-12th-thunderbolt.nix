{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.roles.workstation.intel;
in {
  imports = [
    ../../../../profiles/nixos/kernel
    ../../../../profiles/nixos/hardware
    ../../../../profiles/nixos/system/base-system.nix
    ../../../../profiles/nixos/security/base-yubi-max.nix
    ../../../../profiles/nixos/graphical/base-gtk-hypr.nix
  ];

  options.roles.workstation.intel = {
    enable = mkEnableOption "the role that sets system configuration for workstation with an intel 12th gen CPU";
    overrides = {
      kernelModules = mkOption {
        type = types.nullOr (types.listOf types.str);
        description = "Kernel modules to be installed";
        default = [];
      };
      initrd = {
        availableKernelModules = mkOption {
          type = types.nullOr (types.listOf types.str);
          description = "Kernel modules to be installed";
          default = [];
        };
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      profiles = {
        system-config.base-system = {
          enable = true;
        };
        hardware-config.base-intel-12-thunderbolt = {
          enable = true;
        };
        security-config.base-yubi-max = {
          enable = true;
        };
        graphical-config.base-gtk-hypr = {
          enable = true;
        };

        kernel-interface.settings.baseSecured = {
          enable = true;
          name = "baseSecured";
          kernelModules = cfg.overrides.kernelModules;
          availableKernelModulesIRD = cfg.overrides.initrd.availableKernelModules;
        };

        networking.preset.the-backrooms = {
          enable = true;
          hostName = "the-backrooms";
          extraHosts = ''
            192.168.1.9 vip.chonk.city
          '';
        };
      };
    }
  ]);
}
