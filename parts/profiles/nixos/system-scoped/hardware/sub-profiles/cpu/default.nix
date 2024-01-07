{
  config,
  lib,
  ...
}:
with lib; let
  #inherit (lib) mkEnableOption mkOption types mkIf mdDoc;
  cfg1 = config.modules.hardware.cpu;
  allPresets = builtins.mapAttrs (_: config: config.name) cfg1;
  cfg = cfg1."${builtins.head (builtins.attrNames allPresets)}";
  #slug = "${cfg.settings.cpuType}-${cfg.settings.sub-type}-${builtins.toString cfg.settings.generation}th";
in {
  imports = [./submodules];
  options.modules.hardware.cpu = mkOption {
    default = {};
    type = types.submodule {
      options = {
        enable = mkEnableOption "enable the default CPU profile";
        name = mkOption {
          type = types.string;
          default = "cpu";
        };
        settings = mkOption {
          type = types.submodule {
            options = {
              cpuType = mkOption {
                #type = types.nullOr (types.enum ["intel" "amd"]);
                default = "intel";
                type = types.str;
                description = "Please select the type of CPU you have (intel/amd)";
              };
              generation = mkOption {
                # cpu generation
                #type = types.nullOr types.int;
                default = 12;
                type = types.int;
                description = "Specify the CPU generation you have (intel only)";
              };
              sub-type = mkOption {
                #type = types.nullOr (types.enum ["mobile" "desktop"]);
                type = types.str;
                description = mdDoc "The type of CPU installed [desktop|mobile]";
                default = "mobile";
              };
            };
          };
        };
      };
    };
  };
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.settings.generation != 0;
        message = "Please specify the processor generation. It cannot be omitted";
      }
    ];
    #hardware-cpu-presets.${slug} = {
    hardware-cpu-presets = let
      slug = "${cfg.settings.cpuType}-${cfg.settings.sub-type}-${builtins.toString cfg.settings.generation}th";
    in {
      ${slug} = {
        enable = true;
      };
    };
  };
  #};
}
