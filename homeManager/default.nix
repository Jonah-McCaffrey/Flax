{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkOption mkIf;
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  cfg = config.flax.homeManager;
in {
  options.flax.homeManager = with lib.types; {
    enable = mkOption {
      type = bool;
      default = true;
      description = "Enable the Flax home aggregator submodule";
    };
    systems = mkOption {
      type = nonEmptyListOf str;
      default = ["x86_64-linux" "x86_64-darwin" "aarch64-linux"];
      description = "List of system architectures which will be generated in the flake outputs for each home configuration";
    };
    src = mkOption {
      type = path;
      default = ./.;
      description = "The directory Flax will look for home configurations";
    };
    homeFunction = mkOption {
      type = functionTo attrs;
      default = homeManagerConfiguration;
      description = "Function to create a home configuration";
    };
    extraGlobalArgs = mkOption {
      type = attrs;
      default = {};
      description = "Attribute set containing extraSpecialArgs which will be provided to all home configurations";
    };
    globalModules = mkOption {
      type = listOf deferredModule;
      default = [];
      description = "List containing modules which will be included in all host configurations";
    };
  };
  config.flake = mkIf cfg.enable {
    homeConfigurations = config.flax.lib.mkHome {
      inherit (cfg) src systems homeFunction extraGlobalArgs globalModules;
    };
  };
}
