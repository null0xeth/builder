{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  filterfunc = builtins.attrNames (lib.filterAttrs (n: _: config.profiles.system.preset.${n}.enable) config.profiles.system.preset) or {};
  #cfg = config.profiles.system.preset.${filterfunc};

  enableModule = lib.types.submodule {
    options = {
      enable = mkEnableOption "";
    };
  };
in {
  imports = [
    ./utils
    ./firmware
    #./networking
    ./submodules
  ];

  options.profiles.system = {
    preset = mkOption {
      default = {};
      type = types.attrsOf (types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            default = false;
          };
          name = mkOption {
            type = types.str;
            description = mdDoc "The slug used to refer to this profile";
            default = "default-hardware-template";
          };
          profile = mkOption {
            default = {};
            type = types.submodule {
              options = {
                firmware = mkOption {
                  default = {};
                  type = types.submodule {
                    options = {
                      enable = mkEnableOption "the firmware configuration module";
                      automatic-updates = mkOption {
                        default = {};
                        type = types.submodule {
                          options = {
                            enable = mkEnableOption "enable automatic firmware updates";
                          };
                        };
                      };
                      # packages = mkOption {
                      #   type = with types; listOf package;
                      #   default = [];
                      #   description = mdDoc "Firmware packages to be installed";
                      # };
                    };
                  };
                };
              };
            };
          };
          fonts = mkOption {
            default = {};
            type = types.submodule {
              options = {
                enable = mkEnableOption "the font configuration module";
                packages = mkOption {
                  type = with types; listOf package;
                  default = [];
                  description = mdDoc "Font packages to install";
                };
                defaults = mkOption {
                  default = {};
                  type = types.submodule {
                    options = {
                      serif = mkOption {
                        type = with types; listOf str;
                        default = [];
                      };
                      sansSerif = mkOption {
                        type = with types; listOf str;
                        default = [];
                      };
                      monospace = mkOption {
                        type = with types; listOf str;
                        default = [];
                      };
                      emoji = mkOption {
                        type = with types; listOf str;
                        default = [];
                      };
                    };
                  };
                };
              };
            };
          };

          sysutils = mkOption {
            default = {};
            type = types.submodule {
              options = {
                enable = mkEnableOption "the system utilities module";
                tools = mkOption {
                  default = {};
                  type = types.submodule {
                    options = {
                      common = mkOption {
                        default = {};
                        type = enableModule;
                      };
                      direnv = mkOption {
                        default = {};
                        type = enableModule;
                      };
                      envfs = mkOption {
                        default = {};
                        type = enableModule;
                      };
                      ld = mkOption {
                        default = {};
                        type = enableModule;
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
  };

  config = let
    name = builtins.head filterfunc;
    cfg = config.profiles.system.preset.${name};
  in
    mkIf (filterfunc != {}) (mkMerge [
      (mkIf (cfg.enable && cfg.preset != {}) (mkMerge [
        (mkIf cfg.profile.firmware.enable {
          nixos-modules.system.firmware = {
            inherit (cfg.profile.firmware) enable automatic-updates;
          };

          environment.systemPackages = [pkgs.krew pkgs.jq pkgs.minio-client];
        })

        (mkIf cfg.fonts.enable {
          fonts = {
            enableDefaultPackages = true;
            inherit (cfg.fonts) packages;
            fontconfig.defaultFonts = cfg.fonts.defaults;
          };
        })

        (mkIf cfg.sysutils.enable {
          nixos-modules.sysutils = {
            inherit (cfg.sysutils) enable tools;
          };
        })
      ]))
    ]);
}
