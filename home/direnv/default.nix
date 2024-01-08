_: {
  home = {
    sessionVariables = {
      DIRENV_LOG_FORMAT = "";
    };
  };
  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    bash = {
      enable = true;
      bashrcExtra = ''
        eval "$(direnv hook bash)"
      '';
    };
    zsh = {
      enable = true;
      initExtra = ''
        eval "$(direnv hook zsh)"
      '';
    };
  };
}
