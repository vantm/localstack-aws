{
  pkgs ? import <nixpkgs> { },
}:
let
  venvDir = "./.venv";
  pythonPkgs = pkgs.python3Packages;
in
pkgs.mkShell {
  packages = [
    pythonPkgs.python
  ]
  ++ (with pkgs; [
    openjdk17
    maven
  ]);

  REPO_URL = "https://github.com/localstack-samples/sample-chaos-serverless-multi-region-failover.git";

  shellHook = ''
    if [ ! -d "./source" ] ; then
      ${pkgs.git}/bin/git clone $REPO_URL ./source
    fi

    if [ -d "${venvDir}" ] ; then
      echo "Skipping virtual environment creation, already exists at ${venvDir}";
    else
      echo "Creating virtual environment at ${venvDir}...";
      ${pythonPkgs.python.interpreter} -m venv "${venvDir}"
      echo "Virtual environment created at ${venvDir}!";
    fi

    source "${venvDir}/bin/activate"
  '';
}
