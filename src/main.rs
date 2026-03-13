mod client;

use std::env;

use anyhow::{bail, Result};
use clap::{Parser, Subcommand};

use client::NvimClient;

#[derive(Parser)]
#[command(name = "nvrr", about = "neovim-remote in Rust")]
struct Cli {
    /// Path to neovim socket. Defaults to $NVIM env var.
    #[arg(long)]
    remote: Option<String>,

    #[command(subcommand)]
    command: Command,
}

#[derive(Subcommand)]
enum Command {
    /// Send keys/input to neovim
    Send {
        /// The keys or input to send
        input: String,
    },
    /// Evaluate a VimL/Lua expression and print the result
    Expr {
        /// The expression to evaluate
        expression: String,
    },
}

fn resolve_socket(remote: Option<String>) -> Result<String> {
    if let Some(addr) = remote {
        return Ok(addr);
    }
    if let Ok(addr) = env::var("NVIM") {
        return Ok(addr);
    }
    bail!("No neovim socket found. Use --remote or set $NVIM.")
}

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();
    let socket = resolve_socket(cli.remote)?;
    let client = NvimClient::connect(&socket).await?;

    match cli.command {
        Command::Send { input } => {
            client.send(&input).await?;
        }
        Command::Expr { expression } => {
            let result = client.expr(&expression).await?;
            println!("{result}");
        }
    }

    Ok(())
}
