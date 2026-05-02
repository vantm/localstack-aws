{
  pkgs ? import ../../../../pkgs.nix,
}:
pkgs.mkShell {
  name = "Convert App";
  buildInputs = with pkgs; [
    go
  ];
}
