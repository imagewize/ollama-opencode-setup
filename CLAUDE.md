# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a **documentation and configuration repository** for running Open Code CLI with local Ollama models. It contains:
- Open Code configuration ([opencode.json](opencode.json))
- Comprehensive documentation ([docs/LOCALLLMS.md](docs/LOCALLLMS.md))
- Example workflows ([examples/](examples/))

This repository does NOT contain application code - it's a reference repository meant to be symlinked or copied into other projects.

## Key Configuration Files

### [opencode.json](opencode.json)
The main Open Code CLI configuration defining available Ollama models:
- **Provider**: Ollama (local) at `http://localhost:11434/v1`
- **Models**: qwen3:8b-16k, mistral-nemo:12b, qwen3:8b, granite3.1-moe, qwen3:4b

When adding new models, update this file with the model name and display name.

## Custom Model Context

### Extended Context Models
The `qwen3:8b-16k` model is a **custom variant** created from `qwen3:8b` with 16k context (vs standard 8k). It's created using:
```bash
ollama run qwen3:8b
>>> /set parameter num_ctx 16384
>>> /save qwen3:8b-16k
>>> /bye
```

This pattern can be used to create custom context variants of any Ollama model without increasing model size.

## Ollama Commands Reference

Essential commands for managing local models:
```bash
# List installed models
ollama list

# Pull a new model
ollama pull <model-name>

# Remove a model
ollama rm <model-name>

# Run interactive session
ollama run <model-name>

# Check if Ollama is running
curl http://localhost:11434/v1/models

# Start Ollama service
ollama serve
```

## Model Selection Guidelines

**Context windows:**
- 4k tokens: ~3,000 words, 1 medium file
- 8k tokens: ~6,000 words, 1-2 medium files
- 16k tokens: ~12,000 words, 3-5 medium files
- 200k tokens (Claude): ~150,000 words, entire small-medium codebase

**Model recommendations:**
- **Quick tasks** → `qwen3:4b` (2.5 GB, 5-15s)
- **Standard tasks** → `qwen3:8b` (5.2 GB, 15-30s)
- **Multi-file analysis** → `qwen3:8b-16k` (5.2 GB, 45-90s)
- **Best code quality** → `mistral-nemo:12b-instruct-2407-q4_K_M` (7.5 GB, 25-60s)
- **Efficient MoE** → `granite3.1-moe:latest` (2.0 GB, 6-18s)

## Documentation Structure

All documentation is in [docs/LOCALLLMS.md](docs/LOCALLLMS.md):
- Open Code configuration
- Custom model creation
- Context window comparison
- Model selection guidelines
- Troubleshooting (Ollama not running, model not found, performance issues)
- Known Open Code CLI issues (thinking mode, /no_think flag, binary file detection)

Examples are in [examples/](examples/):
- [code-review.md](examples/code-review.md) - Code review workflows
- [refactoring.md](examples/refactoring.md) - Refactoring patterns
- [multi-file-analysis.md](examples/multi-file-analysis.md) - Multi-file analysis
- [batch-processing.md](examples/batch-processing.md) - Batch operation scripts

## Common Issues

### "Cannot Read Binary File" Error
Occurs when documentation files contain Unicode box-drawing characters (`├`, `│`, `└`). Solution:
```bash
LC_ALL=C tr -cd '\11\12\15\40-\176' < file.md > file_clean.md
mv file_clean.md file.md
```

### Open Code CLI Thinking Mode
The Qwen3 8B 16K model may enter verbose thinking mode despite `/no_think` flag. This is a known limitation - tasks complete correctly but slower. Workarounds:
- Use explicit prompts: "Immediately create X. No analysis needed."
- Use interactive mode with `/mode build`
- Accept the verbosity for local model usage

### Slow Performance
Local models are 3-10x slower than cloud models:
- Simple file write: 8-30s (local) vs 2-5s (Claude)
- Use smaller models for simple tasks
- Use standard context when extended context isn't needed
- Consider cloud models for time-sensitive work

## Local vs Cloud Model Usage

**Use local models (Ollama) when:**
- Working offline
- Processing sensitive/proprietary code
- Running batch operations overnight
- Privacy requirements mandate local processing
- Learning/experimenting without API costs

**Use cloud models (Claude API) when:**
- Real-time interactive development
- Complex multi-file operations requiring fast iteration
- Time-sensitive tasks
- Working with very large codebases (200k+ context)
- Speed is more important than cost

## Repository Workflow

This repository is designed to be:
1. **Cloned** to `~/code/ollama-opencode-setup`
2. **Symlinked** into projects: `ln -s ~/code/ollama-opencode-setup/opencode.json ~/code/your-project/opencode.json`
3. **Referenced** for documentation and examples

When making changes:
- Update [opencode.json](opencode.json) when adding/removing models
- Update [docs/LOCALLLMS.md](docs/LOCALLLMS.md) for documentation changes
- Add new workflows to [examples/](examples/) directory
- Keep [README.md](README.md) in sync with major changes
