{
  config,
  lib,
  flax-lib,
  ...
}: let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) submoduleWith bool attrsOf anything;
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
  in
    mkIf cfg.enable {
      # flax.nixos = {
      #   globalModules = [
      #     ({config, ...}:
      #       mkIf (config ? "home-manager") {
      #         home-manager.extraSpecialArgs.lib = inputs.nixpkgs.lib.extend (final: prev: flax-lib);
      #       })
      #   ];
      # };
      flake.lib = flax-lib;
    };
}
