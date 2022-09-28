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
      rev = "f52f45a49d2df31e7d7aff1fb599c89b1eacbcef";
      sha256 = "sha256-SmLnp+ccqtYQEzIUbHcyB8Y+mR/6gcf4zjQw9rDGgSg=";
    };
  };
}
