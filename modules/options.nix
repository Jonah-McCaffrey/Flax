{lib, ...}: let
  inherit (lib) mkOption;
  inherit (lib.types) listOf submodule str attrs attrsOf;
in {
  options = {
    imports = mkOption {
      type = listOf submodule;
      default = [];
      description = "List of flake modules to import";
    };
    flake = mkOption {
      type = attrs;
      default = {};
      description = "Attrs set to use for standard flake outputs";
    };
    systemSet = mkOption {
      type = attrsOf listOf str;
      default = import ../lib/systems.nix;
      description = "Attrs set of lists with systems for different purposes";
    };
    perSystem = mkOption {
      type = submodule;
      default = {system, ...}: {};
      description = "Function for defining per-system attributes";
    };
  };
}
