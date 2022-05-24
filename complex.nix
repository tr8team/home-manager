{ pkgs }:
{
  setup-keys = import ./modules/setup-keys.nix { inherit pkgs; };
  set-signing-key = import ./modules/set-signing-key.nix { inherit pkgs; };
  setup-devbox-server = import ./modules/setup-devbox-server.nix { inherit pkgs; };
  get-uuid = import ./modules/get-uuid.nix { inherit pkgs; };
  register-with-github = import ./modules/register-with-github.nix { inherit pkgs; };
  customDir = pkgs.stdenv.mkDerivation {
    name = "oh-my-zsh-custom-dir";
    src = ./zsh_custom;
    installPhase = ''
      mkdir -p $out/
      cp -rv $src/* $out/
    '';
  };

  linuxService = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableExtraSocket = true;
    };
  };

  programs = {
    home-manager = {
      enable = true;
    };
    gpg = {
      enable = true;
    };
    ssh = {
      enable = true;
    };
    bat = {
      enable = true;
    };
    exa = {
      enable = true;
      enableAliases = true;
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };
  };
  liveAutoComplete = {
    name = "zsh-autocomplete";
    file = "zsh-autocomplete.plugin.zsh";
    src = pkgs.fetchFromGitHub {
      owner = "marlonrichert";
      repo = "zsh-autocomplete";
      rev = "39423112977a8c520962bc11c46ee31e7ca873ca";
      sha256 = "sha256-+UziTYsjgpiumSulrLojuqHtDrgvuG91+XNiaMD7wIs=";
    };
  };
}
