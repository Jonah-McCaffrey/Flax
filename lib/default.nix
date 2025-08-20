{ lib, sysSet }:
let
  inherit (builtins) listToAttrs attrNames readDir;
  inherit (lib) flatten removeSuffix genAttrs nixosSystem nameValuePair;
in rec {
  # Imports (keeps namespace(?) of lib, e.g., lib.example not lib.util.example (I think?).)
  # import = [ /util.nix ];

  # Specific imports (intermediary namespace e.g., lib.util.example)
  # util = import ./util.nix;

  # add the contents of the Flax library to lib
  mkLib = lib: lib.recursiveUpdate (lib) (import ./default.nix);

  # Get list of nix file names from a given directory
  nixFiles = dir: map (removeSuffix ".nix") (attrNames (readDir dir));

  mkFlake =
    # Function to generate the flake output
    { nixpkgs, inputs }:
    { hostsDir, sysSet ? sysSet, controlDir, globalModules ? [ ]
    , perSystem ? { }, flake ? { } }:
    let globalModules = globalModules // (lib.fileset.toList controlDir);
    in lib.recursiveUpdate {
      # TODO: Implement perSystem
      nixosConfigurations = mkNixOS {
        hosts = nixFiles hostsDir;
        systems = sysSet.nixos;
        controllers = attrNames (readDir controlDir);
        inherit globalModules lib inputs;
      };
    } flake;

  mkNixOS = { hosts, hostsDir, globalModules, systems, inputs }:
    listToAttrs (flatten (map (host:
      map (system:
        nameValuePair "${host}@${system}" (nixosSystem {
          specialArgs = { inherit system lib inputs; };
          modules = [ (hostsDir + /${host}.nix) ] ++ globalModules;
        })) systems) hosts));
}
