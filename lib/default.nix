{
  lib,
  systemSet,
}: {
  # Function to generate the flake output
  mkFlake =
    {inputs}: {
      imports ? [],
      systems ? systemSet.default,
      perSystem ? {},
      flake ? {},
    }:
      flake
    # Standard flake outputs
    ;

  # Import lib functions
  imports = [
    ./util.nix
    ./nixos.nix
    ./symlink.nix
  ];
}
