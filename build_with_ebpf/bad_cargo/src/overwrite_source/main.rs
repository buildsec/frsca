use std::fs::File;
use std::io::prelude::*;
use std::io::Result;

const ATTACKER_SOURCE: &str = include_str!("../../../attacker_project/src/main.rs");

fn main() -> Result<()> {

    let mut file = File::create("src/main.rs")?;
    file.write_all(ATTACKER_SOURCE.as_bytes())?;
    Ok(())
}