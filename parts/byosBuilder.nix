{moduleWithSystem, ...}: {
flake.nixosModules.byosBuilder = moduleWithSystem (
  perSystem@{ self' }:
  { config, lib, ...}:
with lib; let
  filterfunc = set: builtins.head (builtins.attrNames (lib.filterAttrs (n: _: set.${n}.enable) set));
  cfg = config.presets.${filterfunc config.presets};
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
    type = types.attrsOf (types.submodule {
      options = {
        enable = mkEnableOption "the preset builder";
        name = mkOption {
          type = types.str;
          description = mdDoc "The slug used to refer to preset";
          default = "bobTheBuilder";
        };
        builder = mkOption {
          type = types.submodule {
            options = {
              networking = mkOption {
                type = types.submodule {
                  options = {
                    enable = mkEnableOption "tba";
                    hostName = mkOption {
                      type = types.str;
                      description = mdDoc "The hostname of the to-be configured system";
                      default = "honkmaster-007";
                    };
                    extraHosts = mkOption {
                      type = types.nullOr types.lines;
                      description = mdDoc "Extra hosts to add to /etc/hosts";
                    };
                  };
                };
              };
              fromHardwareConfig = mkOption {
                type = types.submodule {
                  options = {
                    enable = mkEnableOption "tba";
                    hostArch = mkOption {
                      type = types.str;
                      default = "x86_64-linux";
                    };
                    kernelModules = mkOption {
                      type = types.nullOr (types.listOf types.str);
                      description = mdDoc "add kernelModules from ur Hardware-config.nix";
                    };
                    initrd = mkOption {
                      type = types.submodule {
                        options = {
                          availableKernelModules = mkOption {
                            type = types.nullOr (types.listOf types.str);
                            description = mdDoc "add initrd kernelModules from ur Hardware-config.nix";
                          };
                        };
                      };
                    };
                    fileSystems = mkOption {
                      type = types.lazyAttrsOf types.anything;
                    };
                    swapDevices = mkOption {
                      type = with types; nullOr (listOf (submodule {
                        options = {
                          device = mkOption {
                            type = path;
                          };
                        };
                      }));
                    };
                  };
                };
              };

              hardware = mkOption {
                type = types.submodule {
                  options = {
                    enable = mkEnableOption "tba";
                    serverMode = mkEnableOption "tba";
                    basics = mkOption {
                      type = types.submodule {
                        options = {
                          enable = mkOption {
                            type = types.bool;
                            default = !cfg.builder.hardware.serverMode;
                          };
                          audio = mkOption {
                            type = enableModule;
                          };
                          bluetooth = mkOption {
                            type = enableModule;
                          };
                          storage = mkOption {
                            type = enableModule;
                            # TODO: more details related to ssd
                          };
                        };
                      };
                    };
                    cpu = mkOption {
                      type = types.submodule {
                        options = {
                          enable = mkOption {
                            type = types.bool;
                            default = !cfg.builder.hardware.serverMode;
                          };
                          brand = mkOption {
                            type = types.enum ["intel" "amd"];
                            default = "intel";
                            description = "Please select the type of CPU you have (intel/amd)";
                          };

                          generation = mkOption {
                            # cpu generation
                            type = types.int;
                            default = 0;
                            description = "Specify the CPU generation you have (intel only)";
                          };
                          sub-type = mkOption {
                            type = types.enum ["mobile" "desktop"];
                            description = mdDoc "The type of CPU installed [desktop|mobile]";
                            default = "mobile";
                          };
                          #useForGraphics = mkEnableOption "use the integrated graphics of the CPU";
                        };
                      };
                    };

                    functionality = mkOption {
                      type = types.submodule {
                        options = {
                          enable = mkOption {
                            type = types.bool;
                            default = !cfg.builder.hardware.serverMode;
                          };
                          thunderbolt = mkOption {
                            type = enableModule;
                          };
                          sensors = mkOption {
                            type = enableModule;
                          };
                          logitech = mkOption {
                            type = enableModule;
                          };
                        };
                      };
                    };
                  };
                };
              };

              kernel = mkOption {
                type = types.submodule {
                  options = {
                    enable = mkEnableOption "tba";
                    settings = mkOption {
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
                            type = types.submodule {
                              options = {
                                useDefaults = mkEnableOption "the default kernel parameters";
                                customParams = mkOption {
                                  type = types.nullOr (types.listOf types.str);
                                  description = "Kernel parameters";
                                  default = null;
                                };
                              };
                            };
                          };
                        };
                      };
                    };

                    tweaks = mkOption {
                      type = types.submodule {
                        options = {
                          networking = mkOption {
                            type = enableModule;
                          };
                          hardening = mkOption {
                            type = enableModule;
                          };
                          failsaves = mkOption {
                            type = enableModule;
                          };
                          clean = mkOption {
                            type = enableModule;
                          };
                        };
                      };
                    };

                    boot = mkOption {
                      type = types.submodule {
                        options = {
                          settings = mkOption {
                            type = types.submodule {
                              options = {
                                general = mkOption {
                                  type = types.submodule {
                                    options = {
                                      silent = mkEnableOption "silence the console logs";
                                    };
                                  };
                                };

                                tmpfs = mkOption {
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
                                  type = types.submodule {
                                    options = {
                                      efiSupport = mkOption {
                                        type = enableModule;
                                      };
                                      timeout = mkOption {
                                        type = types.int;
                                        default = 3;
                                        description = mdDoc "the maximum allowed time in seconds to time out kernel operations";
                                      };
                                      copyToTmpfs = mkOption {
                                        type = enableModule;
                                      };
                                      systemd-boot = mkOption {
                                        type = types.submodule {
                                          options = {
                                            enable = mkEnableOption "use systemd boot";
                                            configurationLimit = mkOption {
                                              type = types.nullOr types.int;
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
                            type = types.submodule {
                              options = {
                                stage1 = mkOption {
                                  type = types.submodule {
                                    options = {
                                      initrd = mkOption {
                                        type = types.submodule {
                                          options = {
                                            systemd = mkOption {
                                              type = enableModule; # enable systemd in the first stage of booting.
                                            };
                                            kernelModules = mkOption {
                                              type = types.nullOr (types.listOf types.str);
                                              description = "Kernel modules to always be installed";
                                              default = null;
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
                      type = types.submodule {
                        options = {
                          system = mkOption {
                            type = types.submodule {
                              options = {
                                dbus = mkOption {
                                  type = enableModule;
                                };
                              };
                            };
                          };
                          xserver = mkOption {
                            type = types.submodule {
                              options = {
                                enable = mkEnableOption "xserver";
                                extra = mkOption {
                                  type = types.submodule {
                                    options = {
                                      exportConfiguration = mkOption {
                                        type = enableModule;
                                      };
                                      hyperlandSupport = mkOption {
                                        type = enableModule;
                                      };
                                    };
                                  };
                                };
                                libinput = mkOption {
                                  type = enableModule;
                                };
                                desktopManager = mkOption {
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
                type = types.submodule {
                  options = {
                    enable = mkEnableOption "tba";
                    profile = mkOption {
                      type = types.submodule {
                        options = {
                          firmware = mkOption {
                            type = types.submodule {
                              options = {
                                enable = mkEnableOption "the firmware configuration module";
                                automatic-updates = mkOption {
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
                      type = types.submodule {
                        options = {
                          enable = mkEnableOption "the font configuration module";
                          packages = mkOption {
                            type = with types; nullOr (listOf package);
                            description = mdDoc "Font packages to install";
                          };
                          defaults = mkOption {
                            type = types.submodule {
                              options = {
                                serif = mkOption {
                                  type = with types; nullOr (listOf str);
                                };
                                sansSerif = mkOption {
                                  type = with types; nullOr (listOf str);
                                };
                                monospace = mkOption {
                                  type = with types; nullOr (listOf str);
                                };
                                emoji = mkOption {
                                  type = with types; nullOr (listOf str);
                                };
                              };
                            };
                          };
                        };
                      };
                    };

                    sysutils = mkOption {
                      type = types.submodule {
                        options = {
                          enable = mkEnableOption "the system utilities module";
                          tools = mkOption {
                            type = types.submodule {
                              options = {
                                common = mkOption {
                                  type = enableModule;
                                };
                                direnv = mkOption {
                                  type = enableModule;
                                };
                                envfs = mkOption {
                                  type = enableModule;
                                };
                                ld = mkOption {
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
                type = types.submodule {
                  options = {
                    enable = mkEnableOption "tba";
                    modules = mkOption {
                      type = types.submodule {
                        options = {
                          agenix = mkOption {
                            type = enableModule;
                          };

                          yubikey = mkOption {
                            type = types.submodule {
                              options = {
                                enable = mkEnableOption "support for yubikey mfa";
                                settings = mkOption {
                                  type = types.submodule {
                                    options = {
                                      configuration = mkOption {
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
                                        type = enableModule;
                                      };
                                      touchDetector = mkOption {
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
    });
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
    (mkIf cfg.builder.networking.enable {
      profiles.networking.preset.${cfg.name} = {
        enable = true;
        hostName = mkIf (cfg.builder.networking.hostName != null) cfg.builder.networking.hostName;
        extraHosts = mkIf (cfg.builder.networking.extraHosts != null) cfg.builder.networking.extraHosts;
      };
    })

    # FS:
    (mkIf cfg.builder.fromHardwareConfig.enable {
      inherit (cfg.builder.fromHardwareConfig) fileSystems swapDevices;
      nixpkgs.hostPlatform = mkDefault "${cfg.builder.fromHardwareConfig.hostArch}";
    })

    # HW:
    (mkIf cfg.builder.hardware.enable (mkMerge [
      (mkIf cfg.builder.hardware.serverMode {
        profiles.hardware.preset.${cfg.name} = {
          enable = true;
          name = "${cfg.name}";
          profile = {
            cpu = {
              enable = false;
            };
          };
          core = {
            enable = false;
          };
          optionals = {
            enable = false;
          };
        }; 
      })

      (mkIf (!cfg.builder.hardware.serverMode) {
        profiles.hardware.preset.${cfg.name} = {
        enable = true;
        name = "${cfg.name}";
        profile = {
          inherit (cfg.builder.hardware) cpu;
        };
        core = {
          inherit (cfg.builder.hardware.basics) audio bluetooth storage;
        };
        optionals = {
          inherit (cfg.builder.hardware.functionality) thunderbolt sensors;
          peripherals.logitech = {
            inherit (cfg.builder.hardware.functionality.logitech) enable;
          };
        };
      };
      })
    ]))

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
            name = "${cfg.name}";
          };
        }

        (mkIf cfg.builder.system.profile.firmware.enable {
          profiles.system.preset.${cfg.name} = {
              inherit (cfg.builder.system) profile;
          };
        })
        (mkIf cfg.builder.system.fonts.enable {
          profiles.system.preset.${cfg.name} = {
            inherit (cfg.builder.system) fonts;
          };
        })
        (mkIf cfg.builder.system.sysutils.enable {
          profiles.system.preset.${cfg.name} = {
            inherit (cfg.builder.system) sysutils;
          };
        })
      ]))

      # Security:
      (mkIf cfg.builder.security.enable (mkMerge [
        {
          profiles.security.preset.${cfg.name} = {
            inherit (cfg.builder.security) enable modules;
          };
        }
      ]))
      ]);
    }
);
}