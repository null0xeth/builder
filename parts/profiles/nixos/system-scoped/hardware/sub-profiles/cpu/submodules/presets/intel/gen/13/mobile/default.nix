{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hardware-cpu-presets.intel-mobile-13th;
in {
  imports = [../../../template.nix];
  options.hardware-cpu-presets.intel-mobile-13th = {
    enable = mkEnableOption "enable a pre-configured profile for intel 13th generation CPUs";
  };
  config = mkIf cfg.enable {
    hardware-templates.cpu.intel.intel-mobile-13th = {
      enable = true;
      preset = {
        name = "intel-mobile-13th";
        cpu = {
          brand = "intel";
          generation = 13;
          sub-type = "mobile";
        };
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
