{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf fileset;
  inherit (lib.types) bool attrsOf deferredModule path;
  cfg = config.flax.develop;
in {
  options.flax.develop = {
    enable = mkOption {
      type = bool;
      default = true;
      description = "Enable the Flax development submodule";
    };
    devShells = mkOption {
      type = attrsOf deferredModule;
      default = {};
      description = "Set of development shells to expose as flake outputs";
    };
    shellDir = mkOption {
      type = path;
      default = ./.;
      description = "Path to a directory of devShell modules";
    };
  };

  config.perSystem = mkIf cfg.enable {
    imports = fileset.toList cfg.shellDir;
  };
}
