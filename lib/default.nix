rec {
  # Imports (keeps namespace(?) of lib, e.g., lib.example not lib.util.example (I think?).)
  # import = [ /util.nix ];

  # Specific imports (intermediary namespace e.g., lib.util.example)
  util = import ./util.nix;

  greet = name: "Hello, ${name}";
  add = a: b: a + b;

  mkFlake = { pkgs, globalModules, hostsDir, hosts, perSystem ? { } }: {
    greeting = greet "Alex";
  };
}
