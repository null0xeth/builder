{
  pkgs,
  inputs,
  ...
}: {
  users.users.null0x = {
    isNormalUser = true;
    description = "null0x";
    extraGroups = [
      "networkmanager"
      "wheel"
      "lp"
      "systemd-journal"
      "atticd"
    ];

    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGqFEgpiJkaI1KV6h6N4uG+fyrkofhQT2pgjwI8wda6E+VWu8an5tfGGkg9GzNcJKF3aaAAwtsXiZas+CP82tyE="
    ];

    shell = pkgs.zsh;
  };

  services.openssh.enable = true;
  environment.systemPackages = with pkgs; [git vim];
  programs = {
    zsh.enable = true;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs;};
    users.null0x = {imports = [./home.nix];};
  };
}
