{inputs, ...}: {
  flake.homeManagerModules = {
    default = {
      imports = [../modules/home];
    };
    extensions = {
      imports = [
        inputs.hyprland.homeManagerModules.default
        inputs.nix-index-database.hmModules.nix-index
        inputs.anyrun.homeManagerModules.default
        inputs.twixvim.homeManagerModules.default
      ];
    };
  };
}
