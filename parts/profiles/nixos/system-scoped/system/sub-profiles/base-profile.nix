{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg1 = config.profiles.system;
  enabled = lib.filterAttrs (n: _: cfg1.${n}.enable) cfg1;
  cfg = config.profiles.system.${builtins.head (builtins.attrNames enabled)};

  enableModule = lib.types.submodule {
    options = {
      enable = mkEnableOption "";
    };
  };

  # options.profiles.system = {
  #   preset = mkOption {
  #     default = {};
  #     type = types.attrsOf (types.submodule ({name, ...}: {
  firmwareSubmodule = {name, ...}: {
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
          };
        };


  fontsSubmodule = {name, ...}: {
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

  utilsSubmodule = {name, ...}: {
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
in {
  imports = [
    ./utils
    ./firmware
    ./submodules
  ];

  options = {
    profiles.system = mkOption {
      default = {};
      type = with types;
        attrsOf (submodule ({name, ...}: {
          options = {
            enable = mkEnableOption "tba";
            profileName = mkOption {
              type = str;
              default = name;
            };

            firmware = mkOption {
              description = ''
                this sucks lol
              '';
              default = {};
              type = with types; submodule firmwareSubmodule;
            };

            fonts = mkOption {
              description = ''
                this sucks aswell
              '';
              default = {};
              type = with types; submodule fontsSubmodule;
            };

            sysutils = mkOption {
              description = ''
                i wouldnt be suprised if this sucked too.
              '';
              default = {};
              type = with types; submodule utilsSubmodule;
            };
          };
        }));
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.firmware.enable {
      nixos-modules.system.firmware = {
        inherit (cfg.firmware) enable automatic-updates;
      };

      environment.systemPackages = [pkgs.krew pkgs.jq pkgs.minio-client];
    })

    (mkIf cfg.fonts.enable {
      fonts = {
        enableDefaultPackages = true;
        inherit (cfg.fonts) packages;
        fontconfig.defaultFonts = {
		inherit (cfg.fonts.defaults) serif sansSerif monospace emoji;
	};
      };
    })

    (mkIf cfg.sysutils.enable {
      nixos-modules.sysutils = {
        inherit (cfg.sysutils) enable tools;
      };
    })
  ]);
}

