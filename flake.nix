{
  description = "A flake for my custom library, Flax.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: {
    flakeModule.default = import ./flakeModule.nix self.lib;
    lib = import ./lib nixpkgs.lib;
  };
}
