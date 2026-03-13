use anyhow::{Context, Result};
use nvim_rs::create::tokio::new_path;
use nvim_rs::rpc::handler::Dummy as DummyHandler;

#[cfg(unix)]
type Connection = tokio::net::UnixStream;
#[cfg(windows)]
type Connection = tokio::net::windows::named_pipe::NamedPipeClient;

pub struct NvimClient {
    nvim: nvim_rs::Neovim<
        nvim_rs::compat::tokio::Compat<tokio::io::WriteHalf<Connection>>,
    >,
    _io_handle: tokio::task::JoinHandle<Result<(), Box<nvim_rs::error::LoopError>>>,
}

impl NvimClient {
    pub async fn connect(socket_path: &str) -> Result<Self> {
        let (nvim, io_handle) = new_path(socket_path, DummyHandler::new())
            .await
            .with_context(|| format!("Failed to connect to neovim at: {socket_path}"))?;

        Ok(Self {
            nvim,
            _io_handle: io_handle,
        })
    }

    pub async fn send(&self, input: &str) -> Result<()> {
        self.nvim
            .input(input)
            .await
            .map_err(|e| anyhow::anyhow!("Failed to send input: {e}"))?;
        Ok(())
    }

    pub async fn expr(&self, expression: &str) -> Result<rmpv::Value> {
        let val = self
            .nvim
            .eval(expression)
            .await
            .map_err(|e| anyhow::anyhow!("Failed to evaluate expression: {e}"))?;
        Ok(val)
    }
}
