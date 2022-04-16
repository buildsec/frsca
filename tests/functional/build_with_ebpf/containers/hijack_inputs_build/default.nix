{pkgs ? import (builtins.fetchTarball {
    name = "nixos-unstable-2021-06-25";
    url = "https://github.com/nixos/nixpkgs/archive/e85975942742a3728226ac22a3415f2355bfc897.tar.gz";
    sha256 = "0zg5c9if4dlk4f0w14439ixjv50m04yfxf0l3bmrhhsgq1f6yk0m";
}){ system = "x86_64-linux"; }}:
let 
    hijack_inputs_cargo = with pkgs; stdenv.mkDerivation {
        name = "hijack_inputs_cargo";

        unpackPhase = ":";
        installPhase = "install -m775 -D ${../../bad_cargo/target/x86_64-unknown-linux-musl/release/bad_cargo_inputs} $out/bin/bad_cargo_inputs;";
    };
in with pkgs; dockerTools.buildLayeredImage {
  name = "hijack-inputs-build";
  contents = [
    rustc
    cargo
    gcc
    hijack_inputs_cargo
  ];
  config = {
    WorkingDir = "/src";
    User = "1000:1000";
    Env = [
        "HOME=/home/nobody"
        "USER=nobody"
    ];
    Cmd = [ "/bin/bad_cargo_inputs"
            "build"
            "--release" ];
  };
  fakeRootCommands = ''
    mkdir -p ./home/nobody
    chown 1000 ./home/nobody
    mkdir -p ./tmp
    chmod 1777 ./tmp
  '';
}

