{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  filterfunc = set: builtins.head (builtins.attrNames (lib.filterAttrs (n: _: set.${n}.enable) set));
  cfg = config.profiles.system.preset.${filterfunc config.profiles.system.preset};

  enableModule = lib.types.submodule {
    options = {
      enable = mkEnableOption "";
    };
  };
in {
  imports = [
    ./utils
    ./firmware
    ./networking
    ./submodules
  ];

  options.profiles.system = {
    preset = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          enable = mkEnableOption "the default system profile template";
          name = mkOption {
            type = types.str;
            description = mdDoc "The slug used to refer to this profile";
            default = "default-hardware-template";
          };
          profile = mkOption {
            type = types.submodule {
              options = {
                serverMode = mkEnableOption "";
                firmware = mkOption {
                  type = types.submodule {
                    options = {
                      enable = mkEnableOption "the firmware configuration module";
                      automatic-updates = {
                        enable = mkEnableOption "enable automatic firmware updates";
                      };
                      packages = mkOption {
                        type = with types; listOf package;
                        default = [];
                        description = mdDoc "Firmware packages to be installed";
                      };
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
                  type = with types; listOf package;
                  default = [];
                  description = mdDoc "Font packages to install";
                };
                defaults = mkOption {
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
      });
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.profile.firmware.enable {
      nixos-modules.system.firmware = {
        inherit (cfg.profile.firmware) enable packages automatic-updates;
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

    (mkIf cfg.serverMode {
      environment.systemPackages = with pkgs; [
        curl
        dnsutils
        gitMinimal
        htop
        jq
      ];

      users.mutableUsers = false;
      # Enable SSH everywhere
      services.openssh.enable = true;
      security.sudo.wheelNeedsPassword = false;
      # If the user is in @wheel they are trusted by default.
      nix.settings.trusted-users = ["root" "@wheel"];

      documentation.enable = lib.mkDefault false;
      documentation.info.enable = lib.mkDefault false;
      documentation.man.enable = lib.mkDefault false;
      documentation.nixos.enable = lib.mkDefault false;

      # Print the URL instead on servers
      environment.variables.BROWSER = "echo";

      systemd = {
        # Given that our systems are headless, emergency mode is useless.
        # We prefer the system to attempt to continue booting so
        # that we can hopefully still access it remotely.
        enableEmergencyMode = false;

        # For more detail, see:
        #   https://0pointer.de/blog/projects/watchdog.html
        watchdog = {
          # systemd will send a signal to the hardware watchdog at half
          # the interval defined here, so every 10s.
          # If the hardware watchdog does not get a signal for 20s,
          # it will forcefully reboot the system.
          runtimeTime = "20s";
          # Forcefully reboot if the final stage of the reboot
          # hangs without progress for more than 30s.
          # For more info, see:
          #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
          rebootTime = "30s";
        };

        sleep.extraConfig = ''
          AllowSuspend=no
          AllowHibernation=no
        '';
      };

      # use TCP BBR has significantly increased throughput and reduced latency for connections
      boot.kernel.sysctl = {
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
      };
    })
  ]);
}
