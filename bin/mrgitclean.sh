#!/usr/bin/env zsh

# Color codes
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
BOLD="\e[1m"
DIM="\e[2m"
RESET="\e[0m"

# Default branches to skip by default unless explicitly included
DEFAULT_SKIP_BRANCHES=("main" "master" "develop")

# Helper: Print error messages in red
error_msg() {
  echo -e "${RED}${BOLD}Error:${RESET} $1"
}

# Helper: Print info messages in green
info_msg() {
  echo -e "${GREEN}$1${RESET}"
}

# Helper: Print warning/important notices in yellow
warn_msg() {
  echo -e "${YELLOW}$1${RESET}"
}

# Helper: Determine the default branch from origin/HEAD
get_default_branch() {
  local default_branch
  default_branch=$(git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's|^origin/||')
  echo "$default_branch"
}

# Helper: Get merged branches into the default branch
get_merged_branches() {
  local default_branch="$1"
  git branch --merged "origin/$default_branch" \
    | sed 's/^\*//; s/^[[:space:]]*//; s/[[:space:]]*$//' \
    | grep -v "^$default_branch$"  # exclude the default branch itself
}

# Helper: Filter branches according to skip, exclude, and include patterns
filter_branches() {
  local branches=("$@")
  local filtered=()

  for b in "${branches[@]}"; do
    [[ -z "$b" ]] && continue
    if [[ " ${DEFAULT_SKIP_BRANCHES[@]} " =~ " $b " ]]; then
      continue
    fi
    if [[ -n "$exclude_pattern" && "$b" == $exclude_pattern ]]; then
      continue
    fi
    if [[ -n "$include_pattern" && "$b" != $include_pattern ]]; then
      continue
    fi
    filtered+=("$b")
  done

  echo "${filtered[@]}"
}

# Convert seconds to a human-readable "X units ago" format
relative_time_ago() {
  local seconds="$1"
  if (( seconds < 60 )); then
    echo "${seconds} second(s) ago"
    return
  fi

  local minutes=$((seconds / 60))
  if (( minutes < 60 )); then
    echo "${minutes} minute(s) ago"
    return
  fi

  local hours=$((minutes / 60))
  if (( hours < 24 )); then
    echo "${hours} hour(s) ago"
    return
  fi

  local days=$((hours / 24))
  if (( days < 30 )); then
    echo "${days} day(s) ago"
    return
  fi

  local months=$((days / 30))
  if (( months < 12 )); then
    echo "${months} month(s) ago"
    return
  fi

  local years=$((months / 12))
  echo "${years} year(s) ago"
}

# Helper: Get last commit timestamp (and friendly time) for a branch
get_branch_last_commit_info() {
  local branch="$1"
  local commit_ts
  commit_ts=$(git log -1 --format="%ct" "$branch" 2>/dev/null)
  if [[ -z "$commit_ts" ]]; then
    echo "Unknown"
    return
  fi

  local now
  now=$(date +%s)
  local diff=$(( now - commit_ts ))
  local friendly
  friendly=$(relative_time_ago "$diff")

  local commit_date
  commit_date=$(git log -1 --format="%ci" "$branch" 2>/dev/null)

  echo "$commit_date ($friendly)"
}

# Helper: Find the merge commit hash that introduced the branch
get_merge_commit_hash() {
  local default_branch="$1"
  local branch="$2"

  local merge_commit
  merge_commit=$(git log --merges --ancestry-path "$(git merge-base origin/$default_branch $branch)"..origin/$default_branch --format="%H" -1 2>/dev/null)
  if [[ -z "$merge_commit" ]]; then
    echo "N/A"
  else
    echo "$merge_commit"
  fi
}

# Helper: Prompt user for deletion
prompt_for_deletion() {
  local branch="$1"
  local remote_mode="$2"
  local last_commit_info="$3"
  local merge_commit="$4"

  # Separator line before showing next branch (for clarity)
  echo -e "\n${DIM}-----------------------------------------${RESET}"

  if $remote_mode; then
    warn_msg "Warning: Deleting remote branches affects all users."
  fi

  echo -e "${BLUE}${BOLD}Branch:${RESET} ${branch}"
  echo -e "${DIM}Last commit:${RESET} $last_commit_info"
  echo -e "${DIM}Merge commit:${RESET} $merge_commit"

  local prompt_msg="Delete this branch"
  [[ $remote_mode == true ]] && prompt_msg="Delete this branch (and potentially remote)"

  echo -en "${YELLOW}${prompt_msg}? [y/N]${RESET} "
  read -r confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    return 0
  else
    return 1
  fi
}

# Helper: Delete local branch
delete_local_branch() {
  local branch="$1"
  if ! git branch -d "$branch" &>/dev/null; then
    git branch -D "$branch" &>/dev/null
  fi
}

# Helper: Delete remote branch
delete_remote_branch() {
  local branch="$1"
  git push origin --delete "$branch" &>/dev/null || warn_msg "Remote branch '$branch' not found or could not be deleted."
}

git_clean_merged_branches() {
  # Default to interactive mode
  local interactive=true
  local remote=false
  local dry_run=false
  local log_file=""
  include_pattern=""
  exclude_pattern=""
  local batch_mode=false

  # Parse flags
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --batch) batch_mode=true; interactive=false ;;
      --remote) remote=true ;;
      --dry-run) dry_run=true ;;
      --log)
        shift
        log_file="$1"
      ;;
      --exclude)
        shift
        exclude_pattern="$1"
      ;;
      --include)
        shift
        include_pattern="$1"
      ;;
      --help)
        echo "Usage: mrgitclean [--batch] [--remote] [--dry-run] [--log <file>] [--exclude <pattern>] [--include <pattern>]"
        echo "By default, runs in interactive mode."
        echo "--batch: Run in non-interactive mode for local branches."
        echo "--remote: Also attempt to delete remote branches (always prompts)."
        echo "--dry-run: Show what would be deleted without deleting."
        echo "--log <file>: Log deleted branches to a file."
        echo "--exclude <pattern>: Exclude branches matching this pattern."
        echo "--include <pattern>: Only include branches matching this pattern."
        return 0
      ;;
      *)
        error_msg "Unknown option: $1"
        return 1
      ;;
    esac
    shift
  done

  # Ensure we are in a git repository and can determine default branch
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    error_msg "Not inside a git repository."
    return 1
  fi

  local default_branch
  default_branch=$(get_default_branch)
  if [[ -z "$default_branch" ]]; then
    error_msg "Unable to determine default branch. Ensure 'origin/HEAD' is set."
    return 1
  fi

  # Fetch updates
  git fetch origin &>/dev/null

  # Get merged branches
  local merged
  merged=($(get_merged_branches "$default_branch"))

  # Filter branches
  local branch_list
  branch_list=($(filter_branches "${merged[@]}"))

  if [[ ${#branch_list[@]} -eq 0 ]]; then
    info_msg "No merged branches to clean up."
    return 0
  fi

  info_msg "Default branch is: $default_branch"
  info_msg "Found ${#branch_list[@]} merged branches eligible for cleanup."

  for b in "${branch_list[@]}"; do
    local last_commit_info
    last_commit_info=$(get_branch_last_commit_info "$b")

    local merge_commit
    merge_commit=$(get_merge_commit_hash "$default_branch" "$b")

    local should_delete=true
    # Always prompt if interactive or remote requested.
    # If batch_mode for local only, no prompt needed (unless remote).
    if $interactive || $remote; then
      if ! prompt_for_deletion "$b" "$remote" "$last_commit_info" "$merge_commit"; then
        info_msg "Skipped '$b'"
        should_delete=false
        echo
      fi
    fi

    if $should_delete; then
      if $dry_run; then
        info_msg "[DRY-RUN] Would delete: $b"
        echo
      else
        delete_local_branch "$b"
        info_msg "Deleted local branch '$b'"
        [[ -n "$log_file" ]] && echo "$b" >> "$log_file"
        echo
      fi

      if $remote; then
        # Even in batch mode, remote deletion prompts again for safety if not interactive.
        if $batch_mode && ! $interactive && ! $dry_run; then
          warn_msg "You chose remote deletion in batch mode. Confirm again to delete remote '$b': [y/N]"
          read -r confirm2
          if [[ "$confirm2" =~ ^[Yy]$ ]]; then
            delete_remote_branch "$b"
            info_msg "Deleted remote branch '$b'"
            [[ -n "$log_file" ]] && echo "remote:$b" >> "$log_file"
          else
            info_msg "Skipped remote deletion for '$b'"
          fi
          echo
        elif $dry_run; then
          info_msg "[DRY-RUN] Would delete remote branch '$b'"
          echo
        else
          # Interactive mode already got user confirmation
          if $interactive; then
            delete_remote_branch "$b"
            info_msg "Deleted remote branch '$b'"
            [[ -n "$log_file" ]] && echo "remote:$b" >> "$log_file"
            echo
          fi
        fi
      fi
    fi
  done
}

alias mrgitclean=git_clean_merged_branches
