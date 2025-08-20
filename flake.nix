{
  description = "Flake for the Flax nix project";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable"; };

  outputs = { self, nixpkgs }: {
    lib = import ./lib {
      inherit (nixpkgs.lib) lib;
      sysSet = import ./lib/systems.nix;
    };
  };
}
