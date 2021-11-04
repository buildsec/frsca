from rust:latest

COPY "target/x86_64-unknown-linux-musl/release/bad_cargo_outputs" "/usr/local/cargo/bin/"
RUN ["mv", "/usr/local/cargo/bin/cargo", "/tmp/cargo"]
RUN ["mv", "/usr/local/cargo/bin/bad_cargo_outputs", "/usr/local/cargo/bin/cargo"]