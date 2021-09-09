# Build "compromised" hello world program and add base64 to source
pushd ../attacker_project
cargo build --release --target x86_64-unknown-linux-musl
base64 -w0 ./target/x86_64-unknown-linux-musl/release/attacker_project > ../bad_cargo/src/overwrite_binary/base64_attacker_binary
popd

# Build payload that overwrites built binary and stage it for "compromised" output hijacking cargo source
cargo build --release --bin overwrite_binary --target x86_64-unknown-linux-musl
base64 -w0 ./target/x86_64-unknown-linux-musl/release/overwrite_binary > src/outputs/base64_overwrite_binary

# Build payload that overwrite source files before building and stage it for "compromised" input hijacking cargo source
cargo build --release --bin overwrite_source --target x86_64-unknown-linux-musl
base64 -w0 ./target/x86_64-unknown-linux-musl/release/overwrite_source > src/inputs/base64_overwrite_source

# Build "compromised" output hijacking cargo
cargo build --release --bin bad_cargo_outputs --target x86_64-unknown-linux-musl

# Build "compromised" input hijacking cargo
cargo build --release --bin bad_cargo_inputs --target x86_64-unknown-linux-musl