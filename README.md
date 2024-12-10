# MrGitClean 🧹

**MrGitClean** is a friendly command-line tool that helps you tidy up your Git repository by removing local (and optionally remote) branches that have already been merged back into your main branch. Instead of manually hunting down old branches and deleting them one-by-one, MrGitClean does the heavy lifting in an interactive, user-friendly manner.

## Features
- **Interactive by default:** Prompt before deleting each branch, ensuring you never accidentally remove something important.
- **Batch mode:** Run non-interactively (`--batch`) to quickly clean up large numbers of branches.
- **Remote cleaning:** Use `--remote` to also remove remote branches (with safeguards and prompts).
- **Dry run:** Use `--dry-run` to see what would be deleted before making changes.
- **Logging:** Write deleted branch names to a log file via `--log`.
- **Filtering:** Include or exclude branches based on patterns.
- **Helpful context:** Shows last commit time (including a "human-friendly" relative time) and the merge commit hash, giving you all the info you need to decide if a branch should go.

## Installation

### 1. Homebrew (macOS/Linux)

As an individual developer, you can create your own custom Homebrew tap. For example, if your GitHub username is `yourusername` and the repo is `mrgitclean`, you can do the following:

1. **Create a Tap Repository** on GitHub:  
   - Create a new repo named `homebrew-mrgitclean` under your account: `https://github.com/yourusername/homebrew-mrgitclean`.
   
2. **Add a Formula:**  
   Inside your `homebrew-mrgitclean` repo, create a `Formula/mrgitclean.rb` file:
   ```ruby
   class Mrgitclean < Formula
     desc "A friendly tool to clean up merged Git branches"
     homepage "https://github.com/yourusername/mrgitclean"
     url "https://github.com/yourusername/mrgitclean/archive/v1.0.0.tar.gz"
     sha256 "<SHA256_OF_TARBALL>"
     license "MIT"

     def install
       bin.install "bin/mrgitclean"
       # If you add a man page later, you can install it like:
       # man1.install "man/mrgitclean.1"
     end

     test do
       system "#{bin}/mrgitclean", "--help"
     end
   end
