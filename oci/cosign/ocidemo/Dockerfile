FROM rust:1.55-slim-bullseye as builder
WORKDIR /usr/src/demo
COPY . .
RUN cargo build --release

FROM debian:bullseye-slim
WORKDIR /usr/src/demo
COPY --from=builder /usr/src/demo/target/release/ocidemo /usr/local/bin
ENTRYPOINT ["ocidemo"]
