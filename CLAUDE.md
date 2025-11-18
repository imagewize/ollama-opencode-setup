# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a **documentation and configuration repository** for running Open Code CLI with local Ollama models. It contains:
- Open Code configuration ([opencode.json](opencode.json))
- Comprehensive documentation ([docs/LOCALLLMS.md](docs/LOCALLLMS.md), [docs/AGENTS.md](docs/AGENTS.md))
- Example workflows ([examples/](examples/))
- Test suite ([test-opencode.md](test-opencode.md))

This repository does NOT contain application code - it's a reference repository meant to be symlinked or copied into other projects.

## Key Configuration Files

### [opencode.json](opencode.json)
The main Open Code CLI configuration defining available Ollama models:
- **Provider**: Ollama (local) at `http://localhost:11434/v1`
- **Models**: qwen3:8b-16k, mistral-nemo:12b-instruct-2407-q4_K_M, qwen3:8b, granite3.1-moe, qwen3:4b

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

### [docs/OPENCODE-COMMANDS.md](docs/OPENCODE-COMMANDS.md)
**Complete Open Code CLI commands reference:**
- All 15 built-in slash commands with keybinds
- Bash command integration using `!command` syntax
- Agent switching with Tab key (build vs plan agents)
- Custom command creation (file-based and config-based)
- Advanced features (arguments, shell integration, file references)
- Common workflows and best practices
- Command troubleshooting

### [docs/LOCALLLMS.md](docs/LOCALLLMS.md)
- Open Code configuration
- Custom model creation
- Context window comparison
- Model selection guidelines
- Troubleshooting (Ollama not running, model not found, performance issues)
- Known Open Code CLI issues (thinking mode behavior, binary file detection)

### [docs/AGENTS.md](docs/AGENTS.md)
- Build and plan agents (Tab key switching)
- Model capabilities for agent workflows
- Agent workflow patterns (autonomous, iterative, analysis-then-action, batch)
- Think mode behavior understanding
- Performance benchmarks by model
- Best practices for autonomous task execution

### [examples/](examples/)
- [code-review.md](examples/code-review.md) - Code review workflows
- [refactoring.md](examples/refactoring.md) - Refactoring patterns
- [multi-file-analysis.md](examples/multi-file-analysis.md) - Multi-file analysis
- [batch-processing.md](examples/batch-processing.md) - Batch operation scripts

### [test-opencode.md](test-opencode.md)
- Test suite for validating Open Code CLI setup
- Performance benchmarks
- Think mode validation
- Comparison matrix for all models

## Common Issues

### "Cannot Read Binary File" Error
Occurs when documentation files contain Unicode box-drawing characters (`├`, `│`, `└`). Solution:
```bash
LC_ALL=C tr -cd '\11\12\15\40-\176' < file.md > file_clean.md
mv file_clean.md file.md
```

### Open Code CLI Thinking Mode
The Qwen3 8B 16K model enters verbose thinking mode during code generation. This is model behavior, not a CLI issue. Build mode is already the default. Tasks complete correctly but slower. Best approach:
- Accept the think mode as part of using local models with extended context
- The verbosity provides useful insight into model reasoning
- Tasks complete successfully despite the extra output

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
- Update [docs/LOCALLLMS.md](docs/LOCALLLMS.md) for technical documentation changes
- Update [docs/AGENTS.md](docs/AGENTS.md) for agent workflow and usage patterns
- Add new workflows to [examples/](examples/) directory
- Update [test-opencode.md](test-opencode.md) with new test cases
- Keep [README.md](README.md) in sync with major changes
