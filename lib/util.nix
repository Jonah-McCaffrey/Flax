{
  lib,
  inputs,
  ...
}: let
  inherit (builtins) attrNames readDir head split;
  inherit (lib) foldl' recursiveUpdate mkMerge crossLists mkDefault nameValuePair mapAttrs' mapAttrsToList;
  inherit (inputs.nixpkgs.lib) nixosSystem;
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
in {
  flax.lib = rec {
    # helper enabled value
    enabled = {enable = true;};

    # helper disabled value
    disabled = {enable = false;};

    # Removes a file's extension
    removeExtension = file: head (split "\\." file);

    # Get list of files from a given directory (WITH extension)
    getFiles = dir: attrNames (readDir dir);

    # Get list of file/directory names from a given directory (WITHOUT extension)
    getNames = dir: map removeExtension (getFiles dir);

    # Deep merge a list of attrsets
    mergeSets = foldl' recursiveUpdate {};

    # lib.crossLists with reversed arguments
    crossMap = list: function: crossLists function list;

    # CrossMap and merge the output sets
    crossMerge = list: function: mergeSets (crossMap list function);

    # crossMerge but using mkMerge
    mkCrossMerge = list: function: mkMerge (crossMap list function);

    importToList = {default ? "default.nix"}: dir:
      mapAttrsToList (name: type:
        import (dir
          + "/${
            if type == "regular"
            then name
            else "${name}/${default}"
          }")) (readDir dir);

    # Import the contents of a given directory, specify default file name, map name/value pairs
    importToSet = {
      default ? "default.nix",
      nameFunc ? x: y: x,
      valueFunc ? x: y: y,
    }: dir:
      mapAttrs' (
        name: type: let
          title = removeExtension name;
          file = import (dir
            + "/${
              if type == "regular"
              then name
              else "${name}/${default}"
            }");
        in
          nameValuePair
          (nameFunc title file)
          (valueFunc title file)
      )
      (readDir dir);

    # Function for defining all host configurations
    mkNixOS = {
      src,
      systems ? ["x86_64-linux" "aarch64-linux"],
      hostFunction ? nixosSystem,
      globalArgs ? {},
      globalModules ? [],
    }: let
      hostsDir = src + "/hosts";
      hosts = getFiles hostsDir;
    in
      mkCrossMerge [hosts systems] (host: system: {
        "${host}@${system}" = hostFunction {
          specialArgs =
            globalArgs
            // {inherit system;};
          modules =
            globalModules
            ++ [
              (hostsDir + "/${host}/configuration.nix")
              {
                nixpkgs.hostPlatform = mkDefault system;
                environment.sessionVariables = {
                  HOST_CONFIGURATION = "${host}@${system}";
                };
              }
            ];
        };
      });

    mkHome = {
      src,
      systems ? ["x86_64-linux" "x86_64-darwin" "aarch64-linux"],
      homeFunction ? homeManagerConfiguration,
      extraGlobalArgs ? {},
      globalModules ? [],
    }: let
      homesDir = src + "/homes";
      homes = getFiles homesDir;
    in
      mkCrossMerge [homes systems] (home: system: {
        "${home}@${system}" = homeFunction {
          pkgs = import inputs.nixpkgs {
            inherit system;
          };
          extraSpecialArgs =
            extraGlobalArgs
            // {inherit system;};
          modules =
            globalModules
            ++ [(homesDir + "/${home}/home.nix")];
        };
      });
  };
}
