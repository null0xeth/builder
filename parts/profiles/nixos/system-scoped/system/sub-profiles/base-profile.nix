{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  # cfg1 = config.profiles.system;
  # profileNames = attrNames cfg1;
  # cfg = cfg1.${builtins.head profileNames};
  # cfg2 = config.profiles;
  # base = name: (builtins.hasAttr name config.profiles.system.preset);
  # filter = lib.filterAttrs (n: _: base n);
  # filterfunc = builtins.head (builtins.attrNames filter);
  # cfg2 = config.profiles.system.preset."${filterfunc}";
  # cfg = config.profiles.system.preset;
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
      # enable = mkOption {
      #   type = types.bool;
      #   default = false;
      # };
      # name = mkOption {
      #   type = types.str;
      #   description = mdDoc "The slug used to refer to this profile";
      #   default = "default-hardware-template";
      # };
      # profile = mkOption {
      #   default = {};
      #   type = types.submodule {
      #     options = {

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
          };
        };
      };
    };
  };

  # fonts = mkOption {
  #   default = {};
  #   type = types.submodule {
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

  # sysutils = mkOption {
  #   default = {};
  #   type = types.submodule {
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
    #./networking
    ./submodules
  ];

  # options.profiles.system = {
  #   enable = mkEnableOption "lol";
  #   preset = mkOption {
  #     default = {};
  #     type = types.attrsOf (types.submodule ({name, ...}: {}));
  #   };
  # };

  # config = let
  #   cfg = let
  #     namez = builtins.head filterfunc ? "none";
  #   in
  #     config.profiles.system.preset."${namez}";
  #   # // {
  #   #   preset = "${namez}";
  #   # };
  # in

  options = {
    profiles.systemPool = mkOption {
      type = types.nullOr types.str;
      readOnly = true;
    };

    profiles.system = mkOption {
      default = {};
      type = with types;
        attrsOf (submodule ({
          name,
          config,
          ...
        }: {
          options = {
            enable = mkOption {
              type = bool;
              default = false;
            };

            profileName = mkOption {
              type = str;
              default = name;
            };

            firmware = mkOption {
              description = ''
                this sucks lol
              '';
              default = {};
              type = with types; attrsOf (submodule firmwareSubmodule);
            };

            fonts = mkOption {
              description = ''
                this sucks aswell
              '';
              default = {};
              type = with types; attrsOf (submodule fontsSubmodule);
            };

            sysutils = mkOption {
              description = ''
                i wouldnt be suprised if this sucked too.
              '';
              default = {};
              type = with types; attrsOf (submodule utilsSubmodule);
            };
          };
          config = {
            cfg.${name} =
              {
                enable = config.enable;
              }
              // {
                inherit (config) profileName firmware fonts sysutils;
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
        fontconfig.defaultFonts = {inherit (cfg.fonts) defaults;};
      };
    })

    (mkIf cfg.sysutils.enable {
      nixos-modules.sysutils = {
        inherit (cfg.sysutils) enable tools;
      };
    })
  ]);
}
