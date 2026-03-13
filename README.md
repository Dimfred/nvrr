# nvrr (neovim-remote-rust)

AI slobbed, `neovim-remote` implementation... in rust... blazingly fast... blabla.

## Install

```bash
brew install Dimfred/tap/nvrr
```

```bash
cargo install nvrr
```

## Usage

By default, `nvrr` connects to the neovim instance specified by the `$NVIM` environment variable. You can override this with the `--remote` flag.

```bash
# Send keys to neovim
nvrr send "iHello World<Esc>"
nvrr send ":w<CR>"

# Evaluate a VimL/Lua expression and print the result
nvrr expr "line('.')"
nvrr expr "expand('%')"

# Use a specific neovim socket
nvrr --remote /path/to/socket send ":q<CR>"
```

## Thank you

Big thank you to `neovim-remote` for powering my nvim automations for the last years.
Big thank you to the peops of `nvim_rs` for making this possible, I am happy I don't have to vibe the serialization stuffz.
