{
  description = "Example flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    # let
    #   lib = nixpkgs.lib;
    #   genHosts = lib.mapAttrs (host: host-conf:
    #     lib.nixosSystem {
    #       specialArgs = let
    #         system = host-conf.system;
    #         users = host-conf.users;
    #         # extraConfig = host-conf.extraConfig;
    #       in { inherit inputs home-manager system users; };
    #       modules = [ ./hosts/${host}.nix host-conf.extraConfig ];
    #     });
    # in {
    #   nixosConfigurations = genHosts
    #     (lib.filterAttrs (n: v: v.enable) (import ./hosts-configuration.nix));
    # };
    let
      hosts = nixpkgs.lib.filesystem.listFilesRecursive ./hosts;
      genHosts = nixpkgs.lib.genAttrs hosts;
    in {
      nixosConfigurations = genHosts (host: {
        specialArgs = { inherit home-manager inputs; };
        modules = [ import ./hosts/${host}.nix ];
      });
    };
}
