#!/bin/bash

# Script to create a GitHub PR with an AI-generated description
# Usage: ./create-pr.sh [options] [base-branch] [pr-title]
# Example: ./create-pr.sh main "Add new feature"
#
# Options:
#   -h, --help            Show this help message
#   --ai=claude|codex|vibe Choose AI backend (default: auto-detect, fallback: claude)
#   --no-ai              Skip AI-powered description generation (faster but less detailed)
#   --no-interactive     Skip all prompts, use defaults/arguments
#   --update             Update existing PR description for current branch

set -e

# Help function
display_help() {
    cat <<'EOF'
Script to create a GitHub PR with an AI-generated description

Usage: ./create-pr.sh [options] [base-branch] [pr-title]
Example: ./create-pr.sh main "Add new feature"

Options:
  -h, --help            Show this help message and exit
  --ai=claude|codex|vibe Choose AI backend (default: auto-detect)
  --no-ai              Skip AI description generation
  --no-interactive     Skip all interactive prompts
  --update             Update existing PR for current branch

Arguments:
  [base-branch]        Target branch for PR (default: main)
  [pr-title]           PR title (prompted if not provided)

Examples:
  ./create-pr.sh --ai=vibe
  ./create-pr.sh main "Add new feature" --no-ai
  ./create-pr.sh --update --ai=claude
EOF
    exit 0
}

# Parse options
USE_AI=""
INTERACTIVE=true
UPDATE_MODE=false
AI_TOOL="claude"
AI_TOOL_SPECIFIED=false
ARGS=()
while [ $# -gt 0 ]; do
    case "$1" in
    -h|--help)
        display_help
        ;;
    --no-ai)
        USE_AI=false
        ;;
    --no-interactive)
        INTERACTIVE=false
        ;;
    --update)
        UPDATE_MODE=true
        ;;
    --ai=*)
        AI_TOOL="${1#--ai=}"
        AI_TOOL_SPECIFIED=true
        ;;
    --ai)
        if [ -n "${2:-}" ]; then
            AI_TOOL="$2"
            AI_TOOL_SPECIFIED=true
            shift
        else
            echo "Error: --ai requires a value (claude, codex, or vibe)."
            exit 1
        fi
        ;;
    *)
        ARGS+=("$1")
        ;;
    esac
    shift
done
set -- "${ARGS[@]}"

AI_TOOL=$(echo "$AI_TOOL" | tr '[:upper:]' '[:lower:]')
if [ "$AI_TOOL" != "claude" ] && [ "$AI_TOOL" != "codex" ] && [ "$AI_TOOL" != "vibe" ]; then
    echo "Error: Unsupported AI tool '$AI_TOOL'. Use 'claude', 'codex', or 'vibe'."
    exit 1
fi

# CLI command names can be overridden via environment if needed
CLAUDE_COMMAND=${CLAUDE_COMMAND:-claude}
CODEX_COMMAND=${CODEX_COMMAND:-codex}
VIBE_COMMAND=${VIBE_COMMAND:-vibe}

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not a git repository."
    exit 1
fi

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed."
    echo "Install it with: brew install gh"
    exit 1
fi

# Get the base branch (e.g., main, master, develop)
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Interactive prompts
if [ "$INTERACTIVE" = true ]; then
    echo ""
    echo "🚀 Create Pull Request"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Current branch: $CURRENT_BRANCH"
    echo ""

    # Prompt for base branch (not needed in update mode)
    if [ "$UPDATE_MODE" = false ]; then
        if [ -z "$1" ]; then
            read -p "Base branch (default: main): " input_base
            BASE_BRANCH="${input_base:-main}"
        else
            BASE_BRANCH="$1"
        fi

        # Prompt for PR title
        if [ -z "$2" ]; then
            # Generate default title from branch name
            DEFAULT_TITLE=$(echo "$CURRENT_BRANCH" | sed 's/[-_]/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')
            echo ""
            read -p "PR title (default: $DEFAULT_TITLE): " input_title
            PR_TITLE="${input_title:-$DEFAULT_TITLE}"
        else
            PR_TITLE="$2"
        fi
    else
        BASE_BRANCH="${1:-main}"
        PR_TITLE="${2:-}"
    fi

    # Prompt for AI mode if not already specified
    if [ -z "$USE_AI" ]; then
        echo ""

        AVAILABLE_AI_TOOLS=()
        command -v "$CLAUDE_COMMAND" &> /dev/null && AVAILABLE_AI_TOOLS+=("claude")
        command -v "$CODEX_COMMAND" &> /dev/null && AVAILABLE_AI_TOOLS+=("codex")
        command -v "$VIBE_COMMAND" &> /dev/null && AVAILABLE_AI_TOOLS+=("vibe")

        if [ ${#AVAILABLE_AI_TOOLS[@]} -eq 0 ]; then
            echo "⚠️  No AI CLI found (checked for '$CLAUDE_COMMAND', '$CODEX_COMMAND', and '$VIBE_COMMAND'). AI mode not available."
            USE_AI=false
        else
            echo "AI-powered description generation is available."
            read -p "Use AI to generate description? (Y/n): " use_ai_input
            if [[ "$use_ai_input" =~ ^[Nn] ]]; then
                USE_AI=false
            else
                USE_AI=true
                if [ "$AI_TOOL_SPECIFIED" = false ] && [ ${#AVAILABLE_AI_TOOLS[@]} -gt 1 ]; then
                    echo ""
                    echo "Available AI tools: ${AVAILABLE_AI_TOOLS[*]}"
                    read -p "Choose AI tool [default: $AI_TOOL]: " chosen_ai_tool
                    if [ -n "$chosen_ai_tool" ]; then
                        chosen_ai_tool=$(echo "$chosen_ai_tool" | tr '[:upper:]' '[:lower:]')
                        if [[ " ${AVAILABLE_AI_TOOLS[*]} " =~ " ${chosen_ai_tool} " ]]; then
                            AI_TOOL="$chosen_ai_tool"
                        else
                            echo "⚠️  '$chosen_ai_tool' not available. Using '$AI_TOOL'."
                        fi
                    fi
                fi
            fi
        fi
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
else
    # Non-interactive mode: use arguments and defaults
    BASE_BRANCH="${1:-main}"

    if [ -n "$2" ]; then
        PR_TITLE="$2"
    else
        # Generate title from branch name
        PR_TITLE=$(echo "$CURRENT_BRANCH" | sed 's/[-_]/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')
    fi

    # Set AI mode default if not specified
    if [ -z "$USE_AI" ]; then
        if [ "$AI_TOOL" = "codex" ] && command -v "$CODEX_COMMAND" &> /dev/null; then
            USE_AI=true
        elif [ "$AI_TOOL" = "vibe" ] && command -v "$VIBE_COMMAND" &> /dev/null; then
            USE_AI=true
        elif [ "$AI_TOOL" = "claude" ] && command -v "$CLAUDE_COMMAND" &> /dev/null; then
            USE_AI=true
        elif command -v "$CLAUDE_COMMAND" &> /dev/null; then
            AI_TOOL="claude"
            USE_AI=true
        elif command -v "$CODEX_COMMAND" &> /dev/null; then
            AI_TOOL="codex"
            USE_AI=true
        elif command -v "$VIBE_COMMAND" &> /dev/null; then
            AI_TOOL="vibe"
            USE_AI=true
        else
            USE_AI=false
        fi
    fi
fi

# Check if we're on the base branch
if [ "$CURRENT_BRANCH" == "$BASE_BRANCH" ]; then
    echo "Error: You are currently on the base branch '$BASE_BRANCH'."
    echo "Please create a feature branch first."
    exit 1
fi

# Check if branch is pushed to remote
if ! git ls-remote --exit-code --heads origin "$CURRENT_BRANCH" > /dev/null 2>&1; then
    echo "Branch '$CURRENT_BRANCH' is not pushed to remote."
    echo "Pushing to origin..."
    git push -u origin "$CURRENT_BRANCH"
fi

# Get the GitHub repository URL for file links
REPO_URL=$(git remote get-url origin | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')

# Get the list of commits since branching from the base branch
COMMITS=$(git log --pretty=format:"- %s (%h)" "$BASE_BRANCH".."$CURRENT_BRANCH")
COMMIT_COUNT=$(git rev-list --count "$BASE_BRANCH".."$CURRENT_BRANCH")

# Get the list of changed files with their status
CHANGED_FILES=$(git diff --name-status "$BASE_BRANCH"..."$CURRENT_BRANCH")

# Separate lock files from regular files
LOCK_FILE_PATTERN="composer\.lock|package-lock\.json|yarn\.lock|pnpm-lock\.yaml|Gemfile\.lock|poetry\.lock"
LOCK_FILES=$(echo "$CHANGED_FILES" | grep -E "$LOCK_FILE_PATTERN" || true)
CHANGED_FILES_NO_LOCKS=$(echo "$CHANGED_FILES" | grep -vE "$LOCK_FILE_PATTERN" || echo "$CHANGED_FILES")

# Get the summary of changes (additions/deletions)
CHANGES_STATS=$(git diff --stat "$BASE_BRANCH"..."$CURRENT_BRANCH" | tail -n 1)

# Count files by type
FILES_ADDED=$(echo "$CHANGED_FILES" | grep -c "^A" 2>/dev/null || echo "0")
FILES_MODIFIED=$(echo "$CHANGED_FILES" | grep -c "^M" 2>/dev/null || echo "0")
FILES_DELETED=$(echo "$CHANGED_FILES" | grep -c "^D" 2>/dev/null || echo "0")
FILES_RENAMED=$(echo "$CHANGED_FILES" | grep -c "^R" 2>/dev/null || echo "0")

# Ensure variables are valid integers
FILES_ADDED=${FILES_ADDED//[^0-9]/}
FILES_MODIFIED=${FILES_MODIFIED//[^0-9]/}
FILES_DELETED=${FILES_DELETED//[^0-9]/}
FILES_RENAMED=${FILES_RENAMED//[^0-9]/}

# Default to 0 if empty
FILES_ADDED=${FILES_ADDED:-0}
FILES_MODIFIED=${FILES_MODIFIED:-0}
FILES_DELETED=${FILES_DELETED:-0}
FILES_RENAMED=${FILES_RENAMED:-0}

# Generate introductory summary
INTRO="This pull request introduces changes from the \`$CURRENT_BRANCH\` branch into \`$BASE_BRANCH\`. "
INTRO+="The changes include $COMMIT_COUNT commit(s) affecting "

FILE_SUMMARY=""
[ "$FILES_ADDED" -gt 0 ] && FILE_SUMMARY+="$FILES_ADDED added"
[ "$FILES_MODIFIED" -gt 0 ] && [ -n "$FILE_SUMMARY" ] && FILE_SUMMARY+=", "
[ "$FILES_MODIFIED" -gt 0 ] && FILE_SUMMARY+="$FILES_MODIFIED modified"
[ "$FILES_DELETED" -gt 0 ] && [ -n "$FILE_SUMMARY" ] && FILE_SUMMARY+=", "
[ "$FILES_DELETED" -gt 0 ] && FILE_SUMMARY+="$FILES_DELETED deleted"
[ "$FILES_RENAMED" -gt 0 ] && [ -n "$FILE_SUMMARY" ] && FILE_SUMMARY+=", "
[ "$FILES_RENAMED" -gt 0 ] && FILE_SUMMARY+="$FILES_RENAMED renamed"

INTRO+="$FILE_SUMMARY file(s)."

# Function to detect change categories based on file patterns
detect_categories() {
    local categories=""

    # Check for dependency changes
    if echo "$CHANGED_FILES" | grep -q "composer.json\|composer.lock\|package.json\|package-lock.json"; then
        categories+="dependencies "
    fi

    # Check for documentation changes
    if echo "$CHANGED_FILES" | grep -q "\.md$\|docs/\|README"; then
        categories+="documentation "
    fi

    # Check for configuration changes
    if echo "$CHANGED_FILES" | grep -q "config/\|\.yml$\|\.yaml$\|\.env"; then
        categories+="configuration "
    fi

    # Check for theme/styling changes
    if echo "$CHANGED_FILES" | grep -q "\.css$\|\.scss$\|tailwind\|theme"; then
        categories+="styling "
    fi

    # Check for JavaScript/block changes
    if echo "$CHANGED_FILES" | grep -q "\.js$\|\.jsx$\|\.ts$\|\.tsx$\|blocks/"; then
        categories+="javascript "
    fi

    # Check for PHP/backend changes
    if echo "$CHANGED_FILES" | grep -q "\.php$"; then
        categories+="php "
    fi

    # Check for build/CI changes
    if echo "$CHANGED_FILES" | grep -q "vite\|webpack\|\.github/\|ansible"; then
        categories+="build "
    fi

    echo "$categories"
}

CHANGE_CATEGORIES=$(detect_categories)

# Generate files changed section with clickable links grouped by status
generate_file_list() {
    local section=""
    local total_files=0
    local added_files=()
    local modified_files=()
    local deleted_files=()
    local renamed_files=()

    # First pass: collect and categorize files
    while IFS=$'\t' read -r status file remaining; do
        [ -z "$file" ] && continue
        ((total_files++))

        # Handle renamed files (format: "R100\toldname\tnewname")
        if [[ $status == R* ]]; then
            renamed_files+=("$file|$remaining")
        elif [ "$status" == "A" ]; then
            added_files+=("$file")
        elif [ "$status" == "M" ]; then
            modified_files+=("$file")
        elif [ "$status" == "D" ]; then
            deleted_files+=("$file")
        fi
    done <<< "$CHANGED_FILES_NO_LOCKS"

    # Function to detect bulk deletions (5+ files with same directory/pattern)
    group_bulk_deletions() {
        local files=("$@")
        local dirs_found=""
        local processed_dirs=""

        # Get unique directories and count files per directory
        for file in "${files[@]}"; do
            local dir=$(dirname "$file")
            dirs_found+="$dir"$'\n'
        done

        # Process each unique directory
        local unique_dirs=$(echo "$dirs_found" | sort -u)
        while IFS= read -r dir; do
            [ -z "$dir" ] && continue

            # Count files in this directory
            local count=0
            for file in "${files[@]}"; do
                if [ "$(dirname "$file")" = "$dir" ]; then
                    ((count++))
                fi
            done

            # Group if 5+ files
            if [ "$count" -ge 5 ]; then
                # Mark this directory as processed
                processed_dirs+="$dir"$'\n'

                # Get file extension if consistent
                local extensions=""
                for file in "${files[@]}"; do
                    if [ "$(dirname "$file")" = "$dir" ]; then
                        extensions+="${file##*.}"$'\n'
                    fi
                done

                local unique_ext=$(echo "$extensions" | sort -u | grep -v "^$")
                local ext_count=$(echo "$unique_ext" | wc -l | tr -d ' ')

                if [ "$ext_count" -eq 1 ] && [ -n "$unique_ext" ]; then
                    echo "**$count files deleted** from \`$dir/\` directory (*.$unique_ext files)"
                else
                    echo "**$count files deleted** from \`$dir/\` directory"
                fi
            fi
        done <<< "$unique_dirs"

        # Output individual files from directories with <5 deletions
        for file in "${files[@]}"; do
            local file_dir=$(dirname "$file")
            if ! echo "$processed_dirs" | grep -q "^${file_dir}$"; then
                echo "FILE:$file"
            fi
        done
    }

    # Add renamed files
    if [ ${#renamed_files[@]} -gt 0 ]; then
        for rename_pair in "${renamed_files[@]}"; do
            local oldfile="${rename_pair%|*}"
            local newfile="${rename_pair#*|}"
            section+="- [\`$newfile\`]($REPO_URL/blob/$CURRENT_BRANCH/$newfile) (renamed from \`$oldfile\`)\n"
        done
    fi

    # Add modified files
    if [ ${#modified_files[@]} -gt 0 ]; then
        for file in "${modified_files[@]}"; do
            section+="- [\`$file\`]($REPO_URL/blob/$CURRENT_BRANCH/$file) (Modified)\n"
        done
    fi

    # Add added files
    if [ ${#added_files[@]} -gt 0 ]; then
        for file in "${added_files[@]}"; do
            section+="- [\`$file\`]($REPO_URL/blob/$CURRENT_BRANCH/$file) (Added)\n"
        done
    fi

    # Add deleted files with bulk grouping
    if [ ${#deleted_files[@]} -gt 0 ]; then
        local deletion_output=$(group_bulk_deletions "${deleted_files[@]}")

        while IFS= read -r line; do
            if [[ "$line" == FILE:* ]]; then
                # Individual file
                local file="${line#FILE:}"
                section+="- \`$file\` (Deleted)\n"
            elif [ -n "$line" ]; then
                # Grouped summary
                section+="- $line\n"
            fi
        done <<< "$deletion_output"
    fi

    # Add lock files summary if any exist
    if [ -n "$LOCK_FILES" ]; then
        local lock_file_names=$(echo "$LOCK_FILES" | awk '{print $2}' | xargs basename -a | tr '\n' ', ' | sed 's/, $//')
        section+="\n*Dependency lock files updated:* $lock_file_names\n"
    fi

    echo -e "$section"
}

FILES_SECTION=$(generate_file_list)

# Function to generate AI-powered description using Claude CLI
generate_ai_description() {
    if [ "$USE_AI" = false ]; then
        echo ""
        return
    fi

    echo "" >&2
    echo "🤖 Generating AI-powered description..." >&2

    # Prepare the prompt for Claude
    local prompt="Analyze the following commit messages and changed files to provide a concise, professional PR description.

REQUIREMENTS:
- Start with ONE paragraph (4-5 sentences) that provides a comprehensive summary of the main changes, their purpose, and their impact. Include key technical details and context based on the commit messages and file paths.
- Follow with 2-4 sections with **bold headings:** that group related changes (e.g., 'Theme Features and Architecture:', 'Documentation and Developer Guidance:', etc.)
- Under each section, use bullet points that explain WHAT changed and WHY, with specific technical details
- Include specific details like version numbers, file counts, or architectural decisions when visible in commits
- Use professional technical writing - NO emoticons, NO casual language
- Focus on the most important changes first
- Keep each bullet point to 1-2 sentences maximum

CHANGED FILES (excluding lock files):
$CHANGED_FILES_NO_LOCKS

COMMIT MESSAGES:
$COMMITS

CHANGE SUMMARY:
$CHANGES_STATS

CATEGORIES DETECTED: $CHANGE_CATEGORIES

LOCK FILES UPDATED: $(echo "$LOCK_FILES" | awk '{print $2}' | xargs basename -a 2>/dev/null | tr '\n' ', ' | sed 's/, $//' || echo "none")

Now provide ONLY the description content (no meta-commentary). Start directly with the summary paragraph."

    local ai_command ai_args=()
    local tmp_error
    tmp_error=$(mktemp)

    if [ "$AI_TOOL" = "codex" ]; then
        ai_command="$CODEX_COMMAND"
        if [ -n "${CODEX_CLI_ARGS:-}" ]; then
            # shellcheck disable=SC2206
            ai_args=($CODEX_CLI_ARGS)
        fi
    elif [ "$AI_TOOL" = "vibe" ]; then
        ai_command="$VIBE_COMMAND"
        if [ -n "${VIBE_CLI_ARGS:-}" ]; then
            # shellcheck disable=SC2206
            ai_args=($VIBE_CLI_ARGS)
        else
            ai_args=(-p)
        fi
    else
        ai_command="$CLAUDE_COMMAND"
        if [ -n "${CLAUDE_CLI_ARGS:-}" ]; then
            # shellcheck disable=SC2206
            ai_args=($CLAUDE_CLI_ARGS)
        else
            ai_args=(--print)
        fi
    fi

    if ! command -v "$ai_command" > /dev/null 2>&1; then
        echo "" >&2
        echo "⚠️  AI tool '$ai_command' not found. Skipping AI description." >&2
        echo "" >&2
        echo ""
        rm -f "$tmp_error"
        return
    fi

    local ai_description=""
    local exit_code=0

    # Call selected AI CLI (Codex requires exec for non-interactive output, Vibe requires prompt as argument)
    set +e
    if [ "$AI_TOOL" = "codex" ]; then
        local tmp_output
        tmp_output=$(mktemp)
        echo "$prompt" | "$ai_command" "${ai_args[@]}" exec --skip-git-repo-check --output-last-message "$tmp_output" - >"$tmp_error" 2>&1
        exit_code=$?
        if [ $exit_code -eq 0 ]; then
            ai_description=$(cat "$tmp_output")
        fi
        rm -f "$tmp_output"
    elif [ "$AI_TOOL" = "vibe" ]; then
        ai_description=$("$ai_command" "${ai_args[@]}" "$prompt" --output text < /dev/null 2>&1)
        exit_code=$?
    else
        ai_description=$(echo "$prompt" | "$ai_command" "${ai_args[@]}" 2>"$tmp_error")
        exit_code=$?
    fi
    set -e

    local error_output
    error_output=$(cat "$tmp_error")
    rm -f "$tmp_error"

    if [ $exit_code -eq 0 ] && [ -n "$ai_description" ]; then
        echo "$ai_description"
    else
        echo "" >&2
        echo "⚠️  AI description generation failed ($AI_TOOL). Using basic description." >&2
        if [ -n "$error_output" ]; then
            echo "$error_output" >&2
        else
            echo "   Make sure you're authenticated with the selected AI CLI ($AI_TOOL)." >&2
        fi
        echo "" >&2
        echo ""
    fi
}

# Generate AI description
AI_DESCRIPTION=$(generate_ai_description)

# Build the PR body
if [ -n "$AI_DESCRIPTION" ]; then
    # Use AI-generated description with file list appended
    PR_BODY="$AI_DESCRIPTION

**Files Changed:**

$FILES_SECTION"
else
    # Fallback to basic description
    PR_BODY="## Summary

$INTRO

## Changes

$CHANGES_STATS

**Commits:**

$COMMITS

**Files Changed:**

$FILES_SECTION"
fi

# Create or update PR
if [ "$UPDATE_MODE" = true ]; then
    # Update existing PR
    echo "🔄 Update Pull Request"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Get PR number for current branch
    set +e
    PR_NUMBER=$(gh pr view --json number -q .number 2>/dev/null)
    PR_VIEW_EXIT_CODE=$?
    set -e

    if [ $PR_VIEW_EXIT_CODE -ne 0 ] || [ -z "$PR_NUMBER" ]; then
        echo "Error: No pull request found for branch '$CURRENT_BRANCH'"
        echo "Use without --update flag to create a new PR."
        exit 1
    fi

    # Get current PR info
    PR_INFO=$(gh pr view $PR_NUMBER --json title,baseRefName)
    CURRENT_TITLE=$(echo "$PR_INFO" | jq -r '.title')
    CURRENT_BASE=$(echo "$PR_INFO" | jq -r '.baseRefName')

    echo "Found PR #$PR_NUMBER: \"$CURRENT_TITLE\""
    echo "Base branch: $CURRENT_BASE"
    echo ""

    # Confirmation in interactive mode
    if [ "$INTERACTIVE" = true ]; then
        echo "⚠️  This will replace the entire PR description with a freshly generated one."
        read -p "Continue? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Update cancelled."
            exit 0
        fi
        echo ""
    fi

    # Update the PR body
    gh pr edit $PR_NUMBER --body "$PR_BODY"

    echo "✅ Pull request #$PR_NUMBER updated successfully!"
    echo ""
    echo "View at: $(gh pr view $PR_NUMBER --json url -q .url)"
else
    # Create new PR
    echo "Creating pull request..."
    echo "Title: $PR_TITLE"
    echo "Base: $BASE_BRANCH"
    echo "Head: $CURRENT_BRANCH"
    echo ""

    # Use gh pr create with the generated body
    gh pr create \
        --base "$BASE_BRANCH" \
        --head "$CURRENT_BRANCH" \
        --title "$PR_TITLE" \
        --body "$PR_BODY"

    echo ""
    echo "Pull request created successfully!"
fi
