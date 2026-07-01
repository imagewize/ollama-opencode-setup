# Ollama Commands Reference

> Complete reference for Ollama CLI commands.

---

## Basic Commands

| Command | Description |
|---------|-------------|
| `ollama list` | List all installed models |
| `ollama run <model>` | Start interactive session |
| `ollama pull <model>` | Download a model from registry |
| `ollama rm <model>` | Delete an installed model |
| `ollama show <model>` | Display model details |
| `ollama show <model> --modelfile` | Show Modelfile parameters |

---

## Model Management

### Create Model from Modelfile
```bash
ollama create <new-name> -f <path-to-Modelfile>

# Examples (run from repo root):
ollama create ministral-3:8b-32k -f modelfiles/ministral-3-8b-32k.Modelfile
ollama create qwen3:8b-16k -f modelfiles/qwen3-8b-16k.Modelfile
```

### Copy a Model
```bash
ollama cp <source-model> <new-name>
```

---

## Server Management

### Check if Ollama Is Running
```bash
curl http://localhost:11434/v1/models
```

### Start Ollama Service
```bash
ollama serve
```

### Start with Custom Context (Global)
```bash
OLLAMA_CONTEXT_LENGTH=16384 ollama serve
```

For macOS Ollama.app:
```bash
launchctl setenv OLLAMA_CONTEXT_LENGTH 16384
# Then quit and reopen Ollama
```

---

## Model Import/Export

### Export Model
```bash
ollama export <model-name> > model.tar
```

### Import Model
```bash
ollama import model.tar
```

---

## Interactive Commands

Within `ollama run <model>` session:

| Command | Description |
|---------|-------------|
| `/set parameter <name> <value>` | Modify model parameters |
| `/save <new-name>` | Save current configuration |
| `/show` | Display model information |
| `/bye` | Exit session |

---

## See Also

- [CUSTOM-MODELS.md](./CUSTOM-MODELS.md) - Modelfile examples
- [CONTEXT-WINDOWS.md](./CONTEXT-WINDOWS.md) - Understanding context parameters
