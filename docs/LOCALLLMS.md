# Local LLMs Documentation

> **DEPRECATED**: This documentation has been restructured. Please see [docs/localllms/](./localllms/) for the new organization.

---

## New Location

All content has been moved to the **lowercase** `docs/localllms/` directory with UPPERCASE file names:

| Topic | New Location |
|-------|--------------|
| Overview & Navigation | [localllms/README.md](./localllms/README.md) |
| **CRITICAL: Context Windows** | [localllms/CONTEXT-WINDOWS.md](./localllms/CONTEXT-WINDOWS.md) |
| Configuration | [localllms/CONFIGURATION.md](./localllms/CONFIGURATION.md) |
| Custom Models | [localllms/CUSTOM-MODELS.md](./localllms/CUSTOM-MODELS.md) |
| MLX Runtime | [localllms/MLX-RUNTIME.md](./localllms/MLX-RUNTIME.md) |
| Model Selection | [localllms/MODEL-SELECTION.md](./localllms/MODEL-SELECTION.md) |
| Commands Reference | [localllms/COMMANDS.md](./localllms/COMMANDS.md) |
| Troubleshooting | [localllms/TROUBLESHOOTING.md](./localllms/TROUBLESHOOTING.md) |

---

## What's New

### Ollama Default Context Windows by System RAM

Ollama automatically sets the default context window based on available system RAM:

| System RAM | Default Context | Affected Systems |
|------------|----------------|------------------|
| **<= 24GB** | **4,096 tokens** | MacBook Pro M1 (16GB), MacBook Air M1/M2 (16GB), **Mac Mini M4 (24GB)** |
| 32GB | 8,192 tokens | MacBook Pro M1 Max (32GB), M2 Pro (32GB) |
| 48GB | 16,384 tokens | MacBook Pro M1 Max (48GB), M1 Ultra, M2 Max (48GB+) |
| 64GB+ | 32,768 tokens | Mac Studio, Mac Pro, high-end MacBook Pro |

**This means your M4 24GB Mac Mini runs ALL base models at 4K context by default** — not a larger value. To use extended context with Open Code CLI, you MUST create custom variants with `num_ctx` baked in via Modelfiles.

---

## Why This Change

This file was ~850 lines and covered too many topics. The new structure:
- Follows single-responsibility principle
- Makes documentation easier to navigate and maintain
- Adds the critical context window clarification as a primary section

---

## See Also

- [Project Setup Guide](./PROJECT-SETUP.md)
- [OpenCode Commands Guide](./OPENCODE-COMMANDS.md)
- [Troubleshooting Guide](./TROUBLESHOOTING.md)
