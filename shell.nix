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
    ])
    ++ (with nur; [
      repos.anthonyroussel.awscli-local
    ]);
}
