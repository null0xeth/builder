{inputs, ...}: {
  flake.serverModules = {
    atticd = {
      imports = [
        inputs.attic.nixosModules.atticd
        ./modules/server/atticd
      ];
    };
  };
}
