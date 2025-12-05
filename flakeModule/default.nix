flax-lib: {lib, ...}: {
  imports = [
    ./lib.nix
    ./nixpkgs.nix
    ./nixos.nix
    ./homeManager.nix
  ];

  config = {
    _module.args = {inherit flax-lib;};
    systems = lib.mkDefault [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  };
}
