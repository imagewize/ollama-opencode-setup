# modelfiles/

Reproducible Modelfile definitions for custom Ollama model variants used with Open Code.

## Why these exist

Open Code talks to Ollama via the OpenAI-compatible (`/v1`) endpoint, which does not
forward Ollama's `num_ctx` option. Without a baked-in context size, base models run at
Ollama's small default (~2k) inside Open Code — too small for agentic tool loops.
Each Modelfile here bakes a `num_ctx` value into a named variant so the correct
context window is always active regardless of how Open Code calls the model.

## Models

| Modelfile | Base model | Context | Build command |
|---|---|---|---|
| `ministral-3-8b-16k.Modelfile` | `ministral-3:8b` | 16k | `ollama create ministral-3:8b-16k -f modelfiles/ministral-3-8b-16k.Modelfile` |
| `qwen3-8b-16k.Modelfile` | `qwen3:8b` | 16k | `ollama create qwen3:8b-16k -f modelfiles/qwen3-8b-16k.Modelfile` |

## Adding a new variant

1. Create `modelfiles/<base-model-slug>-<ctx>.Modelfile` following the existing pattern.
2. Add a row to the table above.
3. Add the new model name to `opencode.json` and `docs/LOCALLLMS.md`.
