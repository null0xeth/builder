{
  withSystem,
  inputs,
  self,
  ...
}: {
  flake = {
    nixosConfigurations = {
      honkbuilder = withSystem "x86_64-linux" ({inputs', ...}:
        inputs.nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs inputs';
          };
          modules = [
            # inputs.agenix.nixosModules.default
            # inputs.agenix-rekey.nixosModules.agenixRekey
            self.nixosModules.byosBuilder
            self.nixosModules.hosts
            self.nixosModules.users
            self.nixosModules.roles
          ];
        });
    };
  };
}
