# Local LLMs Configuration

This document describes the local LLM setup for use with Open Code and other AI development tools.

## Table of Contents

- [Open Code Configuration](#open-code-configuration)
  - [Current Configuration](#current-configuration)
  - [Available Models](#available-models)
- [Custom Model Creation](#custom-model-creation)
  - [Creating Qwen3 8B with Extended Context (16k)](#creating-qwen3-8b-with-extended-context-16k)
  - [Benefits of Extended Context](#benefits-of-extended-context)
  - [Context Window Reality Check](#context-window-reality-check)
- [Ollama Commands Reference](#ollama-commands-reference)
  - [List Models](#list-models)
  - [Run Model](#run-model)
  - [Pull New Model](#pull-new-model)
  - [Remove Model](#remove-model)
  - [Interactive Commands](#interactive-commands-within-ollama-run)
- [Model Selection Guidelines](#model-selection-guidelines)
- [Updating Configuration](#updating-configuration)
- [Troubleshooting](#troubleshooting)
  - [Ollama Not Running](#ollama-not-running)
  - [Model Not Found](#model-not-found)
  - [Out of Memory](#out-of-memory)
  - [Slow Performance with Local Models](#slow-performance-with-local-models)
  - [Open Code CLI "Cannot Read Binary File" Error](#open-code-cli-cannot-read-binary-file-error)
  - [Open Code CLI `/init` Mode Issues](#open-code-cli-init-mode-issues)
- [Resources](#resources)

## Open Code Configuration

Open Code is configured via [`opencode.json`](../opencode.json) in the repository root. This file defines available LLM providers and models.

### Current Configuration

**Provider**: Ollama (local)
- **Base URL**: `http://localhost:11434/v1`
- **NPM Package**: `@ai-sdk/openai-compatible`

### Available Models

| Model | Size | Description |
|-------|------|-------------|
| `qwen3:8b-16k` | 5.2 GB | Qwen3 8B with extended 16k context window (custom) |
| `mistral-nemo:12b-instruct-2407-q4_K_M` | 7.5 GB | Mistral Nemo 12B Instruct (quantized) |
| `qwen3:8b` | 5.2 GB | Qwen3 8B standard model |
| `granite3.1-moe:latest` | 2.0 GB | Granite 3.1 Mixture of Experts |
| `qwen3:4b` | 2.5 GB | Qwen3 4B compact model |

## Custom Model Creation

### Creating Qwen3 8B with Extended Context (16k)

The `qwen3:8b-16k` model is a custom variant created from the base `qwen3:8b` model with an extended context window.

**Process**:

```bash
# Start interactive session with base model
ollama run qwen3:8b

# Set extended context parameter (default is typically 8192)
>>> /set parameter num_ctx 16384
Set parameter 'num_ctx' to '16384'

# Save as new model variant
>>> /save qwen3:8b-16k
Created new model 'qwen3:8b-16k'

# Exit session
>>> /bye
```

**Verification**:

```bash
ollama list
# Output:
# NAME                                     ID              SIZE      MODIFIED
# qwen3:8b-16k                             7ef4ca800d20    5.2 GB    9 seconds ago
# mistral-nemo:12b-instruct-2407-q4_K_M    daf673741712    7.5 GB    14 hours ago
# qwen3:8b                                 500a1f067a9f    5.2 GB    18 hours ago
# granite3.1-moe:latest                    b43d80d7fca7    2.0 GB    20 hours ago
# qwen3:4b                                 e55aed6fe643    2.5 GB    2 months ago
```

### Benefits of Extended Context

- **16k tokens** vs standard 8k allows for larger code files and more context
- Useful for analyzing entire application architectures
- Better for reviewing multiple related files in a single prompt
- No increase in model size (same 5.2 GB as base model)

### Context Window Reality Check

Understanding what different context windows can actually hold:

| Context Window | Approximate Words | Approximate Code | Typical Use Cases |
|----------------|-------------------|------------------|-------------------|
| **4k tokens** | ~3,000 words | 1 medium file | Single component analysis, quick edits |
| **8k tokens** | ~6,000 words | 1-2 medium files | Standard file operations, code reviews |
| **16k tokens** | ~12,000 words | 3-5 medium files | Multi-file analysis, related components |
| **32k tokens** | ~24,000 words | 6-10 medium files | Feature analysis across files |
| **200k tokens** | ~150,000 words | Small-medium codebase | Whole codebase analysis, architecture review |

**Important notes:**
- **Tokens ≠ Words**: 1 token ≈ 0.75 words in English (varies by language and content type)
- **Code uses more tokens**: Technical terms, symbols, and formatting consume more tokens than natural language
- **"Medium file"**: ~500-1000 lines of code (~20-40 KB)
- **Context includes prompts**: System prompts, tool descriptions, and conversation history all consume tokens

**Examples with this codebase:**

```bash
# 8k context (qwen3:8b)
# Can analyze:
- Single theme file (e.g., resources/js/app.js)
- One block component
- README.md + quick overview

# 16k context (qwen3:8b-16k)
# Can analyze:
- Multiple related blocks (e.g., all files in resources/js/blocks/hero/)
- Theme configuration files (tailwind.config.js + theme.json + vite.config.js)
- Related components (index.php + style.css + script.js)

# 200k context (Claude Sonnet 4)
# Can analyze:
- Entire Nynaeve theme structure
- All blocks + configuration + documentation
- Cross-theme patterns (Nynaeve + Moiraine)
- Full project architecture (Trellis + Bedrock + themes)
```

**Practical tip**: If your prompt or file content gets cut off, your context window is too small for the task.

## Ollama Commands Reference

### List Models
```bash
ollama list
```

### Run Model
```bash
ollama run <model-name>
```

### Pull New Model
```bash
ollama pull <model-name>
```

### Remove Model
```bash
ollama rm <model-name>
```

### Interactive Commands (within `ollama run`)
- `/set parameter <name> <value>` - Modify model parameters
- `/save <new-model-name>` - Save current configuration as new model
- `/show` - Display model information
- `/bye` - Exit interactive session

## Model Selection Guidelines

**For Code Generation**:
- **Mistral Nemo 12B**: Best overall code quality, instruction following
- **Qwen3 8B**: Fast, good balance of quality and speed

**For Quick Tasks**:
- **Qwen3 4B**: Fastest responses, good for simple tasks
- **Granite 3.1 MoE**: Efficient for varied tasks

**For Large Context**:
- **Qwen3 8B-16k**: When analyzing multiple files or large codebases

## Updating Configuration

When adding or removing Ollama models, update [`opencode.json`](../opencode.json):

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (local)",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "model-name": {
          "name": "Display Name"
        }
      }
    }
  }
}
```

## Troubleshooting

### Ollama Not Running
```bash
# Check if Ollama is running
curl http://localhost:11434/v1/models

# Start Ollama (macOS)
ollama serve
```

### Model Not Found
```bash
# Verify model exists
ollama list

# Pull model if missing
ollama pull <model-name>
```

### Out of Memory
- Use smaller models (Qwen3 4B, Granite 3.1 MoE)
- Close other applications
- Reduce context window with `/set parameter num_ctx <value>`

### Slow Performance with Local Models

**Problem**: Open Code CLI runs very slowly with Ollama models, even for simple tasks.

**Symptoms:**
- Simple file creation takes 10-30 seconds
- Significant delay before seeing any output
- Model generates verbose thinking output before action
- Overall slower than Claude Code with cloud models

**Causes:**

1. **Local model inference speed**
   - CPU/GPU limitations on local machine
   - Model size vs. available VRAM
   - Quantization level (Q4_K_M is faster than higher precision)

2. **Extended context overhead**
   - 16k context models (like qwen3:8b-16k) use more memory
   - KV cache: 2.2 GiB (16k) vs 576 MiB (8k)
   - Slower token generation with larger context

3. **Open Code CLI overhead**
   - Multiple tool calls for simple operations
   - Verbose system prompts
   - Thinking mode adds extra tokens to generate

**Performance comparison (simple file write task):**

| Model | Context | Time | Notes |
|-------|---------|------|-------|
| qwen3:8b-16k | 16k | 10-30s | Extended context, slower |
| qwen3:8b | 8k | 8-20s | Standard context |
| qwen3:4b | 8k | 5-15s | Smaller, faster |
| granite3.1-moe | 8k | 6-18s | Efficient MoE architecture |
| Claude Sonnet 4 (cloud) | 200k | 2-5s | API-based, much faster |

**Solutions:**

1. **Use smaller models for simple tasks:**
   ```bash
   # For quick file operations
   opencode run "create file" --model ollama/qwen3:4b

   # For analyzing large files or multiple related files
   opencode run "analyze components in resources/js/blocks/" --model ollama/qwen3:8b-16k
   ```

2. **Use standard context when extended context isn't needed:**
   ```bash
   # 8k context is sufficient for most single-file operations
   opencode run "update file" --model ollama/qwen3:8b
   ```

3. **Use cloud models for whole-codebase analysis:**
   ```bash
   # Claude Sonnet 4 has 200k context - much better for codebase-wide tasks
   # Use Claude Code for tasks like:
   # - "Analyze the entire authentication flow"
   # - "Review all API endpoints"
   # - "Find all instances of X pattern across the codebase"
   ```

4. **Use Claude Code for interactive development:**
   - Claude Code with API access is significantly faster
   - Better for real-time coding assistance
   - Open Code CLI with local models is better for:
     - Offline work
     - Privacy-sensitive codebases
     - Batch operations where speed is less critical

5. **Optimize Ollama settings:**
   ```bash
   # Reduce batch size for faster first token
   # In Modelfile:
   PARAMETER num_batch 256  # Default is 512

   # Adjust context window
   PARAMETER num_ctx 4096   # Smaller context = faster
   ```

6. **Hardware considerations:**
   - Use GPU if available (Metal on macOS, CUDA on Linux/Windows)
   - Close memory-intensive applications
   - Monitor `ollama serve` logs for performance bottlenecks

**When to use local vs. cloud models:**

**Use local models (Ollama) when:**
- Working offline
- Processing sensitive/proprietary code
- Running batch operations overnight
- Learning/experimenting without API costs
- Privacy requirements mandate local processing

**Use cloud models (Claude API) when:**
- Real-time interactive development
- Complex multi-file operations requiring fast iteration
- Time-sensitive tasks
- Working with very large codebases (200k+ context)
- Speed is more important than cost

**Note**: Local model performance will improve with better hardware (more VRAM, faster GPU/CPU) and future Ollama optimizations.

### Open Code CLI "Cannot Read Binary File" Error

**Problem**: When running Open Code CLI's `/init` command, you may encounter an error like:
```
Cannot read binary file: /Users/jasperfrumau/code/imagewize.com/AGENTS.md
```

**Cause**: This occurs when documentation files (like `AGENTS.md`) contain Unicode box-drawing characters used for tree structure visualization. These characters (like `├`, `│`, `└`) are multi-byte UTF-8 sequences that some tools misinterpret as binary data.

**Verification**: Check if your file is detected as binary:
```bash
file AGENTS.md
# Bad: "AGENTS.md: data" (binary)
# Good: "AGENTS.md: ASCII text" or "AGENTS.md: UTF-8 Unicode text"
```

**Solution 1: Remove all non-printable characters** (Quick fix):
```bash
# Strip all non-ASCII printable characters
LC_ALL=C tr -cd '\11\12\15\40-\176' < AGENTS.md > AGENTS_clean.md
mv AGENTS_clean.md AGENTS.md

# Verify it's now recognized as text
file AGENTS.md
# Should show: "AGENTS.md: ASCII text"
```

**Solution 2: Manual replacement** - Replace Unicode tree characters with ASCII:

Instead of:
```
├── site/
│   ├── web/
│   │   └── app/
```

Use standard text formatting:
```
- site/
  - web/
    - app/
```

Or use spaces for indentation:
```
imagewize.com/
  site/          # Main site
  demo/          # Demo site
  trellis/       # Server provisioning
```

**Why this happens:**
- Some text editors (like `tree` command output) use Unicode box-drawing characters (U+2500 to U+257F range)
- These are valid UTF-8 but contain byte values outside the ASCII range
- The `file` command and similar tools may classify files with these characters as "data" (binary)
- Open Code CLI refuses to read files detected as binary for safety reasons

**Prevention:**
- Don't copy/paste output from `tree` command into documentation
- Use ASCII-only characters (`-`, `*`, spaces) for structure diagrams
- Verify files with `file` command before committing

**Note**: The `AGENTS.md` file in this repository has been cleaned of all non-printable characters.

### Open Code CLI `/init` Mode Issues

**Problem 1: Agent starts in "thinking mode" instead of "build mode"**

When running `/init`, the agent may start in thinking/planning mode even though the default Open Code mode should be "build". This causes the agent to spend excessive time planning instead of taking action.

**Symptoms:**
- Agent displays `<think>` tags and lengthy analysis
- Takes 2-3 minutes just to analyze the codebase before acting
- Generates verbose planning output before executing tasks

**Cause**: The `/init` command may trigger plan agent behavior, or the agent interprets the initialization request as a planning task.

**Solutions:**

1. **Skip `/init` entirely** - If you have an existing `AGENTS.md` file:
   ```bash
   # Just start Open Code CLI without /init
   # It will automatically read AGENTS.md if present
   ```

2. **Switch to build agent** - After `/init` completes, press Tab to ensure build agent is active:
   ```bash
   # Press Tab key to switch between plan and build agents
   # Build agent is default for file creation tasks
   ```

3. **Create `AGENTS.md` manually** - Instead of using `/init`, create or update `AGENTS.md` yourself:
   - Copy relevant sections from `CLAUDE.md`
   - Add Open Code-specific configuration
   - Format for AI agent consumption (no Unicode characters)

**Problem 1a: Qwen3 models enter verbose thinking mode**

Qwen3 models display `<think>` tags and spend time analyzing before taking action. This is model behavior, not an Open Code CLI issue.

**Example:**
```bash
opencode run "generate a todo.md file with the contents 'hello world, from qwen3' in it" --model ollama/qwen3:8b-16k
# Output shows:
# <think>
# Okay, the user wants me to generate a todo.md file...
# [lengthy analysis]
# </think>
```

**Understanding:**
- This is inherent to Qwen3 model behavior with extended context
- Build mode is already the **default** in Open Code CLI
- There is **no** `/no_think` flag in Open Code CLI (only `/thinking` toggle which enables MORE thinking)
- Task executes correctly but with verbose output (10-30 seconds for simple operations)

**Best Approach:**
Accept the thinking mode as part of using Qwen3 models:
- Tasks complete successfully despite verbosity
- The thinking provides insight into model reasoning
- Consider it "free documentation" of the decision-making process
- Privacy benefits of local models outweigh the verbosity

**Alternative:** Use models with less thinking:
- Mistral Nemo 12B: Minimal thinking but **cannot create files** (analysis only)
- Granite 3.1 MoE: Fast but **cannot create files** (analysis only)
- Qwen3:8b or Qwen3:4b: May have less thinking (needs testing, should support file creation)

**Problem 2: "You must read the file before overwriting it" error**

**Error message:**
```
Edit AGENTS.md [replaceAll=true]
You must read the file /Users/jasperfrumau/code/imagewize.com/AGENTS.md
before overwriting it. Use the Read tool first
```

**Cause**: Open Code CLI's safety mechanism requires the agent to read a file before overwriting it, but the `/init` workflow may attempt to write without reading first.

**Solutions:**

1. **Manually edit AGENTS.md** - Use a text editor to make changes instead of `/init`

2. **Use incremental updates** - Instead of full replacement:
   ```bash
   # In Open Code CLI, request specific sections to be added
   "Add a section about X to AGENTS.md"
   ```

3. **Pre-existing AGENTS.md** - If `AGENTS.md` exists and is working, don't run `/init` again:
   - The file is already configured for Open Code
   - Modifications can be made with targeted edit requests
   - Running `/init` again may cause conflicts

**Best Practice:**

For repositories with existing `AGENTS.md` files:
- **DO**: Use the existing file, make targeted updates as needed
- **DO**: Reference `CLAUDE.md` for comprehensive documentation
- **DON'T**: Run `/init` repeatedly
- **DON'T**: Attempt full file replacements unless necessary

**Note**: This repository already has a properly configured `AGENTS.md` file that works with Open Code CLI. The `/init` command is not needed for normal use.

## Resources

- [Ollama Documentation](https://github.com/ollama/ollama)
- [Open Code Documentation](https://opencode.ai/docs)
- [Qwen3 Model Card](https://huggingface.co/Qwen/Qwen3-8B)
- [Mistral Nemo Documentation](https://mistral.ai/news/mistral-nemo/)
