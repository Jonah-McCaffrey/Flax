{
  lib,
  systemSet,
}: {
  # Function to generate the flake output
  mkFlake = {inputs}: {
    imports ? [],
    systems ? systemSet.default,
    perSystem ? system: {},
    flake ? {},
  }:
    lib.foldl' lib.recursiveUpdate {} (lib.flatten [
      (lib.evalModules {inherit imports;})
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
