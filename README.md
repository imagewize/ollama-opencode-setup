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
| `docs/PROJECT-SETUP.md` | How to wire this config into new and existing projects |
| `docs/LOCALLLMS.md` | Local LLM setup, custom model creation, context windows |
| `docs/AGENTS.md` | Open Code agent modes, tool-use patterns, benchmarks |
| `docs/OPENCODE-COMMANDS.md` | Complete Open Code CLI slash commands reference |
| `docs/TROUBLESHOOTING.md` | Diagnosing tool-call failures, model selection flowchart |
| `examples/` | Code review, refactoring, multi-file analysis, batch processing prompts |
| `scripts/tool-call-test.sh` | Verify a model's tool-calling capability |
| `test-opencode.md` | Test suite for validating the Open Code setup |
| `RECOMMENDATIONS.md` | Historical Ollama vs LM Studio notes (partially outdated) |
| `CHANGELOG.md` | Version history and model test results |

---

## ⚠️ Important: Tool Usage

**Tool calling requires a model trained for it — fitting in RAM is not enough.**

Tested on M1 16GB (2026-05-31):

| Status | Model | Notes |
|--------|-------|-------|
| ✅ | `ministral-3:8b` family | **Recommended** — fastest tool-caller (~4s), no think-mode overhead |
| ✅ | `qwen3:8b-16k`, `qwen3:8b`, `qwen3:4b` | Full tool use, verbose think mode (~26s) |
| ❌ | `deepseek-coder-v2:16b` | FIM/completion model, no tool calling |
| ❌ | `qwen3.5:9b`, `qwen3.5:4b` | Outputs bash instead of invoking the write tool |
| ❌ | `phi4`, `gemma4:e4b` | No tool support |
| ❌ | `mistral-nemo`, `granite3.1-moe` | Analysis only, cannot create files |

Verify a model with [`scripts/tool-call-test.sh`](scripts/tool-call-test.sh). Full details in [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

---

## Available Models

| Model | Size | Context | Tool Use | Notes |
|-------|------|---------|----------|-------|
| `ministral-3:8b-32k` ⭐ | 11 GB | 32k | ✅ | Recommended — 100% GPU on M1 16GB |
| `ministral-3:8b-16k` | 6.5 GB | 16k | ✅ | Memory-constrained fallback |
| `ministral-3:8b` | 6.0 GB | ~4k default | ✅ | Base model, small default context in Open Code |
| `qwen3:8b-16k` | 5.2 GB | 16k | ✅ | Multi-file analysis |
| `qwen3:8b` | 5.2 GB | 8k | ✅ | General file ops |
| `qwen3:4b` | 2.5 GB | 8k | ✅ | Quick edits, smallest footprint |
| `deepseek-coder-v2:16b` | 8.9 GB | 128k | ❌ | Read-only |
| `qwen3.5:9b` / `qwen3.5:4b` | 6.6 / ~2.5 GB | 32k | ❌ | Read-only |
| `phi4:latest` | ~5 GB | 16k | ❌ | Read-only |
| `gemma4:e4b` | ~5.5 GB | 32k | ❌ | Read-only |
| `mistral-nemo:12b-instruct-2407-q4_K_M` | 7.5 GB | 8k | ❌ | Best quality for read-only review |
| `granite3.1-moe` | 2.0 GB | 8k | ❌ | Fastest read-only analysis |

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
