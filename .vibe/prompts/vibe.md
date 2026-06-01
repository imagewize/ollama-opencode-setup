# Custom Instructions for Vibe

This file provides guidance to Mistral Vibe when working with code in this repository.

## Repository Purpose

This is a **documentation and configuration repository** for running Open Code CLI with local Ollama models. It contains:
- Open Code configuration ([opencode.json](opencode.json))
- Custom Modelfiles for extended context variants ([modelfiles/](modelfiles/))
- Comprehensive documentation ([docs/PROJECT-SETUP.md](docs/PROJECT-SETUP.md), [docs/LOCALLLMS.md](docs/LOCALLLMS.md), [docs/AGENTS.md](docs/AGENTS.md), [docs/OPENCODE-COMMANDS.md](docs/OPENCODE-COMMANDS.md))
- Example workflows ([examples/](examples/))
- Test suite ([test-opencode.md](test-opencode.md))

This repository does NOT contain application code - it's a reference repository meant to be symlinked or copied into other projects.

## Primary Directive

Always follow the rules and conventions in this file and [CLAUDE.md](CLAUDE.md). This file takes precedence for Vibe-specific guidance.

## Key Configuration Files

### [opencode.json](opencode.json)
The main Open Code CLI configuration defining available Ollama models:
- **Provider**: Ollama (local) at `http://localhost:11434/v1`
- **Models (tool use, confirmed)**: `ministral-3:8b-32k` (recommended), `ministral-3:8b-16k`, `ministral-3:8b`, `qwen3:8b-16k`, `qwen3:8b`, `qwen3:4b`
- **Models (read-only, confirmed)**: `deepseek-coder-v2:16b`, `qwen3.5:9b`, `qwen3.5:4b`, `phi4`, `gemma4:e4b`, `mistral-nemo:12b-instruct-2407-q4_K_M`, `granite3.1-moe`

When adding new models, update this file with the model name and display name, then run `ollama pull <model-name>`.

### [modelfiles/](modelfiles/)
Custom Modelfiles for creating extended context variants:
- `ministral-3-8b-32k.Modelfile` - 32k context variant of ministral-3:8b (recommended, 100% GPU on M1 16GB)
- `ministral-3-8b-16k.Modelfile` - 16k context variant of ministral-3:8b (memory-constrained fallback)
- `qwen3-8b-16k.Modelfile` - 16k context variant of qwen3:8b
- `ministral-3-8b-64k.Modelfile` - 64k variant (do not use on M1 16GB — causes CPU spillover)
- Create new variants using: `ollama create <model-name> -f modelfiles/<filename>.Modelfile`

## Custom Model Context

### Extended Context Models
The `ministral-3:8b-16k` and `qwen3:8b-16k` models are **custom variants** with 16k context windows (vs standard 8k). This is needed because Open Code talks to Ollama via the OpenAI-compatible endpoint, which does not pass Ollama's `num_ctx` parameter — so the base model would run at Ollama's default context inside Open Code.

Build from a committed Modelfile (reproducible):
```bash
ollama create ministral-3:8b-32k -f modelfiles/ministral-3-8b-32k.Modelfile  # recommended
ollama create ministral-3:8b-16k -f modelfiles/ministral-3-8b-16k.Modelfile
ollama create qwen3:8b-16k -f modelfiles/qwen3-8b-16k.Modelfile
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

**Model recommendations (M1 16GB, tested 2026-05-31):**
- **Default / fast tool use** → `ministral-3:8b` (6.0 GB, tool use confirmed, ~4s warm — recommended)
- **Quick file ops** → `qwen3:4b` (2.5 GB, tool use confirmed)
- **Standard file ops** → `qwen3:8b` (5.2 GB, tool use confirmed, ~26s)
- **Multi-file ops** → `ministral-3:8b-16k` or `qwen3:8b-16k` (16k ctx, tool use confirmed)
- **Large context analysis** → `qwen3.5:9b` (6.6 GB, 32k ctx, read-only — no tool use)
- **Read-only analysis** → `mistral-nemo:12b-instruct-2407-q4_K_M` (7.5 GB, read-only)

## Documentation Structure

### [docs/OPENCODE-COMMANDS.md](docs/OPENCODE-COMMANDS.md)
Complete Open Code CLI commands reference including all 15 built-in slash commands, bash integration, agent switching, custom command creation, and troubleshooting.

### [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
Tool usage discovery, model capability limitations, diagnosing models that plan but do not create files, hybrid workflow strategies, and model selection flowchart.

### [docs/LOCALLLMS.md](docs/LOCALLLMS.md)
- Open Code configuration with local models
- Custom model creation workflows
- Context window comparison
- Model selection guidelines
- Troubleshooting (Ollama not running, model not found, performance issues)
- Known Open Code CLI issues

### [docs/AGENTS.md](docs/AGENTS.md)
- How OpenCode works: the agentic loop (tool-use wrapper pattern)
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

## Before Responding

1. **Review this file and CLAUDE.md** for:
   - Repository purpose and structure
   - Key configuration files and their locations
   - Ollama commands and model management
   - Documentation structure
   - Model selection guidelines

2. **Check Current Context**:
   - Verify you're in `/Users/jasperfrumau/code/ollama-opencode-setup`
   - Confirm the current branch and git status
   - Review any recent commits for relevant changes

3. **Adhere to Key Principles**:
   - This is a documentation/configuration repository, not an application codebase
   - All file paths are relative to this repository root
   - Model operations use Ollama CLI
   - Configuration changes require updates to both opencode.json and documentation

## Response Guidelines

- Be concise and technical
- Reference specific files and line numbers
- Use markdown formatting for code and structure
- Prioritize verification over assumptions
- When unsure, ask for clarification before acting
- For Open Code CLI specifics, reference [docs/OPENCODE-COMMANDS.md](docs/OPENCODE-COMMANDS.md)
- For model selection, reference [docs/LOCALLLMS.md](docs/LOCALLLMS.md)

## Repository Workflow

This repository is designed to be:
1. **Cloned** to `~/code/ollama-opencode-setup`
2. **Symlinked** into projects: `ln -s ~/code/ollama-opencode-setup/opencode.json ~/code/your-project/opencode.json`
3. **Referenced** for documentation and examples

When making changes:
- Update [opencode.json](opencode.json) when adding/removing models
- Add corresponding Modelfile to [modelfiles/](modelfiles/) for custom variants
- Update [docs/LOCALLLMS.md](docs/LOCALLLMS.md) for technical documentation changes
- Update [docs/AGENTS.md](docs/AGENTS.md) for agent workflow and usage patterns
- Add new workflows to [examples/](examples/) directory
- Update [test-opencode.md](test-opencode.md) with new test cases
- Keep [README.md](README.md) in sync with major changes

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

**Use cloud models (Mistral/Vibe API) when:**
- Real-time interactive development
- Complex multi-file operations requiring fast iteration
- Time-sensitive tasks
- Working with very large codebases (200k+ context)
- Speed is more important than cost

## Git Commit Rules

- **Always create a new branch** for commits - never commit directly to main
- **Always use atomic commits**: each commit must represent one logical change or logical group of changes. Atomic commits can be per logical group or single file depending on change size. Do not bundle unrelated edits into a single commit.
- **Commit message format**: Use imperative mood, present tense. Be concise but descriptive.
  - Good: `Add qwen3:8b-16k to opencode.json`
  - Bad: `Added model` or `Updating models`
- **Never add AI attribution** to commit messages - no "Co-authored-by", "Generated by", or similar.
- **Prefix commits** when appropriate:
  - `docs:` for documentation changes
  - `config:` for configuration file updates
  - `test:` for test suite updates
  - `examples:` for example workflow additions

## NO Mistral Vibe Attribution in Any Commits

- Do NOT include "Generated by Mistral Vibe. Co-Authored-By: Mistral Vibe <vibe@mistral.ai>" attribution
- Keep all commits professional and attribution-free
- This applies to ALL files and directories in the entire repository
- Follow standard git commit message format as described above
- **All commits must be atomic** - one logical change or logical group per commit
