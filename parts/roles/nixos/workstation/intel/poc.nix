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
            hostName = "honkbuilder";
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
                device = "/dev/disk/by-uuid/56407bcf-37f9-4e4b-b3e7-c4efb9e6d327";
                fsType = "ext4";
              };

              "/boot" = {
                device = "/dev/disk/by-uuid/2C71-55D3";
                fsType = "vfat";
              };
            };
            swapDevices = [];
          };

          hardware = {
            enable = true;
            core = {
              enable = false;
              audio.enable = false;
              bluetooth.enable = false;
              storage.enable = false;
            };
            profile = {
              enable = true;
              #cpu = {
              ##enable = false;
              # brand = "virtio";
              # generation = 12;
              # sub-type = "virtual";
              #};
            };
            optionals = {
              enable = false;
              thunderbolt.enable = false;
              sensors.enable = false;
              logitech.enable = false;
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
            enable = true;
            base = "gtk";

            settings = {
              system = {
                dbus.enable = true;
              };
              xserver = {
                enable = true;
                extra = {
                  exportConfiguration.enable = true;
                  hyperlandSupport.enable = false;
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
            # profile = {
            #   firmware = {
            #     enable = true;
            #     automatic-updates = {
            #       enable = true;
            #     };
            #   };
            # };
            fonts = {
              enable = false;
              # packages = with pkgs; [
              #   # Icon fonts:
              #   material-symbols

              #   # Normal fonts:
              #   font-awesome
              #   jost
              #   lexend
              #   noto-fonts
              #   noto-fonts-cjk
              #   noto-fonts-emoji
              #   roboto

              #   # NerdFonts:
              #   (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono"];})
              # ];
              # defaults = {
              #   serif = ["Noto Serif" "Noto Color Emoji"];
              #   sansSerif = ["Noto Sans" "Noto Color Emoji"];
              #   monospace = ["JetBrainsMono Nerd Font" "Noto Color Emoji"];
              #   emoji = ["Noto Color Emoji"];
              # };
            };
            sysutils = {
              enable = false;
              # tools = {
              #   common.enable = true;
              #   direnv.enable = true;
              #   envfs.enable = true;
              #   ld.enable = true; # no point
              # };
            };
          };

          security = {
            enable = true;
            modules = {
              agenix = {
                enable = false;
              };
              yubikey = {
                enable = false;
                settings = {
                  configuration = {
                    idVendor = "1050";
                    idProduct = "0407";
                  };
                  udev = {
                    enable = false;
                  };
                  touchDetector = {
                    enable = false;
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
