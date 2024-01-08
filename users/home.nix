{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.self.homeManagerModules.extensions
    ../home/direnv
    ../home/git.nix
  ];

  # Be kind to systemD:
  targets.genericLinux.enable = true;
  systemd.user.startServices = "sd-switch";

  ## NIX CONFIG:
  nix = {
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
    };
  };
  ##

  # Home-Manager configuration:
  home = {
    username = "null0x";
    homeDirectory = "/home/null0x";
    sessionPath = ["/run/current-system/sw/bin" "/etc/profiles/per-user/null0x/bin"];
    stateVersion = "24.05";

    # Packages that should be installed by HM:
    packages = with pkgs; [
      rage
      cached-nix-shell
      nurl # fetchgit hashes
      nix-tree
      nix-init
      nix-prefetch-git
      nnn
      material-icons
      tree
      lens
      gh
    ];

    ## NIX CONFIG:
    sessionVariables.NIX_PATH = "nixpkgs=flake:nixpkgs$\{NIX_PATH:+:$NIX_PATH}";
  };

  programs.home-manager.enable = true;
  modules.twixvim = {
    enable = true;
    settings = {
      configuration = {
        enable = false;
        path = ../../config.lua;
      };
      development = {
        enable = false;
      };
    };
  };
}
