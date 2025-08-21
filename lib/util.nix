lib: let
  inherit (builtins) attrNames readDir head split;
  inherit (lib) foldl' recursiveUpdate;
in rec {
  # helper enabled value
  enabled = {enable = true;};

  # Get list of file names from a given directory (WITH extension)
  getFiles = dir: attrNames (readDir dir);

  # Get list of file names from a given directory (WITHOUT extension)
  getFileNames = dir: map (file: head (split "\\." file)) (getFiles dir);

  # Deep merge a list of attrsets
  mergeSets = foldl' recursiveUpdate {};
}
