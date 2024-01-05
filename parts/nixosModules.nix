{inputs, ...}: {
  flake.nixosModules = {
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
