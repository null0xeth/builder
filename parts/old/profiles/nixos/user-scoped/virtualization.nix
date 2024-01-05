{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.user-profiles.nixos.development.virtualization;
  currentUser = "null0x";
in {
  options = {
    user-profiles.nixos.development.virtualization = {
      enable = mkEnableOption "the virtualization profile";
      backend = mkOption {
        type = types.submodule {
          options = {
            containerRuntime = mkOption {
              type = types.enum ["docker" "podman"];
              default = "docker";
              description = mdDoc "The default container runtime to use for virtualization";
            };
            libvirtd = mkOption {
              type = types.submodule {
                options = {
                  enable = mkEnableOption "the libvirtd systemd service";
                  virtViewer = mkEnableOption "the virtual machine viewer";
                };
              };
            };
          };
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.backend.containerRuntime == "docker") {
      virtualisation = {
        docker.enable = true;
      };
    })
    (mkIf (cfg.backend.containerRuntime == "podman") {
      virtualisation = {
        docker.enable = true;
      };
    })
    (mkIf cfg.backend.libvirtd.enable (mkMerge [
      (mkIf cfg.backend.libvirtd.virtViewer {
        environment.systemPackages = [pkgs.virt-viewer];
        programs.virt-manager.enable = true;
      })
      {
        programs.dconf.enable = true;

        virtualisation = {
          libvirtd.enable = true;
        };

        users.users.${currentUser}.extraGroups = ["libvirtd"];

        home-manager.users.${currentUser} = {
          dconf.settings = {
            "org/virt-manager/virt-manager/connections" = {
              autoconnect = ["qemu:///system"];
              uris = ["qemu:///system"];
            };
          };
        };
      }
    ]))
  ]);
}
