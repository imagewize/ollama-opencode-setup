# Ollama + Open Code Setup

Complete configuration and documentation for running Open Code CLI with local Ollama models.

## Table of Contents

- [Quick Start](#quick-start)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
- [What's Included](#whats-included)
- [⚠️ Important: Tool Usage Discovery](#️-important-tool-usage-discovery)
- [Available Models](#available-models)
- [Common Commands](#common-commands)
  - [Ollama Management](#ollama-management)
  - [Creating Custom Models](#creating-custom-models)
  - [Open Code Usage](#open-code-usage)
- [Performance Tips](#performance-tips)
- [When to Use Local vs Cloud Models](#when-to-use-local-vs-cloud-models)
- [Documentation](#documentation)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)
- [Resources](#resources)
- [Contributing](#contributing)
- [License](#license)

---

## Quick Start

### Prerequisites

1. **Install Ollama**: [ollama.ai](https://ollama.ai)
2. **Install Open Code CLI**: [opencode.ai](https://opencode.ai)

### Setup

1. **Clone this repository:**
   ```bash
   git clone https://github.com/YOUR-USERNAME/ollama-opencode-setup.git ~/code/ollama-opencode-setup
   ```

2. **Start Ollama:**
   ```bash
   ollama serve
   ```

3. **Pull your first model (and build the recommended 16k variant):**
   ```bash
   ollama pull ministral-3:8b   # fast, reliable tool calling

   # Open Code can't set Ollama's num_ctx, so bake a 16k context variant:
   ollama create ministral-3:8b-16k -f modelfiles/ministral-3-8b-16k.Modelfile
   ```

4. **Use the configuration in your project:**
   ```bash
   # Option 1: Symlink into your project
   ln -s ~/code/ollama-opencode-setup/opencode.json ~/code/your-project/opencode.json

   # Option 2: Copy into your project
   cp ~/code/ollama-opencode-setup/opencode.json ~/code/your-project/opencode.json
   ```

5. **Run Open Code:**
   ```bash
   cd ~/code/your-project
   opencode
   ```

## What's Included

- **[opencode.json](opencode.json)** - Open Code configuration for Ollama models
- **[docs/LOCALLLMS.md](docs/LOCALLLMS.md)** - Complete documentation on local LLM setup
- **[docs/AGENTS.md](docs/AGENTS.md)** - Guide to using Open Code CLI agent modes
- **[examples/](examples/)** - Example workflows and prompts
- **[test-opencode.md](test-opencode.md)** - Test suite for validating Open Code CLI setup

## ⚠️ Important: Tool Usage Discovery

**Tool calling requires a model trained for it — and that capability is not tied to size or recency.**

All models in this config have been tested. Results (M1 16GB, 2026-05-31):
- ✅ **Ministral 3 8B** — full tool usage, **fastest tool-caller (~4s warm)**, no think-mode tax — **recommended daily driver**
- ✅ **Qwen3 models** (qwen3:8b-16k, qwen3:8b, qwen3:4b) — full tool usage confirmed, but verbose think mode (~26s)
- ❌ **DeepSeek-Coder-V2-Lite 16B** — Ollama reports `does not support tools`; fits RAM and is fast, but it's a code-completion/FIM model with no tool calling
- ❌ **Qwen3.5 9B / 4B** — outputs bash commands instead of invoking write tool
- ❌ **Phi-4** — Open Code CLI explicitly reports "does not support tools"
- ❌ **Gemma 4 E4B** — attempts tool call but sends malformed/incompatible call format
- ❌ **Mistral Nemo & Granite** — analysis only, cannot create files

Tool-call support is verified with [`scripts/tool-call-test.sh`](scripts/tool-call-test.sh). See [docs/LOCALLLMS.md](docs/LOCALLLMS.md) for full test details.

## Available Models

| Model | Size | Context | Tool Usage | Best For |
|-------|------|---------|------------|----------|
| `ministral-3:8b-16k` ⭐ | 6.0 GB | 16k | ✅ YES | **Recommended for Open Code** — 16k variant (num_ctx baked in) |
| `ministral-3:8b` | 6.0 GB | ~4k default | ✅ YES | Base model — fast tool use (~4s); runs at Ollama's small default context in Open Code |
| `qwen3:8b-16k` | 5.2 GB | 16k | ✅ YES | Multi-file analysis (larger context) |
| `qwen3:8b` | 5.2 GB | 8k | ✅ YES | General file operations (~26s) |
| `qwen3:4b` | 2.5 GB | 8k | ✅ YES | Quick file edits |
| `deepseek-coder-v2:16b` | 8.9 GB | 128k | ❌ NO | No tool support (`does not support tools`) — FIM/completion only |
| `qwen3.5:9b` | 6.6 GB | 32k | ❌ NO | Read-only analysis (too slow, 13+ min) |
| `qwen3.5:4b` | ~2.5 GB | 32k | ❌ NO | Read-only analysis only |
| `phi4:latest` | ~5 GB | 16k | ❌ NO | Read-only analysis only |
| `gemma4:e4b` | ~5.5 GB | 32k | ❌ NO | Read-only analysis only |
| `mistral-nemo:12b-instruct-2407-q4_K_M` | 7.5 GB | 8k | ❌ NO | Code review (read-only) |
| `granite3.1-moe` | 2.0 GB | 8k | ❌ NO | Fast analysis (read-only) |

## Common Commands

### Ollama Management
```bash
# List installed models
ollama list

# Run a model interactively
ollama run qwen3:8b

# Pull a new model
ollama pull mistral-nemo:12b-instruct-2407-q4_K_M

# Remove a model
ollama rm qwen3:4b
```

### Creating Custom Models

Open Code talks to Ollama via the OpenAI-compatible endpoint, which does **not** pass Ollama's `num_ctx`. To get a usable context window, bake it into a custom variant.

**Recommended — from a committed Modelfile (reproducible):**
```bash
ollama create ministral-3:8b-16k -f modelfiles/ministral-3-8b-16k.Modelfile

# Verify the context is baked in
ollama show ministral-3:8b-16k --modelfile | grep num_ctx
# PARAMETER num_ctx 16384
```

The Modelfile is just `FROM ministral-3:8b` + `PARAMETER num_ctx 16384`.

**Alternative — interactive `/save` (used for `qwen3:8b-16k`):**
```bash
# Start interactive session
ollama run qwen3:8b

# Set extended context
>>> /set parameter num_ctx 16384
Set parameter 'num_ctx' to '16384'

# Save as new model
>>> /save qwen3:8b-16k
Created new model 'qwen3:8b-16k'

# Exit
>>> /bye
```

### Open Code Usage

```bash
# Run with default model
opencode run "create a todo.md file"

# Specify model
opencode run "analyze this codebase" --model ollama/qwen3:8b-16k

# Interactive session
opencode
```

## Performance Tips

**Use the right model for the task:**

**File Creation/Modification (use a tool-capable model):**
- **Default / fastest tool use** → `ministral-3:8b-16k` (~4s, no think-mode tax, 16k context for Open Code) ⭐
- **Multi-file changes (larger context)** → `qwen3:8b-16k` (extended context + tool usage)
- **Standard file operations** → `qwen3:8b` (balanced, ~26s)
- **Quick file edits** → `qwen3:4b` (fastest Qwen3 model)

**Code Review/Analysis (read-only — any model works):**
- **Best quality review** → `mistral-nemo:12b-instruct-2407-q4_K_M` (excellent analysis)
- **Fast analysis** → `granite3.1-moe` (quickest)
- **Large context analysis** → `qwen3.5:4b` (32k context, read-only) — avoid `qwen3.5:9b` (too slow)

**Performance expectations (write tool call):**

| Task | ministral-3:8b-16k ⭐ | qwen3:8b | qwen3:8b-16k | Claude Sonnet 4 |
|------|-----------------------|----------|--------------|-----------------|
| Simple file write | **~4s** | 15-30s | 45-90s | 2-5s |
| Multi-file analysis | fast | 40-90s | 90-180s | 10-30s |

**Notes:**
- `ministral-3:8b` is the fastest tool-caller tested — no `<think>` overhead
- Qwen3 models enter verbose "thinking mode" before execution (slower but successful)
- A model must be trained/templated for tools — fitting in RAM is not enough (e.g. DeepSeek-Coder-V2-Lite fits but has no tool calling)

## When to Use Local vs Cloud Models

### Use Local Models (Ollama) When:
- ✅ Working offline
- ✅ Processing sensitive/proprietary code
- ✅ Running batch operations overnight
- ✅ Learning/experimenting without API costs
- ✅ Privacy requirements mandate local processing
- ✅ Code review that doesn't require changes (any model)
- ⚠️ **File operations (use a tool-capable model — Ministral 3 8B or Qwen3)**

### Use Cloud Models (Claude API) When:
- ⏱️ Real-time interactive development
- ⚡ Complex multi-file operations requiring fast iteration
- 🚀 Time-sensitive tasks
- 📚 Working with very large codebases (200k+ context)
- 💰 Speed is more important than cost
- 🎯 Best code quality is critical

## Documentation

### [docs/OPENCODE-COMMANDS.md](docs/OPENCODE-COMMANDS.md)
**Complete Open Code CLI commands reference:**
- All built-in slash commands (15 commands documented)
- Bash command integration (`!command`)
- Agent switching (Tab key for build/plan agents)
- Custom command creation (file-based and config-based)
- Navigation and workflows
- Troubleshooting command issues

### [docs/LOCALLLMS.md](docs/LOCALLLMS.md)
Comprehensive guide to local LLM setup:
- Custom model creation
- Context window comparison (4k vs 8k vs 16k vs 200k)
- Ollama commands reference
- Model selection guidelines
- Troubleshooting guide
- Performance optimization

### [docs/AGENTS.md](docs/AGENTS.md)
Guide to using Open Code CLI agent modes:
- Build and plan agents (Tab key switching)
- Model capabilities for agent workflows
- Agent workflow patterns
- Controlling agent behavior
- Performance benchmarks by model
- Best practices and troubleshooting

### [test-opencode.md](test-opencode.md) & [RECOMMENDATIONS.md](RECOMMENDATIONS.md)
**Critical testing results:**
- ✅ Qwen3 models have full tool usage (file creation works)
- ❌ Mistral Nemo & Granite lack tool usage (analysis only)
- Model-by-model test results and recommendations

## Examples

Check the [examples/](examples/) directory for:
- Code review workflows
- Refactoring prompts
- Multi-file analysis examples
- Batch processing scripts

## Troubleshooting

### Ollama Not Running
```bash
# Check if Ollama is running
curl http://localhost:11434/v1/models

# Start Ollama
ollama serve
```

### Model Not Found
```bash
# Verify model exists
ollama list

# Pull model if missing
ollama pull qwen3:8b
```

### Slow Performance
- Use smaller models for simple tasks (`qwen3:4b`)
- Use standard context when extended context isn't needed (`qwen3:8b` instead of `qwen3:8b-16k`)
- Consider cloud models for time-sensitive work

See [docs/LOCALLLMS.md#troubleshooting](docs/LOCALLLMS.md#troubleshooting) and [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for more details.

## Resources

- [Ollama Documentation](https://github.com/ollama/ollama)
- [Open Code Documentation](https://opencode.ai/docs)
- [Qwen3 Model Card](https://huggingface.co/Qwen/Qwen3-8B)
- [Mistral Nemo Documentation](https://mistral.ai/news/mistral-nemo/)

## Contributing

Contributions welcome! Please feel free to submit issues or pull requests with:
- New model configurations
- Performance optimizations
- Example workflows
- Documentation improvements

## License

MIT
