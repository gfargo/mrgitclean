class Mrgitclean < Formula
  desc "A friendly tool to clean up merged Git branches"
  homepage "https://github.com/yourusername/mrgitclean"
  url "https://github.com/yourusername/mrgitclean/archive/v1.0.0.tar.gz"
  sha256 "<SHA256_OF_TARBALL>"
  license "MIT"

  def install
    bin.install "bin/mrgitclean"
    # If you create a man page later:
    # man1.install "man/mrgitclean.1"
  end

  test do
    system "#{bin}/mrgitclean", "--help"
  end
end
