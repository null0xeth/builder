{inputs, ...}: {
  flake.homeManagerModules = {
    # default = {
    #  imports = [../modules/home];
    # };
    extensions = {
      imports = [
        inputs.twixvim.homeManagerModules.default
      ];
    };
  };
}
