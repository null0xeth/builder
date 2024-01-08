{inputs, ...}: let
  sharedModules = with inputs; [
    #agenix.nixosModules.default
    #agenix-rekey.nixosModules.agenixRekey
    home-manager.nixosModules.home-manager
    nh.nixosModules.default
  ];
in {
  flake.nixosModules = {
    extensions = {
      imports = sharedModules;
    };
    hosts = {
      imports = [../hosts];
    };
    roles = {
      imports = [./roles/nixos/workstation/intel];
    };
    users = {
      imports = [../users];
    };
  };
}
