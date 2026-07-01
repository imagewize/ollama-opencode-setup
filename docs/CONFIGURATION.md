# Configuration

> Open Code CLI configuration with local Ollama models.

## Open Code Configuration

Open Code is configured via [`opencode.json`](../opencode.json) in the repository root. This file defines available LLM providers and models.

### Current Configuration

**Provider**: Ollama (local)
- **Base URL**: `http://localhost:11434/v1`
- **NPM Package**: `@ai-sdk/openai-compatible`

> **Note on context**: The OpenAI-compatible endpoint does NOT respect `num_ctx` parameters. For extended context, you must use custom model variants with `num_ctx` baked in. See [CONTEXT-WINDOWS.md](./CONTEXT-WINDOWS.md) for details.

---

## Available Models

**Tool usage** = can create/modify files in Open Code CLI. Read-only models can analyze code but cannot write files.

### MacBook M1 16GB — Tool Use Confirmed

| Model | Size | Context | Tool Usage | Description |
|-------|------|---------|------------|-------------|
| `ministral-3:8b-32k` | 11 GB | 32k | Yes | **Recommended for M1 16GB** — custom 32k variant, 100% GPU, fastest tool-caller (~4s warm) |
| `ministral-3:8b-16k` | 6.5 GB | 16k | Yes | Memory-constrained fallback — 100% GPU, smaller footprint |
| `ministral-3:8b` | 6.0 GB | ~4k default | Yes | Base model — fast, no think-mode tax; prefer the 32k variant for agentic use |
| `qwen3:8b-16k` | 5.2 GB | 16k | Yes | Custom 16k variant — verbose think mode (~26s) |
| `qwen3:8b` | 5.2 GB | 8k | Yes | Standard Qwen3 8B — ~26s for a write tool call (think-mode overhead) |
| `qwen3:4b` | 2.5 GB | 8k | Yes | Compact, quick for single-file edits |

### Mac Mini M4 Pro 24GB — Tool Use Confirmed

| Model | Size | Context | Tool Usage | Description |
|-------|------|---------|------------|-------------|
| `mistral-small3.2:24b-32k` | 19 GB | 32k | Yes | **Recommended for M4 24GB (no GPU tuning)** — dense 24B, 100% GPU at 32k, tool use confirmed (tested 2026-06-30). The 64k variant spills 22% to CPU (25 GB) — use 32k. The base model refuses with prose if a tool schema asks for an "absolute path" — keep descriptions neutral |
| `qwen3-coder:30b-32k` | 21 GB | 32k | Yes* | Coding-optimized MoE (3.3B active), fastest (~34.5 tok/s warm) — but spills ~19% to CPU at the default ceiling; 98% GPU only with raised `iogpu.wired_limit_mb` (21504), tested 2026-06-30. Base `qwen3-coder:30b` runs at 4k in Open Code — use this variant |
| `qwen3.6:27b-mlx` | 19 GB | 256k | Yes* | Dense 27B — OOM at default GPU limit; loads after raising `iogpu.wired_limit_mb` to 21504 (~9.3 tok/s warm; ~3.3 tok/s cold, tested 2026-06-28). Slower than the MoE; use `qwen3-coder:30b-32k` for speed |
| `qwen3.5:27b-mlx` | 20 GB | 256k | Yes | Ollama built-in MLX engine — confirmed tool use (9.9 tok/s, tested 2026-06-28) |
| `qwen3.5:latest` | 6.6 GB | 32k | Yes | Tool use confirmed on M4 24GB (~18s, tested 2026-06-28) |

### Read-Only (No Tool Use — Analysis Only)

| Model | Size | Context | Notes |
|-------|------|---------|-------|
| `deepseek-coder-v2:16b` | 8.9 GB | 128k | Ollama reports `does not support tools`; FIM/completion model |
| `qwen3.5:9b` / `qwen3.5:4b` | 6.6 / ~2.5 GB | 32k | Outputs bash instead of write tool |
| `phi4:latest` | ~5 GB | 16k | Open Code explicitly reports "does not support tools" |
| `gemma4:e4b` | ~5.5 GB | 32k | Malformed tool call — file not created |
| `mistral-nemo:12b-instruct-2407-q4_K_M` | 7.5 GB | 8k | Best quality for read-only review |
| `granite3.1-moe:latest` | 2.0 GB | 8k | Fastest read-only analysis |

---

## Updating Configuration

When adding or removing Ollama models, update [`opencode.json`](../opencode.json):

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (local)",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "model-name": {
          "name": "Display Name"
        }
      }
    }
  }
}
```

---

## See Also

- [CUSTOM-MODELS.md](./CUSTOM-MODELS.md) - Creating models with extended context
- [MODEL-SELECTION.md](./MODEL-SELECTION.md) - Choosing the right model for your task
- [CONTEXT-WINDOWS.md](./CONTEXT-WINDOWS.md) - Understanding context defaults and how to extend them
