{
  lib,
  systemSet,
  ...
}: let
  inherit (builtins) listToAttrs;
  inherit (lib) flatten nixosSystem nameValuePair mkOption;
  inherit (lib.types) functionTo attrs;
in {
  options = {
    defaultHostFunc = mkOption {
      type = functionTo attrs;
      default = {}: {};
    };
  };
  config = rec {
    # Default function for defining a host configuration
    defaultHostFunc = {
      modules,
      specialArgs,
    }:
      nixosSystem {
        inherit modules specialArgs;
      };

    # Function for defining all host configurations
    mkNixOS = {
      hostsDir ? ./hosts,
      hostFunction ? defaultHostFunc,
      systems ? systemSet.nixos,
      globalModules ? [],
      globalArgs ? {},
    }: let
      hosts = builtins.attrNames (builtins.readDir ./hosts);
      confList = flatten (
        map (
          host:
            map (
              system:
                nameValuePair "${host}@${system}" (hostFunction {
                  modules = globalModules ++ [(import (hostsDir + "/host"))];
                  specialArgs = globalArgs // {inherit system;};
                })
            )
            systems
        )
        hosts
      );
    in
      listToAttrs confList;
  };
}
