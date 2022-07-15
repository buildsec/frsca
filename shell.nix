{ pkgs ? import <nixpkgs> {} }:
with pkgs;
mkShell {
  buildInputs = [
    gnumake
    minikube
    kubectl
    tektoncd-cli
    cosign
    crane
    cue
    jq
    kubernetes-helm
  ];
}

