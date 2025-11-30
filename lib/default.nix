{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) str submoduleWith bool attrsOf anything;
in {
  imports = [
    ./util.nix
    ./systems.nix
    ./home-manager.nix
  ];
  options.flax.lib = mkOption {
    type = submoduleWith {
      shorthandOnlyDefinesConfig = false;
      modules = [
        {
          options = {
            enable = mkOption {
              type = bool;
              default = true;
              description = "Whether to enable the custom library module";
            };
            namespace = mkOption {
              type = str;
              default = "";
              description = "namespace to use for the custom library";
            };
          };
          freeformType = attrsOf anything;
          # Optional: set defaults for freeform attrs if needed
          # config._freeformOptions = mkIf (cfg.enable) {};
        }
      ];
    };
    default = {};
    description = "Custom library including the Flax builtin/default functionality and custom user library content under a custom namespace";
  };
  config = let
    cfg = config.flax.lib;
    inherit (cfg) namespace home-manager;
    flax-lib = removeAttrs cfg ["enable" "namespace" "home-manager"];
  in
    mkIf cfg.enable {
      flax.nixos = {
        globalArgs = {${namespace} = flax-lib;};
        globalModules = [
          ({config, ...}:
            mkIf (config ? "home-manager") {
              home-manager.extraSpecialArgs.${namespace} = flax-lib // home-manager;
            })
        ];
      };
      flake.lib = cfg;
    };
}
