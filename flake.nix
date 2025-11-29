{
  description = "A flake for my custom library, Flax.";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs: {
    flakeModule.default = import ./flakeModule.nix;
  };
}
