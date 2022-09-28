{ config, pkgs, userinfo, atomi, ... }:

##############################
# Import additional modules  #
##############################

let lib = import ./lib.nix { inherit pkgs; }; in
with (with lib;{ inherit zshCustomPlugins liveAutoComplete; });
with pkgs;

{
  #########################
  # Install packages here #
  #########################
  home.packages = [

    # System requirements
    uutils-coreutils

    # ESD Tooling
    kubernetes-helm
    kubelogin-oidc
    cachix
    kubectl
    docker
    awscli2

    # apps
    vscode
  ];

  ############
  # Services #
  ############
  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableExtraSocket = true;
    };
  };

  ##################################################
  # Addtional environment variables for your shell #
  ##################################################
  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  #################################
  # Addtional PATH for your shell #
  #################################
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.krew/bin"
  ];

  ##########################
  # Program Configurations #
  ##########################
  programs = {

    # Git Configurations
    git = {
      enable = true;
      userEmail = "${userinfo.email}";
      userName = "${userinfo.gituser}";
      extraConfig = {
        init.defaultBranch = "main";
      };
      lfs = {
        enable = true;
      };
    };

    # Shell Configurations
    zsh = {

      enable = true;
      enableCompletion = false;

      # Add ~/.zshrc here
      initExtra = ''
        # This is to initialize nix
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
        if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi

        # This is to fix auto-completion
        zstyle ':completion:*:*:man:*:*' menu select=long search
      '';

      # Oh-my-zsh configurations
      oh-my-zsh = {
        enable = true;
        extraConfig = ''
          ZSH_CUSTOM="${zshCustomPlugins}"
          zstyle ':completion:*:*:man:*:*' menu select=long search
          zstyle ':autocomplete:*' recent-dirs zoxide
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
        configterm = "POWERLEVEL9K_CONFIG_FILE=\"$HOME/home-manager-config/p10k-config/.p10k.zsh\" p10k configure";
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

      # ZSH ZPlug Plugins
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
    # Enable GPG
    gpg = {
      enable = true;
    };

    # Enable SSH
    ssh = {
      enable = true;
    };

    # Enable bat
    bat = {
      enable = true;
    };

    # enable exa
    exa = {
      enable = true;
      enableAliases = true;
    };

    # enable fzf
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    # enable zoxide
    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };
  };



}
