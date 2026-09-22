class Decide < Formula
  desc "Make decisions from the command-line and in scripts"
  homepage "https://github.com/vsekhar/decide"
  url "https://github.com/vsekhar/decide/archive/refs/tags/0.1.0.tar.gz"
  sha256 "ae5284bb870fa7e486b950e6fb24172d2d37244b18c5fdd945999b6efb384c8c"
  license "Apache-2.0"
  head "https://github.com/vsekhar/decide.git", branch: "main"

  # DecisionModels uses SwiftUI's @Entry macro, whose plugin ships only
  # with Xcode, not with the Command Line Tools. 26.6 is what CI builds with.
  depends_on xcode: ["26.6", :build]
  depends_on :macos

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
  end
end
