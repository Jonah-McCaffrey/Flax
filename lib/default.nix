{
  lib,
  systemSet,
}: rec {
  evalFlakeModule = args: module:
    lib.evalModules {
      specialArgs = {inputs = args.inputs;};
      modules = imports;
    };

  # Function to generate the flake output
  mkFlake = args: {
    imports ? [],
    systems ? systemSet.default,
    perSystem ? system: {},
    flake ? {},
  }:
    lib.foldl' lib.recursiveUpdate {} (lib.flatten [
      (map (module: evalFlakeModule args module) imports) # Flake modules
      (map perSystem systems) # Outputs defined per-system
      flake # Standard flake outputs
    ]);

  # Import lib functions
  imports = [
    ./util.nix
    ./nixos.nix
    ./symlink.nix
  ];
}
