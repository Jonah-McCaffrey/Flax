{
  lib,
  systemSet,
}: let
  inherit (builtins) listToAttrs;
  inherit (lib) flatten nixosSystem nameValuePair recursiveUpdate mkMerge;
  inherit (import ./util.nix lib) getFileNames;
in rec {
  # Function to generate the flake output
  mkFlake = {
    nixpkgs,
    src,
    inputs ? {},
    hostsDir ? (src + /hosts),
    sysSet ? systemSet,
    flakeModules ? {},
    globalModules ? [],
    specialArgs ? {},
    perSystem ? {},
    flake ? {},
  }:
    mkMerge ((map perSystem sysSet.default)
      ++ [
        {
          nixosConfigurations = mkNixOS {
            hosts = getFileNames hostsDir;
            systems = sysSet.nixos;
            inherit hostsDir globalModules specialArgs inputs;
          };
        }
        flakeModules
        flake
      ]);

  # Function to generate the nixos systems
  mkNixOS = {
    hosts,
    hostsDir,
    systems,
    globalModules,
    specialArgs,
    inputs,
  }:
    listToAttrs (flatten (map (host:
      map (system:
        nameValuePair "${host}@${system}" (nixosSystem {
          specialArgs =
            recursiveUpdate {
              inherit system inputs;
              util = import ./util.nix lib;
            }
            specialArgs;
          modules = [(hostsDir + /${host}.nix)] ++ globalModules;
        }))
      systems)
    hosts));
}
