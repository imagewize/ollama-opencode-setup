# Ollama + Open Code Setup

Complete configuration and documentation for running Open Code CLI with local Ollama models.

## Quick Start

### Prerequisites

1. **Install Ollama**: [ollama.ai](https://ollama.ai)
2. **Install Open Code CLI**: [opencode.ai](https://opencode.ai)

### Setup

1. **Clone this repository:**
   ```bash
   git clone https://github.com/YOUR-USERNAME/ollama-opencode-setup.git ~/code/ollama-opencode-setup
   ```

2. **Start Ollama:**
   ```bash
   ollama serve
   ```

3. **Pull your first model:**
   ```bash
   ollama pull qwen3:8b
   ```

4. **Use the configuration in your project:**
   ```bash
   # Option 1: Symlink into your project
   ln -s ~/code/ollama-opencode-setup/opencode.json ~/code/your-project/opencode.json

   # Option 2: Copy into your project
   cp ~/code/ollama-opencode-setup/opencode.json ~/code/your-project/opencode.json
   ```

5. **Run Open Code:**
   ```bash
   cd ~/code/your-project
   opencode
   ```

## What's Included

- **[opencode.json](opencode.json)** - Open Code configuration for Ollama models
- **[docs/LOCALLLMS.md](docs/LOCALLLMS.md)** - Complete documentation on local LLM setup
- **[examples/](examples/)** - Example workflows and prompts

## Available Models

| Model | Size | Context | Best For |
|-------|------|---------|----------|
| `qwen3:8b-16k` | 5.2 GB | 16k | Multi-file analysis |
| `mistral-nemo:12b-instruct-2407-q4_K_M` | 7.5 GB | 8k | Code generation |
| `qwen3:8b` | 5.2 GB | 8k | General development |
| `granite3.1-moe:latest` | 2.0 GB | 8k | Quick tasks |
| `qwen3:4b` | 2.5 GB | 8k | Fast responses |

## Common Commands

### Ollama Management
```bash
# List installed models
ollama list

# Run a model interactively
ollama run qwen3:8b

# Pull a new model
ollama pull mistral-nemo:12b-instruct-2407-q4_K_M

# Remove a model
ollama rm qwen3:4b
```

### Creating Custom Models

Create a model with extended context (16k):
```bash
# Start interactive session
ollama run qwen3:8b

# Set extended context
>>> /set parameter num_ctx 16384
Set parameter 'num_ctx' to '16384'

# Save as new model
>>> /save qwen3:8b-16k
Created new model 'qwen3:8b-16k'

# Exit
>>> /bye
```

### Open Code Usage

```bash
# Run with default model
opencode run "create a todo.md file"

# Specify model
opencode run "analyze this codebase" --model ollama/qwen3:8b-16k

# Interactive session
opencode
```

## Performance Tips

**Use the right model for the task:**

- **Quick edits** → `qwen3:4b` or `granite3.1-moe` (fastest)
- **Code generation** → `mistral-nemo:12b-instruct-2407-q4_K_M` (best quality)
- **Multi-file analysis** → `qwen3:8b-16k` (extended context)
- **Standard tasks** → `qwen3:8b` (balanced)

**Performance expectations:**

| Task | Local Model (8k) | Local Model (16k) | Claude Sonnet 4 |
|------|-----------------|-------------------|-----------------|
| Simple file write | 8-20s | 10-30s | 2-5s |
| Code review | 15-40s | 20-60s | 5-15s |
| Multi-file analysis | N/A (context limit) | 30-90s | 10-30s |

## When to Use Local vs Cloud Models

### Use Local Models (Ollama) When:
- Working offline
- Processing sensitive/proprietary code
- Running batch operations overnight
- Learning/experimenting without API costs
- Privacy requirements mandate local processing

### Use Cloud Models (Claude API) When:
- Real-time interactive development
- Complex multi-file operations requiring fast iteration
- Time-sensitive tasks
- Working with very large codebases (200k+ context)
- Speed is more important than cost

## Documentation

See [docs/LOCALLLMS.md](docs/LOCALLLMS.md) for comprehensive documentation including:
- Custom model creation
- Context window comparison (4k vs 8k vs 16k vs 200k)
- Ollama commands reference
- Model selection guidelines
- Troubleshooting guide
- Performance optimization

## Examples

Check the [examples/](examples/) directory for:
- Code review workflows
- Refactoring prompts
- Multi-file analysis examples
- Batch processing scripts

## Troubleshooting

### Ollama Not Running
```bash
# Check if Ollama is running
curl http://localhost:11434/v1/models

# Start Ollama
ollama serve
```

### Model Not Found
```bash
# Verify model exists
ollama list

# Pull model if missing
ollama pull qwen3:8b
```

### Slow Performance
- Use smaller models for simple tasks (`qwen3:4b`)
- Use standard context when extended context isn't needed (`qwen3:8b` instead of `qwen3:8b-16k`)
- Consider cloud models for time-sensitive work

See [docs/LOCALLLMS.md#troubleshooting](docs/LOCALLLMS.md#troubleshooting) for more details.

## Resources

- [Ollama Documentation](https://github.com/ollama/ollama)
- [Open Code Documentation](https://opencode.ai/docs)
- [Qwen3 Model Card](https://huggingface.co/Qwen/Qwen3-8B)
- [Mistral Nemo Documentation](https://mistral.ai/news/mistral-nemo/)

## Contributing

Contributions welcome! Please feel free to submit issues or pull requests with:
- New model configurations
- Performance optimizations
- Example workflows
- Documentation improvements

## License

MIT
