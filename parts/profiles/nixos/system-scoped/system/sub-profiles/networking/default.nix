{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  # filterfunc = set: builtins.head (builtins.attrNames (lib.filterAttrs (n: _: set.${n}.enable) set));
  # cfg = config.profiles.networking.preset.${filterfunc config.profiles.networking.preset};
  #cfg1 = config.profiles.networking.preset;
  #filter = filterAttrs (name: _: name.enable) base;
  #names = builtins.attrNames filter;
  #allPresets = builtins.mapAttrs (_: config: config.name) base;
  #activePresets = lib.filterAttrs (_: config: config.enable) allPresets;
  #activePresetNames = builtins.attrValues (builtins.mapAttrs (_: config: config.name) activePresets);
  #cfg = base."${builtins.head (builtins.attrNames allPresets)}";
  #filter = builtins.head (builtins.attrNames (lib.filterAttrs (name: value: preset.${value}.enable) config.profiles.networking));
  #active = builtins.head (builtins.attrNames filter);
  #cfg = config.presets.${active};
  cfg = config.profiles.networking.preset;
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

        config = mkMerge [
          {
            name = mkDefault name;
          }
        ];
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
