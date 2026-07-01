# Troubleshooting

> Common issues and solutions when using Ollama with Open Code CLI.

---

## Ollama Not Running

**Check**: `curl http://localhost:11434/v1/models`

**Fix**: `ollama serve` (or start the menubar app)

---

## Model Not Found

**Check**: `ollama list`

**Fix**: `ollama pull <model-name>`

---

## Out of Memory

**Solutions**:
1. Use smaller models: `qwen3:4b` (2.5 GB), `granite3.1-moe` (2.0 GB)
2. Close other applications
3. For M4 24GB with dense MLX: `sudo sysctl -w iogpu.wired_limit_mb=21504` then restart Ollama
4. Create a variant with lower context via Modelfile

---

## Slow Performance

### Performance Comparison

| Model | Context | Time (warm) |
|-------|---------|-------------|
| `ministral-3:8b-32k` | 32k | 4-8s |
| `ministral-3:8b-16k` | 16k | 4-10s |
| `qwen3:4b` | 8k | 5-15s |
| `qwen3:8b` | 8k | 8-20s |
| `qwen3:8b-16k` | 16k | 10-30s |

**Solutions**:
1. Use `ministral-3:8b` — fastest, no think-mode overhead
2. Use standard context when extended not needed
3. Use cloud models (Claude API) for time-sensitive work
4. Break tasks into smaller pieces

---

## "Cannot Read Binary File" Error

**Cause**: Unicode box-drawing characters (, , ) in documentation.

**Verify**: `file AGENTS.md` — should show "ASCII text" or "UTF-8 Unicode text", not "data".

**Fix**:
```bash
LC_ALL=C tr -cd '\11\12\15\40-\176' < AGENTS.md > AGENTS_clean.md
mv AGENTS_clean.md AGENTS.md
```

**Prevention**: Don't copy/paste `tree` command output into docs. Use ASCII (`-`, `*`, spaces).

---

## Model Capability Issues

### "Does Not Support Tools"

**Affected**: `deepseek-coder-v2:16b`, `phi4`, `gemma4:e4b`

**Fix**: Use confirmed tool-calling models from [MODEL-SELECTION.md](./MODEL-SELECTION.md).

### Outputs Bash Instead of Tools

**Affected**: `qwen3.5:9b` / `qwen3.5:4b`

**Fix**: Use `ministral-3` or `qwen3` variants with confirmed tool support.

---

## Open Code CLI `/init` Mode Issues

**Problem**: Agent starts in thinking mode.

**Solutions**:
1. Skip `/init` if `AGENTS.md` exists
2. Press Tab to switch to build agent
3. Create `AGENTS.md` manually

**Qwen3 Models**: Enter verbose thinking mode — this is **model behavior**, not a CLI issue. Use `ministral-3:8b` for no think-mode overhead.

---

## See Also

- [CONTEXT-WINDOWS.md](./CONTEXT-WINDOWS.md) - Context limitations
- [MODEL-SELECTION.md](./MODEL-SELECTION.md) - Tool-calling models
- [CONFIGURATION.md](./CONFIGURATION.md) - Verified models
