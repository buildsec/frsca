use color_eyre::Report;

#[tokio::main]
async fn main() -> Result<(), Report> {
    setup()?;
    println!("Hello tokio");

    Ok(())
}

fn setup() -> Result<(), Report> {
    color_eyre::install()?;

    Ok(())
}
