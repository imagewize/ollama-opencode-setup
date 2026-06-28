# Ollama + Open Code Setup

Configuration and documentation for running Open Code CLI with local Ollama models on Apple Silicon (M-series) Macs.

## Quick Start

1. **Install prerequisites:** [Ollama](https://ollama.ai) and [Open Code CLI](https://opencode.ai)

2. **Pull the recommended model and build the 32k variant:**
   ```bash
   ollama pull ministral-3:8b
   ollama create ministral-3:8b-32k -f modelfiles/ministral-3-8b-32k.Modelfile
   ```

3. **Wire the config into your project** (symlink or copy — both work, see [docs/PROJECT-SETUP.md](docs/PROJECT-SETUP.md)):
   ```bash
   # Symlink (auto-updates when this repo updates)
   ln -s ~/code/ollama-opencode-setup/opencode.json ~/code/your-project/opencode.json

   # Or copy (self-contained, good for CI or sharing)
   cp ~/code/ollama-opencode-setup/opencode.json ~/code/your-project/opencode.json
   ```

4. **Run Open Code:**
   ```bash
   cd ~/code/your-project && opencode
   ```

---

## What's Included

| Path | Description |
|------|-------------|
| `opencode.json` | Open Code configuration — all tested Ollama models |
| `modelfiles/` | Reproducible Modelfiles for context-baked model variants |
| `examples/` | Code review, refactoring, multi-file analysis, batch processing prompts |
| `scripts/tool-call-test.sh` | Verify a model's tool-calling capability |
| `test-opencode.md` | Test suite for validating the Open Code setup |
| `CHANGELOG.md` | Version history and model test results |
| `docs/` | Full documentation — see [Documentation](#documentation) below |

---

## Available Models

> **⚠️ Tool calling requires a model trained for it — fitting in RAM is not enough.** Models marked ✅ below can create and edit files; models marked ❌ are read-only (they plan and analyze but output bash instead of invoking the write tool). Verify any model yourself with [`scripts/tool-call-test.sh`](scripts/tool-call-test.sh); full details in [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

**Ollama models** — tested on M1 16GB (2026-05-31):

| Model | Size | Context | Tool Use | Notes |
|-------|------|---------|----------|-------|
| `ministral-3:8b-32k` ⭐ | 11 GB | 32k | ✅ | **Recommended** — 100% GPU on M1 16GB, fastest tool-caller (~4s), no think-mode overhead |
| `ministral-3:8b-16k` | 6.5 GB | 16k | ✅ | Memory-constrained fallback |
| `ministral-3:8b` | 6.0 GB | ~4k default | ✅ | Base model, small default context in Open Code |
| `qwen3:8b-16k` | 5.2 GB | 16k | ✅ | Multi-file analysis, verbose think mode (~26s) |
| `qwen3:8b` | 5.2 GB | 8k | ✅ | General file ops, verbose think mode |
| `qwen3:4b` | 2.5 GB | 8k | ✅ | Quick edits, smallest footprint |
| `qwen3.5:latest` | 6.6 GB | 32k | ✅ | Tool use confirmed on Mac Mini M4 (2026-06-28, ~18s) |
| `deepseek-coder-v2:16b` | 8.9 GB | 128k | ❌ | FIM/completion model, no tool calling |
| `qwen3.5:9b` / `qwen3.5:4b` | 6.6 / ~2.5 GB | 32k | ❌ | Read-only — outputs bash instead of the write tool |
| `phi4:latest` | ~5 GB | 16k | ❌ | Read-only — no tool support |
| `gemma4:e4b` | ~5.5 GB | 32k | ❌ | Read-only — no tool support |
| `mistral-nemo:12b-instruct-2407-q4_K_M` | 7.5 GB | 8k | ❌ | Best quality for read-only review |
| `granite3.1-moe` | 2.0 GB | 8k | ❌ | Fastest read-only analysis |

**MLX models** (via `mlx_lm.server`) — requires Mac Mini M4 24GB+, see [docs/LOCALLLMS.md](docs/LOCALLLMS.md#mlx-runtime-mac-mini-m4-24gb):

| Model | Size | Context | Tool Use | Notes |
|-------|------|---------|----------|-------|
| `Jackrong/MLX-Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled-v2-4bit` ⭐ | ~12 GB | 262k | ✅ | Claude Opus 4.6 reasoning distillate, 100% GPU on M4 24GB, ~9.9 tok/s (tested 2026-06-28) |

---

## Documentation

| Doc | Contents |
|-----|----------|
| [docs/PROJECT-SETUP.md](docs/PROJECT-SETUP.md) | Symlink vs copy, new/existing project setup, committing the config |
| [docs/LOCALLLMS.md](docs/LOCALLLMS.md) | Custom model creation, context windows, Ollama commands, performance |
| [docs/AGENTS.md](docs/AGENTS.md) | Agent modes (build/plan), tool-use patterns, benchmarks |
| [docs/OPENCODE-COMMANDS.md](docs/OPENCODE-COMMANDS.md) | All slash commands, bash integration, custom command creation |
| [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Tool-call failures, think mode, model selection flowchart |
| [modelfiles/README.md](modelfiles/README.md) | Why custom Modelfiles exist, GPU test results, adding new variants |

---

## Contributing

Contributions welcome — new model configs, Modelfiles, example workflows, or doc improvements. Open an issue or PR.

## License

MIT
