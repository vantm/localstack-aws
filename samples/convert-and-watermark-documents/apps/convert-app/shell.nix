{
  pkgs ? import ../../../../pkgs.nix,
}:
pkgs.mkShell {
  name = "convert app";
  buildInputs = with pkgs; [
    go
    gopls
  ];
}
