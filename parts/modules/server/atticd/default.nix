{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.serverModules.atticd;
in {
  options.serverModules.atticd = {
    enable = mkEnableOption "the attic binary cache daemon";

    credentials = mkOption {
      type = types.nullOr types.path;
      description = ''
        The absolute path to the atticd credentials file
      '';
    };

    deployment = {
      mode = mkOption {
        type = types.enum ["monolithic" "api-server" "garbage-collector"];
        description = ''
          Mode in which to run the server.

          'monolithic' runs all components, and is suitable for single-node deployments.

          'api-server' runs only the API server, and is suitable for clustering.

          'garbage-collector' only runs the garbage collector periodically.

          A simple NixOS-based Attic deployment will typically have one 'monolithic' and any number of 'api-server' nodes.

          There are several other supported modes that perform one-off operations, but these are the only ones that make sense to run via the NixOS module.
        '';
        default = "monolithic";
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      services.atticd = {
        enable = true;
        credentialsFile = mkIf (cfg.credentials != null) cfg.credentials;
        mode = cfg.deployment.mode;
        settings = {
          listen = "[::]:8080";

          # Data chunking
          #
          # Warning: If you change any of the values here, it will be
          # difficult to reuse existing chunks for newly-uploaded NARs
          # since the cutpoints will be different. As a result, the
          # deduplication ratio will suffer for a while after the change.
          chunking = {
            # The minimum NAR size to trigger chunking
            #
            # If 0, chunking is disabled entirely for newly-uploaded NARs.
            # If 1, all NARs are chunked.
            nar-size-threshold = 64 * 1024; # 64 KiB

            # The preferred minimum size of a chunk, in bytes
            min-size = 16 * 1024; # 16 KiB

            # The preferred average size of a chunk, in bytes
            avg-size = 64 * 1024; # 64 KiB

            # The preferred maximum size of a chunk, in bytes
            max-size = 256 * 1024; # 256 KiB
          };
        };
      };
    }
  ]);
}
