{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  filterfunc = set: builtins.head (builtins.attrNames (lib.filterAttrs (n: v: set.${n}.enable) set));
  cfg = config.profiles.kernel.preset.${filterfunc config.profiles.kernel.preset};

  enableModule = lib.types.submodule {
    options = {
      enable = mkEnableOption "";
    };
  };

  profileTemplate = {name, ...}: {
    options = {
      name = mkOption {
        type = types.str;
        default = "nakedTemplate";
        description = mdDoc "Capybara";
      };

      enable = mkEnableOption "the default kernel profile template";
      general = mkOption {
        default = {};
        type = types.submodule {
          options = {
            enable = mkEnableOption (mdDoc "the general kernel configuration module");
            useLatest = mkEnableOption "the latest kernel packages";
            kernelPackages = mkOption {
              type = types.raw;
              description = "If `useLatest` is disabled, specify the packages here";
              default = pkgs.linuxPackages_latest;
            };
            kernelModules = mkOption {
              type = types.nullOr (types.listOf types.str);
              description = "Kernel modules to be installed";
              default = [];
            };
            kernelParams = mkOption {
              default = {};
              type = types.submodule {
                options = {
                  useDefaults = mkEnableOption "the default kernel parameters";
                  customParams = mkOption {
                    type = types.nullOr (types.listOf types.str);
                    description = "Kernel parameters";
                    default = [];
                  };
                };
              };
            };
            initrd = mkOption {
              default = {};
              type = types.submodule {
                options = {
                  systemd = mkOption {
                    default = {};
                    type = enableModule;
                  };
                  kernelModules = mkOption {
                    type = types.nullOr (types.listOf types.str);
                    description = "Kernel modules to always be installed";
                    default = [];
                  };
                  availableKernelModules = mkOption {
                    type = types.nullOr (types.listOf types.str);
                    description = "Kernel modules to be installed";
                    default = [];
                  };
                };
              };
            };
          };
        };
      };

      tweaks = mkOption {
        default = {};
        type = types.submodule {
          options = {
            networking = mkOption {
              default = {};
              type = enableModule;
            };
            hardening = mkOption {
              default = {};
              type = enableModule;
            };
            failsaves = mkOption {
              default = {};
              type = enableModule;
            };
            clean = mkOption {
              default = {};
              type = enableModule;
            };
          };
        };
      };

      boot = mkOption {
        default = {};
        type = types.submodule {
          options = {
            enable = mkEnableOption "blabla";
            general = mkOption {
              default = {};
              type = types.submodule {
                options = {
                  silent = mkOption {
                    default = {};
                    type = types.submodule {
                      options = {
                        enable = mkEnableOption "tbalol";
                      };
                    };
                  };
                };
              };
            };
            tmpfs = mkOption {
              default = {};
              type = types.submodule {
                options = {
                  enable = mkEnableOption "the temporary filesystem";
                  size = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                  };
                };
              };
            };
            loader = mkOption {
              default = {};
              type = types.submodule {
                options = {
                  systemd = mkOption {
                    default = {};
                    type = types.submodule {
                      options = {
                        enable = mkEnableOption "systemd boot for this system";
                        configurationLimit = mkOption {
                          type = types.nullOr types.int;
                          default = 5;
                          description = mdDoc "the maximum number of nixos generations kept on this system";
                        };
                      };
                    };
                  };
                  settings = mkOption {
                    default = {};
                    type = types.submodule {
                      options = {
                        efiSupport = mkOption {
                          default = {};
                          type = enableModule;
                        };
                        timeout = mkOption {
                          type = types.int;
                          default = 3;
                          description = mdDoc "the maximum allowed time in seconds to time out kernel operations";
                        };
                        copyToTmpfs = mkOption {
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
        };
      };

      optionals = mkOption {
        default = {};
        type = types.submodule {
          options = {
            ricemyttydotcom = mkOption {
              default = {};
              type = enableModule;
            };
          };
        };
      };
    };
  };
in {
  imports = [./submodules];

  options.profiles.kernel = {
    preset = mkOption {
      default = {};
      type = types.attrsOf (types.submodule profileTemplate);
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      modules.kernel = {
        inherit (cfg) boot general tweaks;
      };
    }
    (mkIf cfg.optionals.ricemyttydotcom.enable {
      boot = {
        kernelParams = [
          # RiceMyTTY.com/zerofucksgiven
          "vt.default_red=30,243,166,249,137,245,148,186,88,243,166,249,137,245,148,166"
          "vt.default_grn=30,139,227,226,180,194,226,194,91,139,227,226,180,194,226,173"
          "vt.default_blu=46,168,161,175,250,231,213,222,112,168,161,175,250,231,213,200"
        ];
      };

      console = {
        font = "Lat2-Terminus16";
        earlySetup = true;
        useXkbConfig = true;
        packages = with pkgs; [terminus_font];
      };
    })
  ]);
}
