# AGENTS.md

Instructions for AI coding agents (Mistral Vibe, and any other tool that reads
`AGENTS.md`) working in this repository. The Claude Code companion file is
[CLAUDE.md](CLAUDE.md) — keep the two in sync when changing shared guidance.

## Repository Purpose

This is a **documentation and configuration repository** for running Open Code CLI with local Ollama models. It contains:
- Open Code configuration ([opencode.json](opencode.json))
- Custom Modelfiles for extended context variants ([modelfiles/](modelfiles/))
- Comprehensive documentation ([docs/PROJECT-SETUP.md](docs/PROJECT-SETUP.md), [docs/localllms/](docs/localllms/), [docs/AGENTS-USAGE.md](docs/AGENTS-USAGE.md), [docs/OPENCODE-COMMANDS.md](docs/OPENCODE-COMMANDS.md))
- Example workflows ([examples/](examples/))
- Test suite ([test-opencode.md](test-opencode.md))

This repository does NOT contain application code - it's a reference repository meant to be symlinked or copied into other projects.

## Key Configuration Files

### [opencode.json](opencode.json)
The main Open Code CLI configuration defining available Ollama models:
- **Provider**: Ollama (local) at `http://localhost:11434/v1`
- **Models (tool use, M1 16GB)**: `ministral-3:8b-32k` (recommended), `ministral-3:8b-16k`, `ministral-3:8b`, `qwen3:8b-16k`, `qwen3:8b`, `qwen3:4b`
- **Models (tool use, M4 24GB)**: `mistral-small3.2:24b-32k` (recommended, no GPU tuning), `qwen3-coder:30b-32k` (coding MoE, needs raised GPU limit), `qwen3.5:27b-mlx`, `qwen3.5:latest`
- **Models (read-only)**: `deepseek-coder-v2:16b`, `qwen3.5:9b`, `qwen3.5:4b`, `phi4`, `gemma4:e4b`, `mistral-nemo:12b-instruct-2407-q4_K_M`, `granite3.1-moe`

When adding new models, update this file with the model name and display name, then run `ollama pull <model-name>`.

### [modelfiles/](modelfiles/)
Custom Modelfiles for creating extended context variants:
- `ministral-3-8b-32k.Modelfile` - 32k context variant of ministral-3:8b (recommended, 100% GPU on M1 16GB)
- `ministral-3-8b-16k.Modelfile` - 16k context variant of ministral-3:8b (memory-constrained fallback)
- `qwen3-8b-16k.Modelfile` - 16k context variant of qwen3:8b
- `mistral-small3.2-24b-32k.Modelfile` - 32k variant for M4 24GB (recommended, no GPU tuning)
- `qwen3-coder-30b-32k.Modelfile` - 32k variant of the qwen3-coder 30B MoE for M4 24GB (needs raised GPU limit)
- Create new variants using: `ollama create <model-name> -f modelfiles/<filename>.Modelfile`

## Custom Model Context

### Extended Context Models
Custom variants with `num_ctx` baked in are needed because Open Code talks to Ollama via the OpenAI-compatible endpoint, which does not pass Ollama's `num_ctx` — so base models run at Ollama's small default context inside Open Code. Each variant has a committed Modelfile for reproducible builds:

```bash
ollama create ministral-3:8b-32k -f modelfiles/ministral-3-8b-32k.Modelfile  # recommended (M1 16GB)
ollama create ministral-3:8b-16k -f modelfiles/ministral-3-8b-16k.Modelfile
ollama create qwen3:8b-16k -f modelfiles/qwen3-8b-16k.Modelfile
ollama create mistral-small3.2:24b-32k -f modelfiles/mistral-small3.2-24b-32k.Modelfile  # M4 24GB (recommended)
ollama create qwen3-coder:30b-32k -f modelfiles/qwen3-coder-30b-32k.Modelfile           # M4 24GB (coding MoE)
```

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

# Create model from Modelfile
ollama create <model-name> -f <modelfile-path>
```

## Model Selection Guidelines

**Context windows:**
- 4k tokens: ~3,000 words, 1 medium file
- 8k tokens: ~6,000 words, 1-2 medium files
- 16k tokens: ~12,000 words, 3-5 medium files
- 32k+ tokens: Large multi-file analysis

**Model recommendations (M1 16GB, tested 2026-06-01):**
- **Recommended for Open Code** → `ministral-3:8b-32k` (11 GB, 32k ctx, 100% GPU, tool use confirmed)
- **Memory-constrained fallback** → `ministral-3:8b-16k` (6.5 GB, 16k ctx, 100% GPU, tool use confirmed)
- **Quick file ops** → `qwen3:4b` (2.5 GB, tool use confirmed)
- **Standard file ops** → `qwen3:8b` (5.2 GB, tool use confirmed, ~26s)
- **Multi-file ops** → `qwen3:8b-16k` (5.2 GB, 16k ctx, tool use confirmed)
- **Large context analysis** → `qwen3.5:9b` (6.6 GB, 32k ctx, read-only — no tool use)
- **Read-only analysis** → `mistral-nemo:12b-instruct-2407-q4_K_M` (7.5 GB, read-only)

**Model recommendations (Mac Mini M4 Pro 24GB, tested 2026-06-30):**
- **Recommended (no GPU tuning)** → `mistral-small3.2:24b-32k` (19 GB, 32k ctx, 100% GPU, tool use confirmed). The 64k variant spills 22% to CPU — stay at 32k.
- **Coding MoE (needs raised GPU limit)** → `qwen3-coder:30b-32k` (21 GB, 32k ctx, ~34.5 tok/s warm). Reaches 98% GPU only after `sudo sysctl -w iogpu.wired_limit_mb=21504` + Ollama restart.
- **Lightweight option** → `qwen3.5:latest` (6.6 GB, 32k ctx, tool use confirmed, ~18s)

See [docs/localllms/MLX-RUNTIME.md](docs/localllms/MLX-RUNTIME.md) and [modelfiles/README.md](modelfiles/README.md) for the full GPU test results.

## Documentation Structure

### [docs/PROJECT-SETUP.md](docs/PROJECT-SETUP.md)
How to wire this repo's config into a new or existing project — symlink vs copy, per-project vs global config, launching OpenCode and selecting a model.

### [docs/OPENCODE-COMMANDS.md](docs/OPENCODE-COMMANDS.md)
Complete Open Code CLI commands reference including all 15 built-in slash commands, bash integration, agent switching, custom command creation, and troubleshooting.

### [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
Tool usage discovery, model capability limitations, diagnosing models that plan but do not create files, hybrid workflow strategies, and model selection flowchart.

### [docs/localllms/](docs/localllms/)
Open Code configuration with local models, custom model creation, context window comparison, model selection guidelines, troubleshooting, and known Open Code CLI issues.

### [docs/AGENTS-USAGE.md](docs/AGENTS-USAGE.md)
How OpenCode works (the agentic loop / tool-use wrapper pattern), build and plan agents (Tab key switching), model capabilities, agent workflow patterns, think-mode behavior, performance benchmarks, and best practices. This is the human-facing agents guide; the file you are reading (`AGENTS.md` at the repo root) is the agent instruction file.

### [examples/](examples/)
- [code-review.md](examples/code-review.md) - Code review workflows
- [refactoring.md](examples/refactoring.md) - Refactoring patterns
- [multi-file-analysis.md](examples/multi-file-analysis.md) - Multi-file analysis
- [batch-processing.md](examples/batch-processing.md) - Batch operation scripts

### [test-opencode.md](test-opencode.md)
Test suite for validating Open Code CLI setup, performance benchmarks, think mode validation, and the comparison matrix for all models.

## Before Responding

1. **Review this file and [CLAUDE.md](CLAUDE.md)** for repository purpose and structure, key configuration files, Ollama commands, documentation structure, and model selection guidelines.
2. **Check current context**: confirm the working directory is the repository root (`ollama-opencode-setup`), the current branch, and git status; review recent commits for relevant changes.
3. **Adhere to key principles**: this is a documentation/configuration repository, not an application codebase; file paths are relative to the repository root; model operations use the Ollama CLI; configuration changes require updates to both `opencode.json` and the documentation.

## Response Guidelines

- Be concise and technical
- Reference specific files and line numbers
- Use markdown formatting for code and structure
- Prioritize verification over assumptions
- When unsure, ask for clarification before acting
- For Open Code CLI specifics, reference [docs/OPENCODE-COMMANDS.md](docs/OPENCODE-COMMANDS.md)
- For model selection, reference [docs/localllms/MODEL-SELECTION.md](docs/localllms/MODEL-SELECTION.md)

## Repository Workflow

This repository is designed to be:
1. **Cloned** to `~/code/ollama-opencode-setup`
2. **Symlinked** into projects: `ln -s ~/code/ollama-opencode-setup/opencode.json ~/code/your-project/opencode.json`
3. **Referenced** for documentation and examples

When making changes:
- Update [opencode.json](opencode.json) when adding/removing models
- Add corresponding Modelfile to [modelfiles/](modelfiles/) for custom variants
- Update [docs/localllms/](docs/localllms/) for technical documentation changes
- Update [docs/AGENTS.md](docs/AGENTS.md) for agent workflow and usage patterns
- Add new workflows to [examples/](examples/) directory
- Update [test-opencode.md](test-opencode.md) with new test cases
- Keep [README.md](README.md) and [CLAUDE.md](CLAUDE.md) in sync with major changes

## Common Issues

### "Cannot Read Binary File" Error
Occurs when documentation files contain Unicode box-drawing characters (`├`, `│`, `└`). Solution:
```bash
LC_ALL=C tr -cd '\11\12\15\40-\176' < file.md > file_clean.md
mv file_clean.md file.md
```

### Open Code CLI Thinking Mode
The Qwen3 8B 16K model enters verbose thinking mode during code generation. This is model behavior, not a CLI issue. Tasks complete correctly but slower. The verbosity provides useful insight into model reasoning.

### Slow Performance
Local models are 3-10x slower than cloud models:
- Simple file write: 8-30s (local) vs 2-5s (cloud)
- Use smaller models (`qwen3:4b`, `ministral-3:8b`) for simple tasks
- Use standard context when extended context isn't needed
- Consider cloud models for time-sensitive work

## Local vs Cloud Model Usage

**Use local models (Ollama) when:**
- Working offline
- Processing sensitive/proprietary code
- Running batch operations overnight
- Privacy requirements mandate local processing
- Learning/experimenting without API costs

**Use cloud models when:**
- Real-time interactive development
- Complex multi-file operations requiring fast iteration
- Time-sensitive tasks
- Working with very large codebases (200k+ context)
- Speed is more important than cost

## Git Commit Rules

> **⚠️ STRICT: No AI attribution in commits — this repository is attribution-free**

- **Always create a new branch** for commits — never commit directly to `main`.
- **Always use atomic commits**: each commit must represent **one logical change**. 
  - Split changes into multiple commits if they touch unrelated files/systems
  - Example: Configuration changes = one commit, documentation updates = separate commit
  - Do NOT bundle documentation fixes with config changes in a single commit
- **Commit message format**: imperative mood, present tense; concise but descriptive.
  - Good: `Add qwen3:8b-16k to opencode.json`
  - Bad: `Added model` or `Updating models`
- **Prefix commits** when appropriate: `docs:`, `config:`, `test:`, `examples:`.
- **❌ NEVER add AI attribution** to commit messages:
  - ❌ NO `Co-authored-by: Mistral Vibe <vibe@mistral.ai>`
  - ❌ NO `Generated by Mistral Vibe`
  - ❌ NO `Generated by Mistral AI`
  - ❌ NO any form of AI tool attribution
  - ✅ All commits must be **professional and attribution-free**
  - This applies to **every file and directory** in the repository, without exception
