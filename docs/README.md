# Documentation Index

This directory contains documentation for running Open Code CLI with local Ollama models.

## Documentation Overview

| File | Purpose | Key Topics |
|------|---------|------------|
| [CONFIGURATION.md](./CONFIGURATION.md) | **Configuration** | Available models, provider setup, `opencode.json` |
| [CONTEXT-WINDOWS.md](./CONTEXT-WINDOWS.md) | **Context Windows** | RAM-based defaults, why we bake `num_ctx` |
| [CUSTOM-MODELS.md](./CUSTOM-MODELS.md) | **Custom Models** | Creating extended-context variants via Modelfiles |
| [MODEL-SELECTION.md](./MODEL-SELECTION.md) | **Model Selection** | Guidelines, benchmarks, recommendations by hardware |
| [OLLAMA-COMMANDS.md](./OLLAMA-COMMANDS.md) | **Ollama Commands** | CLI reference for managing models and the server |
| [MLX-RUNTIME.md](./MLX-RUNTIME.md) | **MLX Runtime** | Mac-specific GPU memory tuning for M4 24GB+ |
| [AGENTS-USAGE.md](./AGENTS-USAGE.md) | **Agent Workflows** | Agent modes, capabilities by model, workflow patterns |
| [OPENCODE-COMMANDS.md](./OPENCODE-COMMANDS.md) | **CLI Reference** | All slash commands, bash integration, keybindings |
| [PROJECT-SETUP.md](./PROJECT-SETUP.md) | **Project Setup** | Symlink vs copy, wiring config into projects |
| [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) | **Troubleshooting** | Tool usage, model limitations, Ollama service checks |

## Getting Started

1. **Understand the configuration** → [CONFIGURATION.md](./CONFIGURATION.md)
2. **Learn the CLI** → [OPENCODE-COMMANDS.md](./OPENCODE-COMMANDS.md)
3. **Explore agent workflows** → [AGENTS-USAGE.md](./AGENTS-USAGE.md)
4. **Solve issues** → [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

## Prerequisites

- [Ollama](https://ollama.com) installed and running
- Open Code CLI installed
- Apple Silicon Mac (M1, M2, M3, M4 series) recommended

## Quick Reference

### Available Models (Confirmed Tool Use)
| Model | Size | Context | Tool Use | Speed |
|-------|------|---------|----------|-------|
| `ministral-3:8b-32k` | 11 GB | 32k | Yes | ~4s warm |
| `ministral-3:8b-16k` | 6.5 GB | 16k | Yes | ~4-10s |
| `ministral-3:8b` | 6.0 GB | ~4k default | Yes | ~4s |
| `qwen3:8b-16k` | 5.2 GB | 16k | Yes | ~26s |
| `qwen3:8b` | 5.2 GB | 8k | Yes | ~26s |
| `qwen3:4b` | 2.5 GB | 8k | Yes | Fast |

### Read-Only Models (Analysis Only)
| Model | Size | Context | Tool Use | Best For |
|-------|------|---------|----------|---------|
| `mistral-nemo:12b-instruct-2407-q4_K_M` | 7.5 GB | 8k | No | Code review, analysis |
| `qwen3.5:9b` | 6.6 GB | 32k | No | Large context analysis |
| `qwen3.5:4b` | 2.5 GB | 32k | No | Light analysis |
| `granite3.1-moe` | 2.0 GB | 8k | No | Fast analysis |

### Essential Ollama Commands
```bash
ollama list
ollama pull qwen3:8b
ollama create ministral-3:8b-32k -f modelfiles/ministral-3-8b-32k.Modelfile
ollama run qwen3:8b-16k
curl http://localhost:11434/v1/models
```

## Contribution Guide

When adding new documentation:
1. Create focused, single-purpose markdown files
2. Use consistent heading structure (`##`, `###`, `####`)
3. Include practical examples and code snippets
4. Cross-reference related documentation
5. Add an entry to this README
6. Update [opencode.json](../opencode.json) if adding new models
