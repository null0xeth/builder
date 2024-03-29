{
  config,
  lib,
  ...
}:
with lib; let
  #inherit (lib) mkEnableOption mkOption types mkIf mdDoc;
  # cfg1 = config.modules.hardware.cpu.preset;
  # allPresets = builtins.mapAttrs (_: config: config.name) cfg1;
  # cfg = cfg1."${builtins.head (builtins.attrNames allPresets)}";
  #slug = "${cfg.settings.cpuType}-${cfg.settings.sub-type}-${builtins.toString cfg.settings.generation}th";
  filterfunc = set: builtins.head (builtins.attrNames (lib.filterAttrs (n: _: set.${n}.enable) set));
  cfg = config.modules.hardware.cpu.preset.${filterfunc config.modules.hardware.cpu.preset};
in {
  imports = [./submodules];
  options.modules.hardware.cpu = {
    preset = mkOption {
      type = types.attrsOf (types.submodule ({
        name,
        config,
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
                        type = types.str;
                        description = mdDoc "The manufacturer of your CPU";
                        default = "none";
                      };
                      generation = mkOption {
                        type = types.int;
                        description = mdDoc "The generation of your CPU (intel only)";
                        default = 69;
                      };
                      sub-type = mkOption {
                        type = types.str;
                        description = mdDoc "The type of CPU installed [desktop|mobile]";
                        default = "none";
                        #default = null;
                      };
                    };
                  };
                };
              };
            };
          };
        };
      }));
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.profile.cpu.generation != 0;
          message = "Please specify the processor generation. It cannot be omitted";
        }
      ];
    }
    (mkIf (cfg.profile.enable && (cfg.profile.cpu != null)) {
      hardware-cpu-presets."${cfg.profile.cpu.brand}-${cfg.profile.cpu.sub-type}-${builtins.toString cfg.profile.cpu.generation}th" = {
        enable = true;
      };
    })

    # hardware-cpu-presets = let
    #   slug = "${cfg.settings.cpuType}-${cfg.settings.sub-type}-${builtins.toString cfg.settings.generation}th";
    # in {
    #   ${slug} = {
    #     enable = true;
    #   };
    # };
  ]);
}
