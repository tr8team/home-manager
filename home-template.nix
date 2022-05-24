{ config, pkgs, userinfo, atomi, ... }:

let complex =  import ./complex.nix { inherit pkgs; }; in 

with (
  with complex; 
  { inherit setup-devbox-server customDir linuxService liveAutoComplete;  }
); 

with pkgs;

# GUI applications
let apps = [
  vscode
]; in

# CLI tools
let tools = [

  # Core Utils
  uutils-coreutils

  # DevOps tooling
  cachix
  kubectl
  docker
  awscli2
  atomi.awsmfa

  # Setup
  setup-devbox-server

]; in
{
  home.packages = (if userinfo.remote then tools else tools ++ apps);
  services = (if userinfo.linux then linuxService else { });
  programs = complex.programs // {
    # Git Configurations
    git = {

      enable = true;
      userEmail = "${userinfo.email}";
      userName = "${userinfo.gituser}";
      
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = false;
        pull.ff = "only";
      };
      
      includes = [
        { path = "$HOME/.gitconfig"; }
      ];
      
      lfs = {
        enable = true;
      };

    };

    zsh = {

      enable = true;
      enableCompletion = false;

      # ZSH configurations
      initExtra = ''
        if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi
        PATH="$PATH:/$HOME/.local/bin"
        export NIXPKGS_ALLOW_UNFREE=1
        unalias gm
        export AWS_PROFILE=default-mfa
      '';

      # Oh-my-zsh configurations

      oh-my-zsh = {
        enable = true;
        extraConfig = ''
          ZSH_CUSTOM="${customDir}"
        '';
        plugins = [
          "git"
          "docker"
          "kubectl"
          "pls"
          "aws"
        ];
      };

      # Aliases
      shellAliases = {
        cat = "bat -p";
        hms = "home-manager switch --impure --flake $HOME/home-manager-config#$USER";
        hmsz = "home-manager switch --impure --flake $HOME/home-manager-config#$USER && source ~/.zshrc";
      };

      plugins = [
        # p10k config
        {
          name = "powerlevel10k-config";
          src = ./p10k-config;
          file = ".p10k.zsh";
        }
        # live autocomplete
        liveAutoComplete
      ];

      zplug = {
        enable = true;
        plugins = [
          # Exa auto completes
          {
            name = "ogham/exa";
            tags = [ use:completions/zsh ];
          }
          # alt j to do JQ querry
          {
            name = "reegnz/jq-zsh-plugin";
          }
          # make sound when commands longer than 15 seconds completed
          {
            name = "kevinywlui/zlong_alert.zsh";
          }
          # remind you you have aliases
          {
            name = "djui/alias-tips";
          }
          # themes
          {
            name = "romkatv/powerlevel10k";
            tags = [ as:theme depth:1 ];
          }
        ];
      };
    };


  };



}
