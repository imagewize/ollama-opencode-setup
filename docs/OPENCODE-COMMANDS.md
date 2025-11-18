# Open Code CLI Commands Reference

Complete guide to all commands, navigation, and features available in Open Code CLI.

## Built-in TUI Slash Commands

All commands use `/` as the prefix and have corresponding keybinds using `ctrl+x` as the leader key.

| Command | Aliases | Description | Keybind |
|---------|---------|-------------|---------|
| `/compact` | `/summarize` | Compact the current session | ctrl+x c |
| `/details` | — | Toggle tool execution details | ctrl+x d |
| `/editor` | — | Open external editor for composing messages | ctrl+x e |
| `/exit` | `/quit`, `/q` | Exit OpenCode | ctrl+x q |
| `/export` | — | Export current conversation to Markdown | ctrl+x x |
| `/help` | — | Show the help dialog | ctrl+x h |
| `/init` | — | Create or update `AGENTS.md` file | ctrl+x i |
| `/models` | — | List available models | ctrl+x m |
| `/new` | `/clear` | Start a new session | ctrl+x n |
| `/redo` | — | Redo a previously undone message | ctrl+x r |
| `/sessions` | `/resume`, `/continue` | List and switch between sessions | ctrl+x l |
| `/share` | — | Share current session | ctrl+x s |
| `/themes` | — | List available themes | ctrl+x t |
| `/undo` | — | Undo last message in the conversation | ctrl+x u |
| `/unshare` | — | Unshare current session | — |

### ❌ Commands That DO NOT Exist

The following commands are **not** available in Open Code CLI:
- `/mode` - Does not exist (use Tab key instead)
- `/no_think` - Does not exist (thinking mode is model behavior)
- `/thinking` - Does not exist
- `/rename` - Does not exist
- `/copy` - Does not exist
- `/timeline` - Does not exist

## Bash Commands

Start a message with `!` to run a shell command directly:

```bash
opencode
> !ls -la
```

**How it works:**
- The output of the command is added to the conversation as a tool result
- The model can then analyze or use the output
- Useful for dynamic data gathering during conversations

**Examples:**

```bash
# Get current git status
> !git status

# Analyze test results
> !npm test
> Based on the test output above, fix the failing tests

# Review recent changes
> !git diff HEAD~1
> Review these changes for security issues

# Check system info
> !df -h
> Analyze disk usage and suggest cleanup strategies
```

**Use cases:**
- Getting real-time system information
- Running tests and analyzing output
- Checking git status/diffs
- Gathering metrics or logs
- Any command output you want the model to analyze

## Navigation

### Agent Switching

Press **Tab** to switch between two agents:

1. **Build Agent (Default)** - Optimized for code generation, file creation, and modifications
2. **Plan Agent** - Optimized for analysis, planning, and understanding

**Example:**
```bash
opencode
# Build agent is active by default
> Create a new Express.js server

# Press Tab to switch to plan agent
> Analyze the codebase architecture

# Press Tab again to switch back to build agent
> Implement the suggested improvements
```

## Custom Slash Commands

You can create custom commands to streamline your workflow.

### File-Based Commands

Create markdown files in one of these directories:
- **Global:** `~/.config/opencode/command/`
- **Project-specific:** `.opencode/command/`

The filename becomes the command name. For example, `test.md` becomes `/test`.

**Example: `.opencode/command/test.md`**
```markdown
Run all unit tests in the project and report any failures.
```

**Usage:**
```bash
opencode
> /test
```

### Config-Based Commands

Define commands in `opencode.jsonc`:

```jsonc
{
  "command": {
    "review": {
      "template": "Review the code at @$1 for security vulnerabilities and best practices",
      "description": "Security code review",
      "agent": "plan",
      "model": "ollama/mistral-nemo:12b-instruct-2407-q4_K_M"
    }
  }
}
```

### Advanced Command Features

#### Arguments

- **`$ARGUMENTS`** - All arguments as a single string
- **`$1`, `$2`, `$3`** - Individual positional arguments

**Example:**
```markdown
Refactor the function at line $1 in file $2 to use $3 pattern.
```

**Usage:**
```bash
> /refactor 42 src/utils.py dependency-injection
```

#### Shell Integration

Use `` !`command` `` syntax to inject bash output directly into prompts:

**Example command file:**
```markdown
Review the files that changed in the last commit:

!`git diff --name-only HEAD~1`
```

#### File References

Include file content via `@filename` notation:

**Example:**
```markdown
Analyze the API design in @src/api/routes.ts and suggest improvements.
```

## Command-Line Arguments

When launching Open Code CLI:

```bash
# Use specific model
opencode --model ollama/qwen3:8b-16k

# Run single prompt
opencode run "Create a hello.py file"

# Use specific model with run
opencode run "Create todo.md with 3 tasks" --model ollama/qwen3:8b-16k

# Batch mode (if supported)
opencode --batch tasks.txt
```

## Agent Configuration

### Build Agent (Default)

**Characteristics:**
- Action-oriented
- Minimal analysis before execution
- File creation and modification
- Code generation

**Best for:**
- Creating new files
- Modifying existing code
- Generating boilerplate
- Rapid prototyping

**Models that work:**
- ✅ qwen3:8b-16k (tool usage support)
- ✅ qwen3:8b (likely has tool usage, needs testing)
- ✅ qwen3:4b (likely has tool usage, needs testing)
- ❌ mistral-nemo:12b-instruct-2407-q4_K_M (analysis only, no file creation)
- ❌ granite3.1-moe (analysis only, no file creation)

### Plan Agent

**Characteristics:**
- Analysis-oriented
- Detailed planning
- Code review and understanding
- Architectural decisions

**Best for:**
- Understanding codebases
- Planning refactors
- Code review
- Architectural analysis
- Multi-step planning

**Models that work:**
- All models work for analysis (no file creation needed)
- mistral-nemo:12b-instruct-2407-q4_K_M recommended for best analysis quality

## Common Workflows

### 1. Create Files (Build Agent)

```bash
opencode --model ollama/qwen3:8b-16k
# Build agent is default
> Create a Python FastAPI server with authentication
```

### 2. Analyze Then Build (Agent Switching)

```bash
opencode --model ollama/qwen3:8b-16k
# Press Tab to switch to plan agent
> Analyze the current authentication system and suggest improvements

# Review the plan

# Press Tab to switch back to build agent
> Implement the suggested JWT-based authentication
```

### 3. Code Review Only (Plan Agent)

```bash
opencode --model ollama/mistral-nemo:12b-instruct-2407-q4_K_M
# Press Tab to switch to plan agent
> Review src/auth/ for security vulnerabilities
```

### 4. Session Management

```bash
# Start a new session
> /new

# List and resume previous sessions
> /sessions

# Export current session
> /export

# Share session (if configured)
> /share
```

### 5. Undo/Redo Actions

```bash
# Undo last message
> /undo

# Redo previously undone message
> /redo
```

## Tips and Best Practices

### 1. Use the Right Agent

- **Building/Creating** → Build agent (default)
- **Planning/Analyzing** → Plan agent (press Tab)

### 2. Use the Right Model

- **File creation/modification** → qwen3:8b-16k (only Qwen3 models have tool usage)
- **Code review/analysis** → mistral-nemo:12b-instruct-2407-q4_K_M (best quality, but read-only)
- **Fast analysis** → granite3.1-moe (efficient, but read-only)

### 3. Manage Sessions

- Use `/sessions` to resume previous work
- Use `/export` to save important conversations
- Use `/new` to start fresh without losing current session

### 4. Leverage Custom Commands

Create project-specific commands for repetitive tasks:
- `/test` - Run test suite
- `/lint` - Check code quality
- `/deploy` - Deployment checks
- `/review` - Security review

### 5. Accept Think Mode

- Qwen3 models enter verbose "thinking mode"
- This is **model behavior**, not a CLI issue
- Build agent is already the default
- Tasks complete successfully despite verbosity
- Consider it "free documentation" of reasoning

## Troubleshooting

### Command Not Found

**Issue:** `/mode`, `/no_think`, or other command doesn't work

**Solution:** These commands don't exist. Use:
- Tab key for agent switching (not `/mode`)
- Accept think mode behavior (no `/no_think` flag)

### Model Can't Create Files

**Issue:** Mistral Nemo or Granite models don't create files

**Solution:** Only Qwen3 models have tool usage (file creation). Use:
- qwen3:8b-16k for file operations
- Mistral/Granite for analysis only

### Slow Performance

**Issue:** Tasks take 30-90 seconds

**Solution:** This is normal for local models:
- Use smaller models (qwen3:4b) for simple tasks
- Accept slower speed as trade-off for privacy
- Use cloud models (Claude API) for time-critical work

## Resources

- [Open Code CLI TUI Documentation](https://opencode.ai/docs/tui/)
- [Open Code CLI Commands Documentation](https://opencode.ai/docs/commands/)
- [Ollama Documentation](https://github.com/ollama/ollama)
- [This Repository's Setup Guide](../README.md)
