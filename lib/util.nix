lib: let
  inherit (builtins) attrNames readDir;
  inherit (lib) removeSuffix foldl' recursiveUpdate;
in rec {
  # helper enabled value
  enabled = {enable = true;};

  # Get list of file names from a given directory (WITH extension)
  getFiles = dir: attrNames (readDir dir);

  # Get list of file names from a given directory (WITHOUT extension)
  getFileNames = dir: map (removeSuffix ".nix") (getFiles dir);

  mergeSets = foldl' recursiveUpdate {};
}
