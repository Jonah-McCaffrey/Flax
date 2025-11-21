{
  description = "A flake for my custom library, Flax.";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      flake.flakeModule.default = {
        imports = [
          ./lib
          ./nixos
        ];
      };
    };
}
