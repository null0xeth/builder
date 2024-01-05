{
  withSystem,
  inputs,
  self,
  ...
}: let
  sharedModules = builtins.attrValues self.nixosModules;
in {
  flake = {
    nixosConfigurations = {
      the-backrooms = withSystem "x86_64-linux" ({inputs', ...}:
        inputs.nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs inputs';
          };
          modules = sharedModules;
        });
    };
  };
}
