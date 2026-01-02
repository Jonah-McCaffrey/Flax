lib: let
  inherit (builtins) attrNames readDir head split match elemAt;
  inherit (lib) foldl' recursiveUpdate mkMerge crossLists mkDefault nameValuePair mapAttrs' mapAttrsToList last nixosSystem;
in rec {
  # helper enabled value
  enabled = {enable = true;};

  # helper disabled value
  disabled = {enable = false;};

  # Removes a file's extension
  getBase = file: head (split "\\." file);

  # Removes a file's extension
  getExt = file: last (split "\\." file);

  # Map a filename string to an attrset containing the basename and file extension
  splitFilename = filename: let
    matched = match "([^.]*)\\.(.*)" filename; # [ base ext ] or null
  in
    if matched == null
    then {
      base = filename;
      ext = "";
    }
    else {
      base = elemAt matched 0;
      ext = elemAt matched 1;
    };

  # Get list of files from a given directory (WITH extension)
  getFiles = dir: attrNames (readDir dir);

  # Get list of file/directory names from a given directory (WITHOUT extension)
  getNames = dir: map getBase (getFiles dir);

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
        title = getBase name;
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
    hosts,
    topologies,
    hostFunction ? nixosSystem,
    specialArgs ? {},
    globalModules ? [],
  }:
    mkCrossMerge [hosts topologies] (host: topology: let
      hostName = getBase (baseNameOf host);
      topologyName = getBase (baseNameOf topology);
    in {
      "${topologyName}@${hostName}" = hostFunction {
        inherit specialArgs;
        modules =
          globalModules
          ++ [
            host
            topology
            ({config, ...}: {
              _module.args.system = config.nixpkgs.hostPlatform.system;
              environment.sessionVariables = {
                HOST = hostName;
                TOPOLOGY = topologyName;
              };
            })
          ];
      };
    });

  # mkHome = {
  #   src,
  #   systems ? ["x86_64-linux" "x86_64-darwin" "aarch64-linux"],
  #   homeFunction ? homeManagerConfiguration,
  #   extraGlobalArgs ? {},
  #   globalModules ? [],
  # }: let
  #   homesDir = src + "/homes";
  #   homes = getFiles homesDir;
  # in
  #   mkCrossMerge [homes systems] (home: system: {
  #     "${home}@${system}" = homeFunction {
  #       pkgs = import inputs.nixpkgs {
  #         inherit system;
  #       };
  #       extraSpecialArgs =
  #         extraGlobalArgs
  #         // {inherit system;};
  #       modules =
  #         globalModules
  #         ++ [(homesDir + "/${home}/home.nix")];
  #     };
  #   });
}
