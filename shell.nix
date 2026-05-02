{
  inputs ? import ./inputs.nix,
  pkgs ? inputs.pkgs,
  nur ? inputs.nur,
}:
pkgs.mkShell {
  packages = (
    with pkgs;
    [
      terraform
      awscli2
      graphviz
    ]
  );
}
