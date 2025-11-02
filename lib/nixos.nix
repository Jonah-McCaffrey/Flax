{
  lib,
  systemSet,
  ...
}: let
  inherit (builtins) listToAttrs;
  inherit (lib) flatten nixosSystem nameValuePair;
in rec {
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

  # listToAttrs (flatten (map (host:
  #   map (system:
  #     nameValuePair "${host}@${system}" (hostFuncion {
  #       specialArgs = {
  #         inherit system globalArgs;
  #       };
  #       modules = [(hostsDir + /${host}/configuration.nix)] ++ globalModules;
  #     }))
  #   systems)
  # hosts));

  # Function to generate the nixos systems
  # mkNixOS = {
  #   hosts,
  #   hostsDir,
  #   systems,
  #   globalModules,
  #   specialArgs,
  #   inputs,
  # }:
  #   listToAttrs (flatten (map (host:
  #     map (system:
  #       nameValuePair "${host}@${system}" (nixosSystem {
  #         specialArgs =
  #           recursiveUpdate {
  #             inherit system inputs;
  #             util = import ./util.nix lib;
  #           }
  #           specialArgs;
  #         modules = [(hostsDir + /${host}.nix)] ++ globalModules;
  #       }))
  #     systems)
  #   hosts));
}
