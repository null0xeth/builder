{inputs, ...}: {
  flake.homeManagerModules = {
    extensions = {
      imports = [
        inputs.twixvim.homeManagerModules.default
      ];
    };
  };
}
