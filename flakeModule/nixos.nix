{
  config,
  lib,
  withSystem,
  flax-lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption mkIf;
  cfg = config.flax.nixos;
in {
  options.flax.nixos = with lib.types; {
    enable = mkOption {
      type = bool;
      default = true;
      description = "Enable the Flax host aggregator submodule";
    };
    src = mkOption {
      type = path;
      default = ./.;
      description = "The directory Flax will look for host configurations";
    };
    useGlobalPkgs = mkEnableOption "Use the global perSystem pkgs from the nixpkgs module for nixos configurations";
    default = mkOption {
      type = str;
      default = "default.nix";
      description = "File to look for by default in an imported directory";
    };
    specialArgs = mkOption {
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
      nixosConfigurations =
        flax-lib.mkNixOS {
          inherit (cfg) default specialArgs globalModules;
        }
        cfg.src;
    };
  };
}
