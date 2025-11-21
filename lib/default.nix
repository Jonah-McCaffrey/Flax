{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption mkIf;
  inherit (lib.types) str attrs submoduleWith bool attrsOf anything;
in {
  imports = [
    ./util.nix
    ./systems.nix
    ./home-manager.nix
  ];
  options = {
    # flax.lib = {
    #   enable = mkEnableOption "Enable the flake lib functionality";
    #   namespace = mkOption {
    #     type = str;
    #     default = "flax-lib";
    #     description = "The namespace in which to place both the contents of Flax lib and any custom library configuration";
    #   };
    # };
    flax.lib = mkOption {
      type = submoduleWith {
        shorthandOnlyDefinesConfig = false;
        modules = [
          {
            options = {
              enable = mkOption {
                type = bool;
                default = true;
                description = "Whether to enable myOption";
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
  };
  config = mkIf config.flax.lib.enable {
    flake.lib = config.flax.lib;
  };
}
