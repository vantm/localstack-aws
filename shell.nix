{
  pkgs ?
    import
      (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/heads/nixpkgs-unstable.tar.gz")
      {
        config.allowUnfreePredicate =
          pkg:
          builtins.elem (pkgs.lib.getName pkg) [
            "terraform"
          ];
      },
  nur ?
    import
      (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/9e5cd1c163821839337ba993f895fa8109f93dec.tar.gz")
      {
        inherit pkgs;
      },
}:
pkgs.mkShell {
  packages =
    (with pkgs; [
      terraform
      terraform-local

      awscli2
    ])
    ++ (with nur; [
      repos.anthonyroussel.awscli-local
    ]);
}
