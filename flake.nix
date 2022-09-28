{
  description = "Home Manager configuration for GoTrade";

  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { home-manager, nixpkgs, ... }:
    let atomi = import (fetchTarball "https://github.com/kirinnee/test-nix-repo/archive/refs/tags/v9.1.0.tar.gz"); in

    # obtain user configurations
    let user = import ./user_config.nix; in

    # Operating system specific
    let darwinHome = "/Users/${user.user}"; in
    let darwinTemplate = ./home-template-darwin.nix; in

    let linuxHome = "/home/${user.user}"; in
    let linuxTemplate = ./home-template-linux.nix; in

    # Obtain operating system
    let darwin = nixpkgs.lib.strings.hasSuffix "darwin" user.system; in
    {
      homeConfigurations = {
        "${user.user}" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."${user.system}";
          modules = [
            (if darwin then darwinTemplate else linuxTemplate)
            {
              home = {
                username = user.user;
                homeDirectory = if darwin then darwinHome else linuxHome;
                stateVersion = "21.11";
              };
            }
          ];
          extraSpecialArgs = {
            userinfo = user;
            inherit atomi;
          };
        };
      };
    };
}
