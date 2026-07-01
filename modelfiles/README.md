# modelfiles/

Reproducible Modelfile definitions for custom Ollama model variants used with Open Code.

## Why these exist

Open Code talks to Ollama via the OpenAI-compatible (`/v1`) endpoint, which does not
forward Ollama's `num_ctx` option. Without a baked-in context size, base models run at
Ollama's small default (~2k) inside Open Code — too small for agentic tool loops.
Each Modelfile here bakes a `num_ctx` value into a named variant so the correct
context window is always active regardless of how Open Code calls the model.

## Models

| Modelfile | Base model | Context | GPU fit (tested) | Build command |
|---|---|---|---|---|
| `ministral-3-8b-32k.Modelfile` | `ministral-3:8b` | 32k | ✅ 100% GPU, 11 GB (M1 16GB) | `ollama create ministral-3:8b-32k -f modelfiles/ministral-3-8b-32k.Modelfile` |
| `ministral-3-8b-16k.Modelfile` | `ministral-3:8b` | 16k | ✅ 100% GPU, ~6.5 GB (M1 16GB) | `ollama create ministral-3:8b-16k -f modelfiles/ministral-3-8b-16k.Modelfile` |
| `qwen3-8b-16k.Modelfile` | `qwen3:8b` | 16k | ✅ 100% GPU, ~6.5 GB (M1 16GB) | `ollama create qwen3:8b-16k -f modelfiles/qwen3-8b-16k.Modelfile` |
| `mistral-small3.2-24b-32k.Modelfile` | `mistral-small3.2:latest` | 32k | ✅ 100% GPU, 19 GB (M4 24GB) | `ollama create mistral-small3.2:24b-32k -f modelfiles/mistral-small3.2-24b-32k.Modelfile` |
| `qwen3-coder-30b-32k.Modelfile` | `qwen3-coder:30b` | 32k | ⚠️ 19% CPU spill, 21 GB at default ceiling; 98% GPU only with `wired_limit 21504` (M4 24GB) | `ollama create qwen3-coder:30b-32k -f modelfiles/qwen3-coder-30b-32k.Modelfile` |
| `mistral-small3.2-24b-64k.Modelfile` | `mistral-small3.2:latest` | 64k | ❌ 22% CPU spillover, 25 GB (M4 24GB, wired_limit 21504) | `ollama create mistral-small3.2:24b-64k -f modelfiles/mistral-small3.2-24b-64k.Modelfile` |
| `ministral-3-8b-64k.Modelfile` | `ministral-3:8b` | 64k | ❌ 27% CPU spillover, 16 GB (M1 16GB) | `ollama create ministral-3:8b-64k -f modelfiles/ministral-3-8b-64k.Modelfile` |

## Adding a new variant

1. Create `modelfiles/<base-model-slug>-<ctx>.Modelfile` following the existing pattern.
2. Add a row to the table above.
3. Add the new model name to `opencode.json` and `docs/CONFIGURATION.md`.
