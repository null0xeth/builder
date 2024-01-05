{inputs, ...}:
#let
# sharedModules = with inputs; [
#   agenix.nixosModules.default
#   agenix-rekey.nixosModules.agenixRekey
#   hyprland.nixosModules.default
#   home-manager.nixosModules.home-manager
#   nh.nixosModules.default
#   srvos.nixosModules.mixins-tracing
# ];
#in
{
  flake.nixosModules = {
    # extensions = {
    #   imports = sharedModules;
    # };
    hosts = {
      imports = [../hosts];
    };
    roles = {
      imports = [./roles/nixos/workstation/intel/poc.nix];
    };
    users = {
      imports = [../users];
    };
  };
}
