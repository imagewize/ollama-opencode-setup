# MLX Runtime

> Mac-specific MLX engine details for Ollama on Apple Silicon (M4 24GB+).

## Overview

Ollama includes a built-in **MLX engine** that handles Apple Silicon natively — no separate MLX server needed. Models tagged `-mlx` use this engine automatically, and GGUF models on Apple Silicon also benefit from Metal-backed acceleration.

---

## Memory Ceiling on Mac Mini M4 Pro 24GB

Ollama reserves headroom for the OS, leaving **~17.3 GiB** available for model weights on a 24GB M4. This means:

- **Dense 27B MLX models** (weights >= 18 GiB) **do NOT fit** at the default limit
- **MoE models** like `qwen3-coder:30b` work because only the active parameters (3.3B) are loaded at inference time

---

## Raising the Memory Ceiling for Dense MLX Models

The 17.3 GiB ceiling comes from macOS's default GPU wired-memory limit, not from a hard Ollama cap. You can raise it with the `iogpu.wired_limit_mb` sysctl so dense 27B MLX models can load.

**Confirmed working** — `qwen3.6:27b-mlx` and `qwen3.6:27b-mlx-16k`, which OOM at the default limit, both load and pass the tool-call test after this change (tested 2026-06-28):

```bash
# Raise the GPU wired-memory limit to 21 GB (leaves ~3 GB for the OS on a 24GB Mac)
sudo sysctl -w iogpu.wired_limit_mb=21504

# IMPORTANT: restart Ollama afterward
#   - if running via `ollama serve` in a terminal: stop it (Ctrl-C) and relaunch
#   - if running as the menubar app: quit and reopen Ollama

# Verify the new limit
sysctl iogpu.wired_limit_mb   # -> iogpu.wired_limit_mb: 21504
```

### Caveats

- **Not persistent** — the sysctl resets on reboot. To make it permanent, set it from a LaunchDaemon at boot.
- **Leave OS headroom** — don't push the limit so high the system starves; 21 GB on a 24GB Mac is a safe balance.
- **Account for KV-cache** — weights + context cache must both fit under the limit.

---

## Why Ollama's Built-in MLX Is Enough

Ollama's MLX engine leans on Apple's unified memory and Metal-backed acceleration — delivering higher quality and faster output than earlier llama.cpp/GGUF paths for the same models. A separate `mlx_lm.server` setup is **no longer needed**.

---

## Recommended Models for M4 Pro 24GB

| Model | Size | Context | Tool Use | Notes |
|-------|------|---------|----------|-------|
| `mistral-small3.2:24b-32k` | 19 GB | 32k | Yes | **Recommended (no GPU tuning)** — dense 24B (Q4_K_M), 100% GPU at 32k. The 64k variant spills 22% to CPU (25 GB) — keep to 32k |
| `qwen3-coder:30b-32k` | 21 GB | 32k | Yes* | Coding-optimized MoE (3.3B active), fastest (~34.5 tok/s warm) — but spills ~19% to CPU at the default ceiling; reaches 98% GPU with raised `iogpu.wired_limit_mb` (21504) |
| `qwen3.5:27b-mlx` | 20 GB | 256k | Yes | Ollama built-in MLX engine, confirmed tool use |
| `qwen3.6:27b-mlx` | 19 GB | 256k | Yes* | Dense 27B — needs raised `iogpu.wired_limit_mb` (21504); loads & passes after that (~9.3 tok/s warm) |
| `qwen3.5:latest` | 6.6 GB | 32k | Yes | Confirmed tool use on M4 24GB (~18s) |

---

## Context and `num_ctx` on Large Models

The same `num_ctx` baking rule applies — Ollama's OpenAI-compatible endpoint ignores context length, so the base `qwen3-coder:30b` runs at **4K default** inside Open Code. Bake a variant to get the real window:

```bash
ollama create qwen3-coder:30b-32k -f ../../modelfiles/qwen3-coder-30b-32k.Modelfile
```

**GPU-footprint catch**: The 18 GB of MoE weights plus a 32k KV cache total ~21 GB, which exceeds the default ~17.3 GiB wired ceiling — so the 32k variant spills ~19% to CPU. It only runs 98% GPU after raising `iogpu.wired_limit_mb` to 21504. If you'd rather not tune the GPU limit, use `mistral-small3.2:24b-32k`, which is 100% GPU at 32k out of the box.

---

## See Also

- [CUSTOM-MODELS.md](./CUSTOM-MODELS.md) - Creating context-baked variants for MLX models
- [CONTEXT-WINDOWS.md](./CONTEXT-WINDOWS.md) - Understanding why we need to bake `num_ctx`
- [CONFIGURATION.md](./CONFIGURATION.md) - Full model list for M4 24GB
