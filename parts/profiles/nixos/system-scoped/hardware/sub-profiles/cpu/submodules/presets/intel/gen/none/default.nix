{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hardware-cpu-presets.none-none-69th;
in {
  imports = [../../template.nix];
  options.hardware-cpu-presets.none-none-69th = {
    enable = mkEnableOption "enable a pre-configured profile for intel 11th generation CPUs";
  };
  config = mkIf cfg.enable {};
}
