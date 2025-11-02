{
  lib,
  systemSet,
}: rec {
  evalFlakeModule = args: module:
    lib.evalModules {
      specialArgs = {inputs = args.inputs;};
      modules = [
        module
        {imports = [../modules/options.nix];}
      ];
      class = "flake";
    };

  mkFlake = args: module: (evalFlakeModule args module).config;

  # Function to generate the flake output
  # mkFlake = args: {
  #   imports ? [],
  #   systems ? systemSet.default,
  #   perSystem ? system: {},
  #   flake ? {},
  # }:
  #   lib.foldl' lib.recursiveUpdate {} (lib.flatten [
  #     (map (module: (evalFlakeModule args module).config) imports) # Flake modules
  #     (map perSystem systems) # Outputs defined per-system
  #     flake # Standard flake outputs
  #   ]);

  # Import lib functions
  # imports = [
  #   ./util.nix
  #   ./nixos.nix
  #   ./symlink.nix
  # ];
}
