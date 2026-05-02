let
  nixpkgs = import <nixpkgs> { };
  nixpkgs-unstable = builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/heads/nixpkgs-unstable.tar.gz";
in
with nixpkgs;
import nixpkgs-unstable {
  config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "terraform"
    ];
}
