{
  inputs ? import ./inputs.nix,
  pkgs ? inputs.pkgs,
  nur ? inputs.nur,
}:
pkgs.mkShell {
  packages =
    (with pkgs; [
      terraform
      terraform-local

      awscli2

      graphviz
    ])
    ++ (with nur; [
      repos.anthonyroussel.awscli-local
    ]);
}
