{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.roles.workstation.builder;
in {
  options.roles.workstation.builder = {
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
      presets.remote-builder = {
        enable = true;
        serverMode = true;
        name = "remote-builder";

        builder = {
          networking = {
            hostName = "honkbuilder";
            extraHosts = ''
              192.168.1.9 vip.chonk.city
            '';
          };

          fromHardwareConfig = {
            inherit (cfg.overrides) kernelModules initrd;
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

          # hardware = {
          #   basics = {
          #     audio.enable = false;
          #     bluetooth.enable = false;
          #     storage.enable = true;
          #   };
          #   cpu = {
          #     brand = "intel";
          #     generation = 12;
          #     sub-type = "mobile";
          #     useForGraphics = true;
          #   };
          #   functionality = {
          #     thunderbolt.enable = false;
          #     sensors.enable = false;
          #     logitech.enable = false;
          #   };
          # };

          kernel = {
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
            settings = {
              base = "gtk";
              dbus.enable = true;
            };
            xserver = {
              base = {
                enable = false;
                exportConfiguration.enable = false;
                hyperlandSupport.enable = false;
                libinput.enable = false;
              };
              desktopManager = {
                enable = false;
                active = "gnome";
              };
              displayManager = {
                enable = false;
                active = "gdm";
              };
            };
          };

          system = {
            serverMode = true;
            firmware = {
              enable = false;
              fwupd = false;
            };
            fonts = {
              enable = false;
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
            utilities = {
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
