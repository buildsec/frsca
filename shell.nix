{ pkgs ? import <nixpkgs> {} }:
with pkgs;
mkShell {
  buildInputs = [
    bash
    git
    curl
    gnumake
    minikube
    kubectl
    tektoncd-cli
    cosign
    crane
    cue
    jq
    kubernetes-helm
    zola
  ];
}

