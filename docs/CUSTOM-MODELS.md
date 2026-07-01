# Custom Models

> Creating custom model variants with extended context using Modelfiles.

**IMPORTANT**: Base models pulled from Ollama's registry have **4K default context on systems with <=24GB RAM** (including M1 16GB and M4 24GB). To use extended context with Open Code CLI, you MUST create custom variants with `num_ctx` baked in. See [CONTEXT-WINDOWS.md](./CONTEXT-WINDOWS.md) for the full explanation.

---

## Custom Model Creation

Custom variants with `num_ctx` baked in are needed because Open Code talks to Ollama via the OpenAI-compatible endpoint, which does **not** pass Ollama's `num_ctx` — so base models run at Ollama's RAM-based default context inside Open Code.

Each variant in this repository has a committed Modelfile for reproducible builds.

### Creating Qwen3 8B with Extended Context (16k)

The `qwen3:8b-16k` model is a custom variant created from the base `qwen3:8b` model with `num_ctx` baked in.

```bash
# From the repo root
ollama create qwen3:8b-16k -f modelfiles/qwen3-8b-16k.Modelfile

# Verify
ollama show qwen3:8b-16k --modelfile | grep num_ctx
# PARAMETER num_ctx 16384
```

**Verification**:
```bash
ollama list
# Output:
# NAME                                     ID              SIZE      MODIFIED
# qwen3:8b-16k                             7ef4ca800d20    5.2 GB    9 seconds ago
# qwen3:8b                                 500a1f067a9f    5.2 GB    18 hours ago
```

### Creating Ministral 3 8B with Extended Context (32k) — Recommended

`ministral-3:8b-32k` is the **recommended** Open Code variant — tested 2026-06-01 on M1 16GB: **100% GPU, 11 GB footprint**. 

Ollama docs recommend at least 32k context for agentic tools; 64k was tested but causes 27% CPU spillover on M1 16GB.

```bash
# From the repo root
ollama create ministral-3:8b-32k -f modelfiles/ministral-3-8b-32k.Modelfile

# Verify
ollama show ministral-3:8b-32k --modelfile | grep num_ctx
# PARAMETER num_ctx 32768
```

### Creating Ministral 3 8B with Extended Context (16k) — Fallback

`ministral-3:8b-16k` is the memory-constrained fallback — 100% GPU at ~6.5 GB. Use this if 32k causes issues on your machine.

```bash
ollama create ministral-3:8b-16k -f modelfiles/ministral-3-8b-16k.Modelfile
```

The base model natively supports up to 256k context. 32k is the recommended sweet spot on M1 16GB; 64k saturates all 16 GB and spills to CPU.

---

## Benefits of Extended Context

- **16k tokens** vs standard 8k allows for larger code files and more context
- Useful for analyzing entire application architectures
- Better for reviewing multiple related files in a single prompt
- No increase in model size (same 5.2 GB as base model for qwen3:8b variants)

---

## Available Modelfiles

This repository includes pre-configured Modelfiles in [`modelfiles/`](../modelfiles/) directory:

| Modelfile | Base Model | Context | Notes |
|-----------|------------|---------|-------|
| `ministral-3-8b-32k.Modelfile` | ministral-3:8b | 32k | **Recommended for M1 16GB** — 100% GPU |
| `ministral-3-8b-16k.Modelfile` | ministral-3:8b | 16k | Memory-constrained fallback |
| `qwen3-8b-16k.Modelfile` | qwen3:8b | 16k | Standard extended context |
| `mistral-small3.2-24b-32k.Modelfile` | mistral-small3.2:24b | 32k | **Recommended for M4 24GB** — no GPU tuning |
| `qwen3-coder-30b-32k.Modelfile` | qwen3-coder:30b | 32k | M4 24GB, needs raised GPU limit |

**Usage**:
```bash
# General pattern (run from repo root)
ollama create <new-name> -f modelfiles/<Modelfile>.Modelfile

# Example: Create all recommended variants
ollama create ministral-3:8b-32k -f modelfiles/ministral-3-8b-32k.Modelfile
ollama create ministral-3:8b-16k -f modelfiles/ministral-3-8b-16k.Modelfile
ollama create qwen3:8b-16k -f modelfiles/qwen3-8b-16k.Modelfile
```

---

## Creating Your Own Modelfiles

To create a custom variant with specific context:

1. **Pull the base model first**:
   ```bash
   ollama pull <base-model-name>
   ```

2. **Create a Modelfile**:
   ```bash
   # Example: ministral-3-8b-32k.Modelfile
   FROM ministral-3:8b
   PARAMETER num_ctx 32768
   ```

3. **Create the variant**:
   ```bash
   ollama create <new-name> -f <path-to-Modelfile>
   ```

4. **Verify**:
   ```bash
   ollama show <new-name> --modelfile | grep num_ctx
   ```

---

## See Also

- [CONTEXT-WINDOWS.md](./CONTEXT-WINDOWS.md) - Why we need to bake `num_ctx` and how defaults work
- [CONFIGURATION.md](./CONFIGURATION.md) - Available models and their context settings
- [MLX-RUNTIME.md](./MLX-RUNTIME.md) - Custom models for M4 24GB+ with MLX engine
