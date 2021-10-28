**NOTE: THE SECURE SOFTWARE FACTORY IS BEING REFACTORED HEAVILY AND THERE MIGHT BE MANY BUGS. PLEASE OPEN UP ISSUES FOR ANYTHING YOU MIGHT DISCOVER**

# Supply Chain Examples

These are just a few examples and demos to show how certain supply chain attacks might manifest and how different tools and approaches can help mitigate them.

## Monitoring build with eBPF

The set of examples under `build_with_ebpf` are a few examples of how without the right preventive controls around your supply chain you will have to rely on detective controls. It is still good practice from a defense in depth approach to still apply monitoring like this on the builds to still detect anomalous behaviors or when your preventive controls fail for any reason.

### Threats

The threats these examples emulate are the following:

* Injecting unknown build tools into a container - DONE
* Injecting unknown source code into shared drive - NOT DONE
* Build scripts attempting to call out to internet - NOT DONE
* Approved build tools performing suspicious activities like injecting binaries into memory and executing directly - DONE

### Pre-Requisites

In order to run these examples, you'll need a system with the following

* [Rust & Cargo](https://doc.rust-lang.org/cargo/getting-started/installation.html)
  * Ensure you have x86_64-unknown-linux-musl target installed for static linking
    `rustup target add x86_64-unknown-linux-musl`
* [Nix](https://nixos.org/guides/install-nix.html)

### Setup

TODO: Publish artifacts of binaries + containers

```bash
cd build_with_ebpf/bad_cargo
./build.sh
```

### Development

See our [development guide](devel/development.md))


## Emulating Attacks

### Build on Host

Normal Build:

```bash
cd build_with_ebpf/real_project
cargo build --release
```

Build that hijacks the source files:

```bash
cd build_with_ebpf/real_project
../bad_cargo/target/release/bad_cargo_inputs build --release
```

Build that hijacks the output:

```bash
cd build_with_ebpf/real_project
../bad_cargo/target/release/bad_cargo_outputs build --release
```

Once you have run any of the above you can test it via:

```bash
./target/release/real_project
```

You should get a "Goodbye, World" output on the hijacked ones.

### Build in Container


Normal Build:

```bash
cd containers/real_project
nix-build default.nix
docker load < result
docker run --rm -v <outputs_dir>:/src/target:z -v `pwd`/../../real_project:/src:z real_project:<hash>
```

Build that hijacks the source files:

```bash
cd container/hijack_inputs_build
nix-build default.nix
docker load < result
docker run --rm -v <outputs_dir>:/src/target:z -v `pwd`/../../real_project:/src:z real_project:<hash>
```

Build that hijacks the output:

```bash
cd container/hijack_outputs_build
nix-build default.nix
docker load < result
docker run --rm -v <outputs_dir>:/src/target:z -v `pwd`/../../real_project:/src:z real_project:<hash>
```

Once you have run any of the above you can test it via:

```bash
<outputs_dir>/target/release/real_project
```

## How to detect compromise

TODO: Flesh this out

* You can use a tool like Falco or Tracee to monitor for memfd creations and execve's against the memfds and capture the memfds.
* You can also capture the executed tools, inputs and outputs and their hashes and compare it to known good hashes.
    * Compare captured cargo that is run against the build against cargo inputs
    * Compare source inputs with upstream sources
    * You can debug captured suspicious binaries in sandboxed environments

## Kubernetes Demos

These showcase how to leverage Kubernetes, especialy using [Tekton], to improve
the security of the supply chain.

The scripts provided help provisioning and configuring environments quickly,
either for an investigation purpose, either for demonstration.

You could find more details in the [README.md](kubernetes/README.md) of the
dedicated folder.



[Tekton]: https://tekton.dev/
