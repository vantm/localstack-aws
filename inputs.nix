rec {
  nixpkgs = import <nixpkgs> { };

  pkgs =
    import
      (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/heads/nixpkgs-unstable.tar.gz")
      {
        config.allowUnfreePredicate =
          pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [
            "terraform"
          ];
      };
}
