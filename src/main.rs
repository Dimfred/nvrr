use clap::Parser;

#[derive(Parser)]
#[command(name = "nvrr", about = "neovim-remote in Rust")]
struct Cli {
    #[arg(short, long)]
    verbose: bool,
}

fn main() {
    let _cli = Cli::parse();
}
