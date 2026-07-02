# MrGitClean 🧹

**MrGitClean** is a CLI tool that helps you clean up merged Git branches effortlessly. Instead of manually hunting for merged branches, MrGitClean does the work of listing, confirming, and optionally deleting them. It's interactive by default, safe to use, and easily configurable with various modes and flags.

## Features

- **Interactive by Default:** Prompt before deleting each branch, reducing the risk of accidental removals.
- **Batch Mode:** Use `--batch` to run non-interactively, ideal for large-scale cleanups.
- **Fully Non-Interactive Mode:** Use `-y`/`--yes` to delete all eligible branches in one shot — prints a pre-run summary and final tally, skips all per-branch prompts. Safe to use in CI scripts; combine with `--dry-run` to preview first.
- **Remote Deletions:** With `--remote`, also delete remote branches (always asks for confirmation, unless `--yes` is set).
- **Dry Run:** Test with `--dry-run` to see what would be deleted before actually removing anything.
- **Logging & Filtering:** Log deleted branches with `--log` and limit the cleanup scope using `--include` and `--exclude` patterns.
- **Contextual Info:** Displays the last commit time (including a friendly "X units ago" readout) and the merge commit hash for informed decision-making.
- **TTY-aware Color:** ANSI color output is automatically suppressed when stdout is piped or `NO_COLOR` is set, keeping logs and scripts clean.

## Installation

### Via Homebrew (Beta)

> **Note:** MrGitClean is currently available as a beta release (`v1.0.0-beta.x`). Stable releases will follow once the beta channel matures.

```bash
brew tap gfargo/tap
brew install mrgitclean
```

Or in one step:

```bash
brew install gfargo/tap/mrgitclean
```

Once installed, you can run:

```bash
mrgitclean --help
```

### Manual Installation via `curl`

If Homebrew isn't an option, you can still install MrGitClean directly:

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

**Fully Non-Interactive (CI/Script) Mode:**

```bash
mrgitclean --yes --remote
```

Deletes all eligible local and remote branches with zero per-branch prompts. Prints a pre-run summary of all branches to be deleted and a final tally. Always combine with `--dry-run` first to verify:

```bash
mrgitclean --yes --remote --dry-run
```

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
- The Homebrew formula in [gfargo/homebrew-tap](https://github.com/gfargo/homebrew-tap) is automatically updated so `brew upgrade mrgitclean` always gets the latest beta.

## Contributing

Contributions are welcome! Please submit issues and pull requests on GitHub. When committing changes, following the Conventional Commits format is encouraged, as it helps automate the release and changelog process.

**Enjoy keeping your branches squeaky clean!** 🧼
