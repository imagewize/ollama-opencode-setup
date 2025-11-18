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

3. **Pull your first model:**
   ```bash
   ollama pull qwen3:8b
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

**Only Qwen3 models can create/modify files in Open Code CLI!**

Testing revealed that tool/function calling requires specific model training:
- ✅ **Qwen3 models** (qwen3:8b-16k, qwen3:8b, qwen3:4b) - Full tool usage
- ❌ **Mistral Nemo & Granite** - Analysis only, cannot create files

See [test-opencode.md](test-opencode.md) and [RECOMMENDATIONS.md](RECOMMENDATIONS.md) for details.

## Available Models

| Model | Size | Context | Tool Usage | Best For |
|-------|------|---------|------------|----------|
| `qwen3:8b-16k` ⭐ | 5.2 GB | 16k | ✅ YES | File creation, multi-file analysis |
| `qwen3:8b` | 5.2 GB | 8k | ✅ Likely | General file operations |
| `qwen3:4b` | 2.5 GB | 8k | ✅ Likely | Quick file edits |
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

Create a model with extended context (16k):
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

**File Creation/Modification (MUST use Qwen3):**
- **Multi-file changes** → `qwen3:8b-16k` (extended context + tool usage) ⭐
- **Standard file operations** → `qwen3:8b` (balanced)
- **Quick file edits** → `qwen3:4b` (fastest Qwen3 model)

**Code Review/Analysis (Any model works):**
- **Best quality review** → `mistral-nemo:12b-instruct-2407-q4_K_M` (excellent analysis)
- **Fast analysis** → `granite3.1-moe` (quickest)
- **Comprehensive review** → `qwen3:8b-16k` (if planning changes too)

**Performance expectations:**

| Task | qwen3:8b | qwen3:8b-16k | mistral-nemo:12b-instruct-2407-q4_K_M | Claude Sonnet 4 |
|------|----------|--------------|------------------|-----------------|
| Simple file write | 15-30s | 45-90s | ❌ Can't create | 2-5s |
| Code review (read-only) | 20-45s | 60-120s | 40-90s ⭐ | 5-15s |
| Multi-file analysis | 40-90s | 90-180s | ❌ Read-only | 10-30s |

**Notes:**
- qwen3:8b-16k enters verbose "thinking mode" before execution (slower but successful)
- mistral-nemo:12b-instruct-2407-q4_K_M provides best quality analysis but cannot modify files
- For file operations, Qwen3 models are required despite slower performance

## When to Use Local vs Cloud Models

### Use Local Models (Ollama) When:
- ✅ Working offline
- ✅ Processing sensitive/proprietary code
- ✅ Running batch operations overnight
- ✅ Learning/experimenting without API costs
- ✅ Privacy requirements mandate local processing
- ✅ Code review that doesn't require changes (any model)
- ⚠️ **File operations (MUST use Qwen3 models only)**

### Use Cloud Models (Claude API) When:
- ⏱️ Real-time interactive development
- ⚡ Complex multi-file operations requiring fast iteration
- 🚀 Time-sensitive tasks
- 📚 Working with very large codebases (200k+ context)
- 💰 Speed is more important than cost
- 🎯 Best code quality is critical

## Documentation

### [docs/OPENCODE-COMMANDS.md](docs/OPENCODE-COMMANDS.md) ⭐ NEW
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

See [docs/LOCALLLMS.md#troubleshooting](docs/LOCALLLMS.md#troubleshooting) for more details.

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
