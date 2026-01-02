lib: let
  inherit (builtins) readDir pathExists elem;
  inherit (lib) flatten mapAttrsToList hasSuffix filterAttrs;

  modulePredicate = name: type:
    ((elem type ["regular" "symlink"]) && (hasSuffix ".nix" name))
    || (type == "directory");

  dynport = args @ {default ? "default.nix", ...}: target:
    flatten (
      mapAttrsToList (
        name: type:
          if (type == "regular" || type == "symlink")
          then "${target}/${name}"
          else if (pathExists "${target}/${name}/${default}")
          then "${target}/${name}/${default}"
          else dynport args "${target}/${name}"
      ) (filterAttrs modulePredicate (readDir target))
    );

  result = {
    # __functor = dynport;
    default = "default.nix";
    __functor = self: target:
      flatten (
        mapAttrsToList (
          name: type:
            if (type == "regular" || type == "symlink")
            then "${target}/${name}"
            else if (pathExists "${target}/${name}/${self.default}")
            then "${target}/${name}/${self.default}"
            else self.__functor self "${target}/${name}"
        ) (filterAttrs modulePredicate (readDir target))
      );
  };
in
  result
