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
  # lib.foldl' lib.recursiveUpdate {} (lib.flatten [
  #   # (lib.evalModules {modules = imports;}) # Flake modules
  #   (map perSystem systems) # Outputs defined per-system
  #   flake # Standard flake outputs
  # ]);
  (lib.evalModules {modules = imports;}); # Flake modules

  # Import lib functions
  imports = [
    ./util.nix
    ./nixos.nix
    ./symlink.nix
  ];
}
