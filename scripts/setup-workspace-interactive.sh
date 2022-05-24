#! /bin/sh

# clone my config
git clone https://github.com/tr8team/home-manager.git "$HOME/home-manager-config"
export NIXPKGS_ALLOW_UNFREE=1 && home-manager switch --impure --flake "home-manager-config#$USER"
