{lib, ...}: {
  imports = [
    ./lib
    ./nixos
    ./homeManager
  ];
  config.systems = lib.mkDefault [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-darwin"
    "x86_64-linux"
  ];
}
