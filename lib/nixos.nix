{lib}: let
  inherit (builtins) listToAttrs;
  inherit (lib) flatten nixosSystem nameValuePair recursiveUpdate;
in {
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
