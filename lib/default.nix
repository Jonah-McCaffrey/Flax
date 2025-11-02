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
      # {inherit imports;} # Flake modules
      (map perSystem systems) # Outputs defined per-system
      flake # Standard flake outputs
    ])
    // {
      imports = imports;
    };

  # Import lib functions
  imports = [
    ./util.nix
    ./nixos.nix
    ./symlink.nix
  ];
}
