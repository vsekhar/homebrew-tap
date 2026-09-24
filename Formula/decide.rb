class Decide < Formula
  desc "Make decisions from the command-line and in scripts"
  homepage "https://github.com/vsekhar/decide"
  url "https://github.com/vsekhar/decide/archive/refs/tags/0.3.0.tar.gz"
  sha256 "738cc40c9bd8c45161bd2b374afa9c15f6f79b4a1ca7a32c52c481ec86cf8a71"
  license "Apache-2.0"
  head "https://github.com/vsekhar/decide.git", branch: "main"

  bottle do
    root_url "https://github.com/vsekhar/homebrew-tap/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "50addc20b0fb5c179ebd9b19fe7df9bdfd62ab83558bb26840a014dd36e1b7e2"
  end

  depends_on :macos

  # Package.swift needs Swift 6.2, which the Xcode 26 Command Line Tools
  # provide. Xcode itself is not needed.
  uses_from_macos "swift" => :build

  deny_network_access!

  def fetch
    # SwiftPM tries to apply its own sandbox, which cannot nest inside the
    # build sandbox; Homebrew's sandbox still confines the whole process.
    system "swift", "package", "resolve", "--disable-sandbox"
  end

  def install
    system "swift", "build", *std_swift_args
    bin.install ".build/release/decide"
  end

  test do
    # With no model configured, decide exits 10 and touches no network.
    output = shell_output("#{bin}/decide --context x 'Is the sky blue?' 2>&1", 10)
    assert_match "DECIDE_MODEL is not set", output
    assert_match "Usage: decide", shell_output("#{bin}/decide --help")
    # The version is a constant in decide's source, set by hand at release.
    # This catches a tarball whose constant lags its tag.
    assert_match version.to_s, shell_output("#{bin}/decide --version")
  end
end
