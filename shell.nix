{ pkgs ? import <nixpkgs> {}}:
let minikubePinned =
let
  version = "1.25.2";
  src = pkgs.fetchFromGitHub {
    owner = "kubernetes";
    repo = "minikube";
    rev = "v${version}";
    sha256 = "sha256-WIk4ibq7jcqao0Qiz3mz9yfHdxTUlvtPuEh4gApSDBg=";
  };
  in (pkgs.minikube.override rec {
    buildGoModule = args: pkgs.buildGoModule.override {} (args // {
      inherit src version;
      buildPhase = ''
        make COMMIT=${src.rev}
      '';
      vendorSha256 = "sha256-8QqRIWry15/xwBxEOexMEq57ol8riy+kW8WrQqr53Q8=";
    });
  });
in with pkgs;
mkShell {
  buildInputs = [
    bash
    git
    curl
    gnumake
    minikubePinned
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

