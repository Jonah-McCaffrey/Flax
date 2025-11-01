{
  lib,
  systemSet,
}: {
  # Function to generate the flake output
  mkFlake = {inputs}: {
    imports ? [],
    systems ? systemSet.default,
    perSystem ? {},
    flake ? {},
  }:
    lib.foldl' lib.recursiveUpdate {} (
      imports # Flake modules
      ++ [
        (lib.genAttrs systems perSystem) # Per system outputs
        flake # Standard flake outputs
      ]
    );

  # Import lib functions
  imports = [
    ./util.nix
    ./nixos.nix
    ./symlink.nix
  ];
}
