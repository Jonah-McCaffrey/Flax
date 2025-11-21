{lib, ...}: let
  inherit (builtins) attrNames readDir head split;
  inherit (lib) foldl' recursiveUpdate;
in {
  flax.lib = rec {
    # helper enabled value
    enabled = {enable = true;};

    # helper disabled value
    disabled = {enable = false;};

    # Get list of files from a given directory (WITH extension)
    getFiles = dir: attrNames (readDir dir);

    # Get list of file/directory names from a given directory (WITHOUT extension)
    getNames = dir: map (file: head (split "\\." file)) (getFiles dir);

    # Deep merge a list of attrsets
    mergeSets = foldl' recursiveUpdate {};
  };
}
