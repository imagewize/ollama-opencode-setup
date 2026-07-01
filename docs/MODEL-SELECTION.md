# Model Selection

> Guidelines for choosing the right model for your hardware and use case.

---

## Context Windows Reference

| Context Window | Approximate Words | Approximate Code | Typical Use Cases |
|----------------|-------------------|------------------|-------------------|
| **4k tokens** | ~3,000 words | 1 medium file | Single component analysis, quick edits |
| **8k tokens** | ~6,000 words | 1-2 medium files | Standard file operations, code reviews |
| **16k tokens** | ~12,000 words | 3-5 medium files | Multi-file analysis, related components |
| **32k tokens** | ~24,000 words | 6-10 medium files | Feature analysis across files |
| **200k tokens** | ~150,000 words | Small-medium codebase | Whole codebase analysis |

**Note**: All models with custom context (16k, 32k) have `num_ctx` baked in via Modelfiles. Base models from Ollama registry run at **4K default on <=24GB RAM systems**. See [CONTEXT-WINDOWS.md](./CONTEXT-WINDOWS.md).

---

## MacBook M1 16GB

### For Coding and File Operations (Tool Use Required)

| Priority | Model | Size | Context | Performance | Notes |
|----------|-------|------|---------|-------------|-------|
| **1. Recommended** | `ministral-3:8b-32k` | 11 GB | 32k | ~4s warm | **Best for M1 16GB** — confirmed tool usage, fastest, no think-mode, 100% GPU |
| **2. Fallback** | `ministral-3:8b-16k` | 6.5 GB | 16k | ~4-10s | Memory-constrained, 100% GPU |
| **3. Base** | `ministral-3:8b` | 6.0 GB | ~4k | ~4s | Fast, prefer 32k variant |
| **4. Extended** | `qwen3:8b-16k` | 5.2 GB | 16k | ~26s | Verbose think mode |
| **5. Standard** | `qwen3:8b` | 5.2 GB | 8k | ~26s | Think-mode overhead |
| **6. Compact** | `qwen3:4b` | 2.5 GB | 8k | ~5-15s | Quickest for single-file |

### Confirmed NO Tool Use

| Model | Size | Context | Issue |
|-------|------|---------|-------|
| `deepseek-coder-v2:16b` | 8.9 GB | 128k | Ollama: `does not support tools` — FIM model |
| `qwen3.5:9b` / `qwen3.5:4b` | 6.6 / ~2.5 GB | 32k | Outputs bash instead of tool calls |
| `mistral-nemo:12b` | 7.5 GB | 8k | Read-only, cannot create/modify files |
| `granite3.1-moe` | 2.0 GB | 8k | Read-only, cannot create/modify files |

---

## Mac Mini M4 Pro 24GB

| Priority | Model | Size | Context | Performance | Notes |
|----------|-------|------|---------|-------------|-------|
| **1. Recommended** | `mistral-small3.2:24b-32k` | 19 GB | 32k | ~? tok/s | **Best (no GPU tuning)** — dense 24B, 100% GPU at 32k. 64k spills 22% to CPU |
| **2. Coding MoE** | `qwen3-coder:30b-32k` | 21 GB | 32k | ~34.5 tok/s | Fastest — but spills ~19% to CPU at default; 98% GPU with raised `iogpu.wired_limit_mb` (21504) |
| **3. Dense MLX** | `qwen3.5:27b-mlx` | 20 GB | 256k | ~9.9 tok/s | Ollama built-in MLX engine |
| **4. Dense MLX** | `qwen3.6:27b-mlx` | 19 GB | 256k | ~9.3 tok/s | Needs raised `iogpu.wired_limit_mb` (21504) |
| **5. Lightweight** | `qwen3.5:latest` | 6.6 GB | 32k | ~18s | Confirmed tool use |

---

## Performance Benchmarks (M1 16GB)

| Model | Context | Tool Call | Time (warm) |
|-------|---------|-----------|-------------|
| `ministral-3:8b-32k` | 32k | Yes | ~4s |
| `ministral-3:8b-16k` | 16k | Yes | ~4-10s |
| `qwen3:4b` | 8k | Yes | ~5-15s |
| `qwen3:8b` | 8k | Yes | ~8-20s |
| `qwen3:8b-16k` | 16k | Yes | ~10-30s |
| Claude Sonnet 4 (cloud) | 200k | Yes | 2-5s |

**Key insight**: Ministral models have **no think-mode overhead** — significantly faster for agentic tasks.

---

## When to Use Local vs. Cloud Models

### Use Local Models (Ollama) When:
- Working offline
- Processing sensitive/proprietary code
- Running batch operations overnight
- Privacy requirements mandate local processing
- Learning/experimenting without API costs

### Use Cloud Models When:
- Real-time interactive development
- Complex multi-file operations requiring fast iteration
- Time-sensitive tasks
- Working with very large codebases (200k+ context)
- Speed is more important than cost

---

## Recommendations by Task

| Task Type | M1 16GB | M4 24GB |
|-----------|---------|---------|
| Quick single-file edit | `ministral-3:8b` or `qwen3:4b` | `qwen3.5:latest` |
| Standard file operations | `ministral-3:8b-32k` | `mistral-small3.2:24b-32k` |
| Multi-file analysis (3-5 files) | `ministral-3:8b-32k` | `qwen3-coder:30b-32k` |
| Large context analysis | `ministral-3:8b-32k` | `qwen3.5:27b-mlx` |
| Whole codebase analysis | Cloud (Sonnet 4) | Cloud or `qwen3.6:27b-mlx` |
| Read-only code review | `mistral-nemo:12b` | `mistral-nemo:12b` |

---

## See Also

- [CONFIGURATION.md](./CONFIGURATION.md) - Full model tables and Open Code setup
- [CONTEXT-WINDOWS.md](./CONTEXT-WINDOWS.md) - Understanding context defaults and extensions
- [CUSTOM-MODELS.md](./CUSTOM-MODELS.md) - Creating your own extended context variants
- [MLX-RUNTIME.md](./MLX-RUNTIME.md) - M4-specific model recommendations
