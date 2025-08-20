{
  lib,
  systemSet,
}: let
  inherit (builtins) listToAttrs;
  inherit (lib) flatten nixosSystem nameValuePair recursiveUpdate genAttrs;
  inherit (import ./util.nix lib) getFileNames mergeSets;
in rec {
  # Imports (keeps namespace(?) of lib, e.g., lib.example not lib.util.example (I think?).)
  # imports = [ /util.nix ];

  # Specific imports (intermediary namespace e.g., lib.util.example)
  # util = import ./util.nix lib;

  # add the contents of the Flax library to lib
  # mkLib = lib: lib.recursiveUpdate lib (import ./default.nix);

  mkFlake =
    # Function to generate the flake output
    {
      nixpkgs,
      inputs,
    }: {
      src,
      hostsDir ? null,
      sysSet ? systemSet,
      globalModules ? [],
      specialArgs ? {},
      packages ? {},
      flake ? {},
    }: let
      hostsDir' =
        if hostsDir == null
        then src + /hosts
        else hostsDir;
    in
      mergeSets [
        {
          nixosConfigurations = mkNixOS {
            hosts = getFileNames hostsDir';
            systems = sysSet.nixos;
            inherit hostsDir' globalModules specialArgs inputs;
          };
        }
        {
          packages = genAttrs sysSet.packages packages;
        }
        flake
      ];

  mkNixOS = {
    hosts,
    hostsDir',
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
          modules = [(hostsDir' + /${host}.nix)] ++ globalModules;
        }))
      systems)
    hosts));
}
