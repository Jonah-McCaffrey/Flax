lib: {
  home-manager = {
    # Function to be used within home.file to symlink the contents of a directory to a target directory
    homeLink = {
      config,
      sourceDir, # FIX: Messy sourceDir/source usage
      source,
      target,
      ignore ? [], # TODO: implement ignore function
    }: let
      # Map a single entry in the source to the required format
      processEntry = name: type: let
        sourcePath = "${source}/${name}";
        targetPath = (toString target) + "/" + name;
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
  };
}
