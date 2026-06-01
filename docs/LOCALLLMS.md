# Local LLMs Configuration

This document describes the local LLM setup for use with Open Code and other AI development tools.

## Table of Contents

- [Open Code Configuration](#open-code-configuration)
  - [Current Configuration](#current-configuration)
  - [Available Models](#available-models)
- [Custom Model Creation](#custom-model-creation)
  - [Creating Qwen3 8B with Extended Context (16k)](#creating-qwen3-8b-with-extended-context-16k)
  - [Creating Ministral 3 8B with Extended Context (16k)](#creating-ministral-3-8b-with-extended-context-16k)
  - [Benefits of Extended Context](#benefits-of-extended-context)
  - [Context Window Reality Check](#context-window-reality-check)
- [Setting Context with Open Code (why we bake num_ctx)](#setting-context-with-open-code-why-we-bake-num_ctx)
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

**Tool usage** = can create/modify files in Open Code CLI. Read-only models can analyze code but cannot write files.

| Model | Size | Context | Tool Usage | Description |
|-------|------|---------|------------|-------------|
| `ministral-3:8b-32k` | 11 GB | 32k | Yes | **Recommended for Open Code** — custom 32k variant, 100% GPU on M1 16GB (tested 2026-06-01) |
| `ministral-3:8b-16k` | 6.5 GB | 16k | Yes | Memory-constrained fallback — 100% GPU, smaller footprint |
| `ministral-3:8b` | 6.0 GB | Ollama default (~4k) | Yes | Base model — fast, reliable tool calls, no think-mode tax (~4s warm); runs at Ollama's small default context in Open Code, so prefer the 32k variant |
| `qwen3:8b-16k` | 5.2 GB | 16k | Yes | Qwen3 8B with extended context (custom variant) — works but verbose think mode (~26s) |
| `qwen3:8b` | 5.2 GB | 8k | Yes | Qwen3 8B standard model — ~26s for a write tool call (think-mode overhead) |
| `qwen3:4b` | 2.5 GB | 8k | Yes | Qwen3 4B compact model |
| `deepseek-coder-v2:16b` | 8.9 GB | 128k | No | Not recommended — Ollama reports `does not support tools`; code-completion/FIM model, no tool calling (tested 2026-05-31) |
| `qwen3.5:9b` | 6.6 GB | 32k | No | Not recommended — no tool use, too slow on M1 16GB (13+ min for analysis, tested 2026-05-31) |
| `gemma4:e4b` | ~5.5 GB | 32k | No | Not recommended — attempts tool call but sends malformed call; file not created (tested 2026-05-31) |
| `phi4:latest` | ~5 GB | 16k | No | Not recommended — Open Code CLI explicitly reports "does not support tools" (tested 2026-05-31) |
| `qwen3.5:4b` | ~2.5 GB | 32k | No | Not recommended — no tool use, outputs bash instead of using write tool (tested 2026-05-31) |
| `mistral-nemo:12b-instruct-2407-q4_K_M` | 7.5 GB | 8k | No | Read-only analysis only |
| `granite3.1-moe:latest` | 2.0 GB | 8k | No | Read-only analysis only |

**Testing method:** Tool-call support is verified with [`scripts/tool-call-test.sh`](../scripts/tool-call-test.sh), which sends a `write`-tool request to Ollama's OpenAI-compatible endpoint (the same API Open Code uses) and checks for a valid `tool_calls` response.

```bash
# Pull and test the recommended model
ollama pull ministral-3:8b
./scripts/tool-call-test.sh ministral-3:8b 16384
```

## Custom Model Creation

### Creating Qwen3 8B with Extended Context (16k)

The `qwen3:8b-16k` model is a custom variant created from the base `qwen3:8b` model with `num_ctx` baked in. This repo ships a Modelfile for reproducible builds:

```bash
# From the repo root
ollama create qwen3:8b-16k -f modelfiles/qwen3-8b-16k.Modelfile

# Verify
ollama show qwen3:8b-16k --modelfile | grep num_ctx
# PARAMETER num_ctx 16384
```

**Verification**:

```bash
ollama list
# Output:
# NAME                                     ID              SIZE      MODIFIED
# qwen3:8b-16k                             7ef4ca800d20    5.2 GB    9 seconds ago
# qwen3:8b                                 500a1f067a9f    5.2 GB    18 hours ago
# qwen3:4b                                 e55aed6fe643    2.5 GB    2 months ago
```

### Creating Ministral 3 8B with Extended Context (32k) — Recommended

`ministral-3:8b-32k` is the recommended Open Code variant — tested 2026-06-01 on M1 16GB: **100% GPU, 11 GB footprint**. Ollama docs recommend at least 32k context for agentic tools; 64k was tested but causes 27% CPU spillover on M1 16GB.

```bash
# From the repo root
ollama create ministral-3:8b-32k -f modelfiles/ministral-3-8b-32k.Modelfile

# Verify
ollama show ministral-3:8b-32k --modelfile | grep num_ctx
# PARAMETER num_ctx 32768
```

### Creating Ministral 3 8B with Extended Context (16k) — Fallback

`ministral-3:8b-16k` is the memory-constrained fallback — 100% GPU at ~6.5 GB. Use this if 32k causes issues on your machine.

```bash
ollama create ministral-3:8b-16k -f modelfiles/ministral-3-8b-16k.Modelfile
```

The base model natively supports up to 256k context. 32k is the recommended sweet spot on M1 16GB; 64k saturates all 16 GB and spills to CPU.

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

## Setting Context with Open Code (why we bake num_ctx)

Open Code connects to Ollama through its **OpenAI-compatible endpoint** (`/v1/chat/completions`, via `@ai-sdk/openai-compatible`). That endpoint **ignores `num_ctx`** — only Ollama's native `/api/*` endpoint reads it. As a result:

- **There is no `opencode.json` field that sets the context window.** Putting `num_ctx` in provider/model `options` does nothing, because it never reaches a code path Ollama honors.
- Without intervention, every model runs at Ollama's small default (~4k on most M-series laptops) inside Open Code — too small for agentic tool loops (the system prompt + tool definitions alone eat much of it).

Per-request control is an open feature request upstream ([opencode#3250](https://github.com/anomalyco/opencode/issues/3250), `help-wanted`), not yet available.

### Your options

| Method | Scope | Notes |
|--------|-------|-------|
| **Modelfile `num_ctx`** (this repo's approach) | Per-model | Self-contained, version-controlled, survives restarts. Lets each model carry its own ideal context. |
| **`OLLAMA_CONTEXT_LENGTH` env var** | Global (all models) | Set once on the server; no variants to maintain. But forces one size on *every* model (RAM cost on 16GB), and a model's own baked `num_ctx` can override it. |
| Per-request via `opencode.json` | — | Not supported (the `/v1` limitation above). |

**Global env-var alternative:**
```bash
# macOS Ollama.app — set, then restart Ollama:
launchctl setenv OLLAMA_CONTEXT_LENGTH 16384

# or when running serve manually:
OLLAMA_CONTEXT_LENGTH=16384 ollama serve
```

### Why this repo bakes it per-model

We run several models with different ideal contexts (Ministral, Qwen3 variants) on a 16GB machine. A single global env var would force one context on all of them — e.g. loading `qwen3:4b` at 16k for no reason, wasting RAM. Per-model Modelfiles (`ministral-3:8b-16k`, `qwen3:8b-16k`) keep each model's context appropriate and reproducible. Use the global env var instead only if you settle on one model at one context and would rather not maintain variants.

> Documented precedence is *API param > env var > Modelfile > built-in default*, but in practice a baked `num_ctx` reliably pins that specific model — which is the behavior we want.

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

On a MacBook M1 with 16GB RAM, ~11-12GB is available for model weights. The sweet spot is 7-9B models at Q4 quantization.

**For Coding and File Operations (tool use required):**
- **Ministral 3 8B** (recommended): Confirmed tool usage, fastest tool-calling model tested (~4s warm), no think-mode overhead, newer than the Qwen3 family
- **Qwen3 8B-16k**: Confirmed tool usage, custom 16k context variant — best for larger-context jobs, but verbose think mode (~26s)
- **Qwen3 8B**: Confirmed tool usage, solid general-purpose model (~26s, think-mode overhead)
- **Qwen3 4B**: Confirmed tool usage, fastest of the Qwen options for quick edits

**Confirmed NO tool use (avoid for file operations):**
- **DeepSeek-Coder-V2-Lite 16B**: Ollama rejects tool requests with `does not support tools` — it's a code-completion/FIM model, not an agentic tool-caller (tested 2026-05-31)
- **Qwen3.5 9B / 4B**: 32k context — output bash instead of using the write tool; 9B also too slow on M1 16GB (13+ min)
- **Mistral Nemo 12B**: Excellent analysis quality, cannot create/modify files
- **Granite 3.1 MoE**: Fast analysis, cannot create/modify files

**Performance benchmarks (M1 16GB, scripted `write` tool call via `scripts/tool-call-test.sh`):**

| Model | Context | Tool call | Time (warm) | Notes |
|-------|---------|-----------|-------------|-------|
| ministral-3:8b | 16k | ✅ Yes | ~4s | Fastest tool-caller; recommended |
| qwen3:8b | 16k | ✅ Yes | ~26s | Works, slowed by think mode |
| deepseek-coder-v2:16b | 16k | ❌ No | — | Ollama: `does not support tools` |
| Claude Sonnet 4 (cloud) | 200k | ✅ Yes | 2-5s | Much faster |

**Avoid models above 12B** — they will struggle to load or cause heavy swap on 16GB RAM. Note that even when a large model *fits*, it may still lack tool calling (e.g. DeepSeek-Coder-V2-Lite) — size is not the same as agentic capability.

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
| ministral-3:8b | 4k | 4-8s | Fastest, no think-mode overhead |
| ministral-3:8b-16k | 16k | 4-10s | Fastest with extended context |
| qwen3:4b | 8k | 5-15s | Smaller, faster |
| qwen3:8b | 8k | 8-20s | Standard context |
| qwen3:8b-16k | 16k | 10-30s | Extended context, slower |
| Claude Sonnet 4 (cloud) | 200k | 2-5s | API-based, much faster |

**Solutions:**

1. **Use faster models for simple tasks:**
   - Switch models in the Open Code TUI (`/models` command)
   - `ministral-3:8b` — fastest tool-calling model, no think-mode overhead (~4s warm)
   - `qwen3:4b` — compact and quick for single-file edits

2. **Use standard context when extended context isn't needed:**
   - `ministral-3:8b` or `qwen3:8b` for most single-file operations
   - Reserve 16k variants for tasks spanning multiple files

3. **Use cloud models for whole-codebase analysis:**
   - Claude Sonnet 4 has 200k context — much better for codebase-wide tasks
   - Use Claude Code for: "Analyze the entire authentication flow", "Review all API endpoints", "Find all instances of X pattern"

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

**Alternative:** Use `ministral-3:8b` or `ministral-3:8b-16k` — confirmed tool use with no think-mode overhead at all (~4s warm). This is the recommended solution. Mistral Nemo and Granite have no think-mode but also cannot create files (analysis only).

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
