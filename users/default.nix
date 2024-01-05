{pkgs, ...}: {
  users.users.null0x = {
    isNormalUser = true;
    description = "null0x";
    extraGroups = [
      "networkmanager"
      "wheel"
      "lp"
      "systemd-journal"
    ];

    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGqFEgpiJkaI1KV6h6N4uG+fyrkofhQT2pgjwI8wda6E+VWu8an5tfGGkg9GzNcJKF3aaAAwtsXiZas+CP82tyE="
    ];

    shell = pkgs.zsh;
  };

  programs = {
    zsh.enable = true;
  };
}
