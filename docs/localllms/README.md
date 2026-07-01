# Local LLMs Documentation

> Entry point for all local LLM (Ollama) configuration and usage documentation for Open Code CLI.

This section covers setting up, configuring, and using local language models with Open Code CLI on Apple Silicon Macs.

## Quick Navigation

| Topic | Description | File |
|-------|-------------|------|
| **Configuration** | Open Code + Ollama setup, model lists | [CONFIGURATION.md](./CONFIGURATION.md) |
| **Context Windows** | RAM-based defaults, extended context, why we bake `num_ctx` | [CONTEXT-WINDOWS.md](./CONTEXT-WINDOWS.md) |
| **Custom Models** | Creating variants with extended context via Modelfiles | [CUSTOM-MODELS.md](./CUSTOM-MODELS.md) |
| **MLX Runtime** | Mac-specific MLX engine, GPU memory tuning | [MLX-RUNTIME.md](./MLX-RUNTIME.md) |
| **Model Selection** | Guidelines, benchmarks, recommendations | [MODEL-SELECTION.md](./MODEL-SELECTION.md) |
| **Commands** | Ollama CLI reference | [COMMANDS.md](./COMMANDS.md) |
| **Troubleshooting** | Common issues and solutions | [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) |

## Prerequisites

- [Ollama](https://ollama.com) installed and running
- Open Code CLI installed
- Apple Silicon Mac (M1, M2, M3, M4 series) recommended

## Getting Started

1. **Install a model**: See [COMMANDS.md](./COMMANDS.md) for Ollama commands
2. **Configure Open Code**: See [CONFIGURATION.md](./CONFIGURATION.md)
3. **Select a model**: See [MODEL-SELECTION.md](./MODEL-SELECTION.md)
4. **Extend context if needed**: See [CONTEXT-WINDOWS.md](./CONTEXT-WINDOWS.md) and [CUSTOM-MODELS.md](./CUSTOM-MODELS.md)

## Need Help?

- For Open Code CLI commands: [../OPENCODE-COMMANDS.md](../OPENCODE-COMMANDS.md)
- For project setup: [../PROJECT-SETUP.md](../PROJECT-SETUP.md)
- For troubleshooting: [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
