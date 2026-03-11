# nvrr

neovim-remote rewritten in Rust. CLI tool to control Neovim instances remotely via RPC.

You're my coding assistant, remember these preferences:

## Project Structure

- `src/` — all source code
- `tests/` — all tests (never place tests next to source files)
- Entrypoint: `src/main.rs`
- CLI parsing: `clap` with derive macros

## Build & Commands

- Prefer `make` commands over raw `cargo` commands
- `make build` / `make build-release` — build
- `make test` — run tests
- `make lint` — clippy with warnings as errors
- `make fmt` — format code
- `make check` — run all checks (fmt, lint, test)
- `make install` — install binary locally

## Code Style

- Early returns over nested ifs: check → return if not true, then do thing
- Keep functions focused and small
- Use `thiserror` for error types, `anyhow` for application errors
