{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool attrs;
  cfg = config.flax.nixpkgs;
in {
  options.flax.nixpkgs = {
    enable = mkOption {
      type = bool;
      default = true;
      description = "Whether to enable the nixpkgs module";
    };
    version = mkOption {
      type = attrs;
      default = inputs.nixpkgs;
      description = "Instance of nixpkgs to use";
    };
    args = mkOption {
      type = attrs;
      default = {};
      description = "Set of args to pass when importing nixpkgs";
    };
  };
  config = mkIf cfg.enable {
    perSystem = {system, ...}: {
      _module.args.pkgs = import cfg.version (
        {inherit system;} // cfg.args
      );
    };
  };
}
