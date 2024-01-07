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
    type = types.submodule ({
      config,
      name,
      ...
    }: {
      options = {
        enable = mkEnableOption "the base hardware profile";
        name = mkOption {
          type = types.str;
          description = mdDoc "The slug used to refer to this profile";
          default = name;
        };
        profile = mkOption {
          type = types.submodule {
            options = {
              enable = mkEnableOption "lol";
              cpu = mkOption {
                type = types.submodule {
                  options = {
                    brand = mkOption {
                      type = types.nullOr types.str;
                      description = mdDoc "The manufacturer of your CPU";
                      #default = null;
                    };
                    generation = mkOption {
                      type = types.nullOr types.int;
                      description = mdDoc "The generation of your CPU (intel only)";
                      #default = null;
                    };
                    sub-type = mkOption {
                      type = types.nullOr types.str;
                      description = mdDoc "The type of CPU installed [desktop|mobile]";
                      #default = null;
                    };
                  };
                };
              };
            };
          };
        };
      };
    });
  };
  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.settings.generation != 0;
          message = "Please specify the processor generation. It cannot be omitted";
        }
      ];
    }
    (mkIf (cfg.profile.enable && (cfg.profile.cpu.brand != null) && (cfg.profile.cpu.generation != null) && (cfg.profile.cpu.sub-type != null))
      (let
        slug = "${cfg.profile.brand}-${cfg.profile.sub-type}-${builtins.toString cfg.profile.generation}th";
      in {
        hardware-cpu-presets.${slug}.enable = true;
      }))

    # hardware-cpu-presets = let
    #   slug = "${cfg.settings.cpuType}-${cfg.settings.sub-type}-${builtins.toString cfg.settings.generation}th";
    # in {
    #   ${slug} = {
    #     enable = true;
    #   };
    # };
  ]);
}
