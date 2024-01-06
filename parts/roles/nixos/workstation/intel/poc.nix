{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.roles.workstation.poc;
in {
  options.roles.workstation.poc = {
    enable = mkEnableOption "";
    overrides = {
      kernelModules = mkOption {
        type = types.nullOr (types.listOf types.str);
        description = "Kernel modules to be installed";
        default = [];
      };
      initrd = {
        availableKernelModules = mkOption {
          type = types.nullOr (types.listOf types.str);
          description = "Kernel modules to be installed";
          default = [];
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      presets.proofOfConcept = {
        enable = true;
        name = "proofOfConcept";

        builder = {
          networking = {
            enable = true;
            hostName = "the-backrooms";
            extraHosts = ''
              192.168.1.9 vip.chonk.city
            '';
          };

          fromHardwareConfig = {
            inherit (cfg.overrides) kernelModules initrd;
            enable = true;
            hostArch = "x86_64-linux";
            fileSystems = {
              "/" = {
                device = "/dev/disk/by-uuid/01f1cf1e-4344-4940-aa10-bdc16c187711";
                fsType = "ext4";
              };

              "/boot" = {
                device = "/dev/disk/by-uuid/11C2-7FEB";
                fsType = "vfat";
              };
            };
            swapDevices = [
              {
                device = "/dev/disk/by-uuid/81cc56c3-21a9-4dfb-8b99-649f41aabf94";
              }
            ];
          };

          hardware = {
            enable = true;
            serverMode = false;
            basics = {
              audio.enable = true;
              bluetooth.enable = true;
              storage.enable = true;
            };
            cpu = {
              brand = "intel";
              generation = 12;
              sub-type = "mobile";
              #useForGraphics = true;
            };
            functionality = {
              thunderbolt.enable = true;
              sensors.enable = true;
              logitech.enable = true;
            };
          };

          kernel = {
            enable = true;
            settings = {
              useLatest = true;
              kernelParams = {
                useDefaults = true;
              };
            };
            tweaks = {
              networking.enable = true;
              hardening.enable = true;
              failsaves.enable = true;
              clean.enable = true;
            };
            boot = {
              settings = {
                general = {
                  silent = false;
                };
                tmpfs = {
                  enable = false;
                };

                loader = {
                  systemd-boot = {
                    enable = true;
                    configurationLimit = 5;
                  };

                  timeout = 3;
                  efiSupport.enable = true;
                  copyToTmpfs.enable = false;
                };
              };
              stages = {
                stage1 = {
                  initrd = {
                    systemd.enable = true;
                    kernelModules = [];
                    inherit (cfg.overrides.initrd) availableKernelModules;
                  };
                };
                stage2 = {
                  inherit (cfg.overrides) kernelModules;
                };
              };
            };
          };

          graphical = {
            enable = false;
            base = "gtk";

            settings = {
              system = {
                dbus.enable = true;
              };
              xserver = {
                enable = true;
                extra = {
                  exportConfiguration.enable = true;
                  hyperlandSupport.enable = true;
                };
                libinput = {
                  enable = true;
                };

                desktopManager = {
                  enable = true;
                  active = "gnome";
                };
                displayManager = {
                  enable = true;
                  active = "gdm";
                };
              };
            };
          };

          system = {
            enable = true;
            profile = {
              firmware = {
                enable = true;
                automatic-updates = {
                  enable = true;
                };
              };
            };
            fonts = {
              enable = true;
              packages = with pkgs; [
                # Icon fonts:
                material-symbols

                # Normal fonts:
                font-awesome
                jost
                lexend
                noto-fonts
                noto-fonts-cjk
                noto-fonts-emoji
                roboto

                # NerdFonts:
                (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono"];})
              ];
              defaults = {
                serif = ["Noto Serif" "Noto Color Emoji"];
                sansSerif = ["Noto Sans" "Noto Color Emoji"];
                monospace = ["JetBrainsMono Nerd Font" "Noto Color Emoji"];
                emoji = ["Noto Color Emoji"];
              };
            };
            sysutils = {
              enable = true;
              tools = {
                common.enable = true;
                direnv.enable = true;
                envfs.enable = true;
                ld.enable = true; # no point
              };
            };
          };

          security = {
            enable = true;
            modules = {
              agenix = {
                enable = true;
              };
              yubikey = {
                enable = true;
                settings = {
                  configuration = {
                    idVendor = "1050";
                    idProduct = "0407";
                  };
                  udev = {
                    enable = true;
                  };
                  touchDetector = {
                    enable = true;
                  };
                };
              };
            };
          };
        };
      };
    }
  ]);
}
