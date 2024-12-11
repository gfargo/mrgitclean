# MrGitClean 🧹

**MrGitClean** is a CLI tool that helps you clean up merged Git branches effortlessly. Instead of manually hunting for merged branches, MrGitClean does the work of listing, confirming, and optionally deleting them. It’s interactive by default, safe to use, and easily configurable with various modes and flags.

## Features

- **Interactive by Default:** Prompt before deleting each branch, reducing the risk of accidental removals.
- **Batch Mode:** Use `--batch` to run non-interactively, ideal for large-scale cleanups.
- **Remote Deletions:** With `--remote`, also delete remote branches (always asks for confirmation).
- **Dry Run:** Test with `--dry-run` to see what would be deleted before actually removing anything.
- **Logging & Filtering:** Log deleted branches with `--log` and limit the cleanup scope using `--include` and `--exclude` patterns.
- **Contextual Info:** Displays the last commit time (including a friendly “X units ago” readout) and the merge commit hash for informed decision-making.

## Installation

<!-- 
NOTE: note currently available via Homebrew. Uncomment this section when it is.

### Via Homebrew (Recommended)

If you’re on macOS or Linux, you can install MrGitClean via Homebrew:

```bash
brew tap gfargo/mrgitclean
brew install mrgitclean
```

*(Replace `gfargo` with the actual GitHub username or organization hosting the tap.)*

Once installed, you can run:

```bash
mrgitclean --help
```

For usage details and options. If a man page is included, you can view it by:

```bash
man mrgitclean
``` 
-->

### Manual Installation via `curl`

If Homebrew isn’t an option, you can still install MrGitClean directly:

```bash
curl -sSL https://raw.githubusercontent.com/gfargo/mrgitclean/main/bin/mrgitclean -o /usr/local/bin/mrgitclean
chmod +x /usr/local/bin/mrgitclean
```

Now you can run `mrgitclean` from anywhere.

## Usage Examples

**Default (Interactive) Mode:**

```bash
mrgitclean
```

Prompts you before deleting each eligible branch.

**Batch (Non-Interactive) Mode:**

```bash
mrgitclean --batch
```

Deletes all eligible local branches without prompting (remote still requires confirmation if `--remote` is used).

**Also Delete Remote Branches:**

```bash
mrgitclean --remote
```

After confirming, deletes remote counterparts as well.

**Dry Run:**

```bash
mrgitclean --dry-run
```

Shows what would be deleted without performing any deletions.

## Releases & Changelog

**MrGitClean** uses [semantic-release](https://github.com/semantic-release/semantic-release) to automatically version, tag, and generate release notes based on commit messages. Each commit that follows the [Conventional Commits](https://www.conventionalcommits.org/) specification helps determine the next version number. After a successful release:

- A new GitHub release is created.
- The `CHANGELOG.md` is automatically updated.
- Homebrew formula updates can be integrated into the CI workflow so that the tool’s Homebrew tap is always current.

## Contributing

Contributions are welcome! Please submit issues and pull requests on GitHub. When committing changes, following the Conventional Commits format is encouraged, as it helps automate the release and changelog process.

**Enjoy keeping your branches squeaky clean!** 🧼
