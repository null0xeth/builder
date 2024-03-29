{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hardware-cpu-presets.intel-desktop-12th;
in {
  imports = [../../../template.nix];
  options.hardware-cpu-presets.intel-desktop-12th = {
    enable = mkEnableOption "enable a pre-configured profile for intel 12th generation CPUs";
  };
  config = mkIf cfg.enable {
    hardware-templates.cpu.intel.intel-desktop-12th = {
      enable = true;
      name = "intel-desktop-12th";
      cpu = {
        brand = "intel";
        generation = 12;
        sub-type = "desktop";
      };
      settings = {
        graphics = {
          enable = true;
          drivers = "modesetting";
          dri = {
            enable = true;
            settings = "iris";
          };
          mesa = {
            enable = true;
          };
        };
        kernel = {
          gen-profile = {
            enable = true;
          };
          other = {
            powerstate = {
              enable = true;
            };
          };
        };
        performance = {
          enable = true;
          profile = "performance";
        };
      };
    };
  };
}
