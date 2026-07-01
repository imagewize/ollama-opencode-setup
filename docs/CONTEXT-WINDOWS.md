# Context Windows

> How context windows work with Ollama, Open Code CLI, and Apple Silicon Macs.

## Ollama Default Context Windows by System RAM

**CRITICAL**: Ollama automatically sets the default context window based on available system RAM. On MacBook Pro M1 (16GB) and Mac Mini M4 (24GB), **the default is 4,096 tokens** — NOT larger values. Only systems with 32GB+ RAM receive larger defaults.

| System RAM | Default Context | Affected Systems |
|------------|----------------|------------------|
| <= 24GB | **4,096 tokens** | MacBook Pro M1 (16GB), MacBook Air M1/M2 (16GB), Mac Mini M4 (24GB) |
| 32GB | 8,192 tokens | MacBook Pro M1 Max (32GB), M2 Pro (32GB) |
| 48GB | 16,384 tokens | MacBook Pro M1 Max (48GB), M1 Ultra, M2 Max (48GB+) |
| 64GB+ | 32,768 tokens | Mac Studio, Mac Pro, high-end MacBook Pro |

**Why this matters**:
- Your M4 24GB Mac Mini runs ALL base models from Ollama's registry at **4K context by default**
- System prompts + tool definitions can consume 50-75% of this window in Open Code CLI
- This leaves insufficient space for meaningful agentic workflows (analyzing multiple files, complex prompts)
- Hence the need for custom variants with baked-in extended context in this repository

### Checking Your Default

```bash
# Show the baked num_ctx for any model
ollama show <model-name> --modelfile | grep num_ctx

# For base models on <=24GB systems, this will show:
# PARAMETER num_ctx 4096
```

---

## Setting Context with Open Code (Why We Bake `num_ctx`)

Open Code connects to Ollama through its **OpenAI-compatible endpoint** (`/v1/chat/completions`, via `@ai-sdk/openai-compatible`). This endpoint **ignores `num_ctx`** — only Ollama's native `/api/*` endpoint reads it.

**What this means**:
- There is **NO** `opencode.json` field that sets the context window
- Putting `num_ctx` in provider/model `options` does nothing — it never reaches a code path Ollama honors
- Without intervention, every model runs at Ollama's RAM-based default (~4k on most M-series laptops) inside Open Code
- This is too small for agentic tool loops (system prompt + tool definitions eat much of it)

Per-request control is an open feature request upstream ([opencode#3250](https://github.com/anomalyco/opencode/issues/3250)), not yet available.

### Your Options

| Method | Scope | Notes |
|--------|-------|-------|
| **Modelfile `num_ctx`** (this repo's approach) | Per-model | Self-contained, version-controlled, survives restarts. Each model carries its own ideal context. |
| **`OLLAMA_CONTEXT_LENGTH` env var** | Global (all models) | Set once on the server; no variants to maintain. But forces one size on *every* model (RAM cost on 16GB), and a model's baked `num_ctx` can override it. |
| Per-request via `opencode.json` | — | Not supported (the `/v1` limitation above). |

**Global env-var alternative**:
```bash
# macOS Ollama.app — set, then restart Ollama:
launchctl setenv OLLAMA_CONTEXT_LENGTH 16384

# or when running serve manually:
OLLAMA_CONTEXT_LENGTH=16384 ollama serve
```

### Why This Repository Bakes It Per-Model

We run several models with different ideal contexts (Ministral, Qwen3 variants) on <=24GB machines. A single global env var would force one context on all of them — e.g., loading `qwen3:4b` at 16k for no reason, wasting RAM. 

Per-model Modelfiles (`ministral-3:8b-16k`, `ministral-3:8b-32k`, `qwen3:8b-16k`) keep each model's context appropriate and reproducible. Use the global env var instead only if you settle on one model at one context and would rather not maintain variants.

> Documented precedence is *API param > env var > Modelfile > built-in default*, but in practice a baked `num_ctx` reliably pins that specific model — which is the behavior we want.

---

## Context Window Reality Check

Understanding what different context windows can actually hold:

| Context Window | Approximate Words | Approximate Code | Typical Use Cases |
|----------------|-------------------|------------------|-------------------|
| **4k tokens** | ~3,000 words | 1 medium file | Single component analysis, quick edits |
| **8k tokens** | ~6,000 words | 1-2 medium files | Standard file operations, code reviews |
| **16k tokens** | ~12,000 words | 3-5 medium files | Multi-file analysis, related components |
| **32k tokens** | ~24,000 words | 6-10 medium files | Feature analysis across files |
| **200k tokens** | ~150,000 words | Small-medium codebase | Whole codebase analysis, architecture review |

**Important notes**:
- **Tokens != Words**: 1 token ≈ 0.75 words in English (varies by language and content type)
- **Code uses more tokens**: Technical terms, symbols, and formatting consume more tokens than natural language
- **"Medium file"**: ~500-1000 lines of code (~20-40 KB)
- **Context includes prompts**: System prompts, tool descriptions, and conversation history all consume tokens

**Practical tip**: If your prompt or file content gets cut off, your context window is too small for the task.

---

## See Also

- [CUSTOM-MODELS.md](./CUSTOM-MODELS.md) - Creating variants with extended context
- [MODEL-SELECTION.md](./MODEL-SELECTION.md) - Which models have which context baked in
- [MLX-RUNTIME.md](./MLX-RUNTIME.md) - Context and num_ctx on large models for M4 24GB+
