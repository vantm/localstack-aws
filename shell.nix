{
  inputs ? import ./inputs.nix,
  pkgs ? inputs.pkgs,
}:
pkgs.mkShell {
  packages =
    with pkgs;
    [
      terraform
      awscli2
      graphviz
    ]
    ++ [
      (pkgs.writeShellApplication {
        name = "awslocal";
        runtimeInputs = [ pkgs.awscli2 ];
        text = ''
          aws --profile local --endpoint-url=http://localhost:4566 "$@"
        '';
      })
    ];
}
