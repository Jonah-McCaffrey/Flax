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
    { hostsDir ? ./hosts, sysSet ? sysSet, controlDir
    , confOutput ? confOutputDefault, globalModules ? [ ], perSystem ? { }
    , flake ? { } }:
    lib.recursiveUpdate {
      # imports = # Apply the contents of perSystem for each system in systems
      #   [ # TODO: check the flake-parts implementation
      #     (genAttrs sysSet.default perSystem)
      #   ];
      nixosConfigurations = mkNixOS {
        hosts = nixFiles hostsDir;
        systems = sysSet.nixos;
        controllers = attrNames (readDir controlDir);
        inherit confOutput lib inputs;
      };
    } flake;

  mkNixOS = { hosts, systems, controllers, confOutput, lib, inputs }:
    listToAttrs (flatten (map (host:
      map (system:
        nameValuePair "${host}@${system}"
        (confOutput { inherit host system controllers lib inputs; })) systems)
      hosts));

  # === OLD ===
  # mkNixOS =
  #   # Defining the function to map all hosts/systems to a configuration
  #   { hostDir, hostFunc, lib, inputs, }:
  #   let
  #     hosts = filter (host: config.${host}.enable)
  #       (map (host: removeSuffix ".nix" host) (attrNames (readDir ./hosts)));
  #   in listToAttrs (flatten (attrValues (map (host:
  #     map (system: {
  #       name = "${host}@${system}";
  #       value = hostFunc { inherit host system lib inputs; };
  #     }) config.${host}.systems) hosts)));

  confOutputDefault =
    # Defining function to create a host configuration
    { host, system, controllers, lib, inputs, }:
    nixosSystem {
      specialArgs = { inherit system lib inputs; };
      modules = [ ./hosts/${host}.nix ] ++ controllers;
    };
}
