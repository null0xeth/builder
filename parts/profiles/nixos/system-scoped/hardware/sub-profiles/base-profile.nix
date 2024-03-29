{
  config,
  lib,
  ...
}:
with lib; let
  #inherit (lib) mkEnableOption mkOption mdDoc types mkIf mkMerge;
  filterfunc = set: builtins.head (builtins.attrNames (lib.filterAttrs (n: _: set.${n}.enable) set));
  cfg = config.profiles.hardware.preset.${filterfunc config.profiles.hardware.preset};
  # cfg1 = config.profiles.hardware.preset;
  # enabled = lib.filterAttrs (_: config: config.enable) cfg1;
  # names = builtins.attrNames enabled;
  # filter = lib.filterAttrs (name: _: (builtins.elem name cfg1));
  # active = builtins.head (builtins.attrNames filter);
  # cfg = config.profiles.hardware.preset.${active};
  # c = config.modules;
  #cfg = config.profiles.hardware.preset;
  # cfg1 = config.profiles.hardware.preset;
  # enabled = lib.filterAttrs (n: _: cfg1.${n}.enable) cfg1;
  # cfg = config.profiles.hardware.preset.${builtins.head (builtins.attrNames enabled)};

  enableModule = lib.types.submodule {
    options = {
      enable = mkEnableOption "";
    };
  };
in {
  imports = [
    ./cpu
    ./core
    ./extras
  ];

  options.profiles.hardware = {
    preset = mkOption {
      type = types.attrsOf (types.submodule ({name, ...}: {
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
                        default = "intel";
                        #default = null;
                      };
                      generation = mkOption {
                        type = types.nullOr types.int;
                        description = mdDoc "The generation of your CPU (intel only)";
                        default = 12;
                        #default = null;
                      };
                      sub-type = mkOption {
                        type = types.nullOr types.str;
                        description = mdDoc "The type of CPU installed [desktop|mobile]";
                        default = "mobile";
                        #default = null;
                      };
                    };
                  };
                };
              };
            };
          };

          core = mkOption {
            type = types.submodule {
              options = {
                enable = mkEnableOption "tba";
                audio = mkOption {
                  type = enableModule;
                };
                bluetooth = mkOption {
                  type = enableModule;
                };
                storage = mkOption {
                  type = enableModule;
                };
              };
            };
          };

          optionals = mkOption {
            type = types.submodule {
              options = {
                enable = mkEnableOption "tba";
                thunderbolt = mkOption {
                  type = enableModule;
                };
                sensors = mkOption {
                  type = enableModule;
                };
                peripherals = mkOption {
                  type = types.submodule {
                    options = {
                      logitech = mkOption {
                        type = enableModule;
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
      modules.hardware.cpu.preset.${cfg.name} = {
        enable = cfg.profile.enable;
        name = cfg.name;
        profile = {
          enable = cfg.profile.enable;
          cpu = {
            brand = cfg.profile.cpu.brand;
            generation = cfg.profile.cpu.generation;
            sub-type = cfg.profile.cpu.sub-type;
          };
        };
      };
    }
    (mkIf cfg.core.enable {
      modules.hardware.core = {
        enable = true;
        settings = {
          audio.enable = cfg.core.audio.enable;
          bluetooth.enable = cfg.core.bluetooth.enable;
          storage.enable = cfg.core.storage.enable;
        };
      };
    })

    (mkIf cfg.optionals.enable {
      modules.hardware.extras = {
        enable = cfg.optionals.thunderbolt.enable || cfg.optionals.sensors.enable || cfg.optionals.peripherals.logitech.enable;
        settings = {
          sensors.enable = true;
          thunderbolt.enable = true;
          logitech.enable = true;
        };
      };
    })
    #   (mkIf cfg.profile.enable {
    #     modules.hardware.cpu = {
    #       enable = true;
    #       name = "${cfg.name}";
    #       settings = {
    #         cpuType = cfg.profile.cpu.brand;
    #         generation = mkIf (cfg.profile.cpu.brand == "intel" && cfg.profile.cpu.generation != null) cfg.profile.cpu.generation;
    #         inherit (cfg.profile.cpu) sub-type;
    #       };
    #     };
    #   })

    #   (mkIf (!cfg.profile.enable) {
    #     modules.hardware.cpu = {
    #       enable = false;
    #       # name = "${cfg.name}";
    #       # settings = {
    #       #   cpuType = null;
    #       #   generation = null;
    #       #   sub-type = null;
    #       # };
    #     };
    #   })

    #   (mkIf cfg.core.enable {
    #     modules.hardware.core = {
    #       enable = true;
    #       settings = {
    #         audio.enable = cfg.core.audio.enable;
    #         bluetooth.enable = cfg.core.bluetooth.enable;
    #         storage.enable = cfg.core.storage.enable;
    #       };
    #     };
    #   })

    #   (mkIf cfg.optionals.enable {
    #     modules.hardware.extras = {
    #       enable = cfg.optionals.thunderbolt.enable || cfg.optionals.sensors.enable || cfg.optionals.peripherals.logitech.enable;
    #       settings = {
    #         sensors.enable = true;
    #         thunderbolt.enable = true;
    #         logitech.enable = true;
    #       };
    #     };
    #   })
  ]);
}
