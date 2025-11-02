{
  config,
  lib,
  ...
}: {
  # Function to replicate GNU Stow behavior
  linkDots = {
    sourceStr,
    sourceDir,
    targetDir ? "${config.home.homeDirectory}",
    ignore ? [],
  }: let
    # Map a single entry in sourceDir to required format
    processEntry = name: type: let
      sourcePath = "${sourceStr}/${name}";
      targetPath = targetDir + "/" + name;
    in
      if type == "directory" || type == "regular"
      then {
        name = targetPath;
        value = {source = config.lib.file.mkOutOfStoreSymlink sourcePath;};
      }
      else # Ignore other file types (e.g., symlinks, sockets)
        {};

    # Create attrset required for home.file
    symlinkAttrs =
      builtins.listToAttrs
      (lib.mapAttrsToList processEntry (builtins.readDir sourceDir));
  in
    symlinkAttrs;
}
