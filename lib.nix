{ pkgs }:
{
  zshCustomPlugins = pkgs.stdenv.mkDerivation {
    name = "oh-my-zsh-custom-dir";
    src = ./zsh_custom;
    installPhase = ''
      mkdir -p $out/
      cp -rv $src/* $out/
    '';
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
