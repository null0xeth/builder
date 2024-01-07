{moduleWithSystem, ...}: {
flake.nixosModules.byosBuilder = moduleWithSystem (
  perSystem@{ self' }:
  { config, lib, ...}:
with lib; let
  cfg1 = config.presets;
  enabled = lib.filterAttrs (n: _: cfg1.${n}.enable) cfg1;
  cfg = config.presets.${builtins.head (builtins.attrNames enabled)};

  enableModule = lib.types.submodule {
    options = {
      enable = mkEnableOption "";
    };
  };

  # QuickNav:
  in {
  imports = [
    ./profiles/nixos/system-scoped
  ];

  options.presets = mkOption {
    default = {};
    type = types.attrsOf (types.submodule ({name, config, ...}: {
      options = {
        enable = mkEnableOption "the preset builder";
        name = mkOption {
          type = types.str;
          description = mdDoc "The slug used to refer to preset";
          default = name;
        };
        builder = mkOption {
          default = {};
          type = types.submodule {
            options = {
              networking = mkOption {
                default = {};
                type = types.submodule {
                  options = {
                    enable = mkEnableOption "tba";
                    hostName = mkOption {
                      type = types.nullOr types.str;
                      description = mdDoc "The hostname of the to-be configured system";
                      default = "honkmaster9000";
                    };
                    extraHosts = mkOption {
                      type = types.nullOr types.lines;
                      description = mdDoc "Extra hosts to add to /etc/hosts";
                      default = "";
                    };
                  };
                };
              };
              fromHardwareConfig = mkOption {
                default = {};
                type = types.submodule {
                  options = {
                    enable = mkEnableOption "tba";
                    hostArch = mkOption {
                      type = types.str;
                      default = "x86_64-linux";
                    };
                    kernelModules = mkOption {
                      type = types.listOf types.str;
                      description = mdDoc "add kernelModules from ur Hardware-config.nix";
                      default = [];
                    };
                    initrd = mkOption {
                      default = {};
                      type = types.submodule {
                        options = {
                          availableKernelModules = mkOption {
                            type = types.listOf types.str;
                            description = mdDoc "add initrd kernelModules from ur Hardware-config.nix";
                            default = [];
                          };
                        };
                      };
                    };
                    fileSystems = mkOption {
                      type = types.lazyAttrsOf types.anything;
                      default = {};
                    };
                    swapDevices = mkOption {
                      default = [];
                      type = with types; listOf (submodule {
                        options = {
                          device = mkOption {
                            type = path;
                          };
                        };
                      });
                    };
                  };
                };
              };

              hardware = mkOption {
                default = {};
                type = types.submodule {
                  options = {
                    enable = mkEnableOption "the base hardware profile";
                    name = mkOption {
                      type = types.str;
                      description = mdDoc "The slug used to refer to this profile";
                      default = "${cfg.name}";
                    };
                    profile = mkOption {
                      default = {};
                      type = types.submodule {
                        options = {
                          enable = mkEnableOption "lol";
                          cpu = mkOption {
                            default = {};
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
                                };
                                sub-type = mkOption {
                                  type = types.nullOr types.str;
                                  description = mdDoc "The type of CPU installed [desktop|mobile]";
                                  default = "mobile";
                                };
                              };
                            };
                          };
                        };
                      };
                    };

                    core = mkOption {
                      default = {};
                      type = types.submodule {
                        options = {
                          enable = mkEnableOption "tba";
                          audio = mkOption {
                            default = {};
                            type = enableModule;
                          };
                          bluetooth = mkOption {
                            default = {};
                            type = enableModule;
                          };
                          storage = mkOption {
                            default = {};
                            type = enableModule;
                          };
                        };
                      };
                    };

                    optionals = mkOption {
                      default = {};
                      type = types.submodule {
                        options = {
                          enable = mkEnableOption "tba";
                          thunderbolt = mkOption {
                            default = {};
                            type = enableModule;
                          };
                          sensors = mkOption {
                            default = {};
                            type = enableModule;
                          };
                          peripherals = mkOption {
                            default = {};
                            type = types.submodule {
                              options = {
                                logitech = mkOption {
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

              kernel = mkOption {
                default = {};
                type = types.submodule {
                  options = {
                    enable = mkEnableOption "tba";
                    settings = mkOption {
                      default = {};
                      type = types.submodule {
                        options = {
                          enable = mkOption {
                            type = types.bool;
                            default = cfg.builder.kernel.enable;
                          };
                          useLatest = mkEnableOption "the latest kernel packages";
                          kernelPackages = mkOption {
                            type = types.nullOr types.raw;
                            description = "If `useLatest` is disabled, specify the packages here";
                            default = null;
                          };
                          kernelModules = mkOption {
                            type = types.listOf types.str;
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
                          settings = mkOption {
                            default = {};
                            type = types.submodule {
                              options = {
                                general = mkOption {
                                  default = {};
                                  type = types.submodule {
                                    options = {
                                      silent = mkEnableOption "silence the console logs";
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
                                      };
                                    };
                                  };
                                };

                                loader = mkOption {
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
                                      systemd-boot = mkOption {
                                        default = {};
                                        type = types.submodule {
                                          options = {
                                            enable = mkEnableOption "use systemd boot";
                                            configurationLimit = mkOption {
                                              type = types.int;
                                              default = 5;
                                              description = mdDoc "the maximum number of nixos generations kept on this system";
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

                          stages = mkOption {
                            default = {};
                            type = types.submodule {
                              options = {
                                stage1 = mkOption {
                                  default = {};
                                  type = types.submodule {
                                    options = {
                                      initrd = mkOption {
                                        default = {};
                                        type = types.submodule {
                                          options = {
                                            systemd = mkOption {
                                              default = {};
                                              type = enableModule; # enable systemd in the first stage of booting.
                                            };
                                            kernelModules = mkOption {
                                              type = types.listOf types.str;
                                              description = "Kernel modules to always be installed";
                                              default = [];
                                            };
                                            availableKernelModules = mkOption {
                                              type = types.listOf types.str;
                                              description = "Kernel modules to be installed";
                                              default = cfg.builder.fromHardwareConfig.initrd.availableKernelModules;
                                            };
                                          };
                                        };
                                      };
                                    };
                                  };
                                };

                                stage2 = mkOption {
                                  default = {};
                                  type = types.submodule {
                                    options = {
                                      kernelModules = mkOption {
                                        type = types.listOf types.str;
                                        description = "Kernel modules to be installed";
                                        default = cfg.builder.fromHardwareConfig.kernelModules;
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
                  };
                };
              };
              # Checked and ok.
              graphical = mkOption {
                default = {};
                type = types.submodule {
                  options = {
                    enable = mkEnableOption "tba";
                    name = mkOption {
                      type = types.str;
                      default = "${cfg.name}";
                    };
                    base = mkOption {
                      type = types.enum ["gtk"];
                      description = mdDoc "The base layer used for rendering the system's gui";
                      default = "gtk";
                    };
                    settings = mkOption {
                      default = {};
                      type = types.submodule {
                        options = {
                          system = mkOption {
                            default = {};
                            type = types.submodule {
                              options = {
                                dbus = mkOption {
                                  default = {};
                                  type = enableModule;
                                };
                              };
                            };
                          };
                          xserver = mkOption {
                            default = {};
                            type = types.submodule {
                              options = {
                                enable = mkEnableOption "xserver";
                                extra = mkOption {
                                  default = {};
                                  type = types.submodule {
                                    options = {
                                      exportConfiguration = mkOption {
                                        default = {};
                                        type = enableModule;
                                      };
                                      hyperlandSupport = mkOption {
                                        default = {};
                                        type = enableModule;
                                      };
                                    };
                                  };
                                };
                                libinput = mkOption {
                                  default = {};
                                  type = enableModule;
                                };
                                desktopManager = mkOption {
                                  default = {};
                                  type = types.submodule {
                                    options = {
                                      enable = mkEnableOption "enable the desktopmanager module";
                                      active = mkOption {
                                        type = types.enum ["gnome" "none"];
                                        default = "none";
                                      };
                                    };
                                  };
                                };
                                displayManager = mkOption {
                                  default = {};
                                  type = types.submodule {
                                    options = {
                                      enable = mkEnableOption "enable the displaymanager module";
                                      active = mkOption {
                                        type = types.enum ["gdm" "none"];
                                        default = "none";
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
                  };
                };
              };

              system = mkOption {
                default = {};
                type = types.submodule {
                  options = {
                    enable = mkOption {
                      type = types.bool;
                      default = false;
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
                                #   type = with types; nullOr raw;
                                #   description = mdDoc "Firmware packages to be installed";
                                #   default = null;
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
                          enable = mkOption {
                            type = types.bool;
                            default = false;
                          };
                          packages = mkOption {
                            type = with types; listOf package;
                            description = mdDoc "Font packages to install";
                            default = [];
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
                };
              };

              security = mkOption {
                default = {};
                type = types.submodule {
                  options = {
                    enable = mkEnableOption "tba";
                    modules = mkOption {
                      default = {};
                      type = types.submodule {
                        options = {
                          agenix = mkOption {
                            default = {};
                            type = enableModule;
                          };

                          yubikey = mkOption {
                            default = {};
                            type = types.submodule {
                              options = {
                                enable = mkEnableOption "support for yubikey mfa";
                                settings = mkOption {
                                  default = {};
                                  type = types.submodule {
                                    options = {
                                      configuration = mkOption {
                                        default = {};
                                        type = types.submodule {
                                          options = {
                                            idVendor = mkOption {
                                              type = types.str;
                                              default = null;
                                              description = "Yubikey vendor id";
                                            };
                                            idProduct = mkOption {
                                              type = types.str;
                                              default = null;
                                              description = "Yubikey product id";
                                            };
                                          };
                                        };
                                      };
                                      udev = mkOption {
                                        default = {};
                                        type = enableModule;
                                      };
                                      touchDetector = mkOption {
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
                  };
                };
              };
            };
          };
        };
      };
    }));
  };
  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.name != null;
          message = "Preset name cannot be omitted.";
        }
             ];
    }
    # Networking:
    (mkIf cfg.builder.networking.enable (mkMerge [
      {
        profiles.networking.preset.${cfg.name} = {
          enable = true;
          inherit (cfg.builder.networking) hostName extraHosts;

        };
      }
    ]))

    # FS:
    (mkIf cfg.builder.fromHardwareConfig.enable {
      inherit (cfg.builder.fromHardwareConfig) fileSystems swapDevices;
      nixpkgs.hostPlatform = mkDefault "${cfg.builder.fromHardwareConfig.hostArch}";
    })

    # HW:
    (mkIf cfg.builder.hardware.enable {
      profiles.hardware.preset.${cfg.name} = {
        enable = true;
        name = cfg.name;
        profile = {
          enable = cfg.builder.hardware.profile.enable;
          cpu = {
            brand = cfg.builder.hardware.profile.cpu.brand;
            generation = cfg.builder.hardware.profile.cpu.generation;
            sub-type = cfg.builder.hardware.profile.cpu.sub-type;
          };
        };
        core = {
          enable = cfg.builder.hardware.core.enable;
          audio.enable = cfg.builder.hardware.core.audio.enable;
          bluetooth.enable = cfg.builder.hardware.core.bluetooth.enable;
          storage.enable = cfg.builder.hardware.core.storage.enable;
        };
        optionals = {
          thunderbolt.enable = cfg.builder.hardware.optionals.thunderbolt.enable;
          sensors.enable = cfg.builder.hardware.optionals.sensors.enable;
          peripherals.logitech.enable = cfg.builder.hardware.core.optionals.peripherals.logitech.enable;
        };
      };
          })

    # Kernel:
    (mkIf cfg.builder.kernel.enable {
        profiles.kernel.preset.${cfg.name} = {
          enable = true;
          name = "${cfg.name}";
          general = {
            inherit (cfg.builder.kernel.settings) enable useLatest kernelPackages kernelModules;

            kernelParams = {
              inherit (cfg.builder.kernel.settings.kernelParams) useDefaults customParams;
            };
            initrd = {
              inherit (cfg.builder.kernel.boot.stages.stage1.initrd) kernelModules availableKernelModules systemd;
                          };
          };

          tweaks = {
            inherit (cfg.builder.kernel.tweaks) networking hardening failsaves clean;
          };

          boot = {
            enable = true;

            general = {
              silent = {
                enable = cfg.builder.kernel.boot.settings.general.silent;
              };
            };
            tmpfs = {
              inherit (cfg.builder.kernel.boot.settings.tmpfs) enable size;
            };

            loader = {
              systemd = {
                inherit (cfg.builder.kernel.boot.settings.loader.systemd-boot) enable configurationLimit;
              };

              settings = {
                inherit (cfg.builder.kernel.boot.settings.loader) timeout efiSupport copyToTmpfs;
              };
            };
          };
          optionals = {
            ricemyttydotcom = {
              enable = true;
            };
          };
        };
      })

      # Graphics:
      (mkIf cfg.builder.graphical.enable {
        profiles.graphical.preset.${cfg.name} = {
          inherit (cfg.builder.graphical) enable name base;
          settings = {
            inherit (cfg.builder.graphical.settings) system;
            xserver = {
              inherit (cfg.builder.graphical.settings.xserver)
                enable
                extra
                libinput
                desktopManager
                displayManager;
            };
          };
        };
      })

      # System:
      (mkIf cfg.builder.system.enable (mkMerge [
        {
          profiles.system.preset.${cfg.name} = {
            enable = true;
            profileName = "${cfg.name}";
            firmware.${cfg.name} = {
              inherit (cfg.builder.system.profile.firmware) enable automatic-updates; 
            };
            fonts.${cfg.name} = {
              inherit (cfg.builder.system.fonts) enable packages defaults;
            };
            sysutils.${cfg.name} = {
              inherit (cfg.builder.system.sysutils) enable tools;
            };
          };
        }]))

        # (mkIf cfg.builder.system.profile.firmware.enable {
        #   profiles.system.preset.${cfg.name} = {
        #       inherit (cfg.builder.system) profile;
        #   };
        # })
        # (mkIf cfg.builder.system.fonts.enable {
        #   profiles.system.preset.${cfg.name} = {
        #     inherit (cfg.builder.system) fonts;
        #   };
        # })
        # (mkIf cfg.builder.system.sysutils.enable {
        #   profiles.system.preset.${cfg.name} = {
        #     inherit (cfg.builder.system) sysutils;
        #   };
        # })
      #]))

      # Security:
      (mkIf cfg.builder.security.enable (mkMerge [
        {
          profiles.security.preset.${cfg.name} = {
            enable = cfg.builder.security.enable;
            name = cfg.name;
            modules = {
              agenix.enable = cfg.builder.security.modules.agenix.enable;
              yubikey = {
                enable = cfg.builder.security.modules.yubikey.enable;
                settings = {
                  configuration = {
                    idVendor = cfg.builder.security.modules.yubikey.settings.configuration.idVendor;
                    idProduct = cfg.builder.security.modules.yubikey.settings.configuration.idProduct;
                  };
                  udev = {
                    enable = cfg.builder.security.modules.yubikey.settings.udev.enable;
                  };
                  touchDetector = {
                    enable = cfg.builder.security.modules.yubikey.settings.touchDetector.enable;
                  };
                };
              };
            };
            /* inherit (cfg.builder.security) enable modules; */
          };
        }
      ]))
    ]);
  }
);
}
