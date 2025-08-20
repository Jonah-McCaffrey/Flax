{ lib, sysSet }:
let
  inherit (builtins) listToAttrs attrNames readDir;
  inherit (lib) flatten removeSuffix nixosSystem nameValuePair recursiveUpdate;
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
    { src, hostsDir ? src+/hosts, sysSet ? sysSet, globalModules ? [ ]
    , specialArgs ? { }, perSystem ? { }, flake ? { } }:
    recursiveUpdate {
      # TODO: Implement perSystem
      nixosConfigurations = mkNixOS {
        hosts = nixFiles hostsDir;
        systems = sysSet.nixos;
        inherit hostsDir globalModules specialArgs inputs;
      };
    } flake;

  mkNixOS = { hosts, hostsDir, systems, globalModules, specialArgs, inputs }:
    listToAttrs (flatten (map (host:
      map (system:
        nameValuePair "${host}@${system}" (nixosSystem {
          specialArgs = recursiveUpdate {
            inherit system inputs;
            lib = mkLib lib;
          } specialArgs;
          modules = [ (hostsDir + /${host}.nix) ] ++ globalModules;
        })) systems) hosts));
}
