# Documentation Index

This directory contains comprehensive documentation for running Open Code CLI with local Ollama models. Use this as your starting point to navigate the available guides and references.

## 📚 Documentation Overview

| File | Purpose | Key Topics |
|------|---------|------------|
| [LOCALLLMS.md](./LOCALLLMS.md) | **Core Configuration** | Model setup, context windows, Ollama commands, custom Modelfiles |
| [AGENTS.md](./AGENTS.md) | **Agent Workflows** | Agent modes, capabilities by model, workflow patterns, performance benchmarks |
| [OPENCODE-COMMANDS.md](./OPENCODE-COMMANDS.md) | **CLI Reference** | All slash commands, bash integration, keybindings, troubleshooting |
| [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) | **Issue Resolution** | Tool usage discovery, model limitations, hybrid workflows, model selection |

## 🎯 Getting Started

**New to this setup?** Start here:

1. **Understand the configuration** → [LOCALLLMS.md](./LOCALLLMS.md)
   - Learn how Open Code connects to local Ollama models
   - See available models and their capabilities
   - Discover how to create custom extended-context variants

2. **Learn the CLI** → [OPENCODE-COMMANDS.md](./OPENCODE-COMMANDS.md)
   - Master all 15 built-in slash commands
   - Understand bash integration (`!` prefix)
   - Learn keyboard shortcuts and navigation

3. **Explore agent workflows** → [AGENTS.md](./AGENTS.md)
   - Understand the agentic loop (how OpenCode executes tools)
   - Learn to switch between Build and Plan agents (Tab key)
   - Discover workflow patterns for different tasks
   - See performance benchmarks by model

4. **Solve issues** → [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
   - Diagnostic steps for model capability issues
   - Workarounds for models that plan but don't create files
   - Hybrid workflow strategies combining local and cloud models

## 🔧 Quick Reference

### Available Models (Confirmed Tool Use)
| Model | Size | Context | Tool Use | Speed |
|-------|------|---------|----------|-------|
| `ministral-3:8b-16k` | 6.0 GB | 16k | ✅ Yes | ~4s warm |
| `ministral-3:8b` | 6.0 GB | 4k | ✅ Yes | ~4s warm |
| `qwen3:8b-16k` | 5.2 GB | 16k | ✅ Yes | ~26s |
| `qwen3:8b` | 5.2 GB | 8k | ✅ Yes | ~26s |
| `qwen3:4b` | 2.5 GB | 4k | ✅ Yes | Fast |

### Read-Only Models (Analysis Only)
| Model | Size | Context | Tool Use | Best For |
|-------|------|---------|----------|---------|
| `mistral-nemo:12b-instruct-2407-q4_K_M` | 7.5 GB | 32k | ❌ No | Code review, analysis |
| `qwen3.5:9b` | 6.6 GB | 32k | ❌ No | Large context analysis |
| `qwen3.5:4b` | 2.5 GB | 32k | ❌ No | Light analysis |
| `granite3.1-moe` | 2.0 GB | ? | ❌ No | Fast analysis |

### Essential Ollama Commands
```bash
# List installed models
ollama list

# Pull a new model
ollama pull qwen3:8b

# Create custom variant from Modelfile
ollama create ministral-3:8b-16k -f ../modelfiles/ministral-3-8b-16k.Modelfile

# Run interactive session
ollama run qwen3:8b-16k

# Check if Ollama is running
curl http://localhost:11434/v1/models
```

## 📖 Documentation Structure

### [LOCALLLMS.md](./LOCALLLMS.md)
Comprehensive guide to local model configuration:
- **Open Code Configuration** - Provider setup, available models, `opencode.json` structure
- **Custom Model Creation** - How to create extended context variants (16k, 32k)
  - Qwen3 8B with 16k context
  - Ministral 3 8B with 16k context
- **Context Window Reality Check** - Understanding actual vs advertised context
- **Setting Context with Open Code** - Why num_ctx must be baked into custom models
- **Ollama Commands Reference** - Complete command set
- **Model Selection Guidelines** - When to use each model
- **Troubleshooting** - Common issues: Ollama not running, model not found, out of memory, performance

### [AGENTS.md](./AGENTS.md)
Complete agent workflow guide:
- **How OpenCode Works** - The agentic loop explained (model + tools + execution)
- **Agent Modes** - Build agent (default, Tab) vs Plan agent (Tab)
- **Agent Capabilities by Model** - Star ratings for each model's agent suitability
- **Agent Workflow Patterns**
  - Autonomous Task Execution
  - Iterative Refinement
  - Analysis-Then-Action
  - Batch Processing
- **Think Mode Behavior** - Understanding Qwen3 verbose thinking
- **Context Window Management** - Guidelines for 4k, 8k, 16k contexts
- **Performance Benchmarks** - Real-world timing for various task types
- **Best Practices** - Model selection, context provision, task breakdown, validation
- **Troubleshooting Agent Issues** - Stuck in thinking, context loss, low quality, slowness, hallucinations
- **Cloud vs Local** - When to use each
- **Advanced Techniques** - Chaining agents, documentation generation, code migration

### [OPENCODE-COMMANDS.md](./OPENCODE-COMMANDS.md)
Complete CLI reference:
- **Built-in TUI Slash Commands** - All 15 commands with aliases, descriptions, and keybinds
  - `/compact` / `/summarize` - Compact session
  - `/details` - Toggle tool execution details
  - `/editor` - Open external editor
  - `/exit` / `/quit` / `/q` - Exit OpenCode
  - `/export` - Export conversation to Markdown
  - `/help` - Show help dialog
  - `/init` - Create/update AGENTS.md
  - `/models` - List available models
  - `/new` / `/clear` - Start new session
  - `/redo` - Redo undone message
  - `/sessions` / `/resume` / `/continue` - Session management
  - `/share` / `/unshare` - Session sharing
  - `/themes` - List available themes
  - `/undo` - Undo last message
- **Non-existent Commands** - `/mode`, `/no_think`, `/thinking`, `/rename`, `/copy`, `/timeline`
- **Bash Commands** - Using `!` prefix to run shell commands
- **Themes** - Available theme options
- **Custom Commands** - Creating custom slash commands
- **Performance Tips** - Model switching, context management
- **Session Management** - Resuming, deleting sessions

### [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
Issue resolution guide:
- **RESOLVED: Tool Usage Requires Qwen3 Models** - Only Qwen3 models support tool usage
- **Models Not Creating Files** - Capability limitation, not a bug
- **Diagnostic Steps** - Version checks, Ollama status, model listing
- **Discovery Timeline** - How tool usage capabilities were identified
- **Tool Use Discovery Process** - Testing methodology
- **Confirmed Working Models** - Qwen3 family models
- **Non-Working Models** - Granite, Mistral Nemo (analysis only)
- **Hybrid Workflow Strategy** - Using local models for planning, cloud for execution
- **Model Selection Flowchart** - Decision tree for choosing models
- **Known Open Code CLI Issues** - Feature limitations and workarounds

## 🚀 Common Workflows

| Task | Recommended Model | Agent Mode | Documentation |
|------|------------------|------------|---------------|
| Create new project | `qwen3:8b-16k` or `ministral-3:8b-16k` | Build | [AGENTS.md](./AGENTS.md) |
| Code review | `mistral-nemo:12b-instruct-2407-q4_K_M` | Plan | [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) |
| Refactoring | `qwen3:8b-16k` | Build | [AGENTS.md](./AGENTS.md) |
| Multi-file analysis | `qwen3:8b-16k` | Plan | [AGENTS.md](./AGENTS.md) |
| Quick edits | `qwen3:4b` | Build | [LOCALLLMS.md](./LOCALLLMS.md) |
| Batch operations | `qwen3:8b` | Build | [AGENTS.md](./AGENTS.md) |

## 🔍 Search Tips

Use `grep` to search across all documentation:
```bash
# Search for "context window"
grep -r "context window" docs/

# Search for model-specific info
grep -r "ministral-3:8b-16k" docs/

# Search for troubleshooting
grep -r "tool.*usage" docs/
```

## 📝 Contribution Guide

When adding new documentation:
1. Create focused, single-purpose markdown files
2. Use consistent heading structure (##, ###, ####)
3. Include practical examples and code snippets
4. Cross-reference related documentation
5. Add to this README.md index
6. Update [opencode.json](../opencode.json) if adding new models

## 🎁 Pro Tips

1. **Bookmark frequently used sections** - The documentation is comprehensive; use browser bookmarks or editor bookmarks
2. **Use the table of contents** - Each file has a detailed TOC at the top
3. **Cross-reference** - Related topics are linked between files
4. **Check TROUBLESHOOTING.md first** - Most common issues are documented there
5. **Use AGENTS.md for workflow patterns** - Real-world patterns for different use cases
