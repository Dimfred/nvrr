class Nvrr < Formula
  desc "Simple neovim-remote in Rust"
  homepage "https://github.com/Dimfred/nvrr"
  url "https://github.com/Dimfred/nvrr/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "b2143d0e7aba302ebac5351aaa0852954168de5f8fc29f17329f02ba6495eb94"
  license "MIT"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "nvrr", shell_output("#{bin}/nvrr --help")
  end
end
