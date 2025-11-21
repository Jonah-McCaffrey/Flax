{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkMerge crossLists mkOption mkIf;
  inherit (lib.types) path attrs listOf deferredModule str functionTo nonEmptyListOf bool;
  inherit (inputs.nixpkgs.lib) nixosSystem;
  cfg = config.flax;

  # Function for defining all host configurations
  mkNixOS = {
    # systems ? ["x86_64-linux" "aarch64-linux"],
    # hostsDir ? ./hosts,
    # hostFunction ? nixosSystem,
    # globalArgs ? {},
    # globalModules ? [],
    systems,
    hostsDir,
    hostFunction,
    globalArgs,
    globalModules,
  }: let
    hosts = builtins.attrNames (builtins.readDir hostsDir);
    cfg = config.flax.lib;
    inherit (cfg) namespace home-manager;
    flax-lib = removeAttrs cfg ["enable" "namespace" "home-manager"];
    configSet = mkMerge (
      crossLists (host: system: {
        "${host}@${system}" = hostFunction {
          specialArgs =
            globalArgs
            // {inherit system;}
            // (
              if cfg.enable
              then {${namespace} = flax-lib;}
              else {}
            );
          modules =
            globalModules
            ++ [
              # ({lib, ...}: {
              #   _module.args.lib = lib.extend (final: prev: cfg);
              #   environment.sessionVariables.HOST_CONFIGURATION = "${host}@${system}";
              # })
              {environment.sessionVariables.HOST_CONFIGURATION = "${host}@${system}";}
              (hostsDir + "/${host}/configuration.nix")
              ({config, ...}:
                mkIf (config ? "home-manager" && cfg.enable) {
                  home-manager.extraSpecialArgs.${namespace} = flax-lib // home-manager;
                })
            ];
        };
      }) [hosts systems]
    );
  in
    configSet;
in {
  options.flax.nixos = {
    # enable = mkEnableOption "Enable the Flax host aggregator";
    enable = mkOption {
      type = bool;
      default = true;
      description = "Enable the Flax host aggregator";
    };
    systems = mkOption {
      type = nonEmptyListOf str;
      default = ["x86_64-linux" "aarch64-linux"];
      description = "List of system architectures which will be generated in the flake outputs for each host configuration";
    };
    hostsDir = mkOption {
      type = path;
      default = ./hosts;
      description = "The directory Flax will look for host configurations";
    };
    hostFunction = mkOption {
      type = functionTo attrs;
      default = nixosSystem;
      description = "Function to create a host configuration";
    };
    globalArgs = mkOption {
      type = attrs;
      default = {};
      description = "Attribute set containing specialArgs which will be provided to all host configuratios";
    };
    globalModules = mkOption {
      type = listOf deferredModule;
      default = [];
      description = "List containing modules which will be included in all host configuratios";
    };
  };
  config.flake = {
    nixosConfigurations =
      mkIf cfg.nixos.enable
      (mkNixOS {
        inherit (cfg.nixos) systems hostsDir hostFunction globalArgs globalModules;
      });
  };
}
