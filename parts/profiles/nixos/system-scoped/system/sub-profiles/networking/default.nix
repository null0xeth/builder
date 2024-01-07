{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  filterfunc = set: builtins.head (builtins.attrNames (lib.filterAttrs (n: _: set.${n}.enable) set));
  cfg = config.profiles.networking.preset.${filterfunc config.profiles.networking.preset};
  # cfg1 = config.profiles.networking.preset;
  # enabled = lib.filterAttrs (n: _: cfg1.${n}.enable) cfg1;
  # cfg = config.profiles.networking.preset.${builtins.head (builtins.attrNames enabled)};
in {
  options.profiles.networking = {
    preset = mkOption {
      default = {};
      type = types.attrsOf (types.submodule ({
        name,
        config,
        ...
      }: {
        options = {
          enable = mkEnableOption "the default graphical networking template";
          name = mkOption {
            type = types.str;
            default = name;
          };
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
      }));
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # Allow PMTU / DHCP
      environment.systemPackages = with pkgs; [mullvad-vpn libva-utils networkmanagerapplet];

      networking = {
        hostName = "${cfg.hostName}";
        firewall = {
          allowPing = true;
          logRefusedConnections = lib.mkDefault false;
        };
      };
      networking.useNetworkd = lib.mkDefault true;
      networking.useDHCP = lib.mkDefault false;

      systemd = {
        services = {
          NetworkManager-wait-online.enable = false;
          systemd-networkd.stopIfChanged = false;
          systemd-resolved.stopIfChanged = false;
        };
        network = {
          wait-online.enable = false;
        };
      };

      services.mullvad-vpn.enable = true;
    }
    (mkIf (cfg.extraHosts != null) {
      networking = {
        inherit (cfg) extraHosts;
      };
    })
  ]);
}
