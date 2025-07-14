{
  description = "Flake for the Flax nix project";

  inputs = { nixpkgs-lib.url = "github:nix-community/nixpkgs.lib"; };

  outputs = { self, nixpkgs-lib }: {
    lib = import ./lib/default.nix { inherit (nixpkgs-lib) lib; };
  };
}
