{
  description = "Home Manager configuration for GoTrade";

  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { home-manager, ... }:
    let user = import ./user_config.nix; in
    let atomi = import (fetchTarball "https://github.com/kirinnee/test-nix-repo/archive/refs/tags/v9.1.0.tar.gz"); in
    let homeDir = (if user.linux then "/home/${user.user}" else "/Users/${user.user}"); in
    {
      homeConfigurations = {
        "${user.user}" = home-manager.lib.homeManagerConfiguration {
          configuration = import ./home-template.nix;
          system = user.system;
          username = user.user;
          homeDirectory = homeDir;
          stateVersion = "21.11";
          extraSpecialArgs = {
            userinfo = user;
            inherit atomi;
          };
        };
      };
    };
}
