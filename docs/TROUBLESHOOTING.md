# Open Code CLI Troubleshooting Guide

## ✅ RESOLVED: Tool Usage Requires Qwen3 Models

### Discovery (2025-11-18)
**Only Qwen3 models have tool usage capabilities with Open Code CLI!**

**Root Cause:** Tool/function calling requires specific model training. Qwen3 family has built-in function calling capabilities, while Mistral Nemo and Granite models lack this training.

**Working models:**
- ✅ **qwen3:8b-16k** - TESTED & CONFIRMED working
- ✅ **qwen3:8b** - Likely works (same family, needs testing)
- ✅ **qwen3:4b** - Likely works (same family, needs testing)

**Non-working models (analysis only):**
- ❌ granite3.1-moe:latest - Plans but doesn't execute
- ❌ mistral-nemo:12b-instruct-2407-q4_K_M - Excellent analysis but no file creation

---

## Issue: Models Not Creating Files

### Problem
Some Ollama models understand tasks but **do not execute file creation commands**.

**Symptoms:**
- Model generates task descriptions/plans
- Model shows understanding of the request
- **No actual file is created**
- Terminal shows planning output but no action

**This is NOT a bug - it's a model capability limitation!**

---

## Diagnostic Steps

### Step 1: Verify Open Code CLI Setup

```bash
# Check Open Code CLI version
opencode --version

# Verify Ollama is running
curl http://localhost:11434/v1/models

# Check available models
ollama list
```

### Step 2: Test with Different Prompts

Try these progressively more explicit prompts:

**Test A: Original prompt**
```bash
opencode
> Create a todo.md file with 3 sample tasks
```

**Test B: Explicit mode directive**
```bash
opencode
> /mode build
> Create a todo.md file with 3 sample tasks
```

**Test C: Tool-specific instruction**
```bash
opencode
> Use the write tool to create a file called todo.md with 3 tasks
```

**Test D: Simple file write**
```bash
opencode
> Write a file called hello.txt with the text "Hello World"
```

**Test E: Code generation (sometimes works better)**
```bash
opencode
> Create a hello.py file that prints "Hello World"
```

### Step 3: Check Open Code CLI Agent Configuration

Open Code CLI may require specific configuration for agent/tool usage. Check:

```bash
# Look for Open Code CLI config
cat ~/.opencode/config.json

# Check if there's a workspace-specific config
cat .opencode/config.json
```

### Step 4: Compare with Cloud Model (Claude)

To isolate whether this is an Ollama-specific issue:

```bash
# Test with Claude (if you have API key configured)
opencode --model claude-sonnet-4
> Create a todo.md file with 3 sample tasks
```

If Claude works but Ollama doesn't, this is a **local model tool usage** issue.

---

## ✅ Solution: Use Qwen3 Models for File Operations

### Primary Solution: Switch to Qwen3 Models

**For ANY task requiring file creation or modification, use Qwen3 models:**

```bash
# Recommended: qwen3:8b-16k (tested and confirmed working)
opencode --model ollama/qwen3:8b-16k
> Create a todo.md file with 3 sample tasks
# ✅ This works!
```

**Alternative Qwen3 models (likely also work):**
```bash
# Standard context (faster than 16k)
opencode --model ollama/qwen3:8b
> Add type hints to utils/helpers.py

# Small/fast variant
opencode --model ollama/qwen3:4b
> Create a simple hello.py file
```

### Tool Call Format

Qwen3 models use this format to call file tools:
```json
{
  "name": "write",
  "arguments": {
    "content": "# Todo List\n\n- Task 1\n- Task 2",
    "filePath": "/absolute/path/to/file.md"
  }
}
```

### Think Mode Handling

Qwen3 models enter verbose "thinking mode" before execution:
- **Accept it** - Think mode doesn't prevent file creation
- **Benefit** - Provides detailed reasoning about the task
- **Workaround** - Use `/mode build` to minimize thinking (may not fully suppress)

```bash
opencode --model ollama/qwen3:8b-16k
> /mode build
> Create a todo.md file with 3 tasks
# Still shows some thinking, but completes successfully
```

### Why Custom Prompts Won't Help

**Important:** Custom system prompts or Modelfiles will NOT add tool usage to models lacking this capability:

```bash
# ❌ This will NOT work - Mistral Nemo lacks tool training
ollama create opencode-mistral -f custom-modelfile.txt
opencode --model ollama/opencode-mistral
> Create a file
# Still won't create files - model lacks function calling ability
```

Tool usage requires specific training data and model architecture changes, not just prompt engineering.

---

## Use Cases by Model Type

### ✅ Qwen3 Models (Full Tool Usage)

**Use for:**
- ✅ File creation and modification
- ✅ Code generation
- ✅ Refactoring with file changes
- ✅ Multi-file operations
- ✅ Code review (read-only)
- ✅ Analysis and planning

**Example workflows:**
```bash
# File creation
opencode --model ollama/qwen3:8b-16k
> Create a Python class for user authentication

# Refactoring
> Refactor UserService to use dependency injection

# Multi-file changes
> Add type hints to all files in src/utils/
```

### ⚠️ Mistral Nemo & Granite (Analysis Only)

**Use for:**
- ✅ Code review (read-only)
- ✅ Analysis and suggestions
- ✅ Architecture planning
- ✅ Documentation review
- ❌ **CANNOT create or modify files**

**Example workflows:**
```bash
# Code review (works great)
opencode --model ollama/mistral-nemo:12b-instruct-2407-q4_K_M
> /mode review
> Analyze the security of src/auth/ directory

# Planning (works great)
> /mode plan
> Analyze the codebase architecture and suggest improvements

# Implementation (FAILS - no file creation)
> /mode build
> Implement the suggested improvements
# ❌ Will analyze but NOT create files
```

### Hybrid Workflow (Best of Both)

Use different models for different phases:

```bash
# Phase 1: Analysis with Mistral Nemo (best quality)
opencode --model ollama/mistral-nemo:12b-instruct-2407-q4_K_M
> /mode review
> Review src/auth/ for security issues
# ✅ Get excellent analysis and recommendations

# Phase 2: Implementation with Qwen3 (tool usage)
opencode --model ollama/qwen3:8b-16k
> /mode build
> Implement the security fixes recommended above
# ✅ Actually creates/modifies files
```

---

## Common Issues & Solutions

### Issue: "Model plans but doesn't create files"

**Cause:** Using Mistral Nemo or Granite for file operations

**Solution:** Switch to Qwen3 model
```bash
# Instead of this:
opencode --model ollama/mistral-nemo:12b-instruct-2407-q4_K_M
> Create a file

# Use this:
opencode --model ollama/qwen3:8b-16k
> Create a file
```

### Issue: "A tool-capable model returns prose instead of calling the tool"

**Cause:** Some assistant-tuned models (e.g. `mistral-small3.2`, Mistral's "Le Chat" persona) refuse a write/edit task with prose — *"I'm sorry, I don't have the capability to create files"* — when the **tool schema's path description demands an "absolute path."** The model reasons it can't know the absolute path on your filesystem and abandons the tool call entirely. It is **not** a real tool-use deficiency.

**Diagnosis (tested 2026-06-30, `mistral-small3.2:24b-32k`):** identical request, only the `filePath` description changed:

| `filePath` description | Result |
|---|---|
| `"Absolute path of the file to write"` | 3/3 ❌ prose refusal |
| `"Path of the file to write"` | 3/3 ✅ `write` tool call |

It is **not** a cold-vs-warm or context issue — the model was warm (100% GPU) during every failure.

**Solution:** keep tool-parameter descriptions neutral — `"Path of the file to write"`, not `"Absolute path …"`. `scripts/tool-call-test.sh` already uses neutral wording. If you hit this in Open Code with a custom tool, audit the tool's parameter descriptions.

### Issue: "Verbose thinking mode slows down tasks"

**Cause:** Qwen3 models have built-in thinking behavior

**Solutions:**
1. **Accept it** - File still gets created successfully
2. **Use `/mode build`** - May reduce (but not eliminate) thinking
3. **Consider the benefit** - Think mode provides useful reasoning
4. **Use smaller model** - qwen3:8b or qwen3:4b may be faster

### Issue: "Want best code quality AND file creation"

**Cause:** Mistral Nemo has best quality but no tool usage

**Solution:** Hybrid approach
```bash
# Get analysis from Mistral Nemo
opencode --model ollama/mistral-nemo:12b-instruct-2407-q4_K_M
> /mode plan
> Design the authentication system

# Implement with Qwen3
opencode --model ollama/qwen3:8b-16k
> /mode build
> Implement the authentication system designed above
```

---

## Resources

- [Open Code CLI Documentation](https://opencode.ai/docs)
- [Ollama Function Calling](https://ollama.com/blog/tool-support)
- [Qwen3 Tool Usage](https://qwen.readthedocs.io/en/latest/framework/function_call.html)
- [Open Code GitHub Issues](https://github.com/opencodeai/opencode/issues)

---

## Quick Reference

### Model Selection Flowchart

```
Need to create/modify files?
├─ YES → Use Qwen3 models
│   ├─ Multi-file/complex → qwen3:8b-16k (16k context)
│   ├─ Standard tasks → qwen3:8b (8k context, faster)
│   └─ Simple/quick → qwen3:4b (fastest)
│
└─ NO (analysis only) → Any model
    ├─ Best quality → mistral-nemo:12b-instruct-2407-q4_K_M
    ├─ Fast analysis → granite3.1-moe
    └─ Extended context → qwen3:8b-16k
```

### Command Templates

**File creation (Qwen3 required):**
```bash
opencode --model ollama/qwen3:8b-16k
> Create/modify/refactor [description]
```

**Code review (any model):**
```bash
opencode --model ollama/mistral-nemo:12b-instruct-2407-q4_K_M
> /mode review
> Review [file/directory]
```

**Hybrid workflow:**
```bash
# Step 1: Analyze
opencode --model ollama/mistral-nemo:12b-instruct-2407-q4_K_M
> /mode plan
> [analysis task]

# Step 2: Implement
opencode --model ollama/qwen3:8b-16k
> /mode build
> [implementation task]
```

---

## Ollama Service Checks

### Ollama Not Running

**Check**: `curl http://localhost:11434/v1/models`

**Fix**: `ollama serve` (or start the menubar app)

### Model Not Found

**Check**: `ollama list`

**Fix**: `ollama pull <model-name>`

### Out of Memory

**Solutions**:
1. Use smaller models: `qwen3:4b` (2.5 GB), `granite3.1-moe` (2.0 GB)
2. Close other applications
3. For M4 24GB with dense MLX: `sudo sysctl -w iogpu.wired_limit_mb=21504` then restart Ollama (see [MLX-RUNTIME.md](./MLX-RUNTIME.md))
4. Create a variant with lower context via Modelfile

### "Cannot Read Binary File" Error

**Cause**: Unicode box-drawing characters in documentation files.

**Verify**: `file <filename>.md` — should show "ASCII text" or "UTF-8 Unicode text", not "data".

**Fix**:
```bash
LC_ALL=C tr -cd '\11\12\15\40-\176' < file.md > file_clean.md
mv file_clean.md file.md
```

**Prevention**: Don't copy/paste `tree` command output into docs. Use ASCII (`-`, `*`, spaces) instead of box-drawing characters.

---

## Update Log

**2025-11-18:**
- ✅ **RESOLVED:** Confirmed Qwen3 models have tool usage capabilities
- ✅ **TESTED:** qwen3:8b-16k successfully creates files
- ❌ **CONFIRMED:** granite3.1-moe and mistral-nemo:12b-instruct-2407-q4_K_M lack tool usage
- 📝 **DOCUMENTED:** Root cause is model training, not Open Code CLI issue
- 📝 **PUBLISHED:** Workarounds and hybrid workflow strategies
