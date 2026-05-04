{
  pkgs ? import ../../../pkgs.nix,
}:
pkgs.mkShell {
  name = "function apps";
  buildInputs = with pkgs; [
    go
    gopls
  ];
}
