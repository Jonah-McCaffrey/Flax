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
    lib = import ./lib nixpkgs.lib;
    flakeModule.default = import ./flakeModule self.lib;
  };
}
