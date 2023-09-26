{ config, pkgs, userinfo, atomi, ... }:

####################
# Upstream Mutator #
####################

let mutator = import ./upstream.nix; in

##############################
  # Import additional modules  #
  ##############################

let lib = import ./lib.nix { inherit pkgs; }; in
with (with lib;{ inherit zshCustomPlugins liveAutoComplete; });
with pkgs;

let output = {
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

    # apps
    vscode
  ];
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
    "$PATH:/Users/vivaldiibeliochandra/.npm"
    "$HOME/miniconda/bin:$PATH"
    "$PATH:/Users/vivaldiibeliochandra/Library/Android/sdk/platform-tools/"
    "$PATH:/Users/vivaldiibeliochandra/flutter/bin/cache/dart-sdk/bin"
    "$PATH:/Users/vivaldiibeliochandra/flutter/bin"
    "$PATH:/Users/vivaldiibeliochandra/.composer/vendor/bin"
    "$PATH:/Users/vivaldiibeliochandra/flutter/.pub-cache/bin"
    "'$PATH':'$HOME/.pub-cache/bin'"
    "'$PATH:/usr/lib/dart/bin'"
    "$HOME/.fastlane/bin:$PATH"
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
        push.autoSetupRemote = "true";
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
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

        export AWS_PROFILE=default
        function update-aws-mfa-token() {
          bash ~/update-aws-cli-mfa-token.sh -u tr8ibelio -t $1
          echo "Successfully updated mfa token!"
        }
        alias mfa=update-aws-mfa-token

        export GOTRADE_BASTION_IP=\"54.255.27.224\"

        export HISTTIMEFORMAT=%F

        eval "$(rbenv init -)"

        echo "pinentry-program $(brew --prefix)/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
        killall gpg-agent
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
        git-delete-merged-branch = "git branch --merged | egrep -v \"(^\*|master|dev)\" | xargs git branch -d";

        # rtunnel
        rtunnel-db-tradecharlie = "ssh -i ~/.ssh/aws-sg-tr8.pem -N -L 13306:tradecharlie-db.c9ilcrldgvqh.ap-southeast-1.rds.amazonaws.com:3306 ubuntu@$GOTRADE_BASTION_IP";
        rtunnel-db-tradecrm = "ssh -i ~/.ssh/aws-sg-tr8.pem -N -L 13307:tradecrm-staging-db.c9ilcrldgvqh.ap-southeast-1.rds.amazonaws.com:3306 ubuntu@$GOTRADE_BASTION_IP";
        rtunnel-db-tr8stock = "ssh -i ~/.ssh/aws-sg-tr8.pem -N -L 13308:tr8stock-staging-db.c9ilcrldgvqh.ap-southeast-1.rds.amazonaws.com:3306 ubuntu@$GOTRADE_BASTION_IP";
        rtunnel-db-tr8logging = "ssh -i ~/.ssh/aws-sg-tr8.pem -N -L 13309:logging-staging-db.c9ilcrldgvqh.ap-southeast-1.rds.amazonaws.com:3306 ubuntu@$GOTRADE_BASTION_IP";
        rtunnel-db-gti-staging = "ssh -i ~/.ssh/aws-sg-tr8-sha2.pem -N -L 13320:gti-staging-db-v2.c9ilcrldgvqh.ap-southeast-1.rds.amazonaws.com:3306 ubuntu@54.151.194.149";
        rtunnel-db-gotradeindo-crm-staging = "ssh -i ~/.ssh/aws-sg-tr8-sha2.pem -N -L 13321:gti-staging-tradecrm.c9ilcrldgvqh.ap-southeast-1.rds.amazonaws.com:3306 ubuntu@ec2-54-151-194-149.ap-southeast-1.compute.amazonaws.com";

        # Alias AWS
        ssm-gotrade-a = "aws ssm start-session --target i-096e34cb28bfd435d";
        ssm-indogotrade-a = "aws ssm start-session --target i-025aaf1c45ed93bc5";
        ssm-logging-a = "aws ssm start-session --target i-0782e8a9c2a3363ae";
        ssm-stock-a = "aws ssm start-session --target i-0eb22b849504985de";

        # Alias AWS Prod
        ssm-prod-indogotrade = "aws ssm start-session --target i-078657840f061ce16 --region ap-southeast-3";
        ssm-prod-gotrade-a = "aws ssm start-session --target i-08795e35ca86cdadd";

        # Temporary fix for fastlane iOS upload
        # https://github.com/fastlane/fastlane/issues/20741
        ITMSTRANSPORTER_FORCE_ITMS_PACKAGE_UPLOAD = "true";
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
          # {
          #   name = "ogham/exa";
          #   tags = [ use:completions/zsh ];
          # }
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
}; in
mutator { outputs = output; system = userinfo.system; nixpkgs = pkgs; }
