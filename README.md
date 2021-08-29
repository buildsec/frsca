# Supply Chain Examples

These are just a few examples and demos to show how certain supply chain attacks might manifest and how different tools and approaches can help mitigate them.

# Monitoring build with eBPF

The set of examples under `build_with_ebpf` are a few examples of how without the right preventive controls around your supply chain you will have to rely on detective controls. It is still good practice from a defense in depth approach to still apply monitoring like this on the builds to still detect anomalous behaviors or when your preventive controls fail for any reason.

## Threats

The threats these examples emulate are the following:

* Injecting unknown build tools into a container - NOT DONE
* Injecting unknown source code into shared drive - NOT DONE
* Build scripts attempting to call out to internet - NOT DONE
* Approved build tools performing suspicious activities like injecting binaries into memory and executing directly - DONE

## Setup

TODO: Containerize it

```
cd build_with_ebpf/bad_cargo
./build.sh
```

## Emulating Attacks

Normal Build:

```
cd build_with_ebpf/real_project
cargo build --release
```

Build that hijacks the source files:

```
cd build_with_ebpf/real_project
../bad_cargo/target/release/bad_cargo_inputs build --release
```

Build that hijacks the output:

```
cd build_with_ebpf/real_project
../bad_cargo/target/release/bad_cargo_outputs build --release
```

Once you have run any of the above you can test it via:

```
./target/release/real_project
```

You should get a "Goodbye, World" output on the hijacked ones.

## How to detect compromise

TODO: Flesh this out

* You can use a tool like Falco or Tracee to monitor for memfd creations and execve's against the memfds and capture the memfds.
* You can also capture the executed tools, inputs and outputs and their hashes and compare it to known good hashes.
    * Compare captured cargo that is run against the build against cargo inputs
    * Compare source inputs with upstream sources
    * You can debug captured suspicious binaries in sandboxed environments
