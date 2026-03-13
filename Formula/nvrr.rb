class Nvrr < Formula
  desc "Simple neovim-remote in Rust"
  homepage "https://github.com/Dimfred/nvrr"
  url "https://github.com/Dimfred/nvrr/archive/refs/tags/v0.1.0.tar.gz"
  sha256 ""
  license "MIT"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "nvrr", shell_output("#{bin}/nvrr --help")
  end
end
