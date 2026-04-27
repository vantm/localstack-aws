{
  pkgs ? import <nixpkgs> {
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
pkgs.mkShellNoCC {
  packages =
    (with pkgs; [
      localstack
      terraform
      python3
      awscli2
      terraform-local
    ])
    ++ (with nur; [
      repos.anthonyroussel.awscli-local
    ]);

  shellHook = ''
    localstack start -d
  '';
}
