{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) str submoduleWith bool attrsOf anything;
in {
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
        }
      ];
    };
    default = {};
    description = "Custom library including the Flax builtin/default functionality and custom user library content under a custom namespace";
  };
  config = let
    cfg = config.flax.lib;
    flax-lib = import ../lib lib;
    lib-set = {${cfg.namespace} = flax-lib;};
  in
    mkIf cfg.enable {
      flax.nixos = {
        globalArgs = lib-set;
        globalModules = [
          ({config, ...}:
            mkIf (config ? "home-manager") {
              home-manager.extraSpecialArgs = lib-set;
            })
        ];
      };
      flake.lib = flax-lib;
    };
}
