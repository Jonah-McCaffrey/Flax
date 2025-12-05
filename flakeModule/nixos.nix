{
  config,
  lib,
  inputs,
  withSystem,
  flax-lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption mkIf;
  inherit (inputs.nixpkgs.lib) nixosSystem;
  cfg = config.flax.nixos;
in {
  options.flax.nixos = with lib.types; {
    enable = mkOption {
      type = bool;
      default = true;
      description = "Enable the Flax host aggregator submodule";
    };
    systems = mkOption {
      type = nonEmptyListOf str;
      default = ["x86_64-linux" "aarch64-linux"];
      description = "List of system architectures which will be generated in the flake outputs for each host configuration";
    };
    src = mkOption {
      type = path;
      default = ./.;
      description = "The directory Flax will look for host configurations";
    };
    useGlobalPkgs = mkEnableOption "Use the global perSystem pkgs from the nixpkgs module for nixos configurations";
    hostFunction = mkOption {
      type = functionTo attrs;
      default = nixosSystem;
      description = "Function to create a host configuration";
    };
    globalArgs = mkOption {
      type = attrs;
      default = {};
      description = "Attribute set containing specialArgs which will be provided to all host configurations";
    };
    globalModules = mkOption {
      type = listOf deferredModule;
      default = [];
      description = "List containing modules which will be included in all host configurations";
    };
  };
  config = {
    flax.nixos.globalModules = mkIf cfg.useGlobalPkgs [
      ({system, ...}: {
        nixpkgs.pkgs = withSystem system (
          {pkgs, ...}: pkgs
        );
      })
    ];
    flake = mkIf cfg.enable {
      nixosConfigurations = flax-lib.mkNixOS {
        inherit (cfg) src systems hostFunction globalArgs globalModules;
      };
    };
  };
}
