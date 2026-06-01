# Documentation Index

This directory contains documentation for running Open Code CLI with local Ollama models.

## Documentation Overview

| File | Purpose | Key Topics |
|------|---------|------------|
| [LOCALLLMS.md](./LOCALLLMS.md) | **Core Configuration** | Model setup, context windows, Ollama commands, custom Modelfiles |
| [AGENTS.md](./AGENTS.md) | **Agent Workflows** | Agent modes, capabilities by model, workflow patterns, performance benchmarks |
| [OPENCODE-COMMANDS.md](./OPENCODE-COMMANDS.md) | **CLI Reference** | All slash commands, bash integration, keybindings, troubleshooting |
| [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) | **Issue Resolution** | Tool usage discovery, model limitations, hybrid workflows, model selection |

## Getting Started

1. **Understand the configuration** → [LOCALLLMS.md](./LOCALLLMS.md)
2. **Learn the CLI** → [OPENCODE-COMMANDS.md](./OPENCODE-COMMANDS.md)
3. **Explore agent workflows** → [AGENTS.md](./AGENTS.md)
4. **Solve issues** → [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

## Quick Reference

### Available Models (Confirmed Tool Use)
| Model | Size | Context | Tool Use | Speed |
|-------|------|---------|----------|-------|
| `ministral-3:8b-16k` | 6.0 GB | 16k | Yes | ~4s warm |
| `ministral-3:8b` | 6.0 GB | 4k | Yes | ~4s warm |
| `qwen3:8b-16k` | 5.2 GB | 16k | Yes | ~26s |
| `qwen3:8b` | 5.2 GB | 8k | Yes | ~26s |
| `qwen3:4b` | 2.5 GB | 4k | Yes | Fast |

### Read-Only Models (Analysis Only)
| Model | Size | Context | Tool Use | Best For |
|-------|------|---------|----------|---------|
| `mistral-nemo:12b-instruct-2407-q4_K_M` | 7.5 GB | 32k | No | Code review, analysis |
| `qwen3.5:9b` | 6.6 GB | 32k | No | Large context analysis |
| `qwen3.5:4b` | 2.5 GB | 32k | No | Light analysis |
| `granite3.1-moe` | 2.0 GB | ? | No | Fast analysis |

### Essential Ollama Commands
```bash
ollama list
ollama pull qwen3:8b
ollama create ministral-3:8b-16k -f ../modelfiles/ministral-3-8b-16k.Modelfile
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
