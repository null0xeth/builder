{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  # filterfunc = set: builtins.head (builtins.attrNames (lib.filterAttrs (n: _: set.${n}.enable) set));
  # cfg = config.profiles.networking.preset.${filterfunc config.profiles.networking.preset};
  base = config.profiles.networking.preset;
  #allPresets = builtins.mapAttrs (_: config: config.name) base;
  #activePresets = lib.filterAttrs (_: config: config.enable) allPresets;
  #activePresetNames = builtins.attrValues (builtins.mapAttrs (_: config: config.name) activePresets);
  #cfg = base."${builtins.head (builtins.attrNames allPresets)}";

  filter = lib.filterAttrs (name: _: builtins.elem name base);
  active = builtins.head (builtins.attrNames filter);
  cfg = config.profiles.networking.preset.${active};
in {
  options.profiles.networking = {
    preset = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          enable = mkEnableOption "the default graphical networking template";
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
      });
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
      networking.useNetworkd = true;
      networking.useDHCP = mkDefault false;

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
